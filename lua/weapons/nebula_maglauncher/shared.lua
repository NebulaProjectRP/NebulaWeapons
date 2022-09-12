
SWEP.Base = "weapon_base"
SWEP.PrintName = "Magnum Launcher: Lancer"
SWEP.Category = "NebulaRP"
SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/nebularp/c_magnum_lancer.mdl"
SWEP.WorldModel = "models/weapons/tfa_cso/w_magnum_lancer.mdl"
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 90

SWEP.Primary.ClipSize = 25
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Ammo = "357"
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 40
SWEP.Primary.FireRate = 0.3
SWEP.Primary.MissileFireRate = .65

SWEP.DisableSkinGroups = false
SWEP.WorldModelAngles = Angle(0, 100, 190)
SWEP.OverheatExtra = .5
SWEP.HeatAmount = 2
SWEP.HeatOnHit = 10
SWEP.MaxBeams = 3
SWEP.MaxHeat = 80

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Heat")
    self:NetworkVar("Bool", 1, "Active")
    self:NetworkVar("Bool", 2, "Realoding")
end

function SWEP:Initialize()
    self:SetHoldType("shotgun")
    if SERVER then
        self:InitSV()
    else
        self:InitCL()
    end
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:SendWeaponAnim(self:GetActive() and ACT_VM_THROW or ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    self:GetOwner():ViewPunch(Angle(self:GetActive() and -2 or -.5, 0, 0))
    if (self:GetActive()) then
        if SERVER then
            self:PerformAttack()
        end
        self:SetHeat(self:GetHeat() - 10)
        if (self:GetHeat() <= 0) then
            self:SetNextPrimaryFire(CurTime() + 0.5)
            self:SetNextSecondaryFire(CurTime() + 0.5)
            self:Wait(.25, function()
                self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            end)
            self:SetActive(false)
        end
        self:SetNextPrimaryFire(CurTime() + self.Primary.MissileFireRate)
        return
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.FireRate)

    if SERVER then
        self:PerformAttack()
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()

    if (self:GetActive()) then
        self:SetActive(false)
        if SERVER then
            owner:EmitSound("weapons/tfa_cso/magnum_lancer/clipout.wav")
        end
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:SetNextSecondaryFire(CurTime() + 0.5)
        self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
        local vm = owner:GetViewModel(0)
        timer.Create("mg_idle", vm:SequenceDuration(), 1, function()
            if IsValid(self) and self:GetActive() then
                self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            end
        end)
        return
    end

    if (self:GetHeat() > self.MaxHeat / 2) then
        self:SetActive(true)
        self:SendWeaponAnim(ACT_VM_PULLPIN)
        self:SetNextPrimaryFire(CurTime() + 0.5)
        self:SetNextSecondaryFire(CurTime() + 0.5)
        local vm = owner:GetViewModel(0)
        timer.Create("mg_idle", vm:SequenceDuration(), 1, function()
            if IsValid(self) and self:GetActive() then
                self:SendWeaponAnim(ACT_VM_IDLE)
            end
        end)
    end
end

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    local owner = self:GetOwner()
    local vm = owner:GetViewModel(0)
    timer.Create("mg_idle", vm:SequenceDuration(), 1, function()
        if IsValid(self) then
            self:SendWeaponAnim(self:GetActive() and ACT_VM_IDLE or ACT_VM_IDLE_LOWERED)
        end
    end)
end

function SWEP:Deploy()
    self:SetHeat(0)
    self:SendWeaponAnim(ACT_VM_DRAW)

    if CLIENT then
        local owner = self:GetOwner()
        local vm = owner:GetViewModel(0)
        timer.Create("mg_idle", vm:SequenceDuration(), 1, function()
            if IsValid(self) then
                self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            end
        end)
    else
        self:CallOnClient("Deploy")
    end
end