-- Server-authoritative cloud evolution. Client requests are validated against pure rules
-- and the loaded profile; no client-trusted rewards or counts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(ReplicatedStorage:WaitForChild("EvolutionRules"))
local CloudCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local CatchRules = require(ReplicatedStorage:WaitForChild("CatchRules"))

local remote = Instance.new("RemoteEvent")
remote.Name = "EvolveCloud"
remote.Parent = ReplicatedStorage

local function setSpeciesAttribute(player, speciesId, count)
    if CatchRules.isAttributeSafe("SpeciesCount_" .. speciesId) then
        player:SetAttribute("SpeciesCount_" .. speciesId, count)
    end
end

remote.OnServerEvent:Connect(function(player, speciesId)
    if type(speciesId) ~= "string" then return end
    local data = Profile.Get(player)
    if not data then return end
    local ok, result = EvolutionRules.apply(speciesId, data, CloudCatalog)
    if not ok then
        player:SetAttribute("LastEvolutionMessage", tostring(result))
        return
    end
    -- Persist via normal autosave / leave path; attributes update immediately for HUD.
    player:SetAttribute("CloudCoins", data.coins)
    setSpeciesAttribute(player, speciesId, data.species[speciesId] or 0)
    setSpeciesAttribute(player, result, data.species[result] or 0)
    player:SetAttribute("LastEvolution", result)
    player:SetAttribute("LastEvolutionMessage", "Evolved into " .. (CloudCatalog[result] and CloudCatalog[result].name or result))
end)

-- Optional: expose for other server code
function Profile.Evolve(player, speciesId)
    local data = Profile.Get(player)
    if not data then return false, "no profile" end
    local ok, result = EvolutionRules.apply(speciesId, data, CloudCatalog)
    if ok then
        player:SetAttribute("CloudCoins", data.coins)
        setSpeciesAttribute(player, speciesId, data.species[speciesId] or 0)
        setSpeciesAttribute(player, result, data.species[result] or 0)
    end
    return ok, result
end
