-- Regression tests for EvolutionRules.
return function(test, eq)
    local Rules = require("../src/shared/EvolutionRules")

    test("cannot evolve with insufficient count or coins", function()
        eq(Rules.canEvolve("breeze", 4, 200), false, "count")
        eq(Rules.canEvolve("breeze", 5, 50), false, "coins")
        eq(Rules.canEvolve("breeze_evolved", 5, 200), false, "already evolved")
        eq(Rules.canEvolve("", 5, 200), false, "empty id")
    end)

    test("successful evolve spends resources and awards form", function()
        local data = { coins = 150, species = { breeze = 6 }, xp = 0 }
        eq(Rules.applyEvolve(data, "breeze"), true, "success")
        eq(data.coins, 50, "coins spent")
        eq(data.species.breeze, 5, "base reduced")
        eq(data.species.breeze_evolved, 1, "evolved awarded")
        eq(data.xp, 50, "xp awarded")
    end)

    test("failed evolve leaves data unchanged", function()
        local data = { coins = 50, species = { breeze = 3 }, xp = 10 }
        eq(Rules.applyEvolve(data, "breeze"), false, "fail")
        eq(data.coins, 50, "unchanged")
        eq(data.species.breeze, 3, "unchanged")
        eq(data.xp, 10, "unchanged")
    end)
end
