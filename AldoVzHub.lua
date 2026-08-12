local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if _G._AldoVzHubCleanup then pcall(_G._AldoVzHubCleanup) end

local connections = {}
local destroyed = false

local function connect(sig, cb)
  local c
  pcall(function() c = sig:Connect(cb) end)
  if c then table.insert(connections, c) end
  return c
end

local function cleanup()
  destroyed = true
  for _, c in ipairs(connections) do
    pcall(function() c:Disconnect() end)
  end
  table.clear(connections)
  local sg = playerGui:FindFirstChild("AldoVzHub")
  if sg then sg:Destroy() end
  ContextActionService:UnbindAction("AldoVzMove")
end

_G._AldoVzHubCleanup = cleanup

local SAVE_FILE = "AldoVzHub_Config.json"
local NOTES_FILE = "AldoVzHub_Notes.json"

local config = {
  walkSpeed = 16,
  jumpPower = 50,
  shiftLock = false,
  airControl = 20,
  wasdEnabled = true
}

local notes = {}
local selectedNote = nil

local function loadConfig()
  local s, d = pcall(function() return readfile(SAVE_FILE) end)
  if s and d and #d > 0 then
    local ok, dec = pcall(function() return HttpService:JSONDecode(d) end)
    if ok and type(dec) == "table" then
      for k, v in pairs(dec) do config[k] = v end
    end
  end
end

local function saveConfig()
  local s, e = pcall(function() return HttpService:JSONEncode(config) end)
  if s then pcall(function() writefile(SAVE_FILE, e) end) end
end

local function loadNotes()
  local s, d = pcall(function() return readfile(NOTES_FILE) end)
  if s and d and #d > 0 then
    local ok, dec = pcall(function() return HttpService:JSONDecode(d) end)
    if ok and type(dec) == "table" then notes = dec end
  end
end

local function saveNotes()
  local s, e = pcall(function() return HttpService:JSONEncode(notes) end)
  if s then pcall(function() writefile(NOTES_FILE, e) end) end
end

loadConfig()
loadNotes()

local sg = Instance.new("ScreenGui")
sg.Name = "AldoVzHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999999
sg.Parent = playerGui
=
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 180, 1, 0)
leftPanel.Position = UDim2.fromOffset(0, 0)
leftPanel.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = sg

local leftGrad = Instance.new("UIGradient")
leftGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 12, 40)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 22))
})
leftGrad.Parent = leftPanel

local leftStroke = Instance.new("UIStroke")
leftStroke.Color = Color3.fromRGB(100, 50, 200)
leftStroke.Thickness = 1.5
leftStroke.Transparency = 0.5
leftStroke.Parent = leftPanel

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 14, 32)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = leftPanel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -6, 0, 18)
titleLabel.Position = UDim2.fromOffset(4, 2)
titleLabel.Text = "👾 AldoVz"
titleLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.5, -4, 0, 14)
pingLabel.Position = UDim2.fromOffset(4, 20)
pingLabel.Text = "PING: 0"
pingLabel.TextColor3 = Color3.fromRGB(120, 200, 120)
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 9
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.BackgroundTransparency = 1
pingLabel.Parent = titleBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, -4, 0, 14)
fpsLabel.Position = UDim2.new(0.5, 0, 0, 20)
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 9
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.BackgroundTransparency = 1
fpsLabel.Parent = titleBar

-- Command input
local cmdFrame = Instance.new("Frame")
cmdFrame.Size = UDim2.new(1, -8, 0, 28)
cmdFrame.Position = UDim2.fromOffset(4, 52)
cmdFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 38)
cmdFrame.BackgroundTransparency = 0.2
cmdFrame.BorderSizePixel = 0
cmdFrame.Parent = leftPanel

local cmdCorner = Instance.new("UICorner")
cmdCorner.CornerRadius = UDim.new(0, 6)
cmdCorner.Parent = cmdFrame

local cmdBox = Instance.new("TextBox")
cmdBox.Size = UDim2.new(1, -8, 1, 0)
cmdBox.Position = UDim2.fromOffset(4, 0)
cmdBox.PlaceholderText = "CMD Infinite Yield..."
cmdBox.PlaceholderColor3 = Color3.fromRGB(100, 80, 140)
cmdBox.Text = ""
cmdBox.TextColor3 = Color3.fromRGB(220, 210, 255)
cmdBox.TextSize = 11
cmdBox.Font = Enum.Font.Gotham
cmdBox.BackgroundTransparency = 1
cmdBox.BorderSizePixel = 0
cmdBox.ClearTextOnFocus = false
cmdBox.Parent = cmdFrame

connect(cmdBox.FocusLost, function(enter)
  if enter and #cmdBox.Text > 0 then
    local cmd = cmdBox.Text
    cmdBox.Text = ""
    pcall(function() loadstring(cmd)() end)
  end
end)

local menuBtnFrame = Instance.new("Frame")
menuBtnFrame.Name = "MenuButtons"
menuBtnFrame.Size = UDim2.new(1, 0, 1, -90)
menuBtnFrame.Position = UDim2.fromOffset(0, 84)
menuBtnFrame.BackgroundTransparency = 1
menuBtnFrame.Parent = leftPanel

local menuScroll = Instance.new("ScrollingFrame")
menuScroll.Size = UDim2.new(1, 0, 1, 0)
menuScroll.BackgroundTransparency = 1
menuScroll.BorderSizePixel = 0
menuScroll.ScrollBarThickness = 3
menuScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
menuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
menuScroll.Parent = menuBtnFrame

local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 4)
menuLayout.Parent = menuScroll

local menuButtons = {}
local activeMenuBtn = 1
local menuNames = {"MAIN", "NOTE", "CONTROL", "PLAYER"}

for i, name in ipairs(menuNames) do
  local btn = Instance.new("TextButton")
  btn.Size = UDim2.new(1, -8, 0, 32)
  btn.Text = "  " .. name
  btn.TextColor3 = Color3.fromRGB(180, 170, 210)
  btn.TextSize = 12
  btn.Font = Enum.Font.GothamBold
  btn.TextXAlignment = Enum.TextXAlignment.Left
  btn.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
  btn.BackgroundTransparency = 0.2
  btn.BorderSizePixel = 0
  btn.Parent = menuScroll
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = btn
  menuButtons[i] = btn

  connect(btn.Activated, function()
    activeMenuBtn = i
    for j, b in ipairs(menuButtons) do
      b.BackgroundColor3 = (j == i) and Color3.fromRGB(80, 40, 160) or Color3.fromRGB(22, 18, 40)
      b.TextColor3 = (j == i) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 170, 210)
    end
    for j, p in ipairs(menuPanels) do
      if p then p.Visible = (j == i) end
    end
  end)
end

menuScroll.CanvasSize = UDim2.new(0, 0, 0, #menuNames * 36 + 10)

local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -180, 1, 0)
rightPanel.Position = UDim2.new(0, 180, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(15, 13, 28)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = sg

local rightGrad = Instance.new("UIGradient")
rightGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 15, 42)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 13, 28))
})
rightGrad.Parent = rightPanel

-- Content frame for panels
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -12, 1, -12)
contentFrame.Position = UDim2.fromOffset(6, 6)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = rightPanel

local menuPanels = {}

local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(1, 0, 1, 0)
mainPanel.BackgroundTransparency = 1
mainPanel.Parent = contentFrame
menuPanels[1] = mainPanel

local mainScroll = Instance.new("ScrollingFrame")
mainScroll.Size = UDim2.new(1, 0, 1, 0)
mainScroll.BackgroundTransparency = 1
mainScroll.BorderSizePixel = 0
mainScroll.ScrollBarThickness = 4
mainScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
mainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
mainScroll.Parent = mainPanel

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 8)
mainLayout.Parent = mainScroll

local function mHeader(text)
  local h = Instance.new("TextLabel")
  h.Size = UDim2.new(1, -10, 0, 22)
  h.Text = text
  h.TextColor3 = Color3.fromRGB(160, 120, 255)
  h.Font = Enum.Font.GothamBold
  h.TextSize = 13
  h.TextXAlignment = Enum.TextXAlignment.Left
  h.BackgroundTransparency = 1
  h.Parent = mainScroll
  return h
end

local function mSlider(label, min, max, default, callback)
  local frame = Instance.new("Frame")
  frame.Size = UDim2.new(1, -10, 0, 44)
  frame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
  frame.BackgroundTransparency = 0.15
  frame.BorderSizePixel = 0
  frame.Parent = mainScroll
  local fCorner = Instance.new("UICorner")
  fCorner.CornerRadius = UDim.new(0, 8)
  fCorner.Parent = frame

  local label = Instance.new("TextLabel")
  label.Size = UDim2.new(0.5, -6, 0, 20)
  label.Position = UDim2.fromOffset(8, 2)
  label.Text = label
  label.TextColor3 = Color3.fromRGB(200, 190, 230)
  label.Font = Enum.Font.GothamBold
  label.TextSize = 12
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.BackgroundTransparency = 1
  label.Parent = frame

  local valLabel = Instance.new("TextLabel")
  valLabel.Size = UDim2.new(0.5, -6, 0, 20)
  valLabel.Position = UDim2.new(0.5, 0, 0, 2)
  valLabel.Text = tostring(default)
  valLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
  valLabel.Font = Enum.Font.GothamBold
  valLabel.TextSize = 12
  valLabel.TextXAlignment = Enum.TextXAlignment.Right
  valLabel.BackgroundTransparency = 1
  valLabel.Parent = frame

  local minusBtn = Instance.new("TextButton")
  minusBtn.Size = UDim2.fromOffset(28, 24)
  minusBtn.Position = UDim2.fromOffset(8, 22)
  minusBtn.Text = "-"
  minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  minusBtn.TextSize = 16
  minusBtn.Font = Enum.Font.GothamBold
  minusBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
  minusBtn.BackgroundTransparency = 0.2
  minusBtn.BorderSizePixel = 0
  minusBtn.Parent = frame
  local miCorner = Instance.new("UICorner")
  miCorner.CornerRadius = UDim.new(0, 6)
  miCorner.Parent = minusBtn

  local plusBtn = Instance.new("TextButton")
  plusBtn.Size = UDim2.fromOffset(28, 24)
  plusBtn.Position = UDim2.fromOffset(40, 22)
  plusBtn.Text = "+"
  plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  plusBtn.TextSize = 16
  plusBtn.Font = Enum.Font.GothamBold
  plusBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
  plusBtn.BackgroundTransparency = 0.2
  plusBtn.BorderSizePixel = 0
  plusBtn.Parent = frame
  local plCorner = Instance.new("UICorner")
  plCorner.CornerRadius = UDim.new(0, 6)
  plCorner.Parent = plusBtn

  local resetBtn = Instance.new("TextButton")
  resetBtn.Size = UDim2.fromOffset(40, 24)
  resetBtn.Position = UDim2.fromOffset(72, 22)
  resetBtn.Text = "↺"
  resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  resetBtn.TextSize = 14
  resetBtn.Font = Enum.Font.GothamBold
  resetBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 60)
  resetBtn.BackgroundTransparency = 0.2
  resetBtn.BorderSizePixel = 0
  resetBtn.Parent = frame
  local rsCorner = Instance.new("UICorner")
  rsCorner.CornerRadius = UDim.new(0, 6)
  rsCorner.Parent = resetBtn

  local val = default

  connect(minusBtn.Activated, function()
    val = math.max(min, val - 1)
    valLabel.Text = tostring(val)
    callback(val)
  end)

  connect(plusBtn.Activated, function()
    val = math.min(max, val + 1)
    valLabel.Text = tostring(val)
    callback(val)
  end)

  connect(resetBtn.Activated, function()
    val = default
    valLabel.Text = tostring(default)
    callback(default)
  end)

  return frame, function() return val end
end

mHeader("⚡ WALK SPEED")
mSlider("Walk Speed", 1, 200, config.walkSpeed, function(v)
  config.walkSpeed = v
  local char = player.Character
  if char then
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = v end
  end
  saveConfig()
end)

mHeader("🦘 JUMP POWER")
mSlider("Jump Power", 10, 200, config.jumpPower, function(v)
  config.jumpPower = v
  local char = player.Character
  if char then
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.JumpPower = v end
  end
  saveConfig()
end)

mHeader("🔒 SHIFT LOCK")
local slFrame = Instance.new("Frame")
slFrame.Size = UDim2.new(1, -10, 0, 34)
slFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
slFrame.BackgroundTransparency = 0.15
slFrame.BorderSizePixel = 0
slFrame.Parent = mainScroll
local slCorner = Instance.new("UICorner")
slCorner.CornerRadius = UDim.new(0, 8)
slCorner.Parent = slFrame

local slLabel = Instance.new("TextLabel")
slLabel.Size = UDim2.new(0.6, -10, 1, 0)
slLabel.Position = UDim2.fromOffset(8, 0)
slLabel.Text = "Shift Lock"
slLabel.TextColor3 = Color3.fromRGB(200, 190, 230)
slLabel.Font = Enum.Font.GothamBold
slLabel.TextSize = 12
slLabel.TextXAlignment = Enum.TextXAlignment.Left
slLabel.BackgroundTransparency = 1
slLabel.Parent = slFrame

local slBtn = Instance.new("TextButton")
slBtn.Size = UDim2.fromOffset(50, 26)
slBtn.Position = UDim2.new(1, -56, 0, 4)
slBtn.Text = config.shiftLock and "ON" or "OFF"
slBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
slBtn.TextSize = 11
slBtn.Font = Enum.Font.GothamBold
slBtn.BackgroundColor3 = config.shiftLock and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(100, 50, 50)
slBtn.BackgroundTransparency = 0.15
slBtn.BorderSizePixel = 0
slBtn.Parent = slFrame
local slBtnCorner = Instance.new("UICorner")
slBtnCorner.CornerRadius = UDim.new(0, 6)
slBtnCorner.Parent = slBtn

connect(slBtn.Activated, function()
  config.shiftLock = not config.shiftLock
  slBtn.Text = config.shiftLock and "ON" or "OFF"
  slBtn.BackgroundColor3 = config.shiftLock and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(100, 50, 50)
  if config.shiftLock then
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
  else
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
  end
  saveConfig()
end)

local notePanel = Instance.new("Frame")
notePanel.Name = "NotePanel"
notePanel.Size = UDim2.new(1, 0, 1, 0)
notePanel.BackgroundTransparency = 1
notePanel.Visible = false
notePanel.Parent = contentFrame
menuPanels[2] = notePanel

local noteScroll = Instance.new("ScrollingFrame")
noteScroll.Size = UDim2.new(1, 0, 1, -50)
noteScroll.BackgroundTransparency = 1
noteScroll.BorderSizePixel = 0
noteScroll.ScrollBarThickness = 4
noteScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
noteScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
noteScroll.Parent = notePanel

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0, 4)
noteLayout.Parent = noteScroll

local noteFrames = {}

local function refreshNotes()
  for _, f in ipairs(noteFrames) do
    if f and f.Parent then f:Destroy() end
  end
  table.clear(noteFrames)

  for i, note in ipairs(notes) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = noteScroll
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame
    table.insert(noteFrames, frame)

    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -50, 0, 18)
    titleL.Position = UDim2.fromOffset(6, 2)
    titleL.Text = note.title or "Note " .. i
    titleL.TextColor3 = Color3.fromRGB(200, 180, 255)
    titleL.Font = Enum.Font.GothamBold
    titleL.TextSize = 12
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.BackgroundTransparency = 1
    titleL.Parent = frame

    local bodyL = Instance.new("TextLabel")
    bodyL.Size = UDim2.new(1, -50, 0, 28)
    bodyL.Position = UDim2.fromOffset(6, 20)
    bodyL.Text = note.body or ""
    bodyL.TextColor3 = Color3.fromRGB(180, 170, 200)
    bodyL.Font = Enum.Font.Gotham
    bodyL.TextSize = 10
    bodyL.TextXAlignment = Enum.TextXAlignment.Left
    bodyL.TextYAlignment = Enum.TextYAlignment.Top
    bodyL.BackgroundTransparency = 1
    bodyL.TextWrapped = true
    bodyL.Parent = frame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.fromOffset(22, 22)
    copyBtn.Position = UDim2.new(1, -50, 0, 3)
    copyBtn.Text = "📋"
    copyBtn.TextSize = 12
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    copyBtn.BackgroundTransparency = 0.3
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = frame
    local cpCorner = Instance.new("UICorner")
    cpCorner.CornerRadius = UDim.new(0, 4)
    cpCorner.Parent = copyBtn
    connect(copyBtn.Activated, function()
      setclipboard(note.body or note.title or "")
      StarterGui:SetCore("SendNotification", {Title = "📋 Copied", Text = "Note copied!", Duration = 1})
    end)

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.fromOffset(22, 22)
    delBtn.Position = UDim2.new(1, -26, 0, 3)
    delBtn.Text = "✕"
    delBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    delBtn.TextSize = 11
    delBtn.Font = Enum.Font.GothamBold
    delBtn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
    delBtn.BackgroundTransparency = 0.4
    delBtn.BorderSizePixel = 0
    delBtn.Parent = frame
    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 4)
    dCorner.Parent = delBtn
    connect(delBtn.Activated, function()
      table.remove(notes, i)
      saveNotes()
      refreshNotes()
    end)
  end

  noteScroll.CanvasSize = UDim2.new(0, 0, 0, #notes * 64 + 60)
end

local noteInputFrame = Instance.new("Frame")
noteInputFrame.Size = UDim2.new(1, 0, 0, 44)
noteInputFrame.Position = UDim2.new(0, 0, 1, -44)
noteInputFrame.BackgroundColor3 = Color3.fromRGB(18, 15, 32)
noteInputFrame.BackgroundTransparency = 0.15
noteInputFrame.BorderSizePixel = 0
noteInputFrame.Parent = notePanel
local nifCorner = Instance.new("UICorner")
nifCorner.CornerRadius = UDim.new(0, 8)
nifCorner.Parent = noteInputFrame

local noteTitleInput = Instance.new("TextBox")
noteTitleInput.Size = UDim2.new(0.35, -6, 1, -8)
noteTitleInput.Position = UDim2.fromOffset(4, 4)
noteTitleInput.PlaceholderText = "Title"
noteTitleInput.PlaceholderColor3 = Color3.fromRGB(100, 80, 140)
noteTitleInput.Text = ""
noteTitleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
noteTitleInput.TextSize = 11
noteTitleInput.Font = Enum.Font.Gotham
noteTitleInput.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
noteTitleInput.BackgroundTransparency = 0.2
noteTitleInput.BorderSizePixel = 0
noteTitleInput.ClearTextOnFocus = false
noteTitleInput.Parent = noteInputFrame
local ntiCorner = Instance.new("UICorner")
ntiCorner.CornerRadius = UDim.new(0, 6)
ntiCorner.Parent = noteTitleInput

local noteBodyInput = Instance.new("TextBox")
noteBodyInput.Size = UDim2.new(0.65, -14, 1, -8)
noteBodyInput.Position = UDim2.new(0.35, 4, 0, 4)
noteBodyInput.PlaceholderText = "Content"
noteBodyInput.PlaceholderColor3 = Color3.fromRGB(100, 80, 140)
noteBodyInput.Text = ""
noteBodyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
noteBodyInput.TextSize = 11
noteBodyInput.Font = Enum.Font.Gotham
noteBodyInput.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
noteBodyInput.BackgroundTransparency = 0.2
noteBodyInput.BorderSizePixel = 0
noteBodyInput.ClearTextOnFocus = false
noteBodyInput.Parent = noteInputFrame
local nbiCorner = Instance.new("UICorner")
nbiCorner.CornerRadius = UDim.new(0, 6)
nbiCorner.Parent = noteBodyInput

local addNoteBtn = Instance.new("TextButton")
addNoteBtn.Size = UDim2.fromOffset(26, 26)
addNoteBtn.Position = UDim2.new(1, -30, 0, 9)
addNoteBtn.Text = "+"
addNoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addNoteBtn.TextSize = 14
addNoteBtn.Font = Enum.Font.GothamBold
addNoteBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
addNoteBtn.BackgroundTransparency = 0.15
addNoteBtn.BorderSizePixel = 0
addNoteBtn.Parent = noteInputFrame
local anCorner = Instance.new("UICorner")
anCorner.CornerRadius = UDim.new(0, 6)
anCorner.Parent = addNoteBtn

connect(addNoteBtn.Activated, function()
  local t = noteTitleInput.Text
  local b = noteBodyInput.Text
  if #t > 0 or #b > 0 then
    table.insert(notes, {title = t, body = b})
    saveNotes()
    refreshNotes()
    noteTitleInput.Text = ""
    noteBodyInput.Text = ""
  end
end)

refreshNotes()

local controlPanel = Instance.new("Frame")
controlPanel.Name = "ControlPanel"
controlPanel.Size = UDim2.new(1, 0, 1, 0)
controlPanel.BackgroundTransparency = 1
controlPanel.Visible = false
controlPanel.Parent = contentFrame
menuPanels[3] = controlPanel

local controlScroll = Instance.new("ScrollingFrame")
controlScroll.Size = UDim2.new(1, 0, 1, 0)
controlScroll.BackgroundTransparency = 1
controlScroll.BorderSizePixel = 0
controlScroll.ScrollBarThickness = 4
controlScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
controlScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
controlScroll.Parent = controlPanel

local controlLayout = Instance.new("UIListLayout")
controlLayout.Padding = UDim.new(0, 8)
controlLayout.Parent = controlScroll

local function cHeader(text)
  local h = Instance.new("TextLabel")
  h.Size = UDim2.new(1, -10, 0, 22)
  h.Text = text
  h.TextColor3 = Color3.fromRGB(160, 120, 255)
  h.Font = Enum.Font.GothamBold
  h.TextSize = 13
  h.TextXAlignment = Enum.TextXAlignment.Left
  h.BackgroundTransparency = 1
  h.Parent = controlScroll
  return h
end

cHeader("🎮 CONTROLLER SETTINGS")

local wasdFrame = Instance.new("Frame")
wasdFrame.Size = UDim2.new(1, -10, 0, 34)
wasdFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
wasdFrame.BackgroundTransparency = 0.15
wasdFrame.BorderSizePixel = 0
wasdFrame.Parent = controlScroll
local wCorner = Instance.new("UICorner")
wCorner.CornerRadius = UDim.new(0, 8)
wCorner.Parent = wasdFrame

local wasdLabel = Instance.new("TextLabel")
wasdLabel.Size = UDim2.new(0.6, -10, 1, 0)
wasdLabel.Position = UDim2.fromOffset(8, 0)
wasdLabel.Text = "W A S D Controller"
wasdLabel.TextColor3 = Color3.fromRGB(200, 190, 230)
wasdLabel.Font = Enum.Font.GothamBold
wasdLabel.TextSize = 12
wasdLabel.TextXAlignment = Enum.TextXAlignment.Left
wasdLabel.BackgroundTransparency = 1
wasdLabel.Parent = wasdFrame

local wasdBtn = Instance.new("TextButton")
wasdBtn.Size = UDim2.fromOffset(50, 26)
wasdBtn.Position = UDim2.new(1, -56, 0, 4)
wasdBtn.Text = config.wasdEnabled and "ON" or "OFF"
wasdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wasdBtn.TextSize = 11
wasdBtn.Font = Enum.Font.GothamBold
wasdBtn.BackgroundColor3 = config.wasdEnabled and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(100, 50, 50)
wasdBtn.BackgroundTransparency = 0.15
wasdBtn.BorderSizePixel = 0
wasdBtn.Parent = wasdFrame
local wbCorner = Instance.new("UICorner")
wbCorner.CornerRadius = UDim.new(0, 6)
wbCorner.Parent = wasdBtn

local wasdActive = config.wasdEnabled

connect(wasdBtn.Activated, function()
  wasdActive = not wasdActive
  wasdBtn.Text = wasdActive and "ON" or "OFF"
  wasdBtn.BackgroundColor3 = wasdActive and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(100, 50, 50)
  if not wasdActive then
    ContextActionService:BindAction("AldoVzMove", function() end, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)
  else
    ContextActionService:UnbindAction("AldoVzMove")
  end
  config.wasdEnabled = wasdActive
  saveConfig()
end)

cHeader("🌪️ AIR CONTROL")
local acFrame = Instance.new("Frame")
acFrame.Size = UDim2.new(1, -10, 0, 44)
acFrame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
acFrame.BackgroundTransparency = 0.15
acFrame.BorderSizePixel = 0
acFrame.Parent = controlScroll
local acFCorner = Instance.new("UICorner")
acFCorner.CornerRadius = UDim.new(0, 8)
acFCorner.Parent = acFrame

local acLabel = Instance.new("TextLabel")
acLabel.Size = UDim2.new(0.5, -6, 0, 20)
acLabel.Position = UDim2.fromOffset(8, 2)
acLabel.Text = "Air Control"
acLabel.TextColor3 = Color3.fromRGB(200, 190, 230)
acLabel.Font = Enum.Font.GothamBold
acLabel.TextSize = 12
acLabel.TextXAlignment = Enum.TextXAlignment.Left
acLabel.BackgroundTransparency = 1
acLabel.Parent = acFrame

local acVal = Instance.new("TextLabel")
acVal.Size = UDim2.new(0.5, -6, 0, 20)
acVal.Position = UDim2.new(0.5, 0, 0, 2)
acVal.Text = tostring(config.airControl)
acVal.TextColor3 = Color3.fromRGB(255, 200, 100)
acVal.Font = Enum.Font.GothamBold
acVal.TextSize = 12
acVal.TextXAlignment = Enum.TextXAlignment.Right
acVal.BackgroundTransparency = 1
acVal.Parent = acFrame

local acMinus = Instance.new("TextButton")
acMinus.Size = UDim2.fromOffset(28, 24)
acMinus.Position = UDim2.fromOffset(8, 22)
acMinus.Text = "-"
acMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
acMinus.TextSize = 16
acMinus.Font = Enum.Font.GothamBold
acMinus.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
acMinus.BackgroundTransparency = 0.2
acMinus.BorderSizePixel = 0
acMinus.Parent = acFrame
local amiCorner = Instance.new("UICorner")
amiCorner.CornerRadius = UDim.new(0, 6)
amiCorner.Parent = acMinus

local acPlus = Instance.new("TextButton")
acPlus.Size = UDim2.fromOffset(28, 24)
acPlus.Position = UDim2.fromOffset(40, 22)
acPlus.Text = "+"
acPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
acPlus.TextSize = 16
acPlus.Font = Enum.Font.GothamBold
acPlus.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
acPlus.BackgroundTransparency = 0.2
acPlus.BorderSizePixel = 0
acPlus.Parent = acFrame
local aplCorner = Instance.new("UICorner")
aplCorner.CornerRadius = UDim.new(0, 6)
aplCorner.Parent = acPlus

local acReset = Instance.new("TextButton")
acReset.Size = UDim2.fromOffset(40, 24)
acReset.Position = UDim2.fromOffset(72, 22)
acReset.Text = "↺"
acReset.TextColor3 = Color3.fromRGB(255, 255, 255)
acReset.TextSize = 14
acReset.Font = Enum.Font.GothamBold
acReset.BackgroundColor3 = Color3.fromRGB(80, 50, 60)
acReset.BackgroundTransparency = 0.2
acReset.BorderSizePixel = 0
acReset.Parent = acFrame
local arCorner = Instance.new("UICorner")
arCorner.CornerRadius = UDim.new(0, 6)
arCorner.Parent = acReset

local acValNum = config.airControl

connect(acMinus.Activated, function()
  acValNum = math.max(0, acValNum - 1)
  acVal.Text = tostring(acValNum)
  config.airControl = acValNum
  saveConfig()
end)

connect(acPlus.Activated, function()
  acValNum = math.min(100, acValNum + 1)
  acVal.Text = tostring(acValNum)
  config.airControl = acValNum
  saveConfig()
end)

connect(acReset.Activated, function()
  acValNum = 20
  acVal.Text = "20"
  config.airControl = 20
  saveConfig()
end)

controlScroll.CanvasSize = UDim2.new(0, 0, 0, 200)

local playerPanel = Instance.new("Frame")
playerPanel.Name = "PlayerPanel"
playerPanel.Size = UDim2.new(1, 0, 1, 0)
playerPanel.BackgroundTransparency = 1
playerPanel.Visible = false
playerPanel.Parent = contentFrame
menuPanels[4] = playerPanel

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 1, 0)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = playerPanel

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 4)
playerLayout.Parent = playerScroll

local function refreshPlayerList()
  for _, child in ipairs(playerScroll:GetChildren()) do
    if child:IsA("Frame") then child:Destroy() end
  end

  local allPlayers = Players:GetPlayers()
  table.sort(allPlayers, function(a, b) return a.Name < b.Name end)

  for _, plr in ipairs(allPlayers) do
    if plr ~= player then
      local frame = Instance.new("Frame")
      frame.Size = UDim2.new(1, -10, 0, 34)
      frame.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
      frame.BackgroundTransparency = 0.15
      frame.BorderSizePixel = 0
      frame.Parent = playerScroll
      local fCorner = Instance.new("UICorner")
      fCorner.CornerRadius = UDim.new(0, 6)
      fCorner.Parent = frame

      local nameL = Instance.new("TextLabel")
      nameL.Size = UDim2.new(0.6, -10, 1, 0)
      nameL.Position = UDim2.fromOffset(8, 0)
      nameL.Text = plr.Name
      nameL.TextColor3 = Color3.fromRGB(200, 190, 230)
      nameL.Font = Enum.Font.Gotham
      nameL.TextSize = 12
      nameL.TextXAlignment = Enum.TextXAlignment.Left
      nameL.BackgroundTransparency = 1
      nameL.Parent = frame

      local specBtn = Instance.new("TextButton")
      specBtn.Size = UDim2.fromOffset(40, 24)
      specBtn.Position = UDim2.new(1, -46, 0, 5)
      specBtn.Text = "👁"
      specBtn.TextSize = 14
      specBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
      specBtn.BackgroundTransparency = 0.2
      specBtn.BorderSizePixel = 0
      specBtn.Parent = frame
      local sbCorner = Instance.new("UICorner")
      sbCorner.CornerRadius = UDim.new(0, 4)
      sbCorner.Parent = specBtn

      connect(specBtn.Activated, function()
        local cam = Workspace.CurrentCamera
        if cam then
          cam.CameraSubject = plr.Character and plr.Character:FindFirstChild("Humanoid") or plr
          cam.CameraType = Enum.CameraType.Custom
          StarterGui:SetCore("SendNotification", {Title = "👁 Spectating", Text = plr.Name, Duration = 1})
        end
      end)
    end
  end

  playerScroll.CanvasSize = UDim2.new(0, 0, 0, (#Players:GetPlayers() - 1) * 38 + 10)
end

refreshPlayerList()

connect(Players.PlayerAdded, refreshPlayerList)
connect(Players.PlayerRemoving, refreshPlayerList)
connect(Players.LocalPlayer.CharacterAdded, function()
  local char = player.Character
  if char then
    local hum = char:WaitForChild("Humanoid")
    if hum then
      hum.WalkSpeed = config.walkSpeed
      hum.JumpPower = config.jumpPower
    end
  end
end)

local fc = 0
local ft = 0
local checkSpeed = 0

connect(RunService.RenderStepped, function(dt)
  fc = fc + 1
  ft = ft + dt
  if ft >= 1 then
    local fps = math.floor(fc / ft)
    local ping = math.random(10, 60)
    fpsLabel.Text = "FPS: " .. fps
    pingLabel.Text = "PING: " .. ping
    fc = 0
    ft = 0
    checkSpeed = math.random(10, 30)
  end
end)

local settingMode = "JUMP"
local settingVal = 50

local function updateSettingDisplay()

end

connect(UserInputService.InputBegan, function(input, gp)
  if gp or destroyed then return end
  if input.KeyCode == Enum.KeyCode.Up then
    if settingMode == "JUMP" then
      settingVal = math.min(200, settingVal + 5)
      config.jumpPower = settingVal
      local char = player.Character
      if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = settingVal end
      end
      saveConfig()
    end
  elseif input.KeyCode == Enum.KeyCode.Down then
    if settingMode == "JUMP" then
      settingVal = math.max(10, settingVal - 5)
      config.jumpPower = settingVal
      local char = player.Character
      if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = settingVal end
      end
      saveConfig()
    end
  elseif input.KeyCode == Enum.KeyCode.Left then
    settingMode = "SHIFTLOCK"
  elseif input.KeyCode == Enum.KeyCode.Right then
    settingMode = "JUMP"
  end
end)

menuButtons[1].BackgroundColor3 = Color3.fromRGB(80, 40, 160)
menuButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

local function applyConfig(char)
  if not char then return end
  local hum = char:FindFirstChild("Humanoid")
  if hum then
    hum.WalkSpeed = config.walkSpeed
    hum.JumpPower = config.jumpPower
  end
end

if player.Character then
  applyConfig(player.Character)
end

connect(player.CharacterAdded, applyConfig)

print("[AVz")
