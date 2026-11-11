-- Deterministic, bounded 3D cloud flight. Pure Luau; no Roblox services.
-- Species elements change movement patterns, making cloud-catching a positioning challenge.
local Flight = {}
local styles = {
    Air = { radius = 8, speed = 0.85, lift = 1.6 },
    Storm = { radius = 11, speed = 1.25, lift = 1.1 },
    Water = { radius = 5, speed = 0.48, lift = 0.7 },
    Ice = { radius = 3, speed = 0.34, lift = 0.5 },
    Fire = { radius = 7, speed = 1.05, lift = 1.0 },
    Earth = { radius = 2, speed = 0.28, lift = 0.4 },
    Nature = { radius = 4, speed = 0.46, lift = 0.9 },
    Light = { radius = 6, speed = 0.7, lift = 1.2 },
    Shadow = { radius = 7, speed = 0.62, lift = 0.8 },
    Cosmic = { radius = 9, speed = 0.8, lift = 1.5 },
}
function Flight.offset(element, seed, elapsed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0 or elapsed == math.huge then
        return 0, 0, 0
    end
    local style = styles[element] or styles.Air
    local phase = (type(seed) == "number" and seed % 1000 or 0) * 2.399963
    local t = math.min(elapsed, 1e8) * style.speed
    return math.cos(t + phase) * style.radius,
        math.sin(t * 1.4 + phase) * style.lift,
        math.sin(t * 0.8 + phase) * style.radius
end
return table.freeze(Flight)
