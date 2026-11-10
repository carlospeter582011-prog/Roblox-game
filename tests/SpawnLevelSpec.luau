-- Tests for src/shared/SpawnRules.luau and src/shared/Leveling.luau.
-- Loaded by tests/run.luau, which passes in its test registrar and equality helper.
local Spawn = require("../src/shared/SpawnRules")
local Leveling = require("../src/shared/Leveling")
local Species = require("../src/shared/CloudCatalog")

local function fixed(value)
    return function()
        return value
    end
end

return function(test, eq)
    test("world fast travel requires persisted catch milestones", function()
        eq(Spawn.canFastTravel("starter", 0), true, "starter open")
        eq(Spawn.canFastTravel("eastwind", 24), false, "eastwind locked")
        eq(Spawn.canFastTravel("eastwind", 25), true, "eastwind unlocked")
        eq(Spawn.canFastTravel("ridge", 74), false, "ridge locked")
        eq(Spawn.canFastTravel("ridge", 75), true, "ridge unlocked")
        eq(Spawn.canFastTravel("ridge", 500), true, "late game")
        eq(Spawn.canFastTravel("invalid", 999), false, "unknown destination")
        eq(Spawn.canFastTravel("starter", nil), false, "missing profile")
    end)

    test("expanded species catalog has many unique spawnable entries and every rarity tier", function()
        local count, tiers = 0, {}
        for id, species in pairs(Species) do
            count += 1
            eq(species.id, id, "stable id " .. id)
            eq(type(species.spawnWeight) == "number" and species.spawnWeight > 0, true, "weight " .. id)
            eq(type(species.baseRewardCoins) == "number" and species.baseRewardCoins > 0, true, "reward " .. id)
            eq(#species.colorRGB, 3, "color " .. id)
            tiers[species.rarity] = true
        end
        eq(count >= 50, true, "species count at least 50 (got " .. count .. ")")
        for _, tier in ipairs({ "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }) do
            eq(tiers[tier], true, "rarity " .. tier)
        end
        eq(Spawn.rollSpecies(Species, fixed(0)) ~= nil, true, "first spawn")
        eq(Spawn.rollSpecies(Species, fixed(0.999999)) ~= nil, true, "last spawn")
    end)

    test("rollSpecies maps rng ranges onto weights in sorted id order", function()
        local fixture = { breeze = { spawnWeight = 70 }, drizzle = { spawnWeight = 30 } }
        eq(Spawn.rollSpecies(fixture, fixed(0)), "breeze", "rng 0")
        eq(Spawn.rollSpecies(fixture, fixed(0.699)), "breeze", "rng 0.699")
        eq(Spawn.rollSpecies(fixture, fixed(0.701)), "drizzle", "rng 0.701")
        eq(Spawn.rollSpecies(fixture, fixed(0.9999)), "drizzle", "rng 0.9999")
    end)

    test("rollSpecies returns the last id if rng hits exactly 1.0", function()
        local fixture = { a = { spawnWeight = 1 }, b = { spawnWeight = 1 } }
        eq(Spawn.rollSpecies(fixture, fixed(1)), "b", "exact 1")
    end)

    test("rollSpecies ignores species without a positive finite weight", function()
        local fixture = { good = { spawnWeight = 1 }, zero = { spawnWeight = 0 }, nan = { spawnWeight = 0/0 }, missing = {} }
        eq(Spawn.rollSpecies(fixture, fixed(0)), "good")
    end)

    test("rollSpecies returns nil when nothing is spawnable", function()
        eq(Spawn.rollSpecies({}, fixed(0.5)), nil)
        eq(Spawn.rollSpecies({ bad = { spawnWeight = -1 } }, fixed(0.5)), nil)
    end)

    test("rollSpecies frequencies match the weights over many rolls", function()
        local fixture = { common = { spawnWeight = 70 }, rare = { spawnWeight = 30 } }
        local counts = { common = 0, rare = 0 }
        for i = 1, 1000 do
            local id = Spawn.rollSpecies(fixture, function() return (i - 0.5) / 1000 end)
            counts[id] += 1
        end
        eq(counts.common > counts.rare, true, "common more frequent")
    end)

    test("xpForLevel follows 25*(L-1)*L and clamps", function()
        eq(Leveling.xpForLevel(1), 0)
        eq(Leveling.xpForLevel(2), 50)
        eq(Leveling.xpForLevel(3), 150)
        eq(Leveling.xpForLevel(0), 0)
        eq(Leveling.xpForLevel(1000), Leveling.xpForLevel(100))
    end)

    test("levelForXp is correct at level boundaries", function()
        eq(Leveling.levelForXp(0), 1)
        eq(Leveling.levelForXp(49), 1)
        eq(Leveling.levelForXp(50), 2)
        eq(Leveling.levelForXp(149), 2)
        eq(Leveling.levelForXp(150), 3)
    end)

    test("levelForXp treats invalid input as level 1", function()
        eq(Leveling.levelForXp(nil), 1)
        eq(Leveling.levelForXp("x"), 1)
        eq(Leveling.levelForXp(-5), 1)
        eq(Leveling.levelForXp(0/0), 1)
    end)

    test("levelForXp is monotonic and consistent with xpForLevel", function()
        local prev = 1
        for xp = 0, 500, 7 do
            local level = Leveling.levelForXp(xp)
            eq(level >= prev, true)
            prev = level
            eq(Leveling.xpForLevel(level) <= xp, true)
            if level < Leveling.MAX_LEVEL then
                eq(xp < Leveling.xpForLevel(level + 1), true)
            end
        end
    end)

    test("progress safely handles invalid XP", function()
        local level, into, need = Leveling.progress(nil)
        eq(level, 1)
        eq(into, 0)
    end)

    test("progress reports xp into the level and xp needed", function()
        local level, into, need = Leveling.progress(60)
        eq(level, 2)
        eq(into, 10)
        eq(need, 100)
    end)
end
