-- Deterministic, bounded server-authoritative cloud movement; pure Luau.
-- Different elements demand different chasing strategies without client-controlled coordinates.
local Motion = {}
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Motion.parameters(element)
    if element == "Air" then return 5, 0.65 end
    if element == "Storm" then return 4, 1.1 end
    if element == "Cosmic" then return 3, 0.45 end
    if element == "Water" then return 2.5, 0.4 end
    if element == "Fire" then return 3.5, 0.85 end
    return 1.5, 0.3
end
function Motion.offset(element, elapsed, phase)
    if not finite(elapsed) or not finite(phase) then return 0, 0, 0 end
    local radius, speed = Motion.parameters(element)
    local t = math.max(0, math.min(elapsed, 100000)) * speed + phase
    return math.cos(t) * radius, math.sin(t * 0.7) * 0.65, math.sin(t) * radius
end
return table.freeze(Motion)
