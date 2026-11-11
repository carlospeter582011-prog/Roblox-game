-- Pure Luau regression coverage for expedition quests and idempotent rewards.
local Quests = require("../src/shared/QuestCatalog")
local Catalog = require("../src/shared/CloudCatalog")
local CatchRules = require("../src/shared/CatchRules")
local count = 0
for id, quest in pairs(Quests) do
    count += 1
    assert(id == quest.id, "quest id mismatch: " .. id)
    assert(quest.objective == "total_catches" or (quest.objective == "catch_species" and Catalog[quest.speciesId]), "invalid objective: " .. id)
    assert(quest.required > 0 and quest.rewardCoins >= 0 and quest.rewardXP >= 0, "invalid reward: " .. id)
end
assert(count >= 100, "launch quest catalog must contain 100+ objectives")
local data = { species = {}, captures = 0, coins = 0, xp = 0, quests = {} }
local quest = Quests.expedition_gale_scout
assert(quest and quest.required == 2)
CatchRules.applyCatch(data, "gale", 0, { [quest.id] = quest })
assert(not data.quests[quest.id], "premature expedition completion")
CatchRules.applyCatch(data, "gale", 0, { [quest.id] = quest })
assert(data.quests[quest.id], "expedition not completed")
local awarded = data.coins
CatchRules.applyCatch(data, "gale", 0, { [quest.id] = quest })
assert(data.coins == awarded, "duplicate expedition coin payout")
print("QuestExpeditionsSpec: " .. count .. " catalog quests validated; one-time reward verified")
