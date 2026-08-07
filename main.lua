-- ====================================================
-- ALDO KNIGHTXORZ
-- Premium Advanced Movement Recorder & Route Playback System
-- CYBER NEON EDITION (NO GHOST / DIRECT CHARACTER CONTROL)
-- ====================================================
print("ALDO KNIGHTXORZ - Initialized")
​local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
​local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)
​-- ====================================================
-- FONDASI AWAL & STATE VARIABLES
-- ====================================================
local isRecording = false
local isPlaying = false
local isPaused = false
local isLooping = false
local autoWalkEnabled = false
local linePathVisible = false
​local recordTimer = 0
local playbackTime = 0
local RECORD_FPS = 60
local RECORD_INTERVAL = 1 / RECORD_FPS
​local recordData = {}
local linePathVisuals = {}
local savedFiles = {} -- Slot 1 sampai 5
local selectedFileSlot = 1
​local renderConnection = nil
local characterAddedConn = nil
​-- ====================================================
-- UTILS & CLEANUP SYSTEM
-- ====================================================
local function deepCopy(original)
local copy = {}
for k, v in pairs(original) do
if type(v) == "table" then
copy[k] = deepCopy(v)
else
copy[k] = v
end
end
return copy
end
​local function clearLinePath()
for _, part in pairs(linePathVisuals) do
if part and part.Parent then
part:Destroy()
end
end
table.clear(linePathVisuals)
end
​local function drawLinePath()
clearLinePath()
if #recordData < 2 then return end
​for i = 1, #recordData - 1, math.max(1, math.floor(#recordData / 100)) do
local p1 = recordData[i].Position
local p2 = recordData[math.min(i + 5, #recordData)].Position
​local distance = (p1 - p2).Magnitude
local part = Instance.new("Part")
part.Name = "PathNode"
part.Size = Vector3.new(0.3, 0.3, distance)
part.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -distance / 2)
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Material = Enum.Material.Neon
part.Color = Color3.fromRGB(0, 255, 255)
part.Transparency = 0.3
part.Parent = workspace
​table.insert(linePathVisuals, part)
end
end
​-- ====================================================
-- CYBER NEON UI SYSTEM (ALDO KNIGHTXORZ)
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXorzRecorder"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
​local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
​-- Cyber Theme Palette
local C_DARK = Color3.fromRGB(10, 10, 18)
local C_CYAN = Color3.fromRGB(0, 255, 255)
local C_PURPLE = Color3.fromRGB(153, 0, 255)
local C_PINK = Color3.fromRGB(255, 0, 127)
​-- Open Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(1, -75, 0.4, 0)
OpenBtn.BackgroundColor3 = C_DARK
OpenBtn.Text = "⚡"
OpenBtn.TextColor3 = C_CYAN
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.Parent = ScreenGui
​Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = C_CYAN
OpenStroke.Thickness = 2.5
​-- Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 360, 0, 540)
MainPanel.Position = UDim2.new(0.5, -180, 0.5, -270)
MainPanel.BackgroundColor3 = C_DARK
MainPanel.Visible = false
MainPanel.ClipsDescendants = true
MainPanel.Parent = ScreenGui
​Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)
local PanelStroke = Instance.new("UIStroke", MainPanel)
PanelStroke.Thickness = 3
local PanelGradient = Instance.new("UIGradient", PanelStroke)
PanelGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, C_CYAN),
ColorSequenceKeypoint.new(0.5, C_PURPLE),
ColorSequenceKeypoint.new(1, C_PINK)
})
​local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "ALDO KNIGHTXORZ"
Title.TextColor3 = C_CYAN
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = MainPanel
​local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -20, 0, 25)
StatusLbl.Position = UDim2.new(0, 10, 0, 38)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: IDLE | Frames: 0"
StatusLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 12
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = MainPanel
​local InfoLbl = Instance.new("TextLabel")
InfoLbl.Size = UDim2.new(1, -20, 0, 22)
InfoLbl.Position = UDim2.new(0, 10, 0, 60)
InfoLbl.BackgroundTransparency = 1
InfoLbl.Text = "Duration: 0.0s | AutoWalk: OFF"
InfoLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLbl.Font = Enum.Font.GothamSemibold
InfoLbl.TextSize = 11
InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
InfoLbl.Parent = MainPanel
​local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -95)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 85)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = C_CYAN
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
ScrollingFrame.Parent = MainPanel
​local Layout = Instance.new("UIGridLayout")
Layout.CellSize = UDim2.new(0.48, 0, 0, 40)
Layout.CellPadding = UDim2.new(0.04, 0, 0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = ScrollingFrame
​local function CreateButton(text, color, order)
local btn = Instance.new("TextButton")
btn.Text = text
btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
btn.TextColor3 = color
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.LayoutOrder = order
btn.AutoButtonColor = false
​Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", btn)
stroke.Color = color
stroke.Thickness = 1.2
​btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color, TextColor3 = C_DARK}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 18, 28), TextColor3 = color}):Play()
end)
​btn.Parent = ScrollingFrame
return btn
end
​-- Controls Integration
local BtnRecord = CreateButton("RECORD", Color3.fromRGB(255, 50, 50), 1)
local BtnStop = CreateButton("STOP", Color3.fromRGB(255, 150, 50), 2)
local BtnPlay = CreateButton("PLAY", C_CYAN, 3)
local BtnPause = CreateButton("PAUSE / RESUME", C_CYAN, 4)
local BtnStopPlay = CreateButton("STOP PLAY", Color3.fromRGB(255, 100, 100), 5)
local BtnLoop = CreateButton("LOOP: OFF", C_PURPLE, 6)
local BtnAutoWalk = CreateButton("AUTO WALK", C_PINK, 7)
local BtnShowLine = CreateButton("SHOW LINE", Color3.fromRGB(100, 255, 200), 8)
local BtnHideLine = CreateButton("HIDE LINE", Color3.fromRGB(255, 100, 200), 9)
local BtnClearLine = CreateButton("CLEAR LINE", Color3.fromRGB(200, 100, 255), 10)
local BtnSaveFile = CreateButton("SAVE FILE", Color3.fromRGB(50, 255, 100), 11)
local BtnLoadFile = CreateButton("LOAD FILE", Color3.fromRGB(50, 255, 100), 12)
local BtnDeleteFile = CreateButton("DELETE FILE", Color3.fromRGB(255, 80, 80), 13)
local BtnClearFile = CreateButton("CLEAR FILE", Color3.fromRGB(255, 150, 50), 14)
​OpenBtn.MouseButton1Click:Connect(function()
MainPanel.Visible = not MainPanel.Visible
end)
​-- Draggable UI Implementation
local dragging, dragInput, dragStart, startPos
MainPanel.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MainPanel.Position
end
end)
MainPanel.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
​local function UpdateUI()
local stat = "IDLE"
if isRecording then stat = "RECORDING" end
if isPlaying and not isPaused then stat = string.format("PLAYING [%.1fs]", playbackTime) end
if isPaused then stat = string.format("PAUSED [%.1fs]", playbackTime) end
​StatusLbl.Text = string.format("Status: %s | Frames: %d", stat, #recordData)
local duration = math.floor((#recordData * RECORD_INTERVAL) * 10) / 10
InfoLbl.Text = string.format("Duration: %.1fs | AutoWalk: %s", duration, autoWalkEnabled and "ON" or "OFF")
BtnLoop.Text = isLooping and "LOOP: ON" or "LOOP: OFF"
end
​-- ====================================================
-- RECORD & PLAYBACK ENGINE (DIRECT CHARACTER MOVEMENT)
-- ====================================================
local function CaptureFrame()
if not RootPart or not Humanoid then return end
table.insert(recordData, {
CFrame = RootPart.CFrame,
Position = RootPart.Position,
Velocity = RootPart.AssemblyLinearVelocity,
State = Humanoid:GetState()
})
end
​local function ApplyPlaybackFrame(frameTime)
if #recordData == 0 or not RootPart or not Humanoid then return end
​local index = math.floor(frameTime / RECORD_INTERVAL) + 1
if index >= #recordData then
if isLooping then
playbackTime = 0
index = 1
else
isPlaying = false
isPaused = false
Humanoid.PlatformStand = false
return
end
end
​local nextIndex = math.min(index + 1, #recordData)
local f1 = recordData[index]
local f2 = recordData[nextIndex]
local alpha = (frameTime % RECORD_INTERVAL) / RECORD_INTERVAL
​if f1 and f2 then
-- Langsung kendalikan karakter asli pemain secara smooth tanpa ghost
Humanoid.PlatformStand = true
RootPart.CFrame = f1.CFrame:Lerp(f2.CFrame, alpha)
RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end
​-- ====================================================
-- RENDER LOOP (MAIN TICK)
-- ====================================================
local function MainLoop(dt)
PanelGradient.Rotation = (PanelGradient.Rotation + 90 * dt) % 360
​-- Auto Walk Real Player Logic
if autoWalkEnabled and Humanoid and Humanoid.Health > 0 and RootPart then
Humanoid:Move(RootPart.CFrame.LookVector, false)
end
​-- Recording Tick
if isRecording then
recordTimer = recordTimer + dt
if recordTimer >= RECORD_INTERVAL then
CaptureFrame()
recordTimer = recordTimer - RECORD_INTERVAL
end
end
​-- Playback Tick
if isPlaying and not isPaused then
playbackTime = playbackTime + dt
ApplyPlaybackFrame(playbackTime)
end
​UpdateUI()
end
​-- ====================================================
-- BUTTON HOOKS & CONTROLS
-- ====================================================
BtnRecord.MouseButton1Click:Connect(function()
if isPlaying then return end
table.clear(recordData)
clearLinePath()
isRecording = true
recordTimer = 0
end)
​BtnStop.MouseButton1Click:Connect(function()
isRecording = false
isPlaying = false
isPaused = false
if Humanoid then Humanoid.PlatformStand = false end
UpdateUI()
end)
​BtnPlay.MouseButton1Click:Connect(function()
if isRecording or #recordData == 0 then return end
isPlaying = true
isPaused = false
playbackTime = 0
end)
​BtnPause.MouseButton1Click:Connect(function()
if isPlaying then
isPaused = not isPaused
if not isPaused and Humanoid then
Humanoid.PlatformStand = true
elseif isPaused and Humanoid then
Humanoid.PlatformStand = false
end
end
end)
​BtnStopPlay.MouseButton1Click:Connect(function()
isPlaying = false
isPaused = false
if Humanoid then Humanoid.PlatformStand = false end
end)
​BtnLoop.MouseButton1Click:Connect(function()
isLooping = not isLooping
UpdateUI()
end)
​BtnAutoWalk.MouseButton1Click:Connect(function()
autoWalkEnabled = not autoWalkEnabled
UpdateUI()
end)
​BtnShowLine.MouseButton1Click:Connect(function()
if #recordData > 0 then
drawLinePath()
linePathVisible = true
end
end)
​BtnHideLine.MouseButton1Click:Connect(function()
clearLinePath()
linePathVisible = false
end)
​BtnClearLine.MouseButton1Click:Connect(function()
clearLinePath()
end)
​-- File Manager Operations (Slot 1 Default)
BtnSaveFile.MouseButton1Click:Connect(function()
if #recordData > 0 then
savedFiles[selectedFileSlot] = deepCopy(recordData)
StatusLbl.Text = "Status: ROUTE SAVED!"
end
end)
​BtnLoadFile.MouseButton1Click:Connect(function()
if savedFiles[selectedFileSlot] and #savedFiles[selectedFileSlot] > 0 then
recordData = deepCopy(savedFiles[selectedFileSlot])
StatusLbl.Text = "Status: ROUTE LOADED!"
if linePathVisible then drawLinePath() end
end
end)
​BtnDeleteFile.MouseButton1Click:Connect(function()
savedFiles[selectedFileSlot] = nil
StatusLbl.Text = "Status: SLOT DELETED!"
end)
​BtnClearFile.MouseButton1Click:Connect(function()
table.clear(recordData)
clearLinePath()
StatusLbl.Text = "Status: DATA CLEARED!"
end)
​-- ====================================================
-- CHARACTER RESPAWN REBINDING
-- ====================================================
local function BindCharacter(char)
Character = char
RootPart = Character:WaitForChild("HumanoidRootPart", 10)
Humanoid = Character:WaitForChild("Humanoid", 10)
​isRecording = false
isPlaying = false
isPaused = false
autoWalkEnabled = false
if Humanoid then Humanoid.PlatformStand = false end
end
​characterAddedConn = LocalPlayer.CharacterAdded:Connect(BindCharacter)
renderConnection = RunService.RenderStepped:Connect(MainLoop)
