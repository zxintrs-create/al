local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local GUI_NAME = "DeltaAutoWalk_Final"
local FILE_NAME = "DeltaAutoWalk_Routes.json"

local SAMPLE_INTERVAL = 0.035
local MIN_RECORD_DISTANCE = 0.08
local MAX_ROUTE_POINTS = 15000

local DEFAULT_SPEED = 16
local MIN_SPEED = 2
local MAX_SPEED = 100

local WAYPOINT_DISTANCE = 1.15
local STUCK_DISTANCE = 0.35
local STUCK_DELAY = 1.25
local RECOVERY_DISTANCE = 3

local Character
local Humanoid
local Root

local Recording = false
local Playing = false

local LoopEnabled = false
local RespawnEnabled = true
local JumpEnabled = true
local PathEnabled = true
local ShiftEnabled = false

local PlaybackSpeed = DEFAULT_SPEED
local HorizontalOffset = 0

local Route = {}
local Routes = {}
local CurrentRouteName = nil

local RecordConnection
local PlaybackConnection
local CharacterConnection

local PathFolder

local function getGuiParent()
    local parent

    pcall(function()
        parent = game:GetService("CoreGui")
    end)

    if parent then
        return parent
    end

    return Player:WaitForChild("PlayerGui")
end

local function removeOldGui()
    local parent = getGuiParent()
    local old = parent:FindFirstChild(GUI_NAME)

    if old then
        old:Destroy()
    end
end

removeOldGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = getGuiParent()

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(54, 54)
OpenButton.Position = UDim2.new(0, 18, 0.5, -27)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "AW"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.AutoButtonColor = true
OpenButton.ZIndex = 100
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(255, 40, 180)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(440, 500)
Main.Position = UDim2.new(0.5, -220, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 40, 180)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "AUTO WALK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -140, 0, 18)
Status.Position = UDim2.new(0, 14, 1, -21)
Status.BackgroundTransparency = 1
Status.Text = "READY"
Status.TextColor3 = Color3.fromRGB(160, 160, 170)
Status.Font = Enum.Font.Gotham
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(34, 34)
CloseButton.Position = UDim2.new(1, -43, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(120, 35, 42)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 21
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

local Left = Instance.new("Frame")
Left.Size = UDim2.new(0.52, -12, 1, -66)
Left.Position = UDim2.fromOffset(8, 58)
Left.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
Left.BorderSizePixel = 0
Left.Parent = Main

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 9)
LeftCorner.Parent = Left

local Right = Instance.new("Frame")
Right.Size = UDim2.new(0.48, -12, 1, -66)
Right.Position = UDim2.new(0.52, 4, 0, 58)
Right.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
Right.BorderSizePixel = 0
Right.Parent = Main

local RightCorner = Instance.new("UICorner")
RightCorner.CornerRadius = UDim.new(0, 9)
RightCorner.Parent = Right

local RouteTitle = Instance.new("TextLabel")
RouteTitle.Size = UDim2.new(1, -16, 0, 28)
RouteTitle.Position = UDim2.fromOffset(8, 5)
RouteTitle.BackgroundTransparency = 1
RouteTitle.Text = "ROUTES"
RouteTitle.TextColor3 = Color3.fromRGB(220, 220, 225)
RouteTitle.Font = Enum.Font.GothamBold
RouteTitle.TextSize = 11
RouteTitle.TextXAlignment = Enum.TextXAlignment.Left
RouteTitle.Parent = Left

local RouteList = Instance.new("ScrollingFrame")
RouteList.Size = UDim2.new(1, -12, 1, -42)
RouteList.Position = UDim2.fromOffset(6, 36)
RouteList.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
RouteList.BorderSizePixel = 0
RouteList.ScrollBarThickness = 3
RouteList.CanvasSize = UDim2.fromOffset(0, 0)
RouteList.Parent = Left

local RouteLayout = Instance.new("UIListLayout")
RouteLayout.Padding = UDim.new(0, 5)
RouteLayout.Parent = RouteList

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -14, 0, 34)
    button.Position = UDim2.fromOffset(7, y)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(245, 245, 245)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 9
    button.Parent = Right

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    return button
end

local RecordButton = makeButton("RECORD", 10)
local PlayButton = makeButton("PLAY", 49)
local StopButton = makeButton("STOP", 88)
local LoopButton = makeButton("LOOP : OFF", 127)
local RespawnButton = makeButton("RESPAWN : ON", 166)
local JumpButton = makeButton("JUMP : ON", 205)
local PathButton = makeButton("PATH : ON", 244)
local ShiftButton = makeButton("SHIFT : OFF", 283)
local OffsetMinus = makeButton("H-OFFSET  -", 322)
local OffsetPlus = makeButton("H-OFFSET  +", 361)
local SpeedMinus = makeButton("SPEED  -", 400)
local SpeedPlus = makeButton("SPEED  +", 439)

local SpeedInfo = Instance.new("TextLabel")
SpeedInfo.Size = UDim2.new(1, -14, 0, 30)
SpeedInfo.Position = UDim2.fromOffset(7, 476)
SpeedInfo.BackgroundTransparency = 1
SpeedInfo.Text = "SPEED 16   OFFSET 0"
SpeedInfo.TextColor3 = Color3.fromRGB(170, 170, 180)
SpeedInfo.Font = Enum.Font.Gotham
SpeedInfo.TextSize = 9
SpeedInfo.Parent = Right

local function setStatus(text)
    Status.Text = text
end

local function updateInfo()
    SpeedInfo.Text =
        "SPEED "
        .. tostring(PlaybackSpeed)
        .. "   OFFSET "
        .. string.format("%.1f", HorizontalOffset)
end

local function refreshCharacter()
    Character = Player.Character

    if not Character then
        return false
    end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    Root = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return false
    end

    return Humanoid.Health > 0
end

refreshCharacter()

local function stopRecord()
    if RecordConnection then
        RecordConnection:Disconnect()
        RecordConnection = nil
    end
end

local function stopPlayback()
    if PlaybackConnection then
        PlaybackConnection:Disconnect()
        PlaybackConnection = nil
    end
end

local function stopMovement()
    if Humanoid and Humanoid.Parent then
        Humanoid:Move(Vector3.zero, false)
    end
end

local function clearPath()
    if PathFolder then
        PathFolder:Destroy()
        PathFolder = nil
    end
end

local function ensurePathFolder()
    if not PathEnabled then
        return
    end

    if PathFolder and PathFolder.Parent then
        return
    end

    PathFolder = Instance.new("Folder")
    PathFolder.Name = "DeltaAutoWalkPath"
    PathFolder.Parent = workspace
end

local function makePathSegment(a, b)
    if not PathEnabled then
        return
    end

    ensurePathFolder()

    local difference = b - a
    local length = difference.Magnitude

    if length < 0.05 then
        return
    end

    local segment = Instance.new("Part")
    segment.Anchored = true
    segment.CanCollide = false
    segment.CanTouch = false
    segment.CanQuery = false
    segment.CastShadow = false
    segment.Material = Enum.Material.Neon
    segment.Color = Color3.fromRGB(255, 35, 180)
    segment.Size = Vector3.new(0.07, 0.07, length)
    segment.CFrame = CFrame.lookAt((a + b) / 2, b)
    segment.Parent = PathFolder
end

local function drawPath()
    clearPath()

    if not PathEnabled then
        return
    end

    ensurePathFolder()

    local previous

    local step = 1

    if #Route > 400 then
        step = math.ceil(#Route / 400)
    end

    for index = 1, #Route, step do
        local point = Route[index]

        local position = Vector3.new(
            point.x,
            point.y,
            point.z
        )

        if previous then
            makePathSegment(previous, position)
        end

        previous = position
    end
end

local function getHeading(cframe)
    local look = cframe.LookVector

    return math.atan2(
        -look.X,
        -look.Z
    )
end

local function getState()
    if not Humanoid then
        return false, false, false
    end

    local state = Humanoid:GetState()

    return
        state == Enum.HumanoidStateType.Jumping,
        state == Enum.HumanoidStateType.Freefall,
        state == Enum.HumanoidStateType.Seated
end

local function beginRecording()
    if Recording then
        return
    end

    if not refreshCharacter() then
        setStatus("CHARACTER NOT READY")
        return
    end

    if Playing then
        Playing = false
        stopPlayback()
        stopMovement()
    end

    Route = {}
    CurrentRouteName = nil

    local startPosition = Root.Position
    local startTime = os.clock()

    table.insert(Route, {
        x = 0,
        y = 0,
        z = 0,
        yaw = getHeading(Root.CFrame),
        t = 0,
        jump = false,
        freefall = false,
        seated = false
    })

    clearPath()

    if PathEnabled then
        ensurePathFolder()
    end

    Recording = true

    local lastPosition = startPosition
    local lastSample = startTime

    RecordConnection = RunService.Heartbeat:Connect(function()
        if not Recording then
            return
        end

        if not Root
            or not Root.Parent
            or not Humanoid
            or Humanoid.Health <= 0 then
            return
        end

        local now = os.clock()

        if now - lastSample < SAMPLE_INTERVAL then
            return
        end

        lastSample = now

        local position = Root.Position

        if (position - lastPosition).Magnitude < MIN_RECORD_DISTANCE then
            return
        end

        if #Route >= MAX_ROUTE_POINTS then
            Recording = false
            stopRecord()
            setStatus("MAX ROUTE SIZE")
            return
        end

        local relative = position - startPosition
        local jump, freefall, seated = getState()

        local point = {
            x = relative.X,
            y = relative.Y,
            z = relative.Z,
            yaw = getHeading(Root.CFrame),
            t = now - startTime,
            jump = jump,
            freefall = freefall,
            seated = seated
        }

        table.insert(Route, point)

        if PathEnabled then
            makePathSegment(
                lastPosition,
                position
            )
        end

        lastPosition = position

        setStatus(
            "RECORDING  "
            .. tostring(#Route)
            .. " POINTS"
        )
    end)

    setStatus("RECORDING")
end

local function finishRecording()
    if not Recording then
        return
    end

    Recording = false
    stopRecord()

    if #Route < 2 then
        Route = {}
        clearPath()
        setStatus("ROUTE TOO SHORT")
        return
    end

    setStatus(
        "RECORDED "
        .. tostring(#Route)
        .. " POINTS"
    )
end

local function stopAll()
    Recording = false
    Playing = false

    stopRecord()
    stopPlayback()

    stopMovement()

    setStatus("STOPPED")
end

local function getOffsetVector()
    if #Route == 0 then
        return Vector3.zero
    end

    local firstYaw = Route[1].yaw

    local right = Vector3.new(
        math.cos(firstYaw),
        0,
        -math.sin(firstYaw)
    )

    return right * HorizontalOffset
end

local function getRoutePointPosition(point, origin)
    return origin
        + Vector3.new(
            point.x,
            point.y,
            point.z
        )
        + getOffsetVector()
end

local function findRouteSegment(time)
    if #Route < 2 then
        return nil, nil, 0
    end

    local low = 1
    local high = #Route

    while low < high do
        local middle = math.floor(
            (low + high + 1) / 2
        )

        if Route[middle].t <= time then
            low = middle
        else
            high = middle - 1
        end
    end

    local aIndex = low
    local bIndex = math.min(
        low + 1,
        #Route
    )

    local a = Route[aIndex]
    local b = Route[bIndex]

    if aIndex == bIndex then
        return aIndex, bIndex, 0
    end

    local duration = b.t - a.t

    if duration <= 0 then
        return aIndex, bIndex, 0
    end

    local alpha =
        (time - a.t) / duration

    return
        aIndex,
        bIndex,
        math.clamp(alpha, 0, 1)
end

local function interpolate(a, b, alpha)
    return Vector3.new(
        a.X + (b.X - a.X) * alpha,
        a.Y + (b.Y - a.Y) * alpha,
        a.Z + (b.Z - a.Z) * alpha
    )
end

local function startPlayback()
    if Playing then
        return
    end

    if Recording then
        finishRecording()
    end

    if #Route < 2 then
        setStatus("NO ROUTE")
        return
    end

    if not refreshCharacter() then
        setStatus("CHARACTER NOT READY")
        return
    end

    Playing = true

    local origin = Root.Position
    local elapsed = 0
    local lastClock = os.clock()
    local lastPosition = Root.Position
    local stuckTime = 0
    local lastJumpTime = -10

    PlaybackConnection = RunService.Heartbeat:Connect(function()
        if not Playing then
            return
        end

        if not Character
            or not Character.Parent
            or not Humanoid
            or not Root
            or not Root.Parent
            or Humanoid.Health <= 0 then

            return
        end

        local now = os.clock()
        local delta = math.clamp(
            now - lastClock,
            0,
            0.1
        )

        lastClock = now

        local totalTime = Route[#Route].t

        if totalTime <= 0 then
            Playing = false
            stopPlayback()
            stopMovement()
            return
        end

        elapsed +=
            delta
            * (PlaybackSpeed / DEFAULT_SPEED)

        if elapsed >= totalTime then
            if LoopEnabled then
                elapsed = 0
                origin = Root.Position
                lastPosition = Root.Position
                stuckTime = 0
            else
                Playing = false
                stopPlayback()
                stopMovement()
                setStatus("PLAYBACK COMPLETE")
                return
            end
        end

        local aIndex, bIndex, alpha =
            findRouteSegment(elapsed)

        if not aIndex then
            return
        end

        local a = Route[aIndex]
        local b = Route[bIndex]

        local positionA =
            getRoutePointPosition(
                a,
                origin
            )

        local positionB =
            getRoutePointPosition(
                b,
                origin
            )

        local target =
            interpolate(
                positionA,
                positionB,
                alpha
            )

        local current = Root.Position

        local horizontalTarget =
            Vector3.new(
                target.X,
                current.Y,
                target.Z
            )

        local deltaPosition =
            horizontalTarget - current

        local distance =
            deltaPosition.Magnitude

        if distance <= WAYPOINT_DISTANCE then
            Humanoid:Move(
                Vector3.zero,
                false
            )
        else
            local direction =
                deltaPosition.Unit

            Humanoid.WalkSpeed =
                PlaybackSpeed

            Humanoid:Move(
                direction,
                false
            )
        end

        if ShiftEnabled and distance > 0.1 then
            local look =
                Vector3.new(
                    target.X,
                    current.Y,
                    target.Z
                )

            Root.CFrame =
                CFrame.lookAt(
                    current,
                    look
                )
        end

        if JumpEnabled then
            local shouldJump =
                a.jump
                or b.jump

            if shouldJump
                and now - lastJumpTime > 0.35 then

                Humanoid.Jump = true
                lastJumpTime = now
            end
        end

        local moved =
            (Root.Position - lastPosition).Magnitude

        if distance > WAYPOINT_DISTANCE then
            if moved < STUCK_DISTANCE then
                stuckTime += delta
            else
                stuckTime = 0
            end
        else
            stuckTime = 0
        end

        if stuckTime >= STUCK_DELAY then
            Humanoid.Jump = true

            local recoveryDirection =
                deltaPosition.Magnitude > 0
                and deltaPosition.Unit
                or Vector3.zero

            Humanoid:Move(
                recoveryDirection,
                false
            )

            stuckTime = 0
        end

        lastPosition = Root.Position

        setStatus(
            "PLAYING  "
            .. string.format(
                "%.1f",
                math.min(
                    elapsed,
                    totalTime
                )
            )
            .. "/"
            .. string.format(
                "%.1f",
                totalTime
            )
        )
    end)
end

local function setLoop(value)
    LoopEnabled = value

    LoopButton.Text =
        "LOOP : "
        .. (value and "ON" or "OFF")
end

local function setRespawn(value)
    RespawnEnabled = value

    RespawnButton.Text =
        "RESPAWN : "
        .. (value and "ON" or "OFF")
end

local function setJump(value)
    JumpEnabled = value

    JumpButton.Text =
        "JUMP : "
        .. (value and "ON" or "OFF")
end

local function setPath(value)
    PathEnabled = value

    PathButton.Text =
        "PATH : "
        .. (value and "ON" or "OFF")

    if value then
        drawPath()
    else
        clearPath()
    end
end

local function setShift(value)
    ShiftEnabled = value

    ShiftButton.Text =
        "SHIFT : "
        .. (value and "ON" or "OFF")
end

local function changeSpeed(amount)
    PlaybackSpeed = math.clamp(
        PlaybackSpeed + amount,
        MIN_SPEED,
        MAX_SPEED
    )

    updateInfo()
end

local function changeOffset(amount)
    HorizontalOffset =
        math.clamp(
            HorizontalOffset + amount,
            -100,
            100
        )

    updateInfo()

    if PathEnabled and #Route > 0 then
        drawPath()
    end
end

local function getFileData()
    if type(isfile) ~= "function"
        or type(readfile) ~= "function" then
        return {}
    end

    local exists = false

    pcall(function()
        exists = isfile(FILE_NAME)
    end)

    if not exists then
        return {}
    end

    local content

    local ok = pcall(function()
        content = readfile(FILE_NAME)
    end)

    if not ok
        or type(content) ~= "string"
        or content == "" then

        return {}
    end

    local decoded

    local decodeOK = pcall(function()
        decoded =
            HttpService:JSONDecode(content)
    end)

    if not decodeOK
        or type(decoded) ~= "table" then

        return {}
    end

    return decoded
end

local function writeFileData(data)
    if type(writefile) ~= "function" then
        return false
    end

    local encoded

    local ok = pcall(function()
        encoded =
            HttpService:JSONEncode(data)
    end)

    if not ok then
        return false
    end

    return pcall(function()
        writefile(
            FILE_NAME,
            encoded
        )
    end)
end

local function saveRoute(name)
    if #Route < 2 then
        return false, "NO ROUTE"
    end

    name =
        tostring(name or "")

    name =
        name:gsub(
            "[^%w_%-%s]",
            ""
        )

    name =
        name:match("^%s*(.-)%s*$")

    if name == "" then
        name =
            "Route_"
            .. os.date("%Y%m%d_%H%M%S")
    end

    Routes[name] = {
        version = 1,
        points = Route
    }

    CurrentRouteName = name

    local data = getFileData()

    data[name] = Routes[name]

    local fileOK =
        writeFileData(data)

    if fileOK then
        return true,
            "SAVED : " .. name
    end

    if type(writefile) ~= "function" then
        return true,
            "SAVED SESSION : " .. name
    end

    return false, "SAVE FAILED"
end

local function loadRoute(name)
    local routeData = Routes[name]

    if not routeData then
        local data = getFileData()

        routeData = data[name]
    end

    if type(routeData) ~= "table"
        or type(routeData.points) ~= "table" then

        return false,
            "ROUTE NOT FOUND"
    end

    if #routeData.points < 2 then
        return false,
            "ROUTE INVALID"
    end

    Route = {}

    for _, point in ipairs(routeData.points) do
        if type(point) == "table"
            and type(point.x) == "number"
            and type(point.y) == "number"
            and type(point.z) == "number"
            and type(point.t) == "number" then

            table.insert(
                Route,
                {
                    x = point.x,
                    y = point.y,
                    z = point.z,
                    yaw = tonumber(point.yaw) or 0,
                    t = point.t,
                    jump = point.jump == true,
                    freefall =
                        point.freefall == true,
                    seated =
                        point.seated == true
                }
            )
        end
    end

    if #Route < 2 then
        return false,
            "ROUTE INVALID"
    end

    CurrentRouteName = name

    if PathEnabled then
        drawPath()
    end

    return true,
        "LOADED : " .. name
end

local function deleteRoute(name)
    Routes[name] = nil

    local data = getFileData()

    if data[name] ~= nil then
        data[name] = nil
        writeFileData(data)
    end
end

local function getSavedNames()
    local names = {}

    for name in pairs(Routes) do
        table.insert(names, name)
    end

    local data = getFileData()

    for name in pairs(data) do
        if not Routes[name] then
            table.insert(names, name)
        end
    end

    table.sort(names)

    return names
end

local function rebuildRouteList()
    for _, child in ipairs(
        RouteList:GetChildren()
    ) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local names = getSavedNames()

    for _, name in ipairs(names) do
        local row = Instance.new("Frame")
        row.Size =
            UDim2.new(1, -8, 0, 38)
        row.BackgroundColor3 =
            Color3.fromRGB(35, 35, 42)
        row.BorderSizePixel = 0
        row.Parent = RouteList

        local rowCorner =
            Instance.new("UICorner")

        rowCorner.CornerRadius =
            UDim.new(0, 6)

        rowCorner.Parent = row

        local load = Instance.new("TextButton")
        load.Size =
            UDim2.new(1, -42, 1, 0)
        load.BackgroundTransparency = 1
        load.Text = name
        load.TextColor3 =
            Color3.fromRGB(235, 235, 240)
        load.Font =
            Enum.Font.Gotham
        load.TextSize = 9
        load.TextXAlignment =
            Enum.TextXAlignment.Left
        load.Parent = row

        local padding =
            Instance.new("UIPadding")

        padding.PaddingLeft =
            UDim.new(0, 8)

        padding.Parent = load

        local delete =
            Instance.new("TextButton")

        delete.Size =
            UDim2.fromOffset(36, 30)

        delete.Position =
            UDim2.new(
                1,
                -39,
                0,
                4
            )

        delete.BackgroundColor3 =
            Color3.fromRGB(120, 38, 45)

        delete.BorderSizePixel = 0
        delete.Text = "DEL"
        delete.TextColor3 =
            Color3.fromRGB(255, 255, 255)
        delete.Font =
            Enum.Font.GothamBold
        delete.TextSize = 8
        delete.Parent = row

        local deleteCorner =
            Instance.new("UICorner")

        deleteCorner.CornerRadius =
            UDim.new(0, 5)

        deleteCorner.Parent =
            delete

        load.Activated:Connect(function()
            local ok, message =
                loadRoute(name)

            setStatus(message)

            if ok then
                rebuildRouteList()
            end
        end)

        delete.Activated:Connect(function()
            deleteRoute(name)

            setStatus(
                "DELETED : " .. name
            )

            rebuildRouteList()
        end)
    end

    task.defer(function()
        RouteList.CanvasSize =
            UDim2.fromOffset(
                0,
                RouteLayout.AbsoluteContentSize.Y + 8
            )
    end)
end

local SaveButton = Instance.new("TextButton")
SaveButton.Size =
    UDim2.fromOffset(80, 30)
SaveButton.Position =
    UDim2.new(1, -88, 0, 10)
SaveButton.BackgroundColor3 =
    Color3.fromRGB(40, 105, 60)
SaveButton.BorderSizePixel = 0
SaveButton.Text = "SAVE"
SaveButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)
SaveButton.Font =
    Enum.Font.GothamBold
SaveButton.TextSize = 9
SaveButton.Parent = Header

local SaveCorner =
    Instance.new("UICorner")

SaveCorner.CornerRadius =
    UDim.new(0, 6)

SaveCorner.Parent = SaveButton

OpenButton.Activated:Connect(function()
    Main.Visible = not Main.Visible
end)

CloseButton.Activated:Connect(function()
    Main.Visible = false
end)

RecordButton.Activated:Connect(function()
    if Recording then
        finishRecording()
    else
        beginRecording()
    end
end)

PlayButton.Activated:Connect(function()
    if Playing then
        Playing = false
        stopPlayback()
        stopMovement()
        setStatus("STOPPED")
    else
        startPlayback()
    end
end)

StopButton.Activated:Connect(function()
    stopAll()
end)

LoopButton.Activated:Connect(function()
    setLoop(not LoopEnabled)
end)

RespawnButton.Activated:Connect(function()
    setRespawn(not RespawnEnabled)
end)

JumpButton.Activated:Connect(function()
    setJump(not JumpEnabled)
end)

PathButton.Activated:Connect(function()
    setPath(not PathEnabled)
end)

ShiftButton.Activated:Connect(function()
    setShift(not ShiftEnabled)
end)

OffsetMinus.Activated:Connect(function()
    changeOffset(-1)
end)

OffsetPlus.Activated:Connect(function()
    changeOffset(1)
end)

SpeedMinus.Activated:Connect(function()
    changeSpeed(-2)
end)

SpeedPlus.Activated:Connect(function()
    changeSpeed(2)
end)

SaveButton.Activated:Connect(function()
    if #Route < 2 then
        setStatus("NO ROUTE")
        return
    end

    local name =
        CurrentRouteName

    if not name then
        name =
            "Route_"
            .. os.date("%Y%m%d_%H%M%S")
    end

    local ok, message =
        saveRoute(name)

    setStatus(message)

    if ok then
        rebuildRouteList()
    end
end)

local draggingOpen = false
local dragStart
local buttonStart

OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        draggingOpen = true
        dragStart = input.Position
        buttonStart = OpenButton.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then

                draggingOpen = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
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
        input.Position - dragStart

    OpenButton.Position =
        UDim2.new(
            buttonStart.X.Scale,
            buttonStart.X.Offset + delta.X,
            buttonStart.Y.Scale,
            buttonStart.Y.Offset + delta.Y
        )
end)

local draggingMain = false
local mainDragStart
local mainStart

Header.InputBegan:Connect(function(input)
    if input.UserInputType ==
        Enum.UserInputType.Touch
        or input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        draggingMain = true
        mainDragStart = input.Position
        mainStart = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then

                draggingMain = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
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
        input.Position - mainDragStart

    Main.Position =
        UDim2.new(
            mainStart.X.Scale,
            mainStart.X.Offset + delta.X,
            mainStart.Y.Scale,
            mainStart.Y.Offset + delta.Y
        )
end)

CharacterConnection =
    Player.CharacterAdded:Connect(function()
        Character = nil
        Humanoid = nil
        Root = nil

        task.wait(0.4)

        local ready = false

        for _ = 1, 50 do
            if refreshCharacter() then
                ready = true
                break
            end

            task.wait(0.1)
        end

        if not ready then
            setStatus("CHARACTER NOT READY")
            return
        end

        if RespawnEnabled and Playing then
            Playing = false
            stopPlayback()
            stopMovement()

            task.wait(0.2)

            if refreshCharacter() then
                startPlayback()
            end
        end
    end)

updateInfo()
rebuildRouteList()
setStatus("READY")
