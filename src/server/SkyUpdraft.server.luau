-- Three native 3D sky updrafts for useful aerial traversal across the connected islands.
-- Server owns activation, unlocks, direction, impulse and cooldown. No client remotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyUpdraftRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local folder = Instance.new("Folder")
folder.Name = "SkyUpdraftStations3D"
folder.Parent = Workspace
local lastUse = {}
local function makePart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Parent = parent
    return part
end
for id, station in pairs(Rules.STATIONS) do
    local model = Instance.new("Model")
    model.Name = "SkyUpdraft_" .. id
    model.Parent = folder
    local center = Vector3.new(station.x, station.y, station.z)
    local disc = makePart(model, "LaunchDisc", Vector3.new(1, 10, 10), center,
        Color3.fromRGB(89, 171, 217), Enum.Material.Glass)
    disc.Shape = Enum.PartType.Cylinder
    disc.Orientation = Vector3.new(0, 0, 90)
    disc.Transparency = 0.25
    for i = 1, 4 do
        local angle = i * math.pi / 2
        local offset = Vector3.new(math.cos(angle) * 4, 0, math.sin(angle) * 4)
        local pillar = makePart(model, "WindPillar" .. i, Vector3.new(1.1, 6, 1.1),
            center + offset + Vector3.new(0, 3), Color3.fromRGB(146, 221, 243), Enum.Material.Neon)
        pillar.Transparency = 0.25
    end
    local anchor = makePart(model, "WindCore", Vector3.new(2.5, 2.5, 2.5),
        center + Vector3.new(0, 3), Color3.fromRGB(205, 244, 255), Enum.Material.Neon)
    anchor.Shape = Enum.PartType.Ball
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LaunchUpdraft"
    prompt.ActionText = "Ride Wind"
    prompt.ObjectText = id .. " Updraft"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.3
    prompt.RequiresLineOfSight = false
    prompt.Parent = anchor
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid then return end
        local now = os.clock()
        local distance = (root.Position - anchor.Position).Magnitude
        local allowed, reason = Rules.canLaunch(id, distance, profile.captures, now - (lastUse[player] or -1e9),
            player:GetAttribute("ProfileReady"), humanoid.Health > 0 and humanoid.Sit == false)
        if not allowed then
            if reason == "locked" then
                player:SetAttribute("UpdraftFeedback", "Collect " .. station.unlock .. " clouds to unlock this wind!")
            elseif reason == "cooldown" then
                player:SetAttribute("UpdraftFeedback", "Wind recharging...")
            end
            return
        end
        lastUse[player] = now
        -- Directed toward the next island; the final ridge pad returns toward Eastwind.
        local direction = id == "ridge" and Vector3.new(-1, 0, 0) or Vector3.new(1, 0, 0)
        root.AssemblyLinearVelocity = direction * station.horizontal + Vector3.new(0, station.vertical, 0)
        player:SetAttribute("UpdraftFeedback", "Sky wind launched!")
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
