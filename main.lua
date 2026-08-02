local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("DeltaAutoWalkGUI") then
    PlayerGui.DeltaAutoWalkGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAutoWalkGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 80)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Delta | Auto-Walk & Recorder"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 450)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Content

local function CreateButton(name, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

local function CreateToggle(name, text)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 24)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle
    circle.Parent = toggleBtn
    
    frame.Parent = Content
    return frame, toggleBtn, circle
end

local ToggleWaypointBtn = CreateButton("ToggleWaypointBtn", "Add Waypoint at Position", Color3.fromRGB(50, 120, 200))
ToggleWaypointBtn.Parent = Content

local ClearWaypointsBtn = CreateButton("ClearWaypointsBtn", "Clear All Waypoints", Color3.fromRGB(180, 50, 50))
ClearWaypointsBtn.Parent = Content

local _, AutoWalkToggle, AutoWalkCircle = CreateToggle("AutoWalkToggle", "Enable Auto-Walk")
local _, LoopToggle, LoopCircle = CreateToggle("LoopToggle", "Loop Waypoints")

local RecordBtn = CreateButton("RecordBtn", "Start Recording Path", Color3.fromRGB(180, 120, 40))
RecordBtn.Parent = Content

local PlaybackBtn = CreateButton("PlaybackBtn", "Play Recorded Path", Color3.fromRGB(40, 150, 80))
PlaybackBtn.Parent = Content

local waypoints = {}
local recordedPath = {}
local isRecording = false
local isPlaying = false
local isAutoWalking = false
local isLooping = false

local function tweenColor(object, property, targetColor)
    TweenService:Create(object, TweenInfo.new(0.2), { [property] = targetColor }):Play()
end

local function setToggleState(state, btn, circle)
    if state then
        tweenColor(btn, "BackgroundColor3", Color3.fromRGB(0, 170, 255))
        TweenService:Create(circle, TweenInfo.new(0.2), { Position = UDim2.new(1, -21, 0.5, -9) }):Play()
    else
        tweenColor(btn, "BackgroundColor3", Color3.fromRGB(60, 60, 60))
        TweenService:Create(circle, TweenInfo.new(0.2), { Position = UDim2.new(0, 3, 0.5, -9) }):Play()
    end
end

ToggleWaypointBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        table.insert(waypoints, pos)
        
        local part = Instance.new("Part")
        part.Size = Vector3.new(1, 1, 1)
        part.Position = pos
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = BrickColor.new("Cyan")
        part.Parent = workspace
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
        mesh.Parent = part
    end
end)

ClearWaypointsBtn.MouseButton1Click:Connect(function()
    waypoints = {}
    isAutoWalking = false
    setToggleState(false, AutoWalkToggle, AutoWalkCircle)
end)

AutoWalkToggle.MouseButton1Click:Connect(function()
    isAutoWalking = not isAutoWalking
    setToggleState(isAutoWalking, AutoWalkToggle, AutoWalkCircle)
    
    if isAutoWalking and #waypoints > 0 then
        task.spawn(function()
            local char = Player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            while isAutoWalking and char and humanoid do
                for _, pos in ipairs(waypoints) do
                    if not isAutoWalking then break end
                    humanoid:MoveTo(pos)
                    
                    local reached = false
                    local conn
                    conn = RunService.Stepped:Connect(function()
                        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                        if (char.HumanoidRootPart.Position - pos).Magnitude < 4 then
                            reached = true
                            conn:Disconnect()
                        end
                    end)
                    
                    while not reached and isAutoWalking do
                        task.wait(0.1)
                    end
                    if conn.Connected then conn:Disconnect() end
                end
                
                if not isLooping then
                    isAutoWalking = false
                    setToggleState(false, AutoWalkToggle, AutoWalkCircle)
                    break
                end
            end
        end)
    end
end)

LoopToggle.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    setToggleState(isLooping, LoopToggle, LoopCircle)
end)

RecordBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        recordedPath = {}
        RecordBtn.Text = "Recording... (Click to Stop)"
        tweenColor(RecordBtn, "BackgroundColor3", Color3.fromRGB(200, 50, 50))
        
        task.spawn(function()
            while isRecording do
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    table.insert(recordedPath, char.HumanoidRootPart.CFrame)
                end
                task.wait(0.2)
            end
        end)
    else
        RecordBtn.Text = "Start Recording Path"
        tweenColor(RecordBtn, "BackgroundColor3", Color3.fromRGB(180, 120, 40))
    end
end)

PlaybackBtn.MouseButton1Click:Connect(function()
    if isPlaying or #recordedPath == 0 then return end
    isPlaying = true
    tweenColor(PlaybackBtn, "BackgroundColor3", Color3.fromRGB(80, 80, 80))
    
    task.spawn(function()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            for _, cf in ipairs(recordedPath) do
                if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                root.CFrame = cf
                task.wait(0.2)
            end
        end
        
        isPlaying = false
        tweenColor(PlaybackBtn, "BackgroundColor3", Color3.fromRGB(40, 150, 80))
    end)
end)

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
