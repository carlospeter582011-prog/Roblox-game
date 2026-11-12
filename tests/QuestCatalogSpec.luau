-- Integrity checks for QuestCatalog against CloudCatalog.
return function(test, eq)
    local Quests = require("../src/shared/QuestCatalog")
    local Catalog = require("../src/shared/CloudCatalog")

    test("all quests have unique ids matching keys and valid structure", function()
        local seen = {}
        local count = 0
        for key, quest in pairs(Quests) do
            count += 1
            eq(type(quest.id), "string", "id is string")
            eq(quest.id, key, "id matches key")
            eq(seen[quest.id], nil, "unique id")
            seen[quest.id] = true
            eq(type(quest.title), "string", "title")
            eq(#quest.title > 0, true, "non-empty title")
            eq(type(quest.description), "string", "description")
            eq(quest.rewardCoins > 0, true, "positive coins")
            eq(quest.rewardXP > 0, true, "positive xp")
            eq(type(quest.chapter), "number", "chapter number")
            eq(quest.chapter >= 1 and quest.chapter <= 5, true, "chapter in range")
            eq(type(quest.required), "number", "required number")
            eq(quest.required >= 1, true, "required at least 1")
            if quest.objective == "catch_species" then
                eq(type(quest.speciesId), "string", "speciesId string")
                eq(Catalog[quest.speciesId] ~= nil, true, "species exists in catalog: " .. quest.speciesId)
            elseif quest.objective == "total_catches" then
                eq(quest.speciesId, nil, "no species for total")
            else
                error("unknown objective: " .. tostring(quest.objective))
            end
        end
        eq(count >= 50, true, "at least 50 quests toward 100+ target")
    end)
end
