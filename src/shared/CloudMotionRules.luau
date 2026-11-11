-- Deterministic, bounded elemental movement for catchable 3D clouds.
-- Pure Luau: server owns positions; no client movement or physics authority.
local Motion = {}
local patterns = {
    Air = {radius = 2.8, speed = 0.8, vertical = 0.7},
    Water = {radius = 1.4, speed = 0.45, vertical = 0.45},
    Storm = {radius = 2.4, speed = 1.4, vertical = 0.9},
    Fire = {radius = 1.6, speed = 1.1, vertical = 0.8},
    Ice = {radius = 0.8, speed = 0.35, vertical = 0.3},
    Cosmic = {radius = 2.2, speed = 0.55, vertical = 1},
    Nature = {radius = 1, speed = 0.5, vertical = 0.5},
    Earth = {radius = 0.6, speed = 0.3, vertical = 0.25},
    Light = {radius = 1.5, speed = 0.7, vertical = 0.6},
    Shadow = {radius = 1.8, speed = 0.6, vertical = 0.55},
}
function Motion.offset(element, seconds, seed)
    if type(seconds) ~= "number" or seconds ~= seconds or seconds == math.huge or seconds == -math.huge then
        return 0, 0, 0
    end
    if type(seed) ~= "number" or seed ~= seed or seed == math.huge or seed == -math.huge then
        return 0, 0, 0
    end
    local p = patterns[element] or patterns.Air
    local t = seconds * p.speed + (seed % 97) * 0.31
    local x = math.sin(t) * p.radius
    local z = math.cos(t * 0.73) * p.radius
    local y = math.sin(t * 1.17) * p.vertical
    return x, y, z
end
return Motion
