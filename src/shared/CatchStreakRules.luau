-- Server-authoritative catch streak: consecutive successful catches within a short window.
-- Streaks are session-only; no extra DataStore writes and no client-supplied values.
local Rules = {}
Rules.WINDOW = 30
Rules.MAX_STREAK = 20
Rules.MAX_BONUS_XP = 12

local function finiteNonnegative(n)
    return type(n) == "number" and n == n and n >= 0 and n < math.huge
end

function Rules.advance(previousCount, previousTime, now)
    if not finiteNonnegative(now) then return 0 end
    local previous = finiteNonnegative(previousCount) and math.floor(previousCount) or 0
    if previous > Rules.MAX_STREAK then previous = Rules.MAX_STREAK end
    if not finiteNonnegative(previousTime) or now < previousTime
        or now - previousTime > Rules.WINDOW then
        return 1
    end
    return math.min(previous + 1, Rules.MAX_STREAK)
end

function Rules.bonusXp(streak)
    if not finiteNonnegative(streak) then return 0 end
    local count = math.min(math.floor(streak), Rules.MAX_STREAK)
    -- Every third consecutive catch earns +3 XP, up to +12 XP per catch.
    return math.min(math.floor(count / 3) * 3, Rules.MAX_BONUS_XP)
end

return Rules
