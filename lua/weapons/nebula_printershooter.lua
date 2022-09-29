AddCSLuaFile()
SWEP.Base = "nebula_sck"
SWEP.PrintName = "Printer Shooter"
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
	["cilinder"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/rtg.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(0, -12.837, 1.422), angle = Angle(0, 0, -90), size = Vector(0.214, 0.214, 0.214), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["cilinder+"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/plug.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(-0.973, 33.089, 1.7), angle = Angle(0, -90, 0), size = Vector(1.985, 1.985, 1.985), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["printer"] = { type = "Model", model = "models/ogl/ogl_oneprint_nebula.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0.008, 2.341, -2.952), angle = Angle(0, 0, -90), size = Vector(0.109, 0.199, 0.109), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["cilinder"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/rtg.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(0, -12.837, 3.398), angle = Angle(0, 0, -90), size = Vector(0.214, 0.214, 0.214), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["printer"] = { type = "Model", model = "models/ogl/ogl_oneprint_nebula.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.157, 1.84, -7.999), angle = Angle(0, 90.157, -0.515), size = Vector(0.109, 0.199, 0.109), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["cilinder+"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/plug.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(-0.087, 20.389, 4.124), angle = Angle(0, -90, 0), size = Vector(1.315, 1.315, 1.315), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}