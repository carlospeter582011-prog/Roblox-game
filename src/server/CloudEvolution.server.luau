-- Server-authoritative species evolution. Pure rules decide; ProfileStore persists.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local remote = Instance.new("RemoteEvent")
remote.Name = "RequestCloudEvolution"
remote.Parent = ReplicatedStorage

local function replicate(player, data)
    for id, done in pairs(data.evolvedSpecies or {}) do
        if done then
            player:SetAttribute("Evolved_" .. id, true)
        end
    end
    for id, points in pairs(data.speciesMastery or {}) do
        player:SetAttribute("Mastery_" .. id, points)
    end
end

remote.OnServerEvent:Connect(function(player, speciesId)
    if typeof(speciesId) ~= "string" or #speciesId > 48 then return end
    local profile = ProfileStore.Get(player)
    if not profile then
        remote:FireClient(player, false, "Profile unavailable")
        return
    end
    local species = catalog[speciesId]
    if not species then
        remote:FireClient(player, false, "Unknown species")
        return
    end
    if EvolutionRules.apply(profile, speciesId, species.rarity) then
        player:SetAttribute("Evolved_" .. speciesId, true)
        remote:FireClient(player, true, "Evolved " .. species.name .. "! +" .. EvolutionRules.EVOLUTION_REWARD_COINS .. " Coins")
    else
        remote:FireClient(player, false, "Not ready to evolve yet")
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.delay(2, function()
        local data = ProfileStore.Get(player)
        if data then replicate(player, data) end
    end)
end)
