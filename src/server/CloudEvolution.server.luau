-- Cloud Evolution Station: original 3D interaction for evolving clouds.
-- Server-authoritative; uses ProximityPrompt on native Roblox Parts/Models.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EvolutionRules = require(ReplicatedStorage.Shared.EvolutionRules)
local ProfileStore = require(script.Parent.ProfileStore)
local CloudCatalog = require(ReplicatedStorage.Shared.CloudCatalog)

local station = Instance.new("Model")
station.Name = "CloudEvolutionStation"
station.Parent = workspace

local base = Instance.new("Part")
base.Name = "Base"
base.Size = Vector3.new(8, 1, 8)
base.Position = Vector3.new(20, 5, 20)
base.Anchored = true
base.Material = Enum.Material.Neon
base.Color = Color3.fromRGB(100, 200, 255)
base.Parent = station

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Evolve Cloud"
prompt.ObjectText = "Evolution Station"
prompt.HoldDuration = 1
prompt.MaxActivationDistance = 10
prompt.Parent = base

local lastUse = {}

prompt.Triggered:Connect(function(player)
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < 5 then
        return
    end
    lastUse[player] = now

    local data = ProfileStore.GetData(player)
    if not data then return end

    -- Find first evolvable owned species for this simple interaction.
    local target = nil
    for id, count in pairs(data.species) do
        if EvolutionRules.canEvolve(id, count, data.coins) and CloudCatalog[id] then
            target = id
            break
        end
    end
    if not target then return end

    if EvolutionRules.applyEvolve(data, target) then
        ProfileStore.Save(player)
        -- Optional feedback: could fire a remote for HUD, but keep minimal.
        print(player.Name .. " evolved " .. target)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
