-- Fourth original Roblox 3D region, connected to Thunderhead Ridge without teleporting.
-- All water is decorative non-collidable geometry; the walkable floor stays solid.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reef = require(ReplicatedStorage:WaitForChild("RainfallReefRules"))
local folder = Instance.new("Model")
folder.Name = "RainfallReef3D"
folder.Parent = Workspace
local function part(name, size, pos, color, material, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, pos
    p.Anchored = true
    p.Color = color
    p.Material = material
    p.CanCollide = collide ~= false
    p.Parent = folder
    return p
end
-- Ridge floor ends at x=370; bridge runs x=367..407, reef begins at x=405.
part("ReefBridgeWalkway", Vector3.new(Reef.bridgeLength, 2, Reef.bridgeWidth),
    Vector3.new(Reef.bridgeCenterX, 0, 0), Color3.fromRGB(109, 163, 170), Enum.Material.Slate)
for _, z in ipairs({-8, 8}) do
    part("ReefBridgeRail", Vector3.new(Reef.bridgeLength, 3, 1),
        Vector3.new(Reef.bridgeCenterX, 3, z), Color3.fromRGB(75, 111, 131), Enum.Material.Slate)
end
local ground = part("ReefWalkableGround", Vector3.new(110, 2, 100),
    Vector3.new(Reef.centerX, 0, 0), Color3.fromRGB(89, 173, 153), Enum.Material.Grass)
folder.PrimaryPart = ground
local underside = part("ReefFloatingBedrock", Vector3.new(114, 15, 104),
    Vector3.new(Reef.centerX, -11, 0), Color3.fromRGB(62, 111, 139), Enum.Material.Slate, false)
underside.Shape = Enum.PartType.Ball
for i = 1, 12 do
    local angle = i * math.pi * 2 / 12
    local radius = 31 + (i % 3) * 5
    local x = Reef.centerX + math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local pool = part("RainPool" .. i, Vector3.new(11 + i % 3 * 2, 0.16, 7 + i % 2 * 3),
        Vector3.new(x, 1.12, z), Color3.fromRGB(69, 173, 218), Enum.Material.Glass, false)
    pool.Transparency = 0.24
    local stone = part("ReefCoralStone" .. i, Vector3.new(2.8, 5 + i % 4, 2.8),
        Vector3.new(x + 5, 3.1, z + 3), Color3.fromRGB(106, 202, 197), Enum.Material.Slate, false)
    stone.Shape = Enum.PartType.Ball
end
for i = 1, 6 do
    local x = Reef.centerX - 27 + (i - 1) * 11
    local marker = part("RainfallColumn" .. i, Vector3.new(2.2, 8 + i % 3 * 2, 2.2),
        Vector3.new(x, 5.5, 39), Color3.fromRGB(111, 184, 212), Enum.Material.Glass, false)
    marker.Transparency = 0.22
end
