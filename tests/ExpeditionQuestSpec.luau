-- Validate expedition quests against the real catalog and the existing quest schema.
return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local catalog = require("../src/shared/CloudCatalog")
    test("expedition journal defines 20 valid chapter 6-10 quests", function()
        local count = 0
        local chapters = {}
        for id, quest in pairs(quests) do
            if string.sub(id, 1, 11) == "expedition_" then
                count += 1
                eq(quest.id, id, "stable quest id")
                eq(quest.objective, "catch_species", "supported objective")
                eq(type(catalog[quest.speciesId]), "table", "known species")
                eq(type(quest.required), "number", "required type")
                eq(quest.required > 0 and quest.required % 1 == 0, true, "positive integer target")
                eq(quest.rewardCoins > 0 and quest.rewardCoins % 1 == 0, true, "valid coin reward")
                eq(quest.rewardXP > 0 and quest.rewardXP % 1 == 0, true, "valid xp reward")
                eq(quest.chapter >= 6 and quest.chapter <= 10, true, "chapter range")
                chapters[quest.chapter] = (chapters[quest.chapter] or 0) + 1
            end
        end
        eq(count, 20, "new quests")
        for chapter = 6, 10 do
            eq(chapters[chapter], 4, "four quests per chapter")
        end
    end)
    test("expedition rewards and targets stay bounded", function()
        for id, quest in pairs(quests) do
            if string.sub(id, 1, 11) == "expedition_" then
                eq(quest.required <= 8, true, "achievable target")
                eq(quest.rewardCoins <= 5000, true, "coin cap")
                eq(quest.rewardXP <= 2500, true, "xp cap")
            end
        end
    end)
end
