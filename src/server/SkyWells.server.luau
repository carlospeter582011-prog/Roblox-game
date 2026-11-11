-- Original 3D restorative sky wells; touch/gamepad prompts, server-only healing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyWellRules"))
local lastUse = {}
local folder = Instance.new("Folder")
folder.Name = "RestorativeSkyWells3D"
folder.Parent = Workspace

local function createWell(name, position)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "StoneBasin3D"
    base.Anchored = true
    base.Size = Vector3.new(8, 1.5, 8)
    base.Position = position
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(105, 132, 164)
    base.Parent = model
    local pool = Instance.new("Part")
    pool.Name = "HealingWater3D"
    pool.Anchored = true
    pool.CanCollide = false
    pool.CanTouch = false
    pool.Shape = Enum.PartType.Cylinder
    pool.Size = Vector3.new(0.4, 6, 6)
    pool.Orientation = Vector3.new(0, 0, 90)
    pool.Position = position + Vector3.new(0, 0.85, 0)
    pool.Material = Enum.Material.Glass
    pool.Transparency = 0.35
    pool.Color = Color3.fromRGB(100, 226, 225)
    pool.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Restore Health"
    prompt.ObjectText = "Sky Well"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.6
    prompt.RequiresLineOfSight = false
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or player.Parent ~= Players then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        local now = os.clock()
        local elapsed = now - (lastUse[player] or -100000)
        if not Rules.canUse((root.Position - base.Position).Magnitude, humanoid.Health, humanoid.MaxHealth, elapsed, player:GetAttribute("ProfileReady")) then return end
        local nextHealth = Rules.healedHealth(humanoid.Health, humanoid.MaxHealth)
        if not nextHealth then return end
        lastUse[player] = now
        humanoid.Health = nextHealth
        player:SetAttribute("SkyWellFeedback", "Sky Well restored your health!")
    end)
end
-- Place on the walkable main island and Eastwind island, away from spawn and travel portals.
createWell("MeadowSkyWell", Vector3.new(38, 1.8, 36))
createWell("EastwindSkyWell", Vector3.new(195, 1.8, 28))
Players.PlayerRemoving:Connect(function(player) lastUse[player] = nil end)
