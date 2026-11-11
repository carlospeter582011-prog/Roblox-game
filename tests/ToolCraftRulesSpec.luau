local Rules = require("../src/shared/ToolCraftRules")
local Tools = require("../src/shared/CatchToolCatalog")
local function profile()
    return { captures = 50, coins = 500, ownedTools = {starter_net = true}, species = {breeze = 5, drizzle = 4, mist = 2, cirrus = 2, sunbeam = 3, thunder = 2} }
end
return function(test, eq)
    test("tool crafting consumes duplicates and Coins atomically", function()
        local p = profile()
        local ok = Rules.craft(p, "wind_lasso", Tools)
        eq(ok, true, "craft succeeds")
        eq(p.species.breeze, 3, "two consumed")
        eq(p.coins, 480, "cost paid")
        eq(p.ownedTools.wind_lasso, true, "tool unlocked")
        eq(Rules.craft(p, "wind_lasso", Tools), false, "cannot repeat")
    end)
    test("tool crafting rejects missing duplicates without mutation", function()
        local p = profile()
        p.species.breeze = 2
        eq(Rules.craft(p, "wind_lasso", Tools), false, "keep final copy")
        eq(p.species.breeze, 2, "no partial species change")
        eq(p.coins, 500, "no partial coin change")
        p.species.breeze = 5
        p.coins = 0
        eq(Rules.craft(p, "wind_lasso", Tools), false, "insufficient coins")
        eq(p.species.breeze, 5, "species intact")
    end)
    test("tool crafting cannot bypass capture unlock or unknown recipe", function()
        local p = profile()
        p.captures = 0
        eq(Rules.craft(p, "wind_lasso", Tools), false, "capture gate")
        eq(Rules.craft(p, "archon_net", Tools), false, "unlisted recipe")
        eq(Rules.craft(p, "not_real", Tools), false, "unknown tool")
    end)
end
