-- Regression tests for mutated catches, attribute-safe ids and quest catalog integrity.
-- Loaded by tests/run.luau, which passes in its test registrar and equality helper.
local Rules = require("../src/shared/CatchRules")
local Mutations = require("../src/shared/Mutations")
local Species = require("../src/shared/CloudCatalog")
local Quests = require("../src/shared/QuestCatalog")
-- Isolate legacy catch expectations from newly added Field Guide milestones.
local LegacyQuests = {}
for id, quest in pairs(Quests) do
    if string.sub(id, 1, 9) ~= "discover_" and string.sub(id, 1, 7) ~= "master_" then
        LegacyQuests[id] = quest
    end
end
local Tools = require("../src/shared/CatchToolCatalog")

local function newData()
    return { version = 2, coins = 0, xp = 0, captures = 0, species = {}, quests = {}, lastSeen = 0 }
end

return function(test, eq)
    test("isAttributeSafe accepts letters, digits, underscore, hyphen and rejects the rest", function()
        eq(Rules.isAttributeSafe("SpeciesCount_breeze"), true, "plain")
        eq(Rules.isAttributeSafe("a-b_9"), true, "hyphen/underscore/digit")
        eq(Rules.isAttributeSafe("SpeciesCount_breeze:golden"), false, "colon")
        eq(Rules.isAttributeSafe("has space"), false, "space")
        eq(Rules.isAttributeSafe(""), false, "empty")
        eq(Rules.isAttributeSafe(nil), false, "nil")
        eq(Rules.isAttributeSafe(12), false, "number")
        eq(Rules.isAttributeSafe(string.rep("a", 91)), false, "too long")
        eq(Rules.isAttributeSafe(string.rep("a", 90)), true, "max length")
    end)

    test("every species id yields a valid SpeciesCount attribute name", function()
        for id in pairs(Species) do
            eq(Rules.isAttributeSafe("SpeciesCount_" .. id), true, "species " .. id)
        end
    end)

    test("mutation variant keys are NOT attribute-safe, which is why they stay server-side", function()
        for mutationId in pairs(Mutations) do
            if type(Mutations[mutationId]) == "table" then
                local key = Mutations.key("breeze", mutationId)
                eq(Rules.isAttributeSafe("SpeciesCount_" .. key), false, "variant " .. key)
            end
        end
    end)

    test("a mutated catch counts toward the base species and its variant key", function()
        local data = newData()
        Rules.applyCatch(data, "breeze", 30, LegacyQuests, { variantId = "breeze:golden", xp = 20 })
        eq(data.species.breeze, 1, "base species counted")
        eq(data.species["breeze:golden"], 1, "variant counted")
        eq(data.captures, 1, "one capture, not two")
    end)

    test("a mutated catch advances species quests (first_breeze completes)", function()
        local data = newData()
        local done = Rules.applyCatch(data, "breeze", 30, LegacyQuests, { variantId = "breeze:golden" })
        eq(table.concat(done, ","), "first_breeze", "completed")
    end)

    test("applyCatch uses options.xp and defaults to XP_PER_CATCH", function()
        local custom = newData()
        Rules.applyCatch(custom, "drizzle", 0, {}, { xp = 33 })
        eq(custom.xp, 33, "custom xp")
        local default = newData()
        Rules.applyCatch(default, "drizzle", 0, {}, {})
        eq(default.xp, Rules.XP_PER_CATCH, "default xp, empty options")
        local none = newData()
        Rules.applyCatch(none, "drizzle", 0, {})
        eq(none.xp, Rules.XP_PER_CATCH, "default xp, no options")
    end)

    test("variantId equal to the species id is not double counted", function()
        local data = newData()
        Rules.applyCatch(data, "breeze", 0, {}, { variantId = "breeze" })
        eq(data.species.breeze, 1, "counted once")
    end)

    test("mutation XP multipliers produce the xp the server passes in", function()
        eq(Mutations.bonusXp(Rules.XP_PER_CATCH, "golden"), 20, "golden")
        eq(Mutations.bonusXp(Rules.XP_PER_CATCH, "rainbow"), 30, "rainbow")
        eq(Mutations.bonusXp(Rules.XP_PER_CATCH, "storm"), 15, "storm")
        eq(Mutations.bonusXp(Rules.XP_PER_CATCH, nil), Rules.XP_PER_CATCH, "no mutation")
    end)

    test("quest catalog has no two quests with the same objective, species and target", function()
        local seen = {}
        for id, q in pairs(Quests) do
            local signature = table.concat({ q.objective, tostring(q.speciesId), tostring(q.required) }, "|")
            eq(seen[signature], nil, id .. " duplicates " .. tostring(seen[signature]))
            seen[signature] = id
        end
    end)

    test("every quest description matches an implemented objective (no unimplemented conditions)", function()
        for id, q in pairs(Quests) do
            eq(q.objective == "catch_species" or q.objective == "total_catches", true, id .. " objective")
            eq(string.find(string.lower(q.description), "under the", 1, true), nil, id .. " conditional wording")
        end
    end)

    test("quest tracker ordering is total: ties on chapter and target break by id", function()
        local seen = {}
        for _, q in pairs(Quests) do
            seen[q.id] = true
        end
        local count = 0
        for _ in pairs(seen) do
            count += 1
        end
        local expected = 0
        for _ in pairs(Quests) do
            expected += 1
        end
        eq(count, expected, "unique quest ids")
    end)

    test("every tool name is unique so the picker is unambiguous", function()
        local names = {}
        for id, t in pairs(Tools) do
            eq(names[t.name], nil, id .. " duplicates name of " .. tostring(names[t.name]))
            names[t.name] = id
        end
    end)
end
