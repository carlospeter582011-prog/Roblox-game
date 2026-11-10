return function(test, eq)
    local Rules = require("../src/shared/CloudEvolutionRules")
    local catalog = {
        breeze = { name = "Breeze" }, gale = { name = "Gale" },
        drizzle = { name = "Drizzle" }, monsoon = { name = "Monsoon" },
    }

    test("evolution requires spare specimen and sufficient resources", function()
        local species = { breeze = 2 }
        local ok = Rules.canEvolve("breeze", species, 50, 10, 2, catalog)
        eq(ok, true, "can evolve with spare")
        local bad = Rules.canEvolve("breeze", { breeze = 1 }, 100, 20, 5, catalog)
        eq(bad, false, "protects last specimen")
    end)

    test("evolution rejects insufficient coins or bond or level", function()
        local species = { breeze = 3 }
        eq(Rules.canEvolve("breeze", species, 40, 10, 2, catalog), false, "low coins")
        eq(Rules.canEvolve("breeze", species, 50, 5, 2, catalog), false, "low bond")
        eq(Rules.canEvolve("breeze", species, 50, 10, 1, catalog), false, "low level")
    end)

    test("applyEvolution is immutable and produces correct result", function()
        local species = { breeze = 2, gale = 0 }
        local result, err = Rules.applyEvolution("breeze", species, 60, 15, 3, catalog)
        eq(err, nil, "no error")
        eq(result.coins, 10, "coins deducted")
        eq(result.species.breeze, 1, "base reduced")
        eq(result.species.gale, 1, "evolved gained")
        eq(result.evolvedTo, "gale", "target id")
        eq(species.breeze, 2, "original counts unchanged")
    end)

    test("unknown path is rejected", function()
        local ok, reason = Rules.canEvolve("void", { void = 5 }, 1000, 100, 10, catalog)
        eq(ok, false, "no path")
        eq(reason, "no_path", "reason")
    end)
end
