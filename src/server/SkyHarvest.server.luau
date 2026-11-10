-- Three original, native 3D harvesting stations: repeatable exploration rewards.
-- Rewards are server-authoritative and intentionally modest. Cooldowns are per-session;
-- persistent cooldowns require a future profile schema migration.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyHarvestRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local folder = Instance.new("Folder")
folder.Name = "SkyHarvestNodes3D"
folder.Parent = workspace
local last = {} -- [userId] = { [nodeId] = os.time() }
local busy = {}
local placements = {
    { "meadow", Vector3.new(42, 2, 36), Color3.fromRGB(108, 198, 128) },
    { "eastwind", Vector3.new(173, 2, 28), Color3.fromRGB(108, 187, 214) },
    { "ridge", Vector3.new(315, 2, 27), Color3.fromRGB(158, 145, 218) },
}
for _, item in ipairs(placements) do
    local id, position, color = item[1], item[2], item[3]
    local model = Instance.new("Model")
    model.Name = "Harvest_" .. id
    model.Parent = folder
    local pedestal = Instance.new("Part")
    pedestal.Name = "HarvestPedestal"
    pedestal.Size = Vector3.new(7, 2, 7)
    pedestal.Position = position
    pedestal.Anchored = true
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = Color3.fromRGB(75, 91, 114)
    pedestal.Parent = model
    local orb = Instance.new("Part")
    orb.Name = "SkySeed"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.Position = position + Vector3.new(0, 3, 0)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Parent = model
    model.PrimaryPart = pedestal
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Harvest"
    prompt.ObjectText = id .. " sky seed"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent or busy[player] then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local data = Profile.Get(player)
        if not data or not root or not humanoid or humanoid.Health <= 0 then return end
        local now = os.time()
        local previous = last[player.UserId] and last[player.UserId][id]
        if not Rules.canHarvest(id, (root.Position - pedestal.Position).Magnitude,
            data.captures, now, previous, player:GetAttribute("ProfileReady")) then return end
        busy[player] = true
        -- No yield between eligibility and reward; a duplicate prompt cannot double-pay.
        local coins, xp = Rules.reward(id)
        data.coins += coins
        data.xp += xp
        last[player.UserId] = last[player.UserId] or {}
        last[player.UserId][id] = now
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("CloudXP", data.xp)
        player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
        player:SetAttribute("SkyHarvestFeedback", id .. ": +" .. coins .. " Coins, +" .. xp .. " XP")
        busy[player] = nil
    end)
end
Players.PlayerRemoving:Connect(function(player)
    last[player.UserId] = nil
    busy[player] = nil
end)
