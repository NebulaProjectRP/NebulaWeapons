util.AddNetworkString("NebulaWeapons:UpdateWeapon")
util.AddNetworkString("NebulaWeapons:DeleteWeapon")

net.Receive("NebulaWeapons:UpdateWeapon", function(l, ply)
    if not ply:IsSuperAdmin() then return end
    local wep = net.ReadString()
    local data = net.ReadTable()

    local wepTable = weapons.GetStored(wep)
    for k, v in pairs(data) do
        if (istable(v)) then
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
        MsgN(res)
        MsgN("Weapon " .. wep .. " has been updated")
        net.Start("NebulaWeapons:UpdateWeapon")
        net.Broadcast()
    end, function(err) end, {
        authorization = NebulaAPI.API_KEY
    })
end)

net.Receive("NebulaWeapons:DeleteWeapon", function(l, ply)
    if not ply:IsSuperAdmin() then return end
    local wep = net.ReadString()
    http.Post(NebulaAPI.HOST .. "weapons/upload", {
        class = wep,
    }, function(res)
        MsgN("Weapon " .. wep .. " has been deleted")
        net.Start("NebulaWeapons:UpdateWeapon")
        net.Broadcast()
    end, function(err) end, {
        authorization = NebulaAPI.API_KEY
    })
end)

local commands = {
    ["!buyammo"] = true,
    ["!buyuniammo"] = true,
    ["!buyallammo"] = true,
    ["/buyammo"] = true,
    ["/buyuniammo"] = true,
    ["/buyallammo"] = true
}

hook.Add("PlayerSay", "NebulaRP.ReplenishAmmo", function(ply, text)
    if (commands[text]) then
        local types = {}
        for k, v in pairs(ply:GetWeapons()) do
            if (v.Primary and not types[v.Primary.Ammo]) then
                types[v.Primary.Ammo] = true
                ply:GiveAmmo(100, v.Primary.Ammo)
            end
        end
        ply:addMoney(-1000)
        ply:PrintMessage(HUD_PRINTTALK, "You bought ammo for all your weapons!")
        return ""
    end
end)