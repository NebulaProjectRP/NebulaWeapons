SWEP.Base = "nebula_maglauncher"
SWEP.PrintName = "Magnum Launcher: Shooter"
SWEP.Category = "NebulaRP"
SWEP.Spawnable = true
SWEP.HoldType = "shotgun"
SWEP.WorldModel = "models/weapons/tfa_cso/w_magnum_shooter.mdl"
SWEP.ViewModel = "models/weapons/nebularp/c_magnum_shooter.mdl"

SWEP.Primary = {}
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Ammo = "357"
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 65
SWEP.Primary.FireRate = 0.2
SWEP.Primary.MissileFireRate = .45

SWEP.WorldModelAngles = Angle(10, 10, 180)
SWEP.DisableSkinGroups = true
SWEP.OverheatExtra = .4
SWEP.HeatAmount = 4
SWEP.HeatOnHit = 12
SWEP.MaxBeams = 4
SWEP.MaxHeat = 100

DEFINE_BASECLASS("nebula_maglauncher")