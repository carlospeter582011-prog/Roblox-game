-- Pure rules for a replayable three-island exploration time trial.
local Rules = {}
Rules.MAX_SECONDS = 180
Rules.STATIONS = { "meadow", "eastwind", "ridge" }
Rules.MAX_DISTANCE = 16

function Rules.validDistance(distance)
    return type(distance) == "number" and distance == distance
        and distance >= 0 and distance <= Rules.MAX_DISTANCE
end

function Rules.advance(nextIndex, station, elapsed, distance)
    if type(nextIndex) ~= "number" or nextIndex ~= math.floor(nextIndex)
        or nextIndex < 1 or nextIndex > #Rules.STATIONS then return nil, "invalid" end
    if not Rules.validDistance(distance) then return nil, "too_far" end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0
        or elapsed == math.huge or elapsed > Rules.MAX_SECONDS then return nil, "expired" end
    if Rules.STATIONS[nextIndex] ~= station then return nil, "wrong_station" end
    return nextIndex + 1, nextIndex == #Rules.STATIONS and "complete" or "progress"
end

function Rules.best(previous, elapsed)
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed <= 0
        or elapsed == math.huge or elapsed > Rules.MAX_SECONDS then return previous end
    if type(previous) ~= "number" or previous <= 0 or previous ~= previous then return elapsed end
    return math.min(previous, elapsed)
end

return Rules
