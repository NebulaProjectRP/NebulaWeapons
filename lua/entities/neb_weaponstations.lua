AddCSLuaFile()
ENT.Base = "base_anim"
ENT.PrintName = "Weapon Station"
ENT.Category = "NebulaRP"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Editable = true

if SERVER then
    util.AddNetworkString("NebulaRP.PurchaseWeaponStation")
end

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
    self:NetworkVar("String", 0, "WeaponClass", {
        KeyName = "weaponclass",
        Edit = {type = "Generic", category = "Weapon Station", order = 1}
    })
    self:NetworkVar("Int", 0, "Price", {
        KeyName = "price",
        Edit = {type = "Int", category = "Weapon Station", order = 2, min = 10000, max = 50000}
    })
    self:NetworkVar("Int", 1, "Credits", {
        KeyName = "credits",
        Edit = {type = "Int", category = "Weapon Station", order = 3, min = 10, max = 1000}
    })

    self:NetworkVarNotify("WeaponClass", function(s, name, old, new)
        self.CacheText = nil
        self.CacheSize = nil
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
end

function ENT:DoPurchase(ply, option)
    if ply:HasWeapon(self:GetWeaponClass()) then
        DarkRP.notify(ply, 1, 5, "You already got this weapon!")
        return
    end

    if (option == 1 and not ply:canAfford(self:GetPrice())) then
        DarkRP.notify(ply, 1, 5, "You can't afford this weapon!")
        return
    elseif (option == 1) then
        ply:addMoney(-self:GetPrice())
    end

    if (option == 2 and ply:getCredits() < self:GetCredits()) then
        DarkRP.notify(ply, 1, 5, "You can't afford this weapon with credits!")
        return
    elseif (option == 2) then
        ply:addCredits(-self:GetCredits(), "Weapon Station")
    end

    local wep = ply:Give(self:GetWeaponClass())
    DarkRP.notify(ply, 0, 5, "You have purchased a " .. wep:GetPrintName() .. " for " .. (option == 2 and (self:GetCredits() .. " credits!") or DarkRP.formatMoney(self:GetPrice())) .. ".")
    hook.Run("OnWeaponStationBuy", ply, wep, self:GetWeaponClass(), option)
end

net.Receive("NebulaRP.PurchaseWeaponStation", function(l, ply)
    local ent = net.ReadEntity()
    local option = net.ReadUInt(2)

    if IsValid(ent) and ent:GetClass() == "neb_weaponstations" and ply:GetEyeTrace().Entity == ent then
        ent:DoPurchase(ply, option)
    end
end)

function ENT:CalculatePrice(ply)
    local money = ply:getDarkRPVar("money")

    return math.min(math.Round(money * .01), 7500)
end

ENT.CacheText = nil
ENT.CacheSize = nil
function ENT:GetWeaponName(w)
    local weapon = weapons.GetStored(self:GetWeaponClass())
    local txt = ""
    if not weapon then
        txt = "No weapon"
    else
        txt = weapon.PrintName
    end

    if not self.CacheText then
        local size = 96
        surface.SetFont(NebulaUI:Font(size))
        local tx, _ = surface.GetTextSize(txt)
        while (tx > (w - 16)) do
            size = size - 2
            surface.SetFont(NebulaUI:Font(size))
            tx, _ = surface.GetTextSize(txt)
        end
        self.CacheText = txt
        self.CacheSize = size

        if IsValid(self.Model) then
            self.Model:Remove()
        end

        self.Model = ClientsideModel(weapon.WorldModel)
        self.Model:SetNoDraw(true)
        self.Model:SetParent(self)
        self.Model:SetLocalPos(Vector(0, 0, 90))
    end
    return self.CacheText, self.CacheSize
end

local icon = Material("nebularp/ui/sb_logo")
local fire = Material("sprites/cannon_exp")
local green, blue = Color(62, 207, 62), Color(48, 158, 223)
local eWasPressed = false
function ENT:Draw()
    self:DrawModel()
    
    local pos, ang = self:GetPos(), self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    pos = pos + ang:Forward() * 19
    pos = pos + ang:Right() * 13
    pos = pos + ang:Up() * 88.1
    local w, h = 312, 102
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    cam.Start3D2D(pos, ang, .1)
        surface.SetDrawColor(16, 16, 16)
        surface.DrawRect(1, 1, w - 2, h - 2)

        draw.SimpleText("Weapon Station:", NebulaUI:Font(34), 8, 4, green, 0, 0)
        local name, font = self:GetWeaponName(w)
        draw.SimpleText(name, NebulaUI:Font(font), 8, 38, blue, 0)
    cam.End3D2D()

    pos = pos + ang:Right() * 44
    pos = pos + ang:Up() * .4
    w, h = 320, 72

    local ray = util.IntersectRayWithPlane(LocalPlayer():EyePos(), LocalPlayer():GetAimVector(), pos, ang:Up())
    if (ray) then
        local lray = self:WorldToLocal(ray)
        if (math.abs(lray.x) < 18 and lray.z < 44 and lray.z > 25) then
            self.OptionSelected = lray.z > 35 and 1 or 2
        else
            self.OptionSelected = 0
        end
    else
        self.OptionSelected = 0
    end

    if (self.OptionSelected > 0 and not eWasPressed and input.IsKeyDown(KEY_E)) then
        eWasPressed = true
        net.Start("NebulaRP.PurchaseWeaponStation")
        net.WriteEntity(self)
        net.WriteUInt(self.OptionSelected, 2)
        net.SendToServer()
    elseif (eWasPressed and not input.IsKeyDown(KEY_E)) then
        eWasPressed = false
    end

    cam.Start3D2D(pos, ang, .1)
        surface.SetDrawColor(255, 255, 255, 24)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(55, 172, 55, self.OptionSelected == 1 and 255 or 125)
        surface.DrawRect(1, 1, w - 2, h - 2)
        local y = 30 + math.cos(RealTime() * 2) * ((h - 32) / 4)
        surface.SetDrawColor(color_white)
        draw.SimpleText("Price:", NebulaUI:Font(24), 4, -2, color_white, 0, TEXT_ALIGN_TOP)
        draw.SimpleText(DarkRP.formatMoney(self:GetPrice()), NebulaUI:Font(44, true), 4, h - 2, color_white, 0, TEXT_ALIGN_BOTTOM)
    cam.End3D2D()

    pos = pos + ang:Right() * 10
    w, h = 320, 72

    cam.Start3D2D(pos, ang, .1)
        surface.SetDrawColor(255, 255, 255, 24)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(199, 56, 204, self.OptionSelected == 2 and 255 or 125)
        surface.DrawRect(1, 1, w - 2, h - 2)
        local y = 30 + math.cos(RealTime() * 2) * ((h - 32) / 4)
        surface.SetDrawColor(color_white)
        draw.SimpleText("Credits:", NebulaUI:Font(24), 4, -2, color_white, 0, TEXT_ALIGN_TOP)
        draw.SimpleText(self:GetCredits(), NebulaUI:Font(44, true), 4, h - 2, color_white, 0, TEXT_ALIGN_BOTTOM)
    cam.End3D2D()

    if IsValid(self.Model) then
        if (self.Model:GetParent() != self) then
            self.Model:SetParent(self)
        end
        render.SuppressEngineLighting(true)
        self.Model:DrawModel()
        render.SuppressEngineLighting(false)
        self.Model:SetLocalPos(Vector(-2, 15, 60))
        self.Model:SetLocalAngles(Angle(35, (RealTime() * 30) % 360, 0))
    end

    if halo.RenderedEntity() == self then return end
end