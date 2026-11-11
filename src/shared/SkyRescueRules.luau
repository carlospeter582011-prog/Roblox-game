-- Pure, deterministic safety rules for server-owned sky checkpoints.
local Rules = {}
Rules.FALL_Y = -45
Rules.RECOVERY_COOLDOWN = 3
Rules.CHECKPOINTS = {
    meadow = { x = 0, y = 6, z = -25, radius = 80 },
    eastwind = { x = 170, y = 6, z = 0, radius = 38 },
    ridge = { x = 315, y = 6, z = 0, radius = 40 },
}
function Rules.canActivate(id, distance, alive)
    return type(id) == "string" and Rules.CHECKPOINTS[id] ~= nil
        and type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= 12 and alive == true
end
function Rules.shouldRescue(y, now, lastRescue, alive)
    return alive == true and type(y) == "number" and y == y
        and y < Rules.FALL_Y and type(now) == "number" and now == now
        and (type(lastRescue) ~= "number" or now - lastRescue >= Rules.RECOVERY_COOLDOWN)
end
function Rules.safeCheckpoint(id)
    return Rules.CHECKPOINTS[id] or Rules.CHECKPOINTS.meadow
end
return table.freeze(Rules)
