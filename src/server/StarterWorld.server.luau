-- Original procedural starter environment; all geometry created in Roblox, no external licenses.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
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
local underside=part("FloatingRock",Vector3.new(72,20,72),Vector3.new(0,-15,0),Color3.fromRGB(95,106,135),Enum.Material.Slate)
underside.Shape=Enum.PartType.Ball
for i=1,14 do
    local angle=i*math.pi*2/14
    local x,z=math.cos(angle)*37,math.sin(angle)*37
    local trunk=part("SkyTreeTrunk",Vector3.new(2,12,2),Vector3.new(x,7,z),Color3.fromRGB(112,76,76),Enum.Material.Wood)
    local canopy=part("SkyTreeCanopy",Vector3.new(11,11,11),trunk.Position+Vector3.new(0,8,0),Color3.fromRGB(130,215,194),Enum.Material.SmoothPlastic)
    canopy.Shape=Enum.PartType.Ball
end
for i=1,18 do
    local angle=i*2.399963
    local radius=12+math.sqrt(i)*6
    local crystal=part("LuminousCrystal",Vector3.new(2,math.random(4,9),2),Vector3.new(math.cos(angle)*radius,4,math.sin(angle)*radius),Color3.fromRGB(156,136,247),Enum.Material.Neon)
    crystal.Orientation=Vector3.new(0,math.random(0,180),20)
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
