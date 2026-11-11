-- Server-only session catch combo. A streak rewards active skill without permanent inflation.
-- Call advance ONLY after a server-validated successful catch; never trust client clocks.
local Combo = {}
Combo.WINDOW = 25
Combo.MAX_STREAK = 6
function Combo.preview(previous, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then
        return nil
    end
    local streak = 1
    if type(previous) == "table" and type(previous.time) == "number"
        and previous.time == previous.time and now >= previous.time
        and now - previous.time <= Combo.WINDOW
        and type(previous.streak) == "number" and previous.streak >= 1
        and previous.streak < math.huge and previous.streak == math.floor(previous.streak) then
        streak = math.min(previous.streak + 1, Combo.MAX_STREAK)
    end
    -- Up to +5 XP per catch, no coin bonus and no save-schema change.
    return { time = now, streak = streak, bonusXP = streak - 1 }
end
return Combo
