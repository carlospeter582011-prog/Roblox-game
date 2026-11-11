-- Pure server-side checkpoint validation. Checkpoints last for the current server session.
local Rules = {}
Rules.MAX_DISTANCE = 13
Rules.MIN_ACTIVATION_INTERVAL = 2
Rules.PADS = {
    meadow = { x = -35, y = 2, z = -35 },
    eastwind = { x = 170, y = 2, z = -28 },
    ridge = { x = 315, y = 2, z = -28 },
}
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
function Rules.canActivate(id, distance, ready, alive, now, lastActivation)
    if Rules.PADS[id] == nil or not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE
        or ready ~= true or alive ~= true or not finite(now) or now < 0 then
        return false
    end
    if lastActivation ~= nil then
        if not finite(lastActivation) or lastActivation < 0 or now - lastActivation < Rules.MIN_ACTIVATION_INTERVAL then
            return false
        end
    end
    return true
end
function Rules.respawn(id)
    local pad = Rules.PADS[id]
    if not pad then return nil end
    return pad.x, pad.y + 5, pad.z
end
return Rules
