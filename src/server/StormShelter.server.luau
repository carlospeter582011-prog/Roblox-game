-- Cooperative storm shelter: three timed shelter waves with server-only rewards.
-- All objects are real Roblox Parts/Models; no GUI stand-ins or external assets.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local Rules = require(ReplicatedStorage:WaitForChild("StormShelterRules"))
local center = Vector3.new(315, 2, -25)
local model = Instance.new("Model")
model.Name = "StormShelterChallenge3D"
model.Parent = Workspace
local shelters = {}
local colors = { Color3.fromRGB(85, 208, 231), Color3.fromRGB(230, 190, 97), Color3.fromRGB(167, 132, 242) }
for i, x in ipairs({ 283, 315, 347 }) do
    local platform = Instance.new("Part")
    platform.Name = "Shelter" .. i
    platform.Anchored = true
    platform.Size = Vector3.new(18, 0.5, 18)
    platform.Position = Vector3.new(x, 1.35, -25)
    platform.Color = colors[i]
    platform.Material = Enum.Material.SmoothPlastic
    platform.Parent = model
    shelters[i] = platform
    local canopy = Instance.new("Part")
    canopy.Name = "StormCanopy" .. i
    canopy.Anchored = true
    canopy.CanCollide = false
    canopy.Size = Vector3.new(18, 1, 18)
    canopy.Position = platform.Position + Vector3.new(0, 10, 0)
    canopy.Material = Enum.Material.ForceField
    canopy.Color = colors[i]
    canopy.Transparency = 0.5
    canopy.Parent = model
end
local sign = Instance.new("Part")
sign.Name = "ChallengeBeacon"
sign.Anchored = true
sign.CanCollide = false
sign.Size = Vector3.new(3, 6, 3)
sign.Position = center + Vector3.new(0, 3, 0)
sign.Material = Enum.Material.Neon
sign.Color = colors[1]
sign.Parent = model
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Join Storm Shelter"
prompt.ObjectText = "3 waves - follow the glowing shelter"
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = sign
local entrants = {} -- player -> {score, lastJoin}; no persisted state until reward
local active = false
local lastJoin = {}
local function eligible(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root, humanoid
end
prompt.Triggered:Connect(function(player)
    if active or entrants[player] then return end
    local root, humanoid = eligible(player)
    local now = os.clock()
    local distance = root and (root.Position - sign.Position).Magnitude or math.huge
    if not Rules.canJoin(player:GetAttribute("ProfileReady"), humanoid ~= nil and humanoid.Health > 0,
        distance, now, lastJoin[player]) then return end
    if not Profile.Get(player) then return end
    lastJoin[player] = now
    entrants[player] = { score = 0 }
    player:SetAttribute("StormShelterProgress", "Waiting for storm")
end)
Players.PlayerRemoving:Connect(function(player)
    entrants[player] = nil
    lastJoin[player] = nil
end)
task.spawn(function()
    while true do
        task.wait(5)
        if next(entrants) then
            active = true
            prompt.Enabled = false
            for wave = 1, Rules.WAVES do
                sign.Color = colors[wave]
                for player in pairs(entrants) do
                    if player.Parent then
                        player:SetAttribute("StormShelterProgress", "Wave " .. wave .. ": shelter " .. wave)
                    end
                end
                task.wait(Rules.WAVE_SECONDS)
                for player, state in pairs(entrants) do
                    local root, humanoid = eligible(player)
                    if root and humanoid and humanoid.Health > 0
                        and Rules.validDistance((root.Position - shelters[wave].Position).Magnitude)
                        and player:GetAttribute("ProfileReady") == true then
                        state.score += 1
                    end
                end
            end
            for player, state in pairs(entrants) do
                if player.Parent then
                    local data = Profile.Get(player)
                    if Rules.canReward(data, state.score, false) then
                        data.coins += Rules.REWARD_COINS
                        data.xp += Rules.REWARD_XP
                        player:SetAttribute("CloudCoins", data.coins)
                        player:SetAttribute("CloudXP", data.xp)
                        player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
                        player:SetAttribute("StormShelterProgress", "Survived! +90 Coins +65 XP")
                    else
                        player:SetAttribute("StormShelterProgress", "Storm ended: survive all 3 shelters to earn rewards")
                    end
                end
                entrants[player] = nil
            end
            sign.Color = colors[1]
            active = false
            prompt.Enabled = true
        end
    end
end)
