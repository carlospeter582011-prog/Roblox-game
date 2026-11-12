-- Three original Roblox Part stations. Interaction is ProximityPrompt-only;
-- client never selects an arbitrary recipe, reward, or inventory mutation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Fusion = require(ReplicatedStorage:WaitForChild("CloudFusionRules"))
local Profile = require(ServerScriptService:WaitForChild("ProfileStore"))
local catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))

local forge = Instance.new("Model")
forge.Name = "CloudFusionForge3D"
forge.Parent = workspace
local recipes = { "mist_weave", "storm_charge", "dawn_bloom" }
local colors = { Color3.fromRGB(105, 204, 245), Color3.fromRGB(153, 132, 247), Color3.fromRGB(249, 190, 112) }
local busy = {}
for index, recipeId in ipairs(recipes) do
    local recipe = Fusion.recipes[recipeId]
    local pedestal = Instance.new("Part")
    pedestal.Name = "FusionPedestal_" .. recipeId
    pedestal.Anchored = true
    pedestal.CanCollide = true
    pedestal.Size = Vector3.new(7, 2, 7)
    pedestal.Position = Vector3.new(-28 + (index - 1) * 10, 7, 24)
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = colors[index]
    pedestal.Parent = forge
    local orb = Instance.new("Part")
    orb.Name = "FusionCore_" .. recipeId
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Position = pedestal.Position + Vector3.new(0, 3, 0)
    orb.Material = Enum.Material.Neon
    orb.Color = colors[index]
    orb.Parent = forge
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Fuse (" .. recipe.coins .. " Coins)"
    prompt.ObjectText = recipe.name
    prompt.HoldDuration = 0.8
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = true
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if busy[player] or player.Parent ~= Players or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0
            or (root.Position - pedestal.Position).Magnitude > 13 then return end
        busy[player] = true
        local ok, result = Profile.FuseCloud(player, recipeId)
        player:SetAttribute("LastFusionResult", ok and ("Created " .. catalog[result].name) or tostring(result))
        busy[player] = nil
    end)
end
Players.PlayerRemoving:Connect(function(player) busy[player] = nil end)
