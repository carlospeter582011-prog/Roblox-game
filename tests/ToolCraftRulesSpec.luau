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
    test("advanced tool recipes require rare spare clouds and preserve the last copy", function()
        local p = profile()
        p.captures = 300
        p.coins = 2000
        p.species.frost = 3
        p.species.hail = 3
        eq(Rules.craft(p, "frost_trap", Tools), true, "frost craft succeeds")
        eq(p.species.frost, 1, "last frost remains")
        eq(p.species.hail, 1, "last hail remains")
        eq(p.coins, 1520, "advanced recipe cost")
        eq(p.ownedTools.frost_trap, true, "advanced tool owned")
    end)
    test("nonfinite capture and currency values never grant a craft", function()
        local p = profile()
        p.captures = math.huge
        eq(Rules.craft(p, "wind_lasso", Tools), false, "infinite captures rejected")
        p.captures = 50
        p.coins = math.huge
        eq(Rules.craft(p, "wind_lasso", Tools), false, "infinite currency rejected")
    end)
    test("tool crafting cannot bypass capture unlock or unknown recipe", function()
        local p = profile()
        p.captures = 0
        eq(Rules.craft(p, "wind_lasso", Tools), false, "capture gate")
        eq(Rules.craft(p, "archon_net", Tools), false, "unlisted recipe")
        eq(Rules.craft(p, "not_real", Tools), false, "unknown tool")
    end)
end
