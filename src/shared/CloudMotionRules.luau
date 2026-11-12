-- Pure, deterministic motion for living cloud species. Server owns positions.
-- Anchors never change: each cloud stays within its discovery region.
local Motion = {}
local patterns = {
    Air = { radius = 5, speed = 0.7, lift = 0.8 },
    Water = { radius = 2.5, speed = 0.35, lift = 0.5 },
    Storm = { radius = 6, speed = 1.15, lift = 1.0 },
    Fire = { radius = 3.5, speed = 0.9, lift = 0.6 },
    Ice = { radius = 1.8, speed = 0.25, lift = 0.4 },
    Nature = { radius = 2.4, speed = 0.45, lift = 0.6 },
    Light = { radius = 4, speed = 0.65, lift = 0.8 },
    Shadow = { radius = 3.2, speed = 0.5, lift = 0.6 },
    Earth = { radius = 1.5, speed = 0.2, lift = 0.35 },
    Cosmic = { radius = 4.5, speed = 0.8, lift = 1.1 },
}
function Motion.offset(element, elapsed, seed)
    local p = patterns[element] or patterns.Air
    if type(elapsed) ~= "number" or elapsed ~= elapsed or math.abs(elapsed) == math.huge then
        elapsed = 0
    end
    if type(seed) ~= "number" or seed ~= seed or math.abs(seed) == math.huge then
        seed = 0
    end
    local angle = elapsed * p.speed + seed * 2.399963
    return math.cos(angle) * p.radius, math.sin(elapsed * p.speed * 1.4 + seed) * p.lift,
        math.sin(angle) * p.radius
end
return table.freeze(Motion)
