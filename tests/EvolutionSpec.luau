-- Regression tests for EvolutionRules
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")
    local Catalog = require("../src/shared/CloudCatalog")

    test("valid evolution path succeeds with exact thresholds", function()
        local result = Rules.proposeEvolution("breeze", 5, 50, 100)
        eq(result.ok, true, "ok")
        eq(result.consumeCopies, 5, "copies")
        eq(result.consumeCoins, 50, "coins")
        eq(result.resultSpecies, "cirrus", "result")
        eq(Catalog[result.resultSpecies] ~= nil, true, "result exists")
    end)

    test("evolution rejects insufficient copies coins or xp", function()
        eq(Rules.proposeEvolution("breeze", 4, 50, 100).reason, "insufficient_copies", "copies")
        eq(Rules.proposeEvolution("breeze", 5, 49, 100).reason, "insufficient_coins", "coins")
        eq(Rules.proposeEvolution("breeze", 5, 50, 99).reason, "insufficient_xp", "xp")
    end)

    test("unknown species or broken path is rejected", function()
        eq(Rules.proposeEvolution("nonexistent", 10, 1000, 1000).reason, "invalid_path", "unknown")
        eq(Rules.canEvolve("breeze", 5, 50, 100), true, "can")
    end)

    test("all registered paths point to real catalog species", function()
        for from, path in pairs(Rules.Paths) do
            eq(Catalog[from] ~= nil, true, from .. " base exists")
            eq(Catalog[path.into] ~= nil, true, path.into .. " result exists")
            eq(path.minCopies > 0 and path.coinCost > 0 and path.xpRequired > 0, true, "positive thresholds")
        end
    end)
end
