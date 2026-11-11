-- Pure server-owned cooperative sequence puzzle. No client-supplied step or reward.
local Rules = {}
Rules.SEQUENCE = {2, 1, 3, 2}
Rules.STEP_TIMEOUT = 18
Rules.OPEN_SECONDS = 45
Rules.FAIL_COOLDOWN = 3
function Rules.advance(state, chime, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge or now < 0 then return nil, "invalid_time" end
    if type(chime) ~= "number" or chime % 1 ~= 0 or chime < 1 or chime > 3 then return nil, "invalid_chime" end
    local s = state or {step = 1, deadline = 0, openUntil = 0, cooldownUntil = 0}
    if now < (s.cooldownUntil or 0) then return s, "cooldown" end
    if now < (s.openUntil or 0) then return s, "open" end
    local step = s.step or 1
    if now > (s.deadline or 0) then step = 1 end
    if chime ~= Rules.SEQUENCE[step] then
        return {step = 1, deadline = 0, openUntil = 0, cooldownUntil = now + Rules.FAIL_COOLDOWN}, "reset"
    end
    if step == #Rules.SEQUENCE then
        return {step = 1, deadline = 0, openUntil = now + Rules.OPEN_SECONDS, cooldownUntil = 0}, "solved"
    end
    return {step = step + 1, deadline = now + Rules.STEP_TIMEOUT, openUntil = 0, cooldownUntil = 0}, "progress"
end
function Rules.isOpen(state, now)
    return type(state) == "table" and type(now) == "number" and now < (state.openUntil or 0)
end
return Rules
