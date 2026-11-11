-- Original physical sky traversal pads: no client remote and no Canvas world stand-ins.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("WindLiftRules"))
local folder = Instance.new("Folder")
folder.Name = "WindLiftPads3D"
folder.Parent = Workspace
local lastLaunch = {}
local locations = {
    { name = "Meadow Lift", position = Vector3.new(35, 5, 20), direction = Vector3.new(1, 0, 0) },
    { name = "Eastwind Lift", position = Vector3.new(190, 5, 20), direction = Vector3.new(-1, 0, 0) },
    { name = "Ridge Lift", position = Vector3.new(330, 5, 20), direction = Vector3.new(-1, 0, 0) },
}
for _, entry in ipairs(locations) do
    local model = Instance.new("Model")
    model.Name = entry.name
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "LaunchPlatform"
    base.Size = Vector3.new(12, 1, 12)
    base.Position = entry.position
    base.Anchored = true
    base.Material = Enum.Material.SmoothPlastic
    base.Color = Color3.fromRGB(75, 150, 205)
    base.Parent = model
    local ring = Instance.new("Part")
    ring.Name = "WindCore"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.35, 7, 7)
    ring.CFrame = CFrame.new(entry.position + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, 0, math.rad(90))
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Glass
    ring.Color = Color3.fromRGB(155, 235, 245)
    ring.Transparency = 0.35
    ring.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ride wind lift"
    prompt.ObjectText = entry.name
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.3
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local distance = (root.Position - base.Position).Magnitude
        if not Rules.canLaunch(now, lastLaunch[player.UserId], distance, humanoid.Health > 0) then return end
        lastLaunch[player.UserId] = now
        -- Server-owned impulse, preserves player control in flight.
        root.AssemblyLinearVelocity = entry.direction * Rules.HORIZONTAL_SPEED + Vector3.new(0, Rules.UP_SPEED, 0)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastLaunch[player.UserId] = nil
end)
