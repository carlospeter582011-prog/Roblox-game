-- Compact optional party panel. Invite by server-listed player, no arbitrary user ID typing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("PartyAction")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PartyPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local toggle = Instance.new("TextButton")
toggle.Name = "PartyToggle"
toggle.Size = UDim2.fromOffset(94, 38)
toggle.Position = UDim2.new(1, -104, 0, 96)
toggle.Text = "Party"
toggle.TextScaled = true
toggle.Parent = gui
local frame = Instance.new("ScrollingFrame")
frame.Name = "PartyList"
frame.Size = UDim2.new(0, 230, 0, 260)
frame.Position = UDim2.new(1, -240, 0, 140)
frame.BackgroundTransparency = 0.15
frame.Visible = false
frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
frame.CanvasSize = UDim2.fromOffset(0, 0)
frame.Parent = gui
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = frame
local status = "Invite a player"
local members = {}
local leader = nil
local pending = nil
local function add(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 42)
    b.Text = text
    b.TextScaled = true
    b.TextWrapped = true
    b.Parent = frame
    b.Activated:Connect(callback or function() end)
end
local function refresh()
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    add(status)
    if pending then
        local from = pending
        add("Accept invite from " .. tostring(from), function()
            pending = nil
            remote:FireServer("accept", from)
        end)
    end
    add("Leave party", function() remote:FireServer("leave") end)
    if #members > 0 then add("Members: " .. table.concat(members, ", ")) end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and (#members == 0 or leader == player.UserId) then
            add("Invite " .. other.DisplayName, function()
                remote:FireServer("invite", other.UserId)
            end)
        end
    end
end
toggle.Activated:Connect(function()
    frame.Visible = not frame.Visible
    if frame.Visible then remote:FireServer("status") refresh() end
end)
remote.OnClientEvent:Connect(function(kind, payload)
    if kind == "invite" and type(payload) == "table" then
        pending = payload.from
        status = "Party invitation received"
        frame.Visible = true
    elseif kind == "state" and type(payload) == "table" then
        members = payload.members or {}
        leader = payload.leader
        status = #members > 1 and "Party active" or "Invite a player"
    elseif kind == "result" then
        status = tostring(payload)
    end
    refresh()
end)
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
