
SWEP.Base = "weapon_base"

SWEP.PrintName = "Healer"
SWEP.Author = "Gonzo"

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Spawnable = true
SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.Kinds = {
    [1] = {
        Healing = 25,
        Cooldown = 6,
        Speed = 25,
    },
    [2] = {
        Healing = 40,
        Cooldown = 15,
        Speed = 20,
    },
    [3] = {
        Healing = 75,
        Cooldown = 25,
        Speed = 10,
    },
    [4] = {
        Healing = 100,
        Cooldown = 40,
        Speed = 7.5,
    },
    [5] = {
        Healing = 200,
        Cooldown = 60,
        Speed = 10,
    }
}

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Kind")
    self:NetworkVar("Int", 1, "Heal")
    self:NetworkVar("Int", 2, "Poison")
    self:NetworkVar("Bool", 0, "Applied")
end

local healButton = CreateClientConVar("nebula_autoheal", tostring(KEY_F), true, true, "Key to equip the healer and heal yourself.")

function SWEP:Initialize()
    if CLIENT then
        hook.Add("PlayerButtonDown", self, function(s, ply, btn)
            if (ply:GetActiveWeapon() != s and btn == healButton:GetInt()) then
                ply:SelectWeapon(self)
            end
        end)
    end
end

function SWEP:Think()
    if (self:GetApplied() and self.nextHealth < CurTime()) then
        local healAmount = self.deltaTime * (1 / self:GetPoison())
        
        self:GetOwner():SetHealth(math.Clamp(self:GetOwner():Health() + healAmount, 0, self:GetOwner():GetMaxHealth()))
        self:SetHeal(self:GetHeal() - self.deltaTime)
        self.nextHealth = CurTime() + 1
        
        if (self:GetHeal() <= 0) then
            self:SetApplied(false)
        end
    end
    
    if (self:GetPoison() > 0) then
        if (self.poisonRecover > CurTime()) then return end
        self:SetPoison(math.max(self:GetPoison() - 1, 0))
        self._poisonRecover = CurTime() + kind.Cooldown
    end
end

function SWEP:Deploy()
    if (self:GetApplied()) then return end
    local kind = self.Kinds[self.Kind]
    self:SetApplied(true)
    self:SetHeal(kind.Healing)
    self:SetPoison(math.min(self:GetPoison() + 1, 5))
    self.doingHealing = true
    self.deltaTime = math.ceil(kind.Healing / kind.Speed)
    self._poisonRecover = CurTime() + kind.Cooldown

    self:Wait(.5, function()
        self.doingHealing = nil
        self:ConCommand("lastinv")
    end)
end

function SWEP:Holster()
    if (self.doingHealing) then return false end
end

function SWEP:ViewModelDrawn(vm)
end