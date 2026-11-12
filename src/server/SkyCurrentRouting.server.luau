-- Original 3D Sky Current routing puzzle on Eastwind Outlook.
-- Server owns all progress and rewards; prompts are proximity-checked again here.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyCurrentRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local model = Instance.new("Model")
model.Name = "SkyCurrentRouting3D"
model.Parent = Workspace
local state = {}
local function makePart(name, pos, color, size)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.Size = size or Vector3.new(5, 5, 5)
    p.Position = pos
    p.Material = Enum.Material.Slate
    p.Color = color
    p.Parent = model
    return p
end
local function interact(player, valve, anchor)
    if not player or not player:IsA("Player") or player.Parent ~= Players then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return end
    local distance = (root.Position - anchor.Position).Magnitude
    if distance > 14 then return end
    local profile = Profile.Get(player)
    if not profile or player:GetAttribute("ProfileReady") ~= true then return end
    local now = os.clock()
    local s = state[player] or { step = 0, started = now, last = -1e9 }
    if not Rules.eligible(distance, true, humanoid.Health, now, s.last) then
        player:SetAttribute("SkyCurrentFeedback", "Current stabilizing. Try again shortly.")
        return
    end
    if now - s.started > Rules.TIME_LIMIT then
        s.step, s.started = 0, now
    end
    if s.step == 0 then s.started = now end
    local nextStep, completed = Rules.advance(s.step, valve, now - s.started)
    s.step = nextStep
    if completed then
        -- Guard against reentrancy before applying any wallet mutation.
        s.last = now
        s.step = 0
        if type(profile.coins) ~= "number" or type(profile.xp) ~= "number"
            or profile.coins ~= profile.coins or profile.xp ~= profile.xp
            or profile.coins < 0 or profile.xp < 0
            or profile.coins > 999999999 - Rules.REWARD_COINS
            or profile.xp > 999999999 - Rules.REWARD_XP then return end
        profile.coins += Rules.REWARD_COINS
        profile.xp += Rules.REWARD_XP
        player:SetAttribute("CloudCoins", profile.coins)
        player:SetAttribute("CloudXP", profile.xp)
        player:SetAttribute("CloudLevel", Leveling.levelForXp(profile.xp))
        player:SetAttribute("SkyCurrentFeedback", "Current restored! +110 Coins +65 XP")
    else
        player:SetAttribute("SkyCurrentFeedback", nextStep > 0 and ("Current aligned: " .. nextStep .. "/3") or "Wrong current! Start at North.")
    end
    state[player] = s
end
-- Eastwind is centered at x=170, z=0; stations are on its walkable 100x100 ground.
local positions = {
    { "north", Vector3.new(155, 3, -27), Color3.fromRGB(130, 210, 255) },
    { "east", Vector3.new(190, 3, -12), Color3.fromRGB(255, 220, 125) },
    { "west", Vector3.new(185, 3, 28), Color3.fromRGB(190, 155, 255) },
}
for _, entry in ipairs(positions) do
    local name, pos, color = entry[1], entry[2], entry[3]
    local platform = makePart(name .. "CurrentBase", Vector3.new(pos.X, 1.25, pos.Z), color, Vector3.new(8, 0.5, 8))
    platform.CanCollide = false
    local pillar = makePart(name .. "CurrentValve", pos, color, Vector3.new(3, 4, 3))
    pillar.Shape = Enum.PartType.Cylinder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Align Current"
    prompt.ObjectText = string.upper(name) .. " Wind Valve"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar
    prompt.Triggered:Connect(function(player) interact(player, name, pillar) end)
end
Players.PlayerRemoving:Connect(function(player) state[player] = nil end)
