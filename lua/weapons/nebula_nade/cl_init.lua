include("shared.lua")

SWEP.VElements = {
	["grenade"] = { type = "Model", model = "models/nebularp/grenade_base.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.743, 2.344, 2.974), angle = Angle(-177.62, -72.005, 6.302), size = Vector(1, 1, 1), color = Color(166, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["grenade"] = { type = "Model", model = "models/nebularp/grenade_base.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.673, 2.635, 3.256), angle = Angle(-172.441, 44.479, 0), size = Vector(0.873, 0.873, 0.873), color = Color(166, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:ModelInitialized()
    self.VElements.grenade:SetColor(self.Tint)
    self.VElements.grenade.color = self.Tint
    self.WElements.grenade:SetColor(self.Tint)
    self.WElements.grenade.color = self.Tint
end