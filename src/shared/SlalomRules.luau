-- Pure, server-owned timed slalom rules. No Roblox dependencies.
local Rules = {}
Rules.GATE_COUNT = 4
Rules.LIMIT_SECONDS = 95
Rules.MAX_DISTANCE = 15
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.advance(state, gate, distance, now)
    if not finite(now) or now < 0 or not finite(distance) or distance < 0
        or distance > Rules.MAX_DISTANCE or type(gate) ~= "number"
        or gate ~= math.floor(gate) or gate < 1 or gate > Rules.GATE_COUNT then
        return nil, "invalid"
    end
    if gate == 1 then
        if state and finite(state.started) and now - state.started < Rules.LIMIT_SECONDS then
            return nil, "already_running"
        end
        return { started = now, nextGate = 2 }, "started"
    end
    if type(state) ~= "table" or not finite(state.started)
        or not finite(state.nextGate) or state.nextGate ~= gate
        or now < state.started or now - state.started > Rules.LIMIT_SECONDS then
        return nil, "out_of_order_or_expired"
    end
    if gate == Rules.GATE_COUNT then
        return { started = state.started, nextGate = Rules.GATE_COUNT + 1,
            finished = now - state.started }, "finished"
    end
    return { started = state.started, nextGate = gate + 1 }, "checkpoint"
end
return Rules
