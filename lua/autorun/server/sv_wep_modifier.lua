util.AddNetworkString("NebulaWeapons:UpdateWeapon")
util.AddNetworkString("NebulaWeapons:DeleteWeapon")

-- Net

net.Receive("NebulaWeapons:UpdateWeapon", function(l, ply)
    if not ply:IsSuperAdmin() then return end

    local wep = net.ReadString()
    local data = net.ReadTable()

    local wepTable = weapons.GetStored(wep)

    for k, v in pairs(data) do
        if istable(v) then
            for i, d in pairs(v) do
                wepTable[k][i] = d
            end
        else
            wepTable[k] = v
        end
    end

    http.Post(NebulaAPI.HOST .. "weapons/upload", {
        class = wep,
        data = util.TableToJSON(data)
    }, function(res)
        net.Start("NebulaWeapons:UpdateWeapon")
        net.Broadcast()

        MsgN("[Nebula] Weapon " .. wep .. " has been updated.")
    end, function(err) end, {
        authorization = NebulaAPI.API_KEY
    })
end)

net.Receive("NebulaWeapons:DeleteWeapon", function(l, ply)
    if not ply:IsSuperAdmin() then return end

    local wep = net.ReadString()

    http.Post(NebulaAPI.HOST .. "weapons/delete", {
        class = wep,
    }, function(res)
        local wepTable = weapons.GetStored(wep)
        wepTable = NebulaWeapons.Cache[wep] or wepTable

        net.Start("NebulaWeapons:UpdateWeapon")
        net.Broadcast()

        MsgN("[Nebula] Weapon " .. wep .. " has been reset.")
    end, function(err) end, {
        authorization = NebulaAPI.API_KEY
    })
end)

local commands = {
    ["!buyammo"] = true,
    ["!buyuniammo"] = true,
    ["!buyallammo"] = true,
}

hook.Add("PlayerSay", "NebulaRP.ReplenishAmmo", function(ply, text)
    if commands[text] then
        local types = {}

        for k, v in pairs(ply:GetWeapons()) do
            if v.Primary and not types[v.Primary.Ammo] then
                types[v.Primary.Ammo] = true
                ply:GiveAmmo(100, v.Primary.Ammo)
            end
        end

        ply:addMoney(-1000)
        ply:PrintMessage(HUD_PRINTTALK, "You bought ammo for all your weapons!")

        return ""
    end
end)

hook.Add("PlayerSpawn", "CheckWeaponUpdate", function(ply)
    RunConsoleCommand("nebula_update_weapon")
    hook.Remove("PlayerSpawn", "CheckWeaponUpdate")
end)

local ammoCages = {
    ["models/mailer/bl2_props/banditammocrate.mdl"] = true,
    ["models/mailer/bl2_props/dahlammocrate.mdl"] = true,
}
hook.Add("PlayerUse", "OnUseEntity", function(ply, ent)
    if (ply.nextUse or 0) > CurTime() then return end

    if ammoCages[ent:GetModel()] then
        local types = {}

        for k, v in pairs(ply:GetWeapons()) do
            local ammoType = v:GetPrimaryAmmoType()
            if (ply:GetAmmoCount(ammoType) > v:Clip1() * 5) then continue end
            ply:GiveAmmo(v:Clip1() * 5, ammoType)
        end

        ply:PrintMessage(HUD_PRINTTALK, "<color=green>You picked up ammo for all your weapons!</color>")
        ply:EmitSound("items/ammo_pickup.wav")
        ply.nextUse = CurTime() + 5
    else
        ply.nextUse = CurTime() + 1
    end
end)

concommand.Add("nebula_update_weapon", function(ply, cmd, args)
    if IsValid(ply) then return end
    http.Fetch(NebulaAPI.HOST .. "weapons/fetch", function(res)
        local update = util.JSONToTable(res)
        for wep, data in pairs(update) do
            local wepTable = weapons.GetStored(wep)

            for k, v in pairs(data) do
                if istable(v) then
                    for i, d in pairs(v) do
                        wepTable[k][i] = d
                    end
                else
                    wepTable[k] = v
                end
            end
            MsgN("[Nebula] Weapon " .. wep .. " has been updated.")
        end

    end, function(err) end, {
        authorization = NebulaAPI.API_KEY
    })
end)

timer.Simple(5, function()
    DarkRP.declareChatCommand{
        command = "buyammo",
        description = "Buys ammo",
        delay = 1.5
    }

    DarkRP.declareChatCommand{
        command = "buyuniammo",
        description = "Buys ammo",
        delay = 1.5
    }

    DarkRP.declareChatCommand{
        command = "buyallammo",
        description = "Buys ammo",
        delay = 1.5
    }

    local function buyAmmo(ply, args)
        local types = {}

        for k, v in pairs(ply:GetWeapons()) do
            if v.Primary and not types[v.Primary.Ammo] then
                types[v.Primary.Ammo] = true
                ply:GiveAmmo(100, v.Primary.Ammo)
            end
        end

        ply:addMoney(-1000)
        ply:PrintMessage(HUD_PRINTTALK, "You bought ammo for all your weapons!")

        return ""
    end

    DarkRP.defineChatCommand("buyuniammo", buyAmmo)
    DarkRP.defineChatCommand("buyallammo", buyAmmo)
    DarkRP.defineChatCommand("buyammo", buyAmmo)
end)