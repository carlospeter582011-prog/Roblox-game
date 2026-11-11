return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local species = require("../src/shared/CloudCatalog")
    test("expedition quest roster contains 70 distinct reachable objectives", function()
        local count = 0
        for id, quest in pairs(quests) do
            if string.sub(id, 1, 11) == "expedition_" then
                count += 1
                eq(quest.id, id, "stable quest id")
                eq(quest.objective, "catch_species", "supported server objective")
                eq(species[quest.speciesId] ~= nil, true, "real catchable species")
                eq(quest.required == 3 or quest.required == 12, true, "tier")
                eq(quest.rewardCoins > 0 and quest.rewardXP > 0, true, "meaningful reward")
            end
        end
        eq(count, 70, "new quests")
    end)
    test("quest expansion preserves existing storyline and progression", function()
        eq(quests.first_breeze.required, 1, "original quest")
        eq(quests.three_hundred_total.required, 300, "existing endgame quest")
        eq(quests.expedition_breeze_1.required, 3, "discovery tier")
        eq(quests.expedition_breeze_2.required, 12, "mastery tier")
    end)
end
