-- Native Roblox 3D evolution altar on the starter meadow.
-- Evolves the currently equipped companion species. Server validates everything.
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local EvolutionRules = require(game:GetService("ReplicatedStorage"):WaitForChild("EvolutionRules"))
local CloudCatalog = require(game:GetService("ReplicatedStorage"):WaitForChild("CloudCatalog"))

local folder = Instance.new("Folder")
folder.Name = "CloudEvolutionAltar3D"
folder.Parent = Workspace

local function part(name, size, pos, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.CanCollide = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    if shape then p.Shape = shape end
    p.Parent = folder
    return p
end

-- Placed on the open northern meadow path, clear of arches and crystals.
local base = part("AltarBase", Vector3.new(8, 1, 8), Vector3.new(0, 1.5, 48),
    Color3.fromRGB(140, 130, 160), Enum.Material.Slate)
local pillar = part("AltarPillar", Vector3.new(2, 6, 2), Vector3.new(0, 4.5, 48),
    Color3.fromRGB(180, 170, 210), Enum.Material.Marble)
pillar.CanCollide = false
local orb = part("AltarOrb", Vector3.new(3.5, 3.5, 3.5), Vector3.new(0, 8.5, 48),
    Color3.fromRGB(180, 220, 255), Enum.Material.Neon, Enum.PartType.Ball)
orb.CanCollide = false
local ring = part("AltarRing", Vector3.new(6, 0.4, 6), Vector3.new(0, 2.2, 48),
    Color3.fromRGB(100, 200, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
ring.Orientation = Vector3.new(0, 0, 90)
ring.CanCollide = false

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "EvolveCloud"
prompt.ActionText = "Evolve Companion"
prompt.ObjectText = "Sky Evolution Altar"
prompt.MaxActivationDistance = 12
prompt.HoldDuration = 0.6
prompt.RequiresLineOfSight = false
prompt.Parent = orb

local cooldown = {}

prompt.Triggered:Connect(function(player)
    if not player or not player.Parent then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if (root.Position - orb.Position).Magnitude > 16 then return end
    local now = os.clock()
    if now < (cooldown[player] or 0) then return end
    local profile = ProfileStore.Get(player)
    if not profile then
        player:SetAttribute("EvolutionFeedback", "Profile still loading. Try again shortly.")
        return
    end
    local speciesId = profile.companionSpecies
    if speciesId == "" or not CloudCatalog[speciesId] then
        player:SetAttribute("EvolutionFeedback", "Equip a caught cloud companion first!")
        return
    end
    local ok, stageOrReason, cost = EvolutionRules.canEvolve(speciesId, profile.species, profile.evolutions, profile.coins, CloudCatalog)
    if not ok then
        player:SetAttribute("EvolutionFeedback", stageOrReason)
        return
    end
    local evolved, message = ProfileStore.EvolveSpecies(player)
    if evolved then
        cooldown[player] = now + 2
        player:SetAttribute("EvolutionFeedback", message)
    else
        player:SetAttribute("EvolutionFeedback", message or "Evolution failed")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    cooldown[player] = nil
end)
