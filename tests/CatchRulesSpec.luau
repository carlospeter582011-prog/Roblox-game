-- Tests for src/shared/CatchRules.luau plus data-integrity checks on the real catalogs.
-- Loaded by tests/run.luau, which passes in its test registrar and equality helper.
local Rules = require("../src/shared/CatchRules")
local Species = require("../src/shared/CloudCatalog")
local Quests = require("../src/shared/QuestCatalog")
local Tools = require("../src/shared/CatchToolCatalog")
local SpawnRules = require("../src/shared/SpawnRules")

local function newData()
    return { version = 2, coins = 0, xp = 0, captures = 0, species = {}, quests = {}, lastSeen = 0 }
end

local function joined(list)
    return table.concat(list, ",")
end

return function(test, eq)
    test("range validation rejects NaN, infinity and negative distances", function()
        local Rules = require("../src/shared/CatchRules")
        local species = { baseCatchRadius = 5 }
        local tool = { rangeBonus = 2 }
        eq(Rules.isInRange(7, species, tool), true, "boundary")
        eq(Rules.isInRange(7.01, species, tool), false, "out of range")
        eq(Rules.isInRange(-1, species, tool), false, "negative")
        eq(Rules.isInRange(0/0, species, tool), false, "NaN")
        eq(Rules.isInRange(math.huge, species, tool), false, "infinity")
        eq(Rules.isInRange(nil, species, tool), false, "missing")
        eq(Rules.canMagnetPull(0/0, species, "cloud_magnet", tool), false, "magnet NaN")
    end)

    test("cloud regions rotate across three walkable 3D islands", function()
        local expected = { "StarterMeadow", "EastwindOutlook", "StarterMeadow", "StarterMeadow", "ThunderheadRidge" }
        for i, name in ipairs(expected) do
            local region = SpawnRules.regionBounds(i)
            eq(region.name, name, "region " .. i)
            eq(region.minX < region.maxX and region.minZ < region.maxZ, true, "bounds " .. i)
        end
        eq(SpawnRules.regionBounds(0), nil, "invalid zero")
        eq(SpawnRules.regionBounds(-1), nil, "invalid negative")
        eq(SpawnRules.regionBounds(1.5), nil, "invalid fraction")
        local ridge = SpawnRules.regionBounds(5)
        eq(ridge.minX >= 260 and ridge.maxX <= 370, true, "ridge within floor")
        local east = SpawnRules.regionBounds(2)
        eq(east.minX >= 120 and east.maxX <= 220, true, "outlook within floor")
    end)

    test("resolveTool keeps an unlocked equipped tool", function()
        local tool, id = Rules.resolveTool("wind_lasso", 3, Tools)
        eq(id, "wind_lasso", "id")
        eq(tool, Tools.wind_lasso, "tool")
    end)

    test("resolveTool falls back to the starter net for locked, unknown or invalid ids", function()
        eq(select(2, Rules.resolveTool("wind_lasso", 2, Tools)), "starter_net", "locked")
        eq(select(2, Rules.resolveTool("no_such_tool", 99, Tools)), "starter_net", "unknown")
        eq(select(2, Rules.resolveTool(nil, 99, Tools)), "starter_net", "nil")
        eq(select(2, Rules.resolveTool(42, 99, Tools)), "starter_net", "non-string")
        eq((Rules.resolveTool("golden_net", 29, Tools)), Tools.starter_net, "golden net needs 30")
    end)

    test("canEquip enforces existence, unlock threshold, type and id length", function()
        eq(Rules.canEquip("starter_net", 0, Tools), true, "starter")
        eq(Rules.canEquip("cloud_magnet", 15, Tools), true, "exactly unlocked")
        eq(Rules.canEquip("cloud_magnet", 14, Tools), false, "one short")
        eq(Rules.canEquip("no_such_tool", 99, Tools), false, "unknown")
        eq(Rules.canEquip(7, 99, Tools), false, "non-string")
        eq(Rules.canEquip(nil, 99, Tools), false, "nil")
        eq(Rules.canEquip(string.rep("a", 41), 99, Tools), false, "too long")
    end)

    test("isInRange includes the boundary and honours tool range bonus", function()
        eq(Rules.isInRange(12, Species.breeze, Tools.starter_net), true, "boundary")
        eq(Rules.isInRange(12.01, Species.breeze, Tools.starter_net), false, "just outside")
        eq(Rules.isInRange(16, Species.breeze, Tools.wind_lasso), true, "lasso boundary")
        eq(Rules.isInRange(16.01, Species.breeze, Tools.wind_lasso), false, "lasso outside")
        eq(Rules.isInRange(10, Species.drizzle, Tools.starter_net), true, "drizzle boundary")
    end)

    test("Cloud Magnet pulls beyond normal range but only when server resolves magnet", function()
        eq(Rules.canMagnetPull(31, Species.breeze, "cloud_magnet", Tools.cloud_magnet), true, "pull within field")
        eq(Rules.canMagnetPull(32, Species.breeze, "cloud_magnet", Tools.cloud_magnet), false, "outside field")
        eq(Rules.canMagnetPull(31, Species.breeze, "starter_net", Tools.starter_net), false, "wrong tool")
        eq(Rules.canMagnetPull(-1, Species.breeze, "cloud_magnet", Tools.cloud_magnet), false, "negative")
        eq(Rules.canMagnetPull(math.huge, Species.breeze, "cloud_magnet", Tools.cloud_magnet), false, "infinite")
    end)

    test("vacuum burst picks nearest unique targets and breaks ties by id", function()
        local ids = Rules.selectBurstTargets("main", {
            { id = "far", distance = 18 },
            { id = "b", distance = 4 },
            { id = "a", distance = 4 },
            { id = "a", distance = 4 },
        }, 3)
        eq(table.concat(ids, ","), "main,a,b", "nearest deterministic unique targets")
    end)

    test("burst selection excludes invalid distances and respects single-catch limit", function()
        local candidates = {
            { id = "bad", distance = -2 },
            { id = "infinite", distance = math.huge },
            { id = "good", distance = 2 },
        }
        eq(table.concat(Rules.selectBurstTargets("main", candidates, 3), ","), "main,good", "invalid filtered")
        eq(table.concat(Rules.selectBurstTargets("main", candidates, 1), ","), "main", "normal tool")
        eq(table.concat(Rules.selectBurstTargets("main", {}, 3), ","), "main", "empty burst")
    end)

    test("coinReward applies the tool multiplier and floors", function()
        eq(Rules.coinReward(Species.breeze, Tools.starter_net), 10, "breeze starter")
        eq(Rules.coinReward(Species.breeze, Tools.golden_net), 15, "breeze golden")
        eq(Rules.coinReward(Species.drizzle, Tools.golden_net), 18, "drizzle golden")
        eq(Rules.coinReward({ baseRewardCoins = 7 }, { coinMultiplier = 1.5 }), 10, "floors 10.5")
    end)

    test("first breeze catch completes first_breeze and awards its reward", function()
        local data = newData()
        local done = Rules.applyCatch(data, "breeze", 10, Quests)
        eq(joined(done), "first_breeze", "completed")
        eq(data.species.breeze, 1, "species count")
        eq(data.captures, 1, "captures")
        eq(data.coins, 10 + Quests.first_breeze.rewardCoins, "coins")
        eq(data.xp, Rules.XP_PER_CATCH + Quests.first_breeze.rewardXP, "xp")
        eq(data.quests.first_breeze, true, "flag")
    end)

    test("third catch completes three_clouds; later catches award nothing extra", function()
        local data = newData()
        eq(joined(Rules.applyCatch(data, "breeze", 10, Quests)), "first_breeze", "catch 1")
        eq(joined(Rules.applyCatch(data, "breeze", 10, Quests)), "", "catch 2")
        eq(joined(Rules.applyCatch(data, "drizzle", 12, Quests)), "three_clouds", "catch 3")
        eq(data.captures, 3, "captures")
        eq(data.species.breeze, 2, "breeze")
        eq(data.species.drizzle, 1, "drizzle")
        eq(data.coins, 10 + 50 + 10 + 12 + 80, "coins after 3")
        eq(data.xp, 10 + 25 + 10 + 10 + 40, "xp after 3")
        eq(joined(Rules.applyCatch(data, "breeze", 10, Quests)), "", "catch 4")
        eq(data.coins, 10 + 50 + 10 + 12 + 80 + 10, "no repeat reward")
    end)

    test("catching a non-breeze species does not complete first_breeze", function()
        local data = newData()
        eq(joined(Rules.applyCatch(data, "drizzle", 12, Quests)), "", "completed")
        eq(data.quests.first_breeze, nil, "not flagged")
        eq(data.coins, 12, "coins")
    end)

    test("one catch can complete several quests, reported in sorted order", function()
        local data = newData()
        data.captures = 2
        data.species.drizzle = 2
        eq(joined(Rules.applyCatch(data, "breeze", 10, Quests)), "first_breeze,three_clouds", "both")
        eq(data.coins, 10 + 50 + 80, "both rewards")
    end)

    test("applyCatch with no quests only records the catch", function()
        local data = newData()
        eq(#Rules.applyCatch(data, "breeze", 10, {}), 0, "completed")
        eq(data.coins, 10, "coins")
        eq(data.xp, Rules.XP_PER_CATCH, "xp")
    end)

    test("catalogs: species have the fields the rules read", function()
        for id, s in pairs(Species) do
            eq(s.id, id, "species id matches key " .. id)
            eq(type(s.baseCatchRadius) == "number" and s.baseCatchRadius > 0, true, id .. " radius")
            eq(type(s.baseRewardCoins) == "number" and s.baseRewardCoins >= 0, true, id .. " reward")
            eq(type(s.spawnWeight) == "number" and s.spawnWeight > 0, true, id .. " spawnWeight")
            eq(type(s.name) == "string" and #s.name > 0, true, id .. " name")
            eq(type(s.colorRGB) == "table" and #s.colorRGB == 3, true, id .. " colorRGB shape")
            for i = 1, 3 do
                local c = s.colorRGB[i]
                eq(type(c) == "number" and c >= 0 and c <= 255 and c == math.floor(c), true, id .. " colorRGB[" .. i .. "]")
            end
        end
    end)

    test("catalogs: tools include the starter net and well-formed numbers", function()
        eq(Tools.starter_net ~= nil, true, "starter exists")
        eq(Tools.starter_net.unlockCatches, 0, "starter always unlocked")
        for id, t in pairs(Tools) do
            eq(#id <= Rules.MAX_TOOL_ID_LENGTH, true, id .. " id length")
            eq(type(t.unlockCatches) == "number" and t.unlockCatches >= 0, true, id .. " unlock")
            eq(type(t.rangeBonus) == "number" and t.rangeBonus >= 0, true, id .. " range")
            eq(type(t.cooldown) == "number" and t.cooldown > 0, true, id .. " cooldown")
            eq(type(t.coinMultiplier) == "number" and t.coinMultiplier > 0, true, id .. " multiplier")
        end
    end)

    test("catalogs: quests are well-formed and reference real species", function()
        for id, q in pairs(Quests) do
            eq(q.id, id, "quest id matches key " .. id)
            eq(q.objective == "catch_species" or q.objective == "total_catches", true, id .. " objective")
            eq(type(q.required) == "number" and q.required >= 1, true, id .. " required")
            eq(type(q.rewardCoins) == "number" and q.rewardCoins >= 0, true, id .. " coins")
            eq(type(q.rewardXP) == "number" and q.rewardXP >= 0, true, id .. " xp")
            if q.objective == "catch_species" then
                eq(Species[q.speciesId] ~= nil, true, id .. " species exists")
            end
        end
    end)
end
