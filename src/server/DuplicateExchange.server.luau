-- Native 3D surplus cloud exchange: converts one duplicate into Coins, never the last copy.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Rules = require(ReplicatedStorage:WaitForChild("DuplicateExchangeRules"))
local model = Instance.new("Model")
model.Name = "CloudDuplicateExchange3D"
local function part(name, size, position, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = model
    return p
end
part("Platform", Vector3.new(9, 1, 9), Vector3.new(20, 3, -15), Color3.fromRGB(85, 105, 145))
local pillar = part("ExchangePedestal", Vector3.new(3, 4, 3), Vector3.new(20, 5.5, -15), Color3.fromRGB(125, 190, 220))
local orb = part("CloudOrb", Vector3.new(2.5, 2.5, 2.5), Vector3.new(20, 8.5, -15), Color3.fromRGB(195, 235, 255))
orb.Shape = Enum.PartType.Ball
orb.Material = Enum.Material.Neon
orb.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Exchange duplicate"
prompt.ObjectText = "Cloud Exchange"
prompt.MaxActivationDistance = 9
prompt.HoldDuration = 0.6
prompt.Parent = pillar
model.Parent = workspace
local last = {}
prompt.Triggered:Connect(function(player)
    local profile = ProfileStore.Get(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - pillar.Position).Magnitude > 12 then return end
    local now = os.clock()
    if now - (last[player] or -100) < 5 then return end
    last[player] = now
    local ok, id, reward = Rules.exchange(profile, Catalog)
    if not ok then
        player:SetAttribute("CloudExchangeStatus", id)
        return
    end
    player:SetAttribute("CloudCoins", profile.coins)
    player:SetAttribute("SpeciesCount_" .. id, profile.species[id])
    player:SetAttribute("CloudExchangeStatus", "Exchanged " .. id .. " for " .. reward .. " Coins")
end)
Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
