local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local GUI_NAME = "DeltaAutoWalk"
local DATA_FOLDER = "DeltaAutoWalk"
local INDEX_FILE = DATA_FOLDER .. "/index.json"

local SAMPLE_INTERVAL = 0.035
local MIN_SAMPLE_DISTANCE = 0.12
local MAX_ROUTE_POINTS = 100000

local DEFAULT_SPEED = 16
local MIN_SPEED = 2
local MAX_SPEED = 100

local CHARACTER
local HUMANOID
local ROOT

local function refreshCharacter()
    CHARACTER = Player.Character

    if not CHARACTER then
        CHARACTER = Player.CharacterAdded:Wait()
    end

    HUMANOID = CHARACTER:FindFirstChildOfClass("Humanoid")

    if not HUMANOID then
        HUMANOID = CHARACTER:WaitForChild("Humanoid", 10)
    end

    ROOT = CHARACTER:FindFirstChild("HumanoidRootPart")

    if not ROOT then
        ROOT = CHARACTER:WaitForChild("HumanoidRootPart", 10)
    end

    return CHARACTER ~= nil
        and HUMANOID ~= nil
        and ROOT ~= nil
end

refreshCharacter()

local Recording = false
local Playing = false

local LoopEnabled = false
local RespawnEnabled = false
local JumpEnabled = false
local PathEnabled = true
local ShiftEnabled = false

local HorizontalOffset = 0
local PlaybackSpeed = DEFAULT_SPEED

local Route = {}
local RouteName = nil
local RouteStart = nil

local RecordConnection = nil
local PlaybackConnection = nil
local CharacterConnection = nil

local PlaybackIndex = 1
local PlaybackStartPosition = nil
local PlaybackStartYaw = nil

local LastRecordPosition = nil
local LastRecordTime = 0

local LastMovePosition = nil
local StuckTime = 0

local PathFolder = Instance.new("Folder")
PathFolder.Name = "DeltaAutoWalkPath"
PathFolder.Parent = workspace

local function stopRecordConnection()
    if RecordConnection then
        RecordConnection:Disconnect()
        RecordConnection = nil
    end
end

local function stopPlaybackConnection()
    if PlaybackConnection then
        PlaybackConnection:Disconnect()
        PlaybackConnection = nil
    end
end

local function stopMovement()
    if HUMANOID and HUMANOID.Parent then
        HUMANOID:Move(Vector3.zero, false)
    end
end

local function clearPath()
    for _, object in ipairs(PathFolder:GetChildren()) do
        object:Destroy()
    end
end

local function createPathPoint(position)
    if not PathEnabled then
        return
    end

    local point = Instance.new("Part")
    point.Name = "Point"
    point.Shape = Enum.PartType.Ball
    point.Size = Vector3.new(0.16, 0.16, 0.16)
    point.Position = position
    point.Anchored = true
    point.CanCollide = false
    point.CanTouch = false
    point.CanQuery = false
    point.CastShadow = false
    point.Material = Enum.Material.Neon
    point.Color = Color3.fromRGB(255, 35, 180)
    point.Parent = PathFolder
end

local function createPathLine(a, b)
    if not PathEnabled then
        return
    end

    local difference = b - a
    local length = difference.Magnitude

    if length < 0.01 then
        return
    end

    local line = Instance.new("Part")
    line.Name = "Line"
    line.Size = Vector3.new(0.08, 0.08, length)
    line.CFrame = CFrame.lookAt((a + b) / 2, b)
    line.Anchored = true
    line.CanCollide = false
    line.CanTouch = false
    line.CanQuery = false
    line.CastShadow = false
    line.Material = Enum.Material.Neon
    line.Color = Color3.fromRGB(255, 35, 180)
    line.Parent = PathFolder
end

local function drawRoute()
    clearPath()

    if not PathEnabled then
        return
    end

    local previousPosition = nil

    for _, point in ipairs(Route) do
        local position = Vector3.new(
            point.x,
            point.y,
            point.z
        )

        createPathPoint(position)

        if previousPosition then
            createPathLine(previousPosition, position)
        end

        previousPosition = position
    end
end

local function getStateData()
    local state = HUMANOID:GetState()

    return {
        jump =
            state == Enum.HumanoidStateType.Jumping,

        freefall =
            state == Enum.HumanoidStateType.Freefall,

        seated =
            state == Enum.HumanoidStateType.Seated
    }
end

local function beginRecording()
    if Recording then
        return
    end

    if Playing then
        stopPlaybackConnection()
        Playing = false
        stopMovement()
    end

    if not refreshCharacter() then
        return
    end

    table.clear(Route)

    RouteName = nil
    RouteStart = ROOT.CFrame

    clearPath()

    Recording = true
    LastRecordPosition = ROOT.Position
    LastRecordTime = os.clock()

    table.insert(Route, {
        x = ROOT.Position.X,
        y = ROOT.Position.Y,
        z = ROOT.Position.Z,
        yaw = math.atan2(
            -ROOT.CFrame.LookVector.X,
            -ROOT.CFrame.LookVector.Z
        ),
        t = 0,
        jump = false,
        freefall = false,
        seated = false
    })

    createPathPoint(ROOT.Position)

    RecordConnection = RunService.Heartbeat:Connect(function()
        if not Recording then
            return
        end

        if not ROOT
            or not ROOT.Parent
            or not HUMANOID
            or HUMANOID.Health <= 0 then

            return
        end

        local now = os.clock()

        if now - LastRecordTime < SAMPLE_INTERVAL then
            return
        end

        LastRecordTime = now

        local position = ROOT.Position
        local distance = (position - LastRecordPosition).Magnitude

        if distance < MIN_SAMPLE_DISTANCE then
            return
        end

        if #Route >= MAX_ROUTE_POINTS then
            Recording = false
            stopRecordConnection()
            return
        end

        local stateData = getStateData()

        local first = Route[1]

        local currentTime = now - (LastRecordTime - SAMPLE_INTERVAL)

        if #Route > 0 then
            local firstPoint = Route[1]
            currentTime = now - (os.clock() - firstPoint.t)
        end

        local point = {
            x = position.X,
            y = position.Y,
            z = position.Z,

            yaw = math.atan2(
                -ROOT.CFrame.LookVector.X,
                -ROOT.CFrame.LookVector.Z
            ),

            t = os.clock(),

            jump = stateData.jump,
            freefall = stateData.freefall,
            seated = stateData.seated
        }

        if #Route == 1 then
            point.t = 0
        else
            point.t =
                Route[#Route].t
                + (now - LastRecordTime + SAMPLE_INTERVAL)
        end

        table.insert(Route, point)

        createPathPoint(position)

        local previous = Route[#Route - 1]

        if previous then
            createPathLine(
                Vector3.new(
                    previous.x,
                    previous.y,
                    previous.z
                ),
                position
            )
        end

        LastRecordPosition = position
    end)
end

local function finishRecording()
    if not Recording then
        return
    end

    Recording = false
    stopRecordConnection()

    if #Route >= 2 then
        local startTime = Route[1].t

        for _, point in ipairs(Route) do
            point.t = point.t - startTime
        end
    end
end

local function stopAll()
    Recording = false
    Playing = false

    stopRecordConnection()
    stopPlaybackConnection()

    stopMovement()
end

local function getRoutePosition(point)
    local routePosition = Vector3.new(
        point.x,
        point.y,
        point.z
    )

    if not PlaybackStartPosition or not RouteStart then
        return routePosition
    end

    local routeOrigin = RouteStart.Position

    local relative = routePosition - routeOrigin

    local offset = Vector3.new(
        HorizontalOffset,
        0,
        0
    )

    return PlaybackStartPosition + relative + offset
end

local function getInterpolatedPosition(a, b, alpha)
    return Vector3.new(
        a.X + (b.X - a.X) * alpha,
        a.Y + (b.Y - a.Y) * alpha,
        a.Z + (b.Z - a.Z) * alpha
    )
end

local function findNextPoint(currentTime)
    local count = #Route

    if count < 2 then
        return 1, 1, 0
    end

    while PlaybackIndex < count
        and Route[PlaybackIndex + 1].t <= currentTime do

        PlaybackIndex += 1
    end

    if PlaybackIndex >= count then
        return count, count, 0
    end

    local a = Route[PlaybackIndex]
    local b = Route[PlaybackIndex + 1]

    local duration = b.t - a.t

    if duration <= 0 then
        return PlaybackIndex, PlaybackIndex + 1, 0
    end

    local alpha =
        (currentTime - a.t) / duration

    alpha = math.clamp(alpha, 0, 1)

    return PlaybackIndex, PlaybackIndex + 1, alpha
end

local function startPlayback()
    if Playing then
        return
    end

    if #Route < 2 then
        return
    end

    if not refreshCharacter() then
        return
    end

    finishRecording()

    Playing = true
    PlaybackIndex = 1

    PlaybackStartPosition = ROOT.Position

    PlaybackStartYaw =
        math.atan2(
            -ROOT.CFrame.LookVector.X,
            -ROOT.CFrame.LookVector.Z
        )

    LastMovePosition = ROOT.Position
    StuckTime = 0

    local elapsed = 0
    local lastTime = os.clock()

    PlaybackConnection = RunService.Heartbeat:Connect(function()
        if not Playing then
            return
        end

        if not ROOT
            or not ROOT.Parent
            or not HUMANOID
            or HUMANOID.Health <= 0 then

            if RespawnEnabled then
                return
            end

            Playing = false
            stopPlaybackConnection()
            return
        end

        local now = os.clock()
        local delta = now - lastTime
        lastTime = now

        delta = math.clamp(delta, 0, 0.1)

        elapsed += delta * (PlaybackSpeed / DEFAULT_SPEED)

        local lastPoint = Route[#Route]

        if elapsed > lastPoint.t then
            if LoopEnabled then
                elapsed = 0
                PlaybackIndex = 1

                PlaybackStartPosition = ROOT.Position
            else
                Playing = false
                stopPlaybackConnection()
                stopMovement()
                return
            end
        end

        local aIndex, bIndex, alpha =
            findNextPoint(elapsed)

        local a = Route[aIndex]
        local b = Route[bIndex]

        if not a or not b then
            return
        end

        local targetA = getRoutePosition(a)
        local targetB = getRoutePosition(b)

        local target =
            getInterpolatedPosition(
                targetA,
                targetB,
                alpha
            )

        local current = ROOT.Position

        local horizontalTarget = Vector3.new(
            target.X,
            current.Y,
            target.Z
        )

        local difference =
            horizontalTarget - current

        local distance = difference.Magnitude

        if distance > 0.05 then
            local direction = difference.Unit

            HUMANOID.WalkSpeed = PlaybackSpeed

            HUMANOID:Move(
                direction,
                false
            )

            if ShiftEnabled then
                local lookPosition =
                    Vector3.new(
                        target.X,
                        current.Y,
                        target.Z
                    )

                if (lookPosition - current).Magnitude > 0.1 then
                    ROOT.CFrame = CFrame.lookAt(
                        current,
                        lookPosition
                    )
                end
            end
        else
            HUMANOID:Move(
                Vector3.zero,
                false
            )
        end

        if JumpEnabled then
            if a.jump or b.jump then
                HUMANOID.Jump = true
            end
        end

        local movedDistance =
            (ROOT.Position - LastMovePosition).Magnitude

        if movedDistance < STUCK_DISTANCE
            and distance > WAYPOINT_REACH then

            StuckTime += delta

            if StuckTime >= STUCK_TIME then
                HUMANOID.Jump = true

                local recovery =
                    math.min(
                        aIndex + LOOK_AHEAD,
                        #Route
                    )

                PlaybackIndex = recovery
                StuckTime = 0
            end
        else
            StuckTime = 0
        end

        LastMovePosition = ROOT.Position
    end)
end

local function setPathVisibility(enabled)
    PathEnabled = enabled

    if enabled then
        drawRoute()
    else
        clearPath()
    end
end

local function setLoop(enabled)
    LoopEnabled = enabled
end

local function setJump(enabled)
    JumpEnabled = enabled
end

local function setShift(enabled)
    ShiftEnabled = enabled
end

local function setSpeed(value)
    PlaybackSpeed = math.clamp(
        value,
        MIN_SPEED,
        MAX_SPEED
    )
end

local function changeSpeed(amount)
    setSpeed(PlaybackSpeed + amount)
end

local function changeOffset(amount)
    HorizontalOffset += amount
end

pcall(function()
    local old = CoreGui:FindFirstChild(GUI_NAME)

    if old then
        old:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentOK = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not parentOK or not ScreenGui.Parent then
    ScreenGui.Parent =
        Player:WaitForChild("PlayerGui")
end

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "Open"
OpenButton.Size = UDim2.fromOffset(52, 52)
OpenButton.Position = UDim2.new(
    0,
    18,
    0.5,
    -26
)
OpenButton.BackgroundColor3 =
    Color3.fromRGB(25, 25, 30)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "AW"
OpenButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)
OpenButton.Font =
    Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color =
    Color3.fromRGB(255, 35, 180)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(430, 430)
Main.Position = UDim2.new(
    0.5,
    -215,
    0.5,
    -215
)
Main.BackgroundColor3 =
    Color3.fromRGB(22, 10, 13)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius =
    UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color =
    Color3.fromRGB(90, 255, 100)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(
    1,
    0,
    0,
    48
)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(
    1,
    -60,
    1,
    0
)
Title.Position =
    UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "AUTO WALK"
Title.TextColor3 =
    Color3.fromRGB(255, 255, 255)
Title.Font =
    Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment =
    Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size =
    UDim2.fromOffset(34, 34)
Close.Position =
    UDim2.new(1, -43, 0, 7)
Close.BackgroundColor3 =
    Color3.fromRGB(145, 40, 40)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 =
    Color3.fromRGB(255, 255, 255)
Close.Font =
    Enum.Font.GothamBold
Close.TextSize = 20
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius =
    UDim.new(1, 0)
CloseCorner.Parent = Close

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(
    1,
    -28,
    0,
    24
)
Status.Position =
    UDim2.fromOffset(14, 47)
Status.BackgroundTransparency = 1
Status.Text = "READY"
Status.TextColor3 =
    Color3.fromRGB(170, 170, 170)
Status.Font =
    Enum.Font.Gotham
Status.TextSize = 10
Status.TextXAlignment =
    Enum.TextXAlignment.Left
Status.Parent = Main

local List = Instance.new("ScrollingFrame")
List.Name = "Routes"
List.Size = UDim2.new(
    0.53,
    -10,
    1,
    -82
)
List.Position =
    UDim2.fromOffset(8, 72)
List.BackgroundColor3 =
    Color3.fromRGB(30, 12, 16)
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.CanvasSize =
    UDim2.fromOffset(0, 0)
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius =
    UDim.new(0, 9)
ListCorner.Parent = List

local Layout = Instance.new("UIListLayout")
Layout.Padding =
    UDim.new(0, 5)
Layout.Parent = List

local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(
    0.47,
    -10,
    1,
    -82
)
Controls.Position =
    UDim2.new(
        0.53,
        2,
        0,
        72
    )
Controls.BackgroundColor3 =
    Color3.fromRGB(37, 10, 14)
Controls.BorderSizePixel = 0
Controls.Parent = Main

local ControlsCorner = Instance.new("UICorner")
ControlsCorner.CornerRadius =
    UDim.new(0, 9)
ControlsCorner.Parent = Controls

local function createControl(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(
        1,
        -12,
        0,
        34
    )
    button.Position =
        UDim2.fromOffset(6, y)
    button.BackgroundColor3 =
        Color3.fromRGB(55, 20, 25)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 =
        Color3.fromRGB(245, 245, 245)
    button.Font =
        Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = Controls

    local c = Instance.new("UICorner")
    c.CornerRadius =
        UDim.new(0, 7)
    c.Parent = button

    return button
end

local RecordButton =
    createControl("RECORD", 8)

local StopButton =
    createControl("STOP ALL", 47)

local LoopButton =
    createControl("LOOP OFF", 86)

local RespawnButton =
    createControl("RESPAWN OFF", 125)

local JumpButton =
    createControl("JUMP OFF", 164)

local PathButton =
    createControl("PATH ON", 203)

local ShiftButton =
    createControl("SHIFT OFF", 242)

local OffsetMinus =
    createControl("H-OFFSET -", 281)

local OffsetPlus =
    createControl("H-OFFSET +", 320)

local SpeedMinus =
    createControl("SPEED -", 359)

local SpeedPlus =
    createControl("SPEED +", 398)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size =
    UDim2.new(
        1,
        -12,
        0,
        22
    )
SpeedLabel.Position =
    UDim2.fromOffset(6, 436)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 =
    Color3.fromRGB(180, 180, 180)
SpeedLabel.Font =
    Enum.Font.Gotham
SpeedLabel.TextSize = 9
SpeedLabel.Text =
    "SPEED: 16"
SpeedLabel.Parent = Controls

local BackButton =
    createControl("BK", 463)

local function updateSpeedLabel()
    SpeedLabel.Text =
        "SPEED: "
        .. tostring(PlaybackSpeed)
        .. "  H: "
        .. tostring(HorizontalOffset)
end

local function updateStatus(text)
    Status.Text = text
end

local function rebuildRouteList()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton")
            or child:IsA("Frame") then

            child:Destroy()
        end
    end

    for _, name in ipairs(SavedRoutes) do
        local row = Instance.new("Frame")
        row.Size =
            UDim2.new(1, -8, 0, 38)
        row.BackgroundColor3 =
            Color3.fromRGB(48, 16, 21)
        row.BorderSizePixel = 0
        row.Parent = List

        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius =
            UDim.new(0, 6)
        rowCorner.Parent = row

        local loadButton = Instance.new("TextButton")
        loadButton.Size =
            UDim2.new(1, -38, 1, 0)
        loadButton.BackgroundTransparency = 1
        loadButton.Text =
            name
        loadButton.TextColor3 =
            Color3.fromRGB(235, 235, 235)
        loadButton.Font =
            Enum.Font.Gotham
        loadButton.TextSize = 10
        loadButton.TextXAlignment =
            Enum.TextXAlignment.Left
        loadButton.Parent = row

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft =
            UDim.new(0, 8)
        padding.Parent = loadButton

        local deleteButton =
            Instance.new("TextButton")

        deleteButton.Size =
            UDim2.fromOffset(34, 30)
        deleteButton.Position =
            UDim2.new(
                1,
                -36,
                0,
                4
            )
        deleteButton.BackgroundColor3 =
            Color3.fromRGB(125, 35, 40)
        deleteButton.BorderSizePixel = 0
        deleteButton.Text = "DEL"
        deleteButton.TextColor3 =
            Color3.fromRGB(255, 255, 255)
        deleteButton.Font =
            Enum.Font.GothamBold
        deleteButton.TextSize = 8
        deleteButton.Parent = row

        local deleteCorner =
            Instance.new("UICorner")

        deleteCorner.CornerRadius =
            UDim.new(0, 5)
        deleteCorner.Parent =
            deleteButton

        loadButton.Activated:Connect(function()
            local ok, message =
                loadRoute(name)

            if ok then
                drawRoute()
                updateStatus(
                    "LOADED: "
                    .. name
                )
            else
                updateStatus(message)
            end
        end)

        deleteButton.Activated:Connect(function()
            deleteRoute(name)
            rebuildRouteList()
            updateStatus(
                "DELETED: "
                .. name
            )
        end)
    end

    task.defer(function()
        List.CanvasSize =
            UDim2.fromOffset(
                0,
                Layout.AbsoluteContentSize.Y
                    + 8
            )
    end)
end

RecordButton.Activated:Connect(function()
    if Recording then
        finishRecording()

        updateStatus(
            "RECORDED: "
            .. tostring(#Route)
            .. " POINTS"
        )
    else
        beginRecording()

        updateStatus(
            "RECORDING..."
        )
    end
end)

StopButton.Activated:Connect(function()
    stopAll()
    updateStatus("STOPPED")
end)

LoopButton.Activated:Connect(function()
    LoopEnabled = not LoopEnabled

    LoopButton.Text =
        LoopEnabled
        and "LOOP ON"
        or "LOOP OFF"
end)

RespawnButton.Activated:Connect(function()
    RespawnEnabled =
        not RespawnEnabled

    RespawnButton.Text =
        RespawnEnabled
        and "RESPAWN ON"
        or "RESPAWN OFF"
end)

JumpButton.Activated:Connect(function()
    JumpEnabled =
        not JumpEnabled

    JumpButton.Text =
        JumpEnabled
        and "JUMP ON"
        or "JUMP OFF"
end)

PathButton.Activated:Connect(function()
    setPathVisibility(
        not PathEnabled
    )

    PathButton.Text =
        PathEnabled
        and "PATH ON"
        or "PATH OFF"
end)

ShiftButton.Activated:Connect(function()
    ShiftEnabled =
        not ShiftEnabled

    ShiftButton.Text =
        ShiftEnabled
        and "SHIFT ON"
        or "SHIFT OFF"
end)

OffsetMinus.Activated:Connect(function()
    changeOffset(-1)
    updateSpeedLabel()
end)

OffsetPlus.Activated:Connect(function()
    changeOffset(1)
    updateSpeedLabel()
end)

SpeedMinus.Activated:Connect(function()
    changeSpeed(-2)
    updateSpeedLabel()
end)

SpeedPlus.Activated:Connect(function()
    changeSpeed(2)
    updateSpeedLabel()
end)

BackButton.Activated:Connect(function()
    Playing = false
    stopPlaybackConnection()
    stopMovement()

    updateStatus("READY")
end)

OpenButton.Activated:Connect(function()
    Main.Visible = not Main.Visible
end)

Close.Activated:Connect(function()
    Main.Visible = false
end)

local function saveCurrentRoute()
    if #Route < 2 then
        updateStatus("NO ROUTE")
        return
    end

    local name =
        RouteName

    if not name or name == "" then
        name =
            "Route_"
            .. os.date("%Y%m%d_%H%M%S")
    end

    local ok, message =
        saveRoute(name)

    updateStatus(message)

    rebuildRouteList()
end

local SaveRoute = Instance.new("TextButton")
SaveRoute.Size =
    UDim2.fromOffset(90, 30)
SaveRoute.Position =
    UDim2.new(
        1,
        -100,
        0,
        10
    )
SaveRoute.BackgroundColor3 =
    Color3.fromRGB(40, 100, 55)
SaveRoute.BorderSizePixel = 0
SaveRoute.Text = "SAVE"
SaveRoute.TextColor3 =
    Color3.fromRGB(255, 255, 255)
SaveRoute.Font =
    Enum.Font.GothamBold
SaveRoute.TextSize = 9
SaveRoute.Parent = Main

local SaveCorner =
    Instance.new("UICorner")

SaveCorner.CornerRadius =
    UDim.new(0, 6)

SaveCorner.Parent =
    SaveRoute

SaveRoute.Activated:Connect(
    saveCurrentRoute
)

local PlayRoute = Instance.new("TextButton")
PlayRoute.Size =
    UDim2.fromOffset(90, 30)
PlayRoute.Position =
    UDim2.new(
        1,
        -198,
        0,
        10
    )
PlayRoute.BackgroundColor3 =
    Color3.fromRGB(45, 90, 145)
PlayRoute.BorderSizePixel = 0
PlayRoute.Text = "PLAY"
PlayRoute.TextColor3 =
    Color3.fromRGB(255, 255, 255)
PlayRoute.Font =
    Enum.Font.GothamBold
PlayRoute.TextSize = 9
PlayRoute.Parent = Main

local PlayCorner =
    Instance.new("UICorner")

PlayCorner.CornerRadius =
    UDim.new(0, 6)

PlayCorner.Parent =
    PlayRoute

PlayRoute.Activated:Connect(
    function()
        if Playing then
            Playing = false
            stopPlaybackConnection()
            stopMovement()
            updateStatus("STOPPED")
        else
            startPlayback()
            updateStatus("PLAYING")
        end
    end
)

local draggingOpen = false
local openDragStart
local openStartPosition

OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        draggingOpen = true
        openDragStart = input.Position
        openStartPosition =
            OpenButton.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then

                draggingOpen = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(
    function(input)
        if not draggingOpen then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.Touch
            and input.UserInputType ~=
            Enum.UserInputType.MouseMovement then

            return
        end

        local delta =
            input.Position
            - openDragStart

        OpenButton.Position =
            UDim2.new(
                openStartPosition.X.Scale,
                openStartPosition.X.Offset
                    + delta.X,
                openStartPosition.Y.Scale,
                openStartPosition.Y.Offset
                    + delta.Y
            )
    end
)

local draggingMain = false
local mainDragStart
local mainStartPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        draggingMain = true
        mainDragStart = input.Position
        mainStartPosition =
            Main.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then

                draggingMain = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(
    function(input)
        if not draggingMain then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.Touch
            and input.UserInputType ~=
            Enum.UserInputType.MouseMovement then

            return
        end

        local delta =
            input.Position
            - mainDragStart

        Main.Position =
            UDim2.new(
                mainStartPosition.X.Scale,
                mainStartPosition.X.Offset
                    + delta.X,
                mainStartPosition.Y.Scale,
                mainStartPosition.Y.Offset
                    + delta.Y
            )
    end
)

CharacterConnection =
    Player.CharacterAdded:Connect(
        function()
            task.wait(0.5)

            refreshCharacter()

            if RespawnEnabled
                and Playing
                and #Route >= 2 then

                task.wait(0.3)

                PlaybackStartPosition =
                    ROOT.Position

                PlaybackIndex = 1
            end
        end
    )

rebuildRouteList()
updateSpeedLabel()
updateStatus("READY")
