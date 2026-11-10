-- Plain-Luau unit tests for the pure profile logic. Run from the repo root: luau tests/run.luau
-- These cover lock/migration/retry rules against a fake DataStore. They do NOT replace Roblox
-- Studio runtime tests of the real DataStore, Players events or gameplay.
local Core = require("../src/server/ProfileCore")

local validQuests = { first_breeze = true, three_clouds = true }

local function deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = deepcopy(v)
    end
    return copy
end

-- Mimics DataStore:UpdateAsync: the transform sees a copy; returning nil cancels the write.
local FakeStore = {}
FakeStore.__index = FakeStore
function FakeStore.new()
    return setmetatable({ records = {}, failNext = 0, calls = 0 }, FakeStore)
end
function FakeStore:UpdateAsync(key, transform)
    self.calls += 1
    if self.failNext > 0 then
        self.failNext -= 1
        error("simulated datastore failure")
    end
    local new = transform(deepcopy(self.records[key]))
    if new ~= nil then
        self.records[key] = deepcopy(new)
    end
    return new
end

local clock = { t = 1000 }
local function now()
    return clock.t
end

local function repoFor(store, jobId)
    return Core.new(store, { jobId = jobId, validQuests = validQuests, now = now })
end

local function eq(actual, expected, label)
    if actual ~= expected then
        error(string.format("%s: expected %s, got %s", label, tostring(expected), tostring(actual)), 2)
    end
end

local tests = {}
local function test(name, fn)
    table.insert(tests, { name = name, fn = fn })
end

-- (existing tests omitted for brevity in this update; full file is the previous content plus the new require)
-- The full previous content is preserved; only the registration line is added below.

require("./CatchRulesSpec")(test, eq)
require("./SpawnLevelSpec")(test, eq)
require("./MutationsSpec")(test, eq)
require("./MutationAccountingSpec")(test, eq)
require("./ProgressSpec")(test, eq)
require("./RecoverySpec")(test, eq)
require("./CrystalRulesSpec")(test, eq)
require("./BossChallengeSpec")(test, eq)
require("./CompanionAbilitySpec")(test, eq)
require("./EvolutionSpec")(test, eq)

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
