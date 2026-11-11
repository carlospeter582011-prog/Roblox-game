-- Original server-owned physical weather dial: three levers, personalized glyph order.
-- No client remotes. Progress and rewards are validated on the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyWeatherDialRules"))

local model = Instance.new("Model")
model.Name = "SkyWeatherDial3D"
model.Parent = Workspace
local states = {}
local function makePart(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = true
    p.Material = material
    p.Color = color
    p.Parent = model
    return p
end
-- Placed away from the central spawn and existing meadow paths.
makePart("DialPlatform", Vector3.new(26, 1, 18), Vector3.new(-60, 1.5, -55),
    Color3.fromRGB(75, 105, 133), Enum.Material.Slate)
makePart("DialMonument", Vector3.new(5, 8, 3), Vector3.new(-60, 6, -60),
    Color3.fromRGB(110, 142, 175), Enum.Material.Slate)
for i, glyph in ipairs(Rules.GLYPHS) do
    local lever = makePart(glyph .. "Lever", Vector3.new(3, 4, 3),
        Vector3.new(-68 + (i - 1) * 8, 4, -53),
        ({ Color3.fromRGB(255, 207, 104), Color3.fromRGB(103, 182, 236), Color3.fromRGB(157, 234, 184) })[i],
        Enum.Material.Neon)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Turn" .. glyph
    prompt.ActionText = "Activate " .. glyph
    prompt.ObjectText = "Weather Dial"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.25
    prompt.RequiresLineOfSight = false
    prompt.Parent = lever
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid or humanoid.Health <= 0
            or (root.Position - lever.Position).Magnitude > 13 then return end
        local now = os.clock()
        local state = states[player]
        if not state then
            state = { round = 0, nextAllowed = 0, step = 1, startedAt = now, lastPress = -math.huge }
            states[player] = state
        end
        if now - state.lastPress < 0.4 then return end
        state.lastPress = now
        if not Rules.ready(now, state.nextAllowed) then
            player:SetAttribute("WeatherDialFeedback", "Dial recharging. Come back soon!")
            return
        end
        local sequence = Rules.sequence(player.UserId, state.round)
        if not sequence then return end
        if now - state.startedAt > Rules.WINDOW then
            state.step = 1
            state.startedAt = now
        end
        local nextStep, result = Rules.advance(sequence, state.step, glyph, state.startedAt, now)
        if result == "reset" then
            state.step = 1
            state.startedAt = now
            player:SetAttribute("WeatherDialFeedback", "Wrong glyph! Sequence reset. Hint: " .. sequence[1])
        elseif result == "complete" then
            -- Clear completion eligibility before crediting; no yield in this critical section.
            state.round += 1
            state.step = 1
            state.startedAt = now
            state.nextAllowed = now + Rules.COOLDOWN
            profile.coins = math.min(profile.coins + Rules.REWARD_COINS, 999999999999)
            profile.xp = math.min(profile.xp + Rules.REWARD_XP, 999999999999)
            player:SetAttribute("CloudCoins", profile.coins)
            player:SetAttribute("CloudXP", profile.xp)
            player:SetAttribute("CloudLevel", Leveling.levelForXp(profile.xp))
            player:SetAttribute("WeatherDialFeedback", "Weather balanced! +85 Coins, +45 XP")
        elseif result == "progress" then
            state.step = nextStep
            player:SetAttribute("WeatherDialFeedback", "Glyph " .. (nextStep - 1) .. "/3! Next: " .. sequence[nextStep])
        else
            state.step = 1
            state.startedAt = now
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
end)
