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
local PlaybackCursor = 1
local PlaybackLastCFrame = nil

local ActiveConnections = {}
local ActiveTweens = {}
local ActivePlaybackTracks = {}

local function StopPlayback()
    Playing = false
    Paused = false
    PlaybackElapsed = 0
    PlaybackCursor = 1
    PlaybackLastCFrame = nil

    if ActiveConnections["Playback"] then
        pcall(function()
            ActiveConnections["Playback"]:Disconnect()
        end)
        ActiveConnections["Playback"] = nil
    end

    for id, track in pairs(ActivePlaybackTracks) do
        pcall(function()
            if track then
                track:Stop(0.08)
                track:Destroy()
            end
        end)
        ActivePlaybackTracks[id] = nil
    end

    pcall(function()
        if Humanoid then
            Humanoid.AutoRotate = true
        end
    end)
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
    if not newChar then
        return
    end

    StopRecord()
    StopPlayback()

    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newChar:WaitForChild("Humanoid", 10)

    if Humanoid then
        Animator = Humanoid:WaitForChild("Animator", 10)
    else
        Animator = nil
    end
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

    local rotTweenInfo = TweenInfo.new(
        4,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1
    )

    local rotTween = TweenService:Create(
        neonGradient,
        rotTweenInfo,
        {Rotation = 405}
    )

    local rotTweenOuter = TweenService:Create(
        outerGradient,
        rotTweenInfo,
        {Rotation = 405}
    )

    rotTween:Play()
    rotTweenOuter:Play()

    table.insert(ActiveTweens, rotTween)
    table.insert(ActiveTweens, rotTweenOuter)
end

local function BindTouchClick(button, callback)
    button.Active = true

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            local pressTween = TweenService:Create(
                button,
                TweenInfo.new(
                    0.08,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    BackgroundColor3 = Color3.fromRGB(60, 20, 90)
                }
            )

            pressTween:Play()

            task.delay(0.08, function()
                pcall(function()
                    TweenService:Create(
                        button,
                        TweenInfo.new(
                            0.1,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        ),
                        {
                            BackgroundColor3 = Color3.fromRGB(15, 10, 25)
                        }
                    ):Play()
                end)
            end)

            pcall(callback)
        end
    end)
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

if not PlayerGui then
    return
end

local ExistingGui =
    PlayerGui:FindFirstChild("R15_AdvancedGhostReplay_UI")

if ExistingGui then
    ExistingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R15_AdvancedGhostReplay_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
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
OpenMenu.Active = true
OpenMenu.Draggable = false
OpenMenu.ZIndex = 100
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
Main.Active = true
Main.Draggable = false
Main.ZIndex = 200
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
PlayButton.Text = "PLAY"
PlayButton.TextColor3 = Color3.fromRGB(0, 255, 120)
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 9
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
LoadButton.Active = true
LoadButton.ZIndex = 202
LoadButton.Parent = StorageRow

ApplyNeonGlow(LoadButton)

BindTouchClick(OpenMenu, function()
    Main.Visible = not Main.Visible
end)

BindTouchClick(CloseButton, function()
    Main.Visible = false
end)

local function FetchActiveAnimations()
    local activeAnimList = {}

    if not Animator then
        return activeAnimList
    end

    local success, playingTracks = pcall(function()
        return Animator:GetPlayingAnimationTracks()
    end)

    if not success or not playingTracks then
        return activeAnimList
    end

    for _, track in ipairs(playingTracks) do
        pcall(function()
            if track.Animation
                and track.Animation.AnimationId ~= "" then

                table.insert(activeAnimList, {
                    AnimationId = track.Animation.AnimationId,
                    TimePosition = track.TimePosition,
                    Speed = track.Speed,
                    Weight = track.WeightCurrent
                })
            end
        end)
    end

    return activeAnimList
end

local function CaptureFrame()
    if not RootPart
        or not Humanoid
        or not Character
        or not RootPart:IsDescendantOf(workspace) then
        return
    end

    if #RecordData >= MAX_RECORD_FRAMES then
        StopRecord()

        StatusLabel.Text = "STATUS: MAX DURATION"
        StatusLabel.TextColor3 =
            Color3.fromRGB(255, 100, 100)

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
    StatusLabel.TextColor3 =
        Color3.fromRGB(255, 50, 50)

    FrameLabel.Text = string.format(
        "FRAMES: %d | DURATION: %.1fs",
        #RecordData,
        frame.Time
    )
end

local function StartRecord()
    StopPlayback()
    StopRecord()

    table.clear(RecordData)

    CutIndex = 1

    if not RootPart or not Humanoid then
        return
    end

    Recording = true
    RecordStart = os.clock()
    RecordTimer = 0

    CaptureFrame()

    ActiveConnections["Record"] =
        RunService.Heartbeat:Connect(function(dt)

            if not Recording then
                return
            end

            RecordTimer += dt

            while RecordTimer >= RECORD_INTERVAL do
                RecordTimer -= RECORD_INTERVAL
                CaptureFrame()

                if not Recording then
                    break
                end
            end
        end)
end

BindTouchClick(RecordButton, StartRecord)

BindTouchClick(StopButton, function()
    StopRecord()
    StopPlayback()

    StatusLabel.Text = "STATUS: IDLE"
    StatusLabel.TextColor3 =
        Color3.fromRGB(0, 240, 255)
end)

local function SynchronizePlayerAnimations(animDataList)
    if not Animator then
        return
    end

    local activeIdsThisFrame = {}

    for _, animInfo in ipairs(animDataList or {}) do
        local animId = animInfo.AnimationId

        if animId and animId ~= "" then
            activeIdsThisFrame[animId] = true

            local track = ActivePlaybackTracks[animId]

            if not track then
                local animation = Instance.new("Animation")
                animation.AnimationId = animId

                local ok, loadedTrack =
                    pcall(function()
                        return Animator:LoadAnimation(animation)
                    end)

                animation:Destroy()

                if ok and loadedTrack then
                    track = loadedTrack
                    ActivePlaybackTracks[animId] = track

                    pcall(function()
                        track:Play(
                            0,
                            math.clamp(animInfo.Weight or 1, 0, 1),
                            animInfo.Speed or 1
                        )
                    end)
                end
            end

            if track then
                pcall(function()
                    local speed = animInfo.Speed or 1
                    local weight = animInfo.Weight or 1
                    local timePosition =
                        animInfo.TimePosition or 0

                    if not track.IsPlaying then
                        track:Play(0, weight, speed)
                    else
                        track:AdjustSpeed(speed)
                        track:AdjustWeight(weight, 0.05)
                    end

                    local difference =
                        math.abs(
                            track.TimePosition -
                            timePosition
                        )

                    if difference > 0.25 then
                        track.TimePosition = timePosition
                    end
                end)
            end
        end
    end

    for animId, track in pairs(ActivePlaybackTracks) do
        if not activeIdsThisFrame[animId] then
            pcall(function()
                track:Stop(0.08)
                track:Destroy()
            end)

            ActivePlaybackTracks[animId] = nil
        end
    end
end

local function StartPlayback()
    if #RecordData < 2 then
        return
    end

    StopRecord()

    if Playing and not Paused then
        return
    end

    if Playing and Paused then
        Paused = false

        StatusLabel.Text = "STATUS: PLAYING"
        StatusLabel.TextColor3 =
            Color3.fromRGB(0, 255, 120)

        return
    end

    StopPlayback()

    if not Character
        or not RootPart
        or not Humanoid
        or not RootPart:IsDescendantOf(workspace) then
        return
    end

    Playing = true
    Paused = false
    PlaybackElapsed = 0
    PlaybackCursor = 1

    local firstFrame = RecordData[1]
    local lastFrame = RecordData[#RecordData]

    local totalDuration =
        math.max(
            0,
            lastFrame.Time - firstFrame.Time
        )

    local playbackStartTime = os.clock()

    pcall(function()
        Humanoid.AutoRotate = false
    end)

    pcall(function()
        RootPart.CFrame = firstFrame.CFrame
    end)

    PlaybackLastCFrame = firstFrame.CFrame

    SynchronizePlayerAnimations(
        firstFrame.Animations
    )

    StatusLabel.Text = "STATUS: PLAYING"
    StatusLabel.TextColor3 =
        Color3.fromRGB(0, 255, 120)

    ActiveConnections["Playback"] =
        RunService.RenderStepped:Connect(function()

            if not Playing then
                return
            end

            if Paused then
                return
            end

            if not Character
                or not RootPart
                or not Humanoid
                or not RootPart:IsDescendantOf(workspace) then

                StopPlayback()

                StatusLabel.Text = "STATUS: IDLE"
                StatusLabel.TextColor3 =
                    Color3.fromRGB(0, 240, 255)

                return
            end

            PlaybackElapsed =
                os.clock() - playbackStartTime

            if PlaybackElapsed >= totalDuration then

                PlaybackElapsed = totalDuration

                pcall(function()
                    RootPart.CFrame = lastFrame.CFrame
                end)

                SynchronizePlayerAnimations(
                    lastFrame.Animations
                )

                StopPlayback()

                StatusLabel.Text = "STATUS: IDLE"
                StatusLabel.TextColor3 =
                    Color3.fromRGB(0, 240, 255)

                FrameLabel.Text = string.format(
                    "FRAME: %d/%d | DURATION: %.1fs",
                    #RecordData,
                    #RecordData,
                    totalDuration
                )

                return
            end

            local targetTime =
                firstFrame.Time + PlaybackElapsed

            while PlaybackCursor < #RecordData - 1
                and RecordData[PlaybackCursor + 1].Time <= targetTime do

                PlaybackCursor += 1
            end

            local f1 = RecordData[PlaybackCursor]
            local f2 =
                RecordData[
                    math.min(
                        PlaybackCursor + 1,
                        #RecordData
                    )
                ]

            if not f1 or not f2 then
                return
            end

            local span = f2.Time - f1.Time

            local alpha = 0

            if span > 0 then
                alpha = math.clamp(
                    (targetTime - f1.Time) / span,
                    0,
                    1
                )
            end

            local targetCFrame =
                f1.CFrame:Lerp(
                    f2.CFrame,
                    alpha
                )

            if PlaybackLastCFrame then
                local positionDifference =
                    (
                        targetCFrame.Position -
                        PlaybackLastCFrame.Position
                    ).Magnitude

                if positionDifference > 20 then
                    targetCFrame =
                        PlaybackLastCFrame:Lerp(
                            targetCFrame,
                            0.5
                        )
                end
            end

            pcall(function()
                RootPart.CFrame = targetCFrame
                RootPart.AssemblyLinearVelocity =
                    Vector3.zero
                RootPart.AssemblyAngularVelocity =
                    Vector3.zero
            end)

            PlaybackLastCFrame = targetCFrame

            local animationFrame = f1

            if alpha >= 0.5 then
                animationFrame = f2
            end

            SynchronizePlayerAnimations(
                animationFrame.Animations
            )

            FrameLabel.Text = string.format(
                "FRAME: %d/%d | DURATION: %.1fs",
                PlaybackCursor,
                #RecordData,
                PlaybackElapsed
            )
        end)
end

BindTouchClick(PlayButton, StartPlayback)

BindTouchClick(PauseButton, function()

    if not Playing then
        return
    end

    Paused = not Paused

    if Paused then

        StatusLabel.Text = "STATUS: PAUSED"
        StatusLabel.TextColor3 =
            Color3.fromRGB(255, 200, 0)

        for _, track in pairs(ActivePlaybackTracks) do
            pcall(function()
                track:AdjustSpeed(0)
            end)
        end

    else

        StatusLabel.Text = "STATUS: PLAYING"
        StatusLabel.TextColor3 =
            Color3.fromRGB(0, 255, 120)

        for _, track in pairs(ActivePlaybackTracks) do
            pcall(function()
                local speed = track.Speed

                if not speed or speed == 0 then
                    speed = 1
                end

                track:AdjustSpeed(speed)
            end)
        end
    end
end)

local function UpdatePreviewState()

    CutIndex =
        math.clamp(
            CutIndex,
            1,
            math.max(1, #RecordData)
        )

    if RecordData[CutIndex] then

        if not RootPart or not RootPart:IsDescendantOf(workspace) then
            return
        end

        pcall(function()
            RootPart.CFrame =
                RecordData[CutIndex].CFrame
        end)

        SynchronizePlayerAnimations(
            RecordData[CutIndex].Animations
        )

        FrameLabel.Text = string.format(
            "SEEK: %d/%d | TIME: %.1fs",
            CutIndex,
            #RecordData,
            RecordData[CutIndex].Time
        )
    end
end

BindTouchClick(SeekBackButton, function()

    if #RecordData == 0 then
        return
    end

    StopRecord()
    StopPlayback()

    CutIndex =
        math.max(
            1,
            CutIndex - 15
        )

    Paused = true

    UpdatePreviewState()
end)

BindTouchClick(SeekForwardButton, function()

    if #RecordData == 0 then
        return
    end

    StopRecord()
    StopPlayback()

    CutIndex =
        math.min(
            #RecordData,
            CutIndex + 15
        )

    Paused = true

    UpdatePreviewState()
end)

BindTouchClick(TrimButton, function()

    if #RecordData == 0
        or CutIndex >= #RecordData then
        return
    end

    StopRecord()
    StopPlayback()

    for i = #RecordData, CutIndex + 1, -1 do
        table.remove(RecordData, i)
    end

    StatusLabel.Text = "STATUS: TRIMMED"
    StatusLabel.TextColor3 =
        Color3.fromRGB(255, 200, 0)

    FrameLabel.Text = string.format(
        "FRAMES: %d",
        #RecordData
    )
end)

BindTouchClick(SaveButton, function()

    if #RecordData == 0 then
        return
    end

    SavedData = {}

    for _, frame in ipairs(RecordData) do

        local animsCopy = {}

        for _, anim in ipairs(frame.Animations or {}) do
            table.insert(
                animsCopy,
                {
                    AnimationId = anim.AnimationId,
                    TimePosition = anim.TimePosition,
                    Speed = anim.Speed,
                    Weight = anim.Weight
                }
            )
        end

        table.insert(
            SavedData,
            {
                Time = frame.Time,
                CFrame = frame.CFrame,
                Position = frame.Position,
                Rotation = frame.Rotation,
                Velocity = frame.Velocity,
                HumanoidState = frame.HumanoidState,
                Animations = animsCopy
            }
        )
    end

    StatusLabel.Text = "STATUS: SAVED"
    StatusLabel.TextColor3 =
        Color3.fromRGB(0, 255, 120)
end)

BindTouchClick(LoadButton, function()

    if #SavedData == 0 then
        return
    end

    StopRecord()
    StopPlayback()

    RecordData = {}

    for _, frame in ipairs(SavedData) do

        local animsCopy = {}

        for _, anim in ipairs(frame.Animations or {}) do
            table.insert(
                animsCopy,
                {
                    AnimationId = anim.AnimationId,
                    TimePosition = anim.TimePosition,
                    Speed = anim.Speed,
                    Weight = anim.Weight
                }
            )
        end

        table.insert(
            RecordData,
            {
                Time = frame.Time,
                CFrame = frame.CFrame,
                Position = frame.Position,
                Rotation = frame.Rotation,
                Velocity = frame.Velocity,
                HumanoidState = frame.HumanoidState,
                Animations = animsCopy
            }
        )
    end

    CutIndex = 1
    PlaybackCursor = 1

    StatusLabel.Text = "STATUS: LOADED"
    StatusLabel.TextColor3 =
        Color3.fromRGB(0, 240, 255)

    FrameLabel.Text = string.format(
        "FRAMES: %d",
        #RecordData
    )
end)

ScreenGui.Destroying:Connect(function()
    StopRecord()
    StopPlayback()
    CleanupTweens()
end)
