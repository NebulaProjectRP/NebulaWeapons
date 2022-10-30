
SWEP.Base = "weapon_base"

SWEP.PrintName = "Healer"
SWEP.Author = "Gonzo"

SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = ""

SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.Slot = 10
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
    self:NetworkVar("Float", 0, "Heal")
    self:NetworkVar("Int", 2, "Poison")
    self:NetworkVar("Bool", 0, "Applied")
    self:SetPoison(0)
    self:SetKind(1)
    self:SetHeal(0)
end

local healButton = CreateClientConVar("nebula_autoheal", tostring(KEY_F), true, true, "Key to equip the healer and heal yourself.")

function SWEP:Initialize()
    if CLIENT then
        hook.Add("PlayerButtonDown", self, function(s, ply, btn)
            if (ply:GetActiveWeapon() != s and btn == healButton:GetInt()) then
                self.currWeapon = ply:GetActiveWeapon():GetClass()
                input.SelectWeapon(self)
            end
        end)

        hook.Add("RenderScreenspaceEffects", self, function(s)
            self:RenderScreenspaceEffects()
        end)
    end

    self:SetApplied(false)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    if CLIENT then return end

    if (self:GetPoison() > 0 and (self.nextHealth or 0) < CurTime()) then
        local healAmount = self.deltaTime * (1 / self:GetPoison())
        self:GetOwner():SetHealth(math.Clamp(self:GetOwner():Health() + healAmount, 0, self:GetOwner():GetMaxHealth()))
        self:SetHeal(self:GetHeal() - self.deltaTime)
        self.nextHealth = CurTime() + .25

        if (self:GetHeal() <= 0) then
            self:SetApplied(false)
        end
    end

    if (self:GetPoison() > 0 and self.poisonRecover > CurTime()) then
        self:SetPoison(0)
    end

end

function SWEP:Deploy()
    if not IsFirstTimePredicted() then return end
    //if (self:GetApplied()) then return end
    local kind = self.Kinds[self:GetKind()]
    self:SetApplied(true)
    self:SetHeal(kind.Healing)
    self:SetPoison(math.min(self:GetPoison() + 1, 5))
    self:EmitSound("physics/cardboard/cardboard_box_impact_soft4.wav")
    self.doingHealing = true
    self.nextHealth = CurTime()
    self.deltaTime = (self:GetOwner():GetMaxHealth() * (kind.Healing / 100)) / ((kind.Healing / kind.Speed) * 4)
    self.poisonRecover = CurTime() + kind.Cooldown
    if CLIENT then
        self.anim = {
            start = CurTime(),
            duration = .4,
            progress = 0,
            shouldReturn = false,
            sound = false
        }
    else
        self:GetOwner():addBuff("healing", kind.Cooldown)
    end

    self:Wait(.8, function()
        self.doingHealing = nil
        self:SetApplied(false)
        if CLIENT then
            self:GetOwner():ConCommand("use " .. self.currWeapon)
        end
    end)
end

function SWEP:Holster()
    if (self.doingHealing) then return false end
    if CLIENT then
        local vm = self:GetOwner():GetViewModel(0)
        local bone = vm:LookupBone("ValveBiped.Bip01_L_Forearm")
        vm:ManipulateBoneAngles(bone, Angle(0, 0, 0))
    end
    return true
end

if SERVER then return end

local tpEffect = Material("effects/tp_eyefx/tpeye")

function SWEP:RenderScreenspaceEffects()
    if (self.effectPowder or 0) <= 0 then return end

    self.effectPowder = self.effectPowder - FrameTime()
    DrawMaterialOverlay("effects/strider_pinch_dudv", self.effectPowder / 8)
    render.SetBlend(self.effectPowder)
    render.SetMaterial(tpEffect)
    render.DrawScreenQuad()
    render.SetBlend(1)

    DrawColorModify({
        [ "$pp_colour_contrast" ] = 1 + self.effectPowder,
        [ "$pp_colour_colour" ] = 1 + self.effectPowder * 3,
        [ "$pp_colour_mulb" ] = self.effectPowder * 3,
        [ "$pp_colour_addb" ] = self.effectPowder * .24,
    })
end

function SWEP:TranslateFOV(fov)
    if (self.effectPowder or 0) <= 0 then return end
    return fov + self.effectPowder * 60
end

function SWEP:ViewModelDrawn(vm)
    if not IsValid(self.Vial) then
        self.Vial = ClientsideModel("models/healthvial.mdl")
        self.Vial:SetParent(vm)
        self.Vial:SetLocalPos(Vector(0, 0, 0))
        self.Vial:SetNoDraw(true)
        self:CallOnRemove("RemoveVial", function()
            SafeRemoveEntity(self.Vial)
        end)
    else
        local bone = vm:LookupBone("ValveBiped.Bip01_R_Clavicle")
        if (bone) then
            vm:ManipulateBoneAngles(bone, Angle(0, 0, 90))
        end

        bone = vm:LookupBone("Slam_base")
        if (bone) then
            vm:ManipulateBoneAngles(bone, Angle(0, 0, 90))
        end

        bone = vm:LookupBone("ValveBiped.Bip01_L_Hand")
        if not bone then return end
        local matrix = vm:GetBoneMatrix(bone)
        if not matrix then return end
        local pos, ang = matrix:GetTranslation(), matrix:GetAngles()
        if pos == vm:GetPos() then
            pos = vm:GetBoneMatrix(0):GetTranslation()
        end
        pos = pos + ang:Forward() * 4 + ang:Right() * 2.5 + ang:Up() * -4
        ang:RotateAroundAxis(ang:Up(), 200)
        self.Vial:SetPos(pos)
        self.Vial:SetAngles(ang)
        self.Vial:DrawModel()

        bone = vm:LookupBone("ValveBiped.Bip01_L_Forearm")
        if (self.anim and bone) then
            local power = 0
            if (not self.anim.shouldReturn) then
                local progress = (CurTime() - self.anim.start) / self.anim.duration
                power = math.min(1, progress)
                if (progress >= 1 and not self.anim.sound) then
                    surface.PlaySound("items/smallmedkit1.wav")
                    self.anim.sound = true
                    self.anim.power = .4
                    self.effectPowder = .8
                end
                if (progress >= 2) then
                    self.anim.shouldReturn = true
                    self.anim.sound = false
                    self.anim.start = CurTime()
                end
            else
                power = 1 - math.min(1, (CurTime() - self.anim.start) / (self.anim.duration / 2))
                if (power <= 0) then
                    self.anim = nil
                    return
                end
            end

            self.anim.progress = power
            vm:ManipulateBoneAngles(bone, Angle(-0, -40 * power, -20 * power))
        end
    end
end