-- Original 3D wind shrines: earned short-duration vertical traversal, never client-directed flight.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyUpdraftRules"))

local folder = Instance.new("Folder")
folder.Name = "SkyUpdraftShrines3D"
folder.Parent = Workspace
local lastUse = {}
local active = {}

local function makePart(name, size, position, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Parent = parent
    return part
end

for id, station in pairs(Rules.STATIONS) do
    local model = Instance.new("Model")
    model.Name = id .. "Updraft3D"
    model.Parent = folder
    local center = Vector3.new(station.x, station.y, station.z)
    local base = makePart("WindPedestal", Vector3.new(7, 0.5, 7), center, Color3.fromRGB(93, 195, 222), model)
    base.Material = Enum.Material.SmoothPlastic
    for i = 1, 5 do
        local angle = i * math.pi * 2 / 5
        local orb = makePart("WindMote" .. i, Vector3.new(1, 1, 1),
            center + Vector3.new(math.cos(angle) * 2.5, 1.2 + i * 0.65, math.sin(angle) * 2.5),
            Color3.fromRGB(150, 240, 255), model)
        orb.Shape = Enum.PartType.Ball
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "InvokeUpdraft"
    prompt.ActionText = "Ride wind"
    prompt.ObjectText = id .. " updraft (" .. station.requiredCatches .. " catches)"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = base

    prompt.Triggered:Connect(function(player)
        local data = Profile.Get(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not data or not humanoid or not root then return end
        local now = os.clock()
        if not Rules.canActivate(id, data.captures,
            (root.Position - center).Magnitude, humanoid.Health > 0,
            player:GetAttribute("ProfileReady"), now, lastUse[player]) then
            player:SetAttribute("TravelFeedback", "Updraft locked or cooling down")
            return
        end
        -- Do not stack buffs or restore a previous character's movement settings.
        if active[player] then
            player:SetAttribute("TravelFeedback", "Wind boost already active")
            return
        end
        lastUse[player] = now
        local previousPower, previousHeight = humanoid.JumpPower, humanoid.JumpHeight
        local token = {}
        active[player] = token
        humanoid.JumpPower = math.max(previousPower, station.jumpPower)
        humanoid.JumpHeight = math.max(previousHeight, station.jumpHeight)
        player:SetAttribute("TravelFeedback", "Updraft active: jump higher for 7 seconds!")
        task.delay(Rules.DURATION, function()
            if active[player] ~= token then return end
            active[player] = nil
            if humanoid.Parent and humanoid.Health > 0 then
                humanoid.JumpPower = previousPower
                humanoid.JumpHeight = previousHeight
            end
        end)
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
    active[player] = nil
end)
