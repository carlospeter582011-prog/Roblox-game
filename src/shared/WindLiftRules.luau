-- Pure server-side wind lift validation. Never trust client-supplied velocities.
local Rules = {}
Rules.COOLDOWN = 4
Rules.MAX_DISTANCE = 11
function Rules.canLaunch(distance, elapsed, alive, ready)
    return type(distance) == "number" and distance == distance and distance >= 0
        and distance <= Rules.MAX_DISTANCE
        and type(elapsed) == "number" and elapsed == elapsed and elapsed >= Rules.COOLDOWN
        and alive == true and ready == true
end
function Rules.velocity(direction)
    if direction ~= "east" and direction ~= "west" then return nil end
    local horizontal = direction == "east" and 28 or -28
    return horizontal, 66, 0
end
return Rules
