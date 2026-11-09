-- Lightweight touch, mouse and gamepad-friendly equipment picker.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local catalog=require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local equip=ReplicatedStorage:WaitForChild("EquipCatchTool")
local gui=Instance.new("ScreenGui")
gui.Name="CloudToolPicker"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local button=Instance.new("TextButton")
button.Size=UDim2.fromOffset(160,48)
button.Position=UDim2.new(0,12,1,-68)
button.Text="Tools"
button.TextScaled=true
button.BackgroundColor3=Color3.fromRGB(33,85,125)
button.TextColor3=Color3.new(1,1,1)
button.Parent=gui
local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,250,0,270)
panel.Position=UDim2.new(0,12,1,-348)
panel.Visible=false
panel.BackgroundColor3=Color3.fromRGB(24,48,81)
panel.Parent=gui
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,4)
layout.Parent=panel
local order={"starter_net","wind_lasso","mist_gloves","cloud_magnet","golden_net"}
local rows={}
for _,id in ipairs(order) do
    local tool=catalog[id]
    local row=Instance.new("TextButton")
    row.Name=id
    row.Size=UDim2.new(1,-8,0,48)
    row.TextScaled=true
    row.TextColor3=Color3.new(1,1,1)
    row.BackgroundColor3=Color3.fromRGB(45,103,139)
    row.Parent=panel
    row.Activated:Connect(function()
        if (player:GetAttribute("CloudCount") or 0)>=tool.unlockCatches then
            equip:FireServer(id)
            panel.Visible=false
        end
    end)
    rows[id]=row
end
local function refresh()
    local count=player:GetAttribute("CloudCount") or 0
    for id,row in pairs(rows) do
        local tool=catalog[id]
        local locked=count<tool.unlockCatches
        row.Text=tool.name..(locked and (" | unlock at "..tool.unlockCatches) or " | available")
    end
end
player:GetAttributeChangedSignal("CloudCount"):Connect(refresh)
button.Activated:Connect(function()
    refresh()
    panel.Visible=not panel.Visible
end)
refresh()
