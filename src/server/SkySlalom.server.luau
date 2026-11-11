-- Original 3D time-trial slalom. No currency farming or client-controlled remotes.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("SlalomRules"))
local folder = Instance.new("Folder")
folder.Name = "SkySlalom3D"
folder.Parent = Workspace
local positions = {
    Vector3.new(25, 3, -48),
    Vector3.new(73, 3, -48),
    Vector3.new(151, 3, -32),
    Vector3.new(195, 3, 30),
}
local states = {}
local best = {}
for i, position in ipairs(positions) do
    local model = Instance.new("Model")
    model.Name = "SlalomGate" .. i
    model.Parent = folder
    local function beam(name, size, offset)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = position + offset
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(88, 193, 216)
        p.Parent = model
        return p
    end
    beam("LeftPillar", Vector3.new(2, 12, 2), Vector3.new(-7, 4, 0))
    beam("RightPillar", Vector3.new(2, 12, 2), Vector3.new(7, 4, 0))
    local top = beam("TopBeam", Vector3.new(16, 2, 2), Vector3.new(0, 10, 0))
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = i == 1 and "Start time trial" or "Pass checkpoint"
    prompt.ObjectText = "Sky Slalom " .. i .. "/4"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.2
    prompt.RequiresLineOfSight = false
    prompt.Parent = top
    prompt.Triggered:Connect(function(player)
        if not player or not player:IsA("Player") or not player.Parent
            or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local distance = (root.Position - position).Magnitude
        local nextState, outcome = Rules.advance(states[player], i, distance, os.clock())
        if not nextState then
            player:SetAttribute("SlalomFeedback", outcome)
            return
        end
        states[player] = nextState
        if outcome == "finished" then
            local elapsed = nextState.finished
            if not best[player] or elapsed < best[player] then best[player] = elapsed end
            player:SetAttribute("SlalomBestSeconds", math.floor(best[player] * 100) / 100)
            player:SetAttribute("SlalomFeedback", string.format("Finished in %.2fs! Best %.2fs", elapsed, best[player]))
        else
            player:SetAttribute("SlalomFeedback", outcome .. " " .. i .. "/4")
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
    best[player] = nil
end)
