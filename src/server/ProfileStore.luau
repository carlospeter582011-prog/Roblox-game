-- Server-owned player profile. DataStore calls may fail in Studio without API access.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local store = DataStoreService:GetDataStore("CatchACloudProfiles_v1")
local Profile = {}
local questCatalog = require(game:GetService('ReplicatedStorage'):WaitForChild('QuestCatalog'))
local sessions = {}
local function defaultData()
    return {version=1, coins=0, xp=0, captures=0, species={}, quests={}, lastSeen=os.time()}
end
local function sanitize(data)
    if type(data)~="table" then return defaultData() end
    local clean=defaultData()
    for _,key in {"coins","xp","captures"} do
        if type(data[key])=="number" and data[key]>=0 and data[key]<1e12 then
            clean[key]=math.floor(data[key])
        end
    end
    if type(data.species)=="table" then
        for id,count in pairs(data.species) do
            if type(id)=="string" and #id<=48 and type(count)=="number" and count>=0 and count<=100000 then
                clean.species[id]=math.floor(count)
            end
        end
    end
    if type(data.quests)=='table' then
        for id,done in pairs(data.quests) do
            if type(id)=='string' and questCatalog[id] and done==true then clean.quests[id]=true end
        end
    end
    return clean
end
function Profile.Get(player)
    return sessions[player]
end
function Profile.AddCatch(player,speciesId,coins)
    local data=sessions[player]
    if not data then return false end
    data.species[speciesId]=(data.species[speciesId] or 0)+1
    data.captures+=1
    data.coins+=coins
    data.xp+=10
    for id,quest in pairs(questCatalog) do
        if not data.quests[id] then
            local progress = quest.objective=='catch_species' and (data.species[quest.speciesId] or 0) or data.captures
            if progress >= quest.required then
                data.quests[id]=true
                data.coins+=quest.rewardCoins
                data.xp+=quest.rewardXP
                player:SetAttribute('Quest_'..id,true)
            end
        end
    end
    player:SetAttribute("CloudCount",data.captures)
    player:SetAttribute("CloudCoins",data.coins)
    return true
end
function Profile.Save(player)
    local data=sessions[player]
    if not data then return false end
    local snapshot=sanitize(data)
    snapshot.lastSeen=os.time()
    local success,err=pcall(function()
        store:UpdateAsync("player_"..player.UserId,function(previous)
            -- Never overwrite a newer committed profile with an older in-memory snapshot.
            local old=sanitize(previous)
            if type(previous)=="table" and type(previous.lastSeen)=="number" and previous.lastSeen>snapshot.lastSeen then
                return nil
            end
            return snapshot
        end)
    end)
    if not success then warn("Profile save failed",player.UserId,err) end
    return success
end
Players.PlayerAdded:Connect(function(player)
    local ok,result=pcall(function() return store:GetAsync("player_"..player.UserId) end)
    if not ok then
        warn("Profile load failed; catching disabled until reconnect",player.UserId)
        player:SetAttribute("ProfileReady",false)
        return
    end
    sessions[player]=sanitize(result)
    player:SetAttribute("ProfileReady",true)
    player:SetAttribute("CloudCount",sessions[player].captures)
    player:SetAttribute("CloudCoins",sessions[player].coins)
    for id,_ in pairs(questCatalog) do player:SetAttribute('Quest_'..id,sessions[player].quests[id]==true) end
end)
Players.PlayerRemoving:Connect(function(player)
    Profile.Save(player)
    sessions[player]=nil
end)
game:BindToClose(function()
    for _,player in Players:GetPlayers() do Profile.Save(player) end
end)
task.spawn(function()
    while true do
        task.wait(90)
        for _,player in Players:GetPlayers() do Profile.Save(player) end
    end
end)
return Profile
