-- Three repeatable boss catch trials, represented by native Roblox 3D geometry.
-- No client-trusted progress or new DataStore schema; successful catches are read from ProfileStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProfileStore = require(script.Parent:WaitForChild("ProfileStore"))
local Rules = require(ReplicatedStorage:WaitForChild("BossChallengeRules"))
local folder = Instance.new("Folder")
folder.Name = "CloudBossArenas3D"
folder.Parent = Workspace
local active = {} -- [player] = {id, startCatches, deadline}
local cooldown = {}
local function createBoss(id, x, z, tint)
    local config = Rules.challenges[id]
    local model = Instance.new("Model")
    model.Name = config.name:gsub(" ", "") .. "3D"
    model.Parent = folder
    local function part(name, shape, size, pos, color, collide)
        local p = Instance.new("Part")
        p.Name = name
        p.Shape = shape
        p.Size = size
        p.Position = pos
        p.Anchored = true
        p.CanCollide = collide == true
        p.Color = color
        p.Material = Enum.Material.Slate
        p.Parent = model
        return p
    end
    part("ArenaBase", Enum.PartType.Cylinder, Vector3.new(1, 15, 15),
        Vector3.new(x, 1.5, z), tint, true).Orientation = Vector3.new(0, 0, 90)
    part("BossTorso", Enum.PartType.Ball, Vector3.new(7, 8, 5),
        Vector3.new(x, 8, z), tint, false)
    local head = part("BossHead", Enum.PartType.Ball, Vector3.new(5, 5, 5),
        Vector3.new(x, 14, z), Color3.fromRGB(210, 230, 245), false)
    for _, side in ipairs({ -1, 1 }) do
        part("BossArm", Enum.PartType.Ball, Vector3.new(3, 7, 3),
            Vector3.new(x + side * 5, 8, z), tint, false)
        local eye = part("BossEye", Enum.PartType.Ball, Vector3.new(0.8, 0.8, 0.8),
            Vector3.new(x + side * 1.1, 14.4, z - 2.25),
            Color3.fromRGB(35, 80, 125), false)
        eye.Material = Enum.Material.Neon
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ChallengeBoss"
    prompt.ActionText = "Start Catch Trial"
    prompt.ObjectText = config.name
    prompt.MaxActivationDistance = 13
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = false
    prompt.Parent = head
    prompt.Triggered:Connect(function(player)
        local profile = ProfileStore.Get(player)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if not profile or not root or not humanoid or humanoid.Health <= 0 then return end
        if (root.Position - head.Position).Magnitude > 17 then return end
        if active[player] then
            player:SetAttribute("BossChallengeFeedback", "Finish your current boss trial first!")
            return
        end
        if not Rules.canStart(id, profile.captures) then
            player:SetAttribute("BossChallengeFeedback", "Unlock at " .. config.requiredCatches .. " catches")
            return
        end
        local now = os.clock()
        if now < (cooldown[player] or 0) then
            player:SetAttribute("BossChallengeFeedback", "Boss resting. Try again shortly.")
            return
        end
        active[player] = { id = id, startCatches = profile.captures, deadline = now + config.seconds, phase = 1 }
        player:SetAttribute("BossChallengePhase", 1)
        player:SetAttribute("BossChallengeFeedback", config.name .. ": catch " .. config.goal .. " clouds in " .. config.seconds .. "s!")
        player:SetAttribute("BossChallengeProgress", "0/" .. config.goal)
    end)
end
-- Arenas are on solid island floors, away from the fast-travel arrival points.
createBoss("meadow", -55, 35, Color3.fromRGB(83, 159, 117))
createBoss("eastwind", 190, 27, Color3.fromRGB(90, 164, 205))
createBoss("ridge", 335, 25, Color3.fromRGB(145, 126, 192))
task.spawn(function()
    while true do
        task.wait(0.5)
        for player, trial in pairs(active) do
            local profile = ProfileStore.Get(player)
            if not profile or not player.Parent then
                active[player] = nil
            else
                local config = Rules.challenges[trial.id]
                local now = os.clock()
                local state = Rules.status(trial.startCatches, profile.captures, config.goal, trial.deadline, now)
                local count = Rules.progress(trial.startCatches, profile.captures, config.goal)
                player:SetAttribute("BossChallengeProgress", count .. "/" .. config.goal)
                if state == "active" then
                    local phase = Rules.phase(count, config.goal)
                    if phase > trial.phase then
                        trial.phase = phase
                        player:SetAttribute("BossChallengePhase", phase)
                        player:SetAttribute("BossChallengeFeedback", Rules.phaseMessage(phase, config.name))
                    end
                end
                if state == "complete" then
                    -- Clear active state before crediting, so this trial cannot pay twice.
                    active[player] = nil
                    cooldown[player] = now + 45
                    local rewarded, coins, xp = ProfileStore.AwardBossTrial(player, trial.id)
                    if rewarded then
                        player:SetAttribute("BossChallengeFeedback", config.name .. " defeated! +" .. coins .. " coins, +" .. xp .. " XP!")
                        player:SetAttribute("BossTrialsWon", (player:GetAttribute("BossTrialsWon") or 0) + 1)
                    else
                        player:SetAttribute("BossChallengeFeedback", "Trial complete, but reward unavailable. Rejoin if your profile disconnected.")
                    end
                    player:SetAttribute("BossChallengeProgress", "")
                    player:SetAttribute("BossChallengePhase", 0)
                elseif state == "expired" then
                    active[player] = nil
                    cooldown[player] = now + 15
                    player:SetAttribute("BossChallengeFeedback", config.name .. " escaped! Try again.")
                    player:SetAttribute("BossChallengeProgress", "")
                    player:SetAttribute("BossChallengePhase", 0)
                end
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    cooldown[player] = nil
end)
