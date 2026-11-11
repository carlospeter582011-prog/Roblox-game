-- Deterministic server-side movement profiles. Species differ by element and rarity.
-- This is a bounded horizontal displacement from the original spawn position.
local Flight = {}
local speeds = { Air = 1.4, Storm = 1.2, Cosmic = 0.55, Ice = 0.45, Earth = 0.35, Water = 0.7, Fire = 1.0, Nature = 0.6, Light = 0.8, Shadow = 0.75 }
local radii = { Air = 5, Storm = 4, Cosmic = 2, Ice = 1.5, Earth = 1, Water = 3, Fire = 3, Nature = 2, Light = 3, Shadow = 2.5 }
function Flight.profile(species)
    local element = type(species) == "table" and species.element or nil
    return { speed = speeds[element] or 0.5, radius = radii[element] or 2 }
end
function Flight.offset(species, seconds, seed)
    local p = Flight.profile(species)
    if type(seconds) ~= "number" or seconds ~= seconds or math.abs(seconds) == math.huge then seconds = 0 end
    if type(seed) ~= "number" or seed ~= seed or math.abs(seed) == math.huge then seed = 0 end
    local phase = seconds * p.speed + seed * 0.73
    return math.cos(phase) * p.radius, math.sin(phase * 0.7) * p.radius * 0.65
end
return table.freeze(Flight)
