AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Weapon Station"
ENT.Category = "NebulaRP"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Editable = true

function ENT:SpawnFunction(ply, tr, cs)
    if not tr.Hit then return end
    local ent = ents.Create(cs)
    local pos = tr.HitPos + tr.HitNormal * 10
    local tr2 = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 1000),
        filter = ent
    })
    local ang = tr.HitNormal:Angle()
    ang:RotateAroundAxis(ang:Up(), -90)

    ent:SetPos(tr2.HitPos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Entity", {
        KeyName = "entity",
        Edit = {type = "Generic", category = "Weapon Station", order = 1}
    })
    self:NetworkVar("Int", 0, "Price", {
        KeyName = "price",
        Edit = {type = "Int", category = "Weapon Station", order = 2}
    })
    self:NetworkVar("Int", 1, "Credits", {
        KeyName = "credits",
        Edit = {type = "Int", category = "Weapon Station", order = 3}
    })

    self:NetworkVarNotify("Entity", function(s, name, old, new)
        self.CacheText = nil
    end)
end

local can, cannot = Color(0, 255, 0), Color(255, 0, 0)

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/nebularp/vendingmachine.mdl")
        self:PhysicsInitStatic(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetModelScale(.9, 0)
    else
        hook.Add("PreDrawHalos", self, function(s)
            if LocalPlayer():GetEyeTrace().Entity == s then
                halo.Add({s}, LocalPlayer():canAfford(self:CalculatePrice(LocalPlayer())) and can or cannot, 2, 2, 2, true, false)
            end
        end)
    end

    self:PhysicsInitStatic(SOLID_VPHYSICS)
    --self:SetSolid(SOLID_NONE)
    self:Activate()
end

function ENT:Use(act)
    if (act.machinecooldown or 0) > CurTime() then
        DarkRP.notify(act, 1, 4, "You must wait " .. math.ceil(act.machinecooldown - CurTime()) .. " seconds before using this machine again.")
        return
    end
    act.machinecooldown = CurTime() + 30

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

ENT.CacheText = nil
function ENT:GetWeaponName()
    local txt = "Magnum - Drill"
    if not self.CacheText then
        
    end
    return txt, 32
end

local icon = Material("nebularp/ui/sb_logo")
local fire = Material("sprites/cannon_exp")
local green, blue = Color(62, 207, 62), Color(48, 158, 223)

function ENT:Draw()
    self:DrawModel()
    if halo.RenderedEntity() == self then return end
    local pos, ang = self:GetPos(), self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    pos = pos + ang:Forward() * 19
    pos = pos + ang:Right() * 13
    pos = pos + ang:Up() * 88.1
    local w, h = 312, 102
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
    draw.SimpleText("Weapon Station:", NebulaUI:Font(34), 8, 4, green, 0, 0)
    local name, font = self:GetWeaponName(w)
    draw.SimpleText(name, NebulaUI:Font(font), 8, 38, blue, 0, 0)
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