-- Pure validation for reusable 3D updraft launch pads. Server owns positions and impulse.
local Rules = {}
Rules.COOLDOWN = 8
Rules.MAX_DISTANCE = 13
Rules.HORIZONTAL_SPEED = 45
Rules.VERTICAL_SPEED = 65
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.canLaunch(distance, elapsed, alive, hasProfile)
    return finite(distance) and distance >= 0 and distance <= Rules.MAX_DISTANCE
        and finite(elapsed) and elapsed >= Rules.COOLDOWN
        and alive == true and hasProfile == true
end
-- Fixed, bounded server-defined launch vector; never use client-provided velocity.
function Rules.velocity(dx, dz)
    if not finite(dx) or not finite(dz) then return nil end
    local length = math.sqrt(dx * dx + dz * dz)
    if length < 0.01 or length == math.huge then return nil end
    return dx / length * Rules.HORIZONTAL_SPEED, Rules.VERTICAL_SPEED,
        dz / length * Rules.HORIZONTAL_SPEED
end
return Rules
