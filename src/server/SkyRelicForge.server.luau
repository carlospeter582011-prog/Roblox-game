-- Original native 3D crafting station. No third-party assets or client-trusted rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("RelicCraftRules"))
local model = Instance.new("Model")
model.Name = "SkyRelicForge3D"
model.Parent = Workspace
local center = Vector3.new(19, 7, -12)
local function part(name, size, offset, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = center + offset
    p.Anchored = true
    p.CanCollide = true
    p.Material = material
    p.Color = color
    p.Parent = model
    return p
end
part("ForgeBase", Vector3.new(9, 1, 9), Vector3.new(0, -2, 0), Color3.fromRGB(61, 75, 110), Enum.Material.Slate)
part("ForgePedestal", Vector3.new(3, 3, 3), Vector3.new(0, 0, 0), Color3.fromRGB(89, 122, 156), Enum.Material.Marble)
local recipes = { "lantern", "charm", "compass" }
for i, id in ipairs(recipes) do
    local entry = Rules.recipes[id]
    local p = part("Relic_" .. id, Vector3.new(1.8, 1.8, 1.8),
        Vector3.new((i - 2) * 2.5, 2.5, 0), Color3.fromRGB(102 + i * 34, 180, 230 - i * 30), Enum.Material.Neon)
    p.Shape = Enum.PartType.Ball
    p.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Craft " .. entry.coins .. " Coins"
    prompt.ObjectText = entry.name .. " | " .. entry.crystals .. " crystals"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = p
    prompt.Triggered:Connect(function(player)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or (root.Position - p.Position).Magnitude > 13 then return end
        local ok, message = ProfileStore.CraftRelic(player, id)
        local remote = ReplicatedStorage:FindFirstChild("RelicCraftFeedback")
        if remote then remote:FireClient(player, ok, message) end
    end)
end
local feedback = Instance.new("RemoteEvent")
feedback.Name = "RelicCraftFeedback"
feedback.Parent = ReplicatedStorage
Players.PlayerRemoving:Connect(function() end)
