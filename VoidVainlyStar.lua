local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- KONFIGURASI
-- ═══════════════════════════════════════
local Config = {
    Enabled = false,
    ScanInterval = 10.0,        -- Update NPC cache setiap 10s (ZERO LAG)
    DetectionRadius = 200,      -- Radius deteksi NPC (besar untuk semua enemy)
    PlayerDistanceThreshold = 100,
    KillRadius = 100,           -- Radius AoE kill
    MaxTargets = 200,           -- Max NPC yang di-kill per cycle (semua enemy)
    Damage = 1e30,              -- 100 Undecillion (bypass boss 2.2T)
    DamageLabel = "1000000000T"
}

-- ═══════════════════════════════════════
-- ENEMY FOLDER CACHE
-- Semua NPC di Workspace > Enemy folder
-- ═══════════════════════════════════════
local CachedNPCs = {}
local EnemyFolder = nil

function initEnemyFolder()
    -- Cari folder Enemy di Workspace (dari screenshot Explorer)
    EnemyFolder = Workspace:FindFirstChild("Enemy")
    if not EnemyFolder then
        -- Coba di Map
        local Map = Workspace:FindFirstChild("Map")
        if Map then
            EnemyFolder = Map:FindFirstChild("Enemy")
        end
    end
    if not EnemyFolder then
        -- Coba di dalam Stages
        local Map = Workspace:FindFirstChild("Map")
        if Map then
            local Stages = Map:FindFirstChild("Stages")
            if Stages then
                for _, stage in ipairs(Stages:GetChildren()) do
                    local enemy = stage:FindFirstChild("Enemy")
                    if enemy then
                        EnemyFolder = enemy
                        break
                    end
                end
            end
        end
    end

    if EnemyFolder then
        print(string.format("[VOID VAINLY STAR] Enemy folder ditemukan: %s", EnemyFolder:GetFullName()))
    else
        warn("[VOID VAINLY STAR] Folder 'Enemy' tidak ditemukan! Mencari semua model dengan Humanoid...")
    end
end

function updateNPCCache()
    local newCache = {}

    -- METHOD 1: Scan Enemy folder jika ada
    if EnemyFolder then
        for _, obj in ipairs(EnemyFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart")
                if humanoid and root and humanoid.Health > 0 then
                    if not Players:GetPlayerFromCharacter(obj) then
                        newCache[obj] = {
                            Model = obj,
                            Humanoid = humanoid,
                            Root = root,
                            Position = root.Position,
                            Health = humanoid.Health
                        }
                    end
                end
            end
        end
    end

    -- METHOD 2: Scan semua model di Workspace yang punya Humanoid (fallback)
    if next(newCache) == nil then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart")
                if humanoid and root and humanoid.Health > 0 then
                    if not Players:GetPlayerFromCharacter(obj) then
                        newCache[obj] = {
                            Model = obj,
                            Humanoid = humanoid,
                            Root = root,
                            Position = root.Position,
                            Health = humanoid.Health
                        }
                    end
                end
            end
        end
    end

    CachedNPCs = newCache
end

function getNPCsInRadius(position, radius)
    local result = {}
    if not position then return result end
    for _, npc in pairs(CachedNPCs) do
        if (npc.Position - position).Magnitude <= radius then
            result[#result + 1] = npc
        end
    end
    return result
end

-- ═══════════════════════════════════════
-- REMOTE SETUP
-- ═══════════════════════════════════════
local Remotes = {}

function initRemotes()
    -- Remotes ada di Workspace > Remotes (dari screenshot Explorer)
    local RemotesFolder = Workspace:FindFirstChild("Remotes")
    if not RemotesFolder then
        RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    end
    if not RemotesFolder then
        warn("[VOID VAINLY STAR] Folder 'Remotes' tidak ditemukan!")
        return
    end

    Remotes.CombatEvent = RemotesFolder:FindFirstChild("CombatEvent")
    Remotes.MainEvent = RemotesFolder:FindFirstChild("MainEvent")
    Remotes.MainFunction = RemotesFolder:FindFirstChild("MainFunction")

    if Remotes.CombatEvent then
        print("[VOID VAINLY STAR] CombatEvent ditemukan")
    end
    if Remotes.MainEvent then
        print("[VOID VAINLY STAR] MainEvent ditemukan")
    end
    if Remotes.MainFunction then
        print("[VOID VAINLY STAR] MainFunction ditemukan")
    end
end

-- ═══════════════════════════════════════
-- ONE-HIT KILL ALL NPCs di Enemy folder
-- ═══════════════════════════════════════
local function killNPC(npcData)
    if not npcData or not npcData.Model or not npcData.Model.Parent then return false end

    local humanoid = npcData.Humanoid
    local model = npcData.Model

    -- METHOD 1: TakeDamage dengan nilai super besar
    pcall(function()
        humanoid:TakeDamage(Config.Damage)
    end)

    -- METHOD 2: Set Health = 0 langsung (instant kill)
    task.wait(0.01)
    pcall(function()
        humanoid.Health = 0
    end)

    -- METHOD 3: Fire server CombatEvent (replication)
    task.wait(0.01)
    if Remotes.CombatEvent then
        pcall(function()
            Remotes.CombatEvent:FireServer(model, Config.Damage)
        end)
    end

    -- METHOD 4: Fire server kill command
    task.wait(0.01)
    if Remotes.CombatEvent then
        pcall(function()
            Remotes.CombatEvent:FireServer(model, "OneHitKill")
        end)
    end

    -- METHOD 5: Invoke MainFunction (RemoteFunction) untuk server kill
    task.wait(0.01)
    if Remotes.MainFunction then
        pcall(function()
            local success, result = Remotes.MainFunction:InvokeServer(model, "Kill", Config.Damage)
        end)
    end

    -- METHOD 6: Fire MainEvent untuk replicate death
    task.wait(0.01)
    if Remotes.MainEvent then
        pcall(function()
            Remotes.MainEvent:FireServer("OneHitKill", model, Config.Damage)
        end)
    end

    return true
end

-- KILL ALL NPCs DI FOLDER ENEMY (bukan yang dekat player saja)
local function killAllEnemyNPCs()
    local killed = 0
    for _, npc in pairs(CachedNPCs) do
        if killNPC(npc) then
            killed = killed + 1
        end
    end
    return killed
end

local function killAOE(position, radius, maxTargets)
    local npcs = getNPCsInRadius(position, radius)
    local killed = 0
    for _, npc in ipairs(npcs) do
        if killed >= (maxTargets or Config.MaxTargets) then break end
        if killNPC(npc) then
            killed = killed + 1
        end
    end
    return killed
end

-- ═══════════════════════════════════════
-- STAGE MANAGEMENT (stages 1-27)
-- Workspace > Map > Stages > {number} > Spawns > {spawn} > {Build, WinArea, LevelArea, Spawn}
-- ═══════════════════════════════════════
local StageList = {}
local StageNumbers = {}
local CurrentStageIndex = 1
local StageCompleted = {}

function scanStages()
    table.clear(StageList)
    table.clear(StageNumbers)

    local Map = Workspace:FindFirstChild("Map")
    if not Map then return end

    local Stages = Map:FindFirstChild("Stages")
    if not Stages then return end

    for _, stageFolder in ipairs(Stages:GetChildren()) do
        local stageNumber = tonumber(stageFolder.Name)
        if stageNumber then
            local SpawnsFolder = stageFolder:FindFirstChild("Spawns")
            if SpawnsFolder then
                local bestSpawn = nil
                local bestSpawnNumber = math.huge

                for _, spawnFolder in ipairs(SpawnsFolder:GetChildren()) do
                    local spawnNumber = tonumber(spawnFolder.Name)
                    if spawnNumber and spawnNumber < bestSpawnNumber then
                        bestSpawnNumber = spawnNumber
                        bestSpawn = spawnFolder
                    end
                end

                if bestSpawn then
                    local spawnPart = bestSpawn:FindFirstChild("Spawn") or bestSpawn
                    StageList[stageNumber] = {
                        Folder = stageFolder,
                        StageNumber = stageNumber,
                        SpawnFolder = bestSpawn,
                        SpawnPart = spawnPart
                    }
                    StageNumbers[#StageNumbers + 1] = stageNumber
                end
            end
        end
    end

    table.sort(StageNumbers)

    if #StageNumbers > 0 and CurrentStageIndex > #StageNumbers then
        CurrentStageIndex = #StageNumbers
    end
end

function getCurrentStage()
    local num = StageNumbers[CurrentStageIndex]
    return StageList[num] and StageList[num].Folder
end

function getCurrentStageNumber()
    return StageNumbers[CurrentStageIndex]
end

function isPlayerNearSpawn(stageData)
    if not stageData or not stageData.SpawnPart then return false end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - stageData.SpawnPart.Position).Magnitude <= Config.PlayerDistanceThreshold
end

function isStageComplete(stageFolder)
    if not stageFolder then return false end

    local winArea = stageFolder:FindFirstChild("WinArea")
    if winArea then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - winArea.Position).Magnitude < 15 then
            return true
        end
    end

    local levelArea = stageFolder:FindFirstChild("LevelArea")
    if levelArea then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - levelArea.Position).Magnitude < 15 then
            return true
        end
    end

    return false
end

function advanceStage()
    if CurrentStageIndex < #StageNumbers then
        CurrentStageIndex = CurrentStageIndex + 1
        print(string.format("[VOID VAINLY STAR] Stage %d -> %d", StageNumbers[CurrentStageIndex - 1], getCurrentStageNumber()))
    end
end

-- ═══════════════════════════════════════
-- PANDUAN NPC (auto-kill saat NPC utama mati)
-- ═══════════════════════════════════════
local PANDUAN_NPC = Workspace:FindFirstChild("NamaNPCUtama")

local function setupPanduanNPC()
    if not PANDUAN_NPC then return end

    local HumUtama = PANDUAN_NPC:FindFirstChildOfClass("Humanoid")
    if not HumUtama then return end

    HumUtama.Died:Connect(function()
        local PosUtama = PANDUAN_NPC.PrimaryPart and PANDUAN_NPC.PrimaryPart.Position
        if not PosUtama then return end

        local npcs = getNPCsInRadius(PosUtama, Config.KillRadius)
        for _, npc in ipairs(npcs) do
            killNPC(npc)
        end
    end)
end

-- ═══════════════════════════════════════
-- MEMORY OVERWRITE
-- ═══════════════════════════════════════
local function setupMemoryOverwrite()
    pcall(function()
        local meta = getrawmetatable(game)
        if not meta then return end
        local oldNewIndex = meta.__newindex
        meta.__newindex = newcclosure(function(self, key, value)
            if key == "Health" and typeof(value) == "number" then
                if value == 0 then
                    pcall(function()
                        if Remotes.MainEvent then
                            Remotes.MainEvent:FireServer("NPCDied", self.Parent)
                        end
                    end)
                end
            end
            oldNewIndex(self, key, value)
        end)
    end)
end

-- ═══════════════════════════════════════
-- UI
-- ═══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStarUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 250)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "⚜️ VOID VAINLY STAR ⚜️"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 10)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 260, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -130, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, -20, 0, 35)
StageLabel.Position = UDim2.new(0, 10, 0, 120)
StageLabel.BackgroundTransparency = 1
StageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StageLabel.Font = Enum.Font.GothamBold
StageLabel.TextSize = 16
StageLabel.Text = "Stage: -"
StageLabel.Parent = MainFrame

local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(1, -20, 0, 100)
ConfigLabel.Position = UDim2.new(0, 10, 0, 165)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ConfigLabel.Font = Enum.Font.Gotham
ConfigLabel.TextSize = 12
ConfigLabel.TextWrapped = true
ConfigLabel.Parent = MainFrame

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 170, 0, 44)
OpenButton.Position = UDim2.new(0.02, 0, 0.88, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "Open UI"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.BorderSizePixel = 0
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 6)

-- ═══════════════════════════════════════
-- UI ACTIONS
-- ═══════════════════════════════════════
local function updateStageUI()
    local num = getCurrentStageNumber()
    if num then
        StageLabel.Text = string.format("Stage: %d  [%d/%d]", num, CurrentStageIndex, #StageNumbers)
    else
        StageLabel.Text = "Stage: -"
    end
    ConfigLabel.Text = string.format("Enemy Folder: %s\nRad: %d | Dmg: %s\nScan: %ds | Stages: %d\nDamage: %.0e",
        EnemyFolder and EnemyFolder.Name or "Not Found",
        Config.KillRadius, Config.DamageLabel,
        Config.ScanInterval, #StageNumbers, Config.Damage)
end

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ToggleButton.Text = "STATUS: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
        Functions.Start()
    else
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        Functions.Stop()
    end
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    OpenButton.Text = MainFrame.Visible and "Close UI" or "Open UI"
end)

-- ═══════════════════════════════════════
-- FUNCTIONS
-- ═══════════════════════════════════════
local Functions = {}

function Functions.Start()
    if Config.Enabled then return end
    Config.Enabled = true
    updateNPCCache()

    ActiveThread = task.spawn(function()
        while Config.Enabled do
            -- Update NPC cache setiap 10 detik (ZERO LAG)
            task.wait(Config.ScanInterval)
            updateNPCCache()

            -- Process current stage
            local stageData = StageList[getCurrentStageNumber()]
            if stageData then
                if isPlayerNearSpawn(stageData) then
                    -- ONE-HIT ALL NPCs di Enemy folder (bukan AoE radius)
                    local killed = killAllEnemyNPCs()
                    if killed > 0 then
                        print(string.format("[VOID VAINLY STAR] One-hit ALL %d NPCs at Stage %d (Damage: %s = %.0e)",
                            killed, getCurrentStageNumber(), Config.DamageLabel, Config.Damage))
                    end

                    -- Cek stage complete
                    if isStageComplete(stageData.Folder) then
                        StageCompleted[stageData.Folder.Name] = true
                        advanceStage()
                        updateStageUI()
                        print(string.format("[VOID VAINLY STAR] Stage %d completed!", getCurrentStageNumber()))
                    end
                end
            end
        end
    end)
end

function Functions.Stop()
    if not Config.Enabled then return end
    Config.Enabled = false
    CachedNPCs = {}
    if ActiveThread then
        task.cancel(ActiveThread)
        ActiveThread = nil
    end
end

-- ═══════════════════════════════════════
-- EVENT HANDLERS
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    CachedNPCs = {}
end)

Workspace.Stages.ChildAdded:Connect(function()
    task.wait(0.1)
    scanStages()
    updateStageUI()
end)

Workspace.Stages.ChildRemoved:Connect(function()
    task.wait(0.1)
    scanStages()
    updateStageUI()
end)

-- ═══════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════
initRemotes()
initEnemyFolder()
scanStages()
updateStageUI()
setupPanduanNPC()
setupMemoryOverwrite()
Functions.Start()

print(string.format("⚜️ VOID VAINLY STAR)",
    Config.DamageLabel, Config.Damage, #StageNumbers, Config.ScanInterval,
    EnemyFolder and EnemyFolder.Name or "Not Found"))
