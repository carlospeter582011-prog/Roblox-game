-- Original 3D rune puzzle: unlock a hidden garden by solving an individual
-- timed sequence. All progress and teleports are server-owned; no RemoteEvent.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyRuneRules"))

local folder = Instance.new("Folder")
folder.Name = "SkyRuneGarden3D"
folder.Parent = Workspace
local function part(name, size, position, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.Parent = folder
    return p
end
local function prompt(parent, action, object)
    local p = Instance.new("ProximityPrompt")
    p.ActionText = action
    p.ObjectText = object
    p.MaxActivationDistance = 11
    p.RequiresLineOfSight = false
    p.HoldDuration = 0.25
    p.Parent = parent
    return p
end
local origin = Vector3.new(-82, 4, -38)
part("RunePlaza", Vector3.new(32, 2, 24), origin + Vector3.new(0, -2, 0),
    Color3.fromRGB(75, 109, 132), Enum.Material.Slate)
local colors = {
    Color3.fromRGB(95, 205, 225),
    Color3.fromRGB(225, 171, 87),
    Color3.fromRGB(172, 126, 226),
}
local runes = {}
for i = 1, 3 do
    local pos = origin + Vector3.new((i - 2) * 9, 2, 0)
    local pillar = part("RunePillar" .. i, Vector3.new(3, 6, 3), pos, colors[i], Enum.Material.Slate)
    local orb = part("RuneOrb" .. i, Vector3.new(3, 3, 3), pos + Vector3.new(0, 4.5, 0),
        colors[i], Enum.Material.Neon, Enum.PartType.Ball)
    orb.CanCollide = false
    runes[i] = { prompt = prompt(pillar, "Activate rune " .. i, "Sky Rune"), pillar = pillar }
end
local garden = Vector3.new(530, 46, -120)
part("SecretGardenIsland", Vector3.new(46, 4, 44), garden + Vector3.new(0, -5, 0),
    Color3.fromRGB(105, 170, 126), Enum.Material.Grass)
part("GardenRockBase", Vector3.new(35, 13, 33), garden + Vector3.new(0, -14, 0),
    Color3.fromRGB(87, 97, 122), Enum.Material.Slate)
for i = 1, 8 do
    local angle = i * math.pi / 4
    local pos = garden + Vector3.new(math.cos(angle) * 16, -1, math.sin(angle) * 16)
    local stem = part("GardenTreeTrunk" .. i, Vector3.new(2, 7, 2), pos + Vector3.new(0, 3, 0),
        Color3.fromRGB(104, 76, 66), Enum.Material.Wood)
    part("GardenTreeCanopy" .. i, Vector3.new(8, 7, 8), stem.Position + Vector3.new(0, 6, 0),
        Color3.fromRGB(89, 189, 157), Enum.Material.Grass, Enum.PartType.Ball).CanCollide = false
end
local exitStone = part("ReturnStone", Vector3.new(5, 5, 5), garden + Vector3.new(0, 1, 12),
    Color3.fromRGB(110, 187, 215), Enum.Material.Slate)
local exitPrompt = prompt(exitStone, "Return to meadow", "Sky Rune Garden")
local hintStone = part("RuneGuideStone", Vector3.new(4, 4, 4), origin + Vector3.new(0, 0, -9), Color3.fromRGB(195, 211, 224), Enum.Material.Slate)
local hintPrompt = prompt(hintStone, "Read rune order", "Sky Rune Guide")
local state = {} -- player -> { round, sequence, step, started, cooldown }
local function livingRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then return nil end
    return root
end
local function notify(player, message)
    player:SetAttribute("SkyRuneFeedback", message)
end
local function teleport(player, target)
    local root = livingRoot(player)
    if not root then return false end
    root.CFrame = CFrame.new(target)
    root.AssemblyLinearVelocity = Vector3.zero
    return true
end
hintPrompt.Triggered:Connect(function(player)
    if not Profile.Get(player) then return end
    local root = livingRoot(player)
    if not root or (root.Position - hintStone.Position).Magnitude > 14 then return end
    local now = os.clock()
    local current = state[player] or { round = 0, cooldown = 0 }
    if now < current.cooldown then return end
    if not current.sequence or now - current.started > Rules.TIME_LIMIT then
        current.round += 1
        current.sequence = Rules.sequence(player.UserId, current.round)
        current.step = 1
        current.started = now
    end
    state[player] = current
    notify(player, "Rune order: " .. table.concat(current.sequence, " - ") .. " (40 seconds)")
end)
for i, rune in ipairs(runes) do
    rune.prompt.Triggered:Connect(function(player)
        if not Profile.Get(player) then return end
        local root = livingRoot(player)
        if not root or (root.Position - rune.pillar.Position).Magnitude > 14 then return end
        local now = os.clock()
        local current = state[player] or { round = 0, cooldown = 0 }
        if now < current.cooldown then
            notify(player, "Runes recharging. Try again shortly.")
            return
        end
        if not current.sequence or now - current.started > Rules.TIME_LIMIT then
            current.round += 1
            current.sequence = Rules.sequence(player.UserId, current.round)
            current.step = 1
            current.started = now
        end
        local status, nextStep = Rules.advance(current.sequence, current.step, i, current.started, now)
        if status == "complete" then
            current.sequence = nil
            current.cooldown = now + Rules.RETRY_COOLDOWN
            if teleport(player, garden + Vector3.new(0, 5, 0)) then
                notify(player, "Sky Rune Garden unlocked! Explore and use the return stone.")
            end
        elseif status == "progress" then
            current.step = nextStep
            notify(player, "Rune " .. i .. " activated (" .. (nextStep - 1) .. "/3).")
        else
            current.sequence = nil
            current.cooldown = now + 2
            notify(player, "Rune sequence reset. Try another order!")
        end
        state[player] = current
    end)
end
exitPrompt.Triggered:Connect(function(player)
    if not Profile.Get(player) then return end
    local root = livingRoot(player)
    if not root or (root.Position - exitStone.Position).Magnitude > 14 then return end
    if teleport(player, origin + Vector3.new(0, 5, -8)) then
        notify(player, "Returned to the rune plaza.")
    end
end)
Players.PlayerRemoving:Connect(function(player) state[player] = nil end)
