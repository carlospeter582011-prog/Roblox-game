-- Pure rules for the cooperative Sky Rune Bridge puzzle.
local Rules = {}
Rules.ORDER = { "Air", "Water", "Storm" }
Rules.WINDOW = 75
Rules.BRIDGE_DURATION = 55
local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end
function Rules.advance(stage, startedAt, rune, now, distance, ready)
    if ready ~= true or not finite(now) or now < 0 or not finite(distance) or distance < 0 or distance > 13 then
        return 0, nil, false
    end
    if type(stage) ~= "number" or stage % 1 ~= 0 or stage < 0 or stage > #Rules.ORDER then
        stage, startedAt = 0, nil
    end
    if stage > 0 and (not finite(startedAt) or now < startedAt or now - startedAt > Rules.WINDOW) then
        stage, startedAt = 0, nil
    end
    if rune ~= Rules.ORDER[stage + 1] then
        return stage, startedAt, false
    end
    if stage == 0 then startedAt = now end
    stage += 1
    if stage == #Rules.ORDER then
        return 0, nil, true
    end
    return stage, startedAt, false
end
return Rules
