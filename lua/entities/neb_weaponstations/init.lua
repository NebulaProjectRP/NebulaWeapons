include('shared.lua')
util.AddNetworkString("NebulaRP.PurchaseWeaponStation")

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

local globalIndex = 0

function ENT:InitServer()
    self:SetModel("models/nebularp/vendingmachine.mdl")
    self:SetUseType(SIMPLE_USE)
    self:SetModelScale(.9, 0)
    self:Activate()
    globalIndex = globalIndex + 1

    timer.Create("NebulaRP.PurchaseWeaponStation." .. self:EntIndex(), 10 + globalIndex * FrameTime(), 1, function()
        if not IsValid(self) then return end
        self:RebuildItem()
    end)
end

function ENT:RebuildItem()
    local selectedItem

    for id, item in RandomPairs(NebulaInv.Items) do
        if item.type ~= "weapon" or item.rarity > 4 then continue end

        for _, ven in pairs(ents.FindByClass(self:GetClass())) do
            if ven:GetWeaponClass() == item.classname then
                item = nil
                break
            end
        end

        if not item then continue end
        selectedItem = item
    end

    self:SetWeaponClass(selectedItem.classname)
    self:SetPrice(selectedItem.rarity * 10000)
    self:SetCredits(selectedItem.rarity * 10)

    self:Wait(math.random(300, 1200), function()
        self:RebuildItem()
    end)
end

function ENT:DoPurchase(ply, option)
    if ply:HasWeapon(self:GetWeaponClass()) then
        DarkRP.notify(ply, 1, 5, "You already got this weapon!")

        return
    end

    if option == 1 and not ply:canAfford(self:GetPrice()) then
        DarkRP.notify(ply, 1, 5, "You can't afford this weapon!")

        return
    elseif option == 1 then
        ply:addMoney(-self:GetPrice())
    end

    if option == 2 and ply:getCredits() < self:GetCredits() and self:GetCredits() == 0 then
        DarkRP.notify(ply, 1, 5, "You can't afford this weapon with credits!")

        return
    elseif option == 2 then
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