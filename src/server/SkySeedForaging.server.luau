-- Original 3D Sky Seed foraging: collect three seeds, redeem a temporary mobility boost.
-- Server owns pickups, distances, cooldown, speed and cleanup. Session-only, no paid rewards.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("SkySeedRules"))
local folder = Instance.new("Folder")
folder.Name = "SkySeedForaging3D"
folder.Parent = Workspace
local state = {}
local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = false
    p.Parent = folder
    return p
end
local function status(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return nil, nil end
    return root, humanoid
end
local function promptFor(p, action, object)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = action
    prompt.ObjectText = object
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = p
    return prompt
end
local positions = {
    Vector3.new(-45, 3, -38), Vector3.new(43, 3, 38),
    Vector3.new(-35, 3, 47), Vector3.new(40, 3, -43),
    Vector3.new(153, 3, 32), Vector3.new(188, 3, -28),
    Vector3.new(298, 3, 30), Vector3.new(337, 3, -27),
}
for index, pos in ipairs(positions) do
    local seed = part("WindSeed" .. index, Vector3.new(2.8, 2.8, 2.8), pos,
        Color3.fromRGB(116, 229, 183), Enum.Material.Neon)
    seed.Shape = Enum.PartType.Ball
    local prompt = promptFor(seed, "Gather", "Wind Seed")
    prompt.Triggered:Connect(function(player)
        if not player or not player.Parent then return end
        local root = status(player)
        if not root then return end
        local s = state[player] or { count = 0, nextAllowed = 0, collected = {} }
        local distance = (root.Position - seed.Position).Magnitude
        if s.collected[index] or not Rules.canPickup(s.count, distance, ProfileStore.Get(player) ~= nil, true) then return end
        s.collected[index] = true
        s.count += 1
        state[player] = s
        player:SetAttribute("WindSeeds", s.count)
        player:SetAttribute("WindSeedFeedback", "Wind Seed " .. s.count .. "/" .. Rules.cost .. " — visit the Wind Shrine!")
    end)
end
local shrine = part("WindShrinePedestal", Vector3.new(7, 3, 7),
    Vector3.new(170, 2.5, -2), Color3.fromRGB(98, 157, 216), Enum.Material.Slate)
local orb = part("WindShrineCore", Vector3.new(3, 3, 3),
    Vector3.new(170, 5.5, -2), Color3.fromRGB(130, 231, 243), Enum.Material.Neon)
orb.Shape = Enum.PartType.Ball
promptFor(shrine, "Spend 3 seeds", "Wind Shrine").Triggered:Connect(function(player)
    if not player or not player.Parent then return end
    local root, humanoid = status(player)
    local s = state[player]
    if not root or not s then return end
    local now = os.clock()
    if not Rules.canRedeem(s.count, (root.Position - shrine.Position).Magnitude,
        ProfileStore.Get(player) ~= nil, true, now, s.nextAllowed) then
        player:SetAttribute("WindSeedFeedback", "Need 3 seeds, or wait for shrine cooldown.")
        return
    end
    s.count -= Rules.cost
    s.collected = {} -- seeds can be gathered again for a repeatable exploration loop
    s.nextAllowed = now + Rules.cooldownSeconds
    s.boostToken = (s.boostToken or 0) + 1
    local token = s.boostToken
    local original = humanoid.WalkSpeed
    humanoid.WalkSpeed = math.min(original + Rules.speedBonus, 30)
    player:SetAttribute("WindSeeds", s.count)
    player:SetAttribute("WindSeedFeedback", "Wind blessing! Faster travel for 25 seconds.")
    task.delay(Rules.boostSeconds, function()
        if state[player] == s and s.boostToken == token and humanoid.Parent then
            -- Avoid clobbering unrelated speed modifiers added during the blessing.
            if humanoid.WalkSpeed == math.min(original + Rules.speedBonus, 30) then
                humanoid.WalkSpeed = original
            end
        end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    state[player] = nil
end)
