local Rules = require("../src/shared/RelicCraftRules")
return function(test, eq)
    test("relic forge checks discoveries, coins and spends once", function()
        local data = { coins = 1000, crystals = { [1]=true, [2]=true } }
        eq(Rules.craft(data, "lantern"), false, "insufficient crystals")
        data.crystals[3] = true
        eq(Rules.craft(data, "lantern"), true, "crafted")
        eq(data.coins, 800, "charged")
        eq(Rules.craft(data, "lantern"), false, "no duplicate")
        eq(data.coins, 800, "no double charge")
        eq(Rules.catchXpBonus(data, 39), 1, "bonus")
    end)
    test("relic forge rejects unknown and invalid currency", function()
        local d = { coins = math.huge, crystals = {} }
        eq(Rules.craft(d, "lantern"), false, "infinite coins")
        eq(Rules.craft({ coins = 9999 }, "unknown"), false, "unknown")
        eq(Rules.craft({ coins = 0/0 }, "lantern"), false, "nan")
    end)
    test("relic upgrades require individual purchases", function()
        local d = { coins = 2000, crystals = {} }
        for i = 1, 12 do d.crystals[i] = true end
        eq(Rules.craft(d, "charm"), true, "charm")
        eq(Rules.reachBonus(d), 2, "reach")
        eq(Rules.catchCoinBonus(d, 100), 0, "no compass")
        eq(Rules.craft(d, "compass"), true, "compass")
        eq(Rules.catchCoinBonus(d, 100), 10, "coin bonus")
        eq(d.coins, 850, "both costs")
    end)
end
