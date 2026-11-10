-- Three reusable 3D updraft launchpads: skillful shortcuts between connected islands.
-- Server validates ProximityPrompt interactions, alive character, proximity and cooldown.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyUpdraftRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyUpdrafts3D"
folder.Parent = Workspace
local lastLaunch = {}
local function createPad(label, x, z, dx, dz, tint)
    local model = Instance.new("Model")
    model.Name = label .. "3D"
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "UpdraftPlatform"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(1, 12, 12)
    base.Orientation = Vector3.new(0, 0, 90)
    base.Position = Vector3.new(x, 2.3, z)
    base.Anchored = true
    base.Color = tint
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = model
    local core = Instance.new("Part")
    core.Name = "WindCore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(4, 4, 4)
    core.Position = Vector3.new(x, 5, z)
    core.Anchored = true
    core.CanCollide = false
    core.Material = Enum.Material.Neon
    core.Transparency = 0.3
    core.Color = tint
    core.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "RideUpdraft"
    prompt.ActionText = "Ride Wind"
    prompt.ObjectText = label
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = core
    local nx, nz = Rules.direction(dx, dz)
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local distance = root and (root.Position - core.Position).Magnitude or math.huge
        local now = os.clock()
        if not Rules.canLaunch(distance, humanoid and humanoid.Health > 0, player:GetAttribute("ProfileReady") == true, now, lastLaunch[player]) then return end
        lastLaunch[player] = now
        root.AssemblyLinearVelocity = Vector3.new(nx * Rules.HORIZONTAL_SPEED, Rules.VERTICAL_SPEED, nz * Rules.HORIZONTAL_SPEED)
        player:SetAttribute("TravelFeedback", label .. ": wind lift!")
    end)
end
createPad("Meadow Updraft", 48, 12, 1, 0, Color3.fromRGB(95, 210, 195))
createPad("Eastwind Updraft", 218, -14, 1, 0, Color3.fromRGB(110, 182, 235))
createPad("Ridge Updraft", 352, -14, -1, 0, Color3.fromRGB(178, 147, 232))
Players.PlayerRemoving:Connect(function(player) lastLaunch[player] = nil end)
