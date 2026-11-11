-- Server-authoritative Cloud Evolution Altar. Native Roblox 3D Model/Parts only.
-- No client remotes; ProximityPrompt + server distance/life/profile checks.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rules = require(ReplicatedStorage.Shared.CloudEvolutionRules)
local Catalog = require(ReplicatedStorage.Shared.CloudCatalog)
local ProfileStore = require(script.Parent.ProfileStore)

local ALTAR_POSITION = Vector3.new(48, 12, -18)
local MAX_DISTANCE = 12
local THROTTLE_SECONDS = 2

local lastUse = {}

local function createAltar()
    local model = Instance.new("Model")
    model.Name = "CloudEvolutionAltar"

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Anchored = true
    base.CanCollide = true
    base.Size = Vector3.new(10, 1.5, 10)
    base.Position = ALTAR_POSITION
    base.Color = Color3.fromRGB(90, 160, 220)
    base.Material = Enum.Material.SmoothPlastic
    base.Parent = model

    local crystal = Instance.new("Part")
    crystal.Name = "FocusCrystal"
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3.5, 3.5, 3.5)
    crystal.Position = ALTAR_POSITION + Vector3.new(0, 3.2, 0)
    crystal.Color = Color3.fromRGB(180, 230, 255)
    crystal.Material = Enum.Material.Neon
    crystal.Parent = model

    for i = 1, 4 do
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar" .. i
        pillar.Anchored = true
        pillar.CanCollide = true
        pillar.Size = Vector3.new(1.2, 4, 1.2)
        local angle = (i - 1) * math.pi / 2
        pillar.Position = ALTAR_POSITION + Vector3.new(math.cos(angle) * 4.2, 2.2, math.sin(angle) * 4.2)
        pillar.Color = Color3.fromRGB(70, 130, 190)
        pillar.Material = Enum.Material.SmoothPlastic
        pillar.Parent = model
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "EvolvePrompt"
    prompt.ActionText = "Evolve Cloud"
    prompt.ObjectText = "Evolution Altar"
    prompt.HoldDuration = 0.8
    prompt.MaxActivationDistance = MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = base

    model.PrimaryPart = base
    model.Parent = workspace
    return model, prompt
end

local altar, prompt = createAltar()

local function playerReady(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return false end
    return true, root
end

prompt.Triggered:Connect(function(player)
    local now = os.clock()
    if lastUse[player] and now - lastUse[player] < THROTTLE_SECONDS then return end
    lastUse[player] = now

    local ready, root = playerReady(player)
    if not ready then return end
    if (root.Position - ALTAR_POSITION).Magnitude > MAX_DISTANCE + 2 then return end

    local profile = ProfileStore.Get(player)
    if not profile or not profile.data then return end
    local data = profile.data

    -- Prefer the first recipe the player can complete; server chooses, client cannot force.
    local chosen = nil
    for _, recipe in ipairs(Rules.RECIPES) do
        if Rules.canEvolve(data, recipe, Catalog) then
            chosen = recipe
            break
        end
    end
    if not chosen then return end

    local ok, result = Rules.applyEvolution(data, chosen, Catalog)
    if not ok then return end

    ProfileStore.Save(player, data, false)
    -- Visual feedback is optional; no client remote required for this first slice.
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player] = nil
end)
