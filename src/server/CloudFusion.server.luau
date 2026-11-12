-- Original native 3D elemental fusion altar. Interaction is server-owned.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudFusionRules"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local altar = Instance.new("Model")
altar.Name = "ElementalCloudFusionAltar3D"
altar.Parent = Workspace
local function makePart(name, position, size, color, material)
    local part = Instance.new("Part")
    part.Name, part.Position, part.Size = name, position, size
    part.Anchored = true
    part.Color = color
    part.Material = material
    part.Parent = altar
    return part
end
local base = makePart("FusionPedestal", Vector3.new(-38, 2, 36), Vector3.new(12, 2, 12),
    Color3.fromRGB(96, 118, 154), Enum.Material.Slate)
local glow = makePart("FusionCore", Vector3.new(-38, 5, 36), Vector3.new(4, 4, 4),
    Color3.fromRGB(146, 211, 255), Enum.Material.Neon)
glow.Shape = Enum.PartType.Ball
glow.CanCollide = false
glow.CanTouch = false
glow.CanQuery = false
local lastUse = {}
local busy = {}
local recipes = { "mistweave", "thunderhead", "sunflare" }
for index, recipeId in ipairs(recipes) do
    local pedestal = makePart("Recipe_" .. recipeId, Vector3.new(-45 + (index - 1) * 7, 2.5, 43),
        Vector3.new(5, 3, 5), Color3.fromRGB(125, 169, 204), Enum.Material.SmoothPlastic)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Fuse_" .. recipeId
    prompt.ActionText = "Fuse (" .. Rules.recipes[recipeId].coins .. " Coins)"
    prompt.ObjectText = recipeId
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent or busy[player] then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - pedestal.Position).Magnitude > 13 then return end
        if player:GetAttribute("ProfileReady") ~= true then return end
        local now = os.clock()
        if now - (lastUse[player] or -100) < 2 then return end
        busy[player] = true
        local data = Profile.Get(player)
        if data then
            local ok, outcome = Rules.apply(data, recipeId, Catalog)
            if ok then
                lastUse[player] = now
                for _, id in ipairs({ outcome.a, outcome.b, outcome.result }) do
                    player:SetAttribute("SpeciesCount_" .. id, data.species[id])
                end
                player:SetAttribute("CloudCoins", data.coins)
                player:SetAttribute("FusionFeedback", "Fused " .. Catalog[outcome.result].name)
            else
                player:SetAttribute("FusionFeedback", outcome)
            end
        end
        busy[player] = nil
    end)
end
Players.PlayerRemoving:Connect(function(player)
    busy[player], lastUse[player] = nil, nil
end)
