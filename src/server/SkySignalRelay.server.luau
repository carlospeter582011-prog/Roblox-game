-- Three native 3D relay pylons form an ordered exploration puzzle across connected islands.
-- Server owns station ids, positions, timers and temporary reward; no client remote.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyRelayRules"))
local Profile = require(script.Parent:WaitForChild("ProfileStore"))
local stations = {
    { id = "meadow", position = Vector3.new(35, 2, 35), color = Color3.fromRGB(96, 225, 174) },
    { id = "eastwind", position = Vector3.new(170, 2, 30), color = Color3.fromRGB(124, 205, 244) },
    { id = "ridge", position = Vector3.new(315, 2, 30), color = Color3.fromRGB(190, 145, 255) },
}
local states = {}
local folder = Instance.new("Folder")
folder.Name = "SkySignalRelay3D"
folder.Parent = Workspace
local function makePart(parent, name, size, cf, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Parent = parent
    return part
end
local function activate(player, station)
    if not player or not player:IsA("Player") or not player.Parent then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local alive = humanoid ~= nil and humanoid.Health > 0
    local distance = root and (root.Position - station.position).Magnitude or math.huge
    local ready = player:GetAttribute("ProfileReady") == true and Profile.Get(player) ~= nil
    local ok, state, status = Rules.advance(states[player], station.id, os.clock(), distance, alive, ready)
    states[player] = state
    if not ok then
        player:SetAttribute("SkyRelayFeedback", status)
        return
    end
    if status == "progress" then
        player:SetAttribute("SkyRelayStep", state.step)
        player:SetAttribute("SkyRelayFeedback", "Signal connected! Find pylon " .. state.step .. " of 3.")
        return
    end
    player:SetAttribute("SkyRelayStep", 1)
    player:SetAttribute("SkyRelayFeedback", "Relay complete! Windrunner speed for 20 seconds.")
    -- Temporary, non-economic reward. Restore only if still the same character/humanoid.
    local originalSpeed = humanoid.WalkSpeed
    local boostedSpeed = math.max(originalSpeed, 22)
    humanoid.WalkSpeed = boostedSpeed
    local token = (player:GetAttribute("SkyRelayBoostToken") or 0) + 1
    player:SetAttribute("SkyRelayBoostToken", token)
    task.delay(20, function()
        if player.Parent and player.Character == character and humanoid.Parent and
            player:GetAttribute("SkyRelayBoostToken") == token and humanoid.WalkSpeed == boostedSpeed then
            humanoid.WalkSpeed = originalSpeed
        end
    end)
end
for index, station in ipairs(stations) do
    local model = Instance.new("Model")
    model.Name = "SignalPylon_" .. station.id
    model.Parent = folder
    local base = makePart(model, "Base", Vector3.new(6, 1, 6), CFrame.new(station.position - Vector3.new(0, 1, 0)), station.color)
    base.Material = Enum.Material.Slate
    local mast = makePart(model, "SignalMast", Vector3.new(1.5, 9, 1.5), CFrame.new(station.position + Vector3.new(0, 4, 0)), station.color)
    local orb = makePart(model, "SignalOrb", Vector3.new(3, 3, 3), CFrame.new(station.position + Vector3.new(0, 9, 0)), station.color)
    orb.Shape = Enum.PartType.Ball
    local attachment = Instance.new("Attachment")
    attachment.Position = Vector3.new(0, 2, 0)
    attachment.Parent = base
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ActivateSignal"
    prompt.ActionText = "Link Signal " .. index
    prompt.ObjectText = "Sky Relay"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = attachment
    prompt.Triggered:Connect(function(player) activate(player, station) end)
end
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
