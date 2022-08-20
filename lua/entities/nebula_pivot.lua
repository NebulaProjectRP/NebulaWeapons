AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Heroic Swing's Pivot"
ENT.Author = "Gonzalolog"

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Controller")
    self:NetworkVar("Entity", 1, "Weapon")
    self:NetworkVar("Vector", 0, "Target")
    self:NetworkVar("Float", 0, "Distance")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_wasteland/controlroom_filecabinet002a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:GetPhysicsObject():Wake()
        self:StartMotionController()

        self.ShadowParams = {
            maxangular = 400,
            maxangulardamp = 400,
            maxspeed = 520,
            maxspeeddamp = 520,
            dampfactor = 1,
            teleportdistance = 10000,
        }
    end

    hook.Add("Move", self, function(s, ply, mv)
        if ply == self:GetOwner() then return self:Move(mv) end
    end)
end

ENT.LerpedSpeed = Vector(0, 0, 0)

function ENT:Move(mv)
    if SERVER then
        if not IsValid(self:GetWeapon()) then
            self:Remove()

            return
        end

        if not self:GetWeapon().IsDiver then
            self:Remove()

            return
        end
    end

    local ply = self:GetOwner()
    local side = mv:GetSideSpeed()
    local forw = mv:GetForwardSpeed()
    mv:SetForwardSpeed(0)
    mv:SetSideSpeed(0)
    self.sideSpeed = side / 10
    self.forwSpeed = forw / 10
    self.LerpedSpeed = LerpVector(FrameTime() * 10, self.LerpedSpeed, Vector(self.sideSpeed, self.forwSpeed, 0))
    local vel = self:GetVelocity()
    local diver = self:GetWeapon()
    if not IsValid(diver) then return end

    if diver:GetRefract() then
        vel = vel + (self:GetController():GetPos() - self:GetPos()):GetNormalized() * 500
    end

    if not self:GetOwner():KeyDown(IN_ATTACK) then
        diver:Reload()
        self:GetOwner():SetVelocity(vel * .5)
        mv:SetVelocity(vel * .5)
    end

    return true
end

function ENT:OnRemove()
    local owner = self:GetOwner()

    if SERVER then
        local tr = util.TraceHull({
            startpos = self:GetPos(),
            endpos = self:GetPos(),
            filter = {self, self:GetOwner()},
            mins = Vector(-32, -32, 0),
            maxs = Vector(32, 32, 72),
        })

        if IsValid(owner) then
            local angles = owner:EyeAngles()
            owner:SetParent(nil)
            if (tr.HitWorld) then
                local target = DarkRP.findEmptyPos(self:GetPos() + (self.Push or Vector(0, 0, 0)), {self, owner}, 72, 16, Vector(64, 64, 72))
                owner:SetPos(target)
            else
                owner:SetPos(self:GetPos())
            end
            angles.r = 0
            angles.p = 0
            owner:SetEyeAngles(angles)
            if (self.Push) then
                owner:SetPos(owner:GetPos() + self.Push)
            end
        end

        if self:GetWeapon().loopingCue then
            self:GetWeapon():StopLoopingSound(self:GetWeapon().loopingCue)
        end

        if IsValid(self:GetController()) then
            self:GetController():Remove()
        end
    else
        self:GetWeapon().RollLerp = self:GetAngles().r
        self:GetWeapon().PitchLerp = self:GetAngles().p
    end
end

function ENT:OnTakeDamage(dmg)
    if IsValid(self:GetOwner()) then
        self:GetOwner():TakeDamage(dmg:GetDamage())
    end
end

function ENT:Setup(ply)
    self:SetDistance(ply:GetShootPos():Distance(self:GetTarget()))
    self:SetWeapon(ply:GetActiveWeapon())

    if SERVER then
        ply:SetEyeAngles(self:WorldToLocalAngles(ply:EyeAngles()))
        ply:SetParent(self)
        local controller = ents.Create("prop_dynamic")
        controller:SetModel("models/weapons/c_models/c_grapple_proj/c_grapple_proj.mdl")
        controller:SetPos(self:GetTarget() + self.Normal * -4)
        controller:SetAngles(self.Normal:Angle())
        controller:PhysicsInit(SOLID_NONE)
        controller:Spawn()
        self:SetController(controller)
    end
end

ENT.FlyAngle = Angle(0, 0, 0)

function ENT:CalculatePosition()
    local dist = self:GetDistance()
    local diff = (self:GetTarget() - self:GetPos()):GetNormalized():Angle()
    self.FlyAngle = LerpAngle(FrameTime() * 4, self.FlyAngle, Angle(-(self.forwSpeed or 0), -(self.sideSpeed or 0), 0))
    diff = diff + self.FlyAngle * FrameTime() * 10

    return self:GetController():GetPos() - diff:Forward() * dist
end

function ENT:CalculateAngle()
    local diff = (self:GetTarget() - self:GetPos()):GetNormalized()
    local ang = diff:Angle()
    ang:RotateAroundAxis(ang:Forward(), self.FlyAngle.y / 2)

    return ang
end

ENT.Disposed = false

function ENT:PhysicsSimulate(phys, deltatime)
    self.ShadowParams.secondstoarrive = deltatime
    self.ShadowParams.pos = self:CalculatePosition()
    self.ShadowParams.angle = self:CalculateAngle()
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)

    local tr = util.TraceHull({
        start = self:GetPos() + Vector(0, 0, 0),
        endpos = self:GetPos() + Vector(0, 0, 2),
        mins = -Vector(32, 32, 0),
        maxs = Vector(32, 32, 96),
        filter = {self, self:GetController(), self:GetOwner()},
    })

    if not self.Disposed and tr.HitWorld then
        self.Disposed = true
        self.Push = (tr.HitPos - self:GetOwner():GetPos()):GetNormalized() * -16
        self:GetWeapon():Reload()
    end
end

function ENT:Draw()
end
--self:DrawModel()