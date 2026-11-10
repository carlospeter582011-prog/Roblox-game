-- Discovery quest regression coverage: catalog integrity, persistent completion and no repeat rewards.
return function(test, eq)
    local Catalog = require("../src/shared/CloudCatalog")
    local Quests = require("../src/shared/QuestCatalog")
    local Catch = require("../src/shared/CatchRules")

    test("all species have stable discovery contracts and at least 100 total quests", function()
        local count = 0
        for id, species in pairs(Catalog) do
            local quest = Quests["discover_" .. id]
            if quest == nil then
                for _, authored in pairs(Quests) do
                    if authored.objective == "catch_species" and authored.speciesId == id and authored.required == 1 then
                        quest = authored
                        break
                    end
                end
            end
            eq(quest ~= nil, true, "missing discovery quest " .. id)
            eq(quest.speciesId, id, "species mapping")
            eq(quest.objective, "catch_species", "objective")
            eq(quest.required, 1, "first discovery threshold")
            eq(quest.rewardCoins > 0 and quest.rewardXP > 0, true, "positive reward")
        end
        for _ in pairs(Quests) do count += 1 end
        eq(count >= 100, true, "100+ real quest contracts")
    end)

    test("discovery quest rewards exactly once across subsequent catches", function()
        local id = "cirrus"
        local data = { species = {}, quests = {}, captures = 0, coins = 0, xp = 0 }
        local q = { ["discover_" .. id] = Quests["discover_" .. id] }
        local first = Catch.applyCatch(data, id, 10, q)
        eq(#first, 1, "first catch completes discovery")
        local after = data.coins
        local second = Catch.applyCatch(data, id, 10, q)
        eq(#second, 0, "no duplicate completion")
        eq(data.coins, after + 10, "no repeated quest coins")
    end)

    test("discovery progress survives sanitized profile rejoin", function()
        local Core = require("../src/server/ProfileCore")
        local data = { species = { cirrus = 1 }, quests = { discover_cirrus = true } }
        local clean = Core.sanitize(data, { discover_cirrus = true }, 100)
        eq(clean.quests.discover_cirrus, true, "discovery persisted")
        eq(clean.species.cirrus, 1, "species persisted")
    end)
end
