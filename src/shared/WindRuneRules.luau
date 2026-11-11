-- Pure server-side rules for the repeatable Wind Rune challenge.
local Rules = {}
Rules.ORDER = { "air", "rain", "storm" }
Rules.MAX_DISTANCE = 13
Rules.MIN_STEP_SECONDS = 0.45
Rules.TIME_LIMIT = 35
Rules.COOLDOWN = 90
Rules.BOOST_SECONDS = 20
Rules.BOOST_SPEED = 23
function Rules.step(state, rune, now, distance, alive, ready)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge
        or type(distance) ~= "number" or distance ~= distance or distance < 0
        or distance > Rules.MAX_DISTANCE or not alive or not ready then
        return state, "invalid"
    end
    state = state or { index = 0, started = 0, last = -1000, cooldownUntil = 0 }
    if now < (state.cooldownUntil or 0) then return state, "cooldown" end
    if now - (state.last or -1000) < Rules.MIN_STEP_SECONDS then return state, "too_fast" end
    local index = state.index or 0
    if index > 0 and now - (state.started or 0) > Rules.TIME_LIMIT then index = 0 end
    if rune ~= Rules.ORDER[index + 1] then
        return { index = 0, started = 0, last = now, cooldownUntil = state.cooldownUntil or 0 }, "reset"
    end
    if index + 1 == #Rules.ORDER then
        return { index = 0, started = 0, last = now, cooldownUntil = now + Rules.COOLDOWN }, "complete"
    end
    return { index = index + 1, started = index == 0 and now or state.started,
        last = now, cooldownUntil = state.cooldownUntil or 0 }, "progress"
end
return Rules
