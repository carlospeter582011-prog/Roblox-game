-- Pure server-authoritative time-trial state machine. No currency or client timestamps.
local Rules = {}
Rules.MAX_LEG_SPEED = 90 -- generous allowance for existing launch/traversal mechanics
Rules.MAX_RUN_SECONDS = 240
Rules.MIN_LEG_SECONDS = 0.5
Rules.CHECKPOINTS = {
    { id = "meadow", x = 0, z = -25 },
    { id = "eastwind", x = 170, z = 0 },
    { id = "ridge", x = 315, z = 0 },
}
local function validTime(t)
    return type(t) == "number" and t == t and t > -math.huge and t < math.huge
end
function Rules.advance(state, checkpoint, now)
    if not validTime(now) or type(checkpoint) ~= "number" or checkpoint % 1 ~= 0 then
        return nil, "invalid"
    end
    if checkpoint == 1 then
        return { next = 2, started = now, last = now, lastCheckpoint = 1 }, "started"
    end
    if type(state) ~= "table" or state.next ~= checkpoint or not validTime(state.last)
        or not validTime(state.started) or now < state.last then
        return nil, "out_of_order"
    end
    local elapsed = now - state.last
    local total = now - state.started
    if elapsed < Rules.MIN_LEG_SECONDS or total > Rules.MAX_RUN_SECONDS then
        return nil, "invalid_time"
    end
    local from = Rules.CHECKPOINTS[state.lastCheckpoint]
    local to = Rules.CHECKPOINTS[checkpoint]
    if not from or not to then return nil, "invalid_checkpoint" end
    local dx, dz = to.x - from.x, to.z - from.z
    if math.sqrt(dx * dx + dz * dz) / elapsed > Rules.MAX_LEG_SPEED then
        return nil, "too_fast"
    end
    if checkpoint == #Rules.CHECKPOINTS then
        return { finished = true, duration = total }, "finished"
    end
    return { next = checkpoint + 1, started = state.started, last = now, lastCheckpoint = checkpoint }, "progress"
end
return table.freeze(Rules)
