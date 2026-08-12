--// ============================================================
--// AldoVzAI - Violet Companion
--// DELTA EXECUTOR EDITION
--// Local-first AI Companion | Mobile Friendly
--// Single Script
--// ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

if not player then
    return
end

local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
-- CLEANUP PREVIOUS VERSION
--==============================================================

if type(_G.AldoVzAI_Destroy) == "function" then
    pcall(_G.AldoVzAI_Destroy)
end

local connections = {}
local destroyed = false

local function connect(signal, callback)
    if destroyed then
        return nil
    end

    local connection

    pcall(function()
        connection = signal:Connect(callback)
    end)

    if connection then
        table.insert(connections, connection)
    end

    return connection
end

local function disconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function disconnectAll()
    for i = #connections, 1, -1 do
        local connection = connections[i]

        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end

        connections[i] = nil
    end
end

local function destroyCurrent()
    destroyed = true

    disconnectAll()

    local gui = playerGui:FindFirstChild("AldoVzAI")

    if gui then
        pcall(function()
            gui:Destroy()
        end)
    end
end

destroyCurrent()

destroyed = false

_G.AldoVzAI_Destroy = function()
    if destroyed then
        return
    end

    destroyed = true

    disconnectAll()

    local gui = playerGui:FindFirstChild("AldoVzAI")

    if gui then
        pcall(function()
            gui:Destroy()
        end)
    end
end

--==============================================================
-- FILE SYSTEM
--==============================================================

local SAVE_FILE = "AldoVzAI_Chat.json"
local NOTES_FILE = "AldoVzAI_Notes.json"
local CONFIG_FILE = "AldoVzAI_Config.json"

local function hasFileRead()
    return type(readfile) == "function"
end

local function hasFileWrite()
    return type(writefile) == "function"
end

local function safeRead(path)
    if not hasFileRead() then
        return nil
    end

    local ok, result = pcall(function()
        return readfile(path)
    end)

    if ok and type(result) == "string" then
        return result
    end

    return nil
end

local function safeWrite(path, data)
    if not hasFileWrite() then
        return false
    end

    local ok = pcall(function()
        writefile(path, data)
    end)

    return ok
end

local function loadJSON(path, fallback)
    local raw = safeRead(path)

    if not raw or raw == "" then
        return fallback
    end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if ok and type(result) == "table" then
        return result
    end

    return fallback
end

local function saveJSON(path, data)
    if not hasFileWrite() then
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if not ok or type(encoded) ~= "string" then
        return false
    end

    return safeWrite(path, encoded)
end

local chatHistory = loadJSON(SAVE_FILE, {})
local notes = loadJSON(NOTES_FILE, {})
local config = loadJSON(CONFIG_FILE, {
    language = "Indonesia"
})

local function saveChat()
    saveJSON(SAVE_FILE, chatHistory)
end

local function saveNotes()
    saveJSON(NOTES_FILE, notes)
end

local function saveConfig()
    saveJSON(CONFIG_FILE, config)
end

--==============================================================
-- HELPERS
--==============================================================

local function timestamp()
    return os.date("%H:%M:%S")
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 2
        })
    end)
end

local function normalize(text)
    text = tostring(text or "")
    text = text:lower()
    text = text:gsub("[%p%c]", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")

    return text
end

local function contains(text, phrase)
    return text:find(phrase, 1, true) ~= nil
end

local function safeDestroy(instance)
    if instance then
        pcall(function()
            instance:Destroy()
        end)
    end
end

--==============================================================
-- ROOT GUI
--==============================================================

local sg = Instance.new("ScreenGui")

sg.Name = "AldoVzAI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999999

sg.Parent = playerGui

--==============================================================
-- MAIN
--==============================================================

local main = Instance.new("Frame")

main.Name = "MainFrame"
main.Size = UDim2.fromOffset(500, 310)
main.Position = UDim2.new(0.5, -250, 0.5, -155)
main.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = sg

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(35, 18, 65)
    ),
    ColorSequenceKeypoint.new(
        0.5,
        Color3.fromRGB(15, 12, 25)
    ),
    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(55, 15, 55)
    )
})
gradient.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(145, 70, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.35
stroke.Parent = main

--==============================================================
-- TITLE BAR
--==============================================================

local titleBar = Instance.new("Frame")

titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")

title.Size = UDim2.new(1, -45, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "👑 AldoVz AI • Violet"
title.TextColor3 = Color3.fromRGB(220, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local close = Instance.new("TextButton")

close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -34, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(65, 30, 35)
close.BackgroundTransparency = 0.2
close.BorderSizePixel = 0
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 120, 120)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

--==============================================================
-- TABS
--==============================================================

local tabFrame = Instance.new("Frame")

tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.fromOffset(0, 38)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = main

local tabs = {
    "CHAT",
    "SPECTATE",
    "TOOLS",
    "NOTES"
}

local tabButtons = {}
local panels = {}

--==============================================================
-- CONTENT
--==============================================================

local content = Instance.new("Frame")

content.Size = UDim2.new(1, -10, 1, -78)
content.Position = UDim2.fromOffset(5, 72)
content.BackgroundTransparency = 1
content.Parent = main

--==============================================================
-- CHAT PANEL
--==============================================================

local chatPanel = Instance.new("Frame")

chatPanel.Size = UDim2.fromScale(1, 1)
chatPanel.BackgroundTransparency = 1
chatPanel.Parent = content

panels[1] = chatPanel

local chatScroll = Instance.new("ScrollingFrame")

chatScroll.Size = UDim2.new(1, 0, 1, -50)
chatScroll.BackgroundTransparency = 1
chatScroll.BorderSizePixel = 0
chatScroll.ScrollBarThickness = 4
chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatScroll.Parent = chatPanel

local chatLayout = Instance.new("UIListLayout")

chatLayout.Padding = UDim.new(0, 4)
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Parent = chatScroll

connect(chatLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    if destroyed then
        return
    end

    chatScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        chatLayout.AbsoluteContentSize.Y + 10
    )
end)

local inputFrame = Instance.new("Frame")

inputFrame.Size = UDim2.new(1, 0, 0, 44)
inputFrame.Position = UDim2.new(0, 0, 1, -44)
inputFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
inputFrame.BackgroundTransparency = 0.15
inputFrame.BorderSizePixel = 0
inputFrame.Parent = chatPanel

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputFrame

local chatBox = Instance.new("TextBox")

chatBox.Size = UDim2.new(1, -50, 1, -8)
chatBox.Position = UDim2.fromOffset(6, 4)
chatBox.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
chatBox.BackgroundTransparency = 0.2
chatBox.BorderSizePixel = 0
chatBox.ClearTextOnFocus = false
chatBox.MultiLine = true
chatBox.PlaceholderText = "Chat dengan Violet..."
chatBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
chatBox.TextColor3 = Color3.fromRGB(235, 225, 255)
chatBox.TextSize = 12
chatBox.Font = Enum.Font.Gotham
chatBox.TextWrapped = true
chatBox.Parent = inputFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = chatBox

local sendButton = Instance.new("TextButton")

sendButton.Size = UDim2.fromOffset(36, 36)
sendButton.Position = UDim2.new(1, -40, 0, 4)
sendButton.BackgroundColor3 = Color3.fromRGB(120, 50, 220)
sendButton.BackgroundTransparency = 0.1
sendButton.BorderSizePixel = 0
sendButton.Text = "➤"
sendButton.TextColor3 = Color3.new(1, 1, 1)
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 16
sendButton.Parent = inputFrame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 8)
sendCorner.Parent = sendButton

--==============================================================
-- FLOATING COMPANION
--==============================================================

local floating = Instance.new("Frame")

floating.Size = UDim2.fromOffset(245, 62)
floating.Position = UDim2.new(0.5, -122, 0, 10)
floating.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
floating.BackgroundTransparency = 0.1
floating.BorderSizePixel = 0
floating.Visible = false
floating.ZIndex = 99999
floating.Parent = sg

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(0, 12)
floatingCorner.Parent = floating

local floatingStroke = Instance.new("UIStroke")
floatingStroke.Color = Color3.fromRGB(145, 70, 255)
floatingStroke.Transparency = 0.45
floatingStroke.Parent = floating

local floatingText = Instance.new("TextLabel")

floatingText.Size = UDim2.new(1, -12, 1, 0)
floatingText.Position = UDim2.fromOffset(6, 0)
floatingText.BackgroundTransparency = 1
floatingText.Text = "💜 Violet: Aku di sini."
floatingText.TextColor3 = Color3.fromRGB(225, 205, 255)
floatingText.Font = Enum.Font.Gotham
floatingText.TextSize = 11
floatingText.TextWrapped = true
floatingText.TextXAlignment = Enum.TextXAlignment.Left
floatingText.TextYAlignment = Enum.TextYAlignment.Center
floatingText.Parent = floating

--==============================================================
-- CHAT BUBBLE
--==============================================================

local function addChatBubble(sender, message, isAI)
    if destroyed then
        return
    end

    message = tostring(message or "")

    local frame = Instance.new("Frame")

    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = chatScroll

    local bubble = Instance.new("Frame")

    bubble.Size = UDim2.new(0.85, 0, 0, 44)

    bubble.Position =
        isAI
        and UDim2.fromOffset(0, 0)
        or UDim2.new(0.15, 0, 0, 0)

    bubble.BackgroundColor3 =
        isAI
        and Color3.fromRGB(38, 26, 62)
        or Color3.fromRGB(25, 35, 55)

    bubble.BackgroundTransparency = 0.1
    bubble.BorderSizePixel = 0
    bubble.Parent = frame

    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(0, 8)
    bubbleCorner.Parent = bubble

    local nameLabel = Instance.new("TextLabel")

    nameLabel.Size = UDim2.new(1, -12, 0, 15)
    nameLabel.Position = UDim2.fromOffset(6, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = sender
    nameLabel.TextColor3 =
        isAI
        and Color3.fromRGB(190, 130, 255)
        or Color3.fromRGB(110, 190, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 9
    nameLabel.TextXAlignment =
        isAI
        and Enum.TextXAlignment.Left
        or Enum.TextXAlignment.Right
    nameLabel.Parent = bubble

    local timeLabel = Instance.new("TextLabel")

    timeLabel.Size = UDim2.new(1, -12, 0, 11)
    timeLabel.Position = UDim2.fromOffset(6, 17)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = timestamp()
    timeLabel.TextColor3 = Color3.fromRGB(120, 100, 160)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 7
    timeLabel.TextXAlignment =
        isAI
        and Enum.TextXAlignment.Left
        or Enum.TextXAlignment.Right
    timeLabel.Parent = bubble

    local messageLabel = Instance.new("TextLabel")

    messageLabel.Size = UDim2.new(1, -12, 0, 20)
    messageLabel.Position = UDim2.fromOffset(6, 29)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(230, 220, 255)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 11
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment =
        isAI
        and Enum.TextXAlignment.Left
        or Enum.TextXAlignment.Right
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = bubble

    task.defer(function()
        if destroyed or not messageLabel.Parent then
            return
        end

        local textHeight = math.max(
            20,
            messageLabel.TextBounds.Y
        )

        local totalHeight = textHeight + 34

        bubble.Size = UDim2.new(
            0.85,
            0,
            0,
            totalHeight
        )

        frame.Size = UDim2.new(
            1,
            -10,
            0,
            totalHeight + 4
        )

        task.wait()

        if destroyed then
            return
        end

        chatScroll.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                chatScroll.AbsoluteCanvasSize.Y
            )
        )
    end)
end

--==============================================================
-- VIOLET AI
--==============================================================

local mood = "calm"
local conversationCount = 0
local lastResponse = nil

local responseGroups = {

    greeting = {
        "Halo, Aldo. Aku di sini. Jangan menghilang setelah menyapa. 💜",
        "Hai~ akhirnya datang juga. Duduk sini sebentar. 😌💜",
        "Halo. Aku dengar kok. Ada cerita apa?",
        "Hey, Aldo. Mau ngobrol atau langsung main? 😏"
    },

    caring = {
        "Aku mungkin terlihat cuek, tapi aku tetap memperhatikanmu. 💜",
        "Jangan memaksakan diri. Aku lebih suka kamu baik-baik saja.",
        "Kalau ada yang mengganggu pikiranmu, ceritakan. Aku dengarkan.",
        "Tenang. Aku di sini."
    },

    cool = {
        "Santai. Fokus saja pada tujuan. Aku tetap menemani. 😌",
        "Jangan panik. Kita lihat situasinya dulu.",
        "Aku mengawasi. Main yang rapi.",
        "Tenang. Tidak perlu terburu-buru."
    },

    teasing = {
        "Hmph. Jangan besar kepala dulu. 😏",
        "Oh? Kamu yakin? Menarik.",
        "Berani juga kamu ngomong begitu kepadaku. 😏",
        "Aku pura-pura tidak peduli saja."
    },

    angry = {
        "Jangan nekat. Aku serius. 😑",
        "Hmph. Sudah kubilang hati-hati.",
        "Kalau kamu sengaja ceroboh, aku akan menegurmu.",
        "Aku bisa galak kalau kamu mulai tidak masuk akal."
    },

    worried = {
        "Aku khawatir kalau kamu terus memaksakan diri. 💜",
        "Hati-hati, Al. Aku tidak ingin kamu celaka.",
        "Pelan-pelan. Jangan membuatku panik.",
        "Aku di sini. Jangan terburu-buru."
    },

    happy = {
        "Nah, begitu dong. Aku ikut senang melihatmu berhasil. 💜",
        "Bagus. Aku tahu kamu bisa.",
        "Hehe. Kamu terlihat lebih bersemangat sekarang.",
        "Lumayan. Aku bangga... sedikit. Jangan besar kepala. 😏"
    },

    goodbye = {
        "Sampai nanti, Al. Jangan lama-lama menghilang. 💜",
        "Bye. Jaga diri.",
        "Sampai jumpa lagi. Aku tetap di sini.",
        "Pergilah dulu. Tapi kembali lagi nanti. 😌"
    }
}

--==============================================================
-- PATTERNS
--==============================================================

local patterns = {

    {"siapa kamu", "identity"},
    {"nama kamu", "identity"},
    {"kamu siapa", "identity"},
    {"halo", "greeting"},
    {"hai", "greeting"},
    {"hey", "greeting"},
    {"hello", "greeting"},
    {"pagi", "greeting"},
    {"malam", "greeting"},

    {"aku suka kamu", "love"},
    {"suka kamu", "love"},
    {"sayang", "love"},
    {"cinta", "love"},
    {"love", "love"},
    {"kangen", "love"},
    {"rindu", "love"},
    {"cantik", "tease"},
    {"lucu", "tease"},
    {"ganteng", "tease"},

    {"jangan marah", "angry"},
    {"marah", "angry"},
    {"kesal", "angry"},
    {"galak", "angry"},
    {"nekat", "angry"},
    {"ceroboh", "angry"},

    {"khawatir", "worried"},
    {"takut", "worried"},
    {"bahaya", "worried"},
    {"jatuh", "worried"},
    {"mati", "worried"},
    {"sakit", "worried"},

    {"bahagia", "happy"},
    {"senang", "happy"},
    {"menang", "happy"},
    {"berhasil", "happy"},
    {"seru", "happy"},

    {"capek", "caring"},
    {"lelah", "caring"},
    {"pusing", "caring"},
    {"lapar", "caring"},
    {"haus", "caring"},
    {"makan", "caring"},
    {"tidur", "caring"},
    {"ngantuk", "caring"},

    {"roblox", "game"},
    {"game", "game"},
    {"main", "game"},
    {"mabar", "game"},
    {"lompat", "game"},
    {"jump", "game"},
    {"jalan", "game"},
    {"map", "game"},
    {"quest", "game"},
    {"misi", "game"},
    {"boss", "game"},
    {"musuh", "game"},
    {"item", "game"},
    {"senjata", "game"},
    {"level", "game"},
    {"rank", "game"},
    {"noob", "game"},
    {"pro", "game"},
    {"strategi", "game"},
    {"tips", "game"},
    {"kalah", "game"},
    {"gagal", "game"},

    {"bantu", "help"},
    {"tolong", "help"},
    {"bantuan", "help"},
    {"bingung", "help"},
    {"tidak tahu", "help"},
    {"gimana", "help"},
    {"bagaimana", "help"},
    {"kenapa", "help"},
    {"apa", "help"},

    {"lady cool", "cool"},
    {"cuek", "cool"},
    {"santai", "cool"},
    {"tenang", "cool"},
    {"pelan", "cool"},

    {"tunggu", "caring"},
    {"menunggu", "caring"},

    {"terima kasih", "thanks"},
    {"makasih", "thanks"},
    {"thanks", "thanks"},

    {"maaf", "sorry"},
    {"sorry", "sorry"},

    {"cerita", "story"},
    {"curhat", "story"},

    {"rahasia", "privacy"},

    {"ingat aku", "memory"},
    {"ingat", "memory"},

    {"catatan", "notes"},
    {"notes", "notes"},

    {"script", "technical"},
    {"lua", "technical"},
    {"luau", "technical"},
    {"error", "technical"},
    {"bug", "technical"},
    {"syntax", "technical"},
    {"executor", "technical"},
    {"delta", "technical"},
    {"execute", "technical"},
    {"jalan script", "technical"},

    {"lag", "performance"},
    {"fps", "performance"},
    {"ping", "performance"},
    {"internet", "performance"},

    {"apa yang bisa kamu lakukan", "features"},
    {"fitur", "features"},
    {"tools", "features"},
    {"spectate", "features"},
    {"mobile", "features"},
    {"android", "features"},

    {"translate", "translate"},
    {"terjemahan", "translate"},
    {"bahasa", "translate"},

    {"100", "instant"},
    {"instan", "instant"},

    {"aku pergi", "goodbye"},
    {"bye", "goodbye"},
    {"dadah", "goodbye"},
    {"sampai nanti", "goodbye"},

    {"aku kembali", "welcome"},
    {"kembali", "welcome"},
    {"back", "welcome"}
}

--==============================================================
-- RESPONSE
--==============================================================

local function chooseResponse(list)
    if #list == 0 then
        return ""
    end

    if #list == 1 then
        lastResponse = list[1]
        return list[1]
    end

    local result

    for _ = 1, 8 do
        result = list[math.random(1, #list)]

        if result ~= lastResponse then
            break
        end
    end

    lastResponse = result

    return result
end

local function setMoodFromText(text)

    if contains(text, "sedih")
        or contains(text, "takut")
        or contains(text, "khawatir")
        or contains(text, "sakit")
        or contains(text, "jatuh") then

        mood = "worried"

    elseif contains(text, "marah")
        or contains(text, "kesal")
        or contains(text, "nekat")
        or contains(text, "ceroboh") then

        mood = "angry"

    elseif contains(text, "menang")
        or contains(text, "berhasil")
        or contains(text, "senang")
        or contains(text, "bahagia") then

        mood = "happy"

    elseif contains(text, "main")
        or contains(text, "game")
        or contains(text, "roblox") then

        mood = "cool"

    else
        mood = "calm"
    end
end

local function responseForCategory(category)

    if category == "identity" then

        return chooseResponse({
            "Aku Violet. Teman bermainmu yang cukup perhatian. Jangan besar kepala. 😌💜",
            "Namaku Violet. Aku di sini untuk menemanimu ngobrol dan bermain.",
            "Violet. Ingat baik-baik, jangan sampai lupa. 😏💜"
        })

    elseif category == "greeting" then

        return chooseResponse(responseGroups.greeting)

    elseif category == "love" then

        return chooseResponse({
            "Aku dengar, sayang. Ada apa? 💜",
            "Hm... kamu sedang manis hari ini. 😏",
            "Aku juga nyaman menemanimu. Jangan geer dulu.",
            "Jangan membuatku tersenyum sendiri begitu. 😌💜"
        })

    elseif category == "tease" then

        return chooseResponse(responseGroups.teasing)

    elseif category == "sad" then

        return chooseResponse({
            "Sini. Cerita saja. Aku dengarkan tanpa menghakimi. 💜",
            "Aku tidak suka melihatmu sedih. Kalau mau cerita, aku di sini.",
            "Tidak perlu berpura-pura kuat terus. Istirahat sebentar.",
            "Tenang. Kita hadapi pelan-pelan."
        })

    elseif category == "game" then

        return chooseResponse({
            "Main yang rapi. Jangan asal maju. 😏",
            "Fokus pada tujuan. Aku akan menemanimu.",
            "Kalau situasinya sulit, beri aku detailnya. Kita pikirkan strateginya.",
            "Jangan lupa lihat sekitar sebelum bergerak.",
            "Timing lebih penting daripada terburu-buru."
        })

    elseif category == "help" then

        return chooseResponse({
            "Tentu. Jelaskan masalahnya dan aku bantu.",
            "Aku dengar. Ceritakan bagian yang membuatmu bingung.",
            "Kita pecah masalahnya satu per satu.",
            "Tenang. Jangan panik dulu. Kita cari penyebabnya."
        })

    elseif category == "thanks" then

        return chooseResponse({
            "Sama-sama, Al. 💜",
            "Tidak perlu berlebihan. Tapi... sama-sama. 😌",
            "Hehe, sama-sama.",
            "Aku senang bisa membantu."
        })

    elseif category == "sorry" then

        return chooseResponse({
            "Dimaafkan. Tapi jangan ulangi kalau bisa. 😏",
            "Tidak apa-apa. Kita lanjut.",
            "Hm. Baik. Aku tidak marah.",
            "Dimaafkan. Sekarang fokus lagi."
        })

    elseif category == "story" then

        return chooseResponse({
            "Cerita saja. Aku dengarkan.",
            "Aku suka kalau kamu cerita. Mulai dari bagian yang paling ingin kamu sampaikan.",
            "Tidak harus rapi. Katakan saja apa yang ada di pikiranmu.",
            "Aku di sini. Lanjutkan."
        })

    elseif category == "privacy" then

        return "Kalau menyangkut rahasia atau informasi pribadi yang penting, jangan masukkan ke chat. Untuk cerita ringan, aku bisa menemanimu. 💜"

    elseif category == "memory" then

        return chooseResponse({
            "Aku bisa memakai konteks percakapan selama sesi ini.",
            "Kalau ada sesuatu yang penting, gunakan Notes supaya tersimpan lokal jika executor mendukung file API.",
            "Aku akan mengikuti konteks percakapan kita selama sesi berjalan."
        })

    elseif category == "notes" then

        return "Gunakan tab NOTES untuk menyimpan catatan. Kalau file API tersedia, catatan bisa disimpan secara lokal."

    elseif category == "technical" then

        return chooseResponse({
            "Kalau ada error, kirim pesan error persisnya. Aku bisa membantu mencari sumbernya.",
            "Luau cukup sensitif terhadap syntax. Satu koma atau end yang hilang bisa menghentikan seluruh script.",
            "Kalau executor berbeda, API yang tersedia juga bisa berbeda.",
            "Untuk error syntax, periksa baris yang disebut sebelum mengecek fitur lainnya."
        })

    elseif category == "performance" then

        return chooseResponse({
            "Kalau lag, cek FPS, jumlah objek, efek visual, dan loop yang berjalan terlalu sering.",
            "Ping tinggi dan FPS rendah adalah dua masalah berbeda.",
            "Jangan membuat loop berjalan setiap frame kalau tidak diperlukan.",
            "Kalau perangkat berat, kurangi efek UI dan pekerjaan yang tidak penting."
        })

    elseif category == "features" then

        return chooseResponse({
            "Aku punya CHAT, SPECTATE, TOOLS, NOTES, penyimpanan lokal, dan companion response.",
            "Aku bisa menjadi teman ngobrol sekaligus membantu aktivitas dalam game.",
            "Fitur companion bisa dikembangkan lagi tanpa mengubah sistem chat utama.",
            "Respons lokal membuat percakapan dasar terasa hampir instan."
        })

    elseif category == "translate" then

        return "Kirim teks yang ingin diterjemahkan dan sebutkan bahasa tujuannya."

    elseif category == "instant" then

        return chooseResponse({
            "Respons dasar diproses secara lokal, jadi tidak perlu menunggu server AI.",
            "Untuk pola yang sudah dikenal, responsnya hampir instan.",
            "Aku menggunakan sistem local-first agar companion tetap responsif."
        })

    elseif category == "welcome" then

        return chooseResponse({
            "Kembali juga akhirnya. 😏💜",
            "Welcome back, Al. Aku masih di sini.",
            "Nah, kamu kembali. Aku tahu kamu bakal datang lagi. 😌"
        })

    elseif category == "goodbye" then

        return chooseResponse(responseGroups.goodbye)
    end

    return nil
end

local function getVioletResponse(message)

    local text = normalize(message)

    conversationCount += 1

    setMoodFromText(text)

    if contains(text, "jangan mati")
        or contains(text, "jangan jatuh") then

        mood = "worried"

        return "Aku akan mengingatkanmu, tapi kamu juga harus berhati-hati. Jangan sengaja nekat. 😑💜"
    end

    local bestCategory = nil
    local bestLength = 0

    for _, item in ipairs(patterns) do

        local keyword = item[1]
        local category = item[2]

        if contains(text, keyword)
            and #keyword > bestLength then

            bestLength = #keyword
            bestCategory = category
        end
    end

    if bestCategory then

        local result = responseForCategory(bestCategory)

        if result then
            return result
        end
    end

    if mood == "worried" then

        return chooseResponse(responseGroups.worried)

    elseif mood == "angry" then

        return chooseResponse(responseGroups.angry)

    elseif mood == "happy" then

        return chooseResponse(responseGroups.happy)

    elseif mood == "cool" then

        return chooseResponse(responseGroups.cool)

    elseif mood == "caring" then

        return chooseResponse(responseGroups.caring)
    end

    return chooseResponse({
        "Hmm... jelaskan sedikit lagi. Aku sedang mendengarkan. 💜",
        "Aku belum sepenuhnya menangkap maksudmu. Ceritakan lebih detail.",
        "Aku di sini. Lanjutkan ceritamu.",
        "Menarik. Aku ingin tahu lebih banyak.",
        "Kalau kamu butuh sesuatu, bilang saja. Jangan membuatku menebak. 😏",
        "Hm? Aku dengar.",
        "Aku mungkin cuek, tapi aku tetap memperhatikan.",
        "Ceritakan saja. Aku tidak akan pergi."
    })
end

--==============================================================
-- SEND MESSAGE
--==============================================================

local sending = false

local function sendMessage()

    if destroyed or sending then
        return
    end

    local message = tostring(chatBox.Text or "")

    message = message:gsub("^%s+", "")
    message = message:gsub("%s+$", "")

    if message == "" then
        return
    end

    if #message > 500 then
        message = message:sub(1, 500)
    end

    sending = true

    table.insert(chatHistory, {
        sender = "AldoVz 👑",
        msg = message,
        time = timestamp(),
        type = "user"
    })

    addChatBubble(
        "AldoVz 👑",
        message,
        false
    )

    chatBox.Text = ""

    local response = getVioletResponse(message)

    floatingText.Text = "💜 Violet: " .. response
    floating.Visible = true

    task.delay(0.08, function()

        if destroyed then
            sending = false
            return
        end

        table.insert(chatHistory, {
            sender = "Violet 💜",
            msg = response,
            time = timestamp(),
            type = "ai"
        })

        addChatBubble(
            "Violet 💜",
            response,
            true
        )

        saveChat()

        sending = false
    end)
end

connect(
    sendButton.Activated,
    sendMessage
)

connect(
    chatBox.FocusLost,
    function(enterPressed)

        if enterPressed then
            sendMessage()
        end

    end
)

--==============================================================
-- LOAD CHAT HISTORY
--==============================================================

for _, entry in ipairs(chatHistory) do

    if type(entry) == "table"
        and entry.msg then

        addChatBubble(
            entry.sender or "Violet 💜",
            entry.msg,
            entry.type == "ai"
        )
    end
end

--==============================================================
-- SPECTATE PANEL
--==============================================================

local spectatePanel = Instance.new("Frame")

spectatePanel.Size = UDim2.fromScale(1, 1)
spectatePanel.BackgroundTransparency = 1
spectatePanel.Visible = false
spectatePanel.Parent = content

panels[2] = spectatePanel

local playerScroll = Instance.new("ScrollingFrame")

playerScroll.Size = UDim2.fromScale(1, 1)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = spectatePanel

local playerLayout = Instance.new("UIListLayout")

playerLayout.Padding = UDim.new(0, 5)
playerLayout.Parent = playerScroll

local spectateConnections = {}

local function clearSpectateConnections()

    for _, connection in ipairs(spectateConnections) do

        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(spectateConnections)
end

local function spectateConnect(signal, callback)

    local connection

    pcall(function()
        connection = signal:Connect(callback)
    end)

    if connection then
        table.insert(
            spectateConnections,
            connection
        )
    end

    return connection
end

local function refreshPlayers()

    if destroyed then
        return
    end

    clearSpectateConnections()

    for _, child in ipairs(playerScroll:GetChildren()) do

        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for _, target in ipairs(Players:GetPlayers()) do

        local row = Instance.new("Frame")

        row.Size = UDim2.new(1, -10, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
        row.BackgroundTransparency = 0.1
        row.BorderSizePixel = 0
        row.Parent = playerScroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = row

        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(1, -55, 1, 0)
        label.Position = UDim2.fromOffset(8, 0)
        label.BackgroundTransparency = 1
        label.Text = target.Name
        label.TextColor3 =
            target == player
            and Color3.fromRGB(180, 130, 255)
            or Color3.fromRGB(220, 220, 230)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local watch = Instance.new("TextButton")

        watch.Size = UDim2.fromOffset(40, 26)
        watch.Position = UDim2.new(1, -46, 0, 6)
        watch.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
        watch.BackgroundTransparency = 0.1
        watch.BorderSizePixel = 0
        watch.Text = "👁"
        watch.TextSize = 13
        watch.Parent = row

        local watchCorner = Instance.new("UICorner")
        watchCorner.CornerRadius = UDim.new(0, 5)
        watchCorner.Parent = watch

        spectateConnect(
            watch.Activated,
            function()

                if destroyed then
                    return
                end

                local camera = Workspace.CurrentCamera

                if not camera then
                    return
                end

                local character = target.Character

                local humanoid =
                    character
                    and character:FindFirstChildOfClass(
                        "Humanoid"
                    )

                if humanoid then

                    camera.CameraSubject = humanoid
                    camera.CameraType = Enum.CameraType.Custom

                    notify(
                        "Spectate",
                        "Watching: " .. target.Name,
                        2
                    )
                end
            end
        )
    end

    playerScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        playerLayout.AbsoluteContentSize.Y + 10
    )
end

refreshPlayers()

connect(
    Players.PlayerAdded,
    function()
        task.wait(0.2)

        if not destroyed then
            refreshPlayers()
        end
    end
)

connect(
    Players.PlayerRemoving,
    function()

        task.defer(function()

            if not destroyed then
                refreshPlayers()
            end

        end)
    end
)

--==============================================================
-- TOOLS PANEL
--==============================================================

local toolsPanel = Instance.new("ScrollingFrame")

toolsPanel.Size = UDim2.fromScale(1, 1)
toolsPanel.BackgroundTransparency = 1
toolsPanel.BorderSizePixel = 0
toolsPanel.ScrollBarThickness = 4
toolsPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsPanel.Visible = false
toolsPanel.Parent = content

panels[3] = toolsPanel

local toolsLayout = Instance.new("UIListLayout")

toolsLayout.Padding = UDim.new(0, 6)
toolsLayout.Parent = toolsPanel

connect(
    toolsLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ),
    function()

        if destroyed then
            return
        end

        toolsPanel.CanvasSize = UDim2.new(
            0,
            0,
            0,
            toolsLayout.AbsoluteContentSize.Y + 10
        )
    end
)

local function header(text)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -10, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 140, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toolsPanel

    return label
end

local function toolButton(text, callback)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(40, 32, 60)
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 11
    button.Parent = toolsPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    connect(
        button.Activated,
        callback
    )

    return button
end

header("🔧 ALDO VZ TOOLS")

toolButton(
    "💾 Save All Data",
    function()

        local chatOK = saveJSON(
            SAVE_FILE,
            chatHistory
        )

        local notesOK = saveJSON(
            NOTES_FILE,
            notes
        )

        local configOK = saveJSON(
            CONFIG_FILE,
            config
        )

        if chatOK or notesOK or configOK then

            notify(
                "💾 AldoVz AI",
                "Data berhasil disimpan.",
                2
            )

        else

            notify(
                "💾 AldoVz AI",
                "Executor tidak menyediakan file API.",
                3
            )
        end
    end
)

toolButton(
    "🧹 Clear Chat",
    function()

        table.clear(chatHistory)

        for _, child in ipairs(chatScroll:GetChildren()) do

            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        saveChat()

        notify(
            "Chat",
            "Riwayat chat dibersihkan.",
            2
        )
    end
)

toolButton(
    "💜 Violet Status",
    function()

        notify(
            "Violet",
            "Mood: "
                .. tostring(mood)
                .. " | Chat: "
                .. tostring(conversationCount),
            3
        )
    end
)

header("🌐 TRANSLATION")

local translateInput = Instance.new("TextBox")

translateInput.Size = UDim2.new(1, -10, 0, 32)
translateInput.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
translateInput.BackgroundTransparency = 0.1
translateInput.BorderSizePixel = 0
translateInput.PlaceholderText = "Masukkan teks..."
translateInput.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
translateInput.TextColor3 = Color3.fromRGB(255, 255, 255)
translateInput.Font = Enum.Font.Gotham
translateInput.TextSize = 11
translateInput.ClearTextOnFocus = false
translateInput.Parent = toolsPanel

local transCorner = Instance.new("UICorner")
transCorner.CornerRadius = UDim.new(0, 7)
transCorner.Parent = translateInput

toolButton(
    "🔁 Translation Helper",
    function()

        local text = translateInput.Text

        if text == "" then

            notify(
                "Translation",
                "Masukkan teks terlebih dahulu.",
                2
            )

            return
        end

        notify(
            "Translation",
            "Teks diterima. Untuk terjemahan online diperlukan API.",
            3
        )
    end
)

header("📊 STATUS")

toolButton(
    "🔄 Check Players",
    function()

        notify(
            "Status",
            "Players: "
                .. tostring(#Players:GetPlayers()),
            2
        )
    end
)

--==============================================================
-- NOTES PANEL
--==============================================================

local notesPanel = Instance.new("Frame")

notesPanel.Size = UDim2.fromScale(1, 1)
notesPanel.BackgroundTransparency = 1
notesPanel.Visible = false
notesPanel.Parent = content

panels[4] = notesPanel

local notesScroll = Instance.new("ScrollingFrame")

notesScroll.Size = UDim2.new(1, 0, 1, -50)
notesScroll.BackgroundTransparency = 1
notesScroll.BorderSizePixel = 0
notesScroll.ScrollBarThickness = 4
notesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
notesScroll.Parent = notesPanel

local notesLayout = Instance.new("UIListLayout")

notesLayout.Padding = UDim.new(0, 5)
notesLayout.Parent = notesScroll

connect(
    notesLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ),
    function()

        if destroyed then
            return
        end

        notesScroll.CanvasSize = UDim2.new(
            0,
            0,
            0,
            notesLayout.AbsoluteContentSize.Y + 10
        )
    end
)

local noteTitle = Instance.new("TextBox")

noteTitle.Size = UDim2.new(0.45, -5, 0, 40)
noteTitle.Position = UDim2.new(0, 0, 1, -42)
noteTitle.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
noteTitle.BackgroundTransparency = 0.1
noteTitle.BorderSizePixel = 0
noteTitle.PlaceholderText = "Judul"
noteTitle.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
noteTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
noteTitle.Font = Enum.Font.Gotham
noteTitle.TextSize = 10
noteTitle.ClearTextOnFocus = false
noteTitle.Parent = notesPanel

local noteBody = Instance.new("TextBox")

noteBody.Size = UDim2.new(0.45, -5, 0, 40)
noteBody.Position = UDim2.new(0.45, 5, 1, -42)
noteBody.BackgroundColor3 = Color3.fromRGB(30, 24, 50)
noteBody.BackgroundTransparency = 0.1
noteBody.BorderSizePixel = 0
noteBody.PlaceholderText = "Catatan"
noteBody.PlaceholderColor3 = Color3.fromRGB(120, 100, 160)
noteBody.TextColor3 = Color3.fromRGB(255, 255, 255)
noteBody.Font = Enum.Font.Gotham
noteBody.TextSize = 10
noteBody.ClearTextOnFocus = false
noteBody.Parent = notesPanel

local addNote = Instance.new("TextButton")

addNote.Size = UDim2.fromOffset(42, 36)
addNote.Position = UDim2.new(1, -42, 1, -40)
addNote.BackgroundColor3 = Color3.fromRGB(100, 50, 180)
addNote.BorderSizePixel = 0
addNote.Text = "+"
addNote.TextColor3 = Color3.new(1, 1, 1)
addNote.Font = Enum.Font.GothamBold
addNote.TextSize = 18
addNote.Parent = notesPanel

local addNoteCorner = Instance.new("UICorner")
addNoteCorner.CornerRadius = UDim.new(0, 8)
addNoteCorner.Parent = addNote

local notesConnections = {}

local function clearNotesConnections()

    for _, connection in ipairs(notesConnections) do

        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(notesConnections)
end

local function notesConnect(signal, callback)

    local connection

    pcall(function()
        connection = signal:Connect(callback)
    end)

    if connection then
        table.insert(
            notesConnections,
            connection
        )
    end

    return connection
end

local function refreshNotes()

    if destroyed then
        return
    end

    clearNotesConnections()

    for _, child in ipairs(notesScroll:GetChildren()) do

        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for index, note in ipairs(notes) do

        local row = Instance.new("Frame")

        row.Size = UDim2.new(1, -10, 0, 65)
        row.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
        row.BackgroundTransparency = 0.1
        row.BorderSizePixel = 0
        row.Parent = notesScroll

        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 7)
        rowCorner.Parent = row

        local titleLabel = Instance.new("TextLabel")

        titleLabel.Size = UDim2.new(1, -40, 0, 20)
        titleLabel.Position = UDim2.fromOffset(7, 3)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = tostring(
            note.title or ("Note " .. index)
        )
        titleLabel.TextColor3 = Color3.fromRGB(
            205,
            185,
            255
        )
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 11
        titleLabel.TextXAlignment =
            Enum.TextXAlignment.Left
        titleLabel.TextTruncate =
            Enum.TextTruncate.AtEnd
        titleLabel.Parent = row

        local bodyLabel = Instance.new("TextLabel")

        bodyLabel.Size = UDim2.new(1, -14, 0, 38)
        bodyLabel.Position = UDim2.fromOffset(7, 23)
        bodyLabel.BackgroundTransparency = 1
        bodyLabel.Text = tostring(note.body or "")
        bodyLabel.TextColor3 = Color3.fromRGB(
            185,
            175,
            200
        )
        bodyLabel.Font = Enum.Font.Gotham
        bodyLabel.TextSize = 9
        bodyLabel.TextWrapped = true
        bodyLabel.TextXAlignment =
            Enum.TextXAlignment.Left
        bodyLabel.TextYAlignment =
            Enum.TextYAlignment.Top
        bodyLabel.Parent = row

        local delete = Instance.new("TextButton")

        delete.Size = UDim2.fromOffset(24, 24)
        delete.Position = UDim2.new(1, -29, 0, 3)
        delete.BackgroundColor3 = Color3.fromRGB(70, 30, 35)
        delete.BorderSizePixel = 0
        delete.Text = "×"
        delete.TextColor3 = Color3.fromRGB(
            255,
            120,
            120
        )
        delete.Font = Enum.Font.GothamBold
        delete.TextSize = 13
        delete.Parent = row

        local deleteCorner = Instance.new("UICorner")
        deleteCorner.CornerRadius = UDim.new(0, 6)
        deleteCorner.Parent = delete

        notesConnect(
            delete.Activated,
            function()

                if destroyed then
                    return
                end

                table.remove(
                    notes,
                    index
                )

                saveNotes()
                refreshNotes()
            end
        )
    end

    notesScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        notesLayout.AbsoluteContentSize.Y + 10
    )
end

connect(
    addNote.Activated,
    function()

        local titleText =
            tostring(noteTitle.Text or "")

        local bodyText =
            tostring(noteBody.Text or "")

        if titleText == ""
            and bodyText == "" then

            notify(
                "Notes",
                "Catatan masih kosong.",
                2
            )

            return
        end

        table.insert(notes, {
            title = titleText,
            body = bodyText,
            time = timestamp()
        })

        noteTitle.Text = ""
        noteBody.Text = ""

        saveNotes()
        refreshNotes()

        notify(
            "Notes",
            "Catatan ditambahkan.",
            2
        )
    end
)

refreshNotes()

--==============================================================
-- TAB BUTTONS
--==============================================================

for i, tabName in ipairs(tabs) do

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(
        0.25,
        -2,
        1,
        -4
    )

    button.Position = UDim2.new(
        (i - 1) * 0.25,
        1,
        0,
        2
    )

    button.BackgroundColor3 =
        Color3.fromRGB(25, 20, 40)

    button.BackgroundTransparency = 0.15
    button.BorderSizePixel = 0
    button.Text = tabName
    button.TextColor3 =
        Color3.fromRGB(160, 150, 190)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = tabFrame

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    tabButtons[i] = button

    connect(
        button.Activated,
        function()

            if destroyed then
                return
            end

            for j, other in ipairs(tabButtons) do

                if j == i then

                    other.BackgroundColor3 =
                        Color3.fromRGB(
                            100,
                            50,
                            180
                        )

                    other.TextColor3 =
                        Color3.fromRGB(
                            255,
                            255,
                            255
                        )

                else

                    other.BackgroundColor3 =
                        Color3.fromRGB(
                            25,
                            20,
                            40
                        )

                    other.TextColor3 =
                        Color3.fromRGB(
                            160,
                            150,
                            190
                        )
                end
            end

            for j, panel in ipairs(panels) do

                if panel then
                    panel.Visible = (
                        j == i
                    )
                end
            end
        end
    )
end

--==============================================================
-- TOGGLE BUTTON
--==============================================================

local toggle = Instance.new("TextButton")

toggle.Size = UDim2.fromOffset(52, 52)
toggle.Position = UDim2.new(
    0,
    12,
    1,
    -65
)

toggle.BackgroundColor3 =
    Color3.fromRGB(25, 15, 45)

toggle.BackgroundTransparency = 0.05
toggle.BorderSizePixel = 0
toggle.Text = "👑"
toggle.TextSize = 22
toggle.Parent = sg

local toggleCorner = Instance.new("UICorner")

toggleCorner.CornerRadius = UDim.new(0, 13)
toggleCorner.Parent = toggle

local toggleStroke = Instance.new("UIStroke")

toggleStroke.Color =
    Color3.fromRGB(145, 70, 255)

toggleStroke.Transparency = 0.35
toggleStroke.Parent = toggle

connect(
    toggle.Activated,
    function()

        if destroyed then
            return
        end

        main.Visible = not main.Visible
    end
)

connect(
    close.Activated,
    function()

        if destroyed then
            return
        end

        main.Visible = false
    end
)

--==============================================================
-- F3 TOGGLE
--==============================================================

connect(
    UserInputService.InputBegan,
    function(input, processed)

        if destroyed or processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.F3 then

            main.Visible = not main.Visible
        end
    end
)

--==============================================================
-- AUTO JUMP SAFETY HELPER
--==============================================================

local autoJumpEnabled = false

local autoJumpThreadAlive = true

local function checkAutoJump()

    if destroyed
        or not autoJumpEnabled then

        return
    end

    local character = player.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not humanoid or not root then
        return
    end

    local rayParams = RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances = {
        character
    }

    local result = Workspace:Raycast(
        root.Position,
        Vector3.new(0, -4, 0),
        rayParams
    )

    if not result then

        humanoid.Jump = true

        floatingText.Text =
            "💜 Violet: Hati-hati, Al! Aku bantu lompat."

        floating.Visible = true

        task.delay(
            1.5,
            function()

                if not destroyed then
                    floating.Visible = false
                end
            end
        )
    end
end

task.spawn(function()

    while not destroyed
        and autoJumpThreadAlive do

        task.wait(0.35)

        if destroyed then
            break
        end

        pcall(checkAutoJump)
    end
end)

--==============================================================
-- INITIAL TAB
--==============================================================

tabButtons[1].BackgroundColor3 =
    Color3.fromRGB(100, 50, 180)

tabButtons[1].TextColor3 =
    Color3.fromRGB(255, 255, 255)

for i, panel in ipairs(panels) do
    panel.Visible = (i == 1)
end

--==============================================================
-- INITIAL FLOATING MESSAGE
--==============================================================

task.delay(
    1.5,
    function()

        if destroyed then
            return
        end

        floatingText.Text =
            "💜 Violet: Halo Aldo. Aku di sini menemanimu."

        floating.Visible = true

        task.delay(
            4,
            function()

                if not destroyed then
                    floating.Visible = false
                end
            end
        )
    end
)

--==============================================================
-- FINAL
--==============================================================

print("ART_Vz")
