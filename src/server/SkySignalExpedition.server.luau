-- Original 3D sky-signal expedition: visit three landmarks in order within 180 seconds.
-- ProximityPrompt is only an interaction request; server verifies distance, order and time.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("SkySignalRules"))
local folder = Instance.new("Folder")
folder.Name = "SkySignalExpedition3D"
folder.Parent = Workspace
local sessions, nextStart = {}, {}
local sites = {
    {id="meadow", x=-24, z=26, color=Color3.fromRGB(100,210,145)},
    {id="eastwind", x=186, z=23, color=Color3.fromRGB(95,185,245)},
    {id="ridge", x=332, z=24, color=Color3.fromRGB(190,125,240)},
}
for _, site in ipairs(sites) do
    local model = Instance.new("Model")
    model.Name = "Signal_" .. site.id
    model.Parent = folder
    local pedestal = Instance.new("Part")
    pedestal.Name = "Pedestal"
    pedestal.Size = Vector3.new(5,2,5)
    pedestal.Position = Vector3.new(site.x,4,site.z)
    pedestal.Anchored = true
    pedestal.Material = Enum.Material.Slate
    pedestal.Color = site.color
    pedestal.Parent = model
    local crystal = Instance.new("Part")
    crystal.Name = "SignalCrystal"
    crystal.Shape = Enum.PartType.Ball
    crystal.Size = Vector3.new(3,5,3)
    crystal.Position = pedestal.Position + Vector3.new(0,4,0)
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Material = Enum.Material.Neon
    crystal.Color = site.color
    crystal.Parent = model
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Activate Sky Signal"
    prompt.ObjectText = site.id .. " beacon"
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = pedestal
    prompt.Triggered:Connect(function(player)
        local data = ProfileStore.Get(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not data or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - pedestal.Position).Magnitude > 15 then return end
        local now = os.clock()
        local session = sessions[player]
        if not session or now - session.started > Rules.DURATION then
            sessions[player] = nil
            if site.id ~= "meadow" then
                player:SetAttribute("SkySignalFeedback", "Start at the Meadow beacon.")
                return
            end
            if not Rules.canStart(now, nextStart[player] or 0) then
                player:SetAttribute("SkySignalFeedback", "Sky signals recharging.")
                return
            end
            session = {index=1, started=now}
        end
        local following = Rules.next(session.index, site.id, session.started, now)
        if not following then
            player:SetAttribute("SkySignalFeedback", "Find the next beacon in order!")
            return
        end
        if following == 4 then
            sessions[player] = nil
            nextStart[player] = now + Rules.COOLDOWN
            local ok = ProfileStore.AwardSkySignal(player, Rules.COINS, Rules.XP)
            player:SetAttribute("SkySignalFeedback", ok and "Sky signals restored! +180 Coins, +90 XP" or "Reward unavailable.")
            player:SetAttribute("SkySignalProgress", 0)
        else
            sessions[player] = {index=following, started=session.started}
            player:SetAttribute("SkySignalProgress", following-1)
            player:SetAttribute("SkySignalFeedback", "Signal " .. (following-1) .. "/3! Find " .. Rules.ORDER[following])
        end
    end)
end
Players.PlayerRemoving:Connect(function(player)
    sessions[player] = nil
    nextStart[player] = nil
end)
