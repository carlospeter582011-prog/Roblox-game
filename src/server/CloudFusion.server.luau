-- Server-owned fusion altar: physical Roblox 3D Parts, no client-controlled reward or recipe.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudFusionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local altar = Instance.new("Model")
altar.Name = "CloudFusionAltar3D"
altar.Parent = workspace
local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.Parent = altar
    return p
end
local base = part("FusionPedestal", Vector3.new(10, 2, 10), Vector3.new(-42, 2, 28),
    Color3.fromRGB(90, 100, 155), Enum.Material.Slate)
local orb = part("FusionCore", Vector3.new(4, 4, 4), Vector3.new(-42, 5, 28),
    Color3.fromRGB(175, 235, 255), Enum.Material.Neon)
orb.Shape = Enum.PartType.Ball
orb.CanCollide = false
local lastUse = {}
for _, recipe in ipairs(Rules.Recipes) do
    local index = table.find(Rules.Recipes, recipe)
    local angle = (index - 1) * math.pi * 2 / #Rules.Recipes
    local stone = part("Recipe_" .. recipe.id, Vector3.new(2.5, 3, 2.5),
        Vector3.new(-42 + math.cos(angle) * 8, 2.5, 28 + math.sin(angle) * 8),
        Color3.fromRGB(120, 195, 210), Enum.Material.SmoothPlastic)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Fuse (cost " .. recipe.coins .. " Coins)"
    prompt.ObjectText = recipe.first .. " + " .. recipe.second .. " = " .. recipe.result
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = stone
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - stone.Position).Magnitude > 12 then return end
        local now = os.clock()
        if now - (lastUse[player] or -100) < 2 then return end
        lastUse[player] = now
        local data = Profile.Get(player)
        if not data or player:GetAttribute("ProfileReady") ~= true then return end
        local ok, result = Rules.apply(data, recipe.id, Catalog)
        if not ok then
            player:SetAttribute("FusionFeedback", result)
            return
        end
        for _, id in ipairs({ result.first, result.second, result.result }) do
            player:SetAttribute("SpeciesCount_" .. id, data.species[id])
        end
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("FusionFeedback", "Fused " .. Catalog[result.result].name .. "!")
    end)
end
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
