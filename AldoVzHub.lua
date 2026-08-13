-- AUTO WALK ROUTE RECORDER
-- Mobile / Delta Executor
-- Record -> Save -> Replay route

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "DeltaAutoWalkRecorder"
local SAVE_FILE = "DeltaAutoWalkRoutes.json"

local Character
local Humanoid
local Root

local function refreshCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end

refreshCharacter()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshCharacter()
end)

pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end
end)

local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(245, 350)
Main.Position = UDim2.new(0, 20, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(90, 90, 110)
Stroke.Transparency = 0.25
Stroke.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -20, 0, 40)
Header.Position = UDim2.fromOffset(10, 4)
Header.BackgroundTransparency = 1
Header.Text = "AUTO WALK"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 24)
Status.Position = UDim2.fromOffset(10, 40)
Status.BackgroundTransparency = 1
Status.Text = "READY"
Status.TextColor3 = Color3.fromRGB(170, 170, 180)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local function makeButton(text, y, color)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 36)
    Button.Position = UDim2.fromOffset(10, y)
    Button.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.AutoButtonColor = true
    Button.Parent = Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    return Button
end

local RecordButton = makeButton(
    "RECORD",
    72,
    Color3.fromRGB(170, 45, 55)
)

local PlayButton = makeButton(
    "PLAY ROUTE",
    114,
    Color3.fromRGB(40, 110, 70)
)

local StopButton = makeButton(
    "STOP ALL",
    156,
    Color3.fromRGB(120, 45, 45)
)

local JumpButton = makeButton(
    "JUMP: OFF",
    198,
    Color3.fromRGB(45, 45, 55)
)

local SpeedMinus = makeButton(
    "SPEED -",
    240,
    Color3.fromRGB(45, 45, 55)
)

local SpeedPlus = makeButton(
    "SPEED +",
    282,
    Color3.fromRGB(45, 45, 55)
)

local SaveButton = makeButton(
    "SAVE ROUTE",
    324,
    Color3.fromRGB(45, 75, 120)
)

local route = {}
local recording = false
local playing = false
local jumpEnabled = false
local speed = 16

local recordConnection
local playConnection

local pathFolder = Instance.new("Folder")
pathFolder.Name = "DeltaAutoWalkPath"
pathFolder.Parent = workspace

local pathParts = {}

local function clearVisualPath()
    for _, v in ipairs(pathParts) do
        if v and v.Parent then
            v:Destroy()
        end
    end

    table.clear(pathParts)
end

local function createPathPoint(position)
    local part = Instance.new("Part")
    part.Name = "RoutePoint"
    part.Size = Vector3.new(0.18, 0.18, 0.18)
    part.Shape = Enum.PartType.Ball
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 40, 130)
    part.Transparency = 0.15
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Position = position
    part.Parent = pathFolder

    table.insert(pathParts, part)
end

local function createSegment(a, b)
    local distance = (b - a).Magnitude

    if distance < 0.05 then
        return
    end

    local part = Instance.new("Part")
    part.Name = "RouteSegment"
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 45, 125)
    part.Transparency = 0.18
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false

    part.Size = Vector3.new(0.08, 0.08, distance)
    part.CFrame = CFrame.lookAt((a + b) / 2, b)
    part.Parent = pathFolder

    table.insert(pathParts, part)
end

local function drawRoute()
    clearVisualPath()

    for i = 1, #route do
        createPathPoint(route[i].position)

        if i > 1 then
            createSegment(
                route[i - 1].position,
                route[i].position
            )
        end
    end
end

local function stopEverything()
    recording = false
    playing = false

    if recordConnection then
        recordConnection:Disconnect()
        recordConnection = nil
    end

    if playConnection then
        playConnection:Disconnect()
        playConnection = nil
    end

    if Humanoid then
        Humanoid:Move(Vector3.zero, false)
    end

    Status.Text = "STOPPED"
end

local function startRecording()
    stopEverything()

    refreshCharacter()

    table.clear(route)
    clearVisualPath()

    recording = true

    Status.Text = "RECORDING..."

    local lastPosition = Root.Position
    local lastRecord = 0

    recordConnection = RunService.Heartbeat:Connect(function()
        if not recording then
            return
        end

        if not Root or not Root.Parent then
            return
        end

        local now = os.clock()

        if now - lastRecord < 0.08 then
            return
        end

        lastRecord = now

        local position = Root.Position

        if (position - lastPosition).Magnitude >= 0.18 then

            local state = Humanoid:GetState()

            table.insert(route, {
                x = position.X,
                y = position.Y,
                z = position.Z,
                jump =
                    state == Enum.HumanoidStateType.Jumping
                    or state == Enum.HumanoidStateType.Freefall
            })

            createPathPoint(position)

            if #route > 1 then
                createSegment(
                    Vector3.new(
                        route[#route - 1].x,
                        route[#route - 1].y,
                        route[#route - 1].z
                    ),
                    position
                )
            end

            lastPosition = position
        end
    end)
end

local function finishRecording()
    if not recording then
        return
    end

    recording = false

    if recordConnection then
        recordConnection:Disconnect()
        recordConnection = nil
    end

    Status.Text = "RECORDED: " .. tostring(#route) .. " POINTS"
end

local function startPlayback()
    if playing then
        return
    end

    if #route < 2 then
        Status.Text = "NO ROUTE"
        return
    end

    refreshCharacter()

    if recordConnection then
        recordConnection:Disconnect()
        recordConnection = nil
    end

    playing = true

    Status.Text = "PLAYING..."

    local index = 1
    local targetReachDistance = 1.25
    local jumpCooldown = 0

    playConnection = RunService.Heartbeat:Connect(function(dt)

        if not playing then
            return
        end

        if not Character
            or not Character.Parent
            or not Humanoid
            or Humanoid.Health <= 0
            or not Root
            or not Root.Parent then

            stopEverything()
            return
        end

        if index > #route then
            playing = false

            if playConnection then
                playConnection:Disconnect()
                playConnection = nil
            end

            Humanoid:Move(Vector3.zero, false)

            Status.Text = "ROUTE COMPLETE"
            return
        end

        local data = route[index]

        local target = Vector3.new(
            data.x,
            data.y,
            data.z
        )

        local current = Root.Position

        local horizontalCurrent = Vector3.new(
            current.X,
            0,
            current.Z
        )

        local horizontalTarget = Vector3.new(
            target.X,
            0,
            target.Z
        )

        local offset = horizontalTarget - horizontalCurrent
        local distance = offset.Magnitude

        if distance <= targetReachDistance then
            index += 1
            return
        end

        local direction = offset.Unit

        Humanoid.WalkSpeed = speed
        Humanoid:Move(direction, false)

        jumpCooldown -= dt

        if jumpEnabled and data.jump and jumpCooldown <= 0 then
            Humanoid.Jump = true
            jumpCooldown = 0.45
        end
    end)
end

local function saveRoute()
    if #route < 2 then
        Status.Text = "NOTHING TO SAVE"
        return
    end

    if not writefile then
        Status.Text = "WRITEFILE UNAVAILABLE"
        return
    end

    local success = pcall(function()
        writefile(
            SAVE_FILE,
            HttpService:JSONEncode(route)
        )
    end)

    if success then
        Status.Text = "ROUTE SAVED"
    else
        Status.Text = "SAVE FAILED"
    end
end

local function loadRoute()
    if not isfile or not readfile then
        return false
    end

    if not isfile(SAVE_FILE) then
        return false
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(
            readfile(SAVE_FILE)
        )
    end)

    if not success or type(data) ~= "table" then
        return false
    end

    table.clear(route)

    for _, point in ipairs(data) do
        if type(point) == "table"
            and tonumber(point.x)
            and tonumber(point.y)
            and tonumber(point.z) then

            table.insert(route, {
                x = tonumber(point.x),
                y = tonumber(point.y),
                z = tonumber(point.z),
                jump = point.jump == true
            })
        end
    end

    drawRoute()

    Status.Text = "LOADED: " .. tostring(#route) .. " POINTS"

    return true
end

RecordButton.Activated:Connect(function()
    if recording then
        finishRecording()
    else
        startRecording()
    end
end)

PlayButton.Activated:Connect(function()
    if playing then
        stopEverything()
    else
        startPlayback()
    end
end)

StopButton.Activated:Connect(function()
    stopEverything()
end)

JumpButton.Activated:Connect(function()
    jumpEnabled = not jumpEnabled

    if jumpEnabled then
        JumpButton.Text = "JUMP: ON"
        JumpButton.BackgroundColor3 = Color3.fromRGB(45, 120, 75)
    else
        JumpButton.Text = "JUMP: OFF"
        JumpButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

SpeedMinus.Activated:Connect(function()
    speed = math.clamp(speed - 2, 4, 100)
    Status.Text = "SPEED: " .. tostring(speed)
end)

SpeedPlus.Activated:Connect(function()
    speed = math.clamp(speed + 2, 4, 100)
    Status.Text = "SPEED: " .. tostring(speed)
end)

SaveButton.Activated:Connect(function()
    saveRoute()
end)

loadRoute()

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)
