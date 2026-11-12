-- Deterministic, bounded cloud flight paths. Pure Luau for CI and server reuse.
local Flight = {}
local TAU = math.pi * 2
function Flight.parameters(species)
    local element = species and species.element or "Air"
    local speed = ({ Air = 1.3, Storm = 1.7, Fire = 1.1, Water = 0.7, Ice = 0.45, Earth = 0.35, Nature = 0.6, Light = 0.9, Shadow = 0.8, Cosmic = 1.0 })[element] or 0.6
    return { radius = 1.2 + speed * 1.5, speed = speed, lift = 0.35 + speed * 0.2 }
end
function Flight.offset(species, elapsed, seed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed == math.huge or elapsed == -math.huge then elapsed = 0 end
    if type(seed) ~= "number" or seed ~= seed then seed = 0 end
    elapsed = math.clamp(elapsed, 0, 100000)
    seed = seed % 10000
    local p = Flight.parameters(species)
    local theta = elapsed * p.speed * 0.35 + seed * 0.618
    return math.cos(theta) * p.radius, math.sin(elapsed * p.speed * 0.55 + seed) * p.lift, math.sin(theta) * p.radius
end
return table.freeze(Flight)
