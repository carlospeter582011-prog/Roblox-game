-- Original 3D Sky Forge: repeatable Coin-to-XP training with server-owned pricing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Forge = require(ReplicatedStorage:WaitForChild("SkyForgeRules"))
local model = Instance.new("Model")
model.Name = "SkyForge3D"
model.Parent = workspace
local function block(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.Parent = model
    return p
end
block("ForgeBase", Vector3.new(12, 2, 9), Vector3.new(-35, 2, 32), Color3.fromRGB(76, 90, 118), Enum.Material.Slate)
block("ForgeAnvil", Vector3.new(5, 3, 4), Vector3.new(-35, 4.5, 32), Color3.fromRGB(115, 148, 174), Enum.Material.Metal)
local lastUse = {}
local positions = { spark = -40, gale = -35, tempest = -30 }
for id, x in pairs(positions) do
    local recipe = Forge.Recipes[id]
    local pedestal = block("Recipe_" .. id, Vector3.new(2.5, 3, 2.5),
        Vector3.new(x, 5, 32), Color3.fromRGB(104, 173, 191), Enum.Material.SmoothPlastic)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Craft_" .. id
    prompt.ActionText = "Train: " .. recipe.cost .. " Coins"
    prompt.ObjectText = recipe.name .. " (+" .. recipe.xp .. " XP)"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return end
        if (root.Position - pedestal.Position).Magnitude > 12 then return end
        if player:GetAttribute("ProfileReady") ~= true then return end
        local now = os.clock()
        if now - (lastUse[player] or -100) < 5 then return end
        local ok, message = Profile.CraftSkyForge(player, id)
        if ok then lastUse[player] = now end
        player:SetAttribute("SkyForgeFeedback", message)
    end)
end
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
