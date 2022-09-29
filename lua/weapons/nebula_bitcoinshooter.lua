AddCSLuaFile()
SWEP.Base = "nebula_sck"
SWEP.PrintName = "Bitcoin Shooter"
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
	["cilinder+"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/tv.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(-6.315, 3.243, 3.97), angle = Angle(0, -138.625, 0), size = Vector(0.109, 0.109, 0.109), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["printer"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/power_combiner.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0.008, 2.341, -2.952), angle = Angle(-180, 0, -90), size = Vector(0.462, 0.462, 0.462), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["cilinder"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/miner_solo.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(0, 11.927, 1.184), angle = Angle(0, -90, 0), size = Vector(0.805, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["screen"] = { type = "Quad", bone = "ValveBiped.Bip01_Spine4", rel = "cilinder+", pos = Vector(0, -0.152, 0.238), angle = Angle(-180, 0, -90), size = 0.054, draw_func = nil},
	["cilinder++"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/solar_panel.mdl", bone = "ValveBiped.Bip01_L_Finger41", rel = "printer", pos = Vector(-0.258, 1.148, 7.33), angle = Angle(-0.912, -138.625, 0), size = Vector(0.061, 0.061, 0.061), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["cilinder+"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/tv.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(-6.315, 3.243, 3.97), angle = Angle(0, -138.625, 0), size = Vector(0.101, 0.101, 0.101), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["cilinder"] = { type = "Model", model = "models/craphead_scripts/bitminers/utility/miner_solo.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(0, 11.927, 1.184), angle = Angle(0, -90, 0), size = Vector(0.805, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["printer"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/power_combiner.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(13.571, 0, -2.577), angle = Angle(180, -90, 21.061), size = Vector(0.462, 0.462, 0.462), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["cilinder++"] = { type = "Model", model = "models/craphead_scripts/bitminers/power/solar_panel.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "printer", pos = Vector(-0.258, 1.148, 7.33), angle = Angle(-0.912, -138.625, 0), size = Vector(0.061, 0.061, 0.061), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}