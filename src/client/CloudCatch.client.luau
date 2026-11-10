-- Compact catch HUD and short tutorial. Server decides whether a catch succeeds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Leveling = require(ReplicatedStorage:WaitForChild("Leveling"))
local tools = require(ReplicatedStorage:WaitForChild("CatchToolCatalog"))
local speciesCatalog = require(ReplicatedStorage:WaitForChild("CloudCatalog"))
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("RequestCloudCatch")
local folder = Workspace:WaitForChild("CatchableClouds")
local gui = Instance.new("ScreenGui")
gui.Name = "CloudCatchHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Tutorial overlay (first time only)
local tutorial = Instance.new("Frame")
tutorial.Name = "Tutorial"
tutorial.Size = UDim2.fromOffset(280, 42)
tutorial.AnchorPoint = Vector2.new(0.5, 0.5)
tutorial.Position = UDim2.new(0.5, 0, 0, 56)
tutorial.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
tutorial.BackgroundTransparency = 0.1
tutorial.Parent = gui
local tutorialLabel = Instance.new("TextLabel")
tutorialLabel.Size = UDim2.new(1, -12, 1, -12)
tutorialLabel.Position = UDim2.new(0, 6, 0, 6)
tutorialLabel.BackgroundTransparency = 1
tutorialLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
tutorialLabel.TextSize = 13
tutorialLabel.TextWrapped = true
tutorialLabel.Font = Enum.Font.Gotham
tutorialLabel.Text = "Approach a cloud, then tap Catch!"
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
-- Mid-right, clear of Roblox's own jump button at the bottom-right on touch devices.
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -20, 0.62, 0)
button.Size = UDim2.fromOffset(120, 40)
button.BackgroundColor3 = Color3.fromRGB(71, 137, 230)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Text = "Catch"
button.Parent = gui
local function updateCatchButton()
    local tool = tools[player:GetAttribute("EquippedCatchTool")] or tools.starter_net
    button.Text = "Catch +" .. tostring(tool.rangeBonus)
end
player:GetAttributeChangedSignal("EquippedCatchTool"):Connect(updateCatchButton)
updateCatchButton()

-- Compact status message
local message = Instance.new("TextLabel")
message.Size = UDim2.fromOffset(250, 30)
message.AnchorPoint = Vector2.new(0.5, 0)
message.Position = UDim2.new(0.5, 0, 0, 18)
message.BackgroundTransparency = 0.4
message.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
message.TextSize = 12
message.TextWrapped = true
message.Font = Enum.Font.Gotham
message.TextColor3 = Color3.new(1, 1, 1)
message.Text = ""
message.Visible = false
message.Parent = gui

button.Activated:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- Prefer the nearest *reachable* cloud. The old nearest-only approach could
    -- repeatedly target an out-of-range species while another was catchable.
    local toolId = player:GetAttribute("EquippedCatchTool")
    local tool = tools[toolId] or tools.starter_net
    local nearest, distance = nil, math.huge
    for _, cloud in ipairs(folder:GetChildren()) do
        if cloud:IsA("BasePart") and cloud:GetAttribute("CloudId") then
            local species = speciesCatalog[cloud:GetAttribute("SpeciesId")]
            if species then
                local d = (root.Position - cloud.Position).Magnitude
                local maxRange = species.baseCatchRadius + tool.rangeBonus
                if toolId == "cloud_magnet" then maxRange += 12 end
                if d <= maxRange and d < distance then
                    nearest, distance = cloud, d
                end
            end
        end
    end
    if nearest then
        remote:FireServer(nearest:GetAttribute("CloudId"))
    else
        message.Text = "Move closer to a cloud!"
        message.Visible = true
        task.delay(3, function()
            if message.Text == "Move closer to a cloud!" then message.Visible = false end
        end)
    end
end)

remote.OnClientEvent:Connect(function(success, text)
    message.Text = text
    message.Visible = true
    task.delay(3, function()
        if message.Text == text then message.Visible = false end
    end)
    if success then
        updateCatchButton()
        hideTutorial()
    end
end)

-- Server travel prompts share the compact status display; no in-world Canvas UI.
player:GetAttributeChangedSignal("TravelFeedback"):Connect(function()
    local feedback = player:GetAttribute("TravelFeedback")
    if type(feedback) ~= "string" or feedback == "" then return end
    message.Text = feedback
    message.Visible = true
    task.delay(3, function()
        if message.Text == feedback then message.Visible = false end
    end)
end)

-- Server-owned boss trial updates share the existing compact catch feedback surface.
player:GetAttributeChangedSignal("BossChallengeFeedback"):Connect(function()
    local feedback = player:GetAttribute("BossChallengeFeedback")
    if type(feedback) ~= "string" or feedback == "" then return end
    message.Text = feedback
    message.Visible = true
    task.delay(5, function()
        if message.Text == feedback then message.Visible = false end
    end)
end)
local bossProgress = Instance.new("TextLabel")
bossProgress.Name = "BossTrialProgress"
bossProgress.Size = UDim2.fromOffset(175, 28)
bossProgress.AnchorPoint = Vector2.new(1, 0.5)
bossProgress.Position = UDim2.new(1, -16, 0.52, 0)
bossProgress.BackgroundColor3 = Color3.fromRGB(63, 44, 94)
bossProgress.BackgroundTransparency = 0.15
bossProgress.TextColor3 = Color3.new(1, 1, 1)
bossProgress.TextSize = 13
bossProgress.Font = Enum.Font.GothamBold
bossProgress.Visible = false
bossProgress.Parent = gui
local function updateBossProgress()
    local value = player:GetAttribute("BossChallengeProgress")
    bossProgress.Visible = type(value) == "string" and value ~= ""
    bossProgress.Text = "Boss Trial  " .. tostring(value or "")
end
player:GetAttributeChangedSignal("BossChallengeProgress"):Connect(updateBossProgress)
updateBossProgress()

-- Native crystal discoveries use a ProximityPrompt, while this ScreenGui provides
-- immediate touch-friendly confirmation of rewards and total progress.
local crystalToast = Instance.new("TextLabel")
crystalToast.Name = "CrystalToast"
crystalToast.Size = UDim2.fromOffset(280, 36)
crystalToast.AnchorPoint = Vector2.new(0.5, 0)
crystalToast.Position = UDim2.new(0.5, 0, 0, 72)
crystalToast.BackgroundColor3 = Color3.fromRGB(36, 76, 92)
crystalToast.TextColor3 = Color3.fromRGB(250, 250, 255)
crystalToast.Font = Enum.Font.GothamBold
crystalToast.TextSize = 13
crystalToast.TextWrapped = true
crystalToast.Visible = false
crystalToast.Parent = gui
local toastSerial = 0
player:GetAttributeChangedSignal("CrystalDiscoveryFeedback"):Connect(function()
    local feedback = player:GetAttribute("CrystalDiscoveryFeedback")
    if type(feedback) ~= "string" or feedback == "" then return end
    toastSerial += 1
    local serial = toastSerial
    crystalToast.Text = feedback .. " (" .. tostring(player:GetAttribute("SkyCrystalsDiscovered") or 0) .. "/18)"
    crystalToast.Visible = true
    task.delay(3, function()
        if toastSerial == serial then crystalToast.Visible = false end
    end)
end)

-- Compact quest tracker
local questLabel = Instance.new("TextLabel")
questLabel.Name = "QuestTracker"
questLabel.Size = UDim2.fromOffset(250, 28)
questLabel.AnchorPoint = Vector2.new(1, 0)
questLabel.Position = UDim2.new(1, -16, 0, 118)
questLabel.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
questLabel.BackgroundTransparency = 0.2
questLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
questLabel.TextSize = 12
questLabel.TextTruncate = Enum.TextTruncate.AtEnd
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
levelLabel.Size = UDim2.fromOffset(290, 40)
levelLabel.Position = UDim2.new(0, 16, 0, 102)
levelLabel.BackgroundColor3 = Color3.fromRGB(24, 53, 91)
levelLabel.BackgroundTransparency = 0.2
levelLabel.TextColor3 = Color3.fromRGB(245, 250, 255)
levelLabel.TextSize = 16
levelLabel.Font = Enum.Font.Gotham
levelLabel.Parent = gui
local function refreshLevel()
    local level, into, needed = Leveling.progress(player:GetAttribute("CloudXP"))
    local xpText = needed == 0 and "MAX" or (tostring(math.floor(into)) .. "/" .. tostring(needed))
    levelLabel.Text = "Lv " .. tostring(level) .. "  " .. xpText .. " XP  " .. tostring(player:GetAttribute("CloudCoins") or 0) .. " coins"
end
for _, attribute in ipairs({ "CloudLevel", "CloudCoins", "CloudXP" }) do
    player:GetAttributeChangedSignal(attribute):Connect(refreshLevel)
end
refreshLevel()

-- Hide tutorial after 20s or first successful catch
task.delay(7, hideTutorial)
