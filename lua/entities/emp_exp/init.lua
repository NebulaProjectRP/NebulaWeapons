-- Copyright (c) 2018 TFA Base Devs
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Damage = 100
ENT.Delay = 3

function ENT:Initialize()
    local mdl = self:GetModel()

    if not mdl or mdl == "" or mdl == "models/error.mdl" then
        self:SetModel("models/weapons/w_eq_fraggrenade.mdl")
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
    end

    self:EmitSound("weapons/flaregun/fire.wav")
    self:SetFriction(self.Delay)
    self.killtime = CurTime() + self.Delay
    self:DrawShadow(true)

    if not self.Inflictor and self:GetOwner():IsValid() and self:GetOwner():GetActiveWeapon():IsValid() then
        self.Inflictor = self:GetOwner():GetActiveWeapon()
    end
end

function ENT:Think()
    if self.killtime < CurTime() then
        self:Explode()

        return false
    end

    self:NextThink(CurTime())

    return true
end

ENT.ExplosionSound = "BaseExplosionEffect.Sound"

function ENT:DoExplosionEffect()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("eff_shuriken_elect", effectdata)
    self:EmitSound("ambient/energy/zap" .. math.random(1, 6) .. ".wav")
end

function ENT:PhysicsCollide(data, phys)
    if data.Speed > 60 then
        self.killtime = -1
    end
end

local POWER_RADIUS = 96

local doors = {
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true
}

function ENT:Explode()
    if not IsValid(self.Inflictor) then
        self.Inflictor = self
    end
    self.Damage = 25
    util.ScreenShake(self:GetPos(), POWER_RADIUS * 1.5, 4, 2, POWER_RADIUS * 1.5)

    for k, v in pairs(ents.FindInSphere(self:GetPos(), POWER_RADIUS)) do
        if (IsValid(v:GetPhysicsObject())) then
            v:SetRenderMode(RENDERMODE_NORMAL)
            v:SetRenderFX(kRenderFxNone)
        end

        if (doors[v:GetClass()]) then
            v:Fire("OpenAwayFrom", self._owner)
            v:Fire("SetSpeed", 800)
            v:Fire("unlock", 0)
            v:Fire("Open", 0)
            hook.Run("OnFadeDoorDeactived", self:GetOwner(), v)
            timer.Simple(0.5, function()
                v:Fire("SetSpeed", 150)
            end)
        elseif (v:IsPlayer()) then
            local dist = 100 - (self:GetPos():Distance(v:GetPos()) / POWER_RADIUS) * 100
            local dmg = DamageInfo()
            dmg:SetDamage(dist)
            dmg:SetAttacker(self:GetOwner() or v)
            dmg:SetInflictor(self:GetOwner() or v)
            dmg:SetDamageType(DMG_SHOCK)
            v:TakeDamageInfo(dmg)
        end

        if (v.isFadingDoor and (not v.emp_hasBlocker or (v.emp_blockerEnt:GetChargeEnd() <= CurTime()))) then
            local powner = v.owner
            if (IsValid(powner) and (powner.tooltime_playtime / 3600) < 5) then continue end
            if (not v.fadeActive) then
                v:fadeActivate()
                hook.Run("OnFadeDoorDeactived", self:GetOwner(), v)
                timer.Simple(10, function()
                    if IsValid(v) then
                        v:fadeDeactivate()
                    end
                end)
            end
        elseif (v.emp_hasBlocker) then
            local powner = v.emp_blockerEnt.pOwner
            if (IsValid(powner) and (powner.tooltime_playtime / 3600) < 5) then continue end
            local time = v.emp_blockerEnt:GetChargeEnd()
            v.emp_blockerEnt:SetChargeEnd(math.Clamp(time - 250, CurTime(), CurTime() + 9999))
            if (v.emp_blockerEnt:GetChargeEnd() < CurTime()) then
                hook.Run("OnFadeDoorDeactived", self:GetOwner(), v)
            end
        end
    end

    SafeRemoveEntityDelayed(self, 0)
    self:DoExplosionEffect()
end