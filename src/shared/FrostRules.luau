-- Pure validation for Frost Spires attunement beacons. No Roblox globals.
local Rules = {}

Rules.MAX_DISTANCE = 14
Rules.COOLDOWN_SECONDS = 40
Rules.SPEED_BONUS = 6
Rules.SPEED_DURATION = 20

-- Returns true only for a healthy, ready player within range and outside cooldown.
function Rules.canAttune(distance, profileReady, lastTime, now)
    if profileReady ~= true then return false end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE or distance == math.huge then
        return false
    end
    if type(now) ~= "number" or now ~= now then return false end
    if type(lastTime) == "number" and lastTime == lastTime and now - lastTime < Rules.COOLDOWN_SECONDS then
        return false
    end
    return true
end

return Rules
