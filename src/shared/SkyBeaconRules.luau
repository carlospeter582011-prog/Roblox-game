-- Pure server-side rules for the three-beacon sky memory challenge.
local Rules = {}
Rules.TIME_LIMIT = 35
Rules.MAX_DISTANCE = 14
Rules.COOLDOWN = 8
function Rules.advance(stage, beacon, elapsed, distance)
    if type(stage) ~= "number" or stage % 1 ~= 0 or stage < 0 or stage > 2 then return 0, "reset" end
    if type(beacon) ~= "number" or beacon % 1 ~= 0 or beacon < 1 or beacon > 3 then return stage, "invalid" end
    if type(distance) ~= "number" or distance ~= distance or distance == math.huge or distance < 0 or distance > Rules.MAX_DISTANCE then return stage, "far" end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed < 0 or elapsed == math.huge then return 0, "reset" end
    if stage > 0 and elapsed > Rules.TIME_LIMIT then return 0, "expired" end
    if beacon ~= stage + 1 then return 0, "wrong" end
    if beacon == 3 then return 0, "complete" end
    return stage + 1, "progress"
end
return table.freeze(Rules)
