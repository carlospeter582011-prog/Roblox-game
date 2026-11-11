-- Original native 3D checkpoint route: Meadow -> Eastwind -> Thunderhead.
-- Session-only records; no unverified persistent rewards or client-supplied times.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("SkySurveyRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local folder = Instance.new("Folder")
folder.Name = "SkySurvey3D"
folder.Parent = Workspace
local states = {}

local stations = {
    { id = "meadow", position = Vector3.new(-32, 2, 24), color = Color3.fromRGB(104, 203, 179) },
    { id = "eastwind", position = Vector3.new(165, 2, 25), color = Color3.fromRGB(113, 170, 236) },
    { id = "ridge", position = Vector3.new(315, 2, 25), color = Color3.fromRGB(175, 144, 238) },
}

for _, info in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = "Survey_" .. info.id
    model.Parent = folder
    local pedestal = Instance.new("Part")
    pedestal.Name = "SurveyPedestal"
    pedestal.Size = Vector3.new(7, 2, 7)
    pedestal.Position = info.position
    pedestal.Anchored = true
    pedestal.CanCollide = true
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = info.color
    pedestal.Parent = model
    local orb = Instance.new("Part")
    orb.Name = "SurveyOrb"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(3, 3, 3)
    orb.Position = info.position + Vector3.new(0, 3, 0)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Color = info.color
    orb.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Survey"
    prompt.ObjectText = "Sky Survey: " .. info.id
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = Rules.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent then return end
        if not Profile.Get(player) or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local distance = (root.Position - pedestal.Position).Magnitude
        if not Rules.validDistance(distance) then return end
        local state = states[player]
        if info.id == "meadow" then
            state = { nextIndex = 1, started = os.clock() }
            states[player] = state
        end
        if not state then
            player:SetAttribute("SkySurveyFeedback", "Start at Meadow!")
            return
        end
        local elapsed = os.clock() - state.started
        local nextIndex, result = Rules.advance(state.nextIndex, info.id, elapsed, distance)
        if not nextIndex then
            player:SetAttribute("SkySurveyFeedback", result == "expired" and "Survey expired: restart at Meadow" or "Visit the next station in order")
            if result == "expired" then states[player] = nil end
            return
        end
        if result == "complete" then
            local previous = player:GetAttribute("SkySurveyBest")
            local best = Rules.best(previous, elapsed)
            player:SetAttribute("SkySurveyBest", math.floor(best * 10 + 0.5) / 10)
            player:SetAttribute("SkySurveyCompleted", (player:GetAttribute("SkySurveyCompleted") or 0) + 1)
            player:SetAttribute("SkySurveyFeedback", string.format("Survey complete in %.1fs! Best %.1fs", elapsed, best))
            states[player] = nil
        else
            state.nextIndex = nextIndex
            player:SetAttribute("SkySurveyFeedback", "Checkpoint " .. (nextIndex - 1) .. "/3. Continue!")
        end
    end)
end

Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
