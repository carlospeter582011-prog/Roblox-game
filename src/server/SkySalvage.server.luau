-- Server-owned renewable salvage nodes; native Roblox 3D geometry and prompts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySalvageRules"))
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local folder = Instance.new("Folder")
folder.Name = "SkySalvage"
folder.Parent = workspace
local nodes = {
    { kind = "breeze", position = Vector3.new(22, 17, 12), tint = Color3.fromRGB(130, 225, 245) },
    { kind = "storm", position = Vector3.new(37, 19, -12), tint = Color3.fromRGB(152, 143, 245) },
    { kind = "cosmic", position = Vector3.new(-29, 24, -18), tint = Color3.fromRGB(246, 179, 115) },
}
local sessions = {} -- independent per-player per-node cooldown; bounded session earning
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
for _, definition in ipairs(nodes) do
    local model = Instance.new("Model")
    model.Name = "Salvage_" .. definition.kind
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "Anchor"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(1, 6, 6)
    base.Position = definition.position
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(58, 70, 98)
    base.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "EnergyCore"
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3, 3, 3)
    crystal.Position = definition.position + Vector3.new(0, 3.3, 0)
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Material = Enum.Material.Neon
    crystal.Color = definition.tint
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Collect sky energy"
    prompt.ObjectText = definition.kind .. " salvage"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.6
    prompt.RequiresLineOfSight = true
    prompt.Parent = crystal
    prompt.Triggered:Connect(function(player)
        local data = Profile.Get(player)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not data or not root or not humanoid or humanoid.Health <= 0 then return end
        local record = sessions[player] or { claims = 0, last = {} }
        local now = os.clock()
        local ok, reward = Rules.canClaim(definition.kind, data.captures, (root.Position - crystal.Position).Magnitude, now, record.last[definition.kind], record.claims)
        if not ok then return end
        -- No yielding between validation, reward and cooldown state mutation.
        if type(data.coins) ~= "number" or type(data.xp) ~= "number" then return end
        if data.coins > 1e12 - reward.coins or data.xp > 1e12 - reward.xp then return end
        record.last[definition.kind] = now
        record.claims += 1
        sessions[player] = record
        data.coins += reward.coins
        data.xp += reward.xp
        player:SetAttribute("CloudCoins", data.coins)
        player:SetAttribute("CloudXP", data.xp)
        player:SetAttribute("CloudLevel", Leveling.levelForXp(data.xp))
        player:SetAttribute("SkySalvageClaims", record.claims)
    end)
end
