-- Original native-3D repeatable survey board; session cooldowns, server-owned rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Catalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local Rules = require(ReplicatedStorage:WaitForChild("CloudSurveyRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local board = Instance.new("Model")
board.Name = "CloudSurveyBoard3D"
local base = Instance.new("Part")
base.Name = "SurveyPillar"
base.Size = Vector3.new(5, 8, 2)
base.Anchored = true
base.Material = Enum.Material.Slate
base.Color = Color3.fromRGB(70, 110, 150)
base.CFrame = CFrame.new(13, 9, -18)
base.Parent = board
local panel = Instance.new("Part")
panel.Name = "SurveyCrystal"
panel.Size = Vector3.new(4, 3, 0.5)
panel.Anchored = true
panel.CanCollide = false
panel.Material = Enum.Material.Neon
panel.Color = Color3.fromRGB(100, 230, 240)
panel.CFrame = base.CFrame * CFrame.new(0, 1, -1.3)
panel.Parent = board
board.Parent = workspace
local claims = {} -- [userId] = { timestamps by tier }; no new persistent schema
local busy = {}
Players.PlayerRemoving:Connect(function(player) claims[player.UserId] = nil; busy[player.UserId] = nil end)
for tier, config in ipairs(Rules.TIERS) do
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "SurveyTier" .. tier
    prompt.ActionText = "Survey " .. config.required .. " species"
    prompt.ObjectText = "Cloud Survey +" .. config.coins .. " Coins / +" .. config.xp .. " XP"
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = panel
    prompt.Triggered:Connect(function(player)
        if busy[player.UserId] then return end
        busy[player.UserId] = true
        local ok, err = pcall(function()
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not humanoid or humanoid.Health <= 0 or not root or (root.Position - panel.Position).Magnitude > 12 then return end
            local data = Profile.Get(player)
            if not data or player:GetAttribute("ProfileReady") ~= true then return end
            local previous = claims[player.UserId] or {}
            local result = Rules.evaluate(tier, data.species, Catalog, os.time(), previous[tier] or 0, data.coins, data.xp)
            if not result then return end
            data.coins, data.xp = result.coins, result.xp
            previous[tier] = result.claimedAt
            claims[player.UserId] = previous
            player:SetAttribute("CloudCoins", data.coins)
            player:SetAttribute("CloudXP", data.xp)
            player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
            player:SetAttribute("LastSurveyTier", tier)
        end)
        busy[player.UserId] = nil
        if not ok then warn("Cloud Survey failed", err) end
    end)
end
