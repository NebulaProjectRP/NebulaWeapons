AddCSLuaFile()
ENT.Base = "neb_nadebase"
ENT.PrintName = "Fire Bomb"
ENT.Spawnable = true
ENT.Category = "NebulaRP"
ENT.TintColor = Color(255, 0, 0)
ENT.ThrowForce = 500
ENT.Duration = 5

function ENT:Explode()
    self:EmitSound("common/bugreporter_failed.wav")
end

function ENT:OnActivate()
end