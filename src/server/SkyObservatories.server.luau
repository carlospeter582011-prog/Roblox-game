-- Three replayable original 3D observatories; server-owned interaction and session cooldown.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("ObservatoryRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyObservatories3D"
folder.Parent = Workspace
local nextAllowed = {}
local function makePart(model, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = false
    p.Color = color
    p.Material = material
    p.Parent = model
    return p
end
for id, config in pairs(Rules.stations) do
    local model = Instance.new("Model")
    model.Name = id .. "Observatory3D"
    model.Parent = folder
    local base = Vector3.new(config.x, 2, config.z)
    makePart(model, "StonePlinth", Vector3.new(7, 2, 7), base, Color3.fromRGB(75, 100, 137), Enum.Material.Slate)
    makePart(model, "TelescopePillar", Vector3.new(2, 6, 2), base + Vector3.new(0, 4, 0), Color3.fromRGB(117, 132, 164), Enum.Material.Metal)
    local scope = makePart(model, "SkyLens", Vector3.new(3, 3, 3), base + Vector3.new(0, 8, 0), Color3.fromRGB(90, 197, 240), Enum.Material.Glass)
    scope.Shape = Enum.PartType.Ball
    local ring = makePart(model, "StarRing", Vector3.new(0.6, 5, 5), base + Vector3.new(0, 8, 0), Color3.fromRGB(239, 205, 113), Enum.Material.Neon)
    ring.Shape = Enum.PartType.Cylinder
    ring.Orientation = Vector3.new(0, 0, 90)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Observe Sky"
    prompt.ObjectText = config.name
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = scope
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local data = Profile.Get(player)
        if not data or not root or not humanoid or humanoid.Health <= 0 then return end
        local now = os.clock()
        local nextByPlayer = nextAllowed[player] or {}
        if not Rules.canObserve(id, data.captures, (root.Position - scope.Position).Magnitude,
            now, nextByPlayer[id] or 0, player:GetAttribute("ProfileReady")) then
            player:SetAttribute("ObservatoryFeedback", "Observatory locked, too far, or recharging.")
            return
        end
        -- Commit the cooldown only if the profile reward succeeds.
        local ok, coins, xp = Profile.AwardObservatory(player, id)
        if not ok then return end
        nextByPlayer[id] = now + Rules.COOLDOWN
        nextAllowed[player] = nextByPlayer
        player:SetAttribute("ObservatoryFeedback", config.name .. ": +" .. coins .. " Coins, +" .. xp .. " XP!")
    end)
end
Players.PlayerRemoving:Connect(function(player)
    nextAllowed[player] = nil
end)
