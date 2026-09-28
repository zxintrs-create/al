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
    ScanInterval = 0.5,           -- Update NPC cache setiap 0.5s (bukan setiap frame = no lag)
    DetectionRadius = 60,
    PlayerDistanceThreshold = 50,
    KillRadius = 30,
    MaxTargets = 10,
    Damage = 467000000000000000,  -- 467 Sp
    DamageLabel = "467 Sp"
}

-- ═══════════════════════════════════════
-- CACHE NPC (update periodik, bukan every frame)
-- ═══════════════════════════════════════
local CachedNPCs = {}
local NPCCacheTimer = 0

function updateNPCCache()
    local newCache = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 then
                if not Players:GetPlayerFromCharacter(obj) then
                    newCache[obj] = {
                        Model = obj,
                        Humanoid = humanoid,
                        Root = root
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
        if (npc.Root.Position - position).Magnitude <= radius then
            result[#result + 1] = npc
        end
    end
    return result
end

-- ═══════════════════════════════════════
-- REMOTE SETUP
-- MainFunction = RemoteFunction (InvokeServer)
-- CombatEvent = RemoteEvent (FireServer)
-- ═══════════════════════════════════════
local Remotes = {}

function initRemotes()
    local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    Remotes.CombatEvent = RemotesFolder:WaitForChild("CombatEvent")
    Remotes.MainEvent = RemotesFolder:WaitForChild("MainEvent")
    pcall(function()
        Remotes.MainFunction = RemotesFolder:WaitForChild("MainFunction")
    end)
end

-- ═══════════════════════════════════════
-- KILL FUNCTION (instant kill + replication)
-- ═══════════════════════════════════════
local function killNPC(npcData)
    if not npcData or not npcData.Model or not npcData.Model.Parent then return end

    local humanoid = npcData.Humanoid
    local model = npcData.Model

    -- INSTANT KILL LOKAL: set Health = 0 langsung
    humanoid.Health = 0

    -- REPLICATION KE SERVER via CombatEvent (RemoteEvent)
    pcall(function()
        Remotes.CombatEvent:FireServer(model, Config.Damage)
    end)

    -- Try kill command juga
    pcall(function()
        Remotes.CombatEvent:FireServer(model, "Kill")
    end)
end

local function killAOE(position, radius, maxTargets)
    local npcs = getNPCsInRadius(position, radius)
    local killed = 0
    for _, npc in ipairs(npcs) do
        if killed >= (maxTargets or Config.MaxTargets) then break end
        killNPC(npc)
        killed = killed + 1
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

    -- Cek WinArea: jika player masuk WinArea, stage selesai
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
-- MEMORY OVERWRITE
-- ═══════════════════════════════════════
local function setupMemoryOverwrite()
    pcall(function()
        local meta = getrawmetatable(game)
        if not meta then return end
        local oldNewIndex = meta.__newindex
        meta.__newindex = newcclosure(function(self, key, value)
            if key == "Health" and typeof(value) == "number" and value == 0 then
                oldNewIndex(self, key, value)
                pcall(function()
                    Remotes.MainEvent:FireServer("NPCDied", self.Parent)
                end)
            else
                oldNewIndex(self, key, value)
            end
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
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 38)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "⚜️ VOID VAINLY STAR ⚜️"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 10)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 44)
ToggleButton.Position = UDim2.new(0.5, -90, 0, 48)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 17
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, -20, 0, 28)
StageLabel.Position = UDim2.new(0, 10, 0, 100)
StageLabel.BackgroundTransparency = 1
StageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StageLabel.Font = Enum.Font.GothamBold
StageLabel.TextSize = 13
StageLabel.Text = "Stage: -"
StageLabel.Parent = MainFrame

local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(1, -20, 0, 50)
ConfigLabel.Position = UDim2.new(0, 10, 0, 130)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ConfigLabel.Font = Enum.Font.Gotham
ConfigLabel.TextSize = 11
ConfigLabel.TextWrapped = true
ConfigLabel.Parent = MainFrame

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 130, 0, 36)
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
            -- Update NPC cache setiap ScanInterval detik
            NPCCacheTimer = NPCCacheTimer + RunService.Heartbeat:Wait().DeltaTime
            if NPCCacheTimer >= Config.ScanInterval then
                updateNPCCache()
                NPCCacheTimer = 0
            end

            -- Process current stage
            local stage = getCurrentStage()
            if stage then
                local spawn = stage:FindFirstChild("Spawn")
                if spawn and isPlayerNearSpawn(spawn) then
                    -- AoE kill semua NPC dalam radius detection
                    killAOE(spawn.Position, Config.DetectionRadius, Config.MaxTargets)

                    -- Cek stage complete
                    if isStageComplete(stage) then
                        StageCompleted[stage.Name] = true
                        advanceStage()
                        updateStageUI()
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

print(string.format("⚜️ VOID VAINLY STAR)",
    Config.DamageLabel, #StageNumbers))
