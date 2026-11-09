-- Tests for src/shared/ProgressRules.luau and src/shared/Encyclopedia.luau, plus checks that the
-- real tool and world catalogs satisfy what the UI relies on.
local Progress = require("../src/shared/ProgressRules")
local Encyclopedia = require("../src/shared/Encyclopedia")
local Species = require("../src/shared/CloudCatalog")
local Tools = require("../src/shared/CatchToolCatalog")
local Worlds = require("../src/shared/WorldCatalog")
local Bosses = require("../src/shared/BossCatalog")

return function(test, eq)
    local sample = {
        b = { unlockCatches = 10 },
        a = { unlockCatches = 10 },
        z = { unlockCatches = 0 },
        c = { unlockCatches = 25, order = 2 },
        d = { unlockCatches = 25, order = 1 },
        junk = { name = "no threshold" },
    }

    test("sortedByUnlock orders by threshold, then order, then id, and skips invalid entries", function()
        eq(table.concat(Progress.sortedByUnlock(sample), ","), "z,a,b,d,c", "order")
    end)

    test("status reports unlocked ids, the next id and the catches remaining", function()
        local unlocked, nextId, remaining = Progress.status(0, sample)
        eq(table.concat(unlocked, ","), "z", "unlocked at 0")
        eq(nextId, "a", "next at 0")
        eq(remaining, 10, "remaining at 0")
        unlocked, nextId, remaining = Progress.status(10, sample)
        eq(table.concat(unlocked, ","), "z,a,b", "unlocked at 10")
        eq(nextId, "d", "next at 10")
        eq(remaining, 15, "remaining at 10")
        unlocked, nextId, remaining = Progress.status(999, sample)
        eq(#unlocked, 5, "all unlocked")
        eq(nextId, nil, "no next")
        eq(remaining, 0, "nothing remaining")
    end)

    test("status treats invalid capture counts as 0", function()
        eq(select(2, Progress.status(nil, sample)), "a", "nil")
        eq(select(2, Progress.status(-5, sample)), "a", "negative")
        eq(select(2, Progress.status(0 / 0, sample)), "a", "NaN")
        eq(select(2, Progress.status("9", sample)), "a", "string")
    end)

    test("isUnlocked checks existence and threshold", function()
        eq(Progress.isUnlocked(10, "a", sample), true, "exact")
        eq(Progress.isUnlocked(9, "a", sample), false, "one short")
        eq(Progress.isUnlocked(99, "nope", sample), false, "unknown")
        eq(Progress.isUnlocked(nil, "a", sample), false, "nil count")
    end)

    test("the tool picker can offer every tool: sortedByUnlock returns all 15 and starts with the starter net", function()
        local ids = Progress.sortedByUnlock(Tools)
        local expected = 0
        for _ in pairs(Tools) do
            expected += 1
        end
        eq(#ids, expected, "all tools listed")
        eq(ids[1], "starter_net", "first tool is always unlocked")
        for i = 2, #ids do
            eq(Tools[ids[i - 1]].unlockCatches <= Tools[ids[i]].unlockCatches, true, "non-decreasing at " .. i)
        end
    end)

    test("worlds: unique orders 1..N, thresholds strictly increase with order, first world is free", function()
        local ids = Progress.sortedByUnlock(Worlds)
        eq(Worlds[ids[1]].unlockCatches, 0, "first world free")
        local seenOrder = {}
        for i, id in ipairs(ids) do
            local w = Worlds[id]
            eq(w.id, id, "id matches key " .. id)
            eq(w.order, i, "order matches unlock rank for " .. id)
            eq(seenOrder[w.order], nil, "unique order " .. w.order)
            seenOrder[w.order] = true
            if i > 1 then
                eq(Worlds[ids[i - 1]].unlockCatches < w.unlockCatches, true, "strictly increasing at " .. id)
            end
        end
    end)

    test("every world has exactly one boss and every boss points at a real world", function()
        local perWorld = {}
        for id, boss in pairs(Bosses) do
            eq(Worlds[boss.world] ~= nil, true, id .. " world exists")
            eq(perWorld[boss.world], nil, boss.world .. " has more than one boss")
            perWorld[boss.world] = id
            eq(type(boss.phases) == "number" and boss.phases >= 1, true, id .. " phases")
            eq(type(boss.rewardCoins) == "number" and boss.rewardCoins > 0, true, id .. " reward")
        end
        for id in pairs(Worlds) do
            eq(perWorld[id] ~= nil, true, id .. " has a boss")
        end
    end)

    test("encyclopedia counts only catalog species, ignoring variant keys and unknown ids", function()
        local caught = { breeze = 3, ["breeze:golden"] = 1, drizzle = 0, ghost = 5 }
        eq(Encyclopedia.uniqueCount(caught, Species), 1, "only breeze counts")
        eq(Encyclopedia.uniqueCount(caught), 3, "legacy mode counts every positive entry")
    end)

    test("encyclopedia completion percent is floored and never exceeds 100", function()
        local total = 0
        local all = {}
        for id in pairs(Species) do
            total += 1
            all[id] = 1
        end
        eq(Encyclopedia.completionPercent({}, Species), 0, "none")
        eq(Encyclopedia.completionPercent(all, Species), 100, "all")
        all["breeze:golden"] = 4
        all.ghost = 2
        eq(Encyclopedia.completionPercent(all, Species), 100, "extras ignored")
        eq(Encyclopedia.completionPercent({ breeze = 1 }, Species), math.floor(100 / total), "one species")
        eq(Encyclopedia.completionPercent({ breeze = 1 }, {}), 0, "empty catalog")
        eq(Encyclopedia.completionPercent(nil, Species), 0, "nil map")
    end)

    test("encyclopedia missing lists uncaught catalog species in sorted order", function()
        local small = { a = {}, b = {}, c = {} }
        eq(table.concat(Encyclopedia.missing({ b = 2 }, small), ","), "a,c", "missing")
        eq(#Encyclopedia.missing({ a = 1, b = 1, c = 1 }, small), 0, "none missing")
        eq(table.concat(Encyclopedia.missing(nil, small), ","), "a,b,c", "nil map")
        eq(table.concat(Encyclopedia.missing({ a = 0 }, small), ","), "a,b,c", "zero counts as missing")
    end)

    test("fromAttributes strips the SpeciesCount_ prefix and ignores other or non-numeric attributes", function()
        local map = Encyclopedia.fromAttributes({
            SpeciesCount_breeze = 4,
            SpeciesCount_drizzle = 1,
            CloudCount = 9,
            SpeciesCount_bad = "x",
            Quest_first_breeze = true,
        })
        eq(map.breeze, 4, "breeze")
        eq(map.drizzle, 1, "drizzle")
        eq(map.bad, nil, "non-numeric ignored")
        eq(map.CloudCount, nil, "other attribute ignored")
        eq(#Encyclopedia.ATTRIBUTE_PREFIX, 13, "prefix length")
        eq(Encyclopedia.uniqueCount(Encyclopedia.fromAttributes({ SpeciesCount_breeze = 2 }), Species), 1, "end to end")
        eq(next(Encyclopedia.fromAttributes(nil)), nil, "nil attributes")
    end)

    test("size counts catalog entries", function()
        eq(Encyclopedia.size({ a = 1, b = 2 }), 2, "two")
        eq(Encyclopedia.size(nil), 0, "nil")
    end)
end
