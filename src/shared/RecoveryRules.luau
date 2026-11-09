-- Pure sky-world recovery policy; no Roblox runtime dependencies.
local RecoveryRules = {}
RecoveryRules.FALL_Y = -85
RecoveryRules.MAX_HORIZONTAL_DISTANCE = 210
RecoveryRules.EMERGENCY_FALL_Y = -500
RecoveryRules.COOLDOWN_SECONDS = 3

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function RecoveryRules.shouldRecover(y, horizontalDistance, now, lastRecovery)
    if not finite(y) or not finite(horizontalDistance) or not finite(now) then return false end
    if horizontalDistance < 0 then return false end
    if y >= RecoveryRules.FALL_Y then return false end
    -- Near the starter island, recover promptly. Deep in the void, rescue
    -- even players who have drifted beyond its radius; future worlds should
    -- provide their own checkpoints before enabling remote travel.
    if horizontalDistance > RecoveryRules.MAX_HORIZONTAL_DISTANCE and y > RecoveryRules.EMERGENCY_FALL_Y then
        return false
    end
    if lastRecovery ~= nil then
        if not finite(lastRecovery) then return false end
        if now < lastRecovery or now - lastRecovery < RecoveryRules.COOLDOWN_SECONDS then return false end
    end
    return true
end

-- Resolve the actual configured SpawnLocation instead of teleporting to a
-- hardcoded center point (which can overlap catching props as maps evolve).
-- Inputs and outputs are plain coordinates so the policy is testable in CI.
function RecoveryRules.recoveryPosition(x, y, z, spawnHeight)
    if not finite(x) or not finite(y) or not finite(z) then return nil end
    if not finite(spawnHeight) or spawnHeight < 0 or spawnHeight > 30 then return nil end
    return x, y + spawnHeight, z
end

return RecoveryRules
