-- Pure rules for a three-signal cooperative storm shelter challenge.
local Rules = {}
Rules.WINDOW = 25
Rules.COOLDOWN = 90
Rules.SHIELD_SECONDS = 20
Rules.SWITCHES = 3
function Rules.activate(state, switchId, now)
    if type(switchId) ~= "number" or switchId % 1 ~= 0 or switchId < 1 or switchId > Rules.SWITCHES then
        return false, "invalid", state
    end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge or now < 0 then
        return false, "invalid", state
    end
    state = state or { used = {}, started = nil, cooldownUntil = 0 }
    if now < (state.cooldownUntil or 0) then return false, "cooldown", state end
    if state.started == nil or now - state.started > Rules.WINDOW then
        state = { used = {}, started = now, cooldownUntil = state.cooldownUntil or 0 }
    end
    if state.used[switchId] then return false, "duplicate", state end
    state.used[switchId] = true
    local count = 0
    for _ in pairs(state.used) do count += 1 end
    if count == Rules.SWITCHES then
        return true, "complete", { used = {}, started = nil, cooldownUntil = now + Rules.COOLDOWN }
    end
    return true, "progress", state
end
return table.freeze(Rules)
