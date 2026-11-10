-- Cooperative, replayable health-restoration landmarks using original native Roblox 3D Parts.
-- No client remotes, currency rewards, external meshes, or save-schema changes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyWellRules"))
local cooldown = {} -- [player] = server monotonic time; reset on server exit
local folder = Instance.new("Folder")
folder.Name = "SkyRestorationWells3D"
folder.Parent = workspace
local function part(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, position
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.Material = material
    p.Color = color
    p.Parent = parent
    return p
end
local stations = {
    { name = "Meadow Spring", position = Vector3.new(-35, 1.5, 28), color = Color3.fromRGB(99, 214, 189) },
    { name = "Eastwind Spring", position = Vector3.new(170, 1.5, 30), color = Color3.fromRGB(129, 201, 242) },
    { name = "Thunder Spring", position = Vector3.new(315, 1.5, 20), color = Color3.fromRGB(189, 159, 243) },
}
local function living(player)
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return nil, nil end
    return humanoid, root
end
for _, station in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = station.name:gsub(" ", "") .. "3D"
    model.Parent = folder
    local pedestal = part(model, "StoneBasin", Vector3.new(9, 2, 9), station.position, Color3.fromRGB(100, 117, 140), Enum.Material.Slate)
    pedestal.Shape = Enum.PartType.Cylinder
    part(model, "RestorativeWater", Vector3.new(7, 0.4, 7), station.position + Vector3.new(0, 1.2, 0), station.color, Enum.Material.Glass).Shape = Enum.PartType.Cylinder
    for i = 1, 4 do
        local angle = i * math.pi / 2
        local orb = part(model, "FloatingDrop" .. i, Vector3.new(1.2, 1.8, 1.2),
            station.position + Vector3.new(math.cos(angle) * 3, 3, math.sin(angle) * 3),
            station.color, Enum.Material.Neon)
        orb.Shape = Enum.PartType.Ball
    end
    local attachment = Instance.new("Attachment")
    attachment.Position = Vector3.new(0, 3.2, 0)
    attachment.Parent = pedestal
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Restore nearby players"
    prompt.ObjectText = station.name
    prompt.MaxActivationDistance = Rules.RADIUS
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = attachment
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local humanoid, root = living(player)
        if not humanoid then return end
        local now = os.clock()
        if not Rules.eligible((root.Position - pedestal.Position).Magnitude,
            humanoid.Health, humanoid.MaxHealth, now, cooldown[player]) then return end
        -- Claim cooldown before healing to prevent concurrent prompt callbacks.
        cooldown[player] = now
        for _, ally in ipairs(Players:GetPlayers()) do
            local targetHumanoid, targetRoot = living(ally)
            if targetHumanoid and Rules.allyEligible((targetRoot.Position - pedestal.Position).Magnitude,
                targetHumanoid.Health, targetHumanoid.MaxHealth) then
                targetHumanoid.Health = math.min(targetHumanoid.MaxHealth,
                    targetHumanoid.Health + Rules.healAmount(targetHumanoid.Health, targetHumanoid.MaxHealth))
            end
        end
        player:SetAttribute("SkyWellFeedback", "Spring restored nearby players! Ready again in 120s.")
    end)
end
Players.PlayerRemoving:Connect(function(player) cooldown[player] = nil end)
