-- Pure deterministic sky-navigation puzzle logic. No Roblox globals.
local Rules = {}
Rules.SEQUENCE = { "north", "east", "south", "west" }
Rules.TIME_LIMIT = 45
Rules.COOLDOWN = 120
Rules.REWARD_COINS = 125
Rules.REWARD_XP = 80
function Rules.step(progress, direction, elapsed)
    if type(direction) ~= "string" or type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0 or elapsed > Rules.TIME_LIMIT then
        return 0, false, "expired_or_invalid"
    end
    if type(progress) ~= "number" or progress < 0 or progress > #Rules.SEQUENCE or progress ~= math.floor(progress) then
        return 0, false, "invalid_progress"
    end
    if progress == #Rules.SEQUENCE then return progress, false, "completed" end
    if direction ~= Rules.SEQUENCE[progress + 1] then return 0, false, "wrong_direction" end
    local nextProgress = progress + 1
    return nextProgress, nextProgress == #Rules.SEQUENCE, "correct"
end
return table.freeze(Rules)
