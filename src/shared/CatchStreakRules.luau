-- Server-owned, session-only catch combos. No DataStore schema change.
local Rules = {}
Rules.WINDOW = 45
Rules.MILESTONES = {
    [3] = { coins = 15, xp = 10 },
    [7] = { coins = 45, xp = 25 },
    [12] = { coins = 100, xp = 60 },
}
function Rules.advance(previous, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge or now < 0 then
        return { count = 0, at = 0 }, 0, 0
    end
    local count = 0
    if type(previous) == "table" and type(previous.count) == "number"
        and previous.count == math.floor(previous.count) and previous.count >= 1
        and previous.count < 1000000 and type(previous.at) == "number"
        and previous.at == previous.at and previous.at >= 0 and previous.at <= now
        and now - previous.at <= Rules.WINDOW then
        count = previous.count
    end
    count += 1
    local reward = Rules.MILESTONES[count]
    return { count = count, at = now }, reward and reward.coins or 0, reward and reward.xp or 0
end
return Rules
