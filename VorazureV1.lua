--[[
    +1 Loot To Forge — ServerScript
    Mobile-First Design
    Place in ServerScriptService
    Compatible with existing Hub V3 remote structure
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- ====================================================================
-- 📦 CONFIGURATION
-- ====================================================================
local LootForgeConfig = {
    -- Loot Drop Settings
    LootSpawnInterval = 10,
    LootSpawnRadius = 50,
    LootDespawnTime = 120,
    MaxLootPerSpawn = 5,

    -- Forge Settings (+1 Upgrade)
    ForgeCostBase = 50,
    ForgeCostPerLevel = 20,
    ForgeGemCost = 1,
    ForgeSuccessBase = 0.7,
    ForgeSuccessPenalty = 0.02,

    -- Auto Sell Junk Gear
    AutoSellJunkGear = true,
    AutoEquipBest = true,

    -- Target Mode for +1 Forge
    ForgeTargetMode = "CYCLE",
    ForgeInterval = 1.5,

    -- Rarity system
    RarityOrder = {"Common", "Uncommon", "Rare", "Epic", "Legendary"},
    RarityColors = {
        Common    = Color3.fromRGB(200, 200, 200),
        Uncommon  = Color3.fromRGB(0, 255, 0),
        Rare      = Color3.fromRGB(0, 100, 255),
        Epic      = Color3.fromRGB(160, 0, 255),
        Legendary = Color3.fromRGB(255, 215, 0),
    },
    RarityMultipliers = {
        Common    = 1,
        Uncommon  = 2,
        Rare      = 5,
        Epic      = 10,
        Legendary = 25,
    },

    -- Item templates for loot
    ItemTemplates = {
        "Sword", "Shield", "Helmet", "Armor", "Boots",
        "Ring", "Amulet", "Dagger", "Bow", "Staff",
        "Pickaxe", "Axe", "Spear", "Crossbow", "Orb",
    },

    -- Sell prices per rarity
    SellPrices = {
        Common    = 5,
        Uncommon  = 15,
        Rare      = 50,
        Epic      = 150,
        Legendary = 500,
    },
}

-- ====================================================================
-- 🗄️ DATASTORE
-- ====================================================================
local DataStore = DataStoreService:GetDataStore("LootToForge+1_PlayerData")

local function LoadPlayerData(player)
    local key = "LTF_" .. player.UserId
    local success, data = pcall(function()
        return DataStore:GetAsync(key)
    end)

    if success and data then
        return data
    end

    -- Default new player data
    return {
        TotalLootCollected = 0,
        TotalForges = 0,
        TotalSells = 0,
        TotalCoinsEarned = 0,
        ForgeHistory = {},
        BestWeaponLevel = 0,
        BestArmorLevel = 0,
        BestHatLevel = 0,
        LootSpawnsToday = 0,
        LastDailyReset = os.date("%Y-%m-%d"),
    }
end

local function SavePlayerData(player, data)
    local key = "LTF_" .. player.UserId
    pcall(function()
        DataStore:SetAsync(key, data)
    end)
end

-- ====================================================================
-- 🔧 UTILITY
-- ====================================================================
local function FormatNumber(n)
    local num = tonumber(n)
    if not num then return tostring(n or "0") end
    local suffixes = {
        {1e33, "Dc"}, {1e30, "No"}, {1e27, "Oc"}, {1e24, "Sp"},
        {1e21, "Sx"}, {1e18, "Qi"}, {1e15, "Qa"}, {1e12, "T"},
        {1e9, "B"}, {1e6, "M"}, {1e3, "K"}
    }
    for _, s in ipairs(suffixes) do
        if num >= s[1] then
            return string.format("%.2f%s", num / s[1], s[2])
        end
    end
    return tostring(math.floor(num))
end

local function GetRandomRarity()
    local roll = math.random()
    local cumulative = 0
    local chances = {0.50, 0.30, 0.15, 0.04, 0.01}
    for i, r in ipairs(LootForgeConfig.RarityOrder) do
        cumulative = cumulative + (chances[i] or 0)
        if roll <= cumulative then
            return r
        end
    end
    return "Common"
end

local function GetRandomItemName()
    local templates = LootForgeConfig.ItemTemplates
    return templates[math.random(1, #templates)]
end

local function CalculateItemValue(rarity, level)
    local mult = LootForgeConfig.RarityMultipliers[rarity] or 1
    return mult * level * 10
end

local function CalculateForgeCost(itemLevel)
    return LootForgeConfig.ForgeCostBase + (itemLevel * LootForgeConfig.ForgeCostPerLevel)
end

local function CalculateForgeSuccess(itemLevel)
    local chance = LootForgeConfig.ForgeSuccessBase - (itemLevel * LootForgeConfig.ForgeSuccessPenalty)
    return math.clamp(chance, 0.1, 0.95)
end

-- ====================================================================
-- 👤 PLAYER MANAGEMENT
-- ====================================================================
local PlayerData = {}
local LootParts = {}

Players.PlayerAdded:Connect(function(player)
    PlayerData[player.UserId] = LoadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    local data = PlayerData[player.UserId]
    if data then
        SavePlayerData(player, data)
        PlayerData[player.UserId] = nil
    end
end)

-- ====================================================================
-- 📦 LOOT SPAWN SYSTEM
-- ====================================================================
local function SpawnLootDrop(position, rarity, itemName, level, value)
    local part = Instance.new("Part")
    part.Name = "LTF_Loot_" .. itemName .. "_" .. rarity
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(4, 4, 4) -- Larger for mobile touch targets
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = LootForgeConfig.RarityColors[rarity] or Color3.fromRGB(200, 200, 200)
    part.Parent = workspace

    -- BillboardGui — large readable text for mobile
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 300, 0, 80) -- Bigger for mobile
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = itemName .. " [+" .. level .. "] " .. rarity
    label.TextColor3 = LootForgeConfig.RarityColors[rarity] or Color3.fromRGB(200, 200, 200)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18 -- Minimum readable size for mobile
    label.Parent = billboard

    -- Value badge
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0.3, 0)
    valueLabel.Position = UDim2.new(0, 0, 0.7, 0)
    valueLabel.BackgroundTransparency = 0.5
    valueLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    valueLabel.Text = "💰 " .. FormatNumber(value) .. " Coins"
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = billboard

    -- Attributes
    local valueAttr = Instance.new("IntValue")
    valueAttr.Name = "LTFValue"
    valueAttr.Value = value
    valueAttr.Parent = part

    local rarityAttr = Instance.new("StringValue")
    rarityAttr.Name = "LTF_rarity"
    rarityAttr.Value = rarity
    rarityAttr.Parent = part

    local levelAttr = Instance.new("IntValue")
    levelAttr.Name = "LTF_level"
    levelAttr.Value = level
    levelAttr.Parent = part

    local nameAttr = Instance.new("StringValue")
    nameAttr.Name = "LTF_name"
    nameAttr.Value = itemName
    nameAttr.Parent = part

    local ownerAttr = Instance.new("StringValue")
    ownerAttr.Name = "LTF_owner"
    ownerAttr.Value = ""
    ownerAttr.Parent = part

    table.insert(LootParts, part)

    -- Auto-despawn
    task.delay(LootForgeConfig.LootDespawnTime, function()
        if part.Parent then
            part:Destroy()
        end
        for i, p in ipairs(LootParts) do
            if p == part then
                table.remove(LootParts, i)
                break
            end
        end
    end)

    return part
end

local function AutoLootSpawner()
    while true do
        task.wait(LootForgeConfig.LootSpawnInterval)

        local center = workspace:FindFirstChild("LootSpawnCenter")
        if not center then
            -- Fallback: spawn near workspace center
            center = workspace:FindFirstChild("SpawnLocation")
        end
        if not center then
            center = workspace.PrimaryPart or workspace:FindFirstChild("Map") or workspace
        end

        local spawnPos = center:IsA("BasePart") and center.Position or center:GetPivot().Position

        for i = 1, LootForgeConfig.MaxLootPerSpawn do
            local angle = (i / LootForgeConfig.MaxLootPerSpawn) * math.pi * 2
            local radius = math.random(10, LootForgeConfig.LootSpawnRadius)
            local pos = spawnPos + Vector3.new(
                math.cos(angle) * radius,
                0,
                math.sin(angle) * radius
            )

            local rarity = GetRandomRarity()
            local itemName = GetRandomItemName()
            local level = math.random(1, 5)
            local value = CalculateItemValue(rarity, level)

            SpawnLootDrop(pos, rarity, itemName, level, value)
        end
    end
end

-- ====================================================================
-- 🔨 FORGE +1 SYSTEM
-- ====================================================================
local function HandleForgeRequest(player, request)
    local userId = player.UserId
    local data = PlayerData[userId]
    if not data then return {success = false, message = "Player data not found"} end

    local targetType = request.TargetType or "Weapon"
    local targetUUID = request.TargetUUID
    local currentLevel = request.CurrentLevel or 1

    -- Check if player has the target item
    local backpackData = nil
    pcall(function()
        backpackData = require(ReplicatedStorage:WaitForChild("LocalData"):WaitForChild("BackpackData"))
    end)

    if not backpackData then
        return {success = false, message = "Backpack system not available"}
    end

    local bagData = backpackData.GetData()
    if not bagData or not bagData.have then
        return {success = false, message = "Bag kosong"}
    end

    local targetItem = bagData.have[targetUUID]
    if not targetItem then
        return {success = false, message = "Item tidak ditemukan di bag"}
    end

    -- Calculate cost
    local cost = CalculateForgeCost(currentLevel)
    local coins = 0
    pcall(function()
        local eco = player:FindFirstChild("Eco")
        if eco then
            local coinVal = eco:FindFirstChild("coin")
            if coinVal then coins = coinVal.Value end
        end
    end)

    if coins < cost then
        return {success = false, message = "Coin tidak cukup. Butuh " .. FormatNumber(cost) .. " coin"}
    end

    -- Deduct coins
    pcall(function()
        local eco = player:FindFirstChild("Eco")
        if eco then
            local coinVal = eco:FindFirstChild("coin")
            if coinVal then coinVal.Value = math.max(0, coins - cost) end
        end
    end)

    -- Roll for success
    local success = math.random() <= CalculateForgeSuccess(currentLevel)

    if success then
        -- Forge success — return upgraded item
        local newItem = {
            ID = targetItem.ID or targetItem.name or "Unknown",
            Name = targetItem.Name or targetItem.id or "Unknown",
            Type = targetType,
            Rarity = targetItem.Rarity or targetItem.rarity or "Common",
            DesignPower = (targetItem.DesignPower or targetItem.power or 0) + (currentLevel * 10),
            Level = currentLevel + 1,
            Price = (targetItem.Price or targetItem.price or 0) + cost,
        }

        data.TotalForges = (data.TotalForges or 0) + 1
        data.TotalCoinsEarned = (data.TotalCoinsEarned or 0) + cost

        -- Track best level
        if targetType == "Weapon" and newItem.Level > (data.BestWeaponLevel or 0) then
            data.BestWeaponLevel = newItem.Level
        elseif (targetType == "Armor" or targetType == "Hat") and newItem.Level > (data.BestArmorLevel or 0) then
            data.BestArmorLevel = newItem.Level
        end

        -- Record history
        table.insert(data.ForgeHistory, 1, {
            Name = newItem.Name,
            Type = targetType,
            Rarity = newItem.Rarity,
            Power = newItem.DesignPower,
            Time = os.date("%X"),
            Level = newItem.Level,
            Success = true,
        })
        if #data.ForgeHistory > 20 then table.remove(data.ForgeHistory) end

        return {success = true, item = newItem, message = "Forge berhasil! Item naik ke Level " .. newItem.Level}
    else
        -- Forge failed — return broken item
        table.insert(data.ForgeHistory, 1, {
            Name = targetItem.Name or targetItem.id or "Unknown",
            Type = targetType,
            Rarity = targetItem.Rarity or "Common",
            Power = targetItem.DesignPower or 0,
            Time = os.date("%X"),
            Level = currentLevel,
            Success = false,
        })
        if #data.ForgeHistory > 20 then table.remove(data.ForgeHistory) end

        return {success = false, message = "Forge gagal. Item tidak naik level."}
    end
end

-- ====================================================================
-- 🛒 SELL SYSTEM
-- ====================================================================
local function HandleSellItem(player, uuid, count)
    local userId = player.UserId
    local data = PlayerData[userId]
    if not data then return {success = false, message = "Player data not found"} end

    local backpackData = nil
    pcall(function()
        backpackData = require(ReplicatedStorage:WaitForChild("LocalData"):WaitForChild("BackpackData"))
    end)

    if not backpackData then return {success = false, message = "Backpack not available"} end

    local bagData = backpackData.GetData()
    if not bagData or not bagData.have then return {success = false, message = "Bag kosong"} end

    local item = bagData.have[uuid]
    if not item then return {success = false, message = "Item tidak ditemukan"} end

    local rarity = item.Rarity or item.rarity or "Common"
    local sellPrice = (LootForgeConfig.SellPrices[rarity] or 5) * (count or 1)

    -- Remove item from bag
    bagData.have[uuid] = nil
    if bagData.equiped and bagData.equiped.Weapon == uuid then
        bagData.equiped.Weapon = nil
    end
    if bagData.equiped and bagData.equiped.Armor == uuid then
        bagData.equiped.Armor = nil
    end
    if bagData.equiped and bagData.equiped.Hat == uuid then
        bagData.equiped.Hat = nil
    end

    -- Add coins
    pcall(function()
        local eco = player:FindFirstChild("Eco")
        if eco then
            local coinVal = eco:FindFirstChild("coin")
            if coinVal then coinVal.Value = coinVal.Value + sellPrice end
        end
    end)

    data.TotalSells = (data.TotalSells or 0) + (count or 1)
    data.TotalCoinsEarned = (data.TotalCoinsEarned or 0) + sellPrice

    return {success = true, earned = sellPrice, message = "Terjual +" .. FormatNumber(sellPrice) .. " coin"}
end

-- ====================================================================
-- 🔍 LOOT COLLECTION (Server validates)
-- ====================================================================
local function HandleCollectLoot(player, lootPart)
    if not lootPart or not lootPart.Parent then
        return {success = false, message = "Loot tidak ditemukan"}
    end

    local rarity = lootPart:FindFirstChild("LTF_rarity") and lootPart.LTF_rarity.Value or "Common"
    local level = lootPart:FindFirstChild("LTF_level") and lootPart.LTF_level.Value or 1
    local value = lootPart:FindFirstChild("LTFValue") and lootPart.LTFValue.Value or 0
    local itemName = lootPart:FindFirstChild("LTF_name") and lootPart.LTF_name.Value or "Unknown"

    -- Check if already collected (owner set)
    local ownerAttr = lootPart:FindFirstChild("LTF_owner")
    if ownerAttr and ownerAttr.Value ~= "" and ownerAttr.Value ~= tostring(player.UserId) then
        return {success = false, message = "Loot milik pemain lain"}
    end

    -- Claim loot
    if ownerAttr then ownerAttr.Value = tostring(player.UserId) end

    -- Add to backpack
    local backpackData = nil
    pcall(function()
        backpackData = require(ReplicatedStorage:WaitForChild("LocalData"):WaitForChild("BackpackData"))
    end)

    if backpackData and backpackData.AddItem then
        pcall(function()
            backpackData.AddItem({
                ID = itemName,
                Name = itemName,
                Type = "Loot",
                Rarity = rarity,
                Level = level,
                Value = value,
            })
        end)
    end

    -- Give coins
    pcall(function()
        local eco = player:FindFirstChild("Eco")
        if eco then
            local coinVal = eco:FindFirstChild("coin")
            if coinVal then coinVal.Value = coinVal.Value + value end
        end
    end)

    local data = PlayerData[player.UserId]
    if data then
        data.TotalLootCollected = (data.TotalLootCollected or 0) + 1
    end

    -- Destroy loot part
    lootPart:Destroy()
    for i, p in ipairs(LootParts) do
        if p == lootPart then
            table.remove(LootParts, i)
            break
        end
    end

    return {success = true, itemName = itemName, rarity = rarity, level = level, value = value, message = "Mengumpulkan " .. itemName .. " [+" .. level .. "] " .. rarity}
end

-- ====================================================================
-- 📊 LEADERBOARD
-- ====================================================================
local function GetLeaderboard()
    local board = {}
    for userId, data in pairs(PlayerData) do
        table.insert(board, {
            UserId = userId,
            Name = Players:GetPlayerByUserId(userId) and Players:GetPlayerByUserId(userId).Name or "Unknown",
            TotalLoot = data.TotalLootCollected or 0,
            TotalForges = data.TotalForges or 0,
            TotalSells = data.TotalSells or 0,
            TotalCoins = data.TotalCoinsEarned or 0,
            BestWeapon = data.BestWeaponLevel or 0,
            BestArmor = data.BestArmorLevel or 0,
        })
    end

    -- Sort by total loot collected
    table.sort(board, function(a, b) return a.TotalLoot > b.TotalLoot end)

    -- Return top 20
    local result = {}
    for i = 1, math.min(20, #board) do
        table.insert(result, board[i])
    end

    return result
end

-- ====================================================================
-- 🔗 REMOTE EVENT HANDLERS
-- ====================================================================
-- Create a RemoteEvent for client-server communication if not exists
local LootForgeRemotes = ReplicatedStorage:FindFirstChild("LootForgeRemotes")
if not LootForgeRemotes then
    LootForgeRemotes = Instance.new("Folder")
    LootForgeRemotes.Name = "LootForgeRemotes"
    LootForgeRemotes.Parent = ReplicatedStorage
end

-- Create remotes for loot forge system
local function CreateRemote(name, classType)
    local existing = LootForgeRemotes:FindFirstChild(name)
    if not existing then
        local r = Instance.new(classType)
        r.Name = name
        r.Parent = LootForgeRemotes
    end
    return LootForgeRemotes:FindFirstChild(name)
end

local LootCollectRE = CreateRemote("LootCollectRE", "RemoteEvent")
local ForgeRequestRE = CreateRemote("ForgeRequestRE", "RemoteEvent")
local SellItemRE = CreateRemote("SellItemRE", "RemoteEvent")
local RequestLeaderboardRE = CreateRemote("RequestLeaderboardRE", "RemoteEvent")
local LootSpawnREQ = CreateRemote("LootSpawnREQ", "RemoteEvent")
local LeaderboardUpdateRE = CreateRemote("LeaderboardUpdateRE", "RemoteEvent")

-- Client → Server: Collect loot
LootCollectRE.OnServerEvent:Connect(function(player, lootPart)
    if not lootPart or not lootPart.Parent then return end
    local result = HandleCollectLoot(player, lootPart)
    -- Send result back to client
    pcall(function()
        -- Use existing leaderboard update remote or a custom one
    end)
end)

-- Client → Server: Forge request
ForgeRequestRE.OnServerEvent:Connect(function(player, request)
    local result = HandleForgeRequest(player, request)
    -- Notify client
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            -- Fire a remote to client for notification
        end
    end)
end)

-- Client → Server: Sell item
SellItemRE.OnServerEvent:Connect(function(player, uuid, count)
    local result = HandleSellItem(player, uuid, count)
end)

-- Client → Server: Request leaderboard
RequestLeaderboardRE.OnServerEvent:Connect(function(player)
    local board = GetLeaderboard()
    pcall(function()
        LeaderboardUpdateRE:FireClient(player, board)
    end)
end)

-- ====================================================================
-- 🔄 AUTO SPAWN LOOT (background loop)
-- ====================================================================
task.spawn(AutoLootSpawner)

-- ====================================================================
-- 🧹 CLEANUP ON SHUTDOWN
-- ====================================================================
game:BindToClose(function()
    for userId, data in pairs(PlayerData) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            SavePlayerData(player, data)
        end
    end
end)
