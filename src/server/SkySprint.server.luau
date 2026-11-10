-- Original 3D checkpoint race: sequential touch prompts, server position validation.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyRaceRules"))
local positions = {
    Vector3.new(12, 7, -12),
    Vector3.new(45, 7, -12),
    Vector3.new(65, 7, 12),
}
local folder = Instance.new("Folder")
folder.Name = "SkySprint3D"
folder.Parent = Workspace
local sessions = {}
for index, position in ipairs(positions) do
    local marker = Instance.new("Part")
    marker.Name = "SkySprintCheckpoint" .. index
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(2, 9, 9)
    marker.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.Material = Enum.Material.SmoothPlastic
    marker.Color = Color3.fromRGB(90, 180, 210)
    marker.Transparency = 0.35
    marker.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 1 and "Start Sky Sprint" or "Pass Checkpoint"
    prompt.ObjectText = "Sky Sprint " .. index .. "/" .. Rules.CHECKPOINTS
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.25
    prompt.Parent = marker
    prompt.Triggered:Connect(function(player)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or not ProfileStore.Get(player) then return end
        local distance = (root.Position - position).Magnitude
        local nextState, status = Rules.advance(sessions[player], index, distance, os.clock())
        if not nextState then
            -- A timed-out run can restart at checkpoint one.
            if index == 1 and status == "Race expired; restart at checkpoint 1" then
                sessions[player] = nil
            end
            return
        end
        sessions[player] = nextState
        player:SetAttribute("SkySprintCheckpoint", status == "Finished" and 0 or index)
        if status == "Finished" then
            ProfileStore.AwardSkySprint(player, Rules.REWARD_COINS, Rules.REWARD_XP)
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    sessions[player] = nil
end)
