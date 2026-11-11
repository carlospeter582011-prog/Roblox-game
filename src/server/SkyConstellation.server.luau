-- Original physical 3D observatory: four constellation pillars must be activated in a
-- per-player deterministic order. Server owns puzzle state, interaction and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyConstellationRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local model = Instance.new("Model")
model.Name = "SkyConstellationObservatory3D"
model.Parent = Workspace
local function part(name, size, position, color, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.Slate
    if shape then p.Shape = shape end
    p.Parent = model
    return p
end
local center = Vector3.new(-38, 9, -28)
part("ObservatoryPlatform", Vector3.new(28, 2, 28), center - Vector3.new(0, 2, 0), Color3.fromRGB(55, 70, 100))
local sessions = {}
local pillars = {
    Vector3.new(-9, 0, -9), Vector3.new(9, 0, -9),
    Vector3.new(9, 0, 9), Vector3.new(-9, 0, 9),
}
for index, offset in ipairs(pillars) do
    local base = part("StarPillar_" .. index, Vector3.new(3, 7, 3), center + offset + Vector3.new(0, 2, 0), Color3.fromRGB(70, 92, 132))
    local star = part("StarGlyph_" .. index, Vector3.new(2, 2, 2), base.Position + Vector3.new(0, 4.5, 0), Color3.fromRGB(130, 195, 255), Enum.PartType.Ball)
    star.Material = Enum.Material.Neon
    star.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Align star " .. index
    prompt.ObjectText = "Sky Observatory"
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 10
    prompt.Parent = base
    prompt.Triggered:Connect(function(player)
        local data = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not data or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - base.Position).Magnitude > 13 then return end
        local now = os.clock()
        local session = sessions[player]
        if not session then
            session = { order = Rules.order(player.UserId), progress = 0, start = now }
            sessions[player] = session
        end
        if not Rules.ready(now, session.lastAward) then
            player:SetAttribute("ObservatoryStatus", "Recharge before trying again")
            return
        end
        if now - session.start > Rules.TIME_LIMIT then
            session.progress = 0
            session.start = now
        end
        local nextProgress, completed, status = Rules.step(session.order, session.progress, index, now - session.start)
        session.progress = nextProgress
        player:SetAttribute("ObservatoryProgress", nextProgress)
        player:SetAttribute("ObservatoryStatus", status)
        if status == "reset" then session.start = now end
        if completed then
            -- No yielding between completion guard and reward mutation.
            session.lastAward = now
            session.progress = 0
            session.start = now
            data.coins += Rules.REWARD_COINS
            data.xp += Rules.REWARD_XP
            player:SetAttribute("CloudCoins", data.coins)
            player:SetAttribute("CloudXP", data.xp)
            player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
            player:SetAttribute("ObservatoryProgress", 0)
            player:SetAttribute("ObservatoryStatus", "Constellation solved! +120 Coins +70 XP")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
