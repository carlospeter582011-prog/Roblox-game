-- Seven additional explorable 3D archipelago regions, each reached via server-validated portals.
-- This adds physical destinations, NOT seven complete story worlds or separate Roblox Places.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("OuterWorldRules"))
local WorldCatalog = require(ReplicatedStorage:WaitForChild("WorldCatalog"))
local regions = Instance.new("Folder")
regions.Name = "OuterWorldExpeditions3D"
regions.Parent = Workspace
local lastUse = {}
local palette = {
    Color3.fromRGB(216, 155, 98), Color3.fromRGB(174, 215, 234),
    Color3.fromRGB(115, 193, 130), Color3.fromRGB(138, 112, 199),
    Color3.fromRGB(95, 112, 169), Color3.fromRGB(105, 91, 141),
    Color3.fromRGB(219, 185, 132),
}
local function part(parent, name, size, pos, color, material, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material
    p.CanCollide = collide ~= false
    p.Parent = parent
    return p
end
local function portal(parent, name, pos, color, destination, requiredCatches)
    local pad = part(parent, name .. "Pad", Vector3.new(12, 1, 12),
        pos, color, Enum.Material.Slate, true)
    local beacon = part(parent, name .. "Beacon", Vector3.new(4, 6, 4),
        pos + Vector3.new(0, 4, 0), color, Enum.Material.Glass, false)
    beacon.Shape = Enum.PartType.Ball
    for _, side in ipairs({-1, 1}) do
        part(parent, name .. "ArchPillar", Vector3.new(1.5, 9, 1.5),
            pos + Vector3.new(side * 5, 5, 0), color, Enum.Material.Slate, false)
    end
    part(parent, name .. "ArchTop", Vector3.new(12, 1.5, 1.5),
        pos + Vector3.new(0, 10, 0), color, Enum.Material.Slate, false)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Travel"
    prompt.ObjectText = name
    prompt.HoldDuration = 0.45
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = beacon
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid then return end
        local now = os.clock()
        if now - (lastUse[player] or -100) < 2 then return end
        if not Rules.canActivate(destination.id, profile.captures,
            (root.Position - beacon.Position).Magnitude, humanoid.Health > 0, WorldCatalog) then
            player:SetAttribute("TravelFeedback", name .. " requires " .. requiredCatches .. " catches")
            return
        end
        lastUse[player] = now
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        character:PivotTo(CFrame.new(destination.x, 5, destination.z))
        player:SetAttribute("TravelFeedback", "Arrived at " .. destination.name)
    end)
    return pad
end
local hub = Instance.new("Folder")
hub.Name = "OuterWorldDeparturePortals"
hub.Parent = regions
local entries = Rules.entries(WorldCatalog)
for index, entry in ipairs(entries) do
    local color = palette[index]
    local model = Instance.new("Model")
    model.Name = entry.name:gsub(" ", "") .. "3D"
    model.Parent = regions
    local center = Vector3.new(entry.x, 0, entry.z)
    part(model, "WalkableGround", Vector3.new(120, 3, 115),
        center, color, Enum.Material.Grass, true)
    local underside = part(model, "FloatingBedrock", Vector3.new(125, 16, 120),
        center - Vector3.new(0, 11, 0), Color3.fromRGB(84, 88, 111), Enum.Material.Slate, false)
    underside.Shape = Enum.PartType.Ball
    -- Seven distinct landmark silhouettes, with a bounded static part budget.
    for i = 1, 9 do
        local angle = i * math.pi * 2 / 9
        local radius = 33 + (i % 2) * 6
        local height = 10 + ((i + index) % 5) * 4
        local marker = part(model, "WorldLandmark" .. i, Vector3.new(5, height, 5),
            center + Vector3.new(math.cos(angle) * radius, height / 2 + 1.5,
                math.sin(angle) * radius), color, Enum.Material.Slate, false)
        if index == 2 or index == 4 or index == 7 then
            marker.Shape = Enum.PartType.Ball
        end
        local cap = part(model, "LandmarkCrystal" .. i, Vector3.new(4, 5, 4),
            marker.Position + Vector3.new(0, height / 2 + 2, 0),
            color, Enum.Material.Glass, false)
        cap.Shape = Enum.PartType.Ball
    end
    local arrival = {id = entry.id, name = entry.name, x = entry.x, z = entry.z}
    portal(hub, entry.name, Vector3.new(-70 + (index - 1) * 22, 2, 79),
        color, arrival, entry.requiredCatches)
    -- Return portals use the same unlock checks; once unlocked, return is safe.
    portal(model, "Return to Sky Meadow", center + Vector3.new(0, 2.5, -35),
        color, {id = entry.id, name = "Sky Meadow", x = 0, z = -25}, entry.requiredCatches)
end
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
