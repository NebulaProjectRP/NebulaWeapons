AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local meta = FindMetaTable("Player")

function meta:getMaxProps()
    return 999
end

function SWEP:Initialize()
end