NebulaWeapons = NebulaWeapons or {}

function NebulaWeapons:Update()
    http.Fetch(NebulaAPI.HOST .. "weapons/fetch", function(body)
        local data = util.JSONToTable(body)
        if not data then return end

        for class, info in pairs(data) do
            local wep = weapons.GetStored(class)

            for key, val in pairs(info) do
                if istable(val) then
                    for sub, subval in pairs(val) do
                        if not wep[key][sub] then continue end
                        wep[key][sub] = subval
                    end

                    continue
                end

                wep[key] = val
            end
        end
    end)
end

hook.Add("InitPostEntity", "NebulaWeapons:Register", function(swep, class)
    NebulaWeapons:Update()
end)

net.Receive("NebulaWeapons:UpdateWeapon", function()
    NebulaWeapons:Update()
end)