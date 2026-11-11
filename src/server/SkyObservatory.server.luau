-- Three physical sky observatory lenses; ordered survey rewards encourage exploration.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySurveyRules"))
local state = {}
local folder = Instance.new("Folder")
folder.Name = "SkyObservatory3D"
folder.Parent = Workspace
local locations = {
    Vector3.new(-25, 5, 15),
    Vector3.new(180, 5, -10),
    Vector3.new(320, 5, -15),
}
for index, position in ipairs(locations) do
    local model = Instance.new("Model")
    model.Name = "SurveyLens" .. index
    model.Parent = folder
    local pedestal = Instance.new("Part")
    pedestal.Name = "StonePedestal"
    pedestal.Size = Vector3.new(4, 3, 4)
    pedestal.Position = position
    pedestal.Anchored = true
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = Color3.fromRGB(84, 106, 145)
    pedestal.Parent = model
    local lens = Instance.new("Part")
    lens.Name = "SkyLens"
    lens.Shape = Enum.PartType.Ball
    lens.Size = Vector3.new(2.5, 2.5, 2.5)
    lens.Position = position + Vector3.new(0, 2.7, 0)
    lens.Anchored = true
    lens.CanCollide = false
    lens.Material = Enum.Material.Glass
    lens.Color = Color3.fromRGB(110, 196, 228)
    lens.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Survey Sky"
    prompt.ObjectText = "Observatory " .. index .. "/3"
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.35
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 or (root.Position - pedestal.Position).Magnitude > 13 then return end
        if not ProfileStore.Get(player) then return end
        local nextState, result = Rules.advance(state[player], index, os.clock())
        state[player] = nextState
        if result == "complete" then
            local awarded = ProfileStore.AwardSkySurvey(player, Rules.REWARD_COINS, Rules.REWARD_XP)
            player:SetAttribute("SkySurveyFeedback", awarded and "Sky survey complete! +180 Coins, +90 XP" or "Profile unavailable; reward not granted")
        elseif result == "started" then
            player:SetAttribute("SkySurveyFeedback", "Survey started! Visit lens 2 then 3 within 150 seconds.")
        elseif result == "advanced" then
            player:SetAttribute("SkySurveyFeedback", "Lens 2 calibrated! Find lens 3.")
        elseif result == "cooldown" then
            player:SetAttribute("SkySurveyFeedback", "Observatory recharging. Explore and return later.")
        else
            player:SetAttribute("SkySurveyFeedback", "Visit the lenses in order: 1, 2, 3.")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player) state[player] = nil end)
