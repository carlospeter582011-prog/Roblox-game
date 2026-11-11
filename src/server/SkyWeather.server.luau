-- Original native 3D weather beacon and shared rotating sky conditions.
-- Uses a server-owned clock; clients cannot request or select weather phases.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Weather = require(ReplicatedStorage:WaitForChild("SkyWeatherRules"))
local beacon = Instance.new("Model")
beacon.Name = "SkyWeatherBeacon3D"
beacon.Parent = Workspace
local function part(name, size, pos, material, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Size = size
    p.Position = pos
    p.Material = material
    p.Color = color
    p.Parent = beacon
    return p
end
part("BeaconPedestal", Vector3.new(5, 1, 5), Vector3.new(-24, 6, -16), Enum.Material.Slate, Color3.fromRGB(85, 95, 135))
local orb = part("WeatherOrb", Vector3.new(3, 3, 3), Vector3.new(-24, 10, -16), Enum.Material.Neon, Color3.fromRGB(120, 195, 255))
orb.Shape = Enum.PartType.Ball
local light = Instance.new("PointLight")
light.Brightness = 0.6
light.Range = 14
light.Parent = orb
local start = os.time()
local lastId
while true do
    local phase, remaining = Weather.phaseAt(os.time() - start)
    if phase.id ~= lastId then
        lastId = phase.id
        orb.Color = Color3.fromRGB(phase.color[1], phase.color[2], phase.color[3])
        Workspace:SetAttribute("SkyWeather", phase.id)
        Workspace:SetAttribute("SkyWeatherLabel", phase.label)
        Workspace:SetAttribute("SkyWeatherCoinsMultiplier", phase.coins)
        Workspace:SetAttribute("SkyWeatherXpMultiplier", phase.xp)
    end
    Workspace:SetAttribute("SkyWeatherSecondsRemaining", math.ceil(remaining))
    task.wait(5)
end
