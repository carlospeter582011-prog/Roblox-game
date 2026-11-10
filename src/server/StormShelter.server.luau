-- Shared storm-shelter puzzle. Original native 3D geometry; no client reward remotes.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("StormShelterRules"))
local model = Instance.new("Model")
model.Name = "StormShelter3D"
model.Parent = Workspace
local state = nil
local busy = false
local center = Vector3.new(315, 2, -31)
local function makePart(name, position, size, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.Position = position
    part.Size = size
    part.Material = Enum.Material.Slate
    part.Color = color
    part.Parent = model
    return part
end
makePart("ShelterBase", center, Vector3.new(17, 2, 12), Color3.fromRGB(72, 104, 139))
local pillar = makePart("ShelterBeacon", center + Vector3.new(0, 6, 0), Vector3.new(2, 10, 2), Color3.fromRGB(105, 164, 196))
pillar.Material = Enum.Material.Glass
for i, offset in ipairs({ Vector3.new(-8, 0, -3), Vector3.new(0, 0, -8), Vector3.new(8, 0, -3) }) do
    local pos = center + offset
    local pedestal = makePart("StormSignal" .. i, pos, Vector3.new(3, 3, 3), Color3.fromRGB(127, 173, 214))
    pedestal.Shape = Enum.PartType.Ball
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Tune Signal"
    prompt.ObjectText = "Storm Shelter " .. i .. "/3"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if busy or not player or not player.Parent or not Profile.Get(player) then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not root or (root.Position - pos).Magnitude > 13 then return end
        busy = true
        local accepted, result, nextState = Rules.activate(state, i, os.clock())
        state = nextState
        if result == "complete" then
            for _, ally in Players:GetPlayers() do
                local allyCharacter = ally.Character
                local allyRoot = allyCharacter and allyCharacter:FindFirstChild("HumanoidRootPart")
                local allyHumanoid = allyCharacter and allyCharacter:FindFirstChildOfClass("Humanoid")
                if Profile.Get(ally) and allyRoot and allyHumanoid and allyHumanoid.Health > 0
                    and (allyRoot.Position - center).Magnitude <= 48 then
                    local shield = Instance.new("ForceField")
                    shield.Name = "StormShelterShield"
                    shield.Visible = true
                    shield.Parent = allyCharacter
                    game:GetService("Debris"):AddItem(shield, Rules.SHIELD_SECONDS)
                    ally:SetAttribute("StormShelterFeedback", "Storm shelter activated! 20s protection.")
                end
            end
        elseif accepted then
            player:SetAttribute("StormShelterFeedback", "Signal tuned! Activate all three within 25 seconds.")
        elseif result == "cooldown" then
            player:SetAttribute("StormShelterFeedback", "Shelter recharging. Return shortly.")
        else
            player:SetAttribute("StormShelterFeedback", "Signal already tuned.")
        end
        busy = false
    end)
end
