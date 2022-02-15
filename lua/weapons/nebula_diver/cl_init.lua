include("shared.lua")

local sndGrappleHit		= Sound("weapons/grappling_hook_impact_default.wav")
local sndGrappleHitFlesh= Sound("weapons/grappling_hook_impact_flesh.wav")
local sndGrappleShoot	= Sound("weapons/grappling_hook_shoot.wav")
local sndGrappleReel	= Sound("weapons/grappling_hook_reel_start.wav")
local sndGrappleAbort	= Sound("weapons/grappling_hook_reel_stop.wav")

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(9.892, -0.811, 2.532), angle = Angle(-10.782, -7.685, 14.444) },
	["ValveBiped.square"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.clip"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, -30), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["v_element"] = { type = "Model", model = "models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.032, 1.476, -1.58), angle = Angle(0, 0, 177.921), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["v_element2"] = { type = "Model", model = "models/props_c17/pulleywheels_large01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(9.571, 3.808, -1.502), angle = Angle(-1.657, 89.515, 0), size = Vector(0.09, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "mm_materials/zinc01_low2", skin = 0, bodygroup = {} },
	["v_element3"] = { type = "Model", model = "models/props_c17/pulleywheels_large01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(9.571, 3.808, -1.502), angle = Angle(-1.657, 89.515, 45), size = Vector(0.09, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "mm_materials/zinc01_low2", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["w_element"] = { type = "Model", model = "models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.709, 1.886, -2), angle = Angle(0, 0, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

DEFINE_BASECLASS("nebula_sck")

function SWEP:Initialize()
    BaseClass.Initialize( self )
    hook.Add("CalcView", self, self.CalcView)
end

SWEP.RollLerp = 0
function SWEP:CalcView(ply, pos, angles, fov)
    if (self.RollLerp != 0) then
        self.RollLerp = math.Approach(self.RollLerp, 0, 1)
        if (self.RollLerp == 0) then
            self.RollLerp = 0
            return
        end
        angles.r = self.RollLerp
        return {
            angles = angles
        }
    end
end

function SWEP:GetRopeOrigin()
    local vm = self:GetOwner():GetViewModel(0)
    if not self.bonecache then
        self.bonecache = vm:LookupBone("ValveBiped.Bip01_R_Hand")
    end

    local pos, ang = vm:GetBonePosition(self.bonecache)
    pos = pos + ang:Forward() * 24
    debugoverlay.Cross(pos, 32, FrameTime() * 2, Color(0, 255, 0), true)
    return pos
end

local cabbleMat = Material("cable/cable_lit")
local quality = 32
SWEP.LerpedRope = {}
SWEP.Quadratic = 0
function SWEP:PostDrawViewModel(vm, ply, wep)

    if not IsValid(self:GetController()) then return end
    if (self.TrajectoryIndex < 1) then return end
    local muzzpos, muzzang = self:GetRopeOrigin()

    self:DrawRope(muzzpos)    
end

function SWEP:DrawRope(pos)
    local maxRopes = self.TrajectoryIndex
    for k, v in pairs(self.LerpedRope) do
        local power = (k) / maxRopes
        local targetLerp = Lerp(power, pos, self:GetController():GetController():GetPos())
        local factor = .5 + math.abs(power / 2 - 1)
        self.LerpedRope[k] = LerpVector(factor, self.LerpedRope[k], targetLerp)
        debugoverlay.Cross(self.LerpedRope[k], 16, FrameTime() * 2, Color(0, 0, 155), true)
        debugoverlay.Cross(self.Trajectory[k][2], 32, FrameTime() * 2, Color(0, 255, 0), true)
    end

    debugoverlay.Axis(pos, self:GetOwner():EyeAngles(), 16, 5, true)
    debugoverlay.Axis(self:GetController():GetController():GetPos(), self:GetController():GetController():GetAngles(), 16, FrameTime() * 4, true)
    render.SetColorModulation(1, 1, 1)
    render.SetMaterial(cabbleMat)
    render.StartBeam(self.TrajectoryIndex + 1)
    
    render.AddBeam(pos, 2, .5, color_white)
    render.SetBlend(1)
    for k, pos in pairs(self.LerpedRope) do
        render.AddBeam(pos, 2, k, color_white)
    end
    render.SetBlend(1)
    render.EndBeam()
end

function SWEP:DrawWorldModel()
    BaseClass.DrawWorldModel(self)
    if not IsValid(self:GetController()) then return end
    if (self.TrajectoryIndex < 1) then return end

    local boneID = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
    local pos, ang = self:GetOwner():GetBonePosition(boneID)
    self:DrawRope(pos)
end