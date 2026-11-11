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

test("new player gets default data and the lock", function()
    clock.t = 1000
    local store = FakeStore.new()
    local result = repoFor(store, "A"):Load("p1")
    eq(result.ok, true, "load ok")
    eq(result.data.coins, 0, "coins")
    eq(result.data.version, Core.SCHEMA_VERSION, "version")
    eq(store.records.p1.lock.jobId, "A", "lock owner")
    eq(store.records.p1.lock.at, 1000, "lock time")
end)

test("v1 flat record migrates and bad fields are dropped", function()
    clock.t = 1000
    local store = FakeStore.new()
    store.records.p1 = {
        version = 1, coins = 120, xp = -5, captures = 7.9, lastSeen = 500,
        species = { breeze = 2, [string.rep("x", 49)] = 1, neg = -1 },
        quests = { first_breeze = true, bogus = true, three_clouds = "yes" },
    }
    local result = repoFor(store, "A"):Load("p1")
    eq(result.ok, true, "load ok")
    eq(result.data.coins, 120, "coins kept")
    eq(result.data.xp, 0, "negative xp dropped")
    eq(result.data.captures, 7, "captures floored")
    eq(result.data.species.breeze, 2, "species kept")
    eq(result.data.species.neg, nil, "negative species dropped")
    eq(result.data.species[string.rep("x", 49)], nil, "long species id dropped")
    eq(result.data.quests.first_breeze, true, "valid quest kept")
    eq(result.data.quests.bogus, nil, "unknown quest dropped")
    eq(result.data.quests.three_clouds, nil, "non-true quest dropped")
    eq(store.records.p1.version, Core.SCHEMA_VERSION, "stored at current schema")
    eq(type(result.data.crystals), "table", "v1 migration initializes crystal discoveries")
    eq(next(result.data.crystals), nil, "v1 migration does not invent discoveries")
end)

test("sanitize rejects NaN, inf, huge and non-table input", function()
    local nan = 0 / 0
    local clean = Core.sanitize({ coins = nan, xp = math.huge, captures = 1e13 }, validQuests, 5)
    eq(clean.coins, 0, "nan coins")
    eq(clean.xp, 0, "inf xp")
    eq(clean.captures, 0, "huge captures")
    eq(Core.sanitize("junk", validQuests, 5).coins, 0, "non-table")
    eq(Core.sanitize(nil, validQuests, 5).lastSeen, 5, "nil input")
end)

test("range training survives save and reload and invalid values are rejected", function()
    clock.t = 1000
    local store = FakeStore.new()
    local first = repoFor(store, "A")
    local loaded = first:Load("range_player")
    eq(loaded.ok, true, "initial load")
    eq(loaded.data.rangeTraining, 0, "default range")
    loaded.data.rangeTraining = 2
    eq(first:Save("range_player", loaded.data, true).ok, true, "save range")
    local second = repoFor(store, "B"):Load("range_player")
    eq(second.ok, true, "reload")
    eq(second.data.rangeTraining, 2, "persistent upgrade")
    eq(Core.sanitize({ rangeTraining = 9 }, validQuests, 1).rangeTraining, 0, "reject over max")
    eq(Core.sanitize({ rangeTraining = -1 }, validQuests, 1).rangeTraining, 0, "reject negative")
    eq(Core.sanitize({ rangeTraining = 1.8 }, validQuests, 1).rangeTraining, 1, "floor")
end)

test("boss victories survive save and rejoin with strict per-boss validation", function()
    clock.t = 1000
    local store = FakeStore.new()
    local first = repoFor(store, "boss-A")
    local result = first:Load("boss-player")
    eq(result.ok, true, "load")
    result.data.bossVictories.meadow = 2
    result.data.bossVictories.eastwind = 1
    eq(first:Save("boss-player", result.data, true).ok, true, "save")
    local rejoined = repoFor(store, "boss-B"):Load("boss-player")
    eq(rejoined.ok, true, "rejoin")
    eq(rejoined.data.bossVictories.meadow, 2, "meadow wins")
    eq(rejoined.data.bossVictories.eastwind, 1, "eastwind wins")
    local sanitized = Core.sanitize({ bossVictories = {
        meadow = 2.9, eastwind = -3, ridge = math.huge, bogus = 100
    } }, validQuests, 1)
    eq(sanitized.bossVictories.meadow, 2, "integer count")
    eq(sanitized.bossVictories.eastwind, nil, "negative rejected")
    eq(sanitized.bossVictories.ridge, nil, "infinite rejected")
    eq(sanitized.bossVictories.bogus, nil, "unknown boss rejected")
end)

test("companion selection requires caught owned species and persists", function()
    local Rules = require("../src/shared/CompanionRules")
    local catalog = { breeze = { name = "Breeze" }, drizzle = { name = "Drizzle" }, storm = {} }
    local species = { breeze = 2, drizzle = 1, storm = 0, fake = 20 }
    eq(Rules.owned("fake", species, catalog), false, "unknown catalog id")
    eq(Rules.owned("storm", species, catalog), false, "not caught")
    eq(Rules.next(nil, species, catalog), "breeze", "first unlocked")
    eq(Rules.next("breeze", species, catalog), "drizzle", "cycle forward")
    eq(Rules.next("drizzle", species, catalog), "breeze", "cycle wraps")
    eq(Rules.next(nil, {}, catalog), nil, "no species")
    local store = FakeStore.new()
    local a = repoFor(store, "companionA")
    local loaded = a:Load("companion")
    loaded.data.species.breeze = 1
    loaded.data.companionSpecies = "breeze"
    eq(a:Save("companion", loaded.data, true).ok, true, "save")
    local b = repoFor(store, "companionB"):Load("companion")
    eq(b.data.companionSpecies, "breeze", "saved selection")
    eq(Core.sanitize({ companionSpecies = "bad:id" }, validQuests, 1).companionSpecies, "", "invalid id")
end)

test("companion bonding progresses, persists and rejects malformed values", function()
    local Rules = require("../src/shared/CompanionRules")
    eq(Rules.bondLevel(0), 0, "new companion")
    eq(Rules.bondLevel(10), 1, "bond level one")
    eq(Rules.bondLevel(40), 2, "bond level two")
    eq(Rules.bondLevel(100), 3, "bond level three")
    eq(Rules.advanceBond(999999), 1000000, "bond cap")
    eq(Rules.advanceBond(math.huge), 1, "invalid bond resets")
    eq(Rules.bonusCoins(100, 100), 6, "capped six percent bonus")
    eq(Rules.bonusCoins(100, 0), 0, "no free initial bonus")
    local store = FakeStore.new()
    local first = repoFor(store, "bond-A")
    local loaded = first:Load("bond")
    loaded.data.companionBond.breeze = 40
    eq(first:Save("bond", loaded.data, true).ok, true, "bond saved")
    local second = repoFor(store, "bond-B"):Load("bond")
    eq(second.data.companionBond.breeze, 40, "bond reloaded")
    local clean = Core.sanitize({ companionBond = { breeze = 12.8, [ "bad:id" ] = 20, storm = math.huge, frost = -1 } }, validQuests, 1)
    eq(clean.companionBond.breeze, 12, "fractional bond floored")
    eq(clean.companionBond["bad:id"], nil, "invalid key rejected")
    eq(clean.companionBond.storm, nil, "infinite rejected")
    eq(clean.companionBond.frost, nil, "negative rejected")
end)

test("elemental companion resonance rewards same-element catches only", function()
    local Rules = require("../src/shared/CompanionRules")
    local catalog = {
        breeze = { element = "Air" }, cirrus = { element = "Air" },
        drizzle = { element = "Water" },
    }
    local owned = { breeze = 1, cirrus = 0 }
    eq(Rules.resonanceXp(100, "breeze", "cirrus", owned, catalog, { breeze = 0 }), 0, "unbonded")
    eq(Rules.resonanceXp(100, "breeze", "cirrus", owned, catalog, { breeze = 10 }), 5, "level 1")
    eq(Rules.resonanceXp(100, "breeze", "cirrus", owned, catalog, { breeze = 40 }), 10, "level 2")
    eq(Rules.resonanceXp(100, "breeze", "cirrus", owned, catalog, { breeze = 100 }), 15, "level 3")
    eq(Rules.resonanceXp(100, "breeze", "drizzle", owned, catalog, { breeze = 100 }), 0, "different element")
    eq(Rules.resonanceXp(100, "cirrus", "breeze", owned, catalog, { cirrus = 100 }), 0, "unowned companion")
    eq(Rules.resonanceXp(100, "breeze", "missing", owned, catalog, { breeze = 100 }), 0, "unknown target")
    eq(Rules.resonanceXp(math.huge, "breeze", "cirrus", owned, catalog, { breeze = 100 }), 0, "invalid xp")
    eq(Rules.resonanceXp(11, "breeze", "cirrus", owned, catalog, { breeze = 10 }), 0, "fractional reward floored")
end)

test("a live lock held by another server blocks load and leaves the record alone", function()
    clock.t = 1000
    local store = FakeStore.new()
    eq(repoFor(store, "A"):Load("p1").ok, true, "A loads")
    clock.t = 1100
    local result = repoFor(store, "B"):Load("p1")
    eq(result.ok, false, "B blocked")
    eq(result.reason, "locked", "reason")
    eq(store.records.p1.lock.jobId, "A", "lock still A")
    eq(store.records.p1.lock.at, 1000, "lock time untouched")
end)

test("a stale lock is taken over after the timeout", function()
    clock.t = 1000
    local store = FakeStore.new()
    repoFor(store, "A"):Load("p1")
    clock.t = 1000 + Core.LOCK_TIMEOUT
    local result = repoFor(store, "B"):Load("p1")
    eq(result.ok, true, "B takes over")
    eq(store.records.p1.lock.jobId, "B", "lock owner B")
end)

test("the same server can reload its own lock", function()
    clock.t = 1000
    local store = FakeStore.new()
    local repo = repoFor(store, "A")
    eq(repo:Load("p1").ok, true, "first")
    eq(repo:Load("p1").ok, true, "second")
end)

test("save persists data and refreshes the lock; release lets another server in", function()
    clock.t = 1000
    local store = FakeStore.new()
    local a = repoFor(store, "A")
    local loaded = a:Load("p1").data
    loaded.coins = 42
    loaded.species.breeze = 3
    clock.t = 1090
    eq(a:Save("p1", loaded, false).ok, true, "save ok")
    eq(store.records.p1.data.coins, 42, "coins saved")
    eq(store.records.p1.data.lastSeen, 1090, "lastSeen")
    eq(store.records.p1.lock.at, 1090, "lock refreshed")
    eq(a:Save("p1", loaded, true).ok, true, "release ok")
    eq(store.records.p1.lock, nil, "lock cleared")
    local b = repoFor(store, "B"):Load("p1")
    eq(b.ok, true, "B loads after release")
    eq(b.data.coins, 42, "B sees saved coins")
end)

test("save after losing the lock is refused and never overwrites the new owner", function()
    clock.t = 1000
    local store = FakeStore.new()
    local a = repoFor(store, "A")
    local dataA = a:Load("p1").data
    clock.t = 1000 + Core.LOCK_TIMEOUT + 1
    local dataB = repoFor(store, "B"):Load("p1").data
    dataB.coins = 999
    repoFor(store, "B"):Save("p1", dataB, false)
    dataA.coins = 5
    local result = a:Save("p1", dataA, false)
    eq(result.ok, false, "A refused")
    eq(result.reason, "lost_lock", "reason")
    eq(store.records.p1.data.coins, 999, "B's data intact")
    eq(store.records.p1.lock.jobId, "B", "B still owns lock")
end)

test("save without ever holding the lock is refused", function()
    local store = FakeStore.new()
    local result = repoFor(store, "A"):Save("p1", Core.defaultData(0), false)
    eq(result.ok, false, "refused")
    eq(result.reason, "lost_lock", "reason")
    eq(store.records.p1, nil, "nothing written")
end)

test("a record written by a newer schema is refused and left untouched", function()
    local store = FakeStore.new()
    store.records.p1 = { version = 99, data = { coins = 7 } }
    local result = repoFor(store, "A"):Load("p1")
    eq(result.ok, false, "refused")
    eq(result.reason, "newer_schema", "reason")
    eq(store.records.p1.version, 99, "record untouched")
    eq(store.records.p1.lock, nil, "no lock taken")
end)

test("retry recovers from transient datastore failures with linear backoff", function()
    clock.t = 1000
    local store = FakeStore.new()
    store.failNext = 2
    local repo = repoFor(store, "A")
    local waits = {}
    local result, attempts = Core.retry(function()
        return repo:Load("p1")
    end, 5, 3, function(s)
        table.insert(waits, s)
    end, { error = true, locked = true })
    eq(result.ok, true, "recovered")
    eq(attempts, 3, "attempts")
    eq(#waits, 2, "wait count")
    eq(waits[1], 3, "first wait")
    eq(waits[2], 6, "second wait")
end)

test("retry gives up after the attempt budget and reports the error", function()
    local store = FakeStore.new()
    store.failNext = 99
    local repo = repoFor(store, "A")
    local result, attempts = Core.retry(function()
        return repo:Load("p1")
    end, 3, 1, function() end, { error = true })
    eq(result.ok, false, "failed")
    eq(result.reason, "error", "reason")
    eq(attempts, 3, "attempts")
    eq(store.calls, 3, "datastore calls")
end)

test("retry does not retry non-retryable reasons", function()
    local store = FakeStore.new()
    local result, attempts = Core.retry(function()
        return repoFor(store, "A"):Save("p1", Core.defaultData(0), false)
    end, 4, 1, function() end, { error = true })
    eq(result.reason, "lost_lock", "reason")
    eq(attempts, 1, "attempts")
end)

test("a lock that frees up mid-retry lets the waiting server in", function()
    clock.t = 1000
    local store = FakeStore.new()
    local a = repoFor(store, "A")
    local data = a:Load("p1").data
    local b = repoFor(store, "B")
    local waited = 0
    local result, attempts = Core.retry(function()
        return b:Load("p1")
    end, 5, 3, function()
        waited += 1
        if waited == 2 then
            a:Save("p1", data, true) -- A finishes leaving while B is retrying
        end
    end, { error = true, locked = true })
    eq(result.ok, true, "B got in")
    eq(attempts, 3, "attempts")
end)


test("crystal discoveries survive profile save and reload", function()
    clock.t = 1000
    local store = FakeStore.new()
    local a = repoFor(store, "crystal-A")
    local data = a:Load("crystal-player").data
    data.crystals[1] = true
    data.crystals[18] = true
    eq(a:Save("crystal-player", data, true).ok, true, "saved")
    local b = repoFor(store, "crystal-B"):Load("crystal-player")
    eq(b.ok, true, "reloaded")
    eq(b.data.crystals[1], true, "first crystal")
    eq(b.data.crystals[18], true, "last crystal")
end)

test("crystal migration drops invalid keys and values", function()
    local clean = Core.sanitize({crystals = {[1]=true, [18]=true, [19]=true, [0]=true, [2]="yes", [3.5]=true, bogus=true}}, validQuests, 0)
    eq(clean.crystals[1], true, "first kept")
    eq(clean.crystals[18], true, "last kept")
    eq(clean.crystals[19], nil, "out of bounds")
    eq(clean.crystals[2], nil, "non boolean")
    eq(clean.crystals[3.5], nil, "fraction")
end)

require("./CatchRulesSpec")(test, eq)
require("./SpawnLevelSpec")(test, eq)
require("./MutationsSpec")(test, eq)
require("./MutationAccountingSpec")(test, eq)
require("./ProgressSpec")(test, eq)
require("./RecoverySpec")(test, eq)
require("./CrystalRulesSpec")(test, eq)
require("./BossChallengeSpec")(test, eq)
require("./CompanionAbilitySpec")(test, eq)
require("./SpeciesMasterySpec")(test, eq)

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
