-- Pure server-side rules for the three-stage Sky Weather Shrine.
local Rules = {}
Rules.TIME_LIMIT = 45
Rules.COOLDOWN = 180
Rules.REWARD_COINS = 65
Rules.REWARD_XP = 35
Rules.STAGES = 3
function Rules.sequence(seed)
    if type(seed) ~= "number" or seed ~= seed or seed == math.huge or seed == -math.huge then return nil end
    local n = math.floor(math.abs(seed)) % 6
    local permutations = {
        {1,2,3}, {1,3,2}, {2,1,3}, {2,3,1}, {3,1,2}, {3,2,1}
    }
    return permutations[n+1]
end
function Rules.canStart(now, lastFinish)
    if type(now) ~= "number" or now ~= now or now == math.huge then return false end
    return lastFinish == nil or (type(lastFinish) == "number" and now >= lastFinish + Rules.COOLDOWN)
end
function Rules.advance(sequence, stage, chosen, started, now)
    if type(sequence) ~= "table" or type(stage) ~= "number" or stage % 1 ~= 0
        or stage < 1 or stage > Rules.STAGES or type(chosen) ~= "number"
        or chosen % 1 ~= 0 or chosen < 1 or chosen > 3
        or type(started) ~= "number" or type(now) ~= "number"
        or now ~= now or started ~= started or now < started or now - started > Rules.TIME_LIMIT then
        return false, "expired"
    end
    if sequence[stage] ~= chosen then return false, "wrong" end
    if stage == Rules.STAGES then return true, "complete" end
    return true, stage + 1
end
return Rules
