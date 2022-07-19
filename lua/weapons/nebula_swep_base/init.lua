AddCSLuaFile("shared.lua")
include("shared.lua")

local _, folders = file.Find("weapons/nebula_swep_base/*", "LUA")
for k, v in pairs(folders) do
    AddCSLuaFile(v .. "/sh.lua")
    AddCSLuaFile(v .. "/sv.lua")
    include(v .. "/sh.lua")
    include(v .. "/sv.lua")
end