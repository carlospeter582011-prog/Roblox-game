-- Original procedural starter environment; all geometry created in Roblox, no external licenses.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local WorldAssetModels = require(script.Parent:WaitForChild("WorldAssetModels"))
local CrystalRules = require(game:GetService("ReplicatedStorage"):WaitForChild("CrystalRules"))
local Players = game:GetService("Players")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local world = Instance.new("Folder")
world.Name = "CatchACloudStarterIsland"
world.Parent = Workspace
local function part(name,size,position,color,material,parent)
    local p = Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=position
    p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=color
    p.Parent=parent or world
    return p
end
local base=part("FloatingMeadow",Vector3.new(225,5,225),Vector3.new(0,-3,0),Color3.fromRGB(104,184,125),Enum.Material.Grass)
base.Shape=Enum.PartType.Cylinder
base.Orientation=Vector3.new(0,0,90)
base.CanCollide = false
-- Main safe walkable square over a sculpted underside.
part("WalkableMeadow",Vector3.new(205,2,205),Vector3.new(0,0,0),Color3.fromRGB(102,191,134),Enum.Material.Grass)
WorldAssetModels.floatingRock(world, Vector3.new(0, -15, 0))
-- Sculpted underside silhouette: staggered 3D slate ledges and smaller hanging rock islands.
for i = 1, 12 do
    local angle = i * math.pi * 2 / 12
    local radius = 88 + (i % 3) * 4
    local ledge = part("CliffLedge" .. i,
        Vector3.new(17 + (i % 3) * 4, 8 + (i % 4) * 2, 14 + (i % 2) * 4),
        Vector3.new(math.cos(angle) * radius, -8 - (i % 3) * 3, math.sin(angle) * radius),
        Color3.fromRGB(100 + (i % 3) * 8, 112, 131), Enum.Material.Slate)
    ledge.Shape = Enum.PartType.Ball
    ledge.CanCollide = false
end
for i=1,14 do
    local angle=i*math.pi*2/14
    local x,z=math.cos(angle)*82,math.sin(angle)*82
    WorldAssetModels.tree(world, Vector3.new(x, 1, z), 0.85 + (i % 4) * 0.08)
end
for i=1,18 do
    local angle=i*2.399963
    local radius=28+math.sqrt(i)*11
    local crystal = WorldAssetModels.crystal(world, Vector3.new(math.cos(angle)*radius, 1, math.sin(angle)*radius), 0.7 + (i % 4) * 0.15)
    -- Server-owned interactive 3D discovery. ProximityPrompt supports touch and gamepad.
    -- Discovery is server-authoritative and saved with the player profile.
    local target = crystal and (crystal:IsA("BasePart") and crystal or crystal:FindFirstChild("CrystalShard1", true))
    if target then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "DiscoverCrystal"
        prompt.ActionText = "Discover"
        prompt.ObjectText = "Sky Crystal"
        prompt.MaxActivationDistance = 16
        prompt.MaxIndicatorDistance = 24
        prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
        prompt.HoldDuration = 0.35
        prompt.RequiresLineOfSight = false
        -- Put the prompt above the crystal rather than inside the glowing shard.
        local anchor = Instance.new("Attachment")
        anchor.Name = "DiscoveryPromptAnchor"
        anchor.Position = Vector3.new(0, target.Size.Y * 0.5 + 1.5, 0)
        anchor.Parent = target
        prompt.Parent = anchor
        local crystalId = "sky-crystal-" .. tostring(i)
        prompt.Triggered:Connect(function(player)
            if not player or not player:IsA("Player") or not player.Parent then return end
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root or not humanoid or humanoid.Health <= 0 then return end
            local profile = Profile.Get(player)
            local discovered = profile and profile.crystals or {}
            local distance = (root.Position - target.Position).Magnitude
            if not CrystalRules.canDiscover(i, distance, discovered[i], player:GetAttribute("ProfileReady")) then
                return
            end
            local awarded = Profile.DiscoverCrystal(player, i)
            if awarded then
                player:SetAttribute("CrystalDiscoveryFeedback", "Crystal " .. i .. " discovered! +10 Coins +5 XP")
            end
        end)
    end
end
-- Four original 3D stone arches frame the meadow paths; no Canvas or asset IDs needed.
for _, placement in ipairs({
    { Vector3.new(0, 1, -65), 0 },
    { Vector3.new(0, 1, 65), 0 },
    { Vector3.new(-65, 1, 0), math.pi / 2 },
    { Vector3.new(65, 1, 0), math.pi / 2 },
}) do
    WorldAssetModels.skyArch(world, placement[1], 0.75, placement[2])
end
-- Original 3D lanterns mark the route from spawn to the central catching meadow.
-- Keep the path open for touch users and preserve the actual world as 3D geometry.
-- Keep the middle sightline unobstructed; no central lantern post.
for _, x in ipairs({ -24, -12, 12, 24 }) do
    WorldAssetModels.skyLantern(world, Vector3.new(x, 1, -43), 0.75)
end
-- Eastwind Outlook: a second fully walkable 3D island connected to the starter meadow.
-- Original Roblox Parts and Models only; no in-world Canvas or unverified mesh IDs.
local outlook = Instance.new("Model")
outlook.Name = "EastwindOutlook3D"
outlook.Parent = world
local outlookFloor = part("OutlookWalkableGround", Vector3.new(100, 2, 100),
    Vector3.new(170, 0, 0), Color3.fromRGB(123, 180, 154), Enum.Material.Grass, outlook)
local outlookRock = part("OutlookFloatingRock", Vector3.new(105, 14, 105),
    Vector3.new(170, -9, 0), Color3.fromRGB(92, 112, 133), Enum.Material.Slate, outlook)
outlookRock.Shape = Enum.PartType.Ball
outlookRock.CanCollide = false
-- Bridge overlaps both island edges, so players can cross without jumping.
local bridge = part("EastwindBridgeWalkway", Vector3.new(42, 2, 14),
    Vector3.new(111, 0, 0), Color3.fromRGB(161, 123, 89), Enum.Material.WoodPlanks, outlook)
for _, z in ipairs({ -8, 8 }) do
    local rail = part("EastwindBridgeRail", Vector3.new(42, 3, 1),
        Vector3.new(111, 3, z), Color3.fromRGB(111, 82, 64), Enum.Material.Wood, outlook)
    rail.CanCollide = true
end
for i = 1, 8 do
    local angle = i * math.pi / 4
    local position = Vector3.new(170 + math.cos(angle) * 34, 1, math.sin(angle) * 34)
    WorldAssetModels.tree(outlook, position, 0.7 + (i % 3) * 0.12)
end
for i = 1, 4 do
    local angle = i * math.pi / 2
    WorldAssetModels.floatingRock(outlook,
        Vector3.new(170 + math.cos(angle) * 46, -13, math.sin(angle) * 46))
end
WorldAssetModels.skyArch(outlook, Vector3.new(170, 1, 0), 0.95, math.pi / 2)
for _, z in ipairs({ -20, 20 }) do
    WorldAssetModels.skyLantern(outlook, Vector3.new(145, 1, z), 0.75)
end
outlook.PrimaryPart = outlookFloor

-- Thunderhead Ridge: third connected, walkable 3D region with distinct storm landmarks.
-- The bridge overlaps Eastwind Outlook (edge x=220) and Ridge (edge x=260).
local ridge = Instance.new("Model")
ridge.Name = "ThunderheadRidge3D"
ridge.Parent = world
local ridgeFloor = part("RidgeWalkableGround", Vector3.new(110, 2, 100),
    Vector3.new(315, 0, 0), Color3.fromRGB(99, 138, 154), Enum.Material.Slate, ridge)
local ridgeUnder = part("RidgeFloatingBedrock", Vector3.new(112, 16, 104),
    Vector3.new(315, -11, 0), Color3.fromRGB(72, 85, 116), Enum.Material.Slate, ridge)
ridgeUnder.Shape = Enum.PartType.Ball
ridgeUnder.CanCollide = false
part("StormBridgeWalkway", Vector3.new(54, 2, 14),
    Vector3.new(240, 0, 0), Color3.fromRGB(126, 130, 150), Enum.Material.Slate, ridge)
for _, z in ipairs({ -8, 8 }) do
    part("StormBridgeRail", Vector3.new(54, 3, 1),
        Vector3.new(240, 3, z), Color3.fromRGB(76, 90, 119), Enum.Material.Slate, ridge)
end
for i = 1, 9 do
    local angle = i * math.pi * 2 / 9
    local radius = 34
    local x = 315 + math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local pillar = part("StormSpire" .. i,
        Vector3.new(3.5, 10 + (i % 4) * 3, 3.5),
        Vector3.new(x, 6 + (i % 4) * 1.5, z),
        Color3.fromRGB(112, 151, 189), Enum.Material.Slate, ridge)
    pillar.CanCollide = false
    local crown = part("SpireCrown" .. i, Vector3.new(5, 5, 5),
        pillar.Position + Vector3.new(0, pillar.Size.Y / 2 + 2, 0),
        Color3.fromRGB(132, 189, 218), Enum.Material.Glass, ridge)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
end
WorldAssetModels.skyArch(ridge, Vector3.new(315, 1, 0), 0.85, math.pi / 2)
for _, z in ipairs({ -22, 22 }) do
    WorldAssetModels.skyLantern(ridge, Vector3.new(285, 1, z), 0.7)
end
ridge.PrimaryPart = ridgeFloor

-- Sunset Dunes: fourth traversable native 3D region; warm sandstone formations.
-- Ridge edge x=370, Dunes edge x=405; bridge overlaps both ends.
local dunes = Instance.new("Model")
dunes.Name = "SunsetDunes3D"
dunes.Parent = world
local dunesFloor = part("DunesWalkableGround", Vector3.new(110, 2, 105),
    Vector3.new(460, 0, 0), Color3.fromRGB(203, 165, 105), Enum.Material.Sand, dunes)
local dunesRock = part("DunesFloatingBedrock", Vector3.new(114, 16, 109),
    Vector3.new(460, -10, 0), Color3.fromRGB(138, 98, 83), Enum.Material.Sandstone, dunes)
dunesRock.Shape = Enum.PartType.Ball
dunesRock.CanCollide = false
part("SunsetBridgeWalkway", Vector3.new(42, 2, 15),
    Vector3.new(387, 0, 0), Color3.fromRGB(163, 119, 95), Enum.Material.Sandstone, dunes)
for _, z in ipairs({ -8, 8 }) do
    part("SunsetBridgeRail", Vector3.new(42, 3, 1),
        Vector3.new(387, 3, z), Color3.fromRGB(129, 92, 79), Enum.Material.Sandstone, dunes)
end
-- Landmarks are anchored native Roblox Parts, never HUD or unlicensed meshes.
for i = 1, 8 do
    local angle = i * math.pi / 4
    local radius = 32 + (i % 2) * 5
    local x = 460 + math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local pillarHeight = 9 + (i % 4) * 3
    local spire = part("DuneSandstoneSpire" .. i, Vector3.new(5, pillarHeight, 5),
        Vector3.new(x, pillarHeight / 2 + 1, z),
        Color3.fromRGB(178 + (i % 3) * 7, 129, 91), Enum.Material.Sandstone, dunes)
    spire.CanCollide = false
    local cap = part("DuneSpireCap" .. i, Vector3.new(7, 2, 7),
        Vector3.new(x, pillarHeight + 1, z), Color3.fromRGB(221, 171, 113), Enum.Material.Sandstone, dunes)
    cap.CanCollide = false
end
WorldAssetModels.skyArch(dunes, Vector3.new(460, 1, 0), 0.95, math.pi / 2)
for _, z in ipairs({ -24, 24 }) do
    WorldAssetModels.skyLantern(dunes, Vector3.new(432, 1, z), 0.7)
end
dunes.PrimaryPart = dunesFloor

local spawn=Instance.new("SpawnLocation")
spawn.Name="SkyArrival"
spawn.Size=Vector3.new(12,1,12)
spawn.Position=Vector3.new(0,2,-25)
spawn.Anchored=true
spawn.Neutral=true
spawn.Material=Enum.Material.SmoothPlastic
spawn.Color=Color3.fromRGB(123,193,172)
spawn.Transparency = 0.35
spawn.Parent=world
Lighting.ClockTime=14
Lighting.Brightness=1.5
Lighting.Ambient=Color3.fromRGB(115,142,173)
Lighting.OutdoorAmbient=Color3.fromRGB(145,175,197)
