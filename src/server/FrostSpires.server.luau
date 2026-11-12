-- Original procedural 3D Frost Spires region. Connected walkable island after Thunderhead Ridge.
-- All geometry is native Roblox Parts/Models. No Canvas, no external meshes or asset IDs.
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local FrostRules = require(game:GetService("ReplicatedStorage"):WaitForChild("FrostRules"))

local world = Instance.new("Model")
world.Name = "FrostSpires3D"
world.Parent = Workspace

local function part(name, size, position, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.Parent = parent or world
    return p
end

-- Main walkable floor. Positioned further east so the bridge from Ridge (x~370) overlaps.
local floor = part("FrostWalkableGround", Vector3.new(120, 2, 110), Vector3.new(470, 0, 0),
    Color3.fromRGB(190, 220, 235), Enum.Material.Ice)
floor.Transparency = 0.15
local under = part("FrostFloatingBed", Vector3.new(122, 18, 112), Vector3.new(470, -12, 0),
    Color3.fromRGB(140, 170, 190), Enum.Material.Slate)
under.Shape = Enum.PartType.Ball
under.CanCollide = false

-- Bridge overlapping Thunderhead Ridge edge (~x=370) and Frost edge (~x=410).
part("FrostBridgeWalkway", Vector3.new(50, 2, 16), Vector3.new(390, 0, 0),
    Color3.fromRGB(160, 180, 200), Enum.Material.Ice)
for _, z in ipairs({ -9, 9 }) do
    part("FrostBridgeRail", Vector3.new(50, 3, 1), Vector3.new(390, 3, z),
        Color3.fromRGB(120, 150, 170), Enum.Material.Ice)
end

-- Distinct ice spires around the island.
for i = 1, 10 do
    local angle = i * math.pi * 2 / 10
    local radius = 38
    local x = 470 + math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local spire = part("IceSpire" .. i, Vector3.new(4, 12 + (i % 5) * 2, 4),
        Vector3.new(x, 7 + (i % 5), z), Color3.fromRGB(180, 210, 240), Enum.Material.Ice)
    spire.CanCollide = false
    local tip = part("SpireTip" .. i, Vector3.new(6, 6, 6),
        spire.Position + Vector3.new(0, spire.Size.Y / 2 + 2, 0),
        Color3.fromRGB(200, 230, 255), Enum.Material.Glass)
    tip.Shape = Enum.PartType.Ball
    tip.CanCollide = false
end

-- Three server-owned attunement beacons with ProximityPrompt.
local lastAttune = {}
for i, offset in ipairs({ Vector3.new(-25, 1, 0), Vector3.new(0, 1, 25), Vector3.new(25, 1, -10) }) do
    local beaconPos = Vector3.new(470, 0, 0) + offset
    local base = part("FrostBeaconBase" .. i, Vector3.new(8, 1, 8), beaconPos,
        Color3.fromRGB(160, 200, 230), Enum.Material.Ice)
    local crystal = part("FrostBeaconCrystal" .. i, Vector3.new(3, 6, 3), beaconPos + Vector3.new(0, 4, 0),
        Color3.fromRGB(140, 220, 255), Enum.Material.Neon)
    crystal.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "AttuneFrost"
    prompt.ActionText = "Attune"
    prompt.ObjectText = "Frost Spire"
    prompt.MaxActivationDistance = 16
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = crystal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local profile = Profile.Get(player)
        if not profile then return end
        local distance = (root.Position - crystal.Position).Magnitude
        local ready = player:GetAttribute("ProfileReady") == true
        local now = os.clock()
        local prev = lastAttune[player]
        if not FrostRules.canAttune(distance, ready, prev, now) then return end
        lastAttune[player] = now
        -- Temporary non-stacking speed blessing. Server owns the humanoid.
        local original = humanoid.WalkSpeed
        humanoid.WalkSpeed = math.min(original + FrostRules.SPEED_BONUS, 32)
        player:SetAttribute("FrostAttuneFeedback", "Frost attuned! +" .. FrostRules.SPEED_BONUS .. " speed for " .. FrostRules.SPEED_DURATION .. "s")
        task.delay(FrostRules.SPEED_DURATION, function()
            if humanoid and humanoid.Parent and humanoid.WalkSpeed == original + FrostRules.SPEED_BONUS then
                humanoid.WalkSpeed = original
            end
        end)
    end)
end

world.PrimaryPart = floor
