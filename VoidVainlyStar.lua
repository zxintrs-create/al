-- VOID VAINLY STAR v4 — Sword Loot (🔥Forge️ Sword Loot)
-- FINAL FIX: One-hit kill + no lag + full replication

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- KONFIGURASI (minimal = minimal lag)
-- ═══════════════════════════════════════
local Config = {
    Enabled = false,
    ScanInterval = 1.0,         -- Update NPC cache setiap 1s (sangat minim lag)
    DetectionRadius = 80,       -- Radius deteksi NPC
    PlayerDistanceThreshold = 60,
    KillRadius = 40,            -- Radius AoE kill
    MaxTargets = 20,            -- Max NPC yang di-kill per cycle
    Damage = 99999999999999999, -- Damage super besar (99 quadrillion)
    DamageLabel = "999.99T"
}

-- ═══════════════════════════════════════
-- NPC CACHE (update periodik, BUKAN setiap frame)
-- ═══════════════════════════════════════
local CachedNPCs = {}

function updateNPCCache()
    local newCache = {}
    -- Hanya scan model yang punya Humanoid dan HumanoidRootPart
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 then
                -- Skip player character
                if not Players:GetPlayerFromCharacter(obj) then
                    newCache[obj] = {
                        Model = obj,
                        Humanoid = humanoid,
                        Root = root,
                        Position = root.Position
                    }
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
        local dist = (npc.Position - position).Magnitude
        if dist <= radius then
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
    local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
    Remotes.CombatEvent = RemotesFolder:WaitForChild("CombatEvent")
    Remotes.MainEvent = RemotesFolder:WaitForChild("MainEvent")
    pcall(function()
        Remotes.MainFunction = RemotesFolder:WaitForChild("MainFunction")
    end)
end

-- ═══════════════════════════════════════
-- ONE-HIT KILL FUNCTION (FINAL VERSION)
-- ═══════════════════════════════════════
local function killNPC(npcData)
    if not npcData or not npcData.Model or not npcData.Model.Parent then return false end

    local humanoid = npcData.Humanoid
    local model = npcData.Model

    -- METHOD 1: TakeDamage dengan nilai super besar (bypass validation)
    pcall(function()
        humanoid:TakeDamage(Config.Damage)
    end)

    -- METHOD 2: Set Health = 0 langsung
    pcall(function()
        humanoid.Health = 0
    end)

    -- METHOD 3: Fire server remote untuk replication
    pcall(function()
        Remotes.CombatEvent:FireServer(model, Config.Damage)
    end)

    -- METHOD 4: Fire server kill command
    pcall(function()
        Remotes.CombatEvent:FireServer(model, "Kill")
    end)

    return true
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

    for _, stage in ipairs(Stages:GetChildren()) do
        local number = tonumber(stage.Name)
        if number then
            local spawn = stage:FindFirstChild("Spawn")
            if spawn and spawn:IsA("BasePart") then
                StageList[number] = {Folder = stage, Spawn = spawn}
                StageNumbers[#StageNumbers + 1] = number
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

function isPlayerNearSpawn(spawnPart)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not spawnPart then return false end
    return (root.Position - spawnPart.Position).Magnitude <= Config.PlayerDistanceThreshold
end

function isStageComplete(stageFolder)
    if not stageFolder then return false end

    -- Cek WinArea
    local winArea = stageFolder:FindFirstChild("WinArea")
    if winArea then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - winArea.Position).Magnitude < 15 then
            return true
        end
    end

    -- Cek LevelArea
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
-- MEMORY OVERWRITE (prevent Health override)
-- ═══════════════════════════════════════
local function setupMemoryOverwrite()
    pcall(function()
        local meta = getrawmetatable(game)
        if not meta then return end
        local oldNewIndex = meta.__newindex
        meta.__newindex = newcclosure(function(self, key, value)
            if key == "Health" and typeof(value) == "number" then
                -- Jika health diset ke 0, fire event untuk replication
                if value == 0 then
                    pcall(function()
                        Remotes.MainEvent:FireServer("NPCDied", self.Parent)
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
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "⚜️ VOID VAINLY STAR ⚜️"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 10)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 46)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, -20, 0, 30)
StageLabel.Position = UDim2.new(0, 10, 0, 105)
StageLabel.BackgroundTransparency = 1
StageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StageLabel.Font = Enum.Font.GothamBold
StageLabel.TextSize = 14
StageLabel.Text = "Stage: -"
StageLabel.Parent = MainFrame

local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(1, -20, 0, 60)
ConfigLabel.Position = UDim2.new(0, 10, 0, 140)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ConfigLabel.Font = Enum.Font.Gotham
ConfigLabel.TextSize = 11
ConfigLabel.TextWrapped = true
ConfigLabel.Parent = MainFrame

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 140, 0, 38)
OpenButton.Position = UDim2.new(0.02, 0, 0.88, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Text = "Open UI"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 13
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
    ConfigLabel.Text = string.format("Rad: %d | Dmg: %s | Max: %d\nScan: %ds | Stages: %d",
        Config.KillRadius, Config.DamageLabel, Config.MaxTargets,
        Config.ScanInterval, #StageNumbers)
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
            -- Update NPC cache setiap ScanInterval detik (minimal lag)
            task.wait(Config.ScanInterval)
            updateNPCCache()

            -- Process current stage
            local stage = getCurrentStage()
            if stage then
                local spawn = stage:FindFirstChild("Spawn")
                if spawn and isPlayerNearSpawn(spawn) then
                    -- AoE kill semua NPC dalam radius detection
                    local killed = killAOE(spawn.Position, Config.DetectionRadius, Config.MaxTargets)
                    if killed > 0 then
                        print(string.format("[VOID VAINLY STAR] Killed %d NPCs at Stage %d", killed, getCurrentStageNumber()))
                    end

                    -- Cek stage complete
                    if isStageComplete(stage) then
                        StageCompleted[stage.Name] = true
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
scanStages()
updateStageUI()
setupPanduanNPC()
setupMemoryOverwrite()
Functions.Start()

    Config.DamageLabel, #StageNumbers))
