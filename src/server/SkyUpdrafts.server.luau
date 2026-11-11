-- Traversal gameplay: reusable 3D sky updrafts between existing connected island areas.
-- No external assets or client remotes. Native ProximityPrompt works on touch/gamepad.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("UpdraftRules"))

local folder = Instance.new("Folder")
folder.Name = "SkyUpdrafts3D"
folder.Parent = Workspace
local lastLaunch = {}
local pads = {
    { name = "MeadowToEastwind", origin = Vector3.new(82, 2, 0), direction = Vector3.new(1, 0, 0) },
    { name = "EastwindToRidge", origin = Vector3.new(210, 2, 0), direction = Vector3.new(1, 0, 0) },
    { name = "RidgeToEastwind", origin = Vector3.new(285, 2, 0), direction = Vector3.new(-1, 0, 0) },
}
local function makePart(name, size, pos, color, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = pos
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.Transparency = transparency or 0
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Parent = folder
    return part
end
for _, config in ipairs(pads) do
    local base = makePart(config.name, Vector3.new(9, 1, 9), config.origin, Color3.fromRGB(85, 170, 205))
    base.Shape = Enum.PartType.Cylinder
    local ring = makePart(config.name .. "WindRing", Vector3.new(7, 0.4, 7), config.origin + Vector3.new(0, 1.2, 0), Color3.fromRGB(170, 230, 245), 0.25)
    ring.Shape = Enum.PartType.Cylinder
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LaunchUpdraft"
    prompt.ActionText = "Ride wind"
    prompt.ObjectText = "Sky Updraft"
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.HoldDuration = 0.25
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local elapsed = now - (lastLaunch[player] or -100)
        local distance = (root.Position - base.Position).Magnitude
        if not Rules.canLaunch(distance, elapsed, humanoid.Health > 0, ProfileStore.Get(player) ~= nil) then return end
        local x, y, z = Rules.velocity(config.direction.X, config.direction.Z)
        if not x then return end
        lastLaunch[player] = now
        -- Set bounded velocity on the server. Existing safe-fall recovery remains active.
        root.AssemblyLinearVelocity = Vector3.new(x, y, z)
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastLaunch[player] = nil
end)
