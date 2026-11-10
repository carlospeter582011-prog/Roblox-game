-- Original, deterministic elemental cloud flight patterns. Server-owned motion; no client coordinates.
-- Bounds are deliberately small so all cloud types remain catchable on the starter islands.
local Flight = {}
local patterns = {
    Air = {radius = 2.8, speed = 0.85, vertical = 0.8},
    Water = {radius = 1.5, speed = 0.55, vertical = 0.35},
    Storm = {radius = 2.2, speed = 1.3, vertical = 0.55},
    Fire = {radius = 1.8, speed = 1.1, vertical = 0.5},
    Ice = {radius = 0.7, speed = 0.4, vertical = 0.2},
    Nature = {radius = 1.1, speed = 0.5, vertical = 0.4},
    Earth = {radius = 0.5, speed = 0.3, vertical = 0.15},
    Light = {radius = 2, speed = 0.75, vertical = 0.7},
    Shadow = {radius = 2, speed = 0.65, vertical = 0.35},
    Cosmic = {radius = 2.5, speed = 0.6, vertical = 0.9},
}
local default = {radius = 1, speed = 0.5, vertical = 0.3}
function Flight.offset(element, elapsed, seed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed == math.huge or elapsed == -math.huge then
        return 0, 0, 0
    end
    if type(seed) ~= "number" or seed ~= seed or seed == math.huge or seed == -math.huge then seed = 0 end
    local p = patterns[element] or default
    local phase = elapsed * p.speed + seed % 100
    return math.sin(phase) * p.radius,
        math.sin(phase * 1.4) * p.vertical,
        math.cos(phase * 0.83) * p.radius
end
return Flight
