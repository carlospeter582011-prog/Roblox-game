-- Pure, server-authoritative rules for checkpoint activation and safe fall recovery.
local Rules = {}
Rules.FALL_Y = -35
Rules.RECOVERY_COOLDOWN = 3
Rules.ACTIVATION_RADIUS = 15
Rules.CHECKPOINTS = table.freeze({
    meadow = table.freeze({ x = 0, y = 7, z = 0 }),
    eastwind = table.freeze({ x = 190, y = 7, z = 27 }),
    ridge = table.freeze({ x = 335, y = 7, z = 25 }),
})
function Rules.validCheckpoint(id)
    return type(id) == "string" and Rules.CHECKPOINTS[id] ~= nil
end
function Rules.canActivate(id, distance, alive)
    return Rules.validCheckpoint(id) and alive == true
        and type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= Rules.ACTIVATION_RADIUS
end
function Rules.shouldRescue(y, now, lastRecovery, alive)
    return alive == true and type(y) == "number" and y == y and y < Rules.FALL_Y
        and type(now) == "number" and now == now
        and now >= (lastRecovery or -math.huge) + Rules.RECOVERY_COOLDOWN
end
return table.freeze(Rules)
