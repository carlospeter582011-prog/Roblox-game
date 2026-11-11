-- Sky Wind Lifts: physical 3D traversal, no ScreenGui world substitutes.
-- Original native Parts; server owns pad positions, eligibility, and impulse.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("WindLiftRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyWindLifts3D"
folder.Parent = Workspace
local last = {}
local pads = {
    { name = "Meadow", x = 48, z = 44, direction = "west", color = Color3.fromRGB(91, 189, 216) },
    { name = "Eastwind", x = 186, z = 30, direction = "east", color = Color3.fromRGB(131, 203, 178) },
    { name = "Ridge", x = 326, z = 28, direction = "west", color = Color3.fromRGB(164, 158, 232) },
}
for _, cfg in ipairs(pads) do
    local model = Instance.new("Model")
    model.Name = cfg.name .. "WindLift3D"
    model.Parent = folder
    local pad = Instance.new("Part")
    pad.Name = "WindLiftPad"
    pad.Size = Vector3.new(9, 0.6, 9)
    pad.Position = Vector3.new(cfg.x, 1.4, cfg.z)
    pad.Material = Enum.Material.Neon
    pad.Color = cfg.color
    pad.Transparency = 0.3
    pad.Anchored = true
    pad.CanCollide = false
    pad.Parent = model
    local ring = Instance.new("Part")
    ring.Name = "WindLiftRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.5, 11, 11)
    ring.CFrame = CFrame.new(cfg.x, 1.65, cfg.z) * CFrame.Angles(0, 0, math.pi / 2)
    ring.Color = cfg.color
    ring.Material = Enum.Material.Glass
    ring.Transparency = 0.45
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanTouch = false
    ring.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "RideWind"
    prompt.ActionText = "Ride Wind"
    prompt.ObjectText = cfg.name .. " Wind Lift"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.25
    prompt.RequiresLineOfSight = false
    prompt.Parent = pad
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local elapsed = now - (last[player] or -100)
        local distance = (root.Position - pad.Position).Magnitude
        if not Rules.canLaunch(distance, elapsed, humanoid.Health > 0, player:GetAttribute("ProfileReady") == true) then return end
        local vx, vy, vz = Rules.velocity(cfg.direction)
        if not vx then return end
        last[player] = now
        -- Preserve no client velocity; launch is server-owned and bounded.
        root.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
        player:SetAttribute("TravelFeedback", cfg.name .. " wind lift launched!")
    end)
end
Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
