-- Pure, deterministic rules for the three-region Sky Survey Relay.
local Rules = {}
Rules.STATIONS = { "meadow", "eastwind", "ridge" }
Rules.TIME_LIMIT = 180
Rules.COOLDOWN = 300
Rules.MAX_DISTANCE = 14
Rules.REWARD_COINS = 180
Rules.REWARD_XP = 100

local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

function Rules.cooldownActive(previous, now)
    return type(previous) == "table" and finite(previous.expires)
        and finite(now) and previous.expires > now
end

function Rules.check(stage, station, distance, elapsed, cooldownLeft)
    if type(stage) ~= "number" or stage ~= math.floor(stage) or stage < 1 or stage > 3 then return false, "stage" end
    if Rules.STATIONS[stage] ~= station then return false, "order" end
    if not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then return false, "distance" end
    if not finite(elapsed) or elapsed < 0 or elapsed > Rules.TIME_LIMIT then return false, "timeout" end
    if not finite(cooldownLeft) or cooldownLeft > 0 then return false, "cooldown" end
    return true, stage == 3 and "complete" or "advance"
end

return Rules
