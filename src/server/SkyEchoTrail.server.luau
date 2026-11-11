-- Native 3D sky echo navigation trail. Reward-free until runtime validation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Rules = require(ReplicatedStorage:WaitForChild("SkyEchoRules"))
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local folder = Instance.new("Folder")
folder.Name = "SkyEchoTrail"
folder.Parent = Workspace
local states = {}
for index, point in ipairs(Rules.points) do
    local model = Instance.new("Model")
    model.Name = "SkyEcho_" .. index
    model.Parent = folder
    local base = Instance.new("Part")
    base.Name = "EchoPedestal"
    base.Size = Vector3.new(5, 2, 5)
    base.Shape = Enum.PartType.Cylinder
    base.Material = Enum.Material.Slate
    base.Anchored = true
    base.Position = Vector3.new(point.x, point.y - 3, point.z)
    base.Parent = model
    local beacon = Instance.new("Part")
    beacon.Name = "EchoCrystal"
    beacon.Shape = Enum.PartType.Ball
    beacon.Size = Vector3.new(3, 3, 3)
    beacon.Material = Enum.Material.Neon
    beacon.Color = Color3.fromRGB(95, 190, 255)
    beacon.Anchored = true
    beacon.CanCollide = false
    beacon.Position = Vector3.new(point.x, point.y, point.z)
    beacon.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Trace Echo " .. index .. "/" .. #Rules.points
    prompt.ObjectText = "Sky Echo Trail"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.5
    prompt.Parent = beacon
    prompt.Triggered:Connect(function(player)
        local data = ProfileStore.Get(player)
        if not data or player:GetAttribute("ProfileReady") ~= true then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local now = os.clock()
        local state = states[player] or { nextIndex = 1, last = 0, cooldown = 0 }
        if now < state.cooldown then return end
        local distance = (root.Position - beacon.Position).Magnitude
        if not Rules.canVisit(index, state.nextIndex, now - state.last, distance, true) then return end
        local nextIndex, completed = Rules.advance(index)
        state.last = now
        state.nextIndex = nextIndex or 1
        if completed then
            state.cooldown = now + Rules.RESTART_SECONDS
            player:SetAttribute("SkyEchoCompletions", (player:GetAttribute("SkyEchoCompletions") or 0) + 1)
        end
        states[player] = state
        player:SetAttribute("SkyEchoNext", state.nextIndex)
    end)
end
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
