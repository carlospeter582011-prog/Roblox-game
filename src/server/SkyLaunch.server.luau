-- Two original 3D wind-launch pads connect existing regions with skill-based air travel.
-- Launch is server-authoritative and requires a living character and loaded profile.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyLaunchRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyLaunchPads3D"
folder.Parent = Workspace
local lastLaunch = {}
local pads = {
    { name = "MeadowToOutlook", from = Vector3.new(74, 2, 28), to = Vector3.new(170, 3, 28) },
    { name = "OutlookToRidge", from = Vector3.new(200, 2, -24), to = Vector3.new(315, 3, -24) },
}
for _, config in ipairs(pads) do
    local model = Instance.new("Model")
    model.Name = config.name
    model.Parent = folder
    local platform = Instance.new("Part")
    platform.Name = "WindLaunchPlatform"
    platform.Size = Vector3.new(12, 1, 12)
    platform.Position = config.from
    platform.Anchored = true
    platform.Material = Enum.Material.Slate
    platform.Color = Color3.fromRGB(75, 144, 183)
    platform.Parent = model
    local ring = Instance.new("Part")
    ring.Name = "WindBeacon"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(1, 8, 8)
    ring.CFrame = CFrame.new(config.from + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.pi / 2)
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(132, 230, 241)
    ring.Transparency = 0.65
    ring.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "RideWind"
    prompt.ActionText = "Ride the Wind"
    prompt.ObjectText = config.name == "MeadowToOutlook" and "Eastwind Current" or "Thunderhead Current"
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = platform
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local distance = (root.Position - platform.Position).Magnitude
        if not Rules.canLaunch(distance, now - (lastLaunch[player] or -100), ProfileStore.Get(player) ~= nil, humanoid.Health > 0) then return end
        local vx, vy, vz = Rules.velocity(config.from.X, config.from.Z, config.to.X, config.to.Z)
        if not vx then return end
        lastLaunch[player] = now
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        root.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
        player:SetAttribute("WindLaunchFeedback", "Wind current activated! Steer toward the next island.")
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastLaunch[player] = nil
end)
