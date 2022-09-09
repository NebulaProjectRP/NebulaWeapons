AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("NebulaWep.MagnumEffect")

function SWEP:InitSV()
end

function SWEP:DealDamage()
end

function SWEP:PerformAttack()
    local owner = self:GetOwner()
    local percent = self:Clip1() / self:GetMaxClip1()
    owner:EmitSound(self:GetActive() and "weapons/tfa_cso/magnum_lancer/fire_2.wav" or "weapons/tfa_cso/magnum_lancer/fire.wav", 75, 100 + (1 - percent) * 40, 1, CHAN_WEAPON)
    local num_bullets = self:GetActive() and self.MaxBeams or 1
    local heatAmount = 5
    for k = 0, num_bullets - 1 do
        local dir = owner:GetAimVector()
        if (self:GetActive()) then
            dir = dir + Angle(owner:EyeAngles().p, owner:EyeAngles().y + (-num_bullets / 2) * 5 + k * 5, 0):Forward() * 0.5
        end
        local bullet = {
            Src = owner:GetShootPos(),
            Dir = dir,
            Spread = Vector(0.025, 0.025, 0),
            Num = 1,
            Tracer = 0,
            Force = 100,
            Damage = self:GetActive() and self.Primary.Damage + self.Primary.Damage * self.OverheatExtra or self.Primary.Damage,
            Callback = function(ent, tr, dmg)
                dmg:SetDamageType(DMG_DISSOLVE)
                if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
                    heatAmount = heatAmount + 10
                end

                net.Start("NebulaWep.MagnumEffect")
                net.WriteEntity(self)
                net.WriteVector(tr.HitPos)
                net.SendPVS(owner:GetPos())
            end
        }

        owner:FireBullets(bullet)
    end
    self:TakePrimaryAmmo(num_bullets)
    if (not self:GetActive()) then
        self:SetHeat(math.Clamp(self:GetHeat() + heatAmount, 0, self.MaxHeat))
    end
end