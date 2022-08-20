
local surface = surface

function TFA_CSO_DrawWeaponSelection(self, x, y, wide, tall, alpha)
	if not self.WepSelectIconCSO then return end
	-- Set us up the texture
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(self.WepSelectIconCSO)

	y = y + 10
	x = x + 10
	wide = wide - 20

	self.WepSelectIconCSO:SetFloat('$alpha', alpha / 255)
	surface.DrawTexturedRectUV(x, y, wide, wide / 2, 1, 0, 0, 1)
	self.WepSelectIconCSO:SetFloat('$alpha', 1)
end

timer.Simple(10, function()
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