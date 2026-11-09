-- First playable prototype: generated entirely from Luau.
-- All objects are created on the server when the place starts.
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local old = Workspace:FindFirstChild("PrototypeWorld")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "PrototypeWorld"
world.Parent = Workspace

local function part(name, size, cf, color, material, parent, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.CanCollide = collide ~= false
    p.Parent = parent or world
    return p
end

local grass = Color3.fromRGB(76, 145, 78)
part("Ground", Vector3.new(280, 2, 280), CFrame.new(0, -1, 0), grass, Enum.Material.Grass)
part("Road", Vector3.new(22, .25, 200), CFrame.new(34, .15, 0), Color3.fromRGB(55, 58, 64), Enum.Material.Asphalt)
for z = -90, 90, 18 do
    part("RoadLine", Vector3.new(.45, .08, 8), CFrame.new(34, .33, z), Color3.fromRGB(255, 222, 95), Enum.Material.Neon, world, false)
end

-- Empty, accessible house with a wide front doorway (front faces +Z).
local house = Instance.new("Folder")
house.Name = "EmptyHouse"
house.Parent = world
local wall = Color3.fromRGB(237, 220, 188)
part("Floor", Vector3.new(30, .5, 26), CFrame.new(-22, .25, -10), Color3.fromRGB(177, 133, 92), Enum.Material.WoodPlanks, house)
part("BackWall", Vector3.new(30, 12, .8), CFrame.new(-22, 6.5, -23), wall, Enum.Material.Brick, house)
part("LeftWall", Vector3.new(.8, 12, 26), CFrame.new(-37, 6.5, -10), wall, Enum.Material.Brick, house)
part("RightWall", Vector3.new(.8, 12, 26), CFrame.new(-7, 6.5, -10), wall, Enum.Material.Brick, house)
part("FrontLeft", Vector3.new(11, 12, .8), CFrame.new(-31.5, 6.5, 3), wall, Enum.Material.Brick, house)
part("FrontRight", Vector3.new(11, 12, .8), CFrame.new(-12.5, 6.5, 3), wall, Enum.Material.Brick, house)
part("FrontAboveDoor", Vector3.new(8, 3, .8), CFrame.new(-22, 11, 3), wall, Enum.Material.Brick, house)
part("Roof", Vector3.new(32, .9, 28), CFrame.new(-22, 13, -10), Color3.fromRGB(124, 58, 53), Enum.Material.Slate, house)
part("PathToDoor", Vector3.new(7, .15, 17), CFrame.new(-22, .12, 12), Color3.fromRGB(193, 190, 181), Enum.Material.Concrete)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "PlayerSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(-22, .5, 25)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(91, 181, 222)
spawn.Parent = world

local function tree(x, z)
    part("Trunk", Vector3.new(2, 10, 2), CFrame.new(x, 5, z), Color3.fromRGB(107, 74, 48), Enum.Material.Wood)
    local canopy = part("Leaves", Vector3.new(11, 11, 11), CFrame.new(x, 12, z), Color3.fromRGB(47, 120, 63), Enum.Material.Grass, world, false)
    canopy.Shape = Enum.PartType.Ball
end
for _, pos in ipairs({{-54, -40}, {-58, 25}, {-8, 48}, {58, -35}, {65, 45}}) do
    tree(pos[1], pos[2])
end

-- Arcade car: a VehicleSeat drives a single anchored assembly by server-side
-- CFrame updates. This avoids relying on external chassis assets.
local car = Instance.new("Model")
car.Name = "TestCar"
car.Parent = world
local carCFrame = CFrame.new(34, 2.1, 13)
local body = part("Body", Vector3.new(7, 1.6, 11), carCFrame, Color3.fromRGB(218, 55, 55), Enum.Material.Metal, car)
car.PrimaryPart = body
-- Sports car model uploaded via Open Cloud under creator 7550783083 (asset 124315115505635).
-- Load only its visual geometry; never run scripts from third-party assets.
-- Keep our own trusted VehicleSeat, driving logic and fallback geometry.
local meshLoaded = false
local ok, assetOrError = pcall(function()
    return game:GetService("InsertService"):LoadAsset(124315115505635)
end)
if ok and assetOrError then
    local assetContainer = assetOrError
    -- Preserve the whole imported car, not just the first MeshPart.
    -- GLB imports can contain dozens of separate mesh parts.
    local visual = Instance.new("Model")
    visual.Name = "SportsCarVisual"
    local meshCount = 0
    for _, descendant in ipairs(assetContainer:GetDescendants()) do
        if descendant:IsA("MeshPart") then
            local piece = descendant:Clone()
            piece.Name = descendant.Name
            -- Preserve colored meshes; color neutral imported meshes by part name.
            local name = descendant.Name:lower()
            local col = descendant.Color
            local neutral = math.abs(col.R - col.G) < .08 and math.abs(col.G - col.B) < .08
            if neutral then
                if name:find("wheel") or name:find("tire") or name:find("tyre") or name:find("rubber") then
                    piece.Color = Color3.fromRGB(30, 33, 40)
                    piece.Material = Enum.Material.Rubber
                elseif name:find("glass") or name:find("window") or name:find("windshield") then
                    piece.Color = Color3.fromRGB(45, 90, 125)
                    piece.Material = Enum.Material.Glass
                    piece.Transparency = .22
                elseif name:find("light") or name:find("lamp") then
                    piece.Color = Color3.fromRGB(255, 239, 190)
                    piece.Material = Enum.Material.Neon
                elseif name:find("rim") or name:find("hub") then
                    piece.Color = Color3.fromRGB(165, 171, 180)
                    piece.Material = Enum.Material.Metal
                else
                    piece.Color = Color3.fromRGB(218, 44, 58)
                    piece.Material = Enum.Material.SmoothPlastic
                end
            end
            -- Never execute scripts supplied with a third-party model.
            for _, child in ipairs(piece:GetDescendants()) do
                if child:IsA("BaseScript") or child:IsA("ModuleScript") then
                    child:Destroy()
                end
            end
            piece.Anchored = true
            piece.CanCollide = false
            piece.CanTouch = false
            piece.CanQuery = false
            piece.Massless = true
            piece.Parent = visual
            meshCount += 1
        end
    end
    if meshCount > 0 then
        visual.Parent = car
        -- Preserve relative geometry of all mesh pieces while scaling.
        local _, initialSize = visual:GetBoundingBox()
        local length = math.max(initialSize.X, initialSize.Z)
        local width = math.min(initialSize.X, initialSize.Z)
        local scale = math.min(10 / math.max(length, .01), 6.5 / math.max(width, .01), 3.2 / math.max(initialSize.Y, .01))
        visual:ScaleTo(scale)
        local bbox, size = visual:GetBoundingBox()
        -- Rotate the longer horizontal axis to the vehicle's Z direction.
        local yaw = size.X > size.Z and math.rad(90) or 0
        local desired = carCFrame * CFrame.new(0, -.45, 0) * CFrame.Angles(0, yaw, 0)
        local centerOffset = CFrame.new(-bbox.Position) -- use world-space translation only
        visual:PivotTo(desired * centerOffset * visual:GetPivot())
        meshLoaded = true
        print("Sports car meshes loaded:", meshCount, "original bounds:", initialSize, "scaled bounds:", size)
    else
        visual:Destroy()
        warn("Sports car asset has no MeshParts; using fallback car.")
    end
    assetContainer:Destroy()
else
    warn("Sports car asset 124315115505635 unavailable to this experience. Grant experience permission to use this asset or transfer ownership; using fallback car.")
end
body.Transparency = meshLoaded and 1 or 0
local cabin = part("Cabin", Vector3.new(6, 1.5, 5), carCFrame * CFrame.new(0, 1.35, -1), Color3.fromRGB(72, 139, 174), Enum.Material.Glass, car)
cabin.Transparency = meshLoaded and 1 or .25
local seat = Instance.new("VehicleSeat")
seat.Name = "DriverSeat"
seat.Size = Vector3.new(2, 1, 2)
seat.CFrame = carCFrame * CFrame.new(0, .15, 1.5)
seat.Anchored = true
seat.CanCollide = false
seat.Transparency = meshLoaded and 1 or 0
seat.MaxSpeed = 35
seat.Torque = 10000
seat.TurnSpeed = 1
seat.Parent = car
for _, x in ipairs({-3.6, 3.6}) do
    for _, z in ipairs({-3.5, 3.5}) do
        local wheel = part("Wheel", Vector3.new(1.4, 2.6, 2.6), carCFrame * CFrame.new(x, -.45, z), Color3.fromRGB(28, 30, 34), Enum.Material.Rubber, car)
        wheel.Shape = Enum.PartType.Cylinder
        wheel.Transparency = meshLoaded and 1 or 0
    end
end
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Drive"
prompt.ObjectText = "Test Car"
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = seat
prompt.Triggered:Connect(function(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and humanoid.Health > 0 and seat.Occupant == nil then
        root.CFrame = seat.CFrame * CFrame.new(0, 2.5, 0)
        task.wait(.1)
        seat:Sit(humanoid)
    end
end)

local RunService = game:GetService("RunService")
local current = car:GetPivot()
RunService.Heartbeat:Connect(function(dt)
    local driver = seat.Occupant
    if not driver then return end
    local throttle = seat.ThrottleFloat
    local steering = seat.SteerFloat
    local speed = 35 * throttle
    local turn = 1.5 * steering * math.min(math.abs(throttle) + .2, 1)
    local step = math.min(dt, .05)
    current = current * CFrame.Angles(0, -turn * step, 0) * CFrame.new(0, 0, -speed * step)
    local position = current.Position
    current = CFrame.new(math.clamp(position.X, -125, 125), 2.1, math.clamp(position.Z, -125, 125)) * current.Rotation
    car:PivotTo(current)
end)

print("PrototypeWorld ready: house, road, spawn and drivable sports car; mesh loaded:", meshLoaded)
