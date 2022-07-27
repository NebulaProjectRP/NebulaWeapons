AddCSLuaFile()
ENT.Base = "neb_nadebase"
ENT.PrintName = "Fire Bomb"
ENT.Spawnable = true
ENT.Category = "NebulaRP"
ENT.Model = Model("models/cs574/explosif/grenade_bacta.mdl")
ENT.TintColor = Color(255, 0, 0)
ENT.ThrowForce = 500
ENT.Duration = 5

if SERVER then
    util.AddNetworkString("NebulaNades.Venom")
end

function ENT:Explode()
    self:EmitSound("suits/mist_gasup.mp3")
    self.loop = self:StartLoopingSound("suits/mist_gasloop.mp3")
    if CLIENT then
        self.Part = CreateParticleSystem(self, "suit_mist_cloud", PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
        self.Part:SetControlPoint(0, self:GetPos())
    else
        self.nadeLoop = self:LoopTimer("NadeGas", .1, function()
            for k, v in pairs(ents.FindInSphere(self:GetPos() + Vector(0, 0, 32), 200)) do
                if not v:IsPlayer() and not v:IsNPC() then continue end
                local dmg = DamageInfo()
                dmg:SetDamage(v:Health() * .05)
                dmg:SetDamageType(DMG_ACID)
                dmg:SetAttacker(self:GetOwner())
                dmg:SetInflictor(self)
                v:TakeDamageInfo(dmg)
                if v:IsPlayer() and !v:hasBuff("weed") then
                    v:addBuff("weed", 1, self:GetOwner())
                end
            end
        end)
    end
end

function ENT:OnRemove()
    if (self.nadeLoop) then
        self.nadeLoop:Remove()
    end
    if (self.loop) then
        self:StopLoopingSound(self.loop)
    end
    if (self.Part) then
        self.Part:StopEmissionAndDestroyImmediately()
    end
end

function ENT:OnActivate()
end