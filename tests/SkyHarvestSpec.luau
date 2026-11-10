local Rules = require("../src/shared/SkyHarvestRules")
local function check(value, message)
    if not value then error(message, 2) end
end
local function run()
    check(Rules.canHarvest("meadow", 8, 0, 1000, nil, true), "starter harvest")
    check(not Rules.canHarvest("ridge", 8, 24, 1000, nil, true), "progress gate")
    check(Rules.canHarvest("ridge", 8, 25, 1000, nil, true), "ridge unlocked")
    check(not Rules.canHarvest("meadow", 13, 100, 1000, nil, true), "distance")
    check(not Rules.canHarvest("meadow", 8, 100, 1000, 900, true), "cooldown")
    check(Rules.canHarvest("meadow", 8, 100, 1180, 1000, true), "cooldown expires")
    check(not Rules.canHarvest("meadow", 8, 100, 1000, 1100, true), "clock rollback")
    check(not Rules.canHarvest("meadow", 0/0, 100, 1000, nil, true), "nan")
    check(not Rules.canHarvest("meadow", 8, 100, 1000, nil, false), "profile gate")
    check(Rules.reward("unknown") == nil, "unknown reward")
end
return run
