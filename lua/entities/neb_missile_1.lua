ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Howitzer_missile"
ENT.Category = "None"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.MyModel = "models/weapons/tfa_cso/w_tank_missile.mdl"
ENT.MyModelScale = 1
ENT.Damage = 80
ENT.Radius = 200

if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        local model = self.MyModel and self.MyModel or "models/weapons/tfa_cso/w_tank_missile.mdl"
        self.Class = self:GetClass()
        self:SetModel(model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:GetPhysicsObject():SetMass(1)
        self:SetHealth(1)
        self:SetModelScale(self.MyModelScale, 0)
        util.SpriteTrail(self, 0, Color(255, 255, 255), false, 7, 1, 0.1, 0.125, "trails/smoke.vmt")
        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:Wake()
        end
    end

    function ENT:PhysicsCollide(data, physobj)
        local owent = self.Owner and self.Owner or self
        local filter = {}
        for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Radius)) do
            if !v:IsPlayer() or filter[v] then continue end
            filter[v] = true
            local dmg = DamageInfo()
            dmg:SetAttacker(owent)
            dmg:SetInflictor(self)
            dmg:SetDamage(self.Damage)
            dmg:SetDamageType(DMG_BLAST)
            v:TakeDamageInfo(dmg)
        end
        //util.BlastDamage(self, owent, self:GetPos(), self.Radius, self.Damage)
        local fx = EffectData()
        fx:SetOrigin(self:GetPos())
        fx:SetNormal(data.HitNormal)
        util.Effect("exp_grenade", fx)
        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

local ENT2 = table.Copy(ENT)
ENT2.Base = "neb_missile_1"
ENT2.Damage = 125
ENT2.Radius = 200

scripted_ents.Register(ENT2, "neb_missile_2")

local ENT3 = table.Copy(ENT)
ENT3.Base = "neb_missile_1"
ENT3.Damage = 400
ENT3.Radius = 200
ENT3.MyModel = "models/weapons/tfa_cso/w_tank_missile.mdl"

scripted_ents.Register(ENT3, "neb_missile_3")

