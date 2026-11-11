-- Native 3D checkpoint shrines and server-side fall rescue. No client remotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRescueRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyRescueShrines3D"
folder.Parent = Workspace
local checkpoints = {}
local lastRecovery = {}
for id, pos in pairs(Rules.CHECKPOINTS) do
    local model = Instance.new("Model")
    model.Name = id .. "RescueShrine3D"
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "ShrineBase"
    base.Size = Vector3.new(5, 1, 5)
    base.Position = Vector3.new(pos.x, pos.y - 1, pos.z)
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(76, 109, 150)
    base.Parent = model
    local beacon = Instance.new("Part")
    beacon.Name = "Beacon"
    beacon.Shape = Enum.PartType.Ball
    beacon.Size = Vector3.new(2, 2, 2)
    beacon.Position = Vector3.new(pos.x, pos.y + 2, pos.z)
    beacon.Anchored = true
    beacon.CanCollide = false
    beacon.Material = Enum.Material.Neon
    beacon.Color = Color3.fromRGB(112, 224, 238)
    beacon.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Set rescue checkpoint"
    prompt.ObjectText = id .. " sky shrine"
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = 12
    prompt.Parent = beacon
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        if not Rules.canActivate(id, (root.Position - beacon.Position).Magnitude, humanoid.Health > 0) then return end
        checkpoints[player] = id
        player:SetAttribute("RescueCheckpoint", id)
        player:SetAttribute("RescueFeedback", "Checkpoint activated: " .. id)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    checkpoints[player] = nil
    lastRecovery[player] = nil
end)
task.spawn(function()
    while true do
        task.wait(0.2)
        local now = os.clock()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and Rules.shouldRescue(root.Position.Y, now, lastRecovery[player], humanoid.Health > 0) then
                local id = checkpoints[player] or "meadow"
                local pos = Rules.CHECKPOINTS[id] or Rules.CHECKPOINTS.meadow
                lastRecovery[player] = now
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                character:PivotTo(CFrame.new(pos.x, pos.y + 5, pos.z))
                player:SetAttribute("RescueFeedback", "Sky rescue! Returned to " .. id)
            end
        end
    end
end)
