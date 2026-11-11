-- Original 3D Sky Compass: a repeatable exploration tool that points to the nearest
-- currently catchable cloud. Server-owned target selection, no client-supplied IDs.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Rules = require(ReplicatedStorage:WaitForChild("SkyCompassRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))

local compass = Instance.new("Model")
compass.Name = "SkyCompass3D"
local pedestal = Instance.new("Part")
pedestal.Name = "CompassPedestal"
pedestal.Anchored = true
pedestal.Size = Vector3.new(5, 2, 5)
pedestal.Shape = Enum.PartType.Cylinder
pedestal.Material = Enum.Material.Slate
pedestal.Color = Color3.fromRGB(62, 100, 137)
pedestal.Position = Vector3.new(16, 5, 4)
pedestal.Parent = compass
local needle = Instance.new("Part")
needle.Name = "CompassNeedle"
needle.Anchored = true
needle.CanCollide = false
needle.Size = Vector3.new(0.6, 0.6, 4)
needle.Material = Enum.Material.SmoothPlastic
needle.Color = Color3.fromRGB(255, 204, 88)
needle.CFrame = CFrame.new(16, 6.5, 4)
needle.Parent = compass
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Locate nearest cloud"
prompt.ObjectText = "Sky Compass"
prompt.MaxActivationDistance = 11
prompt.HoldDuration = 0.35
prompt.RequiresLineOfSight = false
prompt.Parent = pedestal
compass.Parent = Workspace

local lastScan = {}
local function scan(player)
    local profile = ProfileStore.Get(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local now = os.clock()
    if not root or not humanoid or (root.Position - pedestal.Position).Magnitude > 13 then return end
    if not Rules.canScan(now, lastScan[player], humanoid.Health > 0, profile ~= nil) then return end
    local folder = Workspace:FindFirstChild("CatchableClouds")
    if not folder then return end
    local distances, candidates = {}, {}
    for _, cloud in ipairs(folder:GetChildren()) do
        if cloud:IsA("BasePart") and cloud:GetAttribute("CloudId") and cloud:GetAttribute("SpeciesId") then
            local id = cloud:GetAttribute("CloudId")
            if type(id) == "string" and #id <= 24 then
                distances[id] = (root.Position - cloud.Position).Magnitude
                candidates[id] = cloud
            end
        end
    end
    local targetId, distance = Rules.nearest(distances)
    lastScan[player] = now
    if not targetId then
        player:SetAttribute("CompassHint", "No cloud within 180 studs")
        return
    end
    local target = candidates[targetId]
    if not target or not target.Parent then return end
    -- A short-lived native 3D beam. No world Canvas/ScreenGui stand-ins.
    local origin = Instance.new("Attachment")
    origin.Name = "SkyCompassOrigin"
    origin.Parent = pedestal
    local destination = Instance.new("Attachment")
    destination.Name = "SkyCompassTarget"
    destination.Parent = target
    local beam = Instance.new("Beam")
    beam.Name = "SkyCompassGuide"
    beam.Attachment0 = origin
    beam.Attachment1 = destination
    beam.Width0 = 0.35
    beam.Width1 = 0.1
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 217, 119))
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = pedestal
    Debris:AddItem(beam, Rules.MARK_SECONDS)
    Debris:AddItem(origin, Rules.MARK_SECONDS)
    Debris:AddItem(destination, Rules.MARK_SECONDS)
    player:SetAttribute("CompassHint", string.format("Nearest cloud: %d studs", math.floor(distance)))
end
prompt.Triggered:Connect(scan)
Players.PlayerRemoving:Connect(function(player) lastScan[player] = nil end)
