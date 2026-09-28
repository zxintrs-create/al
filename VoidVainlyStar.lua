-- VOID VAINLY STAR — Auto-kill NPC di sekitar pemain, damage + AoE + Replication

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = false,
    AttackCooldown = 0.1,
    DetectionRadius = 60,
    PlayerDistanceThreshold = 50,
    KillRadius = 30,
    MaxTargets = 5,
    Damage = 46798765476,
    DamageLabel = "467"
}

-- ASSET & REMOTE
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Enemy = Assets:WaitForChild("Enemy")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local Remotes = {
    MainFunction = RemotesFolder:WaitForChild("MainFunction"),
    CombatEvent = RemotesFolder:WaitForChild("CombatEvent"),
    MainEvent = RemotesFolder:WaitForChild("MainEvent")
}

-- REFERENCE (non-blocking)
local Map = Workspace:FindFirstChild("Map")
local Stages = Map and Map:FindFirstChild("Stages")
local PANDUAN_NPC = Workspace:FindFirstChild("NamaNPCUtama")

if not Map or not Stages then
    warn("VOID VAINLY STAR: Map atau Stages tidak ditemukan. Script berhenti.")
    return
end

-- STATE
local StageList = {}
local StageNumbers = {}
local CurrentStageIndex = 1
local TrackedNPCs = {}
local StageCompleted = {}
local ActiveThread = nil
local StageThread = nil

local function scanStages()
    table.clear(StageList)
    table.clear(StageNumbers)

    for _, Stage in ipairs(Stages:GetChildren()) do
        local Number = tonumber(Stage.Name)
        if Number then
            local Spawn = Stage:FindFirstChild("Spawn")
            if Spawn and Spawn:IsA("BasePart") then
                StageList[Number] = {
                    Folder = Stage,
                    Spawn = Spawn
                }
                StageNumbers[#StageNumbers + 1] = Number
            end
        end
    end

    table.sort(StageNumbers)

    if #StageNumbers == 0 then
        return false
    end

    if CurrentStageIndex > #StageNumbers then
        CurrentStageIndex = #StageNumbers
    end

    return true
end

local function getCurrentStageNumber()
    return StageNumbers[CurrentStageIndex]
end

local function getCurrentStage()
    return StageList[getCurrentStageNumber()]
end

local function getNextStageNumber()
    return StageNumbers[CurrentStageIndex + 1]
end

local function getCharacterRoot()
    local Character = LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function isPlayerNearSpawn(Spawn)
    local Root = getCharacterRoot()
    if not Root or not Spawn then
        return false
    end
    return (Root.Position - Spawn.Position).Magnitude <= Config.PlayerDistanceThreshold
end

local function isPlayerCharacter(Model)
    return Players:GetPlayerFromCharacter(Model) ~= nil
end

local function getNPC(Model)
    if not Model:IsA("Model") then
        return nil, nil
    end
    if isPlayerCharacter(Model) then
        return nil, nil
    end

    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local Root = Model:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return nil, nil
    end
    if Humanoid.Health <= 0 then
        return nil, nil
    end

    return Humanoid, Root
end

-- scanNPCs menggunakan GetDescendants agar model bersarang (HeldWeapon, Handle, dll) ikut terdeteksi
local function scanNPCs(Spawn)
    local NPCs = {}
    if not Spawn then
        return NPCs
    end

    for _, Object in ipairs(Workspace:GetDescendants()) do
        local Humanoid, Root = getNPC(Object)
        if Humanoid and Root then
            local Distance = (Root.Position - Spawn.Position).Magnitude
            if Distance <= Config.DetectionRadius then
                NPCs[#NPCs + 1] = {
                    Model = Object,
                    Humanoid = Humanoid,
                    Root = Root
                }
            end
        end
    end

    return NPCs
end

-- scan semua NPC dalam radius tertentu dari posisi tertentu (untuk AoE)
local function scanNPCsAtPosition(Position, Radius)
    local NPCs = {}
    if not Position then
        return NPCs
    end

    for _, Object in ipairs(Workspace:GetDescendants()) do
        local Humanoid, Root = getNPC(Object)
        if Humanoid and Root then
            local Distance = (Root.Position - Position).Magnitude
            if Distance <= Radius then
                NPCs[#NPCs + 1] = {
                    Model = Object,
                    Humanoid = Humanoid,
                    Root = Root
                }
            end
        end
    end

    return NPCs
end

-- REPLICATION / DESYNC FIX
-- Kirim kill request ke server agar damage 467 Sp direplikasi ke semua client
local function killNPCOnServer(NPCModel, Damage)
    if not NPCModel or not NPCModel.Parent then
        return
    end

    -- Gunakan RemoteEvent jika tersedia di server
    pcall(function()
        Remotes.CombatEvent:FireServer(NPCModel, Damage or Config.Damage)
    end)

    -- Juga coba panggil MainFunction sebagai backup path
    pcall(function()
        Remotes.MainFunction:FireServer(NPCModel, "Kill", Damage or Config.Damage)
    end)
end

local function applyDamageLocally(NPCModel, Damage)
    local Humanoid = NPCModel and NPCModel:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then
        return
    end

    -- Terapkan damage 467 Sp secara lokal
    Humanoid.Health = math.max(0, Humanoid.Health - (Damage or Config.Damage))
end

-- ATTACK LOGIC
local function attackNPC(Data)
    if not Data or not Data.Model or not Data.Model.Parent then
        return
    end

    if TrackedNPCs[Data.Model] then
        return
    end

    TrackedNPCs[Data.Model] = true

    -- Kirim kill 467 Sp ke server (replication) DAN terapkan damage lokal
    killNPCOnServer(Data.Model, Config.Damage)
    applyDamageLocally(Data.Model, Config.Damage)
end

local function attackNPCsInRadius(OriginPosition, Radius, MaxTargets)
    local NPCs = scanNPCsAtPosition(OriginPosition, Radius)
    local killed = 0

    for _, NPC in ipairs(NPCs) do
        if killed >= (MaxTargets or Config.MaxTargets) then
            break
        end
        if not TrackedNPCs[NPC.Model] then
            TrackedNPCs[NPC.Model] = true
            killNPCOnServer(NPC.Model, Config.Damage)
            applyDamageLocally(NPC.Model, Config.Damage)
            killed = killed + 1
        end
    end
end

-- STAGE PROCESSING
local function processCurrentStage()
    local Stage = getCurrentStage()
    if not Stage then
        return
    end

    if not isPlayerNearSpawn(Stage.Spawn) then
        return
    end

    local NPCs = scanNPCs(Stage.Spawn)

    if #NPCs == 0 then
        StageCompleted[getCurrentStageNumber()] = true
        return
    end

    for _, NPC in ipairs(NPCs) do
        if not Config.Enabled then
            break
        end
        attackNPC(NPC)
    end
end

local function processNextStage()
    local CurrentNumber = getCurrentStageNumber()
    if not CurrentNumber then
        return
    end

    if not StageCompleted[CurrentNumber] then
        return
    end

    local NextNumber = getNextStageNumber()
    if not NextNumber then
        return
    end

    local NextStage = StageList[NextNumber]
    if not NextStage then
        return
    end

    if isPlayerNearSpawn(NextStage.Spawn) then
        CurrentStageIndex = CurrentStageIndex + 1
        TrackedNPCs = {}
    end
end

-- PANDUAN NPC: Auto-kill semua NPC dalam radius ketika NPC Utama mati
local function setupPanduanNPC()
    if not PANDUAN_NPC then
        warn("VOID VAINLY STAR: NamaNPCUtama tidak ditemukan di Workspace.")
        return
    end

    local HumUtama = PANDUAN_NPC:FindFirstChildOfClass("Humanoid")
    if not HumUtama then
        warn("VOID VAINLY STAR: NamaNPCUtama tidak memiliki Humanoid.")
        return
    end

    HumUtama.Died:Connect(function()
        local PosUtama = PANDUAN_NPC.PrimaryPart and PANDUAN_NPC.PrimaryPart.Position
        if not PosUtama then
            return
        end

        local terhitung = 0
        for _, model in ipairs(Workspace:GetDescendants()) do
            if terhitung >= Config.MaxTargets then
                break
            end

            local Humanoid, Root = getNPC(model)
            if Humanoid and Root and Root:IsA("BasePart") then
                local Jarak = (PosUtama - Root.Position).Magnitude
                if Jarak <= Config.KillRadius and Humanoid.Health > 0 then
                    TrackedNPCs[model] = true
                    killNPCOnServer(model, Config.Damage)
                    applyDamageLocally(model, Config.Damage)
                    terhitung = terhitung + 1
                end
            end
        end
    end)
end

-- MEMORY OVERWRITE: Patch Humanoid.Health setter agar damage 467 Sp selalu terapply
local function setupMemoryOverwrite()
    pcall(function()
        local HumanoidMeta = getrawmetatable(game)
        if not HumanoidMeta then return end

        local oldNewIndex = HumanoidMeta.__newindex
        HumanoidMeta.__newindex = newcclosure(function(self, key, value)
            if key == "Health" and typeof(value) == "number" and value == 0 then
                -- Intersepsi semua upaya set Health=0 agar damage 467 Sp selalu direplikasi
                local oldHealth = self.Health
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

-- LOCAL INTERCEPTION: Intercept server responses
local function setupLocalInterception()
    pcall(function()
        local oldFireServer = Remotes.CombatEvent.FireServer
        Remotes.CombatEvent.FireServer = newcclosure(function(self, ...)
            local args = {...}
            -- Log setiap kill request 467 Sp untuk debugging
            if args[1] and args[1].IsA and args[1]:IsA("Model") then
                print("[VOID VAINLY STAR] Kill request sent:", args[1].Name, "Damage:", args[2] or Config.DamageLabel)
            end
            return oldFireServer(self, ...)
        end)
    end)
end

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStarUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local GuiSuccess = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not GuiSuccess then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 38)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "⚜️ VOID VAINLY STAR ⚜️"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

-- Status toggle
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

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- Stage info
local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1, -20, 0, 28)
StageLabel.Position = UDim2.new(0, 10, 0, 100)
StageLabel.BackgroundTransparency = 1
StageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StageLabel.Font = Enum.Font.GothamBold
StageLabel.TextSize = 13
StageLabel.Text = "Stage: -"
StageLabel.Parent = MainFrame

-- Config display — menampilkan damage 467 Sp
local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(1, -20, 0, 50)
ConfigLabel.Position = UDim2.new(0, 10, 0, 130)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ConfigLabel.Font = Enum.Font.Gotham
ConfigLabel.TextSize = 11
ConfigLabel.Text = string.format(
    "Rad: %d | Dmg: %s | Max: %d",
    Config.KillRadius, Config.DamageLabel, Config.MaxTargets
)
ConfigLabel.TextWrapped = true
ConfigLabel.Parent = MainFrame

-- Open/close button
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

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 6)
OpenCorner.Parent = OpenButton

-- UI ACTIONS
local function updateStageUI()
    local Number = getCurrentStageNumber()
    if Number then
        StageLabel.Text = string.format(
            "Stage: %d  [%d/%d]",
            Number, CurrentStageIndex, #StageNumbers
        )
    else
        StageLabel.Text = "Stage: -"
    end

    ConfigLabel.Text = string.format(
        "Rad: %d | Dmg: %s | Max: %d",
        Config.KillRadius, Config.DamageLabel, Config.MaxTargets
    )
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

-- FUNCTIONS
local Functions = {}

function Functions.Start()
    if Config.Enabled then
        return
    end

    Config.Enabled = true
    TrackedNPCs = {}

    ActiveThread = task.spawn(function()
        while Config.Enabled do
            processCurrentStage()
            task.wait(Config.AttackCooldown)
        end
    end)

    StageThread = task.spawn(function()
        while Config.Enabled do
            processNextStage()
            task.wait(0.25)
        end
    end)
end

function Functions.Stop()
    if not Config.Enabled then
        return
    end

    Config.Enabled = false
    TrackedNPCs = {}

    if ActiveThread then
        task.cancel(ActiveThread)
        ActiveThread = nil
    end

    if StageThread then
        task.cancel(StageThread)
        StageThread = nil
    end
end

function Functions.Toggle()
    if Config.Enabled then
        Functions.Stop()
    else
        Functions.Start()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    TrackedNPCs = {}
end)

Stages.ChildAdded:Connect(function()
    task.wait(0.1)
    scanStages()
    updateStageUI()
end)

Stages.ChildRemoved:Connect(function()
    task.wait(0.1)
    scanStages()
    updateStageUI()
end)

scanStages()
updateStageUI()
setupPanduanNPC()
setupMemoryOverwrite()
setupLocalInterception()
Functions.Start()

print("⚜️ VOID VAINLY STAR")
