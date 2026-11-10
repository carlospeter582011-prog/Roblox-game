-- Three original 3D updraft launch pads: fast, skill-based traversal without paid gates.
-- ProximityPrompt is supported on mobile, keyboard and gamepad; no client-supplied velocity.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("UpdraftRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyUpdraftLaunchers3D"
folder.Parent = Workspace
local lastLaunch = {}
local pads = {
    { name = "Meadow Updraft", x = 65, z = 34, dx = 1, dz = 0, color = Color3.fromRGB(112, 218, 184) },
    { name = "Eastwind Updraft", x = 185, z = 32, dx = 1, dz = 0, color = Color3.fromRGB(127, 191, 238) },
    { name = "Ridge Updraft", x = 333, z = 30, dx = -1, dz = 0, color = Color3.fromRGB(183, 149, 239) },
}
for _, spec in ipairs(pads) do
    local model = Instance.new("Model")
    model.Name = spec.name:gsub(" ", "") .. "3D"
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "WindLaunchPlate"
    base.Size = Vector3.new(9, 0.7, 9)
    base.Position = Vector3.new(spec.x, 1.7, spec.z)
    base.Anchored = true
    base.CanCollide = true
    base.Material = Enum.Material.SmoothPlastic
    base.Color = spec.color
    base.Parent = model
    local core = Instance.new("Part")
    core.Name = "UpdraftCrystal"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(3, 3, 3)
    core.Position = base.Position + Vector3.new(0, 3, 0)
    core.Anchored = true
    core.CanCollide = false
    core.Material = Enum.Material.Glass
    core.Transparency = 0.25
    core.Color = spec.color
    core.Parent = model
    for i = 1, 4 do
        local a = i * math.pi / 2
        local vane = Instance.new("Part")
        vane.Name = "WindVane3D"
        vane.Size = Vector3.new(1.2, 3, 1.2)
        vane.Position = base.Position + Vector3.new(math.cos(a) * 3, 2, math.sin(a) * 3)
        vane.Anchored = true
        vane.CanCollide = false
        vane.Material = Enum.Material.Neon
        vane.Transparency = 0.4
        vane.Color = spec.color
        vane.Parent = model
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LaunchUpdraft"
    prompt.ActionText = "Ride Updraft"
    prompt.ObjectText = spec.name
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.25
    prompt.Parent = core
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local distance = (root.Position - core.Position).Magnitude
        local previous = lastLaunch[player]
        if not Rules.canLaunch(distance, now, previous, player:GetAttribute("ProfileReady") == true, humanoid.Health > 0) then return end
        local vx, vy, vz = Rules.launchSpeeds(spec.dx, spec.dz)
        if not vx then return end
        lastLaunch[player] = now -- set before applying physics to prevent prompt spam
        root.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
        player:SetAttribute("TravelFeedback", "Updraft launched! Steer in the air.")
    end)
end
Players.PlayerRemoving:Connect(function(player) lastLaunch[player] = nil end)
