local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Animator = Humanoid and Humanoid:WaitForChild("Animator", 10)

local RECORD_FPS = 30
local RECORD_INTERVAL = 1 / RECORD_FPS
local MAX_RECORD_FRAMES = 9000

local RecordData = {}
local SavedData = {}

local Recording = false
local Playing = false
local Paused = false

local CutIndex = 1
local RecordStart = 0
local RecordTimer = 0
local PlaybackElapsed = 0

local ActiveConnections = {}
local ActiveTweens = {}
local ActiveGhostTracks = {}
local GhostCharacter = nil

local function StopPlayback()
    Playing = false
    Paused = false
    if ActiveConnections["Playback"] then
        pcall(function()
            ActiveConnections["Playback"]:Disconnect()
        end)
        ActiveConnections["Playback"] = nil
    end
    for id, track in pairs(ActiveGhostTracks) do
        pcall(function()
            track:Stop(0)
            track:Destroy()
        end)
    end
    table.clear(ActiveGhostTracks)
    if GhostCharacter then
        pcall(function()
            GhostCharacter:Destroy()
        end)
        GhostCharacter = nil
    end
end

local function StopRecord()
    Recording = false
    if ActiveConnections["Record"] then
        pcall(function()
            ActiveConnections["Record"]:Disconnect()
        end)
        ActiveConnections["Record"] = nil
    end
end

local function RebindCharacter(newChar)
    if not newChar then return end
    StopRecord()
    StopPlayback()
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)
    Animator = Humanoid and Humanoid:WaitForChild("Animator", 10)
end

LocalPlayer.CharacterAdded:Connect(RebindCharacter)

local function CleanupTweens()
    for _, tween in ipairs(ActiveTweens) do
        pcall(function()
            tween:Cancel()
            tween:Destroy()
        end)
    end
    table.clear(ActiveTweens)
end

local function CreateGhostClone()
    if GhostCharacter then
        pcall(function() GhostCharacter:Destroy() end)
        GhostCharacter = nil
    end
    table.clear(ActiveGhostTracks)
    if not Character or not RootPart or not Character:IsDescendantOf(workspace) then return nil end
    local oldArchivable = Character.Archivable
    Character.Archivable = true
    local success, clone = pcall(function() return Character:Clone() end)
    pcall(function() Character.Archivable = oldArchivable end)
    if not success or not clone then return nil end
    clone.Name = "Replay_Ghost_Cyan"
    for _, desc in ipairs(clone:GetDescendants()) do
        pcall(function()
            if desc:IsA("LuaSourceContainer") then
                desc:Destroy()
            elseif desc:IsA("BasePart") then
                desc.Anchored = true
                desc.CanCollide = false
                desc.CanQuery = false
                desc.CanTouch = false
                desc.Massless = true
                desc.Transparency = 0.45
                desc.Material = Enum.Material.ForceField
                desc.Color = Color3.fromRGB(0, 240, 255)
            end
        end)
    end
    local gHumanoid = clone:FindFirstChildOfClass("Humanoid")
    if gHumanoid then
        gHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        pcall(function() gHumanoid.EvaluateStateMachine = false end)
        gHumanoid.AutoRotate = false
        if not gHumanoid:FindFirstChildOfClass("Animator") then
            Instance.new("Animator", gHumanoid)
        end
    end
    clone.Parent = workspace
    GhostCharacter = clone
    return clone
end

local function ApplyNeonGlow(guiObject)
    local outerStroke = Instance.new("UIStroke")
    outerStroke.Name = "OuterGlowStroke"
    outerStroke.Thickness = 2
    outerStroke.Transparency = 0.4
    outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerStroke.Parent = guiObject

    local innerStroke = Instance.new("UIStroke")
    innerStroke.Name = "InnerNeonStroke"
    innerStroke.Thickness = 1.5
    innerStroke.Transparency = 0
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent = guiObject

    local neonGradient = Instance.new("UIGradient")
    neonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 32, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
    })
    neonGradient.Rotation = 45
    neonGradient.Parent = innerStroke

    local outerGradient = neonGradient:Clone()
    outerGradient.Parent = outerStroke

    local rotTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
    local rotTween = TweenService:Create(neonGradient, rotTweenInfo, {Rotation = 405})
    local rotTweenOuter = TweenService:Create(outerGradient, rotTweenInfo, {Rotation = 405})
    rotTween:Play()
    rotTweenOuter:Play()

    table.insert(ActiveTweens, rotTween)
    table.insert(ActiveTweens, rotTweenOuter)
end

local function BindTouchClick(button, callback)
    button.Active = true
    button.Selectable = true
    local fired = false
    local function fire()
        if fired then return end
        fired = true
        task.defer(function() fired = false end)
        pcall(callback)
    end
    button.Activated:Connect(fire)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            fire()
        end
    end)
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

local ExistingGui = PlayerGui:FindFirstChild("R15_AdvancedGhostReplay_UI")
if ExistingGui then ExistingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R15_AdvancedGhostReplay_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local OpenMenu = Instance.new("TextButton")
OpenMenu.Name = "OpenMenuButton"
OpenMenu.Size = UDim2.new(0, 95, 0, 38)
OpenMenu.Position = UDim2.new(0, 15, 0.45, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
OpenMenu.Text = "OPEN MENU"
OpenMenu.TextColor3 = Color3.fromRGB(0, 240, 255)
OpenMenu.TextScaled = true
OpenMenu.Font = Enum.Font.GothamBold
OpenMenu.AutoButtonColor = false
OpenMenu.Active = true
OpenMenu.Selectable = true
OpenMenu.ZIndex = 100
OpenMenu.Draggable = false
OpenMenu.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = OpenMenu
ApplyNeonGlow(OpenMenu)

local Main = Instance.new("Frame")
Main.Name = "MainPanel"
Main.Size = UDim2.new(0, 260, 0, 350)
Main.Position = UDim2.new(0.5, -130, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
Main.BackgroundTransparency = 0.1
Main.Visible = false
Main.ZIndex = 200
Main.Active = false
Main.Selectable = false
Main.Draggable = false
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 6)
mainPadding.PaddingBottom = UDim.new(0, 6)
mainPadding.PaddingLeft = UDim.new(0, 6)
mainPadding.PaddingRight = UDim.new(0, 6)
mainPadding.Parent = Main

ApplyNeonGlow(Main)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0, 24)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.ZIndex = 201
HeaderFrame.Active = false
HeaderFrame.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -26, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "R15 GHOST REPLAY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 201
Title.Parent = HeaderFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
})
titleGradient.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -24, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 40, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.AutoButtonColor = false
CloseButton.Active = true
CloseButton.ZIndex = 202
CloseButton.Parent = HeaderFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

local StatusPanel = Instance.new("Frame")
StatusPanel.Name = "StatusPanel"
StatusPanel.Size = UDim2.new(1, -8, 0, 40)
StatusPanel.Position = UDim2.new(0, 4, 0, 28)
StatusPanel.BackgroundColor3 = Color3.fromRGB(20, 12, 35)
StatusPanel.BackgroundTransparency = 0.3
StatusPanel.ZIndex = 201
StatusPanel.Parent = Main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = StatusPanel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0.5, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: IDLE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 202
StatusLabel.Parent = StatusPanel

local FrameLabel = Instance.new("TextLabel")
FrameLabel.Name = "FrameLabel"
FrameLabel.Size = UDim2.new(1, 0, 0.5, 0)
FrameLabel.Position = UDim2.new(0, 0, 0.5, 0)
FrameLabel.BackgroundTransparency = 1
FrameLabel.Text = "FRAMES: 0 | DURATION: 0.0s"
FrameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FrameLabel.Font = Enum.Font.Gotham
FrameLabel.TextSize = 10
FrameLabel.ZIndex = 202
FrameLabel.Parent = StatusPanel

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -72)
Container.Position = UDim2.new(0, 0, 0, 72)
Container.BackgroundTransparency = 1
Container.ZIndex = 201
Container.Parent = Main

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = Container

local function CreateButton(text, layoutOrder)
    local b = Instance.new("TextButton")
    b.Name = text .. "Button"
    b.Size = UDim2.new(1, -8, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.LayoutOrder = layoutOrder
    b.AutoButtonColor = false
    b.Active = true
    b.ZIndex = 202
    b.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = b

    ApplyNeonGlow(b)
    return b
end

local RecordButton = CreateButton("RECORD", 1)
local StopButton = CreateButton("STOP", 2)

local PlayRow = Instance.new("Frame")
PlayRow.Size = UDim2.new(1, -8, 0, 26)
PlayRow.BackgroundTransparency = 1
PlayRow.LayoutOrder = 3
PlayRow.ZIndex = 201
PlayRow.Parent = Container

local prLayout = Instance.new("UIListLayout")
prLayout.FillDirection = Enum.FillDirection.Horizontal
prLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
prLayout.Parent = PlayRow

local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.48, 0, 1, 0)
PlayButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PlayButton.Text = "PLAY GHOST"
PlayButton.TextColor3 = Color3.fromRGB(0, 255, 120)
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 9
PlayButton.AutoButtonColor = false
PlayButton.Active = true
PlayButton.ZIndex = 202
PlayButton.Parent = PlayRow
ApplyNeonGlow(PlayButton)

local PauseButton = Instance.new("TextButton")
PauseButton.Size = UDim2.new(0.48, 0, 1, 0)
PauseButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PauseButton.Text = "PAUSE"
PauseButton.TextColor3 = Color3.fromRGB(255, 200, 0)
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 9
PauseButton.AutoButtonColor = false
PauseButton.Active = true
PauseButton.ZIndex = 202
PauseButton.Parent = PlayRow
ApplyNeonGlow(PauseButton)

local SeekRow = Instance.new("Frame")
SeekRow.Size = UDim2.new(1, -8, 0, 26)
SeekRow.BackgroundTransparency = 1
SeekRow.LayoutOrder = 4
SeekRow.ZIndex = 201
SeekRow.Parent = Container

local srLayout = Instance.new("UIListLayout")
srLayout.FillDirection = Enum.FillDirection.Horizontal
srLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
srLayout.Parent = SeekRow

local SeekBackButton = Instance.new("TextButton")
SeekBackButton.Size = UDim2.new(0.48, 0, 1, 0)
SeekBackButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SeekBackButton.Text = "SEEK BACK"
SeekBackButton.TextColor3 = Color3.fromRGB(0, 240, 255)
SeekBackButton.Font = Enum.Font.GothamBold
SeekBackButton.TextSize = 9
SeekBackButton.AutoButtonColor = false
SeekBackButton.Active = true
SeekBackButton.ZIndex = 202
SeekBackButton.Parent = SeekRow
ApplyNeonGlow(SeekBackButton)

local SeekForwardButton = Instance.new("TextButton")
SeekForwardButton.Size = UDim2.new(0.48, 0, 1, 0)
SeekForwardButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SeekForwardButton.Text = "SEEK FORWARD"
SeekForwardButton.TextColor3 = Color3.fromRGB(0, 240, 255)
SeekForwardButton.Font = Enum.Font.GothamBold
SeekForwardButton.TextSize = 9
SeekForwardButton.AutoButtonColor = false
SeekForwardButton.Active = true
SeekForwardButton.ZIndex = 202
SeekForwardButton.Parent = SeekRow
ApplyNeonGlow(SeekForwardButton)

local TrimButton = CreateButton("TRIM TIMELINE", 5)

local StorageRow = Instance.new("Frame")
StorageRow.Size = UDim2.new(1, -8, 0, 26)
StorageRow.BackgroundTransparency = 1
StorageRow.LayoutOrder = 6
StorageRow.ZIndex = 201
StorageRow.Parent = Container

local stLayout = Instance.new("UIListLayout")
stLayout.FillDirection = Enum.FillDirection.Horizontal
stLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
stLayout.Parent = StorageRow

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.48, 0, 1, 0)
SaveButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SaveButton.Text = "SAVE DATA"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 9
SaveButton.AutoButtonColor = false
SaveButton.Active = true
SaveButton.ZIndex = 202
SaveButton.Parent = StorageRow
ApplyNeonGlow(SaveButton)

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(0.48, 0, 1, 0)
LoadButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
LoadButton.Text = "LOAD DATA"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 9
LoadButton.AutoButtonColor = false
LoadButton.Active = true
LoadButton.ZIndex = 202
LoadButton.Parent = StorageRow
ApplyNeonGlow(LoadButton)

BindTouchClick(OpenMenu, function()
    Main.Visible = true
end)

BindTouchClick(CloseButton, function()
    Main.Visible = false
end)

local function FetchActiveAnimations()
    local activeAnimList = {}
    if Animator then
        local success, playingTracks = pcall(function()
            return Animator:GetPlayingAnimationTracks()
        end)
        if success and playingTracks then
            for _, track in ipairs(playingTracks) do
                pcall(function()
                    if track.Animation and track.Animation.AnimationId ~= "" then
                        table.insert(activeAnimList, {
                            AnimationId = track.Animation.AnimationId,
                            TimePosition = track.TimePosition,
                            Speed = track.Speed,
                            Weight = track.WeightCurrent
                        })
                    end
                end)
            end
        end
    end
    return activeAnimList
end

local function CaptureFrame()
    if not RootPart or not Humanoid or not Character or not RootPart:IsDescendantOf(workspace) then return end
    if #RecordData >= MAX_RECORD_FRAMES then
        StopRecord()
        StatusLabel.Text = "STATUS: MAX DURATION"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    local currentState = Enum.HumanoidStateType.None
    pcall(function()
        currentState = Humanoid:GetState()
    end)

    local frame = {
        Time = os.clock() - RecordStart,
        CFrame = RootPart.CFrame,
        Position = RootPart.Position,
        Rotation = RootPart.Orientation,
        Velocity = RootPart.AssemblyLinearVelocity,
        HumanoidState = currentState,
        Animations = FetchActiveAnimations()
    }

    table.insert(RecordData, frame)
    StatusLabel.Text = "STATUS: RECORDING"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    FrameLabel.Text = string.format("FRAMES: %d | DURATION: %.1fs", #RecordData, frame.Time)
end

local function StartRecord()
    StopPlayback()
    StopRecord()
    table.clear(RecordData)
    CutIndex = 1

    if not RootPart or not Humanoid then return end

    Recording = true
    RecordStart = os.clock()
    RecordTimer = 0
    CaptureFrame()

    ActiveConnections["Record"] = RunService.Heartbeat:Connect(function(dt)
        if Recording then
            RecordTimer += dt
            while RecordTimer >= RECORD_INTERVAL do
                RecordTimer -= RECORD_INTERVAL
                CaptureFrame()
                if not Recording then break end
            end
        end
    end)
end

BindTouchClick(RecordButton, StartRecord)

BindTouchClick(StopButton, function()
    StopRecord()
    StopPlayback()
    StatusLabel.Text = "STATUS: IDLE"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
end)

local function SynchronizeGhostAnimations(ghostAnimator, animDataList)
    if not ghostAnimator then return end
    local active = {}
    for _, info in ipairs(animDataList or {}) do
        local id = info.AnimationId
        if id and id ~= "" then
            active[id] = true
            local track = ActiveGhostTracks[id]
            if not track then
                local anim = Instance.new("Animation")
                anim.AnimationId = id
                local ok, loaded = pcall(function() return ghostAnimator:LoadAnimation(anim) end)
                anim:Destroy()
                if ok and loaded then
                    track = loaded
                    track.Looped = true
                    ActiveGhostTracks[id] = track
                    pcall(function() track:Play(0.05, info.Weight or 1, info.Speed or 1) end)
                end
            end
            if track then
                pcall(function()
                    local speed = info.Speed or 1
                    local weight = info.Weight or 1
                    if not track.IsPlaying then
                        track:Play(0.05, weight, speed)
                    else
                        track:AdjustSpeed(speed)
                        track:AdjustWeight(weight, 0.05)
                    end
                    local recorded = info.TimePosition or 0
                    if math.abs(track.TimePosition - recorded) > 0.12 then
                        track.TimePosition = recorded
                    end
                end)
            end
        end
    end
    for id, track in pairs(ActiveGhostTracks) do
        if not active[id] then
            pcall(function() track:Stop(0.05); track:Destroy() end)
            ActiveGhostTracks[id] = nil
        end
    end
end

local function GetFramePair(targetTime)
    local count = #RecordData
    if count < 2 then return nil, nil, 0, 1 end

    if targetTime <= RecordData[1].Time then
        return RecordData[1], RecordData[2], 0, 1
    end

    if targetTime >= RecordData[count].Time then
        return RecordData[count - 1], RecordData[count], 1, count - 1
    end

    local low = 1
    local high = count - 1

    while low <= high do
        local mid = math.floor((low + high) / 2)
        if RecordData[mid].Time <= targetTime and targetTime <= RecordData[mid + 1].Time then
            local f1 = RecordData[mid]
            local f2 = RecordData[mid + 1]
            local span = f2.Time - f1.Time
            local alpha = span > 0 and (targetTime - f1.Time) / span or 0
            return f1, f2, math.clamp(alpha, 0, 1), mid
        elseif targetTime < RecordData[mid].Time then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    return RecordData[count - 1], RecordData[count], 1, count - 1
end

local PlaybackStartClock = 0
local PlaybackPausedAt = 0
local function StartPlayback()
    if #RecordData < 2 then return end
    StopRecord()
    if Playing then
        Paused = false
        PlaybackStartClock = os.clock() - PlaybackElapsed
        return
    end
    StopPlayback()
    local ghost = CreateGhostClone()
    if not ghost then return end
    local ghostRoot = ghost:FindFirstChild("HumanoidRootPart")
    local ghostHumanoid = ghost:FindFirstChildOfClass("Humanoid")
    local ghostAnimator = ghostHumanoid and ghostHumanoid:FindFirstChildOfClass("Animator")
    if not ghostRoot or not ghostAnimator then StopPlayback(); return end
    Playing = true
    Paused = false
    PlaybackElapsed = 0
    PlaybackStartClock = os.clock()
    PlaybackPausedAt = 0
    pcall(function() ghostHumanoid.AutoRotate = false end)
    pcall(function() ghost:PivotTo(RecordData[1].CFrame) end)
    local totalDuration = math.max(0, RecordData[#RecordData].Time - RecordData[1].Time)
    ActiveConnections["Playback"] = RunService.RenderStepped:Connect(function()
        if not Playing or Paused then return end
        if not GhostCharacter or not GhostCharacter.Parent then StopPlayback(); return end
        PlaybackElapsed = os.clock() - PlaybackStartClock
        if PlaybackElapsed >= totalDuration then
            PlaybackElapsed = totalDuration
            local last = RecordData[#RecordData]
            pcall(function() GhostCharacter:PivotTo(last.CFrame) end)
            SynchronizeGhostAnimations(ghostAnimator, last.Animations)
            StopPlayback()
            StatusLabel.Text = "STATUS: IDLE"
            StatusLabel.TextColor3 = Color3.fromRGB(0,240,255)
            FrameLabel.Text = string.format("FRAME: %d/%d | DURATION: %.1fs", #RecordData, #RecordData, totalDuration)
            return
        end
        local targetTime = RecordData[1].Time + PlaybackElapsed
        local f1, f2, alpha, frameIndex = GetFramePair(targetTime)
        if not f1 or not f2 then return end
        local cf = f1.CFrame:Lerp(f2.CFrame, alpha)
        pcall(function() GhostCharacter:PivotTo(cf) end)
        SynchronizeGhostAnimations(ghostAnimator, f1.Animations)
        FrameLabel.Text = string.format("FRAME: %d/%d | DURATION: %.1fs", frameIndex, #RecordData, PlaybackElapsed)
    end)
    StatusLabel.Text = "STATUS: PLAYING"
    StatusLabel.TextColor3 = Color3.fromRGB(0,255,120)
end

BindTouchClick(PlayButton, StartPlayback)

BindTouchClick(PauseButton, function()
    if not Playing then return end
    if Paused then
        Paused = false
        PlaybackStartClock = os.clock() - PlaybackElapsed
        for _, track in pairs(ActiveGhostTracks) do pcall(function() track:AdjustSpeed(1) end) end
        StatusLabel.Text = "STATUS: PLAYING"
        StatusLabel.TextColor3 = Color3.fromRGB(0,255,120)
    else
        PlaybackElapsed = os.clock() - PlaybackStartClock
        Paused = true
        for _, track in pairs(ActiveGhostTracks) do pcall(function() track:AdjustSpeed(0) end) end
        StatusLabel.Text = "STATUS: PAUSED"
        StatusLabel.TextColor3 = Color3.fromRGB(255,200,0)
    end
end)

local function UpdatePreviewState()
    CutIndex = math.clamp(CutIndex, 1, math.max(1, #RecordData))
    if RecordData[CutIndex] then
        if not GhostCharacter then CreateGhostClone() end
        if GhostCharacter then
            local gRoot = GhostCharacter:FindFirstChild("HumanoidRootPart")
            local gHum = GhostCharacter:FindFirstChildOfClass("Humanoid")
            local gAnim = gHum and gHum:FindFirstChildOfClass("Animator")
            if gRoot then
                pcall(function() GhostCharacter:PivotTo(RecordData[CutIndex].CFrame) end)
            end
            if gAnim then
                SynchronizeGhostAnimations(gAnim, RecordData[CutIndex].Animations)
            end
        end
        FrameLabel.Text = string.format("SEEK: %d/%d | TIME: %.1fs", CutIndex, #RecordData, RecordData[CutIndex].Time)
    end
end

BindTouchClick(SeekBackButton, function()
    if #RecordData == 0 then return end
    StopRecord()
    StopPlayback()
    CutIndex = math.max(1, CutIndex - 15)
    UpdatePreviewState()
end)

BindTouchClick(SeekForwardButton, function()
    if #RecordData == 0 then return end
    StopRecord()
    StopPlayback()
    CutIndex = math.min(#RecordData, CutIndex + 15)
    UpdatePreviewState()
end)

BindTouchClick(TrimButton, function()
    if #RecordData == 0 or CutIndex >= #RecordData then return end
    StopRecord()
    StopPlayback()

    for i = #RecordData, CutIndex + 1, -1 do
        table.remove(RecordData, i)
    end

    StatusLabel.Text = "STATUS: TRIMMED"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    FrameLabel.Text = string.format("FRAMES: %d", #RecordData)
end)

BindTouchClick(SaveButton, function()
    if #RecordData == 0 then return end

    SavedData = {}

    for _, frame in ipairs(RecordData) do
        local animsCopy = {}
        for _, anim in ipairs(frame.Animations) do
            table.insert(animsCopy, {
                AnimationId = anim.AnimationId,
                TimePosition = anim.TimePosition,
                Speed = anim.Speed,
                Weight = anim.Weight
            })
        end

        table.insert(SavedData, {
            Time = frame.Time,
            CFrame = frame.CFrame,
            Position = frame.Position,
            Rotation = frame.Rotation,
            Velocity = frame.Velocity,
            HumanoidState = frame.HumanoidState,
            Animations = animsCopy
        })
    end

    StatusLabel.Text = "STATUS: SAVED"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
end)

BindTouchClick(LoadButton, function()
    if #SavedData == 0 then return end

    StopRecord()
    StopPlayback()

    RecordData = {}

    for _, frame in ipairs(SavedData) do
        local animsCopy = {}
        for _, anim in ipairs(frame.Animations) do
            table.insert(animsCopy, {
                AnimationId = anim.AnimationId,
                TimePosition = anim.TimePosition,
                Speed = anim.Speed,
                Weight = anim.Weight
            })
        end

        table.insert(RecordData, {
            Time = frame.Time,
            CFrame = frame.CFrame,
            Position = frame.Position,
            Rotation = frame.Rotation,
            Velocity = frame.Velocity,
            HumanoidState = frame.HumanoidState,
            Animations = animsCopy
        })
    end

    CutIndex = 1
    StatusLabel.Text = "STATUS: LOADED"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    FrameLabel.Text = string.format("FRAMES: %d", #RecordData)
end)

ScreenGui.Destroying:Connect(function()
    StopRecord()
    StopPlayback()
    CleanupTweens()
end)
