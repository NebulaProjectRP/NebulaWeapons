AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Funny Bomb"
ENT.Spawnable = true
ENT.Category = "NebulaRP"
ENT.Model = Model("models/nebularp/grenade_base.mdl")
ENT.TintColor = Color(255, 0, 0)
ENT.ThrowForce = 500
ENT.Duration = 5

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local ent = ents.Create(ClassName)
    ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 16)
    ent:SetOwner(ply)
    ent:Spawn()

    return ent
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Activated")
    self:NetworkVar("Float", 0, "TimeStamp")
    self:NetworkVar("Vector", 0, "Origin")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:SetColor(self.TintColor)
        self:PhysicsInitSphere(8, "grenade")
        self:Activate()
        self:SetModelScale(1, 0)
        self:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetAimVector() * self.ThrowForce)
        self:SetAngles(AngleRand())
        self.Bounces = 5
        SafeRemoveEntityDelayed(self, 30)
    end
end

ENT.Progress = 0
ENT.BombExploded = false

function ENT:Think()
    if not self:GetActivated() then return end
    local progress = 1 - math.Clamp(self:GetTimeStamp() - CurTime(), 0, 1)
    self.Progress = math.max(self.Progress, progress)

    if not self.BombExploded and self.Progress >= 1 then
        if SERVER then
            SafeRemoveEntityDelayed(self, self.Duration)
        end
        self.BombExploded = true
        self:Explode()
    end

    self:SetPos(LerpVector(self.Progress, self:GetOrigin(), self:GetOrigin() + Vector(0, 0, 24)))
    self:SetAngles(Angle(45, (CurTime() * 250) % 360, 0))
end

function ENT:Explode()
    if SERVER then
        local explode = ents.Create( "env_explosion" ) -- creates the explosion
        explode:SetPos( self:GetPos() )
        -- this creates the explosion through your self.Owner:GetEyeTrace, which is why I put eyetrace in front
        explode:SetOwner( self:GetOwner() ) -- this sets you as the person who made the explosion
        explode:Spawn() --this actually spawns the explosion
        explode:SetKeyValue( "iMagnitude", "100" ) -- the magnitude
        explode:Fire( "Explode", 0, 0 )
        self:Remove()
    end
end

function ENT:OnActivate()
    self.loopSound = self:StartLoopingSound("weapons/gauss/chargeloop.wav")
end

function ENT:OnRemove()
    if (self.loopSound) then
        self:StopLoopingSound(self.loopSound)
    end
end

function ENT:PhysicsCollide(data, col)
    if self.Bounces < 0 then return end
    local physobj = self:GetPhysicsObject()
    local LastSpeed = math.max(data.OurOldVelocity:Length(), data.Speed)
    local NewVelocity = physobj:GetVelocity()
    NewVelocity:Normalize()
    LastSpeed = math.max(NewVelocity:Length(), LastSpeed)
    local power = self.Bounces / 5
    local TargetVelocity = NewVelocity * LastSpeed * power * Vector(.5, .5, 1) + Vector(0, 0, 96)
    self.Bounces = self.Bounces - 1
    self:EmitSound("Paintcan.ImpactHard")
    physobj:SetVelocity(TargetVelocity)

    if self.Bounces <= 0 then
        self:EmitSound("DoSpark")
        self:OnActivate()
        self:SetActivated(true)
        self:SetTimeStamp(CurTime() + 1)
        self:SetOrigin(self:GetPos())
    end
end