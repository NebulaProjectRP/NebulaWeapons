SWEP.Base = "tfa_melee_base"
SWEP.Category = "TFA CS:O"
SWEP.PrintName = "Hell Blades"
SWEP.Author = "Kamikaze" --Author Tooltip
SWEP.Type = "Epic grade melee weapon"
SWEP.ViewModel = "models/weapons/tfa_cso/c_dreadnova_asap.mdl"
SWEP.WorldModel = "models/weapons/tfa_cso/w_dreadnova_a_asap.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 85
SWEP.UseHands = true
SWEP.HoldType = "melee"
SWEP.DrawCrosshair = true
SWEP.Primary.Directional = false
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DisableIdleAnimations = false
SWEP.Secondary.CanBash = false
-- nZombies Stuff
SWEP.NZWonderWeapon = true -- Is this a Wonder-Weapon? If true, only one player can have it at a time. Cheats aren't stopped, though.
--SWEP.NZRePaPText		= "your text here"	-- When RePaPing, what should be shown? Example: Press E to your text here for 2000 points.
SWEP.NZPaPName = "Wallet Slayer"
--SWEP.NZPaPReplacement 	= "tfa_cso_dualsword"	-- If Pack-a-Punched, replace this gun with the entity class shown here.
SWEP.NZPreventBox = false -- If true, this gun won't be placed in random boxes GENERATED. Users can still place it in manually.
SWEP.NZTotalBlackList = false -- if true, this gun can't be placed in the box, even manually, and can't be bought off a wall, even if placed manually. Only code can give this gun.
SWEP.PaPMats = {}
SWEP.Precision = 50
SWEP.Secondary.MaxCombo = -1
SWEP.Primary.MaxCombo = -1

SWEP.WElements = {
    ["dreadnova_a"] = {
        type = "Model",
        model = "models/weapons/tfa_cso/w_dreadnova_a.mdl",
        bone = "ValveBiped.Bip01_L_Hand",
        rel = "",
        pos = Vector(6, -1.5, 5.50),
        angle = Angle(0, -180, 10),
        size = Vector(1, 1, 1),
        color = Color(255, 255, 255, 255),
        surpresslightning = false,
        material = "",
        skin = 0,
        bodygroup = {}
    }
}

SWEP.Offset = {
    Pos = {
        Up = -7.5,
        Right = 3,
        Forward = 3,
    },
    Ang = {
        Up = -30,
        Right = 160,
        Forward = -10
    },
    Scale = 1
}

sound.Add({
    ['name'] = "Dreadnova.Charge_Start",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/charge_start.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Charge_Release",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/charge_release.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Draw",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/draw.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.SlashEnd",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/budgetslayer/slash_end.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.SlashEnd",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/slash_end.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Slash1",
    ['channel'] = CHAN_STATIC,
    ['sound'] = {"weapons/tfa_cso/dreadnova/slash1.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Slash2",
    ['channel'] = CHAN_STATIC,
    ['sound'] = {"weapons/tfa_cso/dreadnova/slash2.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Slash3",
    ['channel'] = CHAN_STATIC,
    ['sound'] = {"weapons/tfa_cso/dreadnova/slash3.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Slash4",
    ['channel'] = CHAN_STATIC,
    ['sound'] = {"weapons/tfa_cso/dreadnova/slash4.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.Stab",
    ['channel'] = CHAN_STATIC,
    ['sound'] = {"weapons/tfa_cso/dreadnova/stab.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.HitFleshSlash",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/hit.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.HitFleshStab",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/stab_hit.wav"},
    ['pitch'] = {100, 100}
})

sound.Add({
    ['name'] = "Dreadnova.HitWall",
    ['channel'] = CHAN_WEAPON,
    ['sound'] = {"weapons/tfa_cso/dreadnova/wall.wav"},
    ['pitch'] = {100, 100}
})

SWEP.Primary.Attacks = {
    {
        ['act'] = ACT_VM_HITLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
        ['len'] = 24 * 5, -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dir'] = Vector(-180, 0, 90), -- Trace dir/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dmg'] = 100, --This isn't overpowered enough, I swear!!
        ['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
        ['delay'] = 0.03, --Delay
        ['spr'] = true, --Allow attack while sprinting?
        ['snd'] = "TFABaseMelee.Null", -- Sound ID
        ['snd_delay'] = 0.035,
        ["viewpunch"] = Angle(0, 0, 0), --viewpunch angle
        ['end'] = 0.4, --time before next attack
        ['hull'] = 32, --Hullsize
        ['direction'] = "F", --Swing dir,
        ['hitflesh'] = "Dreadnova.HitFleshSlash",
        ['hitworld'] = "Dreadnova.HitWall",
        ['maxhits'] = 25
    },
    {
        ['act'] = ACT_VM_HITRIGHT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
        ['len'] = 24 * 5, -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dir'] = Vector(180, 0, 90), -- Trace dir/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dmg'] = 100, --This isn't overpowered enough, I swear!!
        ['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
        ['delay'] = 0.03, --Delay
        ['spr'] = true, --Allow attack while sprinting?
        ['snd'] = "TFABaseMelee.Null", -- Sound ID
        ['snd_delay'] = 0.035,
        ["viewpunch"] = Angle(0, 0, 0), --viewpunch angle
        ['end'] = 0.4, --time before next attack
        ['hull'] = 32, --Hullsize
        ['direction'] = "F", --Swing dir,
        ['hitflesh'] = "Dreadnova.HitFleshSlash",
        ['hitworld'] = "Dreadnova.HitWall",
        ['maxhits'] = 25
    },
    {
        ['act'] = ACT_VM_PRIMARYATTACK, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
        ['len'] = 24 * 5, -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dir'] = Vector(180, 0, 0), -- Trace dir/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dmg'] = 125, --This isn't overpowered enough, I swear!!
        ['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
        ['delay'] = 0.03, --Delay
        ['spr'] = true, --Allow attack while sprinting?
        ['snd'] = "TFABaseMelee.Null", -- Sound ID
        ['snd_delay'] = 0.035,
        ["viewpunch"] = Angle(0, 0, 0), --viewpunch angle
        ['end'] = 0.7, --time before next attack
        ['hull'] = 32, --Hullsize
        ['direction'] = "F", --Swing dir,
        ['hitflesh'] = "Dreadnova.HitFleshSlash",
        ['hitworld'] = "Dreadnova.HitWall",
        ['maxhits'] = 25
    },
}

SWEP.Secondary.Attacks = {
    {
        ['act'] = ACT_VM_MISSLEFT, -- Animation; ACT_VM_THINGY, ideally something unique per-sequence
        ['len'] = 28 * 5, -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dir'] = Vector(0, 60, 0), -- Trace dir/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
        ['dmg'] = 200, --Nope!! Not overpowered!!
        ['dmgtype'] = DMG_SLASH, --DMG_SLASH,DMG_CRUSH, etc.
        ['delay'] = 0.4, --Delay
        ['spr'] = true, --Allow attack while sprinting?
        ['snd'] = "TFABaseMelee.Null", -- Sound ID
        ['snd_delay'] = 0.4,
        ["viewpunch"] = Angle(0, 0, 0), --viewpunch angle
        ['end'] = 0.9, --time before next attack
        ['hull'] = 128, --Hullsize
        ['direction'] = "F", --Swing dir
        ['hitflesh'] = "Dreadnova.HitFleshSlash",
        ['hitworld'] = "Dreadnova.HitWall",
        ['maxhits'] = 25
    }
}

SWEP.InspectionActions = {ACT_VM_RECOIL1}

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Holster(...)
    self:StopSound("Hellfire.Idle")

    return BaseClass.Holster(self, ...)
end

if CLIENT then
    SWEP.WepSelectIconCSO = Material("vgui/killicons/tfa_cso_dreadnova")
    SWEP.DrawWeaponSelection = TFA_CSO_DrawWeaponSelection
end

function SWEP:Initialize(...)
    self:SetNWInt("ShieldHealth", 1000)

    hook.Add("EntityTakeDamage", self, function(_, ent, dmg)
        if (ent == self:GetOwner() and ent:GetActiveWeapon() == self) then
            local extra = 0
            local health = self:GetNWInt("ShieldHealth", 0)

            if (health < dmg:GetDamage()) then
                extra = dmg:GetDamage() - health
            end

            self:SetNWInt("ShieldHealth", health - dmg:GetDamage())
            if (extra == 0) then
                dmg:ScaleDamage(.3)
            else
                dmg:SetDamage(extra)
            end

            if (self:GetNWInt("ShieldHealth", 0) <= 0) then
                hook.Remove("EntityTakeDamage", self)
            end

            self:GetOwner():EmitSound("physics/plastic/plastic_barrel_impact_bullet1.wav")

            return true
        end
    end)

    return BaseClass.Initialize(self, ...)
end

function SWEP:DrawHUD()
    if (self:GetNWInt("ShieldHealth", 1000) > 0) then
        NebulaSuits:DrawBar("Shield Health", self:GetNWInt("ShieldHealth", 1000) / 1000, -1)
    end
end

local ren = Material("particle/warp_grav")
function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)
    if (self:GetNWInt("ShieldHealth", 0) > 0) then
        render.SetMaterial(ren)
        render.DrawSprite(self:GetOwner():GetPos() + Vector(0, 0, 40), 48, 96, color_white)
    end
end
