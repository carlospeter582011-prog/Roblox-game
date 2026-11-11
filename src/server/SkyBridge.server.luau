-- Original Roblox 3D Sky Bridge: solve four runes to reveal a temporary personal crossing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyBridgeRules"))
local rootFolder = Instance.new("Folder")
rootFolder.Name = "SkyBridgeChallenge3D"
rootFolder.Parent = Workspace
local function part(name, size, pos, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Anchored = true
    p.Color = color
    p.Material = Enum.Material.Slate
    p.Parent = parent or rootFolder
    return p
end
-- A separate, reachable course to the east of the starter island; no Canvas world geometry.
local start = Vector3.new(95, 12, 10)
part("ApproachPlatform", Vector3.new(25, 2, 24), start, Color3.fromRGB(95, 135, 170))
part("DestinationIsland", Vector3.new(22, 3, 25), start + Vector3.new(60, 0, 0), Color3.fromRGB(105, 160, 125))
local sign = part("RuneOrder_2_4_1_3", Vector3.new(9, 6, 1), start + Vector3.new(-9, 5, -8), Color3.fromRGB(80, 85, 150))
sign.CanCollide = false
local states = {}
local bridges = {}
local function notice(player, message)
    player:SetAttribute("SkyBridgeStatus", message)
end
local function clearBridge(player)
    local bridge = bridges[player]
    if bridge then bridge:Destroy() end
    bridges[player] = nil
end
local function showBridge(player)
    clearBridge(player)
    local bridge = Instance.new("Model")
    bridge.Name = "SkyBridge_" .. player.UserId
    bridge.Parent = rootFolder
    -- Shared physical bridge; visible to all players, but unlocking requires a personal puzzle.
    for i = 1, 6 do
        local p = part("BridgeSegment" .. i, Vector3.new(10, 1.5, 10),
            start + Vector3.new(i * 8, 0, 0), Color3.fromRGB(125, 195, 230), bridge)
        p.Material = Enum.Material.Glass
        p.Transparency = 0.15
    end
    bridges[player] = bridge
    task.delay(Rules.BRIDGE_DURATION, function()
        if bridges[player] == bridge then clearBridge(player) end
    end)
end
for padId = 1, 4 do
    local pad = part("RunePad_" .. padId, Vector3.new(5, 1, 5),
        start + Vector3.new(-7 + ((padId - 1) % 2) * 14, 2, -2 + math.floor((padId - 1) / 2) * 9),
        Color3.fromRGB(85 + padId * 20, 110, 210))
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate Rune " .. padId
    prompt.ObjectText = "Sky Bridge"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.25
    prompt.Parent = pad
    prompt.Triggered:Connect(function(player)
        local profileReady = player:GetAttribute("ProfileReady")
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if profileReady ~= true or not humanoid or humanoid.Health <= 0 or not root then return end
        if (root.Position - pad.Position).Magnitude > 13 then return end
        local state, result = Rules.step(states[player], padId, os.clock())
        states[player] = state
        if result == "unlocked" then
            showBridge(player)
            notice(player, "Sky Bridge opened for 75 seconds!")
        elseif result == "progress" then
            notice(player, "Rune " .. (state.index - 1) .. "/4 activated")
        elseif result == "wrong" then
            notice(player, "Wrong rune. Retry in 8 seconds.")
        elseif result == "wait" then
            notice(player, "Runes cooling down.")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    clearBridge(player)
end)
