-- Original procedural starter environment; all geometry created in Roblox, no external licenses.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local WorldAssetModels = require(script.Parent:WaitForChild("WorldAssetModels"))
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
local base=part("FloatingMeadow",Vector3.new(115,5,115),Vector3.new(0,-3,0),Color3.fromRGB(104,184,125),Enum.Material.Grass)
base.Shape=Enum.PartType.Cylinder
base.Orientation=Vector3.new(0,0,90)
-- Main safe walkable square over a sculpted underside.
part("WalkableMeadow",Vector3.new(95,2,95),Vector3.new(0,0,0),Color3.fromRGB(102,191,134),Enum.Material.Grass)
WorldAssetModels.floatingRock(world, Vector3.new(0, -15, 0))
for i=1,14 do
    local angle=i*math.pi*2/14
    local x,z=math.cos(angle)*37,math.sin(angle)*37
    WorldAssetModels.tree(world, Vector3.new(x, 1, z), 0.85 + (i % 4) * 0.08)
end
for i=1,18 do
    local angle=i*2.399963
    local radius=12+math.sqrt(i)*6
    WorldAssetModels.crystal(world, Vector3.new(math.cos(angle)*radius, 1, math.sin(angle)*radius), 0.7 + (i % 4) * 0.15)
end
-- Four original 3D stone arches frame the meadow paths; no Canvas or asset IDs needed.
for _, placement in ipairs({
    { Vector3.new(0, 1, -29), 0 },
    { Vector3.new(0, 1, 29), 0 },
    { Vector3.new(-29, 1, 0), math.pi / 2 },
    { Vector3.new(29, 1, 0), math.pi / 2 },
}) do
    WorldAssetModels.skyArch(world, placement[1], 0.75, placement[2])
end
local spawn=Instance.new("SpawnLocation")
spawn.Name="SkyArrival"
spawn.Size=Vector3.new(12,1,12)
spawn.Position=Vector3.new(0,2,0)
spawn.Anchored=true
spawn.Neutral=true
spawn.Material=Enum.Material.Neon
spawn.Color=Color3.fromRGB(128,222,247)
spawn.Parent=world
Lighting.ClockTime=14
Lighting.Brightness=2.5
Lighting.Ambient=Color3.fromRGB(145,170,218)
Lighting.OutdoorAmbient=Color3.fromRGB(166,197,235)
