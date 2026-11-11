-- Sky Relay: repeatable, physical 3D time trial. No client-controlled rewards or times.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRelayRules"))
local origin = Vector3.new(42, 17, -12)
local offsets = { Vector3.new(0,0,0), Vector3.new(30,0,-20), Vector3.new(55,0,-45), Vector3.new(20,0,-70) }
local folder = Instance.new("Folder")
folder.Name = "SkyRelayCourse"
folder.Parent = workspace
local states = {}
local lastStarts = {}
local function makeGate(i, position)
    local model = Instance.new("Model")
    model.Name = "RelayGate" .. i
    model.Parent = folder
    for side = -1,1,2 do
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar"
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.Size = Vector3.new(2,12,2)
        pillar.Material = Enum.Material.SmoothPlastic
        pillar.Color = Color3.fromRGB(105,185,220)
        pillar.Position = position + Vector3.new(side*6,6,0)
        pillar.Parent = model
    end
    local top = Instance.new("Part")
    top.Name = "Arch"
    top.Anchored = true
    top.CanCollide = false
    top.Size = Vector3.new(14,2,2)
    top.Position = position + Vector3.new(0,12,0)
    top.Color = Color3.fromRGB(120,220,240)
    top.Material = Enum.Material.Neon
    top.Parent = model
    local marker = Instance.new("Part")
    marker.Name = "Checkpoint"
    marker.Anchored = true
    marker.CanCollide = false
    marker.Transparency = 0.35
    marker.Material = Enum.Material.ForceField
    marker.Color = Color3.fromRGB(100,210,230)
    marker.Size = Vector3.new(12,8,2)
    marker.Position = position + Vector3.new(0,5,0)
    marker.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = i == 1 and "Start Sky Relay" or ("Pass Gate " .. i)
    prompt.ObjectText = "Sky Relay"
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = marker
    prompt.Triggered:Connect(function(player)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or (root.Position - marker.Position).Magnitude > 13 then return end
        local now = os.clock()
        if i == 1 then
            local previous = lastStarts[player] and {lastStart = lastStarts[player]} or nil
            local state, reason = Rules.start(previous, now)
            if not state then player:SetAttribute("RelayStatus", reason); return end
            states[player] = state
            lastStarts[player] = now
            player:SetAttribute("RelayStatus", "Relay started! Find gate 2")
            player:SetAttribute("RelayGate", 1)
            return
        end
        local state = states[player]
        if not state then return end
        -- First gate starts the race; subsequent gates must be visited in order.
        local nextState = Rules.advance(state, i-1, now)
        if not nextState then return end
        states[player] = nextState
        player:SetAttribute("RelayGate", i)
        if i == #offsets then
            local elapsed = math.floor((now - state.started)*100)/100
            local best = player:GetAttribute("RelayBest")
            if type(best) ~= "number" or elapsed < best then player:SetAttribute("RelayBest", elapsed) end
            player:SetAttribute("RelayStatus", "Finished in " .. elapsed .. "s! (session best)")
            states[player] = nil
        else
            player:SetAttribute("RelayStatus", "Gate " .. i .. " cleared!")
        end
    end)
end
-- Wide connected stepping decks keep the course traversable on touch controls.
for i, offset in ipairs(offsets) do
    local point = origin + offset
    local deck = Instance.new("Part")
    deck.Name = "RelayDeck" .. i
    deck.Anchored = true
    deck.Size = Vector3.new(20, 2, 20)
    deck.Position = point - Vector3.new(0, 1.5, 0)
    deck.Color = Color3.fromRGB(105, 150, 175)
    deck.Material = Enum.Material.Slate
    deck.Parent = folder
    makeGate(i, point)
    if i > 1 then
        local previous = origin + offsets[i-1]
        local difference = point - previous
        local bridge = Instance.new("Part")
        bridge.Name = "RelayBridge" .. i
        bridge.Anchored = true
        bridge.Size = Vector3.new(12, 2, difference.Magnitude + 2)
        bridge.CFrame = CFrame.lookAt((point + previous)/2 - Vector3.new(0,1.5,0), point - Vector3.new(0,1.5,0))
        bridge.Color = Color3.fromRGB(130, 175, 190)
        bridge.Material = Enum.Material.Slate
        bridge.Parent = folder
    end
end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    lastStarts[player] = nil
end)
