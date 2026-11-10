-- Expedition contracts are real persistent quests, not UI-only entries.
return function(test, eq)
    local Quests = require("../src/shared/QuestCatalog")
    local Species = require("../src/shared/CloudCatalog")
    local Rules = require("../src/shared/CatchRules")

    test("expedition contracts raise quest catalog above 100 valid playable entries", function()
        local count, expeditionCount = 0, 0
        for id, quest in pairs(Quests) do
            count += 1
            eq(quest.id, id, "stable quest id")
            eq(type(quest.rewardCoins), "number", "coin reward")
            eq(type(quest.rewardXP), "number", "xp reward")
            if quest.objective == "catch_species" then
                eq(Species[quest.speciesId] ~= nil, true, "spawnable species exists")
            else
                eq(quest.objective, "total_catches", "supported objective")
            end
            if string.sub(id, 1, 11) == "expedition_" then
                expeditionCount += 1
                eq(quest.objective, "catch_species", "expedition objective")
                eq(quest.required == 4 or quest.required == 12, true, "tier threshold")
            end
        end
        eq(expeditionCount, 72, "new expedition quests")
        eq(count >= 100, true, "100+ quests available")
    end)

    test("expedition completion pays once and is safe across rejoin-like catch state", function()
        local quest = Quests.expedition_breeze_4
        local data = { species = {}, captures = 0, coins = 0, xp = 0, quests = {} }
        local onlyQuest = { [quest.id] = quest }
        for _ = 1, 4 do
            Rules.applyCatch(data, "breeze", 10, onlyQuest)
        end
        eq(data.quests[quest.id], true, "completion stored")
        eq(data.coins, 40 + quest.rewardCoins, "coins awarded once")
        eq(data.xp, 40 + quest.rewardXP, "xp awarded once")
        Rules.applyCatch(data, "breeze", 10, onlyQuest)
        eq(data.coins, 50 + quest.rewardCoins, "no second payout")
        eq(data.xp, 50 + quest.rewardXP, "no second xp payout")
    end)
end
