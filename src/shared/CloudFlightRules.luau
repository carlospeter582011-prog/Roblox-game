-- Pure server-authoritative flight patterns; no Roblox services.
-- The original spawn point is immutable. Movement is bounded within its island.
local Flight = {}
local patterns = {
    Air = { radius = 5, speed = 1.1, rise = 1.2 },
    Water = { radius = 2.5, speed = 0.7, rise = 0.7 },
    Storm = { radius = 6, speed = 1.7, rise = 1.5 },
    Fire = { radius = 3.5, speed = 1.4, rise = 1.0 },
    Ice = { radius = 1.5, speed = 0.45, rise = 0.4 },
    Nature = { radius = 2, speed = 0.5, rise = 0.6 },
    Earth = { radius = 1, speed = 0.35, rise = 0.3 },
    Light = { radius = 4, speed = 0.9, rise = 1.1 },
    Shadow = { radius = 3, speed = 0.8, rise = 0.9 },
    Cosmic = { radius = 4.5, speed = 0.6, rise = 1.4 },
}
local fallback = { radius = 2, speed = 0.6, rise = 0.5 }
function Flight.offset(element, seconds, seed)
    if type(seconds) ~= "number" or seconds ~= seconds or seconds == math.huge or seconds == -math.huge then
        return 0, 0, 0
    end
    local p = patterns[element] or fallback
    local s = type(seed) == "number" and seed == seed and math.abs(seed) < 1e9 and seed or 0
    local t = seconds * p.speed + s * 0.37
    return p.radius * math.sin(t), p.rise * math.sin(t * 1.3), p.radius * math.cos(t * 0.73)
end
function Flight.clampPosition(x, y, z, bounds)
    if type(bounds) ~= "table" then return x, y, z end
    local margin = 7
    return math.clamp(x, bounds.minX + margin, bounds.maxX - margin),
        math.clamp(y, 7, 15),
        math.clamp(z, bounds.minZ + margin, bounds.maxZ - margin)
end
return Flight
