-- Original resource-loop rules, pure Luau for CI tests.
local Rules = {}
Rules.COOLDOWN = 75
Rules.MAX_SESSION_CLAIMS = 12
Rules.DISTANCE = 14
Rules.REWARDS = {
    breeze = { coins = 22, xp = 12, required = 0 },
    storm = { coins = 65, xp = 32, required = 15 },
    cosmic = { coins = 130, xp = 65, required = 50 },
}
function Rules.canClaim(kind, captures, distance, now, lastClaim, claims)
    local reward = Rules.REWARDS[kind]
    if not reward then return false, "unknown" end
    if type(captures) ~= "number" or captures ~= captures or captures < reward.required then return false, "locked" end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.DISTANCE then return false, "distance" end
    if type(now) ~= "number" or now ~= now or now == math.huge then return false, "clock" end
    if type(claims) ~= "number" or claims < 0 or claims >= Rules.MAX_SESSION_CLAIMS then return false, "limit" end
    if lastClaim and now - lastClaim < Rules.COOLDOWN then return false, "cooldown" end
    return true, reward
end
return table.freeze(Rules)
