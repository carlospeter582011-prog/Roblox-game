return function(test, eq)
    local R = require("../src/shared/BondAcademyRules")
    local catalog = { breeze = { name = "Breeze" } }
    local function data(points, coins)
        return { companionSpecies = "breeze", species = { breeze = 1 },
            companionBond = { breeze = points }, coins = coins }
    end
    test("bond academy validates ownership, distance and profile", function()
        eq(select(1, R.evaluate(data(10, 100), catalog, 5, true)), true, "valid")
        eq(select(1, R.evaluate(data(10, 100), catalog, 20, true)), false, "remote")
        eq(select(1, R.evaluate(data(10, 100), catalog, 5, false)), false, "not loaded")
        local unowned = data(10, 100)
        unowned.species.breeze = 0
        eq(select(1, R.evaluate(unowned, catalog, 5, true)), false, "unowned")
        eq(select(1, R.evaluate(data(10, 74), catalog, 5, true)), false, "insufficient coins")
    end)
    test("bond academy clamps progress and prevents unlimited training", function()
        local ok, id, points = R.evaluate(data(98, 100), catalog, 5, true)
        eq(ok, true, "eligible")
        eq(id, "breeze", "server selected companion")
        eq(points, 100, "capped bond")
        eq(select(1, R.evaluate(data(100, 1000), catalog, 5, true)), false, "max bond")
        eq(select(1, R.evaluate(data(math.huge, 100), catalog, 5, true)), false, "corrupt bond")
    end)
end
