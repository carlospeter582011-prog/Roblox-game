return function(test, eq)
    local Rules = require("../src/shared/ElementDiscoveryRules")
    local catalog = {
        breeze = { element = "Air" }, cirrus = { element = "Air" },
        drizzle = { element = "Water" }, ember = { element = "Fire" },
    }
    test("first elemental catch awards only once per family", function()
        local owned = {}
        local coins, xp = Rules.firstElementReward("breeze", owned, catalog)
        eq(coins, 35, "first coins")
        eq(xp, 20, "first xp")
        owned.breeze = 1
        eq(select(1, Rules.firstElementReward("breeze", owned, catalog)), 0, "same species")
        eq(select(2, Rules.firstElementReward("cirrus", owned, catalog)), 0, "same element")
        eq(select(1, Rules.firstElementReward("drizzle", owned, catalog)), 35, "different element")
    end)
    test("element discovery rejects invalid and fabricated collection entries", function()
        eq(select(1, Rules.firstElementReward("unknown", {}, catalog)), 0, "unknown species")
        eq(select(1, Rules.firstElementReward("breeze", nil, catalog)), 0, "no profile")
        eq(select(1, Rules.firstElementReward("breeze", {breeze=1}, catalog)), 0, "already owned")
        eq(select(1, Rules.firstElementReward("breeze", {breeze=math.huge}, catalog)), 35, "infinite ignored")
        eq(select(1, Rules.firstElementReward("breeze", {breeze=0/0}, catalog)), 35, "nan ignored")
        eq(select(1, Rules.firstElementReward("breeze", {bogus=100}, catalog)), 35, "bogus ignored")
    end)
end
