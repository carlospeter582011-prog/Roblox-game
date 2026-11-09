-- Original procedural starter environment; all geometry created in Roblox, no external licenses.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local WorldAssetModels = require(script.Parent:WaitForChild("WorldAssetModels"))
local CrystalRules = require(game:GetService("ReplicatedStorage"):WaitForChild("CrystalRules"))
local Players = game:GetService("Players")
local crystalDiscoveries = {} -- [UserId] = {[index] = true}; bounded per-player session state
Players.PlayerRemoving:Connect(function(player)
    crystalDiscoveries[player.UserId] = nil
end)
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
    -- Session-only discovery; do not grant currency or claim quest persistence here.
    local target = crystal and (crystal:IsA("BasePart") and crystal or crystal:FindFirstChildWhichIsA("BasePart", true))
    if target then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "DiscoverCrystal"
        prompt.ActionText = "Discover"
        prompt.ObjectText = "Sky Crystal"
        prompt.MaxActivationDistance = 10
        prompt.HoldDuration = 0.35
        prompt.RequiresLineOfSight = false
        prompt.Parent = target
        local crystalId = "sky-crystal-" .. tostring(i)
        prompt.Triggered:Connect(function(player)
            if not player or not player:IsA("Player") or not player.Parent then return end
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root or not humanoid or humanoid.Health <= 0 then return end
            local discovered = crystalDiscoveries[player.UserId]
            if not discovered then
                discovered = {}
                crystalDiscoveries[player.UserId] = discovered
            end
            local distance = (root.Position - target.Position).Magnitude
            if not CrystalRules.canDiscover(i, distance, discovered[i], player:GetAttribute("ProfileReady")) then
                return
            end
            discovered[i] = true
            player:SetAttribute("SkyCrystalsDiscovered", CrystalRules.count(discovered))
            player:SetAttribute("LastSkyCrystal", crystalId)
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
for _, x in ipairs({ -24, -12, 0, 12, 24 }) do
    WorldAssetModels.skyLantern(world, Vector3.new(x, 1, -43), 0.75)
end
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
