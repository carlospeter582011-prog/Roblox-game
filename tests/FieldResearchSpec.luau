-- Field journal quests are real persistent catch objectives, not data-only milestones.
return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local catalog = require("../src/shared/CloudCatalog")
    local rules = require("../src/shared/CatchRules")
    test("field journal provides 100+ distinct integrated quests", function()
        local count, research = 0, 0
        for id, quest in pairs(quests) do
            count += 1
            eq(id, quest.id, "stable quest id")
            if quest.objective == "catch_species" then
                eq(catalog[quest.speciesId] ~= nil, true, "valid species " .. id)
            end
            if string.sub(id, 1, 6) == "field_" then
                research += 1
                eq(quest.objective, "catch_species", "field objective")
                eq(quest.rewardCoins > 0 and quest.rewardCoins <= 120, true, "bounded coins")
                eq(quest.rewardXP > 0 and quest.rewardXP <= 60, true, "bounded XP")
            end
        end
        eq(research, 63, "research objectives")
        eq(count >= 100, true, "launch quest count")
    end)
    test("field research pays once, tracks species and survives ledger replay", function()
        local q = { field_twilight_observe = quests.field_twilight_observe }
        local data = { species = {}, captures = 0, coins = 0, xp = 0, quests = {} }
        local first = rules.applyCatch(data, "twilight", 10, q)
        eq(#first, 0, "one twilight is insufficient")
        local second = rules.applyCatch(data, "twilight", 10, q)
        eq(#second, 1, "second twilight completes quest")
        eq(data.coins, 50, "two catches and one 30-coin reward")
        eq(data.xp, 35, "two catches and one 15-XP reward")
        rules.applyCatch(data, "twilight", 10, q)
        eq(data.coins, 60, "no repeat reward")
        eq(data.quests.field_twilight_observe, true, "persistent completion ledger")
        rules.applyCatch(data, "breeze", 10, q)
        eq(data.coins, 70, "unrelated species never repeats reward")
    end)
end
