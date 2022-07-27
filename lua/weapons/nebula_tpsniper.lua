SWEP.PrintName = "Teleport Sniper"
SWEP.Primary = {
    ClipSize = 3,
    DefaultClip = 0,
    Automatic = false,
    ReloadRate = 3,
}
SWEP.Ammo = "none"
SWEP.TravelTime = .5
SWEP.SignalTime = 2
SWEP.ViewModel = "models/weapons/nebularp/c_tpsniper.mdl"
SWEP.ViewModelFlip = true
SWEP.WorldModel = "models/weapons/nebularp/c_tpsniper.mdl"

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextBullet")
    self:NetworkVar("Float", 1, "TPStamp")
    self:NetworkVar("Bool", 0, "DoingTP")
    self:NetworkVar("Bool", 1, "Zooming")
    self:NetworkVar("Entity", 1, "Target")

end

if SERVER then
    util.AddNetworkString("NebulaRP.TPSniper:Notify")
end

SWEP.ZoomLevel = 1
function SWEP:Initialize()
    self:SetClip1(3)
    self:SetDeploySpeed(1)
    if CLIENT and self:GetOwner() == LocalPlayer() then
        hook.Add("PlayerBindPress", self, function(s, ply, bind)
            if (s != ply:GetActiveWeapon()) then return end
            if (not self:GetZooming()) then return end
            if (bind == "invprev") then
                self.ZoomLevel = math.Clamp(self.ZoomLevel - .1, .1, 1)
                return true
            end
            if (bind == "invnext") then
                self.ZoomLevel = math.Clamp(self.ZoomLevel + .1, .1, 1)
                return true
            end

        end)
    end
end

function SWEP:PrimaryAttack()
    if (self:Clip1() <= 0) then return end
    self:SetNextBullet(CurTime() + self.Primary.ReloadRate)

    if SERVER then
        self:FireBullets({
            Src = self:GetOwner():GetShootPos(),
            Dir = self:GetOwner():GetAimVector(),
            Spread = Vector(0, 0, 0),
            Num = 1,
            Damage = 0,
            Tracer = 0,
            Force = 0,
            Callback = function(attacker, tr, dmg)
                local hitentity = tr.Entity
                if IsValid(hitentity) and (hitentity:IsPlayer() or hitentity:IsNPC()) then
                    self:SetTarget(hitentity)
                    self:SetTPStamp(CurTime() + self.SignalTime)
                    if hitentity:IsPlayer() then
                        net.Start("NebulaRP.TPSniper:Notify")
                        net.Send(hitentity)
                    end
                end
            end
        })
    end

    self:GetOwner():ViewPunch(Angle(-5, -0, 2))
    self:TakePrimaryAmmo(1)
    self:GetOwner():MuzzleFlash() -- Crappy muzzle light
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
    if CLIENT and self:GetOwner() == LocalPlayer() then
        self:Wait(self.Primary.ReloadRate, function()

        end)
    end

    self:EmitSound("weapons/e_blaster/sf ethereal fire.wav", 110)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    timer.Create("TP_" .. self:EntIndex() .. "_idleanim", self:SequenceDuration(), 1, function()
        if IsValid(self) then
            self:SendWeaponAnim(ACT_VM_IDLE)
        end
    end)
    self:SetNextPrimaryFire(CurTime() + 1)
end

SWEP.DoingTP = false
function SWEP:Reload()
    if self:GetDoingTP() then return end
    local target = self:GetTarget()
    if not IsValid(target) then return end
    if (self:GetZooming()) then return end
    if (self:Clip1() == 0) then return end
    self:SetTPStamp(CurTime() + self.TravelTime)
    self:SetDoingTP(true)

    self:EmitSound("weapons/deadmanstale/deadmanstaleperk.wav")
    self:GetTarget():EmitSound("weapons/deadmanstale/deadmanstaleperk.wav")
    self:TakePrimaryAmmo(1)

    local owner = self:GetOwner()
    if SERVER or (CLIENT and owner == LocalPlayer()) then
        self.origin = owner:GetPos()
        owner:SetFOV(120, self.TravelTime * .7)
        if CLIENT then
            owner:ScreenFade(SCREENFADE.IN, color_white, self.TravelTime * .7, 0)
        end
        owner:Wait(self.TravelTime * .7, function()
            if CLIENT then
                owner:ScreenFade(SCREENFADE.OUT, color_white, self.TravelTime * .5, 0)
            end
            owner:SetFOV(0, self.TravelTime * .3)
        end)
    end
end

function SWEP:SecondaryAttack()
    self:SetZooming(not self:GetZooming())
    if IsFirstTimePredicted() then
        if CLIENT then
            self:GetOwner():ScreenFade(SCREENFADE.IN, Color(0, 0, 0), .15, 0)
        end
        self:EmitSound("weapons/e_blaster/sf ethereal deploy.wav")
    end
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DEPLOY)
    timer.Create("TP_" .. self:EntIndex() .. "_idleanim", self:SequenceDuration(), 1, function()
        if IsValid(self) then
            self:SendWeaponAnim(ACT_VM_IDLE)
        end
    end)
end

function SWEP:Holster()
    return true
end

function SWEP:TranslateFOV(fov)
    if self:GetZooming() then
        return fov * .4 * self.ZoomLevel
    end
    return fov
end

function SWEP:AdjustMouseSensitivity()
    if (self:GetZooming()) then
        return self.ZoomLevel / 8
    end
end

function SWEP:DrawWorldModel()
    self:DrawModel()

    local owner = self:GetOwner()
    if (owner != LocalPlayer() and self:GetDoingTP()) then
        if not self.origin then
            self.origin = owner:GetPos()
        end
    elseif (owner != LocalPlayer() and self.origin) then
        self.origin = nil
    end

    self:UpdatePos()
end

local lastProgress = 0
function SWEP:UpdatePos()
    local progress = math.max(lastProgress, math.Clamp(1 - (self:GetTPStamp() - CurTime()) / self.TravelTime, 0, 1))
    lastProgress = progress
    self:GetOwner():SetPos(LerpVector(progress, self.origin, self:GetTarget():GetPos()))
    if (progress == 1) then
        lastProgress = 0
        self:SetTarget(nil)
        self:SetDoingTP(false)
    end
end

function SWEP:Think()
    if (self:Clip1() < self.Primary.ClipSize and self:GetNextBullet() < CurTime()) then
        self:SetClip1(self:Clip1() + 1)
        self:SetNextBullet(CurTime() + self.Primary.ReloadRate)
    end

    if (self:GetDoingTP()) then
        self:UpdatePos()
    end
end

local scopeMat = Material("scope/gdcw_closedsight")
local aimCrosshair = Material("scope/gdcw_acogcross")
local purple = Color(255, 100, 200)
function SWEP:DrawHUD()
    if self:GetZooming() then
        surface.SetMaterial(scopeMat)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH(), ScrH(), 0)

        surface.SetMaterial(aimCrosshair)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH() * .65, ScrH() * .65, 0)
    end

    local w, h = 392, 20
    local x, y = ScrW() / 2 - w / 2, ScrH() / 1.25
    local bulletWide = 128

    surface.SetDrawColor(purple)
    surface.DrawOutlinedRect(x, y, w, h)
    for k = 1, 3 do
        if (self:Clip1() < k - 1) then
            continue
        end
        local progress = self:Clip1() >= k and 1 or math.Clamp(1 - (self:GetNextBullet() - CurTime()) / self.Primary.ReloadRate, 0, 1)
        draw.RoundedBox(4, x + 2 + (bulletWide + 2) * (k - 1) , y + 2, bulletWide * progress, h - 4, Color(purple.r, purple.g, purple.b, progress * 150))
        if (progress == 1) then
            draw.RoundedBox(4, x + 2 + (bulletWide + 2) * (k - 1) + 1, y, (bulletWide - 3) * progress, h - 4, Color(255, 255, 255, progress * 150))
        end
    end

    if (self:Clip1() < 3) then
        local sec = math.Round(self:GetNextBullet() - CurTime(), 1)
        draw.SimpleText(sec, NebulaUI:Font(24), x + (bulletWide + 2) * self:Clip1(), y - h - 4, purple, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    local target = self:GetTarget()
    if IsValid(target) then
        local name = target:IsNPC() and language.GetPhrase(target:GetClass()) or target:Nick()
        draw.SimpleText("Target acquired", NebulaUI:Font(20), x + w / 2, y + h, purple, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(name, NebulaUI:Font(32), x + w / 2, y + h + 12, purple, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(name, NebulaUI:Font(32), x + w / 2, y + h + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    else
        draw.SimpleText("-Waiting Target-", NebulaUI:Font(20), x + w / 2, y + h, purple, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

local shadow = Material("vgui/scope_shadowmask")

net.Receive("NebulaRP.TPSniper:Notify", function()
    local progress = 5
    hook.Remove("HUDPaint", "NebulaRP.TPSniper:Notify")
    hook.Add("HUDPaint", "NebulaRP.TPSniper:Notify", function()
        if (progress > 0) then
            surface.SetMaterial(shadow)
            surface.SetDrawColor(0, 0, 0, (progress / 5) * 255)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            draw.SimpleText("You got Hit with a Teleport Sniper", NebulaUI:Font(64), ScrW() / 2, ScrH() / 1.4, Color(255, 255, 255, (progress / 5) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Prepare for troubles", NebulaUI:Font(32), ScrW() / 2, ScrH() / 1.4 + 42, Color(255, 255, 255, (progress / 5) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            progress = progress - FrameTime()
        else
            hook.Remove("HUDPaint", "NebulaRP.TPSniper:Notify")
        end
    end)
end)

