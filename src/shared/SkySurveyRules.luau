-- Pure server-owned Sky Observatory survey challenge rules.
local Rules = {}
Rules.STEPS = 3
Rules.TIME_LIMIT = 150
Rules.COOLDOWN = 240
Rules.REWARD_COINS = 180
Rules.REWARD_XP = 90
function Rules.advance(state, station, now)
    if type(station) ~= "number" or station % 1 ~= 0 or station < 1 or station > Rules.STEPS then return state, "invalid" end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return state, "invalid" end
    if state and now < (state.cooldownUntil or 0) then return state, "cooldown" end
    if state and state.cooldownUntil and now >= state.cooldownUntil then state = nil end
    if state and state.started and now > state.started + Rules.TIME_LIMIT then state = nil end
    if not state then
        if station ~= 1 then return nil, "start_at_one" end
        return {started=now, next=2}, "started"
    end
    if station ~= state.next then return state, "wrong_order" end
    if station == Rules.STEPS then
        return {cooldownUntil=now+Rules.COOLDOWN}, "complete"
    end
    return {started=state.started,next=station+1}, "advanced"
end
return table.freeze(Rules)
