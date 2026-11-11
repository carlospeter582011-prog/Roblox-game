-- Pure launch-pad progression and anti-abuse rules. Server owns positions and cooldown.
local Rules = {}
Rules.COOLDOWN = 12
Rules.MAX_DISTANCE = 13
Rules.PADS = {
    meadow = { level = 1, velocity = 64, lift = 55 },
    eastwind = { level = 3, velocity = 76, lift = 65 },
    ridge = { level = 5, velocity = 82, lift = 70 },
}
function Rules.canLaunch(padId, level, distance, now, lastUse, ready)
    local pad = type(padId) == "string" and Rules.PADS[padId]
    if not pad or ready ~= true then return false, "unavailable" end
    if type(level) ~= "number" or level ~= level or level < pad.level then return false, "level" end
    if type(distance) ~= "number" or distance ~= distance or distance < 0 or distance > Rules.MAX_DISTANCE then
        return false, "distance"
    end
    if type(now) ~= "number" or now ~= now or now == math.huge then return false, "clock" end
    if type(lastUse) == "number" and now - lastUse < Rules.COOLDOWN then return false, "cooldown" end
    return true, pad
end
return table.freeze(Rules)
