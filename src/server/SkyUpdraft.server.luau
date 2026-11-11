-- Original 3D updraft pads: reusable exploration shortcuts, no client-trusted remotes.
local Players = game:GetService("Players")
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("SkyUpdraftRules"))
local lastLaunch = {}
local pads = {
    { name = "Meadow Updraft", position = Vector3.new(18, 13, 0), heading = Vector3.new(1, 0, 0), color = Color3.fromRGB(124, 225, 245) },
    { name = "Eastwind Updraft", position = Vector3.new(100, 17, 0), heading = Vector3.new(1, 0, 0), color = Color3.fromRGB(150, 245, 190) },
}
local function makePad(info)
    local model = Instance.new("Model")
    model.Name = info.name
    local platform = Instance.new("Part")
    platform.Name = "UpdraftPlatform"
    platform.Shape = Enum.PartType.Cylinder
    platform.Size = Vector3.new(1.5, 13, 13)
    platform.CFrame = CFrame.new(info.position) * CFrame.Angles(0, 0, math.pi / 2)
    platform.Anchored = true
    platform.Material = Enum.Material.Neon
    platform.Color = info.color
    platform.Parent = model
    for i = 1, 4 do
        local p = Instance.new("Part")
        p.Name = "WindPillar"
        p.Size = Vector3.new(1, 8, 1)
        p.Shape = Enum.PartType.Cylinder
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.ForceField
        p.Color = info.color
        local angle = i * math.pi / 2
        p.Position = info.position + Vector3.new(math.cos(angle) * 4, 5, math.sin(angle) * 4)
        p.Parent = model
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ride Updraft"
    prompt.ObjectText = info.name
    prompt.HoldDuration = 0.2
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = platform
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        local now = os.clock()
        local distance = (root.Position - info.position).Magnitude
        if not Rules.canLaunch(distance, now, lastLaunch[player.UserId], humanoid.Health > 0) then return end
        lastLaunch[player.UserId] = now
        local x, y, z = Rules.velocity(info.heading.X, info.heading.Z)
        root.AssemblyLinearVelocity = Vector3.new(x, y, z)
    end)
    model.Parent = workspace
end
for _, info in ipairs(pads) do makePad(info) end
Players.PlayerRemoving:Connect(function(player) lastLaunch[player.UserId] = nil end)
