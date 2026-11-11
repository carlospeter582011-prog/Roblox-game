-- Three native 3D beacon puzzle: touch/gamepad/keyboard via ProximityPrompt.
-- Server owns progression and distance validation; no RemoteEvent or client rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyBeaconRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local folder = Instance.new("Folder")
folder.Name = "SkyBeaconPuzzle3D"
folder.Parent = Workspace
local sessions = {}
local colors = { Color3.fromRGB(102, 205, 230), Color3.fromRGB(235, 192, 95), Color3.fromRGB(171, 131, 230) }
for index = 1, 3 do
    local stand = Instance.new("Part")
    stand.Name = "Beacon" .. index .. "3D"
    stand.Size = Vector3.new(4, 5, 4)
    stand.Position = Vector3.new(-28 + index * 9, 5, -25)
    stand.Anchored = true
    stand.CanCollide = true
    stand.Material = Enum.Material.SmoothPlastic
    stand.Color = colors[index]
    stand.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate"
    prompt.ObjectText = "Sky Beacon " .. index
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0.35
    prompt.RequiresLineOfSight = false
    prompt.Parent = stand
    prompt.Triggered:Connect(function(player)
        if not ProfileStore.Get(player) then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local state = sessions[player] or { stage = 0, started = 0, last = -100 }
        local now = os.clock()
        if now - state.last < 0.35 then return end
        local distance = (root.Position - stand.Position).Magnitude
        local nextStage, status = Rules.advance(state.stage, index, now - state.started, distance)
        if status == "far" or status == "invalid" then return end
        state.stage = nextStage
        state.last = now
        if status == "progress" and nextStage == 1 then state.started = now end
        if status == "complete" then
            local duration = math.max(0, now - state.started)
            local best = player:GetAttribute("SkyBeaconBestSeconds")
            if type(best) ~= "number" or duration < best then player:SetAttribute("SkyBeaconBestSeconds", math.floor(duration * 10) / 10) end
            player:SetAttribute("SkyBeaconCompletions", (player:GetAttribute("SkyBeaconCompletions") or 0) + 1)
            player:SetAttribute("SkyBeaconFeedback", "Sky puzzle complete! Try to beat your time.")
        elseif status == "progress" then
            player:SetAttribute("SkyBeaconFeedback", "Beacon " .. nextStage .. "/3. Find the next!")
        else
            player:SetAttribute("SkyBeaconFeedback", status == "expired" and "Time expired. Start again!" or "Wrong order. Start at beacon 1!")
        end
        sessions[player] = state
    end)
end
Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
