-- Original 3D rune puzzle at Eastwind Outlook. Touch/gamepad/keyboard ProximityPrompts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkyRuneRules"))
local folder = Instance.new("Folder")
folder.Name = "SkyRunePuzzle3D"
folder.Parent = Workspace
local states = {}
for i = 1, 4 do
    local model = Instance.new("Model")
    model.Name = "RunePillar" .. i
    model.Parent = folder
    local pillar = Instance.new("Part")
    pillar.Name = "RuneStone"
    pillar.Size = Vector3.new(4, 6, 4)
    pillar.Position = Vector3.new(140 + (i - 1) * 20, 4, 30)
    pillar.Anchored = true
    pillar.CanCollide = true
    pillar.Material = Enum.Material.Slate
    pillar.Color = Color3.fromRGB(80, 105, 145)
    pillar.Parent = model
    local gem = Instance.new("Part")
    gem.Name = "RuneGem"
    gem.Shape = Enum.PartType.Ball
    gem.Size = Vector3.new(3, 3, 3)
    gem.Position = pillar.Position + Vector3.new(0, 4, 0)
    gem.Anchored = true
    gem.CanCollide = false
    gem.Material = Enum.Material.Glass
    gem.Color = Color3.fromRGB(100 + i * 22, 170, 225)
    gem.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate"
    prompt.ObjectText = "Sky Rune " .. i
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = pillar
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        if not Profile.Get(player) or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root then return end
        if (root.Position - pillar.Position).Magnitude > 14 then return end
        local nextState, result = Rules.step(states[player], i, os.clock())
        states[player] = nextState
        if result == "complete" then
            if Profile.AwardRunePuzzle(player, Rules.REWARD_COINS, Rules.REWARD_XP) then
                player:SetAttribute("SkyRuneFeedback", "Runes aligned! +60 Coins +35 XP")
            end
        elseif result == "progress" then
            player:SetAttribute("SkyRuneFeedback", "Rune " .. i .. " activated (" .. (nextState.index - 1) .. "/4)")
        elseif result == "reset" then
            player:SetAttribute("SkyRuneFeedback", "Wrong rune! Sequence reset.")
        elseif result == "cooldown" then
            player:SetAttribute("SkyRuneFeedback", "The runes are recharging.")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
