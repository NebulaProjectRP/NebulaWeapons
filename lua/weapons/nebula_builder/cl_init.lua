include("shared.lua")

local hoverColor = Color(150, 255, 50)
function SWEP:Initialize()
    hook.Add("PlayerButtonUp", self, function(s, pl, btn)
        self:ButtonPressed(btn, true)
    end)
    hook.Add("PlayerButtonDown", self, function(s, pl, btn)
        self:ButtonPressed(btn, false)
    end)

    hook.Add("PreDrawHalos", self, function(s)
        if IsValid(self.Aim) then
            halo.Add({self.Aim}, hoverColor, 1, 1, 1)
        end
    end)
end

function SWEP:ButtonPressed(btn, released)
end

SWEP.ModelAim = ""
SWEP.ModelInfo = Vector(0, 0, 0)

local faceColor = {
    x = Color(255, 0, 0),
    y = Color(0, 255, 0),
    z = Color(0, 0, 255),
    c = Color(255, 255, 255, 50)
}
function SWEP:DrawHUD()
    local owner = self:GetOwner()
    self.Aim = self:GetAimEntity()
    if not IsValid(self.Aim) then return end

    if (true or self.ModelAnim != self.Aim:GetModel()) then
        local modelName = string.sub(self.Aim:GetModel(), #self.PropBase + 1)
        for kind, res in pairs(self.Resolvers) do
            if (string.StartWith(modelName, kind)) then
                self.ModelAim = self.Aim:GetModel()
                self.ModelInfo = res(modelName)
                break
            end
        end
    end

    local tr = owner:GetEyeTrace()

    local origin = self.Aim:OBBCenter()
    local size = 24
    cam.Start3D()
    render.SetColorMaterial()
    
    local realCenter = self.Aim:LocalToWorld(self.Aim:OBBCenter())
    local length = self.Aim:WorldToLocal(self.Aim:GetPos() + tr.HitNormal)
    local extra = self.Aim:LocalToWorld(self.Aim:OBBCenter() + length * self.ModelInfo * size)
    local hitLocal = self.Aim:WorldToLocal(extra)

    render.DrawSphere(realCenter, 2, 8, 8, faceColor.c)
    render.DrawLine(realCenter, self.Aim:LocalToWorld(hitLocal), color_white)
    render.DrawSphere(self.Aim:LocalToWorld(hitLocal), 2, 8, 8, faceColor.c)
    render.DrawLine(realCenter, self.Aim:LocalToWorld(hitLocal), color_white)

    local pos = self.Aim:LocalToWorld(origin + Vector(self.ModelInfo.x, 0, 0) * -size)
    render.DrawQuadEasy(pos, -self.Aim:GetForward(), 16, 16, faceColor.x, 0)
    pos = self.Aim:LocalToWorld(origin + Vector(self.ModelInfo.x, 0, 0) * size)
    render.DrawQuadEasy(pos, self.Aim:GetForward(), 16, 16, faceColor.x, 0)

    pos = self.Aim:LocalToWorld(origin + Vector(0, self.ModelInfo.y, 0) * size)
    render.DrawQuadEasy(pos, -self.Aim:GetRight(), 16, 16, faceColor.y, 0)
    pos = self.Aim:LocalToWorld(origin + Vector(0, self.ModelInfo.y, 0) * -size)
    render.DrawQuadEasy(pos, self.Aim:GetRight(), 16, 16, faceColor.y, 0)

    pos = self.Aim:LocalToWorld(origin + Vector(0, 0, self.ModelInfo.z) * size)
    render.DrawQuadEasy(pos, self.Aim:GetUp(), 16, 16, faceColor.z, 0)
    pos = self.Aim:LocalToWorld(origin + Vector(0, 0, self.ModelInfo.z) * -size)
    render.DrawQuadEasy(pos, -self.Aim:GetUp(), 16, 16, faceColor.z, 0)

    cam.End3D()
end