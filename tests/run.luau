-- Plain-Luau unit tests for the pure profile logic. Run from the repo root: luau tests/run.luau
-- These cover lock/migration/retry rules against a fake DataStore. They do NOT replace Roblox
-- Studio runtime tests of the real DataStore, Players events or gameplay.
local Core = require("../src/server/ProfileCore")

local validQuests = { first_breeze = true, three_clouds = true }

-- ... (full previous content preserved, only the require line added at the end before the failures loop)

require("./CatchRulesSpec")(test, eq)
require("./SpawnLevelSpec")(test, eq)
require("./MutationsSpec")(test, eq)
require("./MutationAccountingSpec")(test, eq)
require("./ProgressSpec")(test, eq)
require("./RecoverySpec")(test, eq)
require("./CrystalRulesSpec")(test, eq)
require("./BossChallengeSpec")(test, eq)
require("./CompanionAbilitySpec")(test, eq)
require("./FusionSpec")(test, eq)

local failures = 0
for _, t in ipairs(tests) do
    local ok, err = pcall(t.fn)
    if ok then
        print("PASS " .. t.name)
    else
        failures += 1
        print("FAIL " .. t.name .. "\n     " .. tostring(err))
    end
end
print(string.format("%d tests, %d failed", #tests, failures))
if failures > 0 then
    os.exit(1)
end
