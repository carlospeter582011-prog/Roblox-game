-- Original physical sky checkpoint beacons; server-authoritative fall recovery.
-- Session-only checkpoint selection is intentional: every rejoin starts safely at Meadow.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRescueRules"))
local checkpoints = {}
local lastRescue = {}
local stations = Instance.new("Folder")
stations.Name = "SkyRescueCheckpoints3D"
stations.Parent = Workspace

local function makePart(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Color = color
    p.Material = material
    p.Parent = parent
    return p
end

for _, id in ipairs({ "meadow", "eastwind", "ridge" }) do
    local point = Rules.CHECKPOINTS[id]
    local position = Vector3.new(point.x, 1.2, point.z)
    local model = Instance.new("Model")
    model.Name = id .. "RescueBeacon3D"
    model.Parent = stations
    makePart(model, "Base", Vector3.new(6, 1, 6), position,
        Color3.fromRGB(71, 112, 149), Enum.Material.Slate)
    local crystal = makePart(model, "BeaconCrystal", Vector3.new(2, 5, 2),
        position + Vector3.new(0, 3, 0),
        Color3.fromRGB(118, 225, 239), Enum.Material.Glass)
    crystal.Shape = Enum.PartType.Ball
    local light = Instance.new("PointLight")
    light.Brightness = 1.1
    light.Range = 13
    light.Parent = crystal
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Set checkpoint"
    prompt.ObjectText = id .. " rescue beacon"
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.3
    prompt.Parent = crystal
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid then return end
        if Rules.canActivate(id, (root.Position - crystal.Position).Magnitude, humanoid.Health > 0) then
            checkpoints[player] = id
            player:SetAttribute("SkyRescueCheckpoint", id)
        end
    end)
end

local function rescue(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid then return end
    local now = os.clock()
    if not Rules.shouldRescue(root.Position.Y, now, lastRescue[player], humanoid.Health > 0) then return end
    lastRescue[player] = now
    local destination = Rules.safeCheckpoint(checkpoints[player])
    -- PivotTo moves the complete character without trusting client-supplied coordinates.
    character:PivotTo(CFrame.new(destination.x, destination.y, destination.z))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    player:SetAttribute("SkyRescueFeedback", "Returned to " .. (checkpoints[player] or "meadow") .. " checkpoint")
end

Players.PlayerAdded:Connect(function(player)
    checkpoints[player] = "meadow"
    player:SetAttribute("SkyRescueCheckpoint", "meadow")
    player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            while player.Parent and player.Character == character do
                rescue(player, character)
                task.wait(0.2)
            end
        end)
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    checkpoints[player] = nil
    lastRescue[player] = nil
end)
