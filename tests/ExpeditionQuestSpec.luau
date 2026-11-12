-- Catalog regression: new quests are real CatchRules objectives with valid species and bounded rewards.
return function(test, eq)
    local quests = require("../src/shared/QuestCatalog")
    local clouds = require("../src/shared/CloudCatalog")
    local CatchRules = require("../src/shared/CatchRules")
    test("expedition quests have unique valid catch objectives and fair rewards", function()
        local count = 0
        for id, quest in pairs(quests) do
            eq(quest.id, id, "stable quest ID")
            if string.sub(id, 1, 11) == "expedition_" then
                count += 1
                assert(quest.objective == "catch_species" or quest.objective == "total_catches")
                assert(type(quest.required) == "number" and quest.required > 0 and quest.required == math.floor(quest.required))
                assert(type(quest.rewardCoins) == "number" and quest.rewardCoins > 0 and quest.rewardCoins <= 4000)
                assert(type(quest.rewardXP) == "number" and quest.rewardXP > 0 and quest.rewardXP <= 2000)
                assert(quest.chapter >= 1 and quest.chapter <= 5)
                if quest.objective == "catch_species" then
                    assert(clouds[quest.speciesId] ~= nil, "unknown species " .. tostring(quest.speciesId))
                else
                    eq(quest.speciesId, nil, "total catch has no species")
                end
            end
        end
        eq(count, 28, "new integrated quest count")
    end)
    test("expedition quest completion pays once and persists completion flag", function()
        local data = { captures = 14, species = { hush = 2 }, quests = {}, coins = 0, xp = 0 }
        -- CatchRules is the existing production reward path; test it rather than a duplicate implementation.
        local completed = CatchRules.applyCatch(data, "hush", 10, quests)
        eq(data.captures, 15, "capture updated")
        eq(data.species.hush, 3, "species updated")
        eq(data.quests.expedition_hush, true, "species quest completed")
        eq(data.quests.expedition_total_15, true, "total quest completed")
        local prior = data.coins
        CatchRules.applyCatch(data, "hush", 10, quests)
        eq(data.coins, prior + 10, "no duplicate quest rewards")
        assert(type(completed) == "table")
    end)
end
