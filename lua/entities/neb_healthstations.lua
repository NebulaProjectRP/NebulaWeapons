AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Health Station"
ENT.Category = "NebulaRP"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SpawnFunction(ply, tr, cs)
    if not tr.Hit then return end
    local ent = ents.Create(cs)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(tr.HitNormal:Angle())
    ent:Spawn()
    ent:Activate()

    return ent
end

local can, cannot = Color(0, 255, 0), Color(255, 0, 0)

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_combine/health_charger001.mdl")
        self:PhysicsInitStatic(SOLID_VPHYSICS)
        --self:SetSolid(SOLID_NONE)
        self:SetUseType(SIMPLE_USE)
    else
        hook.Add("PreDrawHalos", self, function(s)
            if LocalPlayer():GetEyeTrace().Entity == s then
                halo.Add({s}, LocalPlayer():canAfford(self:CalculatePrice(LocalPlayer())) and can or cannot, 2, 2, 2, true, false)
            end
        end)
    end

    self:SetModelScale(1.5, 0)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    --self:SetSolid(SOLID_NONE)
    self:Activate()
end

function ENT:Use(act)
    if (act.machinecooldown or 0) > CurTime() then return end
    act.machinecooldown = CurTime() + 1

    if act:Health() >= act:GetMaxHealth() and act:Armor() >= act:GetMaxArmor() then
        self:EmitSound("nebularp/duck_pickup_neg_01.wav")
        DarkRP.notify(act, 1, 4, "You are already at full health and armor!")

        return
    end

    if act:canAfford(self:CalculatePrice(act)) then
        act:addMoney(-self:CalculatePrice(act))
        act:SetHealth(act:GetMaxHealth() + math.Round(act:GetMaxHealth() / 10))
        act:SetArmor(act:GetMaxArmor() + math.Round(act:GetMaxArmor() / 10))
        self:EmitSound("nebularp/duck_pickup_pos_01.wav")
        DarkRP.notify(act, 0, 4, "You have been healed for $" .. self:CalculatePrice(act))
    end
end

function ENT:CalculatePrice(ply)
    local money = ply:getDarkRPVar("money")

    return math.min(math.Round(money * .01), 7500)
end

local icon = Material("nebularp/ui/sb_logo")
local fire = Material("sprites/cannon_exp")
local green, blue = Color(62, 207, 62), Color(48, 158, 223)

function ENT:Draw()
    self:DrawModel()
    if halo.RenderedEntity() == self then return end
    local pos, ang = self:GetPos(), self:GetAngles()
    pos = pos + ang:Forward() * 8.75
    pos = pos + ang:Right() * 14
    pos = pos + ang:Up() * 28
    local w, h = 94, 206
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    cam.Start3D2D(pos, ang, .1)
    surface.SetDrawColor(255, 255, 255, 24)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(16, 16, 16)
    surface.DrawRect(1, 1, w - 2, h - 2)
    local y = 30 + math.cos(RealTime() * 2) * ((h - 32) / 4)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(fire)
    surface.DrawTexturedRectRotated(w / 2, y + h / 2, w, w, 0)
    surface.SetMaterial(icon)
    surface.DrawTexturedRectRotated(w / 2, y + h / 2, w * .7, w * .7, (RealTime() * 120) % 360)
    draw.SimpleText("Health", NebulaUI:Font(34), w / 2, 20, green, 1, 1)
    draw.SimpleText("Station", NebulaUI:Font(32), w / 2, 44, blue, 1, 1)
    cam.End3D2D()
    pos = pos + ang:Right() * 33
    pos = pos + ang:Up() * .4
    w, h = 250, 64
    cam.Start3D2D(pos, ang, .1)
    surface.SetDrawColor(255, 255, 255, 24)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(16, 16, 16)
    surface.DrawRect(1, 1, w - 2, h - 2)
    local y = 30 + math.cos(RealTime() * 2) * ((h - 32) / 4)
    surface.SetDrawColor(color_white)
    draw.SimpleText("Cost:", NebulaUI:Font(24), 4, -2, blue, 0, TEXT_ALIGN_TOP)
    draw.SimpleText(DarkRP.formatMoney(self:CalculatePrice(LocalPlayer())), NebulaUI:Font(44, true), 4, h - 2, green, 0, TEXT_ALIGN_BOTTOM)
    cam.End3D2D()
end