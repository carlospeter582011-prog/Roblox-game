-- Native 3D timed traversal challenge. Server owns all checkpoints and timing.
-- Session leaderboard only: best times intentionally do not pretend to be persisted.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRingRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyRingSprint3D"
folder.Parent = Workspace
local sessions = {}
local positions = {
    Vector3.new(20, 5, 58),
    Vector3.new(35, 5, 72),
    Vector3.new(55, 5, 75),
    Vector3.new(72, 5, 60),
    Vector3.new(60, 5, 43),
}
for i, position in ipairs(positions) do
    local model = Instance.new("Model")
    model.Name = "SkyRingCheckpoint" .. i
    model.Parent = folder
    -- Two columns and an arch form a clearly visible physical checkpoint.
    for _, offset in ipairs({ -4, 4 }) do
        local column = Instance.new("Part")
        column.Name = "RingPillar"
        column.Anchored = true
        column.CanCollide = false
        column.Material = Enum.Material.SmoothPlastic
        column.Color = Color3.fromRGB(87, 163, 208)
        column.Size = Vector3.new(1, 8, 1)
        column.Position = position + Vector3.new(offset, 0, 0)
        column.Parent = model
    end
    local arch = Instance.new("Part")
    arch.Name = "RingArch"
    arch.Anchored = true
    arch.CanCollide = false
    arch.Material = Enum.Material.Neon
    arch.Color = Color3.fromRGB(128, 228, 240)
    arch.Size = Vector3.new(9, 1, 1)
    arch.Position = position + Vector3.new(0, 4, 0)
    arch.Parent = model
    local marker = Instance.new("Part")
    marker.Name = "CheckpointAnchor"
    marker.Transparency = 1
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.Size = Vector3.new(1, 1, 1)
    marker.Position = position
    marker.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = i == 1 and "Start sprint" or "Pass ring"
    prompt.ObjectText = "Sky Ring " .. i .. "/" .. #positions
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = marker
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return end
        local distance = (root.Position - marker.Position).Magnitude
        if distance ~= distance or distance > 10 then return end
        if player:GetAttribute("ProfileReady") ~= true then return end
        local nextState, status, elapsed = Rules.advance(sessions[player], i, os.clock())
        if not nextState then return end
        sessions[player] = nextState
        player:SetAttribute("SkyRingNext", nextState.next or 1)
        if status == "completed" then
            player:SetAttribute("SkyRingLastSeconds", math.floor(elapsed * 10 + 0.5) / 10)
            player:SetAttribute("SkyRingBestSeconds", math.floor(nextState.best * 10 + 0.5) / 10)
            player:SetAttribute("SkyRingFeedback", "Sprint complete! Try beating your best time.")
        elseif status == "started" then
            player:SetAttribute("SkyRingFeedback", "Sprint started! Reach all five rings in 90 seconds.")
        else
            player:SetAttribute("SkyRingFeedback", "Checkpoint " .. i .. " cleared!")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
