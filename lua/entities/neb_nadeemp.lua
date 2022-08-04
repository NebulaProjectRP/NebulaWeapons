AddCSLuaFile()
ENT.Base = "neb_nadebase"
ENT.PrintName = "Fire Bomb"
ENT.Spawnable = true
ENT.Category = "NebulaRP"
ENT.TintColor = Color(0, 204, 255)
ENT.ThrowForce = 500
ENT.Duration = 5

if SERVER then
    util.AddNetworkString("NebulaNade.EMP")
end

game.AddParticles("particles/nebula.pcf")
PrecacheParticleSystem("suit_mecha_emp")
function ENT:Explode()
    if CLIENT then
        self:SetNoDraw(true)
        local part = CreateParticleSystem(self, "suit_mecha_emp", PATTACH_ABSORIGIN, 0, Vector(0, 0, 0))
        part:SetControlPoint(0, self:GetPos() - Vector(0, 0, 32))
        self:CallOnRemove("RemoveParticle", function()
            part:StopEmissionAndDestroyImmediately()
        end)
    else
        self:EmitSound("ambient/energy/weld" .. math.random(1, 2) .. ".wav")
        SafeRemoveEntityDelayed(self, 2)
        self:callOnClient(RPC_PVS, "Explode")

        for k, v in pairs(ents.FindInSphere(self:GetPos(), 400)) do
            MsgN(v:GetClass())
            if (v:GetClass() == "keypad") then
                v:DamageBreak()
                timer.Simple(5, function()
                    v:Repair()
                end)
            end
        end
    end
end

function ENT:OnActivate()
end