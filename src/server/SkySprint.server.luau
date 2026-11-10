-- Replayable Sky Sprint: real Roblox Parts and ProximityPrompts, never client-reported race progress.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySprintRules"))
local active, cooldown = {}, {}
local folder = Instance.new("Folder")
folder.Name = "SkySprint3D"
folder.Parent = Workspace
local stations = {
    Vector3.new(-20, 3, 0), Vector3.new(50, 3, 0),
    Vector3.new(115, 3, 0), Vector3.new(170, 3, 0),
    Vector3.new(240, 3, 0), Vector3.new(310, 3, 0),
}
local function makeStation(index, position)
    local model = Instance.new("Model")
    model.Name = index == 0 and "SprintStart" or "SprintCheckpoint" .. index
    model.Parent = folder
    for _, side in ipairs({-1, 1}) do
        local pillar = Instance.new("Part")
        pillar.Name = "GatePillar"
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.Size = Vector3.new(2, 7, 2)
        pillar.Position = position + Vector3.new(0, 0.5, side * 5)
        pillar.Material = Enum.Material.Neon
        pillar.Color = Color3.fromRGB(93, 205, 235)
        pillar.Parent = model
    end
    local top = Instance.new("Part")
    top.Name = "GateBeam"
    top.Anchored = true
    top.CanCollide = false
    top.Size = Vector3.new(2, 1.5, 12)
    top.Position = position + Vector3.new(0, 4.5, 0)
    top.Color = Color3.fromRGB(122, 192, 241)
    top.Material = Enum.Material.Neon
    top.Parent = model
    local anchor = Instance.new("Part")
    anchor.Name = "PromptAnchor"
    anchor.Anchored = true
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Size = Vector3.new(1, 1, 1)
    anchor.Position = position
    anchor.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 0 and "Start Sky Sprint" or "Mark Checkpoint"
    prompt.ObjectText = index == 0 and "Sky Sprint" or ("Gate " .. index .. "/5")
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor
    prompt.Triggered:Connect(function(player)
        if not player or not player.Parent or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or not Profile.Get(player) then return end
        local distance = (root.Position - anchor.Position).Magnitude
        if not Rules.validDistance(distance) then return end
        local now = os.clock()
        if index == 0 then
            if active[player] then
                player:SetAttribute("SkySprintFeedback", "Finish your current race first.")
            elseif now < (cooldown[player] or 0) then
                player:SetAttribute("SkySprintFeedback", "Rest before racing again.")
            else
                active[player] = { started = now, next = 1 }
                player:SetAttribute("SkySprintProgress", "0/5")
                player:SetAttribute("SkySprintFeedback", "Race started! Follow all five gates within 120 seconds.")
            end
            return
        end
        local state = active[player]
        if not state then return end
        local ok, status = Rules.advance(state, index, now, distance)
        if not ok then
            if status == "expired" then
                active[player] = nil
                player:SetAttribute("SkySprintProgress", "")
                player:SetAttribute("SkySprintFeedback", "Time up! Return to the start.")
            end
            return
        end
        if status == "finished" then
            active[player] = nil
            cooldown[player] = now + Rules.cooldown
            local paid = Profile.AwardSkySprint(player, Rules.rewards.coins, Rules.rewards.xp)
            player:SetAttribute("SkySprintProgress", "")
            player:SetAttribute("SkySprintFeedback", paid and "Sky Sprint complete! +130 Coins +70 XP" or "Race complete, profile unavailable.")
        else
            player:SetAttribute("SkySprintProgress", (index) .. "/5")
            player:SetAttribute("SkySprintFeedback", "Checkpoint " .. index .. " reached!")
        end
    end)
end
for i, pos in ipairs(stations) do makeStation(i - 1, pos) end
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    cooldown[player] = nil
end)
