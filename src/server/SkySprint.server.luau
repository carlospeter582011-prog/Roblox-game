-- Native Roblox 3D sky sprint: touch/gamepad ProximityPrompts, server clock and route checks.
-- Session-only best times; no farmable currency or unverified DataStore schema.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkySprintRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local states = {}
local bests = {}
local folder = Instance.new("Folder")
folder.Name = "SkySprint3D"
folder.Parent = Workspace
local function makeGate(index, info)
    local model = Instance.new("Model")
    model.Name = "SkySprintGate" .. index
    model.Parent = folder
    local position = Vector3.new(info.x, 2, info.z)
    for _, offset in ipairs({ -7, 7 }) do
        local post = Instance.new("Part")
        post.Name = "GatePost"
        post.Size = Vector3.new(2, 12, 2)
        post.Position = position + Vector3.new(0, 5, offset)
        post.Anchored = true
        post.CanCollide = false
        post.Material = Enum.Material.Neon
        post.Color = Color3.fromRGB(88, 180, 225)
        post.Parent = model
    end
    local beam = Instance.new("Part")
    beam.Name = "GateBeam"
    beam.Size = Vector3.new(2, 2, 16)
    beam.Position = position + Vector3.new(0, 11, 0)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Material = Enum.Material.SmoothPlastic
    beam.Color = Color3.fromRGB(49, 93, 146)
    beam.Parent = model
    local anchor = Instance.new("Part")
    anchor.Name = "RaceCheckpoint"
    anchor.Size = Vector3.new(2, 1, 2)
    anchor.Position = position
    anchor.Transparency = 1
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = index == 1 and "Start Sky Sprint" or ("Checkpoint " .. index)
    prompt.ObjectText = "Sky Sprint"
    prompt.HoldDuration = 0.2
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent
            or not player:GetAttribute("ProfileReady") or not Profile.Get(player) then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0
            or (root.Position - anchor.Position).Magnitude > 14 then return end
        local nextState, result = Rules.advance(states[player], index, Workspace:GetServerTimeNow())
        if not nextState then
            player:SetAttribute("SkySprintStatus", result == "out_of_order" and "Visit checkpoints in order" or "Run invalid; restart at Meadow")
            if result ~= "out_of_order" then states[player] = nil end
            return
        end
        if result == "finished" then
            local duration = math.floor(nextState.duration * 100) / 100
            local old = bests[player]
            if not old or duration < old then
                bests[player] = duration
                player:SetAttribute("SkySprintBest", duration)
            end
            player:SetAttribute("SkySprintStatus", string.format("Sky Sprint finished: %.2fs", duration))
            states[player] = nil
        else
            states[player] = nextState
            player:SetAttribute("SkySprintStatus", result == "started" and "Race started! Reach Eastwind" or "Reach Thunderhead Ridge!")
        end
    end)
end
for i, checkpoint in ipairs(Rules.CHECKPOINTS) do makeGate(i, checkpoint) end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    bests[player] = nil
end)
