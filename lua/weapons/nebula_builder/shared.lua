SWEP.PrintName = "Builder"
SWEP.Author = "Gonzo"
SWEP.Category = "NebulaRP"
SWEP.WorldModel = ""
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true

function SWEP:SetupDataTables()
end

function SWEP:PrimaryAttack()
end

SWEP.PropBase = "models/hunter/blocks/"

SWEP.Resolvers = {
    ["cube"] = function(str)
        str = string.Explode("x", string.sub(str, 5, #str - 4), false)
        for k = 1, 3 do
            if (str[k][1] == "0") then
                str[k] = string.sub(str[k], 2)
                str[k] = string.Trim(str[k])
                if (#str[k] == 2) then
                    str[k] = tonumber(str[k][1] .. (str[k][2] or "")) / 100
                else
                    str[k] = tonumber(str[k][1]) / 10
                end
            else
                str[k] = tonumber(str[k])
            end
        end
        return Vector(str[1], str[2], str[3])
    end
}

function SWEP:SecondaryAttack()
end


function SWEP:GetAimEntity()
    local ent = self:GetOwner():GetEyeTrace().Entity

    if not IsValid(ent) or ent:GetClass() != "prop_physics" then return end

    local mdl = ent:GetModel()
    if not string.StartWith(mdl, self.PropBase) then return end
    return ent
end
