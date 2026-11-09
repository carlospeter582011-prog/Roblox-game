-- Compact catch HUD and short tutorial. Server decides whether a catch succeeds.
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

-- Tutorial overlay (first time only)
local tutorial = Instance.new("Frame")
tutorial.Name = "Tutorial"
tutorial.Size = UDim2.new(0.85, 0, 0, 90)
tutorial.Position = UDim2.new(0.075, 0, 0.35, 0)
tutorial.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
tutorial.BackgroundTransparency = 0.1
tutorial.Parent = gui
local tutorialLabel = Instance.new("TextLabel")
tutorialLabel.Size = UDim2.new(1, -12, 1, -12)
tutorialLabel.Position = UDim2.new(0, 6, 0, 6)
tutorialLabel.BackgroundTransparency = 1
tutorialLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
tutorialLabel.TextSize = 16
tutorialLabel.TextWrapped = true
tutorialLabel.Font = Enum.Font.Gotham
tutorialLabel.Text = "Tutorial: Walk near a glowing cloud, then tap the blue Catch button."
tutorialLabel.Parent = tutorial
local tutorialDone = false
local function hideTutorial()
    if tutorialDone then return end
    tutorialDone = true
    tutorial.Visible = false
end

-- Compact catch button (fixed size, no TextScaled)
local button = Instance.new("TextButton")
button.Name = "CatchButton"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -12, 1, -12)
button.Size = UDim2.fromOffset(120, 40)
button.BackgroundColor3 = Color3.fromRGB(71, 137, 230)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Text = "Catch"
button.Parent = gui

-- Compact status message
local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.7, 0, 0, 28)
message.Position = UDim2.new(0.15, 0, 0.05, 0)
message.BackgroundTransparency = 0.4
message.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
message.TextSize = 14
message.Font = Enum.Font.Gotham
message.TextColor3 = Color3.new(1, 1, 1)
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
    if success then
        button.Text = "Catch"
        hideTutorial()
    end
end)

-- Compact quest tracker
local questLabel = Instance.new("TextLabel")
questLabel.Name = "QuestTracker"
questLabel.Size = UDim2.new(0.6, 0, 0, 28)
questLabel.Position = UDim2.new(0.2, 0, 0.1, 0)
questLabel.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
questLabel.BackgroundTransparency = 0.2
questLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
questLabel.TextSize = 13
questLabel.Font = Enum.Font.Gotham
questLabel.Parent = gui
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
            questLabel.Text = quest.title .. " (" .. tostring(math.min(current, quest.required)) .. "/" .. tostring(quest.required) .. ")"
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

-- Compact level/coins
local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.Size = UDim2.fromOffset(140, 36)
levelLabel.Position = UDim2.new(0, 8, 0, 8)
levelLabel.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
levelLabel.BackgroundTransparency = 0.2
levelLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
levelLabel.TextSize = 13
levelLabel.Font = Enum.Font.Gotham
levelLabel.Parent = gui
local function refreshLevel()
    local level, into, needed = Leveling.progress(player:GetAttribute("CloudXP"))
    local xpText = needed == 0 and "MAX" or (tostring(math.floor(into)) .. "/" .. tostring(needed))
    levelLabel.Text = "Lv " .. tostring(level) .. "  " .. tostring(player:GetAttribute("CloudCoins") or 0) .. " coins"
end
for _, attribute in ipairs({ "CloudLevel", "CloudCoins", "CloudXP" }) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshLevel)
end
refreshLevel()

-- Hide tutorial after 20s or first successful catch
task.delay(20, hideTutorial)
