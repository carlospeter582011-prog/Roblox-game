-- Catalog regression: all research milestones are valid, distinct and persisted by existing quest flow.
return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local species = require("../src/shared/CloudCatalog")
    test("quest catalog contains 100+ valid persistent objectives", function()
        local count, research = 0, 0
        for id, quest in pairs(quests) do
            count += 1
            eq(quest.id, id, "stable quest id")
            if quest.objective == "catch_species" then
                eq(species[quest.speciesId] ~= nil, true, "known species: " .. id)
            else
                eq(quest.objective, "total_catches", "supported objective")
            end
            eq(type(quest.required), "number", "required numeric")
            eq(quest.required >= 1 and quest.required == math.floor(quest.required), true, "positive integer goal")
            eq(quest.rewardCoins >= 0 and quest.rewardXP >= 0, true, "nonnegative reward")
            if string.sub(id, 1, 6) == "field_" then
                research += 1
                eq(quest.objective, "catch_species", "research catch objective")
                eq(id, "field_" .. quest.speciesId, "research ID tracks species")
            end
        end
        eq(count >= 100, true, "100+ quest entries")
        eq(research >= 66, true, "66+ field research milestones")
    end)
    test("field journal quest cannot pay twice", function()
        local CatchRules = require("../src/shared/CatchRules")
        local quest = quests.field_pebbleflow
        eq(quest ~= nil, true, "known field quest")
        -- Isolate the milestone under test: the full catalog can legitimately award\n        -- another quest on the next catch, which is not a duplicate payout.\n        local onlyThisQuest = { [quest.id] = quest }\n        local data = { coins = 0, xp = 0, captures = 0, species = {}, quests = {} }
        for _ = 1, quest.required do
            CatchRules.applyCatch(data, quest.speciesId, 0, onlyThisQuest)
        end
        eq(data.quests[quest.id], true, "field quest completed at required threshold")
        local coins = data.coins
        CatchRules.applyCatch(data, quest.speciesId, 0, onlyThisQuest)
        eq(data.coins, coins, "repeat catch does not repay quest")
    end)
end
