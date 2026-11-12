-- Original connected 3D Rainfall Reef environment. Not a separate Roblox Place.
-- Geometry is all native Roblox Parts; no external assets or unverified mesh IDs.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("RainfallReefRules"))
local reef = Instance.new("Model")
reef.Name = "RainfallReef3D"
reef.Parent = Workspace
local function make(name, size, position, color, material, shape, collidable)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material
    p.CanCollide = collidable ~= false
    if shape then p.Shape = shape end
    p.Parent = reef
    return p
end
local floor = make("ReefWalkableGround", Vector3.new(110,2,110), Vector3.new(455,0,0),
    Color3.fromRGB(68,161,169), Enum.Material.Grass)
reef.PrimaryPart = floor
make("FloatingCoralBedrock", Vector3.new(113,16,113), Vector3.new(455,-12,0),
    Color3.fromRGB(56,95,126), Enum.Material.Slate, Enum.PartType.Ball, false)
-- Walkable bridge connects Thunderhead Ridge's eastern edge at x=370.
make("ReefBridge", Vector3.new(36,2,16), Vector3.new(383,0,0),
    Color3.fromRGB(119,169,172), Enum.Material.Slate)
for _, z in ipairs({-9,9}) do
    make("ReefBridgeRail", Vector3.new(36,3,1), Vector3.new(383,3,z),
        Color3.fromRGB(68,112,136), Enum.Material.Slate)
end
-- Open traversable ground; outer ring is scenery, not an obstacle course.
for i=1,12 do
    local a = i * math.pi / 6
    local x, z = 455 + math.cos(a)*44, math.sin(a)*44
    local coral = make("CoralPillar"..i, Vector3.new(4,9+(i%4)*2,4),
        Vector3.new(x,5+(i%4),z), Color3.fromRGB(90+(i%3)*32,166,187),
        Enum.Material.SmoothPlastic, nil, false)
    coral.Orientation = Vector3.new(0, i*30, 14)
    make("CoralCrown"..i, Vector3.new(7,5,7),
        Vector3.new(x,11+(i%4)*2,z), Color3.fromRGB(116,211,213),
        Enum.Material.Glass, Enum.PartType.Ball, false)
end
-- Waterfall columns are visual only; no touch damage or expensive physics.
for i=1,5 do
    local x = 416+i*15
    local column = make("SkyfallStream"..i, Vector3.new(3,21,3),
        Vector3.new(x,12,45), Color3.fromRGB(115,205,242),
        Enum.Material.Glass, nil, false)
    column.Transparency = 0.45
end
-- Three cooperative exploration beacons: safe, server-validated and per-player.
-- Feedback is session-only; this is NOT claimed as persistent quest progress.
local activated = {}
for _, b in ipairs(Rules.beacons) do
    local pedestal = make(b.id, Vector3.new(7,3,7), Vector3.new(b.x,2,b.z),
        Color3.fromRGB(70,132,156), Enum.Material.Slate)
    local crystal = make(b.id.."_light", Vector3.new(3,7,3), Vector3.new(b.x,7,b.z),
        Color3.fromRGB(126,233,240), Enum.Material.Neon, nil, false)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Attune"
    prompt.ObjectText = "Reef Beacon"
    prompt.HoldDuration = 0.45
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not Rules.canActivate((root.Position-pedestal.Position).Magnitude,
            player:GetAttribute("ProfileReady"), humanoid ~= nil and humanoid.Health > 0) then return end
        local userId = player.UserId
        local seen = activated[userId]
        if not seen then seen = {}; activated[userId] = seen end
        seen[b.id] = true
        local count = 0
        for _, beacon in ipairs(Rules.beacons) do if seen[beacon.id] then count += 1 end end
        player:SetAttribute("ReefBeaconProgress", count)
        player:SetAttribute("ReefBeaconFeedback", count == #Rules.beacons
            and "All Reef Beacons attuned!" or ("Reef beacons: "..count.."/"..#Rules.beacons))
    end)
end
game:GetService("Players").PlayerRemoving:Connect(function(player)
    activated[player.UserId] = nil
end)
