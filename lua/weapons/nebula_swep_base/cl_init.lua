include("shared.lua")

local _, folders = file.Find("weapons/nebula_swep_base/*", "LUA")
for k, v in pairs(folders) do
    include(v .. "/sh.lua")
end