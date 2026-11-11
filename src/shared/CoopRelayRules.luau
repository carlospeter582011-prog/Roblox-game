-- Pure, server-side rules for a two-player cooperative sky relay.
local Rules = {}
Rules.WINDOW = 12
Rules.COOLDOWN = 180
Rules.MAX_DISTANCE = 14
Rules.COINS = 110
Rules.XP = 65

local function validTime(t)
    return type(t) == "number" and t == t and t > -math.huge and t < math.huge and t >= 0
end

function Rules.canActivate(distance, ready, alive)
    return type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= Rules.MAX_DISTANCE
        and ready == true and alive == true
end

function Rules.canPair(first, second, now, lastReward)
    if type(first) ~= "table" or type(second) ~= "table" or not validTime(now) then return false end
    if not first.userId or not second.userId or first.userId == second.userId then return false end
    if first.station ~= 1 or second.station ~= 2 then return false end
    if not validTime(first.at) or not validTime(second.at) then return false end
    if first.at > now or second.at > now or now - first.at > Rules.WINDOW or now - second.at > Rules.WINDOW then return false end
    if type(lastReward) ~= "table" then return false end
    for _, userId in ipairs({first.userId, second.userId}) do
        local last = lastReward[userId]
        if last ~= nil and (not validTime(last) or now - last < Rules.COOLDOWN) then return false end
    end
    return true
end

return Rules
