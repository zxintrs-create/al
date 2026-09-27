local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = false,
    AttackCooldown = 0.1,
    DetectionRadius = 60,
    PlayerDistanceThreshold = 50
}

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Enemy = Assets:WaitForChild("Enemy")

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local Remotes = {
    MainFunction = RemotesFolder:WaitForChild("MainFunction"),
    CombatEvent = RemotesFolder:WaitForChild("CombatEvent"),
    MainEvent = RemotesFolder:WaitForChild("MainEvent")
}

local Map = Workspace:WaitForChild("Map", 10)
if not Map then return end

local Stages = Map:WaitForChild("Stages", 10)
if not Stages then return end

local Functions = {}
local ActiveThread
local StageThread

local StageList = {}
local StageNumbers = {}
local CurrentStageIndex = 1

local TrackedNPCs = {}
local StageCompleted = {}

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

if not scanStages() then
    return
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InstantKillUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local GuiSuccess = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not GuiSuccess then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,220,0,155)
MainFrame.Position = UDim2.new(0.5,-110,0.4,-77)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0,8)
FrameCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,0,0,35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(45,45,45)
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.Text = "INSTANT KILL NPC"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0,8)
TitleCorner.Parent = TitleLabel

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0,160,0,42)
ToggleButton.Position = UDim2.new(0.5,-80,0,48)
ToggleButton.BackgroundColor3 = Color3.fromRGB(180,40,40)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0,6)
ButtonCorner.Parent = ToggleButton

local StageLabel = Instance.new("TextLabel")
StageLabel.Size = UDim2.new(1,-20,0,25)
StageLabel.Position = UDim2.new(0,10,0,98)
StageLabel.BackgroundTransparency = 1
StageLabel.TextColor3 = Color3.fromRGB(220,220,220)
StageLabel.Font = Enum.Font.SourceSansBold
StageLabel.TextSize = 14
StageLabel.Parent = MainFrame

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0,120,0,40)
OpenButton.Position = UDim2.new(0.02,0,0.85,0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
OpenButton.TextColor3 = Color3.fromRGB(255,255,255)
OpenButton.Text = "Open Kill UI"
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.TextSize = 14
OpenButton.BorderSizePixel = 0
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0,6)
OpenCorner.Parent = OpenButton

local function updateStageUI()
    local Number = getCurrentStageNumber()

    if Number then
        StageLabel.Text = "Stage: "..tostring(Number).."  ["..CurrentStageIndex.."/"..#StageNumbers.."]"
    else
        StageLabel.Text = "Stage: -"
    end
end

local function attackNPC(Data)
    if not Data or not Data.Model then
        return
    end

    if TrackedNPCs[Data.Model] then
        return
    end

    TrackedNPCs[Data.Model] = true

    pcall(function()
        Remotes.CombatEvent:FireServer(Data.Model)
    end)

    pcall(function()
        if Data.Humanoid and Data.Humanoid.Health > 0 then
            Data.Humanoid.Health = 0
        end
    end)
end

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
        CurrentStageIndex += 1
        TrackedNPCs = {}
        updateStageUI()
    end
end

function Functions.Start()
    if Config.Enabled then
        return
    end

    Config.Enabled = true

    ToggleButton.Text = "STATUS: ON"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40,180,40)

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

    ToggleButton.Text = "STATUS: OFF"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(180,40,40)

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

ToggleButton.MouseButton1Click:Connect(Functions.Toggle)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    OpenButton.Text = MainFrame.Visible and "Close Kill UI" or "Open Kill UI"
end)

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

updateStageUI()
Functions.Start()

Notify("Load script , 👑 VOID VAINLY STAR")
print("⚜️VOID VAINLY STAR")
