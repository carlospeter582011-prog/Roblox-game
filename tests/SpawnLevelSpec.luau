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
    test("expanded species catalog has 20 unique spawnable entries and every rarity tier", function()
        local count, tiers = 0, {}
        for id, species in pairs(Species) do
            count += 1
            eq(species.id, id, "stable id " .. id)
            eq(type(species.spawnWeight) == "number" and species.spawnWeight > 0, true, "weight " .. id)
            eq(type(species.baseRewardCoins) == "number" and species.baseRewardCoins > 0, true, "reward " .. id)
            eq(#species.colorRGB, 3, "color " .. id)
            tiers[species.rarity] = true
        end
        eq(count, 20, "species count")
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
        eq(Spawn.rollSpecies({ breeze = { spawnWeight = 70 }, drizzle = { spawnWeight = 30 } }, fixed(1)), "drizzle", "rng 1.0")
    end)

    test("rollSpecies ignores species without a positive finite weight", function()
        local species = {
            a = { spawnWeight = 0 },
            b = { spawnWeight = -1 },
            c = { spawnWeight = 0 / 0 },
            d = { spawnWeight = math.huge },
            e = {},
            f = { spawnWeight = 5 },
        }
        eq(Spawn.rollSpecies(species, fixed(0)), "f", "rng 0")
        eq(Spawn.rollSpecies(species, fixed(0.99)), "f", "rng 0.99")
    end)

    test("rollSpecies returns nil when nothing is spawnable", function()
        eq(Spawn.rollSpecies({}, fixed(0.5)), nil, "empty")
        eq(Spawn.rollSpecies({ a = { spawnWeight = 0 } }, fixed(0.5)), nil, "all zero")
    end)

    test("rollSpecies frequencies match the weights over many rolls", function()
        local state = 12345
        local function rng()
            state = (state * 1664525 + 1013904223) % 4294967296
            return state / 4294967296
        end
        local breeze = 0
        local total = 20000
        for _ = 1, total do
            if Spawn.rollSpecies({ breeze = { spawnWeight = 70 }, drizzle = { spawnWeight = 30 } }, rng) == "breeze" then
                breeze += 1
            end
        end
        local fraction = breeze / total
        eq(fraction > 0.68 and fraction < 0.72, true, "breeze fraction " .. tostring(fraction))
    end)

    test("xpForLevel follows 25*(L-1)*L and clamps", function()
        eq(Leveling.xpForLevel(1), 0, "L1")
        eq(Leveling.xpForLevel(2), 50, "L2")
        eq(Leveling.xpForLevel(3), 150, "L3")
        eq(Leveling.xpForLevel(4), 300, "L4")
        eq(Leveling.xpForLevel(100), 247500, "L100")
        eq(Leveling.xpForLevel(0), 0, "below 1")
        eq(Leveling.xpForLevel(101), 247500, "above max")
        eq(Leveling.xpForLevel(2.9), 50, "floors")
    end)

    test("levelForXp is correct at level boundaries", function()
        eq(Leveling.levelForXp(0), 1, "0")
        eq(Leveling.levelForXp(49), 1, "49")
        eq(Leveling.levelForXp(50), 2, "50")
        eq(Leveling.levelForXp(149), 2, "149")
        eq(Leveling.levelForXp(150), 3, "150")
        eq(Leveling.levelForXp(299), 3, "299")
        eq(Leveling.levelForXp(300), 4, "300")
        eq(Leveling.levelForXp(247499), 99, "247499")
        eq(Leveling.levelForXp(247500), 100, "247500")
        eq(Leveling.levelForXp(1e12), 100, "huge")
        eq(Leveling.levelForXp(math.huge), 100, "inf")
    end)

    test("levelForXp treats invalid input as level 1", function()
        eq(Leveling.levelForXp(nil), 1, "nil")
        eq(Leveling.levelForXp("5"), 1, "string")
        eq(Leveling.levelForXp(0 / 0), 1, "NaN")
        eq(Leveling.levelForXp(-1), 1, "negative")
    end)

    test("levelForXp is monotonic and consistent with xpForLevel", function()
        local previous = 1
        for xp = 0, 5000 do
            local level = Leveling.levelForXp(xp)
            eq(level >= previous, true, "monotonic at " .. xp)
            eq(xp >= Leveling.xpForLevel(level), true, "lower bound at " .. xp)
            if level < Leveling.MAX_LEVEL then
                eq(xp < Leveling.xpForLevel(level + 1), true, "upper bound at " .. xp)
            end
            previous = level
        end
    end)

    test("progress safely handles invalid XP", function()
        for _, value in ipairs({ "bad", -5, 0 / 0 }) do
            local level, into, needed = Leveling.progress(value)
            eq(level, 1, "invalid level")
            eq(into, 0, "invalid progress")
            eq(needed, 50, "invalid threshold")
        end
        local level, into, needed = Leveling.progress(nil)
        eq(level, 1, "nil level")
        eq(into, 0, "nil progress")
        eq(needed, 50, "nil threshold")
    end)

    test("progress reports xp into the level and xp needed", function()
        local level, into, needed = Leveling.progress(0)
        eq(level, 1, "L at 0")
        eq(into, 0, "into at 0")
        eq(needed, 50, "needed at 0")
        level, into, needed = Leveling.progress(60)
        eq(level, 2, "L at 60")
        eq(into, 10, "into at 60")
        eq(needed, 100, "needed at 60")
        level, into, needed = Leveling.progress(247500)
        eq(level, 100, "L at max")
        eq(into, 0, "into at max")
        eq(needed, 0, "needed at max")
    end)
end
