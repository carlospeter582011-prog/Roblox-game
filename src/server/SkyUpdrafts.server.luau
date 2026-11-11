-- Reusable 3D updrafts for traversal between connected starter regions.
-- No remote event: only server-owned ProximityPrompts may request launch.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local Rules = require(ReplicatedStorage:WaitForChild("UpdraftRules"))

local folder = Instance.new("Folder")
folder.Name = "SkyUpdraftLaunchPads3D"
folder.Parent = Workspace
local lastUse = {}
local placements = {
    { id = "meadow", pos = Vector3.new(68, 2, -25), direction = Vector3.new(1, 0, 0) },
    { id = "eastwind", pos = Vector3.new(178, 2, 23), direction = Vector3.new(1, 0, 0) },
    { id = "ridge", pos = Vector3.new(290, 2, 0), direction = Vector3.new(-1, 0, 0) },
}
local function makePart(parent, name, size, position, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Parent = parent
    return part
end
for _, config in ipairs(placements) do
    local model = Instance.new("Model")
    model.Name = "SkyUpdraft_" .. config.id
    model.Parent = folder
    local ring = makePart(model, "WindCore", Vector3.new(7, 0.6, 7), config.pos, Color3.fromRGB(100, 218, 240))
    ring.Shape = Enum.PartType.Cylinder
    ring.Transparency = 0.35
    local column = makePart(model, "WindColumn", Vector3.new(3, 9, 3), config.pos + Vector3.new(0, 5, 0), Color3.fromRGB(141, 225, 252))
    column.Shape = Enum.PartType.Cylinder
    column.Transparency = 0.78
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LaunchUpdraft"
    prompt.ActionText = "Ride wind"
    prompt.ObjectText = "Sky Updraft (Lv " .. Rules.PADS[config.id].level .. ")"
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = ring
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or player.Parent ~= Players then return end
        local profile = Profile.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid or humanoid.Health <= 0 or humanoid.Sit then return end
        local now = os.clock()
        local ok, result = Rules.canLaunch(config.id, Leveling.levelForXp(profile.xp),
            (root.Position - ring.Position).Magnitude, now, lastUse[player], player:GetAttribute("ProfileReady"))
        if not ok then
            player:SetAttribute("UpdraftFeedback", result == "level" and ("Reach level " .. Rules.PADS[config.id].level) or "Updraft unavailable")
            return
        end
        lastUse[player] = now
        root.AssemblyLinearVelocity = config.direction * result.velocity + Vector3.new(0, result.lift, 0)
        player:SetAttribute("UpdraftFeedback", "Wind launched! Steer toward the next island.")
    end)
end
Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
