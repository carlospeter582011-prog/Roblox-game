-- Pure server-side sky rescue decisions. No client-controlled teleport destinations.
local Rules = {}
Rules.CHECKPOINTS = {
    meadow = { x = 0, y = 5, z = -25 },
    eastwind = { x = 170, y = 5, z = 0 },
    ridge = { x = 315, y = 5, z = 0 },
}
Rules.TOUCH_RADIUS = 12
Rules.FALL_Y = -45
Rules.COOLDOWN = 5

local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

function Rules.canActivate(id, distance, ready, alive)
    return Rules.CHECKPOINTS[id] ~= nil and finite(distance)
        and distance >= 0 and distance <= Rules.TOUCH_RADIUS
        and ready == true and alive == true
end

function Rules.shouldRescue(y, now, lastRescue, ready, alive)
    return finite(y) and y < Rules.FALL_Y and finite(now)
        and finite(lastRescue) and now >= lastRescue
        and now - lastRescue >= Rules.COOLDOWN
        and ready == true and alive == true
end

function Rules.destination(id)
    return Rules.CHECKPOINTS[id] or Rules.CHECKPOINTS.meadow
end

return table.freeze(Rules)
