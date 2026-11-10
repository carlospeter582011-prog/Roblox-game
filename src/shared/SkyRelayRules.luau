-- Pure server-side rules for the three-region signal relay exploration puzzle.
local Rules = {}
Rules.STEP_LIMIT = 90
Rules.REPLAY_COOLDOWN = 150
Rules.MAX_DISTANCE = 13
Rules.ORDER = { "meadow", "eastwind", "ridge" }
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.advance(state, station, now, distance, alive, ready)
    if not ready or not alive or not finite(now) or not finite(distance) or distance < 0 or distance > Rules.MAX_DISTANCE then
        return false, state, "Unavailable"
    end
    state = state or { step = 1, started = 0, nextAt = 0 }
    if not finite(state.nextAt) or not finite(state.started) or type(state.step) ~= "number" then
        return false, { step = 1, started = 0, nextAt = 0 }, "Reset"
    end
    if now < state.nextAt then return false, state, "Relay recharging" end
    local step = state.step
    if step < 1 or step > #Rules.ORDER or (step > 1 and now - state.started > Rules.STEP_LIMIT) then
        step = 1
    end
    if station ~= Rules.ORDER[step] then
        return false, { step = step, started = step == 1 and 0 or state.started, nextAt = state.nextAt }, "Find the next signal"
    end
    if step == #Rules.ORDER then
        return true, { step = 1, started = 0, nextAt = now + Rules.REPLAY_COOLDOWN }, "complete"
    end
    return true, { step = step + 1, started = step == 1 and now or state.started, nextAt = state.nextAt }, "progress"
end
return Rules
