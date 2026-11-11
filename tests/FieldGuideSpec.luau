-- Regression: every cloud has a playable, server-awarded discovery milestone.
return function(test, eq)
    local Catalog = require("../src/shared/CloudCatalog")
    local Quests = require("../src/shared/QuestCatalog")
    local Rules = require("../src/shared/CatchRules")
    test("field guide quests cover every species with valid bounded rewards", function()
        local speciesCount, questCount = 0, 0
        for id in pairs(Catalog) do
            speciesCount += 1
            local q = Quests["discover_" .. id]
            eq(q ~= nil, true, "missing discovery " .. id)
            eq(q.speciesId, id, "species binding")
            eq(q.required, 1, "discovery requirement")
        end
        for id, q in pairs(Quests) do
            questCount += 1
            eq(q.id, id, "stable quest id")
            eq(q.rewardCoins > 0 and q.rewardCoins <= 10000, true, "coin budget")
            eq(q.rewardXP > 0 and q.rewardXP <= 5000, true, "XP budget")
            if q.objective == "catch_species" then
                eq(Catalog[q.speciesId] ~= nil, true, "missing catalog species")
            end
        end
        eq(speciesCount >= 86, true, "species coverage")
        eq(questCount >= 100, true, "quest milestone")
    end)
    test("discovery and mastery pay exactly once and persist in quest flags", function()
        local data = { species = {}, captures = 0, coins = 0, xp = 0, quests = {} }
        local selected = {
            discover_breeze = Quests.discover_breeze,
            master_breeze = Quests.master_breeze,
        }
        Rules.applyCatch(data, "breeze", 0, selected)
        eq(data.quests.discover_breeze, true, "discovered")
        eq(data.quests.master_breeze, nil, "mastery not early")
        local firstReward = data.coins
        for _ = 1, 9 do
            Rules.applyCatch(data, "breeze", 0, selected)
        end
        eq(data.quests.master_breeze, true, "mastered")
        local masteredReward = data.coins
        Rules.applyCatch(data, "breeze", 0, selected)
        eq(data.coins, masteredReward, "no duplicate reward")
        eq(firstReward > 0, true, "discovery reward")
        eq(masteredReward > firstReward, true, "mastery reward")
    end)
end
