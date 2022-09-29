AddCSLuaFile()
SWEP.Base = "nebula_sck"
SWEP.PrintName = "Trash Shooter"
SWEP.Category = "NebulaRP Permas"
SWEP.HoldType = "shotgun"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/c_shotgun.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}
SWEP.VElements = {
	["printer"] = { type = "Model", model = "models/zerochain/props_trashman/ztm_trashburner.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0.565, 0.505, -1.755), angle = Angle(-180, 90.01, 174.578), size = Vector(0.123, 0.123, 0.123), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["cilinder"] = { type = "Model", model = "models/zerochain/props_trashman/ztm_recycler.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(1.427, 0.026, -6.704), angle = Angle(-180, -90, 81.041), size = Vector(0.071, 0.105, 0.071), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["cilinder"] = { type = "Model", model = "models/zerochain/props_trashman/ztm_recycler.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(1.427, 0.103, -5.185), angle = Angle(-180, -90, 81.041), size = Vector(0.071, 0.105, 0.071), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["printer"] = { type = "Model", model = "models/zerochain/props_trashman/ztm_trashburner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.034, 0.128, -2.503), angle = Angle(91.347, -180, 1.664), size = Vector(0.123, 0.123, 0.123), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}