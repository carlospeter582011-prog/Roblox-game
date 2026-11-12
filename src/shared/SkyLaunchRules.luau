-- Pure server-side sky launch eligibility and trajectory validation.
local Rules = {}
Rules.COOLDOWN = 12
Rules.MAX_DISTANCE = 15
Rules.SPEED = 80
Rules.LIFT = 55
function Rules.canLaunch(distance, elapsed, ready, alive)
    return type(distance) == "number" and distance == distance and distance >= 0
        and distance <= Rules.MAX_DISTANCE
        and type(elapsed) == "number" and elapsed == elapsed and elapsed >= Rules.COOLDOWN
        and ready == true and alive == true
end
function Rules.velocity(fromX, fromZ, toX, toZ)
    local dx, dz = toX - fromX, toZ - fromZ
    local length = math.sqrt(dx * dx + dz * dz)
    if length < 1 or length ~= length or length == math.huge then return nil end
    return dx / length * Rules.SPEED, Rules.LIFT, dz / length * Rules.SPEED
end
return Rules
