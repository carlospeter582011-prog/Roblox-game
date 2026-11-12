-- Three original 3D survey beacons; a timed exploration loop spanning all playable regions.
-- Rewards are server-authoritative and persisted through the existing profile session.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySurveyRules"))

local positions = {
    meadow = Vector3.new(-42, 3, 40),
    eastwind = Vector3.new(174, 3, 35),
    ridge = Vector3.new(325, 3, 30),
}
local progress = {}
local beacons = Instance.new("Folder")
beacons.Name = "SkySurveyRelay3D"
beacons.Parent = Workspace

for index, id in ipairs(Rules.STATIONS) do
    local model = Instance.new("Model")
    model.Name = "SurveyBeacon_" .. id
    model.Parent = beacons
    local pedestal = Instance.new("Part")
    pedestal.Name = "StoneBase"
    pedestal.Anchored = true
    pedestal.Size = Vector3.new(6, 2, 6)
    pedestal.Position = positions[id] - Vector3.new(0, 1, 0)
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = Color3.fromRGB(85, 112, 144)
    pedestal.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "SurveyCrystal"
    crystal.Shape = Enum.PartType.Ball
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Size = Vector3.new(3, 4, 3)
    crystal.Position = positions[id] + Vector3.new(0, 2, 0)
    crystal.Material = Enum.Material.Neon
    crystal.Color = Color3.fromRGB(125, 205, 242)
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 3 and "Finish survey" or "Survey skies"
    prompt.ObjectText = "Sky Survey " .. index .. "/3"
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        if player:GetAttribute("ProfileReady") ~= true then return end
        local data = Profile.Get(player)
        if not data then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local now = os.clock()
        local state = progress[player] or { stage = 1, started = now, nextAt = 0 }
        if state.stage > 1 and now - state.started > Rules.TIME_LIMIT then
            state.stage, state.started = 1, now
        end
        local ok, reason = Rules.check(state.stage, id,
            (root.Position - pedestal.Position).Magnitude,
            now - state.started, state.nextAt - now)
        if not ok then
            player:SetAttribute("SkySurveyStatus", reason)
            progress[player] = state
            return
        end
        if reason == "complete" then
            local awarded = Profile.AwardSkySurvey(player, Rules.REWARD_COINS, Rules.REWARD_XP)
            if not awarded then return end
            state.stage = 1
            state.started = now
            state.nextAt = now + Rules.COOLDOWN
            player:SetAttribute("SkySurveyStatus", "Complete! +180 Coins +100 XP")
        else
            state.stage += 1
            player:SetAttribute("SkySurveyStatus", "Survey " .. index .. "/3 complete")
        end
        player:SetAttribute("SkySurveyStage", state.stage)
        progress[player] = state
    end)
end
Players.PlayerRemoving:Connect(function(player) progress[player] = nil end)
