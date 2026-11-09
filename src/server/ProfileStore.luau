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
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))

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
    for _, id in ipairs(CatchRules.applyCatch(data, speciesId, coins, questCatalog, options)) do
        player:SetAttribute("Quest_" .. id, true)
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

-- Saves with retries. release = true also frees the session lock and ends the session.
-- Returns true only if the data reached the DataStore.
local function persist(player, release)
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
    player:SetAttribute("CloudCount", data.captures)
    player:SetAttribute("CloudCoins", data.coins)
    player:SetAttribute("CloudXP", data.xp)
    player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
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
