-- Pure rules for cooperative storm shelter events. No Roblox globals.
local Rules = {}
Rules.WAVE_SECONDS = 12
Rules.WAVES = 3
Rules.RADIUS = 15
Rules.COOLDOWN = 90
Rules.REWARD_COINS = 90
Rules.REWARD_XP = 65
function Rules.validDistance(distance, radius)
    return type(distance) == "number" and distance == distance and distance >= 0
        and distance < math.huge and distance <= (radius or Rules.RADIUS)
end
function Rules.canJoin(ready, alive, distance, now, lastJoin)
    if ready ~= true or alive ~= true or not Rules.validDistance(distance, 12) then return false end
    if type(now) ~= "number" or now ~= now or now == math.huge then return false end
    return type(lastJoin) ~= "number" or now - lastJoin >= Rules.COOLDOWN
end
function Rules.canReward(profile, survived, alreadyPaid)
    if not profile or survived ~= Rules.WAVES or alreadyPaid then return false end
    return type(profile.coins) == "number" and profile.coins >= 0
        and profile.coins + Rules.REWARD_COINS <= 1000000000
        and type(profile.xp) == "number" and profile.xp >= 0
        and profile.xp + Rules.REWARD_XP <= 1000000000
end
return Rules
