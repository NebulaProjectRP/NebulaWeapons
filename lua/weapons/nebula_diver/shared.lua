SWEP.Base = "nebula_sck"
SWEP.PrintName = "Heroic Swing"
SWEP.Category = "NebulaRP"
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.UnitsPerTick = 112
SWEP.IsDiver = true
DEFINE_BASECLASS("nebula_sck")
SWEP.HoldType = "revolver"


function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsHooked")
    self:NetworkVar("Bool", 1, "IsMoving")
    self:NetworkVar("Bool", 2, "Refract")
    self:NetworkVar("Entity", 0, "Controller")
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self.HasThrown = true
    self:StartAttack()
    self.Idle = 0
    self.IdleTimer = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    if not self:GetIsHooked() then return end
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self.Idle = 0
    self.IdleTimer = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()
    self:SetNextSecondaryFire(CurTime() + .5)
    self:SetRefract(true)
end

function SWEP:Think()
    if self:GetIsHooked() and self:GetRefract() and IsValid(self:GetController()) then
        local tr = util.QuickTrace(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * 48, {self:GetOwner(), self:GetController()})

        if tr.Hit then return end

        if self:GetController().GetDistance then
            self:GetController():SetDistance(math.max(self:GetController():GetDistance() - FrameTime() * 500, 32))
        end

        if not self:GetOwner():KeyDown(IN_ATTACK2) then
            self:SetRefract(false)
        end
    end

    if self.Idle == 0 and self.IdleTimer <= CurTime() then
        if SERVER then
            self:SendWeaponAnim(ACT_VM_IDLE)
        end

        self.Idle = 1
    end
end
local lastTimer = 0
SWEP.TimerCreated = {}
SWEP.Trajectory = {}
SWEP.TrajectoryIndex = 0
SWEP.Ticks = 10

function SWEP:StartAttack()
    local lastPos = self:GetOwner():GetShootPos()
    local aimVector = self:GetOwner():GetAimVector()
    local sid = self:GetOwner():SteamID64()

    if SERVER then
        self:GetOwner():EmitSound("weapons/grappling_hook_shoot.wav")
    end

    self.Trajectory = {
        {1, self:GetOwner():GetShootPos()}
    }

    self.TrajectoryIndex = 1

    if CLIENT then
        self:CreateLazyRope()
    end

    local plaidCue = false

    for k = 1, self.Ticks do
        local tag = sid .. "_Grappling_" .. lastTimer
        self.TimerCreated[k] = tag
        local i = 0

        timer.Create(tag, k / (self.Ticks * 2), 1, function()
            if SERVER and not plaidCue then
                if self.loopingCue then
                    self:StopLoopingSound(self.loopingCue)
                    self.loopingCue = nil
                end

                self.loopingCue = self:StartLoopingSound("weapons/grappling_hook_reel_start.wav")
            end

            if self:GetIsHooked() then
                for k, v in pairs(self.TimerCreated) do
                    timer.Remove(v)
                end

                return
            end

            local tr = util.TraceLine({
                start = lastPos,
                endpos = lastPos + aimVector * self.UnitsPerTick + Vector(0, 0, -k / 2),
                filter = self:GetOwner(),
                mask = MASK_SHOT_HULL
            })

            debugoverlay.Line(lastPos, tr.HitPos, 1, Color(255, 0, 0), true)
            lastPos = tr.HitPos

            if tr.HitWorld then
                if self.loopingCue then
                    self:StopLoopingSound(self.loopingCue)
                    self.loopingCue = nil
                end

                self:EmitSound("weapons/grappling_hook_impact_default.wav")
                self:SetIsHooked(true)

                if SERVER then
                    self:CreateProjectile(tr.HitPos, tr.HitNormal)
                else
                    self.LerpedRope = {self:GetRopeOrigin()}

                    for k, v in pairs(self.Trajectory) do
                        table.insert(self.LerpedRope, v[2])
                    end
                end

                --debugoverlay.Cross(tr.HitPos, 32, 5, Color(255, 0, 0), true)
                for k, v in pairs(self.TimerCreated) do
                    timer.Remove(v)
                end
            end

            table.insert(self.Trajectory, {k, tr.HitPos})

            self.TrajectoryIndex = self.TrajectoryIndex + 1

            if self.TrajectoryIndex > self.Ticks then
                if CLIENT then
                    self.TrajectoryIndex = 0
                    self.LazyRopePoints = {}
                    self.LastRope = 0
                end

                self:Reload()
            end
        end)

        lastTimer = lastTimer + 1
    end
end

function SWEP:OnRemove()
    self:Reload()
    for k, v in pairs(self.TimerCreated) do
        timer.Remove(v)
    end
end

function SWEP:Deploy()
    BaseClass.Deploy(self)
    self:SendWeaponAnim(ACT_VM_DRAW)
    AvailableGrapple = false
    self.Idle = 0
    self.IdleTimer = CurTime() + self:GetOwner():GetViewModel():SequenceDuration()

    return true
end

function SWEP:Holster()
    BaseClass.Holster(self)

    for k, v in pairs(self.TimerCreated) do
        timer.Remove(v)
    end

    AvailableGrapple = true
    self.HasThrown = nil
    self.TimerCreated = {}
end

SWEP.NextReload = 0

function SWEP:Reload()
    if self.NextReload > CurTime() then return end
    if not self.HasThrown then return end
    self.NextReload = CurTime() + .5

    if SERVER and IsValid(self:GetController()) then
        self:GetController():Remove()
    end

    for k, v in pairs(self.TimerCreated) do
        timer.Remove(v)
    end

    self.HasThrown = nil
    self.TimerCreated = {}
    self:SetIsHooked(false)
    self:SetIsMoving(false)

    if SERVER then
        self:GetOwner():EmitSound("weapons/grappling_hook_reel_stop.wav")
    end

    if self.loopingCue then
        self:StopLoopingSound(self.loopingCue)
        self.loopingCue = nil
    end
end

