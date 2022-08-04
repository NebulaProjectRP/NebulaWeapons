AddCSLuaFile()

SWEP.Base                       = "tfa_nade_base"
SWEP.PrintName = "Nade - EMP"
SWEP.Category                   = "NebulaRP" -- The category.
-- Please, just choose something generic or something I've already done if you plan on only doing like one (or two or three) swep(s).
SWEP.Manufacturer               = nil -- Gun Manufactrer (e.g. Hoeckler and Koch)
SWEP.Author                     = "Gonzo" -- Author Tooltip
SWEP.Spawnable                  = true
SWEP.DrawCrosshair              = true
SWEP.ProjectileEntity = "neb_nadeemp"

DEFINE_BASECLASS("tfa_gun_base")

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.ProjectileVelocity = 500
SWEP.Primary.AmmoConsumption = 1

SWEP.HoldType = "grenade"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["nade"] = { type = "Model", model = "models/nebularp/grenade_base.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(-0.022, 1.069, 2.75), angle = Angle(180, 0, -7.974), size = Vector(0.884, 0.884, 0.884), color = Color(0, 204, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["nade"] = { type = "Model", model = "models/nebularp/grenade_base.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.072, 2.431, 2.772), angle = Angle(-171.896, 74.039, 1.383), size = Vector(0.884, 0.884, 0.884), color = Color(0, 204, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:PostPrimaryAttack()
	if (SERVER and self:Clip1() == 0) then
        self:GetOwner():ConCommand("lastinv")
        self:Remove()
    end
end