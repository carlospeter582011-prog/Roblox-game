-- Cooperative 3D exploration puzzle on Eastwind Outlook. Server owns sequence and timer.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkyChimeRules"))
local Workspace = game:GetService("Workspace")
local folder = Instance.new("Model")
folder.Name = "EastwindSkyChimeSanctuary"
folder.Parent = Workspace
local function make(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Parent = folder
    return p
end
-- Outlook extends to z=50. A solid bridge leads to a secret observation balcony.
make("SanctuaryBridge", Vector3.new(12, 2, 24), Vector3.new(170, 0, 60), Color3.fromRGB(142, 116, 87), Enum.Material.WoodPlanks)
make("SanctuaryBalcony", Vector3.new(38, 2, 30), Vector3.new(170, 0, 84), Color3.fromRGB(114, 180, 158), Enum.Material.Grass)
local gate = make("ChimeGate", Vector3.new(12, 13, 2), Vector3.new(170, 7, 49), Color3.fromRGB(120, 182, 235), Enum.Material.ForceField)
local state = nil
local lastTouch = {}
local chimePositions = {Vector3.new(148, 3, 27), Vector3.new(170, 3, 27), Vector3.new(192, 3, 27)}
local function refresh()
    local opened = Rules.isOpen(state, os.clock())
    gate.CanCollide = not opened
    gate.Transparency = opened and 0.85 or 0.25
    gate.Color = opened and Color3.fromRGB(115, 230, 165) or Color3.fromRGB(120, 182, 235)
end
for i, pos in ipairs(chimePositions) do
    local pillar = make("ChimePedestal" .. i, Vector3.new(5, 5, 5), pos, Color3.fromRGB(106, 121, 167), Enum.Material.Slate)
    local bell = make("ChimeBell" .. i, Vector3.new(3, 4, 3), pos + Vector3.new(0, 4, 0), Color3.fromRGB(245, 204, 112), Enum.Material.Metal)
    bell.Shape = Enum.PartType.Ball
    bell.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ring"
    prompt.ObjectText = "Sky Chime " .. i
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.15
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent or player:GetAttribute("ProfileReady") ~= true then return end
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 or (root.Position - pillar.Position).Magnitude > 15 then return end
        local now = os.clock()
        if now - (lastTouch[player] or -100) < 0.35 then return end
        lastTouch[player] = now
        local nextState, outcome = Rules.advance(state, i, now)
        if not nextState then return end
        state = nextState
        refresh()
        -- Public puzzle feedback is session-only, no economy rewards or persistent flags.
        for _, participant in Players:GetPlayers() do
            participant:SetAttribute("SkyChimeStatus", outcome == "solved" and "Sanctuary open for 45 seconds!" or
                outcome == "progress" and ("Chime " .. i .. " resonated!") or
                outcome == "reset" and "Wrong chime! Try again." or
                outcome == "open" and "Sanctuary is open!" or "Wait for the chimes")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) lastTouch[player] = nil end)
task.spawn(function()
    while folder.Parent do
        task.wait(0.5)
        refresh()
    end
end)
