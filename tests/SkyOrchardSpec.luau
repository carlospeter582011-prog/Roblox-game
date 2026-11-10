local Rules = require("../src/shared/SkyOrchardRules")
assert(Rules.canHarvest("meadow", 0, 10, true, true, 100, nil))
assert(not Rules.canHarvest("ridge", 59, 10, true, true, 100, nil))
assert(Rules.canHarvest("ridge", 60, 10, true, true, 100, nil))
assert(not Rules.canHarvest("meadow", 0, 15, true, true, 100, nil))
assert(not Rules.canHarvest("meadow", 0, 10, false, true, 100, nil))
assert(not Rules.canHarvest("meadow", 0, 10, true, false, 100, nil))
assert(not Rules.canHarvest("meadow", 0, 10, true, true, 219, 100))
assert(Rules.canHarvest("meadow", 0, 10, true, true, 220, 100))
assert(not Rules.canHarvest("meadow", 0, 10, true, true, 100, 101))
assert(not Rules.canHarvest("invalid", 0, 10, true, true, 100, nil))
assert(not Rules.canHarvest("meadow", 0, 0/0, true, true, 100, nil))
-- Cross-server cooldown timestamps are epoch seconds; rejoining cannot bypass a persisted window.
local harvestedAt = 1794330000
assert(not Rules.canHarvest("meadow", 0, 10, true, true, harvestedAt + 20, harvestedAt))
assert(Rules.canHarvest("meadow", 0, 10, true, true, harvestedAt + 120, harvestedAt))
assert(not Rules.canHarvest("meadow", 0, 10, true, true, math.huge, nil))
return true
