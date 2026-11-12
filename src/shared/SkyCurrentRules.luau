-- Pure rules for the repeatable Sky Current routing puzzle.
local Rules = {}
Rules.ORDER = { "north", "east", "west" }
Rules.TIME_LIMIT = 70
Rules.COOLDOWN = 150
Rules.REWARD_COINS = 110
Rules.REWARD_XP = 65
function Rules.advance(step, valve, elapsed)
    if type(step) ~= "number" or step ~= math.floor(step) or step < 0 or step > #Rules.ORDER then return 0, false end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0 or elapsed > Rules.TIME_LIMIT then return 0, false end
    if type(valve) ~= "string" then return 0, false end
    if valve ~= Rules.ORDER[step + 1] then return 0, false end
    local nextStep = step + 1
    return nextStep, nextStep == #Rules.ORDER
end
function Rules.eligible(distance, ready, health, now, last)
    if ready ~= true or type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > 14 then return false end
    if type(health) ~= "number" or health ~= health or health <= 0 then return false end
    if type(now) ~= "number" or now ~= now or type(last) ~= "number" or last ~= last then return false end
    return now - last >= Rules.COOLDOWN
end
return table.freeze(Rules)
