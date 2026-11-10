return function(test, eq)
    local Rules = require("../src/shared/CatchRules")
    local Quests = require("../src/shared/QuestCatalog")
    test("sky survey quests have distinct thresholds and bounded rewards", function()
        local seen = {}
        for i = 1, 12 do
            local q = Quests["survey_" .. tostring(i * 5)]
            eq(q.objective, "unique_species", "objective")
            eq(q.required, i * 5, "threshold")
            eq(q.rewardCoins > 0 and q.rewardXP > 0, true, "rewards")
            eq(seen[q.required], nil, "unique threshold")
            seen[q.required] = true
        end
    end)
    test("unique survey excludes mutated variants and invalid counts", function()
        local data = {captures = 200, species = {breeze = 3, ["breeze:golden"] = 20, drizzle = 1, mist = 0, void = math.huge}}
        eq(Rules.questProgress({objective = "unique_species"}, data), 2, "unique base species")
        eq(Rules.questProgress({objective = "total_catches"}, data), 200, "existing catch quests")
        eq(Rules.questProgress({objective = "unknown"}, data), 0, "unknown objective")
    end)
    test("survey quest is paid exactly once as discovery grows", function()
        local q = {survey_5 = Quests.survey_5}
        local data = {species = {breeze = 1, drizzle = 1, mist = 1, thunder = 1}, captures = 4, coins = 0, xp = 0, quests = {}}
        Rules.applyCatch(data, "frost", 10, q)
        eq(data.quests.survey_5, true, "completed")
        local reward = data.coins
        Rules.applyCatch(data, "frost", 10, q)
        eq(data.coins, reward + 10, "no duplicate payout")
        eq(data.captures, 6, "catch count preserved")
    end)
end
