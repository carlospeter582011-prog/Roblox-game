local Rules = require("../src/server/CloudBurstRules")
local cloud, another = {}, {}
assert(Rules.canReward(cloud, cloud, true, 100, 5, true, false))
assert(Rules.canReward(cloud, cloud, true, 100, 25, false, true), "targeted magnet reach")
assert(not Rules.canReward(another, cloud, true, 100, 5, true, false), "stale target")
assert(not Rules.canReward(nil, cloud, true, 100, 5, true, false), "despawned")
assert(not Rules.canReward(cloud, cloud, false, 100, 5, true, false), "character changed")
assert(not Rules.canReward(cloud, cloud, true, 0, 5, true, false), "dead player")
assert(not Rules.canReward(cloud, cloud, true, math.huge, 5, true, false), "invalid health")
assert(not Rules.canReward(cloud, cloud, true, 100, math.huge, true, false), "infinite distance")
assert(not Rules.canReward(cloud, cloud, true, 100, 5, false, false), "out of range")
return true
