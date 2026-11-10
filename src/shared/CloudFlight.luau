-- Deterministic bounded flight paths for catchable clouds. Pure Luau, no Roblox services.
local Flight = {}
function Flight.offset(seconds, seed, amplitude)
    if type(seconds) ~= "number" or seconds ~= seconds or math.abs(seconds) == math.huge then return 0, 0 end
    if type(seed) ~= "number" or seed ~= seed or math.abs(seed) == math.huge then return 0, 0 end
    local a = math.clamp(type(amplitude) == "number" and amplitude or 0, 0, 4)
    return math.sin(seconds * 0.42 + seed * 1.7) * a,
        math.sin(seconds * 0.31 + seed * 2.3) * a
end
function Flight.position(x, z, region, seconds, seed)
    local dx, dz = Flight.offset(seconds, seed, 3)
    return math.clamp(x + dx, region.minX + 2, region.maxX - 2),
        math.clamp(z + dz, region.minZ + 2, region.maxZ - 2)
end
return Flight
