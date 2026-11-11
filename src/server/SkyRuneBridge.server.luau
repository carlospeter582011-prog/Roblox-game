-- Original cooperative 3D exploration puzzle. No client remote or economy grant.
-- Each player solves three runes in order; a solved sequence opens a shared physical bridge.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("SkyRuneRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyRuneBridge3D"
folder.Parent = Workspace
local function block(name, size, position, color, material, collision)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, position
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = collision == true
    p.Parent = folder
    return p
end
-- Eastwind's northern edge ends at Z=50. Bridge starts there and leads to a secret islet.
local secret = block("HiddenCloudGarden", Vector3.new(54, 3, 50), Vector3.new(170, -0.5, 130),
    Color3.fromRGB(112, 186, 171), Enum.Material.Grass, true)
block("FloatingGardenRock", Vector3.new(57, 11, 54), Vector3.new(170, -9, 130),
    Color3.fromRGB(87, 107, 139), Enum.Material.Slate, false).Shape = Enum.PartType.Ball
for i = 1, 5 do
    local angle = i * math.pi * 2 / 5
    local flower = block("SkyBloom" .. i, Vector3.new(4, 4, 4),
        Vector3.new(170 + math.cos(angle) * 16, 3, 130 + math.sin(angle) * 16),
        Color3.fromRGB(180, 151 + i * 10, 229), Enum.Material.Neon, false)
    flower.Shape = Enum.PartType.Ball
end
local bridge = block("RuneBridgeWalkway", Vector3.new(12, 2, 60), Vector3.new(170, 0, 80),
    Color3.fromRGB(126, 190, 227), Enum.Material.Glass, false)
bridge.Transparency = 0.85
local openedUntil = 0
local progress = {}
local function updateBridge()
    local open = os.clock() < openedUntil
    bridge.CanCollide = open
    bridge.Transparency = open and 0.15 or 0.85
end
for i, entry in ipairs({
    { "Air", Vector3.new(147, 3, 20), Color3.fromRGB(176, 231, 249) },
    { "Water", Vector3.new(170, 3, 20), Color3.fromRGB(111, 170, 244) },
    { "Storm", Vector3.new(193, 3, 20), Color3.fromRGB(190, 148, 245) },
}) do
    local rune = block(entry[1] .. "Rune", Vector3.new(5, 5, 5), entry[2], entry[3],
        Enum.Material.Neon, false)
    rune.Shape = Enum.PartType.Ball
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate (" .. tostring(i) .. "/3)"
    prompt.ObjectText = entry[1] .. " Sky Rune"
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0.4
    prompt.Parent = rune
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local human = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not human or human.Health <= 0 then return end
        local current = progress[player.UserId] or { stage = 0 }
        local now = os.clock()
        local stage, start, complete = Rules.advance(current.stage, current.startedAt,
            entry[1], now, (root.Position - rune.Position).Magnitude,
            player:GetAttribute("ProfileReady") == true)
        progress[player.UserId] = { stage = stage, startedAt = start }
        if complete then
            openedUntil = math.max(openedUntil, now + Rules.BRIDGE_DURATION)
            updateBridge()
            player:SetAttribute("RuneBridgeFeedback", "Sky Bridge opened for everyone!")
        elseif stage > current.stage then
            player:SetAttribute("RuneBridgeFeedback", entry[1] .. " rune activated (" .. stage .. "/3)")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    progress[player.UserId] = nil
end)
task.spawn(function()
    while folder.Parent do
        task.wait(0.5)
        updateBridge()
    end
end)
