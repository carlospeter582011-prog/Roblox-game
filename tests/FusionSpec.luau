local Rules = require("../src/shared/FusionRules")
return function(test, eq)
    local catalog = { breeze = {}, cirrus = {}, drizzle = {}, mistveil = {} }
    test("fusion spends three duplicates and coins, preserving source companion", function()
        local profile = { coins = 200, species = { breeze = 4, cirrus = 0 } }
        local ok, recipe = Rules.apply(profile, catalog)
        eq(ok, true, "fused")
        eq(recipe.result, "cirrus", "output")
        eq(profile.species.breeze, 1, "source retained")
        eq(profile.species.cirrus, 1, "result granted")
        eq(profile.coins, 125, "cost deducted")
        eq(Rules.apply(profile, catalog), false, "no repeat with one source")
    end)
    test("fusion rejects insufficient duplicates, coins, unknown species and invalid counters", function()
        for _, profile in ipairs({
            { coins = 200, species = { breeze = 3 } },
            { coins = 74, species = { breeze = 4 } },
            { coins = 200, species = { breeze = math.huge } },
            { coins = 200, species = { unknown = 999 } },
            { coins = 0/0, species = { breeze = 4 } },
        }) do
            local before = profile.coins
            eq(Rules.apply(profile, catalog), false, "invalid denied")
            eq(profile.coins ~= profile.coins, before ~= before, "nan untouched")
        end
    end)
    test("fusion deterministic recipe order and fallback to affordable recipe", function()
        local profile = { coins = 100, species = { breeze = 4, drizzle = 4 } }
        eq(Rules.available(profile, catalog).source, "breeze", "first eligible")
        profile.species.breeze = 1
        eq(Rules.available(profile, catalog).source, "drizzle", "next eligible")
    end)
end
