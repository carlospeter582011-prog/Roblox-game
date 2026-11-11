-- Pure, deterministic constellation navigation challenge rules.
local Rules = {}
Rules.COUNT = 4
Rules.TIME_LIMIT = 65
Rules.COOLDOWN = 240
Rules.REWARD_COINS = 120
Rules.REWARD_XP = 70
function Rules.order(seed)
    if type(seed) ~= "number" or seed ~= seed or seed == math.huge then return nil end
    local remaining = {1, 2, 3, 4}
    local result = {}
    local value = math.floor(math.abs(seed))
    for i = 4, 1, -1 do
        local index = (value % i) + 1
        result[#result + 1] = table.remove(remaining, index)
        value = math.floor(value / i)
    end
    return result
end
function Rules.step(sequence, progress, selected, elapsed)
    if type(sequence) ~= "table" or #sequence ~= Rules.COUNT then return 0, false, "invalid" end
    if type(progress) ~= "number" or progress < 0 or progress >= Rules.COUNT then return 0, false, "invalid" end
    if type(selected) ~= "number" or selected % 1 ~= 0 or selected < 1 or selected > Rules.COUNT then return progress, false, "invalid" end
    if type(elapsed) ~= "number" or elapsed < 0 or elapsed > Rules.TIME_LIMIT then return 0, false, "expired" end
    if selected ~= sequence[progress + 1] then return 0, false, "reset" end
    local nextProgress = progress + 1
    return nextProgress, nextProgress == Rules.COUNT, "correct"
end
function Rules.ready(now, lastAward)
    return type(now) == "number" and now == now and (lastAward == nil or now - lastAward >= Rules.COOLDOWN)
end
return Rules
