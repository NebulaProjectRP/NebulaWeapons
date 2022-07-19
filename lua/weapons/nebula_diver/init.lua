AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:Holster()
    return true
end

function SWEP:CreateProjectile(target, normal)
    local ent = ents.Create("nebula_pivot")
    ent:SetPos(self:GetOwner():GetPos() + Vector(0, 0, 32))
    ent:SetAngles(self:GetOwner():EyeAngles())
    ent:SetTarget(target)
    ent.Normal = -normal
    ent:SetOwner(self:GetOwner())
    ent:Setup(self:GetOwner())
    ent:Spawn()
    self:SetController(ent)
end


hook.Add( "GetFallDamage", "NebulaRP.Hook", function( ply, speed )
    if (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().IsDiver) then
        return 0
    end
end )