-- Pure, server-authoritative checkpoint race progression.
local Rules = {}
Rules.limitSeconds = 100
Rules.minSeconds = 8
Rules.cooldownSeconds = 120
Rules.checkpoints = 4
function Rules.advance(state, checkpoint, now)
    if type(state) ~= "table" or type(checkpoint) ~= "number" or checkpoint ~= math.floor(checkpoint)
        or type(now) ~= "number" or now ~= now or now == math.huge then return nil, "invalid" end
    if checkpoint ~= state.next then return nil, "order" end
    local elapsed = now - state.started
    if elapsed < 0 or elapsed > Rules.limitSeconds then return nil, "expired" end
    if checkpoint == Rules.checkpoints and elapsed < Rules.minSeconds then return nil, "too_fast" end
    if checkpoint == Rules.checkpoints then return { completed = true, elapsed = elapsed }, "finished" end
    return { started = state.started, next = checkpoint + 1 }, "advanced"
end
function Rules.reward(elapsed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < Rules.minSeconds or elapsed > Rules.limitSeconds then return nil end
    if elapsed <= 25 then return 140, 75 end
    if elapsed <= 50 then return 95, 55 end
    return 65, 40
end
return Rules
