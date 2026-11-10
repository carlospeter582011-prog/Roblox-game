-- World travel stations are native 3D geometry, not Canvas stand-ins.
-- Travel eligibility is derived from persistent catch count; the server never trusts a client destination.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local SpawnRules = require(ReplicatedStorage:WaitForChild("SpawnRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local stations = Instance.new("Folder")
stations.Name = "CloudTravelStations3D"
stations.Parent = Workspace
local lastTravel = {}

local function makeStation(id, label, x, z, color)
    local base = Instance.new("Part")
    base.Name = label .. "Platform3D"
    base.Size = Vector3.new(10, 1, 10)
    base.Position = Vector3.new(x, 1.8, z)
    base.Anchored = true
    base.Color = color
    base.Material = Enum.Material.Slate
    base.Parent = stations

    local beacon = Instance.new("Part")
    beacon.Name = label .. "Beacon3D"
    beacon.Shape = Enum.PartType.Ball
    beacon.Size = Vector3.new(3, 5, 3)
    beacon.Position = Vector3.new(x, 5, z)
    beacon.Anchored = true
    beacon.CanCollide = false
    beacon.Material = Enum.Material.Glass
    beacon.Color = color
    beacon.Parent = stations

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "TravelTo" .. label
    prompt.ActionText = "Travel"
    prompt.ObjectText = label
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = beacon

    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - beacon.Position).Magnitude > 15 then return end
        local now = os.clock()
        if now - (lastTravel[player] or -100) < 2 then return end
        lastTravel[player] = now
        if not SpawnRules.canFastTravel(id, profile.captures) then
            player:SetAttribute("TravelFeedback", label .. " unlocks at " ..
                tostring(SpawnRules.travelDestinations[id].requiredCatches) .. " catches")
            return
        end
        local destination = SpawnRules.travelDestinations[id]
        character:PivotTo(CFrame.new(destination.x, destination.y, destination.z))
        player:SetAttribute("TravelFeedback", "Arrived at " .. label)
    end)
end

-- Every island has a station; cross-island travel is a deliberate earned shortcut.
makeStation("starter", "Starter Meadow", -16, -42, Color3.fromRGB(99, 205, 167))
makeStation("eastwind", "Eastwind Outlook", 0, -42, Color3.fromRGB(122, 184, 230))
makeStation("ridge", "Thunderhead Ridge", 16, -42, Color3.fromRGB(174, 151, 230))
-- Return stations allow players who explored by bridge to return without retracing the route.
makeStation("starter", "Eastwind Return", 154, -18, Color3.fromRGB(99, 205, 167))
makeStation("starter", "Ridge Return", 295, -18, Color3.fromRGB(99, 205, 167))
Players.PlayerRemoving:Connect(function(player) lastTravel[player] = nil end)
