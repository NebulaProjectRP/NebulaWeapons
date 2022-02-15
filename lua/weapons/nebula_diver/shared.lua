SWEP.Base = "nebula_sck"
SWEP.PrintName = "Heroic Swing"
SWEP.Category = "NebulaRP"
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.UnitsPerTick = 96

DEFINE_BASECLASS("nebula_sck")

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsHooked")
    self:NetworkVar("Bool", 1, "IsMoving")
    self:NetworkVar("Float", 0, "HitStamp")
    self:NetworkVar("Float", 1, "Radius")
    self:NetworkVar("Vector", 0, "HitPos")
    self:NetworkVar("Vector", 1, "TravelDir")
    self:NetworkVar("Entity", 0, "Controller")
end

function SWEP:PrimaryAttack()
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
    self.HasThrown = true
    self:StartAttack()
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
    self:SetNextSecondaryFire(CurTime() + .5)
end

function SWEP:Think()
    if self.Idle == 0 and self.IdleTimer <= CurTime() then
		if SERVER then
			self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		end
		self.Idle = 1
	end
end

local lastTimer = 0
SWEP.TimerCreated = {}
SWEP.Trajectory = {}
SWEP.TrajectoryIndex = 0
function SWEP:StartAttack()
    local lastPos = self.Owner:GetShootPos()
    local aimVector = self.Owner:GetAimVector()
    local sid = self.Owner:SteamID64()

    if SERVER then
        self:GetOwner():EmitSound("weapons/grappling_hook_shoot.wav")
    end

    self.Trajectory = {{1, self:GetOwner():GetShootPos()}}
    self.TrajectoryIndex = 1

    local plaidCue = false
    for k = 1, 10 do
        local tag = sid .. "_Grappling_" .. lastTimer
        self.TimerCreated[k] = tag
        timer.Create(tag, k / 20, 1, function()
            if SERVER and not plaidCue then
                if self.loopingCue then
                    self:StopLoopingSound(self.loopingCue)
                    self.loopingCue = nil
                end
                self.loopingCue = self:StartLoopingSound("weapons/grappling_hook_reel_start.wav")
            end
            if (self:GetIsHooked()) then
                for k, v in pairs(self.TimerCreated) do
                    timer.Remove(v)
                end
                return
            end
            local tr = util.TraceLine({
                start = lastPos,
                endpos = lastPos + aimVector * self.UnitsPerTick + Vector(0, 0, -k / 2),
                filter = self.Owner,
                mask = MASK_SHOT_HULL
            })

            debugoverlay.Line(lastPos, tr.HitPos, 1, Color(255, 0, 0), true)
            lastPos = tr.HitPos
            if (tr.HitWorld) then
                if (self.loopingCue) then
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
                debugoverlay.Cross(tr.HitPos, 32, 5, Color(255, 0, 0), true)
                for k, v in pairs(self.TimerCreated) do
                    timer.Remove(v)
                end
            end

            table.insert(self.Trajectory, {k, tr.HitPos})
            self.TrajectoryIndex = self.TrajectoryIndex + 1
        end)
        lastTimer = lastTimer + 1
    end
end

function SWEP:OnRemove()
    for k, v in pairs(self.TimerCreated) do
        timer.Remove(v)
    end
end

function SWEP:Deploy()
    BaseClass.Deploy( self )
    self:SendWeaponAnim(ACT_VM_DRAW)
	
	self.Idle = 0
	self.IdleTimer = CurTime() + self.Owner:GetViewModel():SequenceDuration()
	return true
end

function SWEP:Holster()
    BaseClass.Holster( self )
    for k, v in pairs(self.TimerCreated) do
        timer.Remove(v)
    end
    self.HasThrown = nil
    self.TimerCreated = {}
end

SWEP.NextReload = 0
function SWEP:Reload()
    if (self.NextReload > CurTime()) then
        return
    end

    if (not self.HasThrown) then return end
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

    if (self.loopingCue) then
        self:StopLoopingSound(self.loopingCue)
        self.loopingCue = nil
        MsgN("Stopping sound")
    end
end
