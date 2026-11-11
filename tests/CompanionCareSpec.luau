return function(test, eq)
    local Rules = require("../src/shared/CompanionCareRules")
    local catalog = { breeze = { element = "Air" } }
    local function profile() return { coins = 100, companionSpecies = "breeze",
        species = { breeze = 1 }, companionBond = { breeze = 9 } } end
    test("care spends coins and raises owned companion bond", function()
        local p = profile()
        local t = Rules.preview(p, catalog, 1000, nil)
        eq(t.coins, 70, "cost")
        eq(t.bond, 14, "gain")
        eq(p.coins, 100, "preview immutable")
        eq(Rules.apply(p, t), true, "applied")
        eq(p.coins, 70, "deducted")
        eq(p.companionBond.breeze, 14, "bond persisted in profile")
    end)
    test("care refuses cooldown and clock rollback", function()
        local p = profile()
        eq(select(2, Rules.preview(p, catalog, 1089, 1000)), "cooldown", "too soon")
        eq(select(2, Rules.preview(p, catalog, 999, 1000)), "cooldown", "clock rollback")
        eq(Rules.preview(p, catalog, 1090, 1000) ~= nil, true, "ready")
    end)
    test("care refuses unowned, insufficient coins and invalid balances", function()
        local p = profile()
        p.species.breeze = 0
        eq(select(2, Rules.preview(p, catalog, 1000)), "companion", "not owned")
        p.species.breeze = 1
        p.coins = 29
        eq(select(2, Rules.preview(p, catalog, 1000)), "coins", "poor")
        p.coins = math.huge
        eq(select(2, Rules.preview(p, catalog, 1000)), "coins", "infinite")
        p.coins = 100
        p.companionBond.breeze = Rules.MAX_BOND
        eq(select(2, Rules.preview(p, catalog, 1000)), "max_bond", "capped")
    end)
end
