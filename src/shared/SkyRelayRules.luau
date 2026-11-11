-- Pure server-side rules for the three-beacon Sky Relay exploration challenge.
local Relay = {}
Relay.ORDER = { "meadow", "outlook", "ridge" }
Relay.TIME_LIMIT = 180
Relay.REPLAY_COOLDOWN = 600
Relay.REWARD_COINS = 90
Relay.REWARD_XP = 45

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

function Relay.advance(stage, beacon, elapsed, distance)
    if not finite(stage) or stage % 1 ~= 0 or stage < 0 or stage >= #Relay.ORDER then
        return nil, "invalid_stage"
    end
    if not finite(elapsed) or elapsed < 0 or elapsed > Relay.TIME_LIMIT then
        return nil, "expired"
    end
    if not finite(distance) or distance < 0 or distance > 14 then
        return nil, "too_far"
    end
    if beacon ~= Relay.ORDER[stage + 1] then
        return nil, "wrong_order"
    end
    return stage + 1, nil
end

function Relay.canStart(now, lastFinish)
    if not finite(now) or now < 0 then return false end
    if lastFinish == nil then return true end
    return finite(lastFinish) and lastFinish >= 0 and now >= lastFinish + Relay.REPLAY_COOLDOWN
end

return Relay
