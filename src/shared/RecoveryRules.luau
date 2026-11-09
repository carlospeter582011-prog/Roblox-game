-- Pure recovery policy for the starter sky island. No Roblox runtime dependencies.
local RecoveryRules = {}
RecoveryRules.FALL_Y = -85
RecoveryRules.MAX_HORIZONTAL_DISTANCE = 210
RecoveryRules.COOLDOWN_SECONDS = 3

function RecoveryRules.shouldRecover(y, horizontalDistance, now, lastRecovery)
    if type(y) ~= "number" or y ~= y or type(horizontalDistance) ~= "number" or horizontalDistance ~= horizontalDistance then
        return false
    end
    if type(now) ~= "number" or now ~= now then return false end
    if y >= RecoveryRules.FALL_Y or horizontalDistance > RecoveryRules.MAX_HORIZONTAL_DISTANCE then return false end
    if type(lastRecovery) == "number" and now - lastRecovery < RecoveryRules.COOLDOWN_SECONDS then return false end
    return true
end

return RecoveryRules
