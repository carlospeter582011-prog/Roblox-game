-- Discovery contracts are real CatchRules objectives, not data-only achievements.
return function(test, eq)
    local Catalog = require("../src/shared/CloudCatalog")
    local Quests = require("../src/shared/QuestCatalog")
    local CatchRules = require("../src/shared/CatchRules")
    test("every cloud species has one valid persistent discovery quest", function()
        local total, discovered = 0, 0
        for speciesId in pairs(Catalog) do
            total += 1
            local quest = Quests["discover_" .. speciesId]
            eq(type(quest), "table", "missing discovery quest " .. speciesId)
            eq(quest.objective, "catch_species", "objective")
            eq(quest.speciesId, speciesId, "species")
            eq(quest.required, 1, "first catch")
            eq(quest.rewardCoins > 0 and quest.rewardXP > 0, true, "rewards")
        end
        for id, quest in pairs(Quests) do
            if id:sub(1, 9) == "discover_" then
                discovered += 1
                eq(Catalog[quest.speciesId] ~= nil, true, "unknown species")
            end
        end
        eq(discovered, total, "one quest per species")
        eq(total >= 60, true, "discovery coverage")
    end)
    test("discovery quest pays once on first capture", function()
        local data = { coins = 0, xp = 0, captures = 0, species = {}, quests = {} }
        local first = CatchRules.applyCatch(data, "breeze", 10, Quests)
        eq(data.quests.discover_breeze, true, "discovery completed")
        local coins = data.coins
        CatchRules.applyCatch(data, "breeze", 10, Quests)
        eq(data.coins, coins + 10, "second catch does not pay discovery again")
    end)
end
