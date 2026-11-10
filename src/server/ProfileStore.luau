-- Server-owned player profile. Persistence rules (session lock, migration, retries) live in
-- ProfileCore and are unit-tested in CI; this module only wires them to Roblox services.
-- DataStore calls may fail in Studio without API access; failures kick the player rather than
-- letting them play on a profile that cannot be saved.
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local questCatalog = require(ReplicatedStorage:WaitForChild("QuestCatalog"))
local ProfileCore = require(script.Parent:WaitForChild("ProfileCore"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))
local toolCatalog = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local CrystalRules = require(ReplicatedStorage:WaitForChild("CrystalRules"))
local CompanionRules = require(ReplicatedStorage:WaitForChild("CompanionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local STORE_NAME = "CatchACloudProfiles_v1" -- v1 flat records are migrated on first load
local LOAD_ATTEMPTS, LOAD_DELAY = 5, 3 -- waits 3+6+9+12s while another server releases the lock
local SAVE_ATTEMPTS, SAVE_DELAY = 4, 2
local AUTOSAVE_SECONDS = 90
local CLOSE_TIMEOUT = 25

local validQuests = {}
for id in pairs(questCatalog) do
    validQuests[id] = true
end

local jobId = game.JobId ~= "" and game.JobId or ("studio-" .. HttpService:GenerateGUID(false))
local repo = ProfileCore.new(DataStoreService:GetDataStore(STORE_NAME), {
    jobId = jobId,
    validQuests = validQuests,
})

local Profile = {}
local sessions = {} -- [player] = data table (nil until loaded, nil again once released/lost)
local saving = {} -- [player] = true while a save is in flight (serialises saves per player)
local observatoryPending = {} -- prevent overlapping reward requests during durable save
local persist -- forward declaration: observatory awards require a durable receipt
local pendingRelease = {} -- [userId] = true while a leaving player's final save runs
local weak = { __mode = "k" }
local leaving = setmetatable({}, weak)
local started = setmetatable({}, weak)

local function keyFor(userId)
    return "player_" .. userId
end

local KICK_MESSAGES = {
    locked = "Your save is still open on another server. Please wait a moment and rejoin.",
    newer_schema = "Your save was written by a newer version of the game. Please rejoin later.",
    error = "Your save could not be loaded. Please rejoin.",
}

function Profile.Get(player)
    return sessions[player]
end

-- options: { variantId = "breeze:golden", xp = number } for mutated catches (see CatchRules).
function Profile.AddCatch(player, speciesId, coins, options)
    local data = sessions[player]
    if not data then
        return false
    end
    -- Server-authoritative elemental companion resonance; reward only the catch XP.
    -- Copy options so caller-owned mutation data is never changed in place.
    local catchOptions = options and table.clone(options) or {}
    local baseXp = catchOptions.xp or CatchRules.XP_PER_CATCH
    local resonance = CompanionRules.resonanceXp(baseXp, data.companionSpecies, speciesId,
        data.species, CloudCatalog, data.companionBond)
    catchOptions.xp = baseXp + resonance
    for _, id in ipairs(CatchRules.applyCatch(data, speciesId, coins, questCatalog, catchOptions)) do
        player:SetAttribute("Quest_" .. id, true)
    end
    if data.companionSpecies == "" then
        data.companionSpecies = speciesId
        player:SetAttribute("CompanionSpecies", speciesId)
    end
    -- Bond only advances for the currently equipped, genuinely owned companion.
    -- Rewards are calculated from the server-authoritative base catch amount.
    local companion = data.companionSpecies
    if CompanionRules.owned(companion, data.species, CloudCatalog) then
        data.companionBond = data.companionBond or {}
        local points = CompanionRules.advanceBond(data.companionBond[companion])
        data.companionBond[companion] = points
        local bonus = CompanionRules.bonusCoins(coins, points)
        data.coins += bonus
        player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(points))
        player:SetAttribute("CompanionBondPoints", points)
    end
    player:SetAttribute("CloudCount", data.captures)
    -- Only attribute-safe ids are replicated; mutation keys contain ":" and stay server-side.
    if CatchRules.isAttributeSafe("SpeciesCount_" .. speciesId) then
        player:SetAttribute("SpeciesCount_" .. speciesId, data.species[speciesId])
    end
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    return true
end

function Profile.DiscoverCrystal(player, index)
    local data = sessions[player]
    if not data or type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > 18 then
        return false
    end
    data.crystals = data.crystals or {}
    if data.crystals[index] then return false end
    local coins, xp = CrystalRules.reward(index, false)
    data.crystals[index] = true
    data.coins += coins
    data.xp += xp
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    local total = 0
    for _, found in pairs(data.crystals) do
        if found then total += 1 end
    end
    player:SetAttribute("SkyCrystalsDiscovered", total)
    player:SetAttribute("LastSkyCrystal", "sky-crystal-" .. index)
    return true
end

-- Reward a completed server-validated boss trial. Only the server passes a catalog id.
-- Rewards use the existing persistent coin/XP fields; no save schema migration.
function Profile.AwardBossTrial(player, bossId)
    local data = sessions[player]
    if not data then return false end
    local BossRules = require(ReplicatedStorage:WaitForChild("BossChallengeRules"))
    local coins, xp = BossRules.reward(bossId)
    if not coins then return false end
    data.bossVictories = data.bossVictories or {}
    local previous = data.bossVictories[bossId] or 0
    data.bossVictories[bossId] = math.min(previous + 1, 1000000)
    data.coins += coins
    data.xp += xp
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    player:SetAttribute("BossWins_" .. bossId, data.bossVictories[bossId])
    player:SetAttribute("BossTrialsWon", (data.bossVictories.meadow or 0) + (data.bossVictories.eastwind or 0) + (data.bossVictories.ridge or 0))
    return true, coins, xp
end

-- Expedition rewards: only trusted server scripts supply observatory ids.
-- Uses the existing profile lock/save pipeline; no new persistent fields.
function Profile.AwardObservatory(player, stationId)
    local data = sessions[player]
    if not data or observatoryPending[player] then return false, "Profile unavailable or reward pending" end
    local Rules = require(ReplicatedStorage:WaitForChild("ObservatoryRules"))
    local coins, xp = Rules.reward(stationId)
    if not coins then return false, "Invalid observatory" end
    local now = os.time()
    data.observatoryCooldowns = data.observatoryCooldowns or {}
    local nextAllowed = data.observatoryCooldowns[stationId] or 0
    if not Rules.canObserve(stationId, data.captures, 0, now, nextAllowed, true) then
        return false, "Observatory recharging or locked"
    end
    observatoryPending[player] = true
    -- Update reward and cooldown together in the same profile record. Do not tell
    -- the client the award succeeded until the locked DataStore write completes.
    data.observatoryCooldowns[stationId] = now + Rules.COOLDOWN
    data.coins += coins
    data.xp += xp
    local saved = persist(player, false)
    observatoryPending[player] = nil
    if not saved then
        -- An uncertain write must never be retried as a fresh reward in this session.
        -- Kick rather than roll back a possibly committed transaction and duplicate it.
        sessions[player] = nil
        player:SetAttribute("ProfileReady", false)
        if player.Parent then player:Kick("Your observatory reward could not be confirmed. Please rejoin.") end
        return false, "Reward save not confirmed"
    end
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    return true, coins, xp
end

function Profile.CycleCompanion(player)
    local data = sessions[player]
    if not data then return false, "Profile unavailable" end
    local nextId = CompanionRules.next(data.companionSpecies, data.species, CloudCatalog)
    if not nextId then return false, "Catch a cloud to unlock a companion!" end
    data.companionSpecies = nextId
    player:SetAttribute("CompanionSpecies", nextId)
    local points = (data.companionBond or {})[nextId] or 0
    player:SetAttribute("CompanionBondPoints", points)
    player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(points))
    return true, "Companion: " .. CloudCatalog[nextId].name
end

function Profile.BuyTool(player, toolId)
    local data = sessions[player]
    local tool = type(toolId) == "string" and toolCatalog[toolId] or nil
    if not data or not tool then return false, "Invalid tool or profile unavailable" end
    data.ownedTools = data.ownedTools or { starter_net = true }
    if data.ownedTools[toolId] then return true, "Already owned" end
    if data.captures < tool.unlockCatches then return false, "Unlock at " .. tool.unlockCatches .. " catches" end
    if data.coins < tool.priceCoins then return false, "Need " .. tool.priceCoins .. " coins" end
    data.coins -= tool.priceCoins
    data.ownedTools[toolId] = true
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("OwnsTool_" .. toolId, true)
    return true, "Purchased " .. tool.name
end

-- Permanent range training: a meaningful, bounded Coin sink unlocked by XP levels.
-- Stored on the existing player profile and saved by the normal session-lock pipeline.
local TRAINING_COSTS = { 100, 250, 500 }
local TRAINING_LEVELS = { 2, 4, 6 }
function Profile.BuyRangeTraining(player)
    local data = sessions[player]
    if not data then return false, "Profile unavailable" end
    local current = math.clamp(math.floor(tonumber(data.rangeTraining) or 0), 0, #TRAINING_COSTS)
    if current >= #TRAINING_COSTS then return false, "Range training maxed!" end
    local nextLevel = current + 1
    local level = Leveling.levelForXp(data.xp)
    if level < TRAINING_LEVELS[nextLevel] then
        return false, "Reach level " .. TRAINING_LEVELS[nextLevel] .. " first"
    end
    local cost = TRAINING_COSTS[nextLevel]
    if data.coins < cost then return false, "Need " .. cost .. " coins" end
    data.coins -= cost
    data.rangeTraining = nextLevel
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("RangeTraining", nextLevel)
    return true, "Range upgraded! +" .. (nextLevel * 2) .. " studs"
end

-- Saves with retries. release = true also frees the session lock and ends the session.
-- Returns true only if the data reached the DataStore.
persist = function(player, release)
    if saving[player] then
        if not release then
            return false -- an autosave is already running
        end
        while saving[player] do
            task.wait(0.1)
        end
    end
    local data = sessions[player]
    if not data then
        return false
    end
    saving[player] = true
    local result = ProfileCore.retry(function()
        return repo:Save(keyFor(player.UserId), data, release)
    end, SAVE_ATTEMPTS, SAVE_DELAY, task.wait, { error = true })
    saving[player] = nil
    if result.ok then
        if release then
            sessions[player] = nil
        end
        return true
    end
    warn("Profile save failed", player.UserId, result.reason, result.detail)
    if result.reason == "lost_lock" then
        -- Another server owns this profile now; stop all writes from here to avoid duplication.
        sessions[player] = nil
        player:SetAttribute("ProfileReady", false)
        if player.Parent then
            player:Kick("Your save was opened on another server. Please rejoin.")
        end
    end
    return false
end

function Profile.Save(player)
    return persist(player, false)
end

local function onPlayerAdded(player)
    if started[player] then
        return
    end
    started[player] = true
    player:SetAttribute("ProfileReady", false)
    while pendingRelease[player.UserId] do
        task.wait(0.2) -- same player rejoining this server: let their final save finish first
    end
    local key = keyFor(player.UserId)
    local result = ProfileCore.retry(function()
        return repo:Load(key)
    end, LOAD_ATTEMPTS, LOAD_DELAY, task.wait, { error = true, locked = true })
    if not player.Parent or leaving[player] then
        if result.ok then
            repo:Save(key, result.data, true) -- left while loading: free the lock we just took
        end
        return
    end
    if not result.ok then
        warn("Profile load failed", player.UserId, result.reason, result.detail)
        player:Kick(KICK_MESSAGES[result.reason] or KICK_MESSAGES.error)
        return
    end
    local data = result.data
    sessions[player] = data
    player:SetAttribute("ProfileReady", true)
    local crystalCount = 0
    for _, found in pairs(data.crystals or {}) do
        if found then crystalCount += 1 end
    end
    player:SetAttribute("SkyCrystalsDiscovered", crystalCount)
    player:SetAttribute("CloudCount", data.captures)
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
    player:SetAttribute("RangeTraining", math.clamp(math.floor(tonumber(data.rangeTraining) or 0), 0, 3))
    if not CompanionRules.owned(data.companionSpecies, data.species, CloudCatalog) then
        data.companionSpecies = CompanionRules.next(nil, data.species, CloudCatalog) or ""
    end
    player:SetAttribute("CompanionSpecies", data.companionSpecies)
    local bondPoints = (data.companionBond or {})[data.companionSpecies] or 0
    player:SetAttribute("CompanionBondPoints", bondPoints)
    player:SetAttribute("CompanionBondLevel", CompanionRules.bondLevel(bondPoints))
    local wins = data.bossVictories or {}
    for _, bossId in ipairs({ "meadow", "eastwind", "ridge" }) do
        player:SetAttribute("BossWins_" .. bossId, wins[bossId] or 0)
    end
    player:SetAttribute("BossTrialsWon", (wins.meadow or 0) + (wins.eastwind or 0) + (wins.ridge or 0))
    for toolId, owned in pairs(data.ownedTools or {}) do
        if owned and toolCatalog[toolId] then player:SetAttribute("OwnsTool_" .. toolId, true) end
    end
    player:SetAttribute("OwnsTool_starter_net", true)
    for speciesId, count in pairs(data.species) do
        -- Saves written by earlier builds may hold mutation keys like "breeze:golden".
        if CatchRules.isAttributeSafe("SpeciesCount_" .. speciesId) then
            player:SetAttribute("SpeciesCount_" .. speciesId, count)
        end
    end
    for id in pairs(questCatalog) do
        player:SetAttribute("Quest_" .. id, data.quests[id] == true)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
    leaving[player] = true
    if sessions[player] then
        local userId = player.UserId
        pendingRelease[userId] = true
        persist(player, true)
        pendingRelease[userId] = nil
    end
    sessions[player] = nil
end)

game:BindToClose(function()
    local pending = 0
    for _, player in Players:GetPlayers() do
        if sessions[player] then
            pending += 1
            task.spawn(function()
                persist(player, true)
                pending -= 1
            end)
        end
    end
    local deadline = os.clock() + CLOSE_TIMEOUT
    while pending > 0 and os.clock() < deadline do
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        task.wait(AUTOSAVE_SECONDS)
        for _, player in Players:GetPlayers() do
            if sessions[player] then
                task.spawn(persist, player, false)
            end
        end
    end
end)

return Profile
