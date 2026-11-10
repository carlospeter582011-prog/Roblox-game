-- Three native 3D wind-current launchpads. Optional skill movement, no client remote or paid gates.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyCurrentRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyCurrentLaunchpads3D"
folder.Parent = Workspace
local ready = {} -- per-player cooldown; no currency reward or farming incentive
local function makePad(name, from, toward, tint)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "WindLaunchPlatform"
    base.Anchored = true
    base.Size = Vector3.new(12, 1, 12)
    base.Position = from
    base.Color = tint
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = model
    local ring = Instance.new("Part")
    ring.Name = "CurrentRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.35, 10, 10)
    ring.CFrame = CFrame.new(from + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = tint
    ring.Transparency = 0.35
    ring.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ride Sky Current"
    prompt.ObjectText = name
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.25
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        local now = os.clock()
        if not Rules.canLaunch((root.Position - base.Position).Magnitude, humanoid.Health, now, ready[player] or 0) then return end
        if humanoid.Sit or humanoid.PlatformStand then return end
        local x, y, z = Rules.velocity(toward.X - from.X, toward.Z - from.Z)
        if not x then return end
        ready[player] = now + Rules.COOLDOWN
        -- Assembly velocity is server-set and bounded; Roblox physics handles the trajectory.
        root.AssemblyLinearVelocity = Vector3.new(x, y, z)
        player:SetAttribute("SkyCurrentFeedback", "Wind current launched! Steer toward the landing platform.")
    end)
end
-- Launch toward connected-island routes; positions must be verified in Roblox before merging.
makePad("Meadow Current", Vector3.new(45, 3, 10), Vector3.new(145, 3, 10), Color3.fromRGB(94, 202, 235))
makePad("Eastwind Current", Vector3.new(230, 3, 10), Vector3.new(320, 3, 10), Color3.fromRGB(126, 207, 167))
makePad("Ridge Return Current", Vector3.new(305, 3, -12), Vector3.new(205, 3, -12), Color3.fromRGB(178, 149, 235))
Players.PlayerRemoving:Connect(function(player) ready[player] = nil end)
