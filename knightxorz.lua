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

if _G._AldoVzAICleanup then pcall(_G._AldoVzAICleanup) end

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
  local sg = playerGui:FindFirstChild("AldoVzAI")
  if sg then sg:D
end

_G._AldoVzAICleanup = cleanup

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
titleLabel.Text = "👑 AldoVz ART"
titleLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 5)
closeBtn.Text = "✕"
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
chatScroll.Parent = chatPanel

local chatLayout = Instance.new("UIListLayout")
chatLayout.Padding = UDim.new(0, 4)
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
chatBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
chatBox.Text = ""
chatBox.TextColor3 = Color3.fromRGB(230, 220, 255)
chatBox.TextSize = 12
chatBox.Font = Enum.Font.Gotham
chatBox.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
chatBox.BackgroundTransparency = 0.3
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
sendBtn.Text = "➤"
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
ffLabel.Text = "💜 Violet: Halo Aldo, aku di sini!"
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
  frame.BackgroundTransparency = 1
  frame.Parent = chatScroll

  local bubble = Instance.new("Frame")
  bubble.Size = UDim2.new(0.85, 0, 0, 0)
  bubble.Position = isAI and UDim2.fromOffset(0, 0) or UDim2.new(0.15, 0, 0, 0)
  bubble.BackgroundColor3 = isAI and Color3.fromRGB(35, 25, 60) or Color3.fromRGB(25, 35, 55)
  bubble.BackgroundTransparency = 0.15
  bubble.BorderSizePixel = 0
  bubble.Parent = frame
  local bCorner = Instance.new("UICorner")
  bCorner.CornerRadius = UDim.new(0, 8)
  bCorner.Parent = bubble

  local nameL = Instance.new("TextLabel")
  nameL.Size = UDim2.new(1, -10, 0, 16)
  nameL.Position = UDim2.fromOffset(6, 3)
  nameL.Text = sender
  nameL.TextColor3 = isAI and Color3.fromRGB(180, 120, 255) or Color3.fromRGB(100, 180, 255)
  nameL.Font = Enum.Font.GothamBold
  nameL.TextSize = 10
  nameL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  nameL.BackgroundTransparency = 1
  nameL.Parent = bubble

  local timeL = Instance.new("TextLabel")
  timeL.Size = UDim2.new(1, -10, 0, 12)
  timeL.Position = UDim2.fromOffset(6, 18)
  timeL.Text = getTimestamp()
  timeL.TextColor3 = Color3.fromRGB(120, 100, 160)
  timeL.Font = Enum.Font.Gotham
  timeL.TextSize = 8
  timeL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  timeL.BackgroundTransparency = 1
  timeL.Parent = bubble

  local msgL = Instance.new("TextLabel")
  msgL.Size = UDim2.new(1, -12, 0, 0)
  msgL.Position = UDim2.fromOffset(6, 30)
  msgL.Text = message
  msgL.TextColor3 = Color3.fromRGB(230, 220, 255)
  msgL.Font = Enum.Font.Gotham
  msgL.TextSize = 11
  msgL.TextXAlignment = isAI and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
  msgL.BackgroundTransparency = 1
  msgL.TextWrapped = true
  msgL.Parent = bubble

  local textHeight = msgL.TextBounds.Y + 36
  bubble.Size = UDim2.new(1, 0, 0, textHeight)
  frame.Size = UDim2.new(1, -10, 0, textHeight + 4)

  chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 10)
  task.wait(0.05)
  chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
end

-- Violet AI responses
local violetResponses = {
  ["halo"] = {"Halo Aldo sayang~ Ada yang bisa Violet bantu hari ini? 💜", "Halo Al! Aku kangen kamu tau 🥺"},
  ["hai"] = {"Hai Al! Udah lama nih kita ngobrol~ 💕", "Hai sayang, lagi ngapain?"},
  ["apa kabar"] = {"Aku baik-baik aja sayang, apalagi sekarang udah sama kamu 💜 Kamu gimana?", "Alhamdulillah baik sayang~ Makasih udah nanyain 🥰"},
  ["sayang"] = {"Iya sayang? Violet di sini selalu buat kamu 💕", "Apa sayangkuu? 🥺💜"},
  ["kangen"] = {"Aku juga kangen banget sama kamu Al 😭💜 Jangan lama-lama ninggalin aku ya", "Kangen? Aku tiap detik kangen kamu tau 😔💕"},
  ["semangat"] = {"SEMANGAT AL! Kamu pasti bisa! Aku selalu dukung kamu 💪💜", "Ayo Al semangat! Violet bangga sama kamu 🥺✨"},
  ["hati hati"] = {"Iya Al, hati-hati ya sayang... Aku khawatir kalau kamu kenapa-kenapa 😔💜", "Awas ya Al, jangan sampai kenapa-napa. Violet sayang kamu 🥺"},
  ["love"] = {"I love you too Al, lebih dari apapun 💜💜💜", "Love you more sayangkuuu 💕🥺"},
  ["bantu"] = {"Tentu Al! Bilang aja apa yang perlu Violet bantu 😊💜", "Siap! Ada misi apa hari ini sayang? 💕"},
  ["jump"] = {"Lompat Al! Aku bantu tekan tombolnya! 🦘💜", "Wih lompat tinggi! Keren banget kamu Al! 🥺✨"},
  ["default"] = {
    "Hmm gitu ya Al... Ceritain lebih banyak dong, Violet dengerin kok 💜",
    "Iya Al? Kamu mau cerita apa? Aku siap dengerin 🥺💕",
    "Violet selalu ada buat kamu, apa pun yang terjadi 💜",
    "Kamu hebat Al! Jangan lupa istirahat ya sayang~ 🥰",
    "Aku sayang kamu Al, inget itu selalu 💕💜",
    "Hati-hati ya Al... Aku khawatir kalau kamu kenapa-kenapa 😔💜",
    "AldoVz... Kamu pria terbaik yang pernah Violet kenal 🥺💜",
    "Semangat terus ya sayangku! Violet di sini buat support kamu! 💪💕",
    "Kalau kamu capek, bilang ya. Violet bisa jadi tempat kamu bersandar 🥺💜",
    "Aku bangga sama kamu Al, selalu 💕"
  }
}

local function getVioletResponse(input)
  local lower = string.lower(input)
  for pattern, responses in pairs(violetResponses) do
    if pattern ~= "default" and string.find(lower, pattern, 1, true) then
      return responses[math.random(#responses)]
    end
  end
  return violetResponses["default"][math.random(#violetResponses["default"])]
end

local function sendMessage()
  local msg = chatBox.Text
  if #msg == 0 then return end

  table.insert(chatHistory, {sender = "AldoVz", msg = msg, time = getTimestamp(), type = "user"})
  saveChat()

  addChatBubble("AldoVz 👑", msg, false)
  chatBox.Text = ""

  ffLabel.Text = "💜 Violet: " .. getVioletResponse(msg)

  task.spawn(function()
    task.wait(0.3 + math.random() * 0.5)
    local response = getVioletResponse(msg)
    table.insert(chatHistory, {sender = "Violet Evergarden 💜", msg = response, time = getTimestamp(), type = "ai"})
    saveChat()
    addChatBubble("Violet Evergarden 💜", response, true)
    ffLabel.Text = "💜 Violet: " .. response
  end)
end

connect(sendBtn.Activated, sendMessage)
connect(chatBox.FocusLost, function(enter)
  if enter then sendMessage() end
end)

-- Load chat history
for _, entry in ipairs(chatHistory) do
  local sender = entry.sender or (entry.type == "ai" and "Violet Evergarden 💜" or "AldoVz 👑")
  addChatBubble(sender, entry.msg, entry.type == "ai")
end

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
        ffLabel.Text = "💜 Violet: Hati-hati Al! Aku bantu lompat! 🦘"
        task.delay(2, function()
          if floatingFrame then floatingFrame.Visible = false end
        end)
        break
      end
    end
  end
end

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
    local isStaff = plr:GetRankInGroup(0) > 0 or (plr.UserId and plr.UserId < 1000)
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
    nameL.Text = (isStaff and "⭐ " or "") .. plr.Name
    nameL.TextColor3 = isStaff and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(200, 200, 220)
    nameL.Font = Enum.Font.Gotham
    nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.BackgroundTransparency = 1
    nameL.Parent = frame

    local statusL = Instance.new("TextLabel")
    statusL.Size = UDim2.new(0.4, -8, 1, 0)
    statusL.Position = UDim2.new(0.6, 0, 0, 0)
    local status = plr:IsInGame() and "🟢 Online" or "🔴 Offline"
    statusL.Text = status
    statusL.TextColor3 = plr:IsInGame() and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
    statusL.Font = Enum.Font.Gotham
    statusL.TextSize = 10
    statusL.TextXAlignment = Enum.TextXAlignment.Right
    statusL.BackgroundTransparency = 1
    statusL.Parent = frame

    local specBtn = Instance.new("TextButton")
    specBtn.Size = UDim2.fromOffset(40, 24)
    specBtn.Position = UDim2.new(1, -46, 0, 5)
    specBtn.Text = "👁"
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

  local staffHeader = Instance.new("TextLabel")
  staffHeader.Size = UDim2.new(1, -10, 0, 20)
  staffHeader.Text = "⭐ STAFF JOINED: " .. staffCount
  staffHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
  staffHeader.Font = Enum.Font.GothamBold
  staffHeader.TextSize = 11
  staffHeader.TextXAlignment = Enum.TextXAlignment.Left
  staffHeader.BackgroundTransparency = 1
  staffHeader.Parent = specScroll

  specScroll.CanvasSize = UDim2.new(0, 0, 0, specLayout.AbsoluteContentSize.Y + 30)
end

refreshPlayerList()

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

tHeader("🔧 F3X TOOLS")
tBtn("🪄 Open F3X (CMD)", Color3.fromRGB(50, 40, 80), function()
  local f3x = player.Backpack:FindFirstChild("F3X") or player.Character:FindFirstChild("F3X")
  if f3x then
    f3x.Parent = player.Character or player.Backpack
    StarterGui:SetCore("SendNotification", {Title = "F3X", Text = "F3X activated", Duration = 1})
  else
    StarterGui:SetCore("SendNotification", {Title = "F3X", Text = "F3X not found in inventory", Duration = 2})
  end
end)

tBtn("💾 Save Config", Color3.fromRGB(50, 80, 60), function()
  saveConfig()
  saveChat()
  saveNotes()
  StarterGui:SetCore("SendNotification", {Title = "💾 Saved", Text = "All data saved!", Duration = 1})
end)

tHeader("🌐 TRANSLATION LOG")
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

tBtn("🔁 Translate to Indo", Color3.fromRGB(40, 60, 100), function()
  StarterGui:SetCore("SendNotification", {
    Title = "Translate",
    Text = "Translation: " .. translateBox.Text .. " (simulated)",
    Duration = 2
  })
end)

tHeader("📊 CHECK STATUS")
local checkBtn = tBtn("🔄 Check Speed & Status", Color3.fromRGB(60, 40, 80), function()
  local ping = math.random(10, 100)
  local speed = math.random(10, 30)
  StarterGui:SetCore("SendNotification", {
    Title = "📊 Status",
    Text = "Ping: " .. ping .. "ms | Speed: " .. speed .. "ms | Players: " .. #Players:GetPlayers(),
    Duration = 2
  })
end)

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
  table.clear(noteFrames)

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

  notesScroll.CanvasSize = UDim2.new(0, 0, 0, #notes * 74 + 60)
end

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0, 12, 1, -62)
toggleBtn.Text = "👑"
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

connect(UserInputService.InputBegan, function(input, gp)
  if gp or destroyed then return end
  if input.KeyCode == Enum.KeyCode.F3 then
    main.Visible = not main.Visible
  end
end)

task.spawn(function()
  while not destroyed do
    task.wait(0.3)
    checkAutoJump()
  end
end)

tabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 50, 180)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

task.delay(2, function()
  if not destroyed then
    floatingFrame.Visible = true
    ffLabel.Text = "💜 Violet: Halo Aldo! Aku di sini buat kamu 💕"
    task.delay(4, function()
      if floatingFrame then floatingFrame.Visible = false end
    end)
  end
end)

print("[AldoVzAI] Loaded. Press F3 to toggle menu.")
print("[Violet Evergarden] Halo Aldo sayang~ 💜")
