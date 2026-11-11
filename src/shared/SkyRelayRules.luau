-- Pure, server-owned checkpoint race rules. No player-provided timing or checkpoint ids.
local Rules = {}
Rules.CHECKPOINTS = 3
Rules.MIN_SECONDS = 8
Rules.MAX_SECONDS = 180
Rules.RESTART_COOLDOWN = 5
function Rules.advance(state, checkpoint, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return nil, "clock" end
    if type(checkpoint) ~= "number" or checkpoint % 1 ~= 0 or checkpoint < 1 or checkpoint > Rules.CHECKPOINTS then return nil, "checkpoint" end
    if checkpoint == 1 then
        if state and now - (state.started or now) < Rules.RESTART_COOLDOWN then return nil, "cooldown" end
        return { started = now, next = 2 }, "started"
    end
    if not state or state.next ~= checkpoint then return nil, "order" end
    local elapsed = now - state.started
    if elapsed < 0 or elapsed > Rules.MAX_SECONDS then return nil, "expired" end
    if checkpoint == Rules.CHECKPOINTS then
        if elapsed < Rules.MIN_SECONDS then return nil, "too_fast" end
        return { started = state.started, next = 0, finished = elapsed }, "finished"
    end
    return { started = state.started, next = checkpoint + 1 }, "progress"
end
return Rules
