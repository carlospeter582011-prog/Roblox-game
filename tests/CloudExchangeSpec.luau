return function(test, eq)
    local Rules = require("../src/shared/CloudExchangeRules")
    local catalog = { breeze = {rarity = "Common"}, storm = {rarity = "Rare"} }
    test("exchange consumes one duplicate, preserves collection and grants coins", function()
        local data = { species = {breeze = 3, storm = 1}, coins = 10 }
        local ok, id, rate, left = Rules.apply(data, catalog)
        eq(ok, true, "success")
        eq(id, "breeze", "species")
        eq(rate, 12, "rate")
        eq(left, 2, "remaining")
        eq(data.coins, 22, "coins")
        Rules.apply(data, catalog)
        eq(data.species.breeze, 1, "last copy preserved")
        eq(Rules.apply(data, catalog), false, "no more duplicates")
    end)
    test("exchange rejects invalid counts and forged species", function()
        local data = {species = {fake = 99, breeze = math.huge, storm = 1}, coins = 0}
        eq(Rules.apply(data, catalog), false, "invalid inventory")
        eq(data.coins, 0, "no reward")
    end)
    test("exchange refuses wallet overflow without consuming cloud", function()
        local data = {species = {storm = 2}, coins = 999999999}
        eq(Rules.apply(data, catalog), false, "wallet full")
        eq(data.species.storm, 2, "inventory intact")
    end)
end
