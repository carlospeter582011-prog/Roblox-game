-- Regression tests for EvolutionRules.
local Rules = require("../src/shared/EvolutionRules")

return function(test, eq)
    test("evolution requires threshold and returns evolved id", function()
        eq(Rules.checkEvolution("breeze", 9), nil, "below threshold")
        eq(Rules.checkEvolution("breeze", 10), "gale", "at threshold")
        eq(Rules.checkEvolution("breeze", 100), "gale", "above threshold")
        eq(Rules.checkEvolution("unknown", 50), nil, "no recipe")
        eq(Rules.checkEvolution("breeze", -1), nil, "negative")
        eq(Rules.checkEvolution("breeze", 0/0), nil, "nan")
    end)

    test("tryEvolve awards once and mutates species", function()
        local data = { species = { breeze = 9 } }
        eq(Rules.tryEvolve(data, "breeze"), nil, "not yet")
        data.species.breeze = 10
        eq(Rules.tryEvolve(data, "breeze"), "gale", "first award")
        eq(data.species.gale, 1, "evolved counted")
        eq(data.evolutions.breeze, true, "claimed")
        eq(Rules.tryEvolve(data, "breeze"), nil, "not repeated")
        eq(data.species.gale, 1, "still one")
    end)

    test("invalid data is ignored", function()
        eq(Rules.tryEvolve(nil, "breeze"), nil, "nil data")
        eq(Rules.tryEvolve({ }, "breeze"), nil, "no species")
        local bad = { species = "not-table" }
        eq(Rules.tryEvolve(bad, "breeze"), nil, "bad species")
    end)
end
