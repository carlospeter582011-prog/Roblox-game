-- Catalog-backed, server-awarded field journal regression checks.
return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local species = require("../src/shared/CloudCatalog")
    local CatchRules = require("../src/shared/CatchRules")
    test("100+ unique playable quests reference valid species and bounded rewards", function()
        local count = 0
        for id, quest in pairs(quests) do
            count += 1
            eq(quest.id, id, "stable quest id")
            assert(quest.objective == "catch_species" or quest.objective == "total_catches")
            if quest.objective == "catch_species" then assert(species[quest.speciesId] ~= nil, id) end
            assert(type(quest.required) == "number" and quest.required > 0 and quest.required % 1 == 0)
            assert(type(quest.rewardCoins) == "number" and quest.rewardCoins >= 0 and quest.rewardCoins <= 10000)
            assert(type(quest.rewardXP) == "number" and quest.rewardXP >= 0 and quest.rewardXP <= 10000)
        end
        assert(count >= 100, "expected at least 100 integrated quests, got " .. count)
    end)
    test("field journal tiers award once and mutated catches advance base species", function()
        local data = {species = {}, captures = 0, coins = 0, xp = 0, quests = {}}
        local subset = { journey_breeze_2 = quests.journey_breeze_2 }
        CatchRules.applyCatch(data, "breeze", 0, subset, {variantId = "breeze:golden"})
        eq(data.quests.journey_breeze_2, nil, "not yet reached")
        CatchRules.applyCatch(data, "breeze", 0, subset)
        eq(data.quests.journey_breeze_2, true, "tier completed")
        local rewarded = data.coins
        CatchRules.applyCatch(data, "breeze", 0, subset)
        eq(data.coins, rewarded, "no duplicate reward")
    end)
end
