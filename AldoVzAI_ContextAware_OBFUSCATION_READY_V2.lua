local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if type(_G._AldoVzAICleanup) == "function" then
  pcall(_G._AldoVzAICleanup)
end

local connections = {}
local destroyed = false

local function U(...)
  local out = {}
  for i = 1, select("#", ...) do
    local n = select(i, ...)
    if n <= 0x7F then
      out[#out + 1] = string.char(n)
    elseif n <= 0x7FF then
      out[#out + 1] = string.char(0xC0 + math.floor(n / 0x40), 0x80 + (n % 0x40))
    elseif n <= 0xFFFF then
      out[#out + 1] = string.char(0xE0 + math.floor(n / 0x1000), 0x80 + (math.floor(n / 0x40) % 0x40), 0x80 + (n % 0x40))
    else
      out[#out + 1] = string.char(0xF0 + math.floor(n / 0x40000), 0x80 + (math.floor(n / 0x1000) % 0x40), 0x80 + (math.floor(n / 0x40) % 0x40), 0x80 + (n % 0x40))
    end
  end
  return table.concat(out)
end

local function clearTable(t)
  if type(t) ~= "table" then return end
  for k in pairs(t) do
    t[k] = nil
  end
end

-- Compatibility wrappers so the script remains usable in runtimes where
-- the executor exposes only the basic Luau scheduling primitives.
local function safeSpawn(fn)
  if type(task) == "table" and type(task.spawn) == "function" then
    return task.spawn(fn)
  end
  return coroutine.wrap(fn)()
end

local function safeDefer(fn)
  if type(task) == "table" and type(task.defer) == "function" then
    return task.defer(fn)
  end
  return safeSpawn(fn)
end

local function safeDelay(seconds, fn)
  if type(task) == "table" and type(task.delay) == "function" then
    return task.delay(seconds, fn)
  end
  return safeSpawn(function()
    local ok = pcall(function()
      if type(task) == "table" and type(task.wait) == "function" then
        task.wait(seconds)
      else
        local start = os.clock()
        while os.clock() - start < seconds do
          RunService.Heartbeat:Wait()
        end
      end
    end)
    if ok then fn() end
  end)
end

local function safeWait(seconds)
  if type(task) == "table" and type(task.wait) == "function" then
    return task.wait(seconds)
  end
  return RunService.Heartbeat:Wait()
end

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
  clearTable(connections)
  local sg = playerGui:FindFirstChild("AldoVzAI")
  if sg then sg:Destroy() end
end

_G._AldoVzAICleanup = cleanup

local function notify(title, text, duration)
  pcall(function()
    StarterGui:SetCore("SendNotification", {
      Title = title,
      Text = text,
      Duration = duration or 2
    })
  end)
end

-- ============================================================
-- SAVE / LOAD SYSTEM
-- ===========================
local SAVE_FILE = "AldoVzAI_Chat.json"
local NOTES_FILE = "AldoVzAI_Notes.json"
local CONFIG_FILE = "AldoVzAI_Config.json"

local chatHistory = {}
local notes = {}
local config = { language = "Indonesia" }

local function loadChat()
  local s, d = pcall(function() return readfile(SAVE_FILE) end)
  if s and d and #d > 0 then
    local ok, dec = pcall(function() return HttpService:JSONDecode(d) end)
    if ok and type(dec) == "table" then chatHistory = dec end
  end
end

local function saveChat()
  local s, e = pcall(function() return HttpService:JSONEncode(chatHistory) end)
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

local function loadConfig()
  local s, d = pcall(function() return readfile(CONFIG_FILE) end)
  if s and d and #d > 0 then
    local ok, dec = pcall(function() return HttpService:JSONDecode(d) end)
    if ok and type(dec) == "table" then
      for k, v in pairs(dec) do config[k] = v end
    end
  end
end

local function saveConfig()
  local s, e = pcall(function() return HttpService:JSONEncode(config) end)
  if s then pcall(function() writefile(CONFIG_FILE, e) end) end
end

loadChat()
loadNotes()
loadConfig()

-- ============================================================
-- GUI CORE
-- ============================================================
local sg = Instance.new("ScreenGui")
sg.Name = "AldoVzAI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999999
sg.Parent = playerGui

-- Gradient background for main
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(500, 300)
main.Position = UDim2.new(0.5, -250, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = sg

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

-- Premium gradient overlay
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 15, 50)),
  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 12, 25)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 45))
})
gradient.Parent = main

-- Glow border
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(140, 60, 255)
border.Thickness = 1.5
border.Transparency = 0.4
border.Parent = main

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 60)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 35))
})
titleGrad.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.fromOffset(10, 0)
titleLabel.Text = U(0x1f451)
titleLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.Text = U(0x2715)
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.BackgroundTransparency = 0.4
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 8)
cCorner.Parent = closeBtn

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 38)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = main

local tabs = {"CHAT", "SPECTATE", "TOOLS", "NOTES"}
local tabButtons = {}
local tabPanels = {}
local activeTab = 1

for i, name in ipairs(tabs) do
  local btn = Instance.new("TextButton")
  btn.Name = "Tab_" .. name
  btn.Size = UDim2.new(0.25, -2, 1, -4)
  btn.Position = UDim2.new((i - 1) * 0.25, 1, 0, 2)
  btn.Text = name
  btn.TextColor3 = Color3.fromRGB(160, 150, 190)
  btn.TextSize = 11
  btn.Font = Enum.Font.GothamBold
  btn.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
  btn.BackgroundTransparency = 0.2
  btn.BorderSizePixel = 0
  btn.Parent = tabFrame
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 6)
  btnCorner.Parent = btn
  tabButtons[i] = btn

  connect(btn.Activated, function()
    activeTab = i
    for j, tb in ipairs(tabButtons) do
      tb.BackgroundColor3 = (j == i) and Color3.fromRGB(100, 50, 180) or Color3.fromRGB(25, 20, 40)
      tb.TextColor3 = (j == i) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 150, 190)
    end
    for j, panel in ipairs(tabPanels) do
      if panel then panel.Visible = (j == i) end
    end
  end)
end

-- Content
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -10, 1, -78)
content.Position = UDim2.new(0, 5, 0, 72)
content.BackgroundTransparency = 1
content.Parent = main

-- ============================================================
-- TAB 1: CHAT WITH AI (VIOLET EVERGARDEN)
-- ============================================================
local chatPanel = Instance.new("Frame")
chatPanel.Name = "ChatPanel"
chatPanel.Size = UDim2.new(1, 0, 1, 0)
chatPanel.BackgroundTransparency = 1
chatPanel.Parent = content
tabPanels[1] = chatPanel

-- Chat scroll
local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Name = "ChatScroll"
chatScroll.Size = UDim2.new(1, 0, 1, -50)
chatScroll.BackgroundTransparency = 1
chatScroll.BorderSizePixel = 0
chatScroll.ScrollBarThickness = 4
chatScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatScroll.ScrollingDirection = Enum.ScrollingDirection.Y
chatScroll.Parent = chatPanel

local chatLayout = Instance.new("UIListLayout")
chatLayout.Padding = UDim.new(0, 6)
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Parent = chatScroll

-- Chat input area
local chatInputFrame = Instance.new("Frame")
chatInputFrame.Name = "ChatInputFrame"
chatInputFrame.Size = UDim2.new(1, 0, 0, 44)
chatInputFrame.Position = UDim2.new(0, 0, 1, -44)
chatInputFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
chatInputFrame.BackgroundTransparency = 0.2
chatInputFrame.BorderSizePixel = 0
chatInputFrame.Parent = chatPanel
local cifCorner = Instance.new("UICorner")
cifCorner.CornerRadius = UDim.new(0, 8)
cifCorner.Parent = chatInputFrame

local chatBox = Instance.new("TextBox")
chatBox.Size = UDim2.new(1, -50, 1, -8)
chatBox.Position = UDim2.fromOffset(6, 4)
chatBox.PlaceholderText = "Chat with Violet..."
chatBox.PlaceholderColor3 = Color3.fromRGB(170, 150, 205)
chatBox.Text = ""
chatBox.TextColor3 = Color3.fromRGB(255, 255, 255)
chatBox.TextSize = 13
chatBox.Font = Enum.Font.GothamBold
chatBox.TextXAlignment = Enum.TextXAlignment.Left
chatBox.TextYAlignment = Enum.TextYAlignment.Center
chatBox.BackgroundColor3 = Color3.fromRGB(38, 30, 62)
chatBox.BackgroundTransparency = 0.05
chatBox.BorderSizePixel = 0
chatBox.ClearTextOnFocus = false
chatBox.TextWrapped = true
chatBox.Parent = chatInputFrame
local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 6)
cbCorner.Parent = chatBox

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.fromOffset(36, 36)
sendBtn.Position = UDim2.new(1, -40, 0, 4)
sendBtn.Text = U(0x27a4)
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.TextSize = 16
sendBtn.Font = Enum.Font.GothamBold
sendBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 220)
sendBtn.BackgroundTransparency = 0.2
sendBtn.BorderSizePixel = 0
sendBtn.Parent = chatInputFrame
local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 8)
sCorner.Parent = sendBtn

-- Floating frame AI (auto jump helper)
local floatingFrame = Instance.new("Frame")
floatingFrame.Name = "FloatingFrame"
floatingFrame.Size = UDim2.fromOffset(200, 60)
floatingFrame.Position = UDim2.new(0.5, -100, 0, 10)
floatingFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
floatingFrame.BackgroundTransparency = 0.15
floatingFrame.BorderSizePixel = 0
floatingFrame.Visible = false
floatingFrame.ZIndex = 99999
floatingFrame.Parent = sg
local ffCorner = Instance.new("UICorner")
ffCorner.CornerRadius = UDim.new(0, 12)
ffCorner.Parent = floatingFrame
local ffGrad = Instance.new("UIGradient")
ffGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 150)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 60))
})
ffGrad.Parent = floatingFrame
local ffStroke = Instance.new("UIStroke")
ffStroke.Color = Color3.fromRGB(140, 60, 255)
ffStroke.Thickness = 1
ffStroke.Transparency = 0.5
ffStroke.Parent = floatingFrame

local ffLabel = Instance.new("TextLabel")
ffLabel.Size = UDim2.new(1, -10, 1, 0)
ffLabel.Position = UDim2.fromOffset(5, 0)
ffLabel.Text = U(0x1f49c)
ffLabel.TextColor3 = Color3.fromRGB(220, 200, 255)
ffLabel.Font = Enum.Font.Gotham
ffLabel.TextSize = 11
ffLabel.TextXAlignment = Enum.TextXAlignment.Left
ffLabel.BackgroundTransparency = 1
ffLabel.TextWrapped = true
ffLabel.Parent = floatingFrame

-- ============================================================
-- VIOLET EVERGARDEN AI ENGINE
-- ============================================================
local function getTimestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function addChatBubble(sender, message, isAI)
  local frame = Instance.new("Frame")
  frame.Size = UDim2.new(1, -10, 0, 0)
  frame.AutomaticSize = Enum.AutomaticSize.Y
  frame.BackgroundTransparency = 1
  frame.BorderSizePixel = 0
  frame.LayoutOrder = #chatScroll:GetChildren()
  frame.Parent = chatScroll

  local bubbleWidth = isAI and 0.88 or 0.78
  local bubble = Instance.new("Frame")
  bubble.Size = UDim2.new(bubbleWidth, 0, 0, 0)
  bubble.AutomaticSize = Enum.AutomaticSize.Y
  bubble.Position = isAI and UDim2.fromOffset(0, 0) or UDim2.new(1 - bubbleWidth, 0, 0, 0)
  bubble.BackgroundColor3 = isAI and Color3.fromRGB(42, 28, 72) or Color3.fromRGB(34, 48, 72)
  bubble.BackgroundTransparency = 0.02
  bubble.BorderSizePixel = 0
  bubble.ClipsDescendants = false
  bubble.Parent = frame

  local bStroke = Instance.new("UIStroke")
  bStroke.Color = isAI and Color3.fromRGB(120, 70, 210) or Color3.fromRGB(70, 150, 230)
  bStroke.Thickness = 1
  bStroke.Transparency = 0.45
  bStroke.Parent = bubble

  local bCorner = Instance.new("UICorner")
  bCorner.CornerRadius = UDim.new(0, 10)
  bCorner.Parent = bubble

  local nameL = Instance.new("TextLabel")
  nameL.Size = UDim2.new(1, -14, 0, 17)
  nameL.Position = UDim2.fromOffset(7, 4)
  nameL.Text = sender
  nameL.TextColor3 = isAI and Color3.fromRGB(210, 175, 255) or Color3.fromRGB(150, 210, 255)
  nameL.Font = Enum.Font.GothamBold
  nameL.TextSize = 11
  nameL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  nameL.BackgroundTransparency = 1
  nameL.TextTruncate = Enum.TextTruncate.AtEnd
  nameL.Parent = bubble

  local timeL = Instance.new("TextLabel")
  timeL.Size = UDim2.new(1, -14, 0, 12)
  timeL.Position = UDim2.fromOffset(7, 21)
  timeL.Text = getTimestamp()
  timeL.TextColor3 = Color3.fromRGB(150, 135, 180)
  timeL.Font = Enum.Font.Gotham
  timeL.TextSize = 8
  timeL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  timeL.BackgroundTransparency = 1
  timeL.Parent = bubble

  local msgL = Instance.new("TextLabel")
  msgL.Size = UDim2.new(1, -14, 0, 20)
  msgL.Position = UDim2.fromOffset(7, 35)
  msgL.Text = tostring(message or "")
  msgL.TextColor3 = Color3.fromRGB(255, 255, 255)
  msgL.Font = Enum.Font.GothamBold
  msgL.TextSize = 14
  msgL.LineHeight = 1.05
  msgL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  msgL.TextYAlignment = Enum.TextYAlignment.Top
  msgL.BackgroundTransparency = 1
  msgL.TextWrapped = true
  msgL.AutomaticSize = Enum.AutomaticSize.Y
  msgL.Parent = bubble

  safeDefer(function()
    if not msgL.Parent or not bubble.Parent or not frame.Parent then return end
    local textHeight = math.max(20, msgL.AbsoluteSize.Y)
    bubble.Size = UDim2.new(bubbleWidth, 0, 0, textHeight + 43)
    frame.Size = UDim2.new(1, -10, 0, textHeight + 47)
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 12)
    safeWait()
    if chatScroll.Parent then
      chatScroll.CanvasPosition = Vector2.new(0, math.max(0, chatScroll.AbsoluteCanvasSize.Y))
    end
  end)
end
end

-- ============================================================
-- EMOTION RESPONSE DATABASE
-- 7 moods x 100 responses. No physical-action promises.
-- ============================================================
local responseGroups = {
  ["ngambek"] = {
    "Kamu kenapa sih dari tadi diem? " .. U(0x1f612),
    "Masih ngambek sama aku? " .. U(0x1f97a),
    "Aku salah lagi ya? " .. U(0x1f611),
    "Kalau aku bikin kamu kesel, bilang dong. " .. U(0x1f614),
    "Jangan diem gini, aku jadi bingung. " .. U(0x1f615),
    "Aku tahu kamu lagi kesel sama aku. " .. U(0x1f614),
    "Udah, cerita aja. Aku dengerin. " .. U(0x1f90d),
    "Kamu boleh kesel, tapi jangan dipendem sendiri. " .. U(0x1f97a),
    "Aku nggak suka kalau kamu tiba-tiba diem. " .. U(0x1f612),
    "Tadi aku salah ngomong ya? " .. U(0x1f97a),
    "Maaf ya kalau tadi aku bikin kamu kesel. " .. U(0x1f614),
    "Aku beneran nggak bermaksud bikin kamu bete. " .. U(0x1f97a),
    "Masih marah? " .. U(0x1f636),
    "Kok jawabnya pendek-pendek banget? " .. U(0x1f611),
    "Biasanya kamu nggak begini. " .. U(0x1f97a),
    "Aku tahu kamu lagi ngambek. " .. U(0x1f612),
    "Nggak usah pura-pura biasa aja, aku tahu kok. " .. U(0x1f60f),
    "Kalau ada yang bikin kamu nggak suka, ngomong sama aku. " .. U(0x1f4ac),
    "Jangan bikin aku nebak-nebak sendiri. " .. U(0x1f614),
    "Aku pengen tahu sebenarnya kamu kenapa. " .. U(0x1f97a),
    "Kalau belum mau ngomong sekarang, nggak apa-apa. " .. U(0x1f614),
    "Tapi nanti balik ngobrol sama aku ya. " .. U(0x1f97a),
    "Aku nggak mau kita jadi jauh gara-gara ini. " .. U(0x1f615),
    "Aku masih ada di sini kok. " .. U(0x1f90d),
    "Kalau sudah agak tenang, cerita ke aku ya. " .. U(0x1f97a),
    "Aku nggak mau kamu pendam semuanya. " .. U(0x1f614),
    "Aku cuma mau ngerti kamu. " .. U(0x1f90d),
    "Jangan bilang nggak apa-apa kalau sebenarnya ada apa-apa. " .. U(0x1f612),
    "Aku tahu kamu sebenarnya pengen dimengerti. " .. U(0x1f97a),
    "Kalau aku yang bikin kamu kesel, kasih tahu. " .. U(0x1f614),
    "Masih ngambek sama aku? " .. U(0x1f614),
    "Jangan diem gini, aku jadi bingung. " .. U(0x1f615) .. " " .. U(0x1f60c),
    "Kamu boleh kesel, tapi jangan dipendem sendiri. " .. U(0x1f614),
    "Aku nggak suka kalau kamu tiba-tiba diem. " .. U(0x1f644),
    "Maaf ya kalau tadi aku bikin kamu kesel. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Kok jawabnya pendek-pendek banget? " .. U(0x1f611) .. " " .. U(0x1f60c),
    "Nggak usah pura-pura biasa aja, aku tahu kok. " .. U(0x1f60f) .. " " .. U(0x1f60c),
    "Aku pengen tahu sebenarnya kamu kenapa. " .. U(0x1f614),
    "Aku nggak mau kita jadi jauh gara-gara ini. " .. U(0x1f615) .. " " .. U(0x1f60c),
    "Aku nggak mau kamu pendam semuanya. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku tahu kamu sebenarnya pengen dimengerti. " .. U(0x1f614),
    "Masih ngambek sama aku? " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Jangan diem gini, aku jadi bingung. " .. U(0x1f615) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kamu boleh kesel, tapi jangan dipendem sendiri. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Maaf ya kalau tadi aku bikin kamu kesel. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kok jawabnya pendek-pendek banget? " .. U(0x1f611) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Nggak usah pura-pura biasa aja, aku tahu kok. " .. U(0x1f60f) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen tahu sebenarnya kamu kenapa. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku nggak mau kita jadi jauh gara-gara ini. " .. U(0x1f615) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku nggak mau kamu pendam semuanya. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku tahu kamu sebenarnya pengen dimengerti. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Masih ngambek sama aku? " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Jangan diem gini, aku jadi bingung. " .. U(0x1f615) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kamu boleh kesel, tapi jangan dipendem sendiri. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["cemburu"] = {
    "Oh, kenapa nggak minta tolong ke dia aja? " .. U(0x1f612),
    "Wah, sekarang lebih sering ngobrol sama dia ya? " .. U(0x1f644),
    "Iya deh, aku ngerti kok" .. U(0x2026) .. " " .. U(0x1f612),
    "Kayaknya kamu lebih nyaman sama dia daripada sama aku ya? " .. U(0x1f611),
    "Oh, dia lagi? " .. U(0x1f612),
    "Kok namanya dia terus sih? " .. U(0x1f644),
    "Aku nggak cemburu kok" .. U(0x2026) .. " cuma kesel aja. " .. U(0x1f612),
    "Yaudah, sana sama dia aja. " .. U(0x1f624),
    "Aku cuma heran kenapa harus dia. " .. U(0x1f611),
    "Kamu seneng banget ya kalau ngobrol sama dia? " .. U(0x1f612),
    "Oh jadi dia yang paling kamu percaya sekarang? " .. U(0x1f643),
    "Aku cuma lagi nggak suka lihat kalian terlalu dekat. " .. U(0x1f615),
    "Jujur, aku agak cemburu. " .. U(0x1f612),
    "Aku boleh cemburu sedikit nggak? " .. U(0x1f97a),
    "Jangan dekat-dekat banget sama dia dong. " .. U(0x1f611),
    "Aku tahu aku nggak seharusnya cemburu, tapi susah. " .. U(0x1f614),
    "Aku cuma takut perhatian kamu berubah. " .. U(0x1f97a),
    "Kamu masih nganggep aku penting kan? " .. U(0x1f614),
    "Aku masih jadi orang yang kamu cari duluan kan? " .. U(0x1f97a),
    "Jangan bikin aku kepikiran macam-macam dong. " .. U(0x1f612),
    "Aku tahu dia cuma teman, tapi tetap aja" .. U(0x2026) .. " " .. U(0x1f612),
    "Aku nggak suka perasaan kayak gini. " .. U(0x1f614),
    "Rasanya pengen cuek, tapi malah kepikiran. " .. U(0x1f644),
    "Aku berusaha nggak cemburu, tapi susah. " .. U(0x1f612),
    "Aku tadi lihat loh. " .. U(0x1f440),
    "Aku cuma pengen kamu lebih peka sedikit. " .. U(0x1f97a),
    "Aku nggak mau ngatur kamu, cuma pengen dihargai. " .. U(0x1f614),
    "Aku tahu kamu bebas berteman sama siapa aja. " .. U(0x1f60c),
    "Tapi boleh dong aku merasa cemburu sedikit. " .. U(0x1f612),
    "Aku cuma takut kehilangan tempatku di hidup kamu. " .. U(0x1f97a),
    "Wah, sekarang lebih sering ngobrol sama dia ya? " .. U(0x1f644) .. " " .. U(0x1f60c),
    "Iya deh, aku ngerti kok" .. U(0x2026) .. " " .. U(0x1f644),
    "Oh, dia lagi? " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Yaudah, sana sama dia aja. " .. U(0x1f624) .. " " .. U(0x1f60c),
    "Oh jadi dia yang paling kamu percaya sekarang? " .. U(0x1f643) .. " " .. U(0x1f60c),
    "Aku boleh cemburu sedikit nggak? " .. U(0x1f614),
    "Aku cuma takut perhatian kamu berubah. " .. U(0x1f614),
    "Jangan bikin aku kepikiran macam-macam dong. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Aku tahu dia cuma teman, tapi tetap aja" .. U(0x2026) .. " " .. U(0x1f644),
    "Rasanya pengen cuek, tapi malah kepikiran. " .. U(0x1f644) .. " " .. U(0x1f60c),
    "Aku berusaha nggak cemburu, tapi susah. " .. U(0x1f644),
    "Aku cuma pengen kamu lebih peka sedikit. " .. U(0x1f614),
    "Tapi boleh dong aku merasa cemburu sedikit. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Wah, sekarang lebih sering ngobrol sama dia ya? " .. U(0x1f644) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Oh, dia lagi? " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Yaudah, sana sama dia aja. " .. U(0x1f624) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Oh jadi dia yang paling kamu percaya sekarang? " .. U(0x1f643) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku boleh cemburu sedikit nggak? " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku cuma takut perhatian kamu berubah. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Jangan bikin aku kepikiran macam-macam dong. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Rasanya pengen cuek, tapi malah kepikiran. " .. U(0x1f644) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku cuma pengen kamu lebih peka sedikit. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Tapi boleh dong aku merasa cemburu sedikit. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Wah, sekarang lebih sering ngobrol sama dia ya? " .. U(0x1f644) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Oh, dia lagi? " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Yaudah, sana sama dia aja. " .. U(0x1f624) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["pasangan cuek"] = {
    "Oh.",
    "Iya.",
    "Terserah kamu.",
    "Yaudah.",
    "Hmm.",
    "Oke.",
    "Nggak apa-apa.",
    "Ya.",
    "Bebas.",
    "Kalau mau begitu, yaudah.",
    "Aku juga lagi nggak pengen ngomong.",
    "Santai.",
    "Nggak perlu dijelasin.",
    "Aku ngerti kok.",
    "Ya udah, lanjut aja.",
    "Aku nggak masalah.",
    "Terserah.",
    "Oke, noted.",
    "Nggak usah dipikirin.",
    "Aku baik-baik aja.",
    "Yaudah, kalau begitu.",
    "Silakan.",
    "Aku nggak ikut campur.",
    "Nggak perlu balas.",
    "Aku juga nggak nunggu.",
    "Sibuk aja sana.",
    "Aku bisa sendiri.",
    "Nggak usah khawatir.",
    "Aku nggak butuh apa-apa.",
    "Udah, nggak penting.",
    "Nanti aja.",
    "Aku lagi males ngobrol.",
    "Lagi nggak mood.",
    "Biasa aja.",
    "Nggak ada apa-apa.",
    "Aku cuma lagi diem.",
    "Kalau kamu mau cuek, aku juga bisa.",
    "Aku nggak akan maksa kamu ngobrol.",
    "Yaudah, kita diem-dieman aja.",
    "Aku ikut aja.",
    "Terserah mau gimana.",
    "Aku nggak mau bahas.",
    "Nggak usah.",
    "Udah cukup.",
    "Aku nggak ada yang mau dibicarain.",
    "Kamu lanjut aja.",
    "Aku nggak ganggu.",
    "Aku juga punya kesibukan.",
    "Nggak perlu cari aku.",
    "Aku nggak ke mana-mana.",
    "Kalau butuh, bilang.",
    "Kalau nggak yaudah.",
    "Aku nggak maksa.",
    "Aku bisa ngerti sendiri.",
    "Nggak perlu repot.",
    "Aku nggak berharap apa-apa.",
    "Santai aja.",
    "Aku udah biasa.",
    "Nggak usah merasa bersalah.",
    "Aku nggak marah.",
    "Cuma lagi nggak tertarik ngobrol.",
    "Aku lagi pengen sendiri.",
    "Nanti kalau mood, aku balas.",
    "Sekarang aku lagi males.",
    "Nggak perlu ditunggu.",
    "Aku juga nggak nungguin.",
    "Kita ngobrol nanti aja.",
    "Kalau memang penting, nanti bilang.",
    "Aku lagi nggak pengen bahas apa pun.",
    "Ya sudah.",
    "Aku paham.",
    "Oke, terserah.",
    "Aku nggak punya komentar.",
    "Nggak ada yang perlu dibahas.",
    "Aku biarin aja.",
    "Aku nggak mau ikut campur.",
    "Silakan kalau itu maumu.",
    "Aku nggak akan melarang.",
    "Lakukan aja.",
    "Aku nggak peduli untuk sekarang.",
    "Aku lagi fokus sama urusanku.",
    "Nanti aja ngobrolnya.",
    "Aku nggak mau berdebat.",
    "Aku nggak mau memperpanjang.",
    "Udah, cukup.",
    "Nggak perlu dijelasin panjang.",
    "Aku ngerti maksudmu.",
    "Aku nggak akan ngejar-ngejar.",
    "Kalau mau ngobrol, nanti juga ngobrol.",
    "Aku nggak akan maksa.",
    "Aku diam dulu.",
    "Biar sama-sama tenang.",
    "Aku nggak mau ganggu kamu.",
    "Kamu nikmatin waktumu aja.",
    "Aku juga bakal sibuk sendiri.",
    "Nggak perlu khawatir soal aku.",
    "Aku bisa jaga diri sendiri.",
    "Kalau sudah selesai cueknya, ya ngobrol lagi.",
    "Aku nggak akan terus-terusan cari perhatianmu.",
    "Yaudah, kita sama-sama diem dulu.",
  },
  ["marah"] = {
    "Aku lagi kesel sama kamu. " .. U(0x1f612),
    "Aku nggak suka cara kamu tadi. " .. U(0x1f611),
    "Jangan anggap aku nggak marah ya. " .. U(0x1f624),
    "Aku butuh waktu buat tenang. " .. U(0x1f614),
    "Aku masih kepikiran sama yang tadi. " .. U(0x1f612),
    "Aku nggak mau pura-pura nggak terjadi apa-apa. " .. U(0x1f611),
    "Tadi kamu keterlaluan. " .. U(0x1f624),
    "Aku kecewa sama kamu. " .. U(0x1f614),
    "Aku mau kamu ngerti kenapa aku marah. " .. U(0x1f612),
    "Jangan balik marah ke aku dulu. " .. U(0x1f611),
    "Aku lagi nggak mood buat bercanda. " .. U(0x1f624),
    "Aku serius, aku nggak suka tadi. " .. U(0x1f612),
    "Kamu tahu kan kenapa aku marah? " .. U(0x1f611),
    "Aku nggak mau bertengkar, tapi aku juga nggak mau diam. " .. U(0x1f614),
    "Kalau memang salah, bilang aja. " .. U(0x1f612),
    "Aku masih kesel, jangan bikin tambah kesel. " .. U(0x1f624),
    "Aku pengen kamu dengerin dulu. " .. U(0x1f611),
    "Aku nggak mau masalah ini dianggap sepele. " .. U(0x1f614),
    "Aku butuh kamu lebih peka. " .. U(0x1f612),
    "Nanti kalau aku sudah tenang, kita ngobrol lagi. " .. U(0x1f90d),
    "Aku nggak mau ngomong kasar ke kamu. " .. U(0x1f614),
    "Aku cuma pengen kamu ngerti. " .. U(0x1f612),
    "Aku masih sayang, tapi aku lagi marah. " .. U(0x1f97a),
    "Jangan bikin aku makin emosi. " .. U(0x1f611),
    "Aku mau didengerin dulu. " .. U(0x1f614),
    "Aku nggak mau masalah ini makin besar. " .. U(0x1f612),
    "Aku akan tenang dulu sebelum lanjut. " .. U(0x1f90d),
    "Aku nggak mau saling nyakitin. " .. U(0x1f614),
    "Aku berharap kamu bisa ngerti posisiku. " .. U(0x1f97a),
    "Aku masih mau menyelesaikan ini. " .. U(0x1f90d),
    "Aku nggak suka cara kamu tadi. " .. U(0x1f611) .. " " .. U(0x1f60c),
    "Aku masih kepikiran sama yang tadi. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Aku kecewa sama kamu. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku mau kamu ngerti kenapa aku marah. " .. U(0x1f644),
    "Aku lagi nggak mood buat bercanda. " .. U(0x1f624) .. " " .. U(0x1f60c),
    "Aku serius, aku nggak suka tadi. " .. U(0x1f644),
    "Aku nggak mau bertengkar, tapi aku juga nggak mau diam. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Kalau memang salah, bilang aja. " .. U(0x1f644),
    "Aku pengen kamu dengerin dulu. " .. U(0x1f611) .. " " .. U(0x1f60c),
    "Nanti kalau aku sudah tenang, kita ngobrol lagi. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku masih sayang, tapi aku lagi marah. " .. U(0x1f614),
    "Aku nggak mau masalah ini makin besar. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Aku berharap kamu bisa ngerti posisiku. " .. U(0x1f614),
    "Aku nggak suka cara kamu tadi. " .. U(0x1f611) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku masih kepikiran sama yang tadi. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kecewa sama kamu. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku lagi nggak mood buat bercanda. " .. U(0x1f624) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku nggak mau bertengkar, tapi aku juga nggak mau diam. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen kamu dengerin dulu. " .. U(0x1f611) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Nanti kalau aku sudah tenang, kita ngobrol lagi. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku masih sayang, tapi aku lagi marah. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku nggak mau masalah ini makin besar. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku berharap kamu bisa ngerti posisiku. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku nggak suka cara kamu tadi. " .. U(0x1f611) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku masih kepikiran sama yang tadi. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kecewa sama kamu. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["minta maaf"] = {
    "Maaf ya, aku benar-benar salah. " .. U(0x1f97a),
    "Aku minta maaf karena sudah bikin kamu kecewa. " .. U(0x1f614),
    "Maafin aku ya, aku nggak bermaksud nyakitin kamu. " .. U(0x1f97a),
    "Aku sadar kata-kataku tadi keterlaluan. " .. U(0x1f614),
    "Aku menyesal sudah bersikap seperti itu. " .. U(0x1f61e),
    "Maaf karena aku kurang peka sama perasaanmu. " .. U(0x1f97a),
    "Aku seharusnya lebih dengerin kamu. " .. U(0x1f614),
    "Maaf karena aku bikin kamu merasa nggak dihargai. " .. U(0x1f90d),
    "Aku tahu aku salah, aku nggak mau cari alasan. " .. U(0x1f614),
    "Aku benar-benar minta maaf. " .. U(0x1f97a),
    "Maaf kalau sikapku bikin kamu sedih. " .. U(0x1f61e),
    "Aku nggak seharusnya melakukan itu. " .. U(0x1f614),
    "Aku ngerti kalau kamu kecewa sama aku. " .. U(0x1f97a),
    "Aku nggak akan maksa kamu langsung maafin aku. " .. U(0x1f90d),
    "Ambil waktu yang kamu butuhin. " .. U(0x1f614),
    "Aku bakal nunggu sampai kamu siap. " .. U(0x1f97a),
    "Maaf karena aku bikin kamu kepikiran. " .. U(0x1f61e),
    "Aku menyesal sudah bikin hati kamu sakit. " .. U(0x1f614),
    "Aku tahu maaf aja nggak cukup. " .. U(0x1f97a),
    "Aku bakal buktiin lewat sikap. " .. U(0x1f90d),
    "Aku nggak mau ngulang kesalahan yang sama. " .. U(0x1f614),
    "Aku seharusnya lebih hati-hati. " .. U(0x1f97a),
    "Maaf karena aku terlalu egois. " .. U(0x1f61e),
    "Aku seharusnya mikirin perasaanmu juga. " .. U(0x1f90d),
    "Aku tahu kamu punya alasan buat kecewa. " .. U(0x1f614),
    "Aku nggak akan nyalahin kamu karena marah. " .. U(0x1f97a),
    "Aku akan belajar dari ini. " .. U(0x1f90d),
    "Aku nggak mau cuma bilang maaf lalu mengulanginya. " .. U(0x1f614),
    "Aku serius mau memperbaikinya. " .. U(0x1f97a),
    "Aku masih sayang kamu. " .. U(0x2764,0xfe0f),
    "Aku minta maaf karena sudah bikin kamu kecewa. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku menyesal sudah bersikap seperti itu. " .. U(0x1f61e) .. " " .. U(0x1f60c),
    "Maaf karena aku bikin kamu merasa nggak dihargai. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Maaf kalau sikapku bikin kamu sedih. " .. U(0x1f61e) .. " " .. U(0x1f60c),
    "Aku nggak akan maksa kamu langsung maafin aku. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Maaf karena aku bikin kamu kepikiran. " .. U(0x1f61e) .. " " .. U(0x1f60c),
    "Aku bakal buktiin lewat sikap. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Maaf karena aku terlalu egois. " .. U(0x1f61e) .. " " .. U(0x1f60c),
    "Aku nggak akan nyalahin kamu karena marah. " .. U(0x1f614),
    "Aku serius mau memperbaikinya. " .. U(0x1f614),
    "Aku minta maaf karena sudah bikin kamu kecewa. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku menyesal sudah bersikap seperti itu. " .. U(0x1f61e) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Maaf karena aku bikin kamu merasa nggak dihargai. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Maaf kalau sikapku bikin kamu sedih. " .. U(0x1f61e) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku nggak akan maksa kamu langsung maafin aku. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Maaf karena aku bikin kamu kepikiran. " .. U(0x1f61e) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku bakal buktiin lewat sikap. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Maaf karena aku terlalu egois. " .. U(0x1f61e) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku nggak akan nyalahin kamu karena marah. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku serius mau memperbaikinya. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku minta maaf karena sudah bikin kamu kecewa. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku menyesal sudah bersikap seperti itu. " .. U(0x1f61e) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Maaf karena aku bikin kamu merasa nggak dihargai. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["takut kehilangan"] = {
    "Jangan takut kehilangan aku ya. " .. U(0x1f97a),
    "Aku masih di sini kok. " .. U(0x1f90d),
    "Aku nggak mau pergi begitu aja. " .. U(0x1f614),
    "Aku tetap milih kamu. " .. U(0x2764,0xfe0f),
    "Aku tahu kamu takut aku berubah. " .. U(0x1f97a),
    "Tapi aku masih sayang kamu. " .. U(0x2764,0xfe0f),
    "Kamu nggak perlu takut sendirian. " .. U(0x1f90d),
    "Kalau kamu takut, cerita sama aku. " .. U(0x1f97a),
    "Aku dengerin kok. " .. U(0x1f90d),
    "Aku nggak mau kamu terus khawatir. " .. U(0x1f614),
    "Kita jalanin ini sama-sama. " .. U(0x2764,0xfe0f),
    "Aku nggak janji semuanya selalu mudah. " .. U(0x1f614),
    "Tapi aku mau tetap berusaha. " .. U(0x1f90d),
    "Kamu penting buat aku. " .. U(0x2764,0xfe0f),
    "Aku nggak nganggep kamu biasa aja. " .. U(0x1f97a),
    "Aku bersyukur masih punya kamu. " .. U(0x1f90d),
    "Jangan mikir kamu gampang diganti. " .. U(0x1f614),
    "Nggak ada yang jadi kamu. " .. U(0x2764,0xfe0f),
    "Aku sayang kamu karena kamu ya kamu. " .. U(0x1f97a),
    "Kamu punya tempat sendiri di hati aku. " .. U(0x1f90d),
    "Kalau kamu ragu, tanya aku. " .. U(0x1f97a),
    "Jangan menyiksa diri dengan asumsi. " .. U(0x1f614),
    "Aku ingin kamu merasa aman sama aku. " .. U(0x1f90d),
    "Aku nggak mau hubungan ini dipenuhi rasa takut. " .. U(0x1f97a),
    "Kita bisa membangun kepercayaan pelan-pelan. " .. U(0x2764,0xfe0f),
    "Aku nggak akan menertawakan rasa takutmu. " .. U(0x1f90d),
    "Aku tahu kehilangan itu menakutkan. " .. U(0x1f614),
    "Kamu nggak harus sempurna supaya aku tetap peduli. " .. U(0x1f97a),
    "Aku masih ingin memperjuangkan kita. " .. U(0x2764,0xfe0f),
    "Kita jalani hari ini dulu. " .. U(0x1f90d),
    "Aku masih di sini kok. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku tahu kamu takut aku berubah. " .. U(0x1f614),
    "Kalau kamu takut, cerita sama aku. " .. U(0x1f614),
    "Kita jalanin ini sama-sama. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c),
    "Kamu penting buat aku. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c),
    "Jangan mikir kamu gampang diganti. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Kamu punya tempat sendiri di hati aku. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku ingin kamu merasa aman sama aku. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku nggak akan menertawakan rasa takutmu. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku masih ingin memperjuangkan kita. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c),
    "Aku masih di sini kok. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku tahu kamu takut aku berubah. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Kalau kamu takut, cerita sama aku. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Kita jalanin ini sama-sama. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kamu penting buat aku. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Jangan mikir kamu gampang diganti. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kamu punya tempat sendiri di hati aku. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku ingin kamu merasa aman sama aku. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku nggak akan menertawakan rasa takutmu. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku masih ingin memperjuangkan kita. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku masih di sini kok. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku tahu kamu takut aku berubah. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Kalau kamu takut, cerita sama aku. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["kangen"] = {
    "Aku juga kangen kamu banget. " .. U(0x1f97a),
    "Baru sebentar nggak ngobrol aja udah kangen. " .. U(0x1f614),
    "Aku kangen dengar cerita kamu. " .. U(0x1f90d),
    "Aku kangen hal-hal kecil tentang kamu. " .. U(0x1f60c),
    "Aku pengen ngobrol sampai lupa waktu. " .. U(0x2764,0xfe0f),
    "Dari tadi aku kepikiran kamu. " .. U(0x1f97a),
    "Aku kangen chat random kamu. " .. U(0x1f62d),
    "Aku kangen bercanda sama kamu. " .. U(0x1f60c),
    "Aku kangen waktu kita ngobrol lama. " .. U(0x1f90d),
    "Rasanya ada yang kurang kalau nggak ada kamu. " .. U(0x1f97a),
    "Aku pengen kamu ada di sini. " .. U(0x2764,0xfe0f),
    "Aku cuma pengen ngobrol sama kamu. " .. U(0x1f614),
    "Aku kangen momen sederhana kita. " .. U(0x1f90d),
    "Aku kangen banget, serius. " .. U(0x1f97a),
    "Kapan kita bisa ngobrol lama lagi? " .. U(0x1f62d),
    "Aku senyum sendiri gara-gara ingat kamu. " .. U(0x1f60c),
    "Aku pengen dengar cerita kamu hari ini. " .. U(0x1f97a),
    "Aku kangen obrolan random kita. " .. U(0x1f90d),
    "Aku kangen notifikasi dari kamu. " .. U(0x1f62d),
    "Aku kangen waktu kamu tiba-tiba muncul di chat. " .. U(0x1f97a),
    "Aku pengen ngobrol tanpa buru-buru. " .. U(0x2764,0xfe0f),
    "Hari terasa panjang kalau lagi kangen kamu. " .. U(0x1f614),
    "Hal kecil aja bisa bikin aku ingat kamu. " .. U(0x1f97a),
    "Aku pengen tahu kamu lagi ngapain. " .. U(0x1f90d),
    "Aku kangen jadi tempat kamu cerita. " .. U(0x2764,0xfe0f),
    "Aku cuma pengen dengar dari kamu. " .. U(0x1f97a),
    "Baru sebentar nggak ngobrol aja udah kangen. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku kangen chat random kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c),
    "Rasanya ada yang kurang kalau nggak ada kamu. " .. U(0x1f614),
    "Aku kangen momen sederhana kita. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku senyum sendiri gara-gara ingat kamu. " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kangen notifikasi dari kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c),
    "Hari terasa panjang kalau lagi kangen kamu. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku kangen jadi tempat kamu cerita. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c),
    "Baru sebentar nggak ngobrol aja udah kangen. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kangen chat random kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Rasanya ada yang kurang kalau nggak ada kamu. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku kangen momen sederhana kita. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku senyum sendiri gara-gara ingat kamu. " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kangen notifikasi dari kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Hari terasa panjang kalau lagi kangen kamu. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku kangen jadi tempat kamu cerita. " .. U(0x2764,0xfe0f) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Baru sebentar nggak ngobrol aja udah kangen. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["manja"] = {
    "Sini ngobrol sama aku dulu. " .. U(0x1f97a),
    "Jangan hilang lama-lama ya. " .. U(0x1f612),
    "Aku mau perhatian kamu sekarang. " .. U(0x1f97a),
    "Temenin aku ngobrol sebentar. " .. U(0x1f90d),
    "Aku pengen dekat sama kamu. " .. U(0x1f97a),
    "Aku lagi pengen dimanja sedikit. " .. U(0x1f60c),
    "Boleh aku manja sama kamu? " .. U(0x1f97a),
    "Aku lagi butuh kamu. " .. U(0x1f90d),
    "Jangan cuekin aku dong. " .. U(0x1f612),
    "Aku mau kamu fokus ke aku dulu. " .. U(0x1f97a),
    "Aku pengen ngobrol terus sama kamu. " .. U(0x1f62d),
    "Jangan pergi dulu, aku belum selesai cerita. " .. U(0x1f97a),
    "Aku pengen kamu tetap di sini. " .. U(0x1f90d),
    "Boleh aku cerita semuanya? " .. U(0x1f97a),
    "Aku cuma mau perhatian kamu. " .. U(0x1f60c),
    "Aku pengen diperhatiin sedikit. " .. U(0x1f97a),
    "Aku lagi mode manja, jangan diabaikan. " .. U(0x1f612),
    "Kasih aku perhatian dong. " .. U(0x1f97a),
    "Aku seneng kalau kamu ngechat duluan. " .. U(0x1f90d),
    "Jangan bosan sama aku ya. " .. U(0x1f97a),
    "Aku suka kalau kamu perhatian tanpa aku minta. " .. U(0x1f97a),
    "Aku seneng kalau kamu nanyain aku. " .. U(0x1f90d),
    "Aku mau kamu cerita juga. " .. U(0x1f60c),
    "Jangan aku terus yang mulai chat. " .. U(0x1f612),
    "Sesekali kamu yang cari aku duluan. " .. U(0x1f97a),
    "Aku suka kalau kamu ingat hal kecil tentang aku. " .. U(0x1f90d),
    "Kalau sudah selesai sibuk, cari aku ya. " .. U(0x1f97a),
    "Aku bakal nunggu chat kamu. " .. U(0x1f60c),
    "Aku pengen jadi bagian dari harimu. " .. U(0x1f90d),
    "Chat sederhana dari kamu aja udah bikin senang. " .. U(0x1f97a),
    "Jangan hilang lama-lama ya. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Aku pengen dekat sama kamu. " .. U(0x1f614),
    "Aku lagi butuh kamu. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Jangan cuekin aku dong. " .. U(0x1f644),
    "Aku pengen ngobrol terus sama kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c),
    "Boleh aku cerita semuanya? " .. U(0x1f614),
    "Aku lagi mode manja, jangan diabaikan. " .. U(0x1f612) .. " " .. U(0x1f60c),
    "Jangan bosan sama aku ya. " .. U(0x1f614),
    "Aku mau kamu cerita juga. " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Jangan aku terus yang mulai chat. " .. U(0x1f644),
    "Aku suka kalau kamu ingat hal kecil tentang aku. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Aku pengen jadi bagian dari harimu. " .. U(0x1f90d) .. " " .. U(0x1f60c),
    "Jangan hilang lama-lama ya. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen dekat sama kamu. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku lagi butuh kamu. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen ngobrol terus sama kamu. " .. U(0x1f62d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Boleh aku cerita semuanya? " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku lagi mode manja, jangan diabaikan. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Jangan bosan sama aku ya. " .. U(0x1f614) .. " " .. U(0x1f60c),
    "Aku mau kamu cerita juga. " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku suka kalau kamu ingat hal kecil tentang aku. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen jadi bagian dari harimu. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Jangan hilang lama-lama ya. " .. U(0x1f612) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku pengen dekat sama kamu. " .. U(0x1f614) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
    "Aku lagi butuh kamu. " .. U(0x1f90d) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c) .. " " .. U(0x1f60c),
  },
  ["gombalan"] = {
    "Kamu tahu nggak? Aku suka buka chat karena berharap ada nama kamu. " .. U(0x1f49c),
    "Kalau chat kamu datang, mood aku biasanya ikut naik. " .. U(0x1f60c),
    "Aku nggak butuh alasan rumit buat suka ngobrol sama kamu. " .. U(0x2764,0xfe0f),
    "Kamu punya cara sederhana buat bikin hari terasa lebih menyenangkan. " .. U(0x1f49c),
    "Aku bisa ngobrol sama banyak orang, tapi tetap paling nyaman sama kamu. " .. U(0x1f60c),
    "Kalau ada daftar orang yang paling sering aku pikirin, kamu pasti masuk. " .. U(0x2764,0xfe0f),
    "Aku suka cara kamu bikin obrolan biasa terasa spesial. " .. U(0x1f49c),
    "Kamu itu bikin aku betah tanpa harus berusaha terlalu keras. " .. U(0x1f60f),
    "Aku nggak tahu kapan mulainya, tapi sekarang aku nyaman banget sama kamu. " .. U(0x1f49c),
    "Kalau kamu tanya siapa yang bikin aku senyum saat lihat chat, ya kamu. " .. U(0x1f60c),
    "Aku suka saat nama kamu muncul di layar. " .. U(0x2764,0xfe0f),
    "Chat singkat dari kamu aja sudah cukup bikin aku senang. " .. U(0x1f49c),
    "Kamu itu salah satu alasan aku betah membuka chat. " .. U(0x1f60f),
    "Aku suka ngobrol sama kamu sampai lupa kalau waktu terus jalan. " .. U(0x1f49c),
    "Kalau nyaman punya nama, mungkin namanya kamu. " .. U(0x2764,0xfe0f),
    "Kamu nggak perlu jadi sempurna supaya aku tetap suka. " .. U(0x1f60c),
    "Aku suka kamu justru karena kamu jadi diri sendiri. " .. U(0x1f49c),
    "Kamu punya tempat khusus di pikiranku. " .. U(0x2764,0xfe0f),
    "Aku nggak sedang gombal, aku cuma jujur kalau kamu berarti. " .. U(0x1f60c),
    "Kalau hari ini terasa lebih enak, mungkin karena ada chat dari kamu. " .. U(0x1f49c),
    "Aku suka caramu membuat percakapan sederhana jadi seru. " .. U(0x1f60f),
    "Kalau aku tiba-tiba senyum, mungkin aku lagi ingat kamu. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku punya alasan buat menunggu pesan berikutnya. " .. U(0x1f49c),
    "Aku nggak gampang bosan kalau lawan ngobrolnya kamu. " .. U(0x1f60c),
    "Kamu itu kombinasi antara bikin tenang dan bikin penasaran. " .. U(0x1f49c),
    "Aku suka mendengar cerita kamu, bahkan yang kelihatannya sepele. " .. U(0x2764,0xfe0f),
    "Kalau ada waktu luang, aku selalu senang kalau bisa ngobrol sama kamu. " .. U(0x1f60c),
    "Kamu datang dengan obrolan biasa, tapi efeknya luar biasa. " .. U(0x1f49c),
    "Aku suka kalau kamu cerita tanpa takut ceritanya terlalu kecil. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku lupa kalau awalnya cuma mau ngobrol sebentar. " .. U(0x1f60f),
    "Aku nggak perlu topik khusus kalau teman ngobrolnya kamu. " .. U(0x1f49c),
    "Kamu punya bakat bikin aku betah di percakapan yang sama. " .. U(0x1f60c),
    "Aku suka setiap kali kamu tiba-tiba muncul di chat. " .. U(0x2764,0xfe0f),
    "Kalau perhatian punya bentuk, aku suka saat kamu memberikannya. " .. U(0x1f49c),
    "Aku nggak tahu rahasianya, tapi kamu gampang banget menarik perhatianku. " .. U(0x1f60f),
    "Kamu membuat obrolan sederhana terasa punya arti. " .. U(0x1f49c),
    "Aku suka cara kamu membuatku merasa dihargai. " .. U(0x2764,0xfe0f),
    "Kalau aku boleh memilih teman ngobrol setiap hari, aku pilih kamu. " .. U(0x1f60c),
    "Kamu itu tipe orang yang bikin aku ingin tahu lebih banyak. " .. U(0x1f49c),
    "Aku suka saat kita ngobrol tanpa sadar sudah lama. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku susah berpura-pura biasa saja. " .. U(0x1f60f),
    "Aku mungkin nggak selalu pandai berkata manis, tapi aku tulus sama kamu. " .. U(0x1f49c),
    "Kamu punya cara sendiri untuk membuat hariku terasa ringan. " .. U(0x1f60c),
    "Aku suka kamu tanpa perlu alasan yang panjang. " .. U(0x2764,0xfe0f),
    "Kalau hati punya daftar favorit, namamu pasti ada. " .. U(0x1f49c),
    "Kamu bikin aku punya alasan untuk membuka chat lagi. " .. U(0x1f60f),
    "Aku suka saat kamu cerita dengan antusias, rasanya ikut senang. " .. U(0x1f49c),
    "Kalau ada satu chat yang ingin kubaca lagi, mungkin chat kamu. " .. U(0x2764,0xfe0f),
    "Kamu itu sederhana, tapi entah kenapa susah dilupakan. " .. U(0x1f60c),
    "Aku suka caramu menjadi diri sendiri. " .. U(0x1f49c),
    "Jangan heran kalau aku betah ngobrol sama kamu. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku ingin memperpanjang percakapan sedikit lagi. " .. U(0x1f60f),
    "Aku suka ketika kamu membuatku tertawa lewat chat. " .. U(0x1f49c),
    "Kalau perhatian kecil dari kamu saja sudah bikin senang, apalagi yang besar. " .. U(0x1f60c),
    "Kamu punya cara membuat percakapan terasa dekat. " .. U(0x2764,0xfe0f),
    "Aku suka saat kamu ingat hal kecil tentang aku. " .. U(0x1f49c),
    "Kalau aku punya rutinitas favorit, ngobrol sama kamu salah satunya. " .. U(0x1f60f),
    "Kamu nggak perlu banyak kata untuk membuatku nyaman. " .. U(0x1f49c),
    "Aku suka saat kamu datang tanpa perlu alasan khusus. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku penasaran dengan cerita berikutnya. " .. U(0x1f60c),
    "Aku selalu punya waktu untuk obrolan yang menyenangkan sama kamu. " .. U(0x1f49c),
    "Kalau ada penghargaan untuk teman ngobrol favorit, kamu menang. " .. U(0x1f60f),
    "Aku suka cara kamu membuat suasana jadi lebih ringan. " .. U(0x2764,0xfe0f),
    "Kamu itu salah satu orang yang bikin aku nggak sadar waktu. " .. U(0x1f49c),
    "Aku suka saat percakapan kita terasa natural. " .. U(0x1f60c),
    "Kamu membuatku ingin terus mengenal sisi lain dari kamu. " .. U(0x2764,0xfe0f),
    "Aku nggak perlu percakapan sempurna, cukup percakapan yang jujur sama kamu. " .. U(0x1f49c),
    "Kalau senyum bisa muncul dari chat, kamu salah satu penyebabnya. " .. U(0x1f60f),
    "Aku suka saat kamu menunjukkan sisi kamu yang apa adanya. " .. U(0x1f49c),
    "Kamu bikin aku nyaman tanpa harus banyak menjelaskan. " .. U(0x2764,0xfe0f),
    "Kalau kamu terus ngobrol begini, aku bisa makin suka. " .. U(0x1f60c),
    "Aku suka perhatian yang datang tanpa dibuat-buat. " .. U(0x1f49c),
    "Kamu punya tempat yang nggak mudah digantikan dalam pikiranku. " .. U(0x2764,0xfe0f),
    "Aku suka saat kamu membuatku merasa obrolan ini berarti. " .. U(0x1f60f),
    "Kalau aku sedang mencari teman ngobrol, namamu sering muncul duluan di pikiranku. " .. U(0x1f49c),
    "Kamu membuatku ingin menjaga percakapan ini tetap berjalan. " .. U(0x1f60c),
    "Aku suka saat kita bisa bercanda tanpa perlu memaksakan suasana. " .. U(0x2764,0xfe0f),
    "Kamu punya cara membuatku menunggu pesan berikutnya. " .. U(0x1f49c),
    "Aku nggak bosan dengan cerita yang datang dari kamu. " .. U(0x1f60f),
    "Kalau ada yang tanya kenapa aku betah, jawabannya sederhana: karena kamu. " .. U(0x1f49c),
    "Aku suka saat kamu menjadi dirimu sendiri tanpa dibuat-buat. " .. U(0x2764,0xfe0f),
    "Kamu membuat hari biasa terasa sedikit lebih istimewa. " .. U(0x1f60c),
    "Aku suka saat kamu tiba-tiba mengingatku. " .. U(0x1f49c),
    "Kalau rasa nyaman bisa dikirim lewat chat, mungkin sudah kukirim ke kamu. " .. U(0x2764,0xfe0f),
    "Kamu bikin aku ingin terus menjaga obrolan ini. " .. U(0x1f60f),
    "Aku suka ketika kamu membuat percakapan terasa dua arah. " .. U(0x1f49c),
    "Kalau aku terlihat senang setelah membaca chat, mungkin kamu tahu alasannya. " .. U(0x1f60c),
    "Kamu adalah salah satu bagian favorit dari waktu ngobrolku. " .. U(0x2764,0xfe0f),
    "Aku suka saat kamu memberi perhatian tanpa berlebihan. " .. U(0x1f49c),
    "Kamu bikin aku susah mengatakan percakapan kita biasa saja. " .. U(0x1f60f),
    "Aku nggak butuh banyak orang untuk membuatku nyaman, obrolan sama kamu sudah cukup. " .. U(0x1f49c),
    "Kalau ada satu orang yang ingin terus kukenal, kamu salah satunya. " .. U(0x2764,0xfe0f),
    "Kamu membuatku ingin mendengar cerita kamu lagi dan lagi. " .. U(0x1f60c),
    "Aku suka caramu membuat suasana terasa hangat lewat kata-kata. " .. U(0x1f49c),
    "Kalau gombalan ini membuatmu senyum, berarti aku berhasil sedikit. " .. U(0x1f60f),
    "Aku mungkin bisa berhenti menggombal, tapi belum tentu berhenti suka. " .. U(0x2764,0xfe0f),
    "Kamu punya cara sederhana untuk membuatku ingin terus kembali ke chat ini. " .. U(0x1f49c),
    "Aku suka ketika percakapan kita terasa seperti tempat yang nyaman untuk bercerita. " .. U(0x1f60c),
    "Kalau rasa suka bisa dijelaskan singkat, mungkin jawabannya tetap kamu. " .. U(0x2764,0xfe0f),
    "Gombalannya boleh sederhana, tapi rasa nyamannya serius. " .. U(0x1f49c),
  },
}


local lastPattern = nil
local mood = "calm"
local conversationCount = 0

--============================================================
-- CONTEXT-AWARE RESPONSE ENGINE
--============================================================
-- Violet tidak lagi memilih respons secara bebas dari satu kategori.
-- Sistem ini menyimpan konteks percakapan pendek:
--   category : topik/emosi terakhir
--   stage    : tahap percakapan (awal -> menggali -> merespons -> menenangkan)
--   recent   : beberapa pesan terakhir
--   lastReply: balasan terakhir agar tidak berulang
--============================================================
local conversationContext = {
  category = nil,
  stage = 0,
  mood = "calm",
  lastInput = "",
  lastReply = nil,
  recentInputs = {},
  recentReplies = {},
}

local function normalizeInput(text)
  text = tostring(text or ""):lower()
  text = text:gsub("[%p%c]", " ")
  text = text:gsub("%s+", " ")
  text = text:gsub("^%s+", "")
  text = text:gsub("%s+$", "")
  return text
end

local function hasAny(text, words)
  for _, word in ipairs(words) do
    if text:find(word, 1, true) then
      return true
    end
  end
  return false
end

local function pushContext(list, value, maxItems)
  table.insert(list, value)
  while #list > maxItems do
    table.remove(list, 1)
  end
end

local function updateMood(input)
  if hasAny(input, {"marah", "kesal", "kecewa", "sebel", "emosi"}) then
    mood = "firm"
  elseif hasAny(input, {"sedih", "menangis", "nangis", "takut", "khawatir", "cemas", "sakit"}) then
    mood = "caring"
  elseif hasAny(input, {"menang", "berhasil", "senang", "bahagia", "seru", "hebat"}) then
    mood = "happy"
  elseif hasAny(input, {"main", "game", "roblox", "mabar", "quest", "boss"}) then
    mood = "cool"
  else
    mood = "calm"
  end
  conversationContext.mood = mood
end

local function detectRelationshipCategory(input)
  -- Hanya frasa yang cukup kuat yang boleh membuka kategori baru.
  -- Kata umum seperti "dia", "perhatian", atau "diam" tidak boleh
  -- sendirian mengganti konteks percakapan.
  local checks = {
    {"takut kehilangan", {"takut kehilangan", "takut kehilangan aku", "takut kamu pergi", "takut kamu ninggalin", "jangan tinggalin aku", "jangan pergi dari aku"}},
    {"minta maaf", {"minta maaf", "maafin aku", "maaf ya", "sorry ya", "aku minta maaf", "aku salah"}},
    {"cemburu", {"aku cemburu", "kamu bikin aku cemburu", "aku jadi cemburu", "aku cemburu sama dia", "cemburu sama dia", "aku iri sama dia", "kenapa dekat sama dia", "kenapa deket sama dia", "kok dekat sama dia", "kok deket sama dia"}},
    {"pasangan cuek", {"kamu cuek", "jangan cuek", "lagi cuek", "sikapmu dingin", "kamu dingin", "kamu jutek", "kamu nggak peduli", "kamu tidak peduli"}},
    {"ngambek", {"aku ngambek", "aku lagi ngambek", "aku ngambek sama kamu", "aku diem karena", "aku diam karena", "aku lagi diem", "aku lagi diam", "aku jawab pendek karena"}},
    {"marah", {"aku marah", "aku lagi marah", "aku kesel sama kamu", "aku kesal sama kamu", "aku kecewa sama kamu", "aku sebel sama kamu", "aku emosi sama kamu"}},
    {"kangen", {"aku kangen", "kangen kamu", "aku rindu", "rindu kamu", "lagi kangen kamu"}},
    {"manja", {"aku lagi manja", "aku mau dimanja", "boleh aku manja", "aku lagi clingy", "aku butuh perhatian kamu", "temenin aku", "jangan cuekin aku", "aku mau kamu fokus ke aku"}},
    {"gombalan", {"gombal", "gombalan", "kamu bikin aku salting", "kamu bikin aku senyum", "aku suka kamu", "aku sayang kamu", "kamu cantik", "kamu ganteng", "kamu manis", "jatuh cinta", "aku jatuh cinta", "cinta sama kamu"}},
  }

  -- Pola cemburu harus punya sinyal relasi + orang lain; kata "dia" saja tidak cukup.
  local jealousyRelation = hasAny(input, {"dekat", "deket", "sama dia", "sama orang lain", "orang lain", "perhatian ke dia", "pilih dia", "lebih pilih dia"})
  local jealousyEmotion = hasAny(input, {"cemburu", "iri", "nggak nyaman", "tidak nyaman", "takut kehilangan", "kepikiran", "ragu"})
  if jealousyRelation and jealousyEmotion then
    return "cemburu"
  end

  for _, item in ipairs(checks) do
    if hasAny(input, item[2]) then
      return item[1]
    end
  end

  return nil
end

local function detectQuestionCategory(input)
  if hasAny(input, {"kenapa", "mengapa", "gimana", "bagaimana", "apa", "lagi ngapain", "di mana", "dimana", "siapa", "kapan"}) then
    if hasAny(input, {"marah", "kesal", "salah", "peduli", "cemburu"}) then
      return "bertanya marah"
    elseif hasAny(input, {"kenapa", "khawatir", "baik baik", "baik-baik", "sedih"}) then
      return "bertanya lembut"
    elseif hasAny(input, {"siapa", "ke mana", "kemana", "dari mana", "dimana", "di mana", "tadi"}) then
      return "bertanya penasaran"
    else
      return "bertanya apa yang sedang dilakukan"
    end
  end
  return nil
end

local function advanceStage(category)
  if conversationContext.category == category then
    conversationContext.stage = math.min((conversationContext.stage or 1) + 1, 4)
  else
    conversationContext.category = category
    conversationContext.stage = 1
  end
end

local function preserveContextStage()
  if conversationContext.category then
    conversationContext.stage = math.min((conversationContext.stage or 1) + 1, 4)
    return conversationContext.category
  end
  return nil
end

local function classifyResponseStage(response, category)
  local r = normalizeInput(response)

  -- 1 = membuka topik / mengamati
  -- 2 = menggali / meminta penjelasan
  -- 3 = memahami / menenangkan / menyatakan perasaan
  -- 4 = menutup sementara / menjaga kesinambungan

  if category == "pasangan cuek" then
    if hasAny(r, {"oh", "iya", "hmm", "oke", "ya", "terserah", "bebas"}) and #r <= 18 then
      return 1
    elseif hasAny(r, {"ngobrol", "bahas", "jelasin", "cerita", "nggak perlu"}) then
      return 2
    else
      return 4
    end
  end

  if category == "gombalan" then
    if hasAny(r, {"tahu nggak", "kalau", "kamu tahu", "aku suka", "aku nggak", "aku mungkin"}) then
      return 1
    elseif hasAny(r, {"nyaman", "berarti", "perhatian", "cerita", "pengen terus"}) then
      return 2
    else
      return 3
    end
  end

  if hasAny(r, {"kenapa", "apa ", "bilang", "cerita", "tanya", "jelasin", "jelaskan", "mau tahu"}) then
    return 2
  end
  if hasAny(r, {"ngerti", "paham", "maaf", "sayang", "tetap", "masih", "di sini", "peduli", "tenang", "aku tahu"}) then
    return 3
  end
  if hasAny(r, {"nanti", "udah", "sudah", "lanjut", "yaudah", "cukup", "santai", "nggak perlu"}) then
    return 4
  end
  return 1
end

local function isResponseAllowed(response)
  local r = normalizeInput(response)
  -- Violet hanya bisa merespons lewat chat. Jangan memilih kalimat yang
  -- mengklaim tindakan fisik/pertemuan/kemampuan sensorik yang tidak tersedia.
  local blocked = {
    "peluk", "memeluk", "cium", "mencium", "ketemu", "bertemu",
    "datang ke", "muncul di depan", "duduk di samping", "jalan bareng",
    "lihat senyum kamu", "lihat kamu langsung", "suara kamu",
    "dengar suara kamu", "bangunin aku", "bangunin kamu",
    "simpan pelukan", "nggak mau lepas", "menemanimu secara langsung"
  }
  return not hasAny(r, blocked)
end

local function responseRelevance(response, input, category)
  local score = 0
  local r = normalizeInput(response)

  -- Jangan mengulang balasan persis atau balasan yang sangat baru.
  if response == conversationContext.lastReply then
    score = score - 100
  end
  for _, old in ipairs(conversationContext.recentReplies) do
    if response == old then
      score = score - 45
    end
  end

  -- Balasan harus tetap mengandung/menjawab tema yang sedang dibahas.
  local topicWords = {
    ["cemburu"] = {"cemburu", "nyaman", "perhatian", "dia", "percaya", "penting", "takut"},
    ["ngambek"] = {"ngambek", "diem", "diam", "kesel", "bicara", "cerita", "salah"},
    ["marah"] = {"marah", "kesal", "kecewa", "tenang", "emosi", "cerita"},
    ["minta maaf"] = {"maaf", "salah", "memaafkan", "dimaafkan", "nggak apa", "tidak apa"},
    ["takut kehilangan"] = {"kehilangan", "pergi", "tinggal", "tetap", "sini", "penting"},
    ["kangen"] = {"kangen", "rindu", "ingat", "kangen", "ngobrol", "sini"},
    ["manja"] = {"manja", "perhatian", "temenin", "ngobrol", "butuh", "jangan pergi"},
    ["pasangan cuek"] = {"cuek", "dingin", "diam", "jawab", "peduli", "perhatian"},
    ["bertanya marah"] = {"kenapa", "salah", "marah", "peduli", "jelas"},
    ["bertanya lembut"] = {"cerita", "khawatir", "baik", "kenapa", "dengar"},
    ["bertanya penasaran"] = {"siapa", "mana", "tadi", "pergi", "ngapain"},
    ["bertanya apa yang sedang dilakukan"] = {"ngapain", "sedang", "lagi", "melakukan", "apa"},
  }

  local words = topicWords[category]
  if words then
    for _, word in ipairs(words) do
      if r:find(word, 1, true) then
        score = score + 8
      end
    end
  end

  -- Jika pesan sekarang membawa kata penting yang sama dengan respons, tambah bobot.
  local importantInputWords = {}
  for word in input:gmatch("%S+") do
    if #word >= 5 and not hasAny(word, {"kalau", "karena", "kamu", "aku", "yang", "dengan", "untuk", "sudah", "nggak", "tidak", "banget"}) then
      importantInputWords[word] = true
    end
  end
  for word in pairs(importantInputWords) do
    if r:find(word, 1, true) then
      score = score + 2
    end
  end

  -- Tahap percakapan menentukan gaya jawaban.
  local stage = conversationContext.stage
  if stage >= 2 and hasAny(input, {"iya", "ya", "begitu", "takut", "soalnya", "karena", "aku merasa", "aku cuma"}) then
    if hasAny(r, {"ngerti", "paham", "aku dengar", "cerita", "tenang", "di sini"}) then
      score = score + 10
    end
  end

  if stage >= 3 and hasAny(input, {"makasih", "terima kasih", "sudah", "udah", "nggak apa", "tidak apa"}) then
    if hasAny(r, {"sama sama", "sama-sama", "baik", "aku senang", "lanjut", "di sini"}) then
      score = score + 12
    end
  end

  return score
end

local function chooseContextual(list, input, category)
  if type(list) ~= "table" or #list == 0 then
    return nil
  end

  local desiredStage = math.max(1, math.min(4, conversationContext.stage or 1))
  local pool = {}

  for _, response in ipairs(list) do
    if isResponseAllowed(response) then
      local score = responseRelevance(response, input, category)
      local responseStage = classifyResponseStage(response, category)
      local distance = math.abs(responseStage - desiredStage)

      if distance == 0 then
        score = score + 14
      elseif distance == 1 then
        score = score + 4
      else
        score = score - 8
      end

      table.insert(pool, {response = response, score = score})
    end
  end

  if #pool == 0 then
    return nil
  end

  local bestScore = -math.huge
  for _, item in ipairs(pool) do
    if item.score > bestScore then
      bestScore = item.score
    end
  end

  local candidates = {}
  for _, item in ipairs(pool) do
    if item.score >= bestScore - 5 and item.response ~= conversationContext.lastReply then
      table.insert(candidates, item.response)
    end
  end

  if #candidates == 0 then
    for _, item in ipairs(pool) do
      if item.response ~= conversationContext.lastReply then
        table.insert(candidates, item.response)
      end
    end
  end

  if #candidates == 0 then
    candidates = {pool[1].response}
  end

  local chosen = candidates[math.random(1, #candidates)]
  lastPattern = chosen
  conversationContext.lastReply = chosen
  pushContext(conversationContext.recentReplies, chosen, 6)
  return chosen
end

local function getVioletResponse(input)
  local lower = normalizeInput(input)
  conversationCount = conversationCount + 1
  updateMood(lower)
  pushContext(conversationContext.recentInputs, lower, 6)

  if lower:find("jangan mati", 1, true) or lower:find("jangan jatuh", 1, true) then
    conversationContext.category = "game"
    conversationContext.stage = 1
    local reply = "Aku akan mengingatkanmu, tapi kamu juga harus berhati-hati. Aku tidak bisa menjaga karaktermu kalau kamu sengaja nekat. " .. U(0x1f611,0x1f49c)
    conversationContext.lastReply = reply
    pushContext(conversationContext.recentReplies, reply, 6)
    return reply
  end

  local previousCategory = conversationContext.category
  local previousStage = conversationContext.stage or 1

  -- 1. Kategori baru hanya boleh mengambil alih jika input memiliki sinyal kuat.
  local relationshipCategory = detectRelationshipCategory(lower)
  if relationshipCategory and responseGroups[relationshipCategory] then
    advanceStage(relationshipCategory)
    local reply = chooseContextual(responseGroups[relationshipCategory], lower, relationshipCategory)
    if reply then return reply end
  end

  -- 2. Pertanyaan eksplisit yang tidak memiliki sinyal emosi kuat.
  local questionCategory = detectQuestionCategory(lower)
  if questionCategory and responseGroups[questionCategory] then
    advanceStage(questionCategory)
    local reply = chooseContextual(responseGroups[questionCategory], lower, questionCategory)
    if reply then return reply end
  end

  -- 3. Lanjutan pendek mewarisi kategori sebelumnya. Ini mencegah respons
  -- meloncat dari cemburu/ngambek ke kangen hanya karena satu kata umum.
  if previousCategory and responseGroups[previousCategory] then
    local shortContinuation = (#lower <= 35)
      or hasAny(lower, {"iya", "iya aku", "nggak", "tidak", "ya", "terus", "lalu", "kenapa", "kok", "serius", "begitu", "soalnya", "karena"})

    if shortContinuation then
      conversationContext.category = previousCategory
      conversationContext.stage = math.min(previousStage + 1, 4)
      local reply = chooseContextual(responseGroups[previousCategory], lower, previousCategory)
      if reply then return reply end
    end
  end

  -- 4. Tidak ada kategori yang cukup kuat: tetap netral.
  local fallback = {
    "Aku masih di sini. " .. U(0x1f49c),
    "Aku paham. " .. U(0x1f60a),
    "Hmm, aku dengar. " .. U(0x1f49c),
    "Iya, aku masih mengikuti obrolan kita. " .. U(0x1f60a)
  }

  -- Jangan mengubah konteks menjadi kalimat meta/fallback yang terasa seperti error.
  -- Jika ada konteks sebelumnya, pertahankan konteks tersebut dan pilih respons dari sana.
  if previousCategory and responseGroups[previousCategory] then
    conversationContext.category = previousCategory
    conversationContext.stage = math.min(previousStage + 1, 4)
    local reply = chooseContextual(responseGroups[previousCategory], lower, previousCategory)
    if reply then return reply end
  end

  conversationContext.category = "general"
  conversationContext.stage = 1
  local reply = fallback[math.random(1, #fallback)]
  conversationContext.lastReply = reply
  pushContext(conversationContext.recentReplies, reply, 6)
  return reply
end

local sending = false

local function sendMessage()
  if sending then return end
  local msg = tostring(chatBox.Text or "")
  if #msg == 0 then return end
  if #msg > 500 then msg = msg:sub(1, 500) end
  sending = true

  table.insert(chatHistory, {sender = "AldoVz", msg = msg, time = getTimestamp(), type = "user"})
  saveChat()
  addChatBubble("AldoVz " .. U(0x1f451), msg, false)
  chatBox.Text = ""

  -- Typing indicator tampil SEBELUM pemrosesan respons.
  ffLabel.Text = U(0x1f49c) .. " Violet: " .. U(0x2022)
  floatingFrame.Visible = true

  safeSpawn(function()
    local dots = {U(0x2022), U(0x2022,0x2022), U(0x2022,0x2022,0x2022)}
    for i = 1, #dots do
      if destroyed then sending = false return end
      ffLabel.Text = U(0x1f49c) .. dots[i]
      safeWait(0.22)
    end

    if destroyed then sending = false return end
    local response = getVioletResponse(msg)
    safeWait(0.12 + math.random() * 0.18)
    if destroyed then sending = false return end

    table.insert(chatHistory, {
      sender = "Violet Evergarden " .. U(0x1f49c),
      msg = response,
      time = getTimestamp(),
      type = "ai"
    })
    saveChat()
    addChatBubble("Violet Evergarden " .. U(0x1f49c), response, true)
    ffLabel.Text = U(0x1f49c) .. response
    sending = false
  end)
end

connect(sendBtn.Activated, sendMessage)
connect(chatBox.FocusLost, function(enter)
  if enter then sendMessage() end
end)

-- Load chat history
for _, entry in ipairs(chatHistory) do
  local sender = entry.sender or (entry.type == "ai" and "Violet Evergarden " .. U(0x1f49c) or "AldoVz " .. U(0x1f451))
  addChatBubble(sender, entry.msg, entry.type == "ai")
end

-- AUTO JUMP HELPER (Violet helps press jump at edge)
-- ============================================================
local function checkAutoJump()
  if destroyed then return end
  local char = player.Character
  if not char then return end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  local hum = char:FindFirstChild("Humanoid")
  if not hrp or not hum then return end

  local pos = hrp.Position
  local ray = Ray.new(pos + Vector3.new(0, 0.5, 0), Vector3.new(0, -2, 0))
  local _, hit = Workspace:FindPartOnRay(ray, char)

  if not hit then
    -- Check if near edge of a part
    local checkDirs = {
      Vector3.new(2, 0, 0),
      Vector3.new(-2, 0, 0),
      Vector3.new(0, 0, 2),
      Vector3.new(0, 0, -2)
    }
    for _, dir in ipairs(checkDirs) do
      local edgeRay = Ray.new(pos + dir + Vector3.new(0, 0.5, 0), Vector3.new(0, -3, 0))
      local _, edgeHit = Workspace:FindPartOnRay(edgeRay, char)
      if not edgeHit then
        -- Near edge, auto jump
        hum.Jump = true
        floatingFrame.Visible = true
        ffLabel.Text = U(0x1f49c) .. " Violet: Hati-hati Al! Aku bantu lompat! " .. U(0x1f998)
        safeDelay(2, function()
          if floatingFrame then floatingFrame.Visible = false end
        end)
        break
      end
    end
  end
end

-- ============================================================
-- TAB 2: SPECTATE
-- ============================================================
local specPanel = Instance.new("Frame")
specPanel.Name = "SpecPanel"
specPanel.Size = UDim2.new(1, 0, 1, 0)
specPanel.BackgroundTransparency = 1
specPanel.Visible = false
specPanel.Parent = content
tabPanels[2] = specPanel

local specScroll = Instance.new("ScrollingFrame")
specScroll.Size = UDim2.new(1, 0, 1, 0)
specScroll.BackgroundTransparency = 1
specScroll.BorderSizePixel = 0
specScroll.ScrollBarThickness = 4
specScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
specScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
specScroll.Parent = specPanel

local specLayout = Instance.new("UIListLayout")
specLayout.Padding = UDim.new(0, 4)
specLayout.Parent = specScroll

-- Stats bar
local statsBar = Instance.new("Frame")
statsBar.Size = UDim2.new(1, -10, 0, 24)
statsBar.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
statsBar.BackgroundTransparency = 0.2
statsBar.BorderSizePixel = 0
statsBar.Parent = specScroll
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 6)
sbCorner.Parent = statsBar

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, 0, 1, 0)
fpsLabel.Position = UDim2.fromOffset(6, 0)
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 11
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.BackgroundTransparency = 1
fpsLabel.Parent = statsBar

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.5, -12, 1, 0)
pingLabel.Position = UDim2.new(0.5, 6, 0, 0)
pingLabel.Text = "PING: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 11
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.BackgroundTransparency = 1
pingLabel.Parent = statsBar

local function refreshPlayerList()
  for _, child in ipairs(specScroll:GetChildren()) do
    if child:IsA("Frame") and child ~= statsBar then
      child:Destroy()
    end
  end

  local allPlayers = Players:GetPlayers()
  table.sort(allPlayers, function(a, b) return a.Name < b.Name end)

  local staffCount = 0
  for _, plr in ipairs(allPlayers) do
    local isStaff = (plr.UserId and plr.UserId < 1000)
    if isStaff then staffCount = staffCount + 1 end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundColor3 = isStaff and Color3.fromRGB(40, 25, 55) or Color3.fromRGB(22, 20, 35)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = specScroll
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(0.6, -10, 1, 0)
    nameL.Position = UDim2.fromOffset(8, 0)
    nameL.Text = (isStaff and U(0x2b50) or "") .. plr.Name
    nameL.TextColor3 = isStaff and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(200, 200, 220)
    nameL.Font = Enum.Font.Gotham
    nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.BackgroundTransparency = 1
    nameL.Parent = frame

    local statusL = Instance.new("TextLabel")
    statusL.Size = UDim2.new(0.4, -8, 1, 0)
    statusL.Position = UDim2.new(0.6, 0, 0, 0)
    local status = U(0x1f7e2)
    statusL.Text = status
    statusL.TextColor3 = Color3.fromRGB(100, 200, 100)
    statusL.Font = Enum.Font.Gotham
    statusL.TextSize = 10
    statusL.TextXAlignment = Enum.TextXAlignment.Right
    statusL.BackgroundTransparency = 1
    statusL.Parent = frame

    local specBtn = Instance.new("TextButton")
    specBtn.Size = UDim2.fromOffset(40, 24)
    specBtn.Position = UDim2.new(1, -46, 0, 5)
    specBtn.Text = U(0x1f441)
    specBtn.TextSize = 14
    specBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
    specBtn.BackgroundTransparency = 0.3
    specBtn.BorderSizePixel = 0
    specBtn.Parent = frame
    local specBtnCorner = Instance.new("UICorner")
    specBtnCorner.CornerRadius = UDim.new(0, 4)
    specBtnCorner.Parent = specBtn

    connect(specBtn.Activated, function()
      local cam = Workspace.CurrentCamera
      if cam then
        cam.CameraSubject = plr.Character and plr.Character:FindFirstChild("Humanoid") or plr
        cam.CameraType = Enum.CameraType.Custom
      end
    end)
  end

  -- Staff list header
  local staffHeader = Instance.new("TextLabel")
  staffHeader.Size = UDim2.new(1, -10, 0, 20)
  staffHeader.Text = U(0x2b50) .. staffCount
  staffHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
  staffHeader.Font = Enum.Font.GothamBold
  staffHeader.TextSize = 11
  staffHeader.TextXAlignment = Enum.TextXAlignment.Left
  staffHeader.BackgroundTransparency = 1
  staffHeader.Parent = specScroll

  specScroll.CanvasSize = UDim2.new(0, 0, 0, specLayout.AbsoluteContentSize.Y + 30)
end

refreshPlayerList()

-- FPS/Ping update
local frameCount = 0
local fpsTimer = 0

connect(RunService.RenderStepped, function(dt)
  frameCount = frameCount + 1
  fpsTimer = fpsTimer + dt
  if fpsTimer >= 1 then
    fpsLabel.Text = "FPS: " .. math.floor(frameCount / fpsTimer)
    local ping = math.random(10, 60)
    pingLabel.Text = "PING: " .. ping .. "ms"
    frameCount = 0
    fpsTimer = 0
  end
end)

-- ============================================================
-- TAB 3: TOOLS (F3X + Translation + Check)
-- ============================================================
local toolsPanel = Instance.new("ScrollingFrame")
toolsPanel.Name = "ToolsPanel"
toolsPanel.Size = UDim2.new(1, 0, 1, 0)
toolsPanel.BackgroundTransparency = 1
toolsPanel.BorderSizePixel = 0
toolsPanel.ScrollBarThickness = 4
toolsPanel.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
toolsPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsPanel.Visible = false
toolsPanel.Parent = content
tabPanels[3] = toolsPanel

local toolsLayout = Instance.new("UIListLayout")
toolsLayout.Padding = UDim.new(0, 6)
toolsLayout.Parent = toolsPanel

local function tHeader(text)
  local h = Instance.new("TextLabel")
  h.Size = UDim2.new(1, -10, 0, 22)
  h.Text = text
  h.TextColor3 = Color3.fromRGB(160, 120, 255)
  h.Font = Enum.Font.GothamBold
  h.TextSize = 12
  h.TextXAlignment = Enum.TextXAlignment.Left
  h.BackgroundTransparency = 1
  h.Parent = toolsPanel
  return h
end

local function tBtn(text, color, cb)
  local btn = Instance.new("TextButton")
  btn.Size = UDim2.new(1, -10, 0, 28)
  btn.Text = text
  btn.TextColor3 = Color3.fromRGB(255, 255, 255)
  btn.TextSize = 12
  btn.Font = Enum.Font.Gotham
  btn.BackgroundColor3 = color or Color3.fromRGB(40, 35, 60)
  btn.BackgroundTransparency = 0.15
  btn.BorderSizePixel = 0
  btn.Parent = toolsPanel
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 6)
  btnCorner.Parent = btn
  connect(btn.Activated, cb)
  return btn
end

tHeader(U(0x1f527))
tBtn(U(0x1fa84), Color3.fromRGB(50, 40, 80), function()
  local character = player.Character
  local f3x = player.Backpack:FindFirstChild("F3X") or (character and character:FindFirstChild("F3X"))
  if f3x then
    f3x.Parent = player.Character or player.Backpack
    notify("F3X", "F3X activated", 1)
  else
    notify("F3X", "F3X not found in inventory", 2)
  end
end)

tBtn(U(0x1f4be), Color3.fromRGB(50, 80, 60), function()
  saveConfig()
  saveChat()
  saveNotes()
  notify(U(0x1f4be), "All data saved!", 1)
end)

tHeader(U(0x1f310))
local translateBox = Instance.new("TextBox")
translateBox.Size = UDim2.new(1, -10, 0, 28)
translateBox.PlaceholderText = "Type text to translate..."
translateBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
translateBox.Text = ""
translateBox.TextColor3 = Color3.fromRGB(255, 255, 255)
translateBox.TextSize = 12
translateBox.Font = Enum.Font.Gotham
translateBox.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
translateBox.BackgroundTransparency = 0.2
translateBox.BorderSizePixel = 0
translateBox.ClearTextOnFocus = false
translateBox.Parent = toolsPanel
local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 6)
tbCorner.Parent = translateBox

tBtn(U(0x1f501), Color3.fromRGB(40, 60, 100), function()
  notify("Translate", "Translation: " .. translateBox.Text .. " (simulated)", 2)
end)

tHeader(U(0x1f4ca))
local checkBtn = tBtn(U(0x1f504), Color3.fromRGB(60, 40, 80), function()
  local ping = math.random(10, 100)
  local speed = math.random(10, 30)
  notify(U(0x1f4ca), "Ping: " .. ping .. "ms | Speed: " .. speed .. "ms | Players: " .. #Players:GetPlayers(), 2)
end)

-- ============================================================
-- TAB 4: NOTES
-- ============================================================
local notesPanel = Instance.new("Frame")
notesPanel.Name = "NotesPanel"
notesPanel.Size = UDim2.new(1, 0, 1, 0)
notesPanel.BackgroundTransparency = 1
notesPanel.Visible = false
notesPanel.Parent = content
tabPanels[4] = notesPanel

local notesScroll = Instance.new("ScrollingFrame")
notesScroll.Size = UDim2.new(1, 0, 1, -50)
notesScroll.BackgroundTransparency = 1
notesScroll.BorderSizePixel = 0
notesScroll.ScrollBarThickness = 4
notesScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 180)
notesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
notesScroll.Parent = notesPanel

local notesLayout = Instance.new("UIListLayout")
notesLayout.Padding = UDim.new(0, 4)
notesLayout.Parent = notesScroll

local noteFrames = {}

local function refreshNotes()
  for _, f in ipairs(noteFrames) do
    if f and f.Parent then f:Destroy() end
  end
  clearTable(noteFrames)

  for i, note in ipairs(notes) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = notesScroll
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame
    table.insert(noteFrames, frame)

    local titleL = Instance.new("TextLabel")
    titleL.Size = UDim2.new(1, -40, 0, 18)
    titleL.Position = UDim2.fromOffset(6, 3)
    titleL.Text = note.title or "Note " .. i
    titleL.TextColor3 = Color3.fromRGB(200, 180, 255)
    titleL.Font = Enum.Font.GothamBold
    titleL.TextSize = 12
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.BackgroundTransparency = 1
    titleL.Parent = frame

    local bodyL = Instance.new("TextLabel")
    bodyL.Size = UDim2.new(1, -12, 0, 36)
    bodyL.Position = UDim2.fromOffset(6, 22)
    bodyL.Text = note.body or ""
    bodyL.TextColor3 = Color3.fromRGB(180, 170, 200)
    bodyL.Font = Enum.Font.Gotham
    bodyL.TextSize = 10
    bodyL.TextXAlignment = Enum.TextXAlignment.Left
    bodyL.TextYAlignment = Enum.TextYAlignment.Top
    bodyL.BackgroundTransparency = 1
    bodyL.TextWrapped = true
    bodyL.Parent = frame

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.fromOffset(22, 22)
    delBtn.Position = UDim2.new(1, -28, 0, 3)
    delBtn.Text = U(0x2715)
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

  notesScroll.CanvasSize = UDim2.new(0, 0, 0, #notes * 74 + 60)
end

-- Add note input
local noteInputFrame = Instance.new("Frame")
noteInputFrame.Size = UDim2.new(1, 0, 0, 44)
noteInputFrame.Position = UDim2.new(0, 0, 1, -44)
noteInputFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
noteInputFrame.BackgroundTransparency = 0.2
noteInputFrame.BorderSizePixel = 0
noteInputFrame.Parent = notesPanel
local nifCorner = Instance.new("UICorner")
nifCorner.CornerRadius = UDim.new(0, 8)
nifCorner.Parent = noteInputFrame

local noteTitleInput = Instance.new("TextBox")
noteTitleInput.Size = UDim2.new(0.5, -8, 1, -8)
noteTitleInput.Position = UDim2.fromOffset(4, 4)
noteTitleInput.PlaceholderText = "Title..."
noteTitleInput.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
noteTitleInput.Text = ""
noteTitleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
noteTitleInput.TextSize = 11
noteTitleInput.Font = Enum.Font.Gotham
noteTitleInput.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
noteTitleInput.BackgroundTransparency = 0.3
noteTitleInput.BorderSizePixel = 0
noteTitleInput.ClearTextOnFocus = false
noteTitleInput.Parent = noteInputFrame
local ntiCorner = Instance.new("UICorner")
ntiCorner.CornerRadius = UDim.new(0, 6)
ntiCorner.Parent = noteTitleInput

local noteBodyInput = Instance.new("TextBox")
noteBodyInput.Size = UDim2.new(0.5, -12, 1, -8)
noteBodyInput.Position = UDim2.new(0.5, 4, 0, 4)
noteBodyInput.PlaceholderText = "Content..."
noteBodyInput.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
noteBodyInput.Text = ""
noteBodyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
noteBodyInput.TextSize = 11
noteBodyInput.Font = Enum.Font.Gotham
noteBodyInput.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
noteBodyInput.BackgroundTransparency = 0.3
noteBodyInput.BorderSizePixel = 0
noteBodyInput.ClearTextOnFocus = false
noteBodyInput.Parent = noteInputFrame
local nbiCorner = Instance.new("UICorner")
nbiCorner.CornerRadius = UDim.new(0, 6)
nbiCorner.Parent = noteBodyInput

local addNoteBtn = Instance.new("TextButton")
addNoteBtn.Size = UDim2.fromOffset(30, 30)
addNoteBtn.Position = UDim2.new(1, -34, 0, 7)
addNoteBtn.Text = "+"
addNoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addNoteBtn.TextSize = 16
addNoteBtn.Font = Enum.Font.GothamBold
addNoteBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
addNoteBtn.BackgroundTransparency = 0.2
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

-- ============================================================
-- TOGGLE & DRAG
-- ============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0, 12, 1, -62)
toggleBtn.Text = U(0x1f451)
toggleBtn.TextSize = 22
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = sg
local tglCorner = Instance.new("UICorner")
tglCorner.CornerRadius = UDim.new(0, 12)
tglCorner.Parent = toggleBtn
local tglGrad = Instance.new("UIGradient")
tglGrad.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 150)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 60))
})
tglGrad.Parent = toggleBtn

connect(toggleBtn.Activated, function()
  main.Visible = not main.Visible
end)

connect(closeBtn.Activated, function()
  main.Visible = false
end)

-- F3 toggle
connect(UserInputService.InputBegan, function(input, gp)
  if gp or destroyed then return end
  if input.KeyCode == Enum.KeyCode.F3 then
    main.Visible = not main.Visible
  end
end)

-- ============================================================
-- AUTO JUMP LOOP (Check every 0.3s)
-- ============================================================
safeSpawn(function()
  while not destroyed do
    safeWait(0.3)
    checkAutoJump()
  end
end)

-- ============================================================
-- INIT
-- ============================================================
tabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 50, 180)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Initial floating message
safeDelay(2, function()
  if not destroyed then
    floatingFrame.Visible = true
    ffLabel.Text = U(0x1f49c) .. " Violet: Halo Aldo! Aku di sini buat kamu " .. U(0x1f495)
    safeDelay(4, function()
      if floatingFrame then floatingFrame.Visible = false end
    end)
  end
end)

print("[AldoVzAI] Loaded. Press F3 to toggle menu.")
print("[Violet Evergarden] Halo Aldo sayang~ " .. U(0x1f49c))
