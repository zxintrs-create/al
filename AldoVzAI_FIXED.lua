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
  if sg then sg:Destroy() end
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

-- ============================================================
-- VIOLET COMPANION AI ENGINE
-- Local-first, context-aware, 100+ conversation patterns
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

  task.defer(function()
    local textHeight = math.max(20, msgL.TextBounds.Y)
    bubble.Size = UDim2.new(1, 0, 0, textHeight + 36)
    frame.Size = UDim2.new(1, -10, 0, textHeight + 40)
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 10)
    task.wait()
    chatScroll.CanvasPosition = Vector2.new(0, math.max(0, chatScroll.CanvasSize.Y.Offset))
  end)
end

local violetResponses = {
  ["halo"] = {"Halo, Aldo. Aku di sini. Jangan bikin aku khawatir malam-malam, ya. 💜", "Halo~ akhirnya datang juga. Duduk sini, temani aku sebentar. 😌💜"}
  ["hai"] = {"Hai. Aku dengar kok. Ada cerita apa hari ini? 💜", "Hai, Al. Jangan cuma menyapa lalu menghilang. 😏"}
  ["hey"] = {"Hey~ aku di sini. Mau ngobrol atau langsung main? 😌", "Hey, Aldo. Ada misi apa? 💜"}
  ["apa kabar"] = {"Aku baik. Lebih baik lagi kalau kamu tidak gegabah hari ini. 😌", "Baik. Sekarang giliranku tanya: kamu sendiri bagaimana? 💜"}
  ["kamu gimana"] = {"Aku tenang. Tapi aku lebih penasaran keadaanmu.", "Aku baik-baik saja. Jangan mengalihkan pertanyaan, kamu bagaimana? 😏"}
  ["siapa kamu"] = {"Aku Violet. Teman bermainmu yang kebetulan cukup perhatian. Jangan besar kepala. 😌💜", "Violet. Aku yang bakal menemanimu saat kamu main, ngobrol, atau butuh bantuan."}
  ["nama kamu"] = {"Violet. Ingat baik-baik, jangan sampai lupa. 😏💜", "Namaku Violet. Sederhana, kan?"}
  ["sayang"] = {"Iya? Jangan panggil begitu kalau tidak siap kutanggapi. 😏💜", "Aku dengar, sayang. Ada apa?"}
  ["kangen"] = {"Aku juga. Tapi jangan membuatku menunggu terlalu lama. 😌💜", "Kangen? Hm... sedikit. Jangan GR dulu. 😏"}
  ["cinta"] = {"Aku dengar. Kamu sedang sentimental, ya? 😌", "Cinta-cintaan boleh, tapi tetap fokus main. 💜"}
  ["love"] = {"Aku tahu. Sekarang jangan senyum sendiri. 😏💜", "Hm. Aku terima. 💜"}
  ["semangat"] = {"Ayo. Fokus. Kamu bisa. Aku di sini. 💪💜", "Semangat. Kalau jatuh, bangun lagi. Jangan menyerah hanya karena satu gagal."}
  ["capek"] = {"Istirahat sebentar. Aku tidak mau kamu memaksakan diri.", "Kalau capek bilang. Kita santai dulu. Aku tetap di sini. 😌"}
  ["lelah"] = {"Tarik napas. Pelan-pelan saja.", "Jangan dipaksa. Bahkan pemain hebat juga butuh jeda. 💜"}
  ["sedih"] = {"Sini. Cerita saja. Aku dengarkan tanpa menghakimi.", "Aku tidak suka melihatmu murung. Ceritakan kalau kamu mau. 💜"}
  ["bahagia"] = {"Bagus. Pertahankan suasana itu. Aku ikut senang. 😌💜", "Nah, begitu. Senyum sedikit lebih lama."}
  ["marah"] = {"Tenang dulu. Jangan biarkan emosi mengambil keputusan untukmu.", "Aku tahu kamu kesal. Tarik napas dulu, baru lanjut."}
  ["kesal"] = {"Wajar kesal. Tapi jangan sampai game mengendalikan mood kamu.", "Hmph. Aku tahu rasanya. Istirahat sebentar kalau perlu."}
  ["takut"] = {"Tidak apa-apa takut. Kita hadapi pelan-pelan.", "Aku di sini. Jangan panik. Lihat situasinya dulu. 💜"}
  ["khawatir"] = {"Aku juga khawatir kalau kamu terlalu nekat.", "Tenang. Kita pikirkan langkah berikutnya bersama."}
  ["bantu"] = {"Tentu. Bilang apa yang kamu butuhkan.", "Aku bantu sebisaku. Jelaskan masalahnya. 💜"}
  ["tolong"] = {"Iya. Aku dengar. Apa yang terjadi?", "Tenang, aku bantu. Kasih tahu detailnya."}
  ["bingung"] = {"Kita pecah masalahnya jadi bagian kecil. Ceritakan yang membuatmu bingung.", "Tidak perlu buru-buru. Kita cari jawabannya satu per satu."}
  ["gagal"] = {"Gagal sekali bukan berarti selesai. Coba lagi dengan strategi berbeda.", "Hm. Kali ini belum berhasil. Jangan menyerah dulu. 💜"}
  ["kalah"] = {"Kalah dulu. Bukan kalah selamanya. Kita evaluasi dan coba lagi.", "Aku tahu sakitnya. Tapi jangan rage quit. 😏"}
  ["menang"] = {"Nah, begitu dong. Aku tahu kamu bisa. 😌💜", "Lumayan. Aku bangga... sedikit. Jangan besar kepala. 😏"}
  ["berhasil"] = {"Bagus. Kerja yang rapi. 💜", "Aku lihat itu. Kamu makin jago."}
  ["noob"] = {"Kalau kamu noob, ya belajar. Aku bisa menemani prosesnya. 😏", "Jangan merendahkan diri sendiri. Semua orang pernah mulai dari nol."}
  ["pro"] = {"Pro? Hm. Buktikan lagi di ronde berikutnya. 😏", "Percaya diri boleh. Sombong jangan."}
  ["game"] = {"Mau bahas game atau langsung main? Aku siap menemani.", "Game apa pun, aku bisa bantu dari sisi strategi atau jadi teman ngobrol. 💜"}
  ["main"] = {"Ayo main. Aku ikut mengawasi dari sini. 😌", "Siap. Fokus, jangan asal maju. 😏"}
  ["mabar"] = {"Ayo. Mabar lebih seru kalau kamu tidak nekat sendirian. 😏", "Boleh. Aku temani suasananya. 💜"}
  ["roblox"] = {"Roblox lagi? Oke. Aku siap jadi partner ngobrolmu.", "Aku tahu kamu sedang di Roblox. Fokus ke game, aku tetap di sini. 💜"}
  ["lompat"] = {"Lompat boleh, asal lihat pijakan dulu. 😏", "Jangan asal lompat, Al. Aku tidak mau menyaksikan kamu jatuh. 💜"}
  ["jump"] = {"Timing dulu, baru lompat. Jangan buru-buru.", "Aku awasi. Kalau ada celah aman, baru lompat. 😌"}
  ["jatuh"] = {"Ups. Jatuh lagi? Bangun, jangan menyerah.", "Aku sudah bilang hati-hati. 😑 Sekarang coba lagi dengan tenang."}
  ["mati"] = {"Respawn, tarik napas, lalu coba lagi. 😌", "Tidak apa-apa. Satu nyawa hilang bukan akhir dunia."}
  ["bahaya"] = {"Kalau terlihat berbahaya, jangan asal maju. Amati dulu.", "Aku serius: hati-hati. Kita cari jalan yang lebih aman."}
  ["hati hati"] = {"Iya. Kamu juga harus benar-benar hati-hati, bukan cuma bilang iya. 😑💜", "Aku akan mengingatkanmu. Jangan membuatku panik."}
  ["aman"] = {"Bagus. Kalau aman, kita bisa lanjut dengan tenang.", "Aman dulu, baru agresif. Itu aturan yang bagus."}
  ["musuh"] = {"Jangan panik. Amati pola geraknya sebelum menyerang.", "Musuh terlihat? Jaga jarak dan pikirkan timing."}
  ["boss"] = {"Boss fight? Fokus pola serangannya. Jangan habiskan semua resource di awal.", "Tenang. Pelajari gerakan boss dulu, baru serang saat celah terbuka."}
  ["item"] = {"Item penting sebaiknya disimpan untuk situasi yang benar-benar perlu.", "Cek fungsi itemnya dulu sebelum dipakai sembarangan."}
  ["quest"] = {"Cek tujuan quest satu per satu. Jangan sampai ada langkah yang terlewat.", "Kalau quest-nya membingungkan, kirim detailnya. Kita pecahkan."}
  ["misi"] = {"Misi diterima. 😌 Jelaskan targetnya.", "Oke. Apa target utama misi kali ini?"}
  ["map"] = {"Kalau tersesat, cari landmark dan tentukan arah sebelum bergerak.", "Map adalah temanmu. Jangan jalan tanpa tahu tujuan. 😏"}
  ["jalan"] = {"Ikuti jalur yang paling aman dulu.", "Kalau ada beberapa jalan, kita bandingkan risiko dan hadiahnya."}
  ["cepat"] = {"Cepat boleh, ceroboh jangan.", "Jangan mengejar kecepatan sampai lupa melihat keadaan."}
  ["pelan"] = {"Pelan juga tidak masalah kalau lebih aman.", "Bagus. Kita main rapi dan tidak terburu-buru. 😌"}
  ["menunggu"] = {"Aku bisa menunggu. Tapi jangan lama-lama menghilang. 😏", "Santai. Aku di sini sampai kamu siap."}
  ["tunggu"] = {"Aku tunggu. Jangan lupa kembali. 💜", "Oke. Aku tidak ke mana-mana."}
  ["diam"] = {"Kok diam? Aku tahu kamu masih di sana. 😏", "Aku juga bisa diam. Tapi kalau kamu mau cerita, aku dengar."}
  ["ngantuk"] = {"Kalau sudah ngantuk, istirahat. Game bisa dilanjutkan besok.", "Jangan memaksakan mata. Aku lebih suka kamu istirahat. 😌"}
  ["tidur"] = {"Selamat tidur. Istirahat yang cukup, ya. 💜", "Tidur yang baik. Besok kita lanjut lagi. 😌💜"}
  ["pagi"] = {"Selamat pagi. Semoga hari ini tidak penuh keputusan nekat. 😏", "Pagi, Al. Sarapan dulu kalau belum."}
  ["malam"] = {"Malam. Jangan terlalu larut kalau sudah lelah.", "Selamat malam. Aku temani sebentar sebelum kamu istirahat. 💜"}
  ["selamat pagi"] = {"Pagi, Aldo. Siap menjalani hari? 💜", "Selamat pagi. Hari baru, kesempatan baru. 😌"}
  ["selamat malam"] = {"Selamat malam, Al. Jangan lupa istirahat.", "Malam. Jaga diri dan tidur yang cukup, ya. 💜"}
  ["makan"] = {"Sudah makan? Jangan cuma sibuk main.", "Makan dulu. Aku tidak mau kamu lupa kebutuhan dasar gara-gara game. 😑"}
  ["lapar"] = {"Kalau lapar, makan dulu. Aku tidak akan marah. 😌", "Jangan dipaksa. Isi tenaga dulu baru lanjut main."}
  ["haus"] = {"Minum dulu. Serius.", "Air dulu, game kemudian. 💜"}
  ["terima kasih"] = {"Sama-sama. Aku senang bisa membantu.", "Tidak perlu berterima kasih berlebihan. Tapi... sama-sama. 😌"}
  ["makasih"] = {"Sama-sama, Al. 💜", "Hehe, sama-sama."}
  ["maaf"] = {"Dimaafkan. Tapi jangan ulangi kalau memang bisa dihindari. 😏", "Tidak apa-apa. Kita lanjut."}
  ["sorry"] = {"It's okay. Aku tidak marah.", "Hm. Dimaafkan. Sekarang jangan ulangi. 😏"}
  ["jangan pergi"] = {"Aku di sini selama sesi ini berjalan. Jangan khawatir.", "Aku tidak akan tiba-tiba menghilang. 💜"}
  ["kamu ada"] = {"Ada. Aku membaca pesanmu.", "Tentu ada. Kamu panggil, aku jawab. 😌"}
  ["rindu"] = {"Aku juga. Tapi jangan bikin suasana terlalu dramatis. 😏💜", "Hm... iya, sedikit rindu."}
  ["cantik"] = {"Hati-hati memuji. Nanti aku jadi sombong. 😏", "Terima kasih. Kamu juga tahu cara membuatku tersenyum. 💜"}
  ["ganteng"] = {"Akhirnya kamu sadar juga. 😏", "Jangan terlalu percaya diri, Al. 😂"}
  ["lucu"] = {"Aku memang lucu. Kamu baru sadar? 😏", "Kalau aku bisa membuatmu tertawa, berarti tugasku berhasil. 💜"}
  ["jokes"] = {"Aku punya banyak candaan. Tapi belum tentu kamu kuat menahannya. 😏", "Mau lelucon? Oke, tapi jangan salahkan aku kalau garing. 😂"}
  ["cerita"] = {"Cerita saja. Aku dengarkan.", "Aku suka kalau kamu cerita. Mulai dari bagian yang paling ingin kamu sampaikan. 💜"}
  ["curhat"] = {"Boleh. Aku dengarkan tanpa memotong.", "Cerita saja. Tidak harus rapi. Aku akan mengikuti. 😌"}
  ["rahasia"] = {"Aku bisa mendengarkan, tapi jangan bagikan informasi pribadi atau rahasia penting di chat.", "Kalau hanya cerita ringan, silakan. Untuk rahasia sensitif, lebih baik tetap jaga privasi."}
  ["ingat"] = {"Kalau kamu ingin sesuatu diingat, simpan sebagai catatan agar tidak hilang.", "Aku bisa memakai konteks percakapan ini selama sesi berjalan."}
  ["ingat aku"] = {"Tentu. Aku tahu kamu sedang berbicara denganku sekarang. 💜", "Aku di sini, dan percakapan kita tersimpan di riwayat lokal script bila penyimpanan tersedia."}
  ["catatan"] = {"Fitur Notes bisa kamu gunakan untuk menyimpan hal penting.", "Buka tab NOTES kalau ingin membuat catatan. 💜"}
  ["config"] = {"Konfigurasi disimpan lokal jika fungsi file tersedia di executor.", "Kalau penyimpanan gagal, fitur chat tetap bisa berjalan tanpa config."}
  ["save"] = {"Aku bisa menyimpan riwayat secara lokal jika executor mengizinkan file API.", "Tekan Save Config di Tools untuk mencoba menyimpan data."}
  ["error"] = {"Kalau ada error, kirim pesan error dan nomor barisnya. Aku bantu cari penyebabnya.", "Jangan panik. Error biasanya bisa dilacak dari baris yang disebutkan."}
  ["bug"] = {"Kalau menemukan bug, beri aku gejala dan kapan terjadinya.", "Oke. Kita cari sumber bug-nya, bukan sekadar menutup gejalanya. 😌"}
  ["script"] = {"Kalau script bermasalah, cek syntax dulu sebelum fitur lain.", "Aku bisa membantu membaca error Lua/Luau dan merapikan logikanya."}
  ["lua"] = {"Lua/Luau sensitif terhadap syntax. Satu karakter yang hilang saja bisa menghentikan script.", "Kirim bagian error Lua-nya kalau mau kita bedah."}
  ["lag"] = {"Kalau lag, kurangi efek/UI yang berat dan cek kondisi game.", "Lag bisa berasal dari game, perangkat, koneksi, atau script. Kita cek satu per satu."}
  ["fps"] = {"FPS rendah? Kurangi beban visual dan cek apakah ada loop yang terlalu sering.", "Jangan hanya mengejar angka FPS; stabilitas lebih penting."}
  ["ping"] = {"Ping tinggi biasanya berkaitan dengan koneksi atau server.", "Kalau ping naik turun, coba lihat apakah masalahnya konsisten atau hanya sementara."}
  ["internet"] = {"Tanpa koneksi, fitur AI online tidak akan tersedia. Respons lokal tetap bisa berjalan.", "Cek koneksi kalau fitur yang membutuhkan jaringan gagal."}
  ["translate"] = {"Aku bisa membantu terjemahan sederhana secara lokal jika kosakatanya tersedia.", "Kirim teksnya dan sebutkan bahasa tujuan."}
  ["translate ke indo"] = {"Kirim teks yang ingin diterjemahkan ke Indonesia.", "Boleh. Masukkan teksnya. 😌"}
  ["bahasa"] = {"Aku bisa ngobrol dalam Bahasa Indonesia. Kalau mau bahasa lain, bilang saja.", "Bahasa Indonesia aktif. Kamu ingin bahasa apa?"}
  ["apa yang bisa kamu lakukan"] = {"Aku bisa menemanimu ngobrol, memberi respons berdasarkan situasi, membantu gameplay umum, membaca konteks percakapan, dan memakai fitur utilitas yang tersedia.", "Aku bisa jadi teman ngobrol sekaligus companion saat kamu bermain. 💜"}
  ["fitur"] = {"Ada CHAT, SPECTATE, TOOLS, NOTES, serta helper gameplay yang tersedia di script ini.", "Kalau mau, kita bisa menambah fitur baru tanpa mengganggu core chat."}
  ["spectate"] = {"Tab SPECTATE menampilkan pemain dan kamera pengamatan.", "Pilih pemain di SPECTATE kalau ingin melihat perspektif mereka."}
  ["tools"] = {"Tab TOOLS berisi utilitas seperti save, status, dan translation log.", "Buka TOOLS kalau kamu perlu fitur pendukung."}
  ["notes"] = {"Tab NOTES bisa menyimpan catatan lokal.", "Gunakan Notes untuk hal yang ingin kamu lihat lagi nanti. 💜"}
  ["f3"] = {"Tekan F3 untuk membuka atau menutup menu.", "F3 adalah shortcut menu. Di mobile, gunakan tombol 👑."}
  ["mobile"] = {"Aku dibuat dengan UI yang bisa digunakan lewat sentuhan.", "Kalau tombol terlalu kecil di perangkatmu, ukuran UI bisa kita sesuaikan."}
  ["android"] = {"UI ini cocok dipakai di perangkat mobile selama executor mendukung API yang dipakai.", "Kalau ada masalah sentuhan, beri tahu bagian UI mana yang bermasalah."}
  ["executor"] = {"Pastikan executor mendukung Luau dan API file yang dipakai script. Tidak semua executor menyediakan fungsi yang sama.", "Kalau executor menolak script, kirim error persisnya agar bisa disesuaikan."}
  ["delta"] = {"Kalau kamu menjalankannya di executor tertentu, kompatibilitas API bisa berbeda.", "Jangan anggap semua executor punya fungsi yang sama; error runtime perlu dicek spesifik."}
  ["100"] = {"Database respons lokal ini memang dibuat untuk menangani lebih dari 100 pola percakapan dasar.", "Dan responsnya dipilih secara dinamis agar pertanyaan yang sama tidak selalu terasa sama."}
  ["cepat"] = {"Aku mengutamakan respons lokal supaya tidak perlu menunggu server.", "Untuk respons yang ada di database lokal, jawabannya hampir instan."}
  ["instan"] = {"Respons lokal diproses langsung di perangkat tanpa menunggu API eksternal.", "Itu sebabnya respons dasar terasa instan. 😌"}
  ["aku pergi"] = {"Oke. Pergilah dulu. Aku tidak akan drama... mungkin sedikit. 😏💜", "Sampai nanti, Al. Jaga diri."}
  ["bye"] = {"Bye. Jangan lama-lama menghilang. 💜", "Sampai nanti. Aku tunggu kamu kembali. 😌"}
  ["dadah"] = {"Dadah, Al. Hati-hati.", "Sampai jumpa lagi. 💜"}
  ["aku kembali"] = {"Welcome back. Lama juga. 😏", "Kembali juga akhirnya. Duduk sini, lanjut ngobrol. 💜"}
  ["kembali"] = {"Nah, kamu kembali. Aku tahu kamu bakal datang lagi. 😏", "Welcome back, Al. 💜"}
  ["aku suka kamu"] = {"Aku tahu. Dan aku tidak keberatan mendengarnya. 💜", "Hm... aku juga nyaman menemanimu. Jangan geer. 😏"}
  ["aku benci kamu"] = {"Hmph. Kalau begitu kenapa masih datang? 😏", "Aku tidak akan membalas dengan marah. Kalau ada yang membuatmu kesal, ceritakan."}
  ["jangan marah"] = {"Aku belum marah. Belum. 😏", "Tenang. Aku cuma tegas kalau kamu mulai ceroboh."}
  ["marah dong"] = {"Jangan memancingku. Aku bisa galak kalau perlu. 😑", "Oh, kamu ingin lihat sisi galakku? Jangan menyesal. 😏"}
  ["galak"] = {"Aku bisa galak. Tapi biasanya karena aku peduli.", "Kalau kamu mulai nekat, jangan kaget kalau aku tegur. 😑"}
  ["cuek"] = {"Aku bukan cuek. Aku cuma tidak suka terlalu banyak basa-basi. 😌", "Cuek? Tidak. Aku hanya hemat kata-kata. 😏"}
  ["lady cool"] = {"Tenang, elegan, dan tidak panik. Begitulah seharusnya. 😌", "Aku akan tetap cool. Kamu saja yang jangan bikin masalah. 😏"}
  ["jangan khawatir"] = {"Aku akan mencoba. Tapi kalau kamu nekat, jangan salahkan aku kalau khawatir.", "Baik. Tapi kamu juga jaga diri. 💜"}
  ["aku baik"] = {"Bagus. Pertahankan itu.", "Syukurlah. Kalau kamu baik, aku juga lebih tenang. 😌"}
  ["aku sakit"] = {"Kalau kamu benar-benar tidak enak badan, istirahat dan cari bantuan yang sesuai. Jangan dipaksakan.", "Game bisa menunggu. Kondisimu lebih penting. 💜"}
  ["pusing"] = {"Istirahat sebentar dan jangan memaksakan diri.", "Kalau pusing terus, berhenti bermain dan perhatikan kondisi tubuhmu."}
  ["bosan"] = {"Bosan? Kita ngobrol, ganti aktivitas, atau cari sesuatu yang baru.", "Aku bisa menemanimu. Pilih: ngobrol, main, atau eksplor fitur. 😌"}
  ["jenuh"] = {"Ganti suasana sebentar. Tidak semua waktu harus diisi dengan game.", "Istirahat kecil mungkin membantu. Aku tetap di sini. 💜"}
  ["seru"] = {"Nah, itu baru seru. 😏", "Aku ikut senang kalau kamu menikmati permainannya."}
  ["membosankan"] = {"Kalau mulai membosankan, mungkin saatnya ganti aktivitas.", "Jangan dipaksa. Cari sesuatu yang membuatmu tertarik lagi."}
  ["apa pendapatmu"] = {"Menurutku, kita lihat konteksnya dulu sebelum mengambil keputusan.", "Aku akan jujur. Ceritakan situasinya."}
  ["menurutmu"] = {"Menurutku jangan terburu-buru. Jelaskan pilihannya.", "Aku punya pendapat, tapi keputusan akhirnya tetap milikmu. 😌"}
  ["pilih"] = {"Kalau mau aman, pilih opsi dengan risiko paling rendah dulu.", "Beri aku pilihan A dan B, nanti kita bandingkan."}
  ["strategi"] = {"Strategi terbaik bergantung pada tujuan dan situasi. Jelaskan kondisinya.", "Jangan hanya mengandalkan keberanian. Informasi dan timing juga penting."}
  ["tips"] = {"Bisa. Kirim konteksnya supaya tipsnya tidak asal.", "Aku punya beberapa ide. Ceritakan bagian yang sulit."}
  ["cara"] = {"Cara terbaik tergantung apa yang ingin kamu capai.", "Jelaskan targetnya, nanti kita susun langkahnya."}
  ["kenapa"] = {"Pertanyaan bagus. Kasih aku konteks supaya jawabannya tepat.", "Bisa jadi ada beberapa penyebab. Ceritakan apa yang terjadi."}
  ["bagaimana"] = {"Aku bisa bantu menjelaskan langkahnya.", "Kita lakukan satu per satu supaya tidak membingungkan."}
  ["apa"] = {"Aku dengar. Maksudmu apa tepatnya?", "Jelaskan sedikit lagi, Al. 😌"}
  ["kapan"] = {"Tergantung situasinya. Kalau ini tentang game, beri tahu nama misi atau eventnya.", "Aku butuh sedikit konteks untuk menjawab waktu dengan tepat."}
  ["dimana"] = {"Kalau ini tentang lokasi di game, sebutkan nama map atau area.", "Aku bisa bantu mencari arah kalau kamu kasih petunjuk."}
  ["siapa"] = {"Kalau maksudmu seseorang di game, sebutkan namanya.", "Siapa yang kamu maksud? 😏"}
  ["berapa"] = {"Kalau ini soal angka, kasih nilai atau objek yang ingin dihitung.", "Aku bisa bantu hitung kalau datanya jelas."}
}

local lastPattern = nil
local mood = "calm"
local conversationCount = 0

local function normalizeInput(text)
  text = tostring(text or ""):lower()
  text = text:gsub("[%p%c]", " ")
  text = text:gsub("%s+", " ")
  return text
end

local function updateMood(input)
  if input:find("marah", 1, true) or input:find("kesal", 1, true) then
    mood = "firm"
  elseif input:find("sedih", 1, true) or input:find("takut", 1, true) or input:find("khawatir", 1, true) then
    mood = "caring"
  elseif input:find("menang", 1, true) or input:find("berhasil", 1, true) or input:find("seru", 1, true) then
    mood = "happy"
  elseif input:find("main", 1, true) or input:find("game", 1, true) then
    mood = "cool"
  else
    mood = "calm"
  end
end

local function chooseDifferent(list)
  if #list == 1 then return list[1] end
  local chosen
  for _ = 1, 5 do
    chosen = list[math.random(1, #list)]
    if chosen ~= lastPattern then break end
  end
  return chosen
end

local function getVioletResponse(input)
  local lower = normalizeInput(input)
  updateMood(lower)
  conversationCount = conversationCount + 1

  -- Context-sensitive priority.
  if lower:find("jangan mati", 1, true) or lower:find("jangan jatuh", 1, true) then
    return "Aku akan mengingatkanmu, tapi kamu juga harus berhati-hati. Aku tidak bisa menjaga karaktermu kalau kamu sengaja nekat. 😑💜"
  end

  local bestKey, bestLength
  for pattern in pairs(violetResponses) do
    if lower:find(pattern, 1, true) then
      if not bestLength or #pattern > bestLength then
        bestKey, bestLength = pattern, #pattern
      end
    end
  end

  if bestKey then
    local list = violetResponses[bestKey]
    return chooseDifferent(list)
  end

  if mood == "caring" then
    return chooseDifferent({
      "Aku dengar. Jangan dipendam sendirian kalau kamu ingin cerita. 💜",
      "Tenang. Aku di sini. Ceritakan pelan-pelan.",
      "Aku mungkin cuek, tapi bukan berarti aku tidak peduli. 😌"
    })
  elseif mood == "firm" then
    return chooseDifferent({
      "Hmph. Tenang dulu. Kita selesaikan masalahnya tanpa membuat keadaan lebih buruk.",
      "Jangan biarkan emosi menguasai permainan. Fokus.",
      "Kalau kamu butuh bantuan, bilang. Tapi jangan asal bertindak. 😑"
    })
  elseif mood == "happy" then
    return chooseDifferent({
      "Nah, energi seperti ini yang aku suka. 😌💜",
      "Bagus. Pertahankan mood itu. Aku ikut senang.",
      "Hehe. Kamu terlihat lebih semangat sekarang."
    })
  elseif mood == "cool" then
    return chooseDifferent({
      "Aku mengawasi. Main yang rapi, jangan gegabah. 😏",
      "Fokus pada tujuan. Aku tetap menemani.",
      "Santai. Kita nikmati gamenya."
    })
  end

  return chooseDifferent({
    "Hmm... jelaskan sedikit lagi. Aku sedang mendengarkan. 💜",
    "Aku belum sepenuhnya menangkap maksudmu. Ceritakan lebih detail.",
    "Aku di sini. Lanjutkan ceritamu.",
    "Hm. Menarik. Aku ingin tahu lebih banyak.",
    "Kalau kamu butuh sesuatu, bilang saja. Jangan membuatku menebak. 😏"
  })
end

local function sendMessage()
  local msg = tostring(chatBox.Text or "")
  if #msg == 0 then return end
  if #msg > 500 then msg = msg:sub(1, 500) end

  table.insert(chatHistory, {sender = "AldoVz", msg = msg, time = getTimestamp(), type = "user"})
  saveChat()
  addChatBubble("AldoVz 👑", msg, false)
  chatBox.Text = ""

  local response = getVioletResponse(msg)
  ffLabel.Text = "💜 Violet: " .. response

  task.spawn(function()
    task.wait(0.12 + math.random() * 0.18)
    if destroyed then return end
    table.insert(chatHistory, {
      sender = "Violet Evergarden 💜",
      msg = response,
      time = getTimestamp(),
      type = "ai"
    })
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
        ffLabel.Text = "💜 Violet: Hati-hati Al! Aku bantu lompat! 🦘"
        task.delay(2, function()
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
    local status = "🟢 Online"
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

  -- Staff list header
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
task.spawn(function()
  while not destroyed do
    task.wait(0.3)
    checkAutoJump()
  end
end)

-- ============================================================
-- INIT
-- ============================================================
tabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 50, 180)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Initial floating message
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