-- Original native 3D traversal launch pads; no GUI-based world objects or third-party assets.
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Rules = require(Shared:WaitForChild("UpdraftRules"))
local lastLaunch = {}
local stations = {
    { name = "Meadow Windlift", position = Vector3.new(36, 13, -12), direction = Vector3.new(1, 0, 0), speed = 36, rise = 65 },
    { name = "Eastwind Windlift", position = Vector3.new(165, 28, -14), direction = Vector3.new(-1, 0, 0), speed = 42, rise = 70 },
}
local folder = Instance.new("Folder")
folder.Name = "SkyUpdrafts3D"
folder.Parent = workspace
for _, station in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = station.name
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "WindliftPlatform"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(1.5, 11, 11)
    base.CFrame = CFrame.new(station.position) * CFrame.Angles(0, 0, math.rad(90))
    base.Anchored = true
    base.Material = Enum.Material.Neon
    base.Color = Color3.fromRGB(90, 205, 245)
    base.Parent = model
    local ring = Instance.new("Part")
    ring.Name = "AirCurrent"
    ring.Shape = Enum.PartType.Ball
    ring.Size = Vector3.new(6, 6, 6)
    ring.Position = station.position + Vector3.new(0, 4, 0)
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.65
    ring.Material = Enum.Material.ForceField
    ring.Color = Color3.fromRGB(180, 240, 255)
    ring.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ride Wind Current"
    prompt.ObjectText = station.name
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.35
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not (root and humanoid and root:IsA("BasePart")) then return end
        local now = os.clock()
        local distance = (root.Position - base.Position).Magnitude
        if not Rules.canLaunch(distance, humanoid.Health, now, lastLaunch[player.UserId], 5) then return end
        local x, y, z = Rules.velocity(station.direction.X, station.direction.Z, station.speed, station.rise)
        if not x then return end
        lastLaunch[player.UserId] = now
        root.AssemblyLinearVelocity = Vector3.new(x, y, z)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastLaunch[player.UserId] = nil
end)
