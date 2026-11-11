-- Server-authoritative cloud fusion altar.
-- Original procedural 3D Model of Parts with ProximityPrompt.
-- Validates ownership via profile species counts; no client trust for counts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FusionRules = require(ReplicatedStorage.Shared.FusionRules)
local ProfileStore = require(script.Parent.ProfileStore)

local function createAltar()
    local model = Instance.new("Model")
    model.Name = "FusionAltar3D"
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(8, 1, 8)
    base.Position = Vector3.new(20, 5, 20) -- near starter island; adjust as needed
    base.Anchored = true
    base.Color = Color3.fromRGB(100, 80, 200)
    base.Material = Enum.Material.Neon
    base.Parent = model
    local pillar = Instance.new("Part")
    pillar.Name = "Pillar"
    pillar.Size = Vector3.new(2, 6, 2)
    pillar.Position = base.Position + Vector3.new(0, 3.5, 0)
    pillar.Anchored = true
    pillar.Color = Color3.fromRGB(180, 140, 255)
    pillar.Material = Enum.Material.Glass
    pillar.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Fuse Clouds"
    prompt.ObjectText = "Fusion Altar"
    prompt.HoldDuration = 1
    prompt.MaxActivationDistance = 10
    prompt.Parent = base
    model.Parent = workspace
    return prompt
end

local prompt = createAltar()

prompt.Triggered:Connect(function(player)
    local profile = ProfileStore.Get(player)
    if not profile then return end
    -- For this initial slice, attempt the first eligible recipe.
    -- Expand to client selection or cycling later.
    for _, recipe in ipairs(FusionRules.RECIPES) do
        if FusionRules.canFuse(profile, recipe) then
            if FusionRules.applyFusion(profile, recipe) then
                ProfileStore.Save(player, profile)
                -- Optional: fire client feedback remote if one exists.
                return
            end
        end
    end
end)
