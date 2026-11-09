-- Pure XP -> level curve. Total XP required to reach level L is 25 * (L - 1) * L:
-- level 2 at 50 XP, level 3 at 150, level 4 at 300, ... capped at MAX_LEVEL.
local Leveling = {}

Leveling.MAX_LEVEL = 100

-- Total XP needed to reach `level` (clamped to 1..MAX_LEVEL).
function Leveling.xpForLevel(level)
    local clamped = math.clamp(math.floor(level), 1, Leveling.MAX_LEVEL)
    return 25 * (clamped - 1) * clamped
end

-- Level for a total XP amount. Invalid input (non-number, NaN, negative) is level 1.
function Leveling.levelForXp(xp)
    if type(xp) ~= "number" or xp ~= xp or xp < 0 then
        return 1
    end
    local level = math.clamp(math.floor((1 + math.sqrt(1 + 4 * xp / 25)) / 2), 1, Leveling.MAX_LEVEL)
    -- Correct any floating-point drift from the closed-form estimate.
    while level < Leveling.MAX_LEVEL and xp >= Leveling.xpForLevel(level + 1) do
        level += 1
    end
    while level > 1 and xp < Leveling.xpForLevel(level) do
        level -= 1
    end
    return level
end

-- Returns (level, xpIntoLevel, xpNeededForNext). At MAX_LEVEL both amounts are 0.
function Leveling.progress(xp)
    local level = Leveling.levelForXp(xp)
    if level >= Leveling.MAX_LEVEL then
        return level, 0, 0
    end
    local base = Leveling.xpForLevel(level)
    return level, xp - base, Leveling.xpForLevel(level + 1) - base
end

return Leveling
