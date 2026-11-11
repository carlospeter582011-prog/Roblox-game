-- Session-only sky sanctuary checkpoints. Actual Roblox Parts, not 2D world art.
-- A player activates a sanctuary by proximity, then respawns there after defeat/falling.
-- Does not alter persistent profiles, currencies, or other players' spawn points.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SanctuaryRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local folder = Instance.new("Folder")
folder.Name = "SkySanctuaries3D"
folder.Parent = Workspace
local selected = {}
local lastActivation = {}
local function createSanctuary(id, position, color)
    local model = Instance.new("Model")
    model.Name = id .. "Sanctuary3D"
    model.Parent = folder
    local function makePart(name, size, offset, material, canCollide)
        local p = Instance.new("Part")
        p.Name = name
        p.Anchored = true
        p.Size = size
        p.Position = position + offset
        p.Color = color
        p.Material = material
        p.CanCollide = canCollide
        p.Parent = model
        return p
    end
    makePart("SanctuaryPlatform", Vector3.new(12, 1, 12), Vector3.new(0, -0.5, 0), Enum.Material.Slate, true)
    local beacon = makePart("SanctuaryBeacon", Vector3.new(2, 5, 2), Vector3.new(0, 3, 0), Enum.Material.Neon, false)
    for _, offset in ipairs({Vector3.new(-4, 1, -4), Vector3.new(4, 1, -4),
        Vector3.new(-4, 1, 4), Vector3.new(4, 1, 4)}) do
        makePart("CornerMarker", Vector3.new(1, 2, 1), offset, Enum.Material.Slate, false)
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ActivateSanctuary"
    prompt.ActionText = "Set Respawn"
    prompt.ObjectText = "Sky Sanctuary"
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.HoldDuration = 0.35
    prompt.RequiresLineOfSight = false
    prompt.Parent = beacon
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local now = os.clock()
        local distance = (root.Position - beacon.Position).Magnitude
        if not Rules.canActivate(id, distance, player:GetAttribute("ProfileReady") == true
            and Profile.Get(player) ~= nil, humanoid.Health > 0, now, lastActivation[player]) then
            return
        end
        selected[player] = id
        lastActivation[player] = now
        player:SetAttribute("SanctuaryCheckpoint", id)
        player:SetAttribute("SanctuaryFeedback", "Respawn set: " .. id .. " (this server)")
    end)
end
for id, coords in pairs(Rules.PADS) do
    local tint = id == "meadow" and Color3.fromRGB(123, 235, 169)
        or (id == "eastwind" and Color3.fromRGB(128, 202, 255)
        or Color3.fromRGB(185, 158, 255))
    createSanctuary(id, Vector3.new(coords.x, coords.y, coords.z), tint)
end
local function setup(player)
    player.CharacterAdded:Connect(function(character)
        local checkpoint = selected[player]
        if not checkpoint then return end
        local x, y, z = Rules.respawn(checkpoint)
        if not x then return end
        local root = character:WaitForChild("HumanoidRootPart", 10)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not root or not player.Parent or player.Character ~= character
            or (humanoid and humanoid.Health <= 0) then return end
        -- Deferred until character has spawned; never teleport clients directly.
        task.wait(0.15)
        if player.Character == character and root.Parent and Profile.Get(player) then
            character:PivotTo(CFrame.new(x, y, z))
        end
    end)
end
Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do setup(player) end
Players.PlayerRemoving:Connect(function(player)
    selected[player] = nil
    lastActivation[player] = nil
end)
