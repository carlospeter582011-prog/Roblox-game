-- Deterministic species-element flight patterns. No Roblox globals, no client authority.
-- Returns horizontal displacement (x,z) in studs relative to a fixed spawn anchor.
local Flight = {}
local patterns = {
    Air = { radius = 3.5, speed = 0.85, mode = "circle" },
    Water = { radius = 2.5, speed = 0.65, mode = "wave" },
    Storm = { radius = 4, speed = 1.3, mode = "figure8" },
    Nature = { radius = 1.7, speed = 0.5, mode = "circle" },
    Cosmic = { radius = 3, speed = 0.4, mode = "figure8" },
}
local fallback = { radius = 1.2, speed = 0.55, mode = "wave" }
function Flight.offset(element, elapsed, seed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or math.abs(elapsed) == math.huge then return 0, 0 end
    if type(seed) ~= "number" or seed ~= seed or math.abs(seed) == math.huge then return 0, 0 end
    local p = patterns[element] or fallback
    local angle = elapsed * p.speed + seed * 1.618
    if p.mode == "figure8" then
        return p.radius * math.sin(angle), p.radius * 0.5 * math.sin(2 * angle)
    elseif p.mode == "circle" then
        return p.radius * math.cos(angle), p.radius * math.sin(angle)
    end
    return p.radius * math.sin(angle), p.radius * 0.35 * math.sin(angle * 0.7)
end
return Flight
