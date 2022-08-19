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