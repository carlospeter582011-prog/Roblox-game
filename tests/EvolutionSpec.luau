-- Evolution rules and profile persistence tests.
local Rules = require("../src/shared/EvolutionRules")
local Core = require("../src/server/ProfileCore")

return function(test, eq)
    local catalog = { breeze = { name = "Breeze Cloud" }, thunder = { name = "Thunder Cloud" } }

    test("evolution requires ownership, count and coins then advances stages", function()
        local species = { breeze = 2 }
        local ok, reason = Rules.canEvolve("breeze", species, {}, 100, catalog)
        eq(ok, false, "below threshold")
        eq(reason, "Need 3 of this species", "threshold message")
        species.breeze = 5
        ok, reason = Rules.canEvolve("breeze", species, {}, 40, catalog)
        eq(ok, false, "insufficient coins")
        ok, reason, cost = Rules.canEvolve("breeze", species, {}, 60, catalog)
        eq(ok, true, "can evolve")
        eq(reason, 1, "next stage")
        eq(cost, 50, "stage 1 cost")
        local evo = { breeze = 1 }
        ok, reason, cost = Rules.canEvolve("breeze", { breeze = 10 }, evo, 200, catalog)
        eq(ok, true, "stage 2 allowed")
        eq(reason, 2, "next is 2")
        eq(cost, 150, "stage 2 cost")
        ok = Rules.canEvolve("breeze", { breeze = 30 }, { breeze = 3 }, 1000, catalog)
        eq(ok, false, "max stage blocked")
        ok = Rules.canEvolve("missing", { breeze = 10 }, {}, 1000, catalog)
        eq(ok, false, "unknown species")
        ok = Rules.canEvolve("thunder", { breeze = 10 }, {}, 1000, catalog)
        eq(ok, false, "not owned")
    end)

    test("evolution XP bonus is stage-scaled and rejects invalid XP", function()
        eq(Rules.xpBonus(100, 0), 0, "stage 0")
        eq(Rules.xpBonus(100, 1), 5, "stage 1")
        eq(Rules.xpBonus(100, 2), 10, "stage 2")
        eq(Rules.xpBonus(100, 3), 15, "stage 3")
        eq(Rules.xpBonus(100, 9), 15, "clamped")
        eq(Rules.xpBonus(math.huge, 3), 0, "invalid xp")
        eq(Rules.xpBonus(11, 1), 0, "floor")
    end)

    test("evolution stages persist through sanitize, save and reload", function()
        local clean = Core.sanitize({
            evolutions = { breeze = 2.9, thunder = -1, bad = 1, [string.rep("x", 49)] = 1 }
        }, {}, 1)
        eq(clean.evolutions.breeze, 2, "floored and capped")
        eq(clean.evolutions.thunder, nil, "negative rejected")
        eq(clean.evolutions.bad, 1, "valid kept")
        -- long id rejected by length
        local long = string.rep("x", 49)
        eq(clean.evolutions[long], nil, "long id rejected")

        -- Full save/reload using the existing test infrastructure pattern is covered
        -- by ProfileCore unit tests; this asserts the field is present on defaults.
        local defaults = Core.defaultData(0)
        eq(type(defaults.evolutions), "table", "default evolutions table")
        eq(next(defaults.evolutions), nil, "empty by default")
    end)
end
