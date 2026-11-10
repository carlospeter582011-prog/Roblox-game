-- Server-only session streaks. No wall-clock rewards while offline; no client-provided times.
local Rules = {}
Rules.WINDOW = 75
Rules.MAX_STREAK = 20
function Rules.advance(previous, lastAt, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then
        return 0, 0
    end
    local valid = type(previous) == "number" and previous >= 1 and previous <= Rules.MAX_STREAK
        and previous == math.floor(previous) and type(lastAt) == "number"
        and lastAt == lastAt and now >= lastAt and now - lastAt <= Rules.WINDOW
    local streak = valid and math.min(previous + 1, Rules.MAX_STREAK) or 1
    -- Every fifth successful catch pays a capped, deterministic bonus.
    local bonus = streak % 5 == 0 and 10 * math.floor(streak / 5) or 0
    return streak, bonus
end
return Rules
