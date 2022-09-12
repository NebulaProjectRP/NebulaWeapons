include("shared.lua")

function SWEP:InitCL()
    self.Shadow = ClientsideModel(self.WorldModel)
    self.Shadow:SetNoDraw(true)
    self.Shadow:SetParent(self:GetOwner())
    self:InitMods()
end

function SWEP:InitMods()
    if NebulaAcc.Trinkets and LocalPlayer():hasTrinket(self:GetClass()) then
        local data = NebulaAcc.Trinkets[self:GetClass()]
        if not data then return end
        local model = NebulaInv.Items[LocalPlayer():hasTrinket(self:GetClass())].model
        self.Trinket = ClientsideModel(model)
        self.Trinket:SetParent(self:GetOwner():GetViewModel())
        self.Trinket:SetNoDraw(true)

        self:CallOnRemove("RemoveTrinket", function()
            SafeRemoveEntity(self.Trinket)
        end)
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    return pos + ang:Right() * -3, ang + Angle(0, 6, 0)
end

local lwhite = Color(255, 255, 255, 25)
local purple = Color(16, 0, 26, 200)
local purple_opaque = Color(16, 0, 26)
local purple_charge = Color(145, 26, 219)
local beam_1 = Material("tracer/hardlight_arc_tracer")
local beam_2 = Material("tracers/tracer_tornado")
local explodePart = Material("sprites/trinity_stun_particles")
local plasma_exp = Material("sprites/sgmissilegs_plasma_ball")

function SWEP:DrawHUD()
    local w, h = 256, 32
    local x, y = ScrW() / 2 - w / 2, ScrH() - h - 156

    if self:GetHeat() > self.MaxHeat / 2 or self:GetActive() then
        surface.SetMaterial(explodePart)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(x + w / 4, y + h / 2, w, w / 2, 0)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w, w, 0)
        surface.DrawTexturedRectRotated(x + w / 2 + w / 4, y + h / 2, w, w / 2, 0)
    end

    draw.RoundedBox(8, x, y, w, h, lwhite)
    draw.RoundedBox(8, x + 1, y + 1, w - 2, h - 2, purple)
    draw.RoundedBox(8, x + 8, y + 8, w - 16, h - 16, purple_opaque)
    draw.SimpleText("Magnum Charge:", NebulaUI:Font(20, false), x, y - 4, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.RoundedBox(8, x + 10, y + 10, (w - 20) * (self:GetHeat() / self.MaxHeat), h - 20, purple_charge)
end

SWEP.Beams = {}
SWEP.ExplodePlaces = {}
SWEP.FlareEvent = nil
local lifeTime = .1
SWEP.NextFlare = 0

function SWEP:CreateEffect(target)
    local active = self:GetActive()
    local diff = target - self:GetOwner():GetShootPos()
    local distance = diff:Length()

    local entry = {
        dir = diff:GetNormalized(),
        dist = distance,
        target = target,
        max = lifeTime,
        stamp = RealTime() + lifeTime,
        active = active,
    }

    table.insert(self.Beams, entry)

    if self.NextFlare < CurTime() then
        self.NextFlare = CurTime() + lifeTime

        self.FlareEvent = {
            time = CurTime(),
            active = active
        }
    end

    timer.Simple(0.05, function()
        table.insert(self.ExplodePlaces, {
            pos = target,
            normal = diff:GetNormalized(),
            time = RealTime() + lifeTime,
            active = active
        })
    end)
end

local flare_new = CreateMaterial("flare_material", "UnlitGeneric", {
    ["$basetexture"] = "sprites/trinity_stun",
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$additive"] = 1,
    ["$nocull"] = 1,
    ["$ignorez"] = 1,
    ["$illumfactor"] = 8
})

function SWEP:PreDrawViewModel(vm, ply, wep)
    if not self.DisableSkinGroups then
        vm:SetBodygroup(8, self:GetNextPrimaryFire() < CurTime() and 0 or 1)
        vm:SetBodygroup(7, self:GetActive() and 0 or 1)
    end

    self:DisplayEffects()
end

function SWEP:PostDrawViewModel(vm, ply, wep)
    if IsValid(self.Trinket) then
        local boneid = vm:LookupBone("sm_root")
        local pos, ang = vm:GetBonePosition(boneid)
        ang:RotateAroundAxis(ang:Up(), 110)
        ang:RotateAroundAxis(ang:Forward(), 90)
        pos = pos + ang:Forward() * 3 + ang:Up() * 1
        self.Trinket:SetPos(pos)
        self.Trinket:SetAngles(ang)
        self.Trinket:DrawModel()
    end
end

function SWEP:DisplayEffects()
    local vm = self:GetOwner():GetViewModel(0)
    local att = vm:GetAttachment(1)
    local ang = vm:GetAngles()
    local toremove
    local origin = att.Pos + ang:Forward() * 12 + ang:Right() * 3

    if self.FlareEvent then
        render.SetMaterial(flare_new)
        local progress = (CurTime() - self.FlareEvent.time) / lifeTime
        local size = 16 + progress * (self.FlareEvent.active and 128 or 32)
        render.DrawSprite(origin, size, size, Color(255, 255, 255, math.Clamp((1 - progress) * 255, 0, 255)))

        if progress >= 1 then
            self.FlareEvent = nil
        end
    end

    if self:GetActive() then
        render.SetMaterial(explodePart)
        render.DrawSprite(att.Pos, 24, 24, color_white)
    end

    for k, v in pairs(self.Beams) do
        local progress = 1 - (v.stamp - RealTime()) / v.max
        local pointa = LerpVector(progress, origin, v.target) - v.dir * (v.dist / 2) * progress
        local pointb = pointa + v.dir * (v.dist / 2)
        render.SetMaterial(beam_1)
        render.DrawBeam(pointa, pointb, 8 + progress * (v.active and 200 or 96), 0, 1, color_white)
        render.SetMaterial(beam_2)
        render.DrawBeam(pointa, pointb, 4 + progress * (v.active and 64 or 16), 0, 1, color_white)

        if progress >= 1 then
            toremove = k
        end
    end

    for k, v in pairs(self.ExplodePlaces) do
        local progress = (v.time - RealTime()) / lifeTime
        local size = 64 + (1 - progress) * (v.active and 200 or 96)
        render.SetMaterial(plasma_exp)
        render.DrawSprite(v.pos, size, size, Color(255, 255, 255, math.Clamp(progress * 255, 0, 255)))

        if progress <= 0 then
            table.remove(self.ExplodePlaces, k)
        end
    end

    if toremove then
        table.remove(self.Beams, toremove)
    end
end

function SWEP:DrawWorldModel()
    if IsValid(self.Shadow) then
        local offsetVec = Vector(5, -2.7, -3.4)
        local offsetAng = self.WorldModelAngles
        local boneid = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
        if not boneid then return end
        local matrix = self:GetOwner():GetBoneMatrix(boneid)
        if not matrix then return end
        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
        self.Shadow:SetPos(newPos)
        self.Shadow:SetAngles(newAng)
        self.Shadow:SetupBones()
        self.Shadow:DrawModel()
    end

    if self:GetActive() then
        local owner = self:GetOwner()

        for k = 1, 6 do
            local prg = (RealTime() * 4) + k * (math.pi / 2)
            local force = (RealTime() / 2 + k) % 1
            local alpha = Color(255, 255, 255, force)
            local extra = 18 - 2 * k
            render.SetMaterial(explodePart)
            render.DrawSprite(owner:GetPos() + Vector(math.cos(prg) * extra, math.sin(prg) * extra, 8 * k), 48 * force, 48 * force, alpha)
        end
    end

    self:DisplayEffects()
end

net.Receive("NebulaWep.MagnumEffect", function()
    local wep = net.ReadEntity()
    local targetPos = net.ReadVector()
    if not IsValid(wep) then return end
    wep:CreateEffect(targetPos)
end)