-- Mobile and desktop catch button. Server decides whether a catch succeeds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RequestCloudCatch")
local folder = Workspace:WaitForChild("CatchableClouds")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudCatchHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Name = "CatchButton"
-- Mid-right, clear of Roblox's own jump button and thumbstick at the bottom of the screen.
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -24, 0.6, 0)
button.Size = UDim2.fromOffset(170, 70)
button.BackgroundColor3 = Color3.fromRGB(71, 137, 230)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Text = "Catch Cloud"
button.Parent = gui
local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.8, 0, 0, 42)
message.Position = UDim2.new(0.1, 0, 0.08, 0)
message.BackgroundTransparency = 0.3
message.TextScaled = true
message.Text = "Find a glowing cloud and get close!"
message.Parent = gui
button.Activated:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local nearest, distance = nil, math.huge
    for _, cloud in folder:GetChildren() do
        if cloud:IsA("BasePart") then
            local d = (root.Position - cloud.Position).Magnitude
            if d < distance then nearest, distance = cloud, d end
        end
    end
    if nearest then
        remote:FireServer(nearest:GetAttribute("CloudId"))
    else
        message.Text = "No clouds nearby yet."
    end
end)
remote.OnClientEvent:Connect(function(success, text)
    message.Text = text
    if success then button.Text = "Catch Another" end
end)

local questLabel=Instance.new("TextLabel")
questLabel.Name="QuestTracker"
questLabel.Size=UDim2.new(0.75,0,0,54)
questLabel.Position=UDim2.new(0.125,0,0.16,0)
questLabel.BackgroundColor3=Color3.fromRGB(24,53,91)
questLabel.BackgroundTransparency=0.15
questLabel.TextColor3=Color3.fromRGB(245,250,255)
questLabel.TextScaled=true
questLabel.Parent=gui
local QuestCatalog = require(ReplicatedStorage:WaitForChild("QuestCatalog"))
local orderedQuests = {}
for _, quest in pairs(QuestCatalog) do
    table.insert(orderedQuests, quest)
end
table.sort(orderedQuests, function(a, b)
    if a.chapter ~= b.chapter then return a.chapter < b.chapter end
    if a.required ~= b.required then return a.required < b.required end
    return a.id < b.id
end)
local function refreshQuest()
    for _, quest in ipairs(orderedQuests) do
        if not player:GetAttribute("Quest_" .. quest.id) then
            local current = 0
            if quest.objective == "total_catches" then
                current = player:GetAttribute("CloudCount") or 0
            else
                current = player:GetAttribute("SpeciesCount_" .. quest.speciesId) or 0
            end
            questLabel.Text = quest.title .. " (" .. tostring(math.min(current, quest.required))
                .. "/" .. tostring(quest.required) .. ")"
            return
        end
    end
    questLabel.Text = "All available quests completed!"
end
player:GetAttributeChangedSignal("CloudCount"):Connect(refreshQuest)
for _, quest in ipairs(orderedQuests) do
    player:GetAttributeChangedSignal("Quest_" .. quest.id):Connect(refreshQuest)
    if quest.objective == "catch_species" then
        player:GetAttributeChangedSignal("SpeciesCount_" .. quest.speciesId):Connect(refreshQuest)
    end
end
refreshQuest()

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Size = UDim2.fromOffset(220, 52)
levelLabel.Position = UDim2.new(0, 12, 0, 12)
levelLabel.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
levelLabel.BackgroundTransparency = 0.15
levelLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
levelLabel.TextScaled = true
levelLabel.Parent = gui
local function refreshLevel()
    local level, into, needed = Leveling.progress(player:GetAttribute("CloudXP"))
    local xpText = needed == 0 and "MAX" or (tostring(math.floor(into)) .. "/" .. tostring(needed) .. " XP")
    levelLabel.Text = "Lv " .. tostring(level) .. "  |  " .. tostring(player:GetAttribute("CloudCoins") or 0) .. " coins\n" .. xpText
end
for _, attribute in ipairs({ "CloudLevel", "CloudCoins", "CloudXP" }) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshLevel)
end
refreshLevel()
