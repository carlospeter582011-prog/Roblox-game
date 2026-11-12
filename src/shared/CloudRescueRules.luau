-- Pure timed rescue rules: all progress is server-owned and session-only.
local Rules = {}
Rules.STAGES = 3
Rules.TIME_LIMIT = 65
Rules.COOLDOWN = 100
Rules.RANGE = 15
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.step(state, stage, now, distance, ready)
    if ready ~= true or not finite(now) or not finite(distance) or distance < 0 or distance > Rules.RANGE then
        return nil, "invalid"
    end
    if type(stage) ~= "number" or stage ~= math.floor(stage) or stage < 1 or stage > Rules.STAGES then
        return nil, "stage"
    end
    state = type(state) == "table" and state or {}
    local cooldownUntil = finite(state.cooldownUntil) and state.cooldownUntil or 0
    if now < cooldownUntil then return nil, "cooldown" end
    local current = type(state.stage) == "number" and state.stage or 0
    local started = finite(state.started) and state.started or now
    if current > 0 and (now < started or now - started > Rules.TIME_LIMIT) then
        current = 0
    end
    if stage ~= current + 1 then return nil, "order" end
    if stage == 1 then started = now end
    if stage == Rules.STAGES then
        return { stage = 0, started = 0, cooldownUntil = now + Rules.COOLDOWN }, "complete"
    end
    return { stage = stage, started = started, cooldownUntil = cooldownUntil }, "progress"
end
return table.freeze(Rules)
