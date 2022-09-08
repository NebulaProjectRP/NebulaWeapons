SWEP.Base = "nebula_maglauncher"
SWEP.PrintName = "Magnum Launcher: Expert"
SWEP.Category = "NebulaRP"
SWEP.Spawnable = true
SWEP.HoldType = "shotgun"
SWEP.WorldModel = "models/weapons/tfa_cso/w_magnumlauncher_gs18.mdl"
SWEP.ViewModel = "models/weapons/nebularp/c_magnumlauncher_gs18.mdl"

SWEP.Primary = {}
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Ammo = "357"
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 80
SWEP.Primary.FireRate = 0.1
SWEP.Primary.MissileFireRate = .5

SWEP.WorldModelAngles = Angle(10, 10, 180)
SWEP.OverheatExtra = .5
SWEP.HeatAmount = 5
SWEP.HeatOnHit = 15
SWEP.MaxBeams = 5
SWEP.MaxHeat = 200

DEFINE_BASECLASS("nebula_maglauncher")