task.wait(1)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getSafeGui()
    if gethui then return gethui() end
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

---------------------------------------------------------
-- [1] LOGIKA EMOTE (EKSTRAK ASET & OVERRIDE ANIMASI)
---------------------------------------------------------
local currentTrack = nil
local moveConnection = nil
local jumpConnection = nil

local function stopCurrentEmote()
    if currentTrack then
        currentTrack:Stop()
        currentTrack = nil
    end
    if moveConnection then moveConnection:Disconnect() moveConnection = nil end
    if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
end

local function getAnimationObject(assetId)
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)
    end)
    if success and objects then
        for _, v in ipairs(objects) do
            if v:IsA("Animation") then return v end
            local anim = v:FindFirstChildOfClass("Animation", true)
            if anim then return anim end
        end
    end
    local directAnim = Instance.new("Animation")
    directAnim.AnimationId = "rbxassetid://" .. assetId
    return directAnim
end

local function playEmote(assetId)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopCurrentEmote()
    local animObject = getAnimationObject(assetId)
    if not animObject then return end

    local success, track = pcall(function() return animator:LoadAnimation(animObject) end)
    if success and track then
        currentTrack = track
        currentTrack.Priority = Enum.AnimationPriority.Action4
        currentTrack:Play()

        moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if humanoid.MoveDirection.Magnitude > 0 then stopCurrentEmote() end
        end)
        jumpConnection = humanoid.StateChanged:Connect(function(_, state)
            if state == Enum.HumanoidStateType.Jumping then stopCurrentEmote() end
        end)
    end
end

---------------------------------------------------------
-- [2] PEMBUATAN UI (GAYA 1709.PNG - DELTA STYLE)
---------------------------------------------------------
local GuiParent = getSafeGui()
if GuiParent:FindFirstChild("VoidVainlyStar_AldoVVS") then
    GuiParent.VoidVainlyStar_AldoVVS:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStar_AldoVVS"
ScreenGui.Parent = GuiParent
ScreenGui.ResetOnSpawn = false

-- Warna Tema
local ColorBlack = Color3.fromRGB(5, 5, 5)
local ColorMagenta = Color3.fromRGB(255, 0, 255)
local ColorCyan = Color3.fromRGB(0, 255, 255)
local ColorWhite = Color3.fromRGB(255, 255, 255)

-- [OPEN BUTTON] Bulat dengan Crown dan Border Magenta
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 1, -60)
OpenButton.BackgroundColor3 = ColorBlack
OpenButton.Text = "👑"
OpenButton.TextSize = 20
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = ColorMagenta
OpenStroke.Thickness = 2.5
OpenStroke.Parent = OpenButton

-- [MAIN FRAME] Latar Hitam
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 280)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = ColorBlack
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Responsif untuk layar HP kecil
local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MaxSize = Vector2.new(600, 350)
SizeConstraint.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- [HEADER AREA]
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(0, 100, 1, 0)
MenuTitle.Position = UDim2.new(0, 15, 0, 0)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = ColorWhite
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextSize = 16
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
MenuTitle.Parent = Header

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, -120, 1, 0)
MainTitle.Position = UDim2.new(0, 100, 0, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "👑 VOID VAINLY STAR"
MainTitle.TextColor3 = ColorWhite
MainTitle.Font = Enum.Font.Gotham
MainTitle.TextSize = 16
MainTitle.TextXAlignment = Enum.TextXAlignment.Center
MainTitle.Parent = Header

-- Tombol Close X transparan di ujung kanan
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = ""
CloseBtn.Parent = Header

-- [GARIS PEMISAH MAGENTA]
local H_Line = Instance.new("Frame")
H_Line.Size = UDim2.new(1, 0, 0, 4)
H_Line.Position = UDim2.new(0, 0, 0, 40)
H_Line.BackgroundColor3 = ColorMagenta
H_Line.BorderSizePixel = 0
H_Line.Parent = MainFrame

local V_Line = Instance.new("Frame")
V_Line.Size = UDim2.new(0, 4, 1, -44)
V_Line.Position = UDim2.new(0, 120, 0, 44)
V_Line.BackgroundColor3 = ColorMagenta
V_Line.BorderSizePixel = 0
V_Line.Parent = MainFrame

-- [SIDEBAR KIRI]
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local function createSidebarButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = ColorMagenta
    btn.Text = text
    btn.TextColor3 = ColorCyan
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    return btn
end

local BtnEmote = createSidebarButton("EMOTE", 15)
local BtnMain = createSidebarButton("MAIN", 50)
local BtnControl = createSidebarButton("CONTROL", 85)

-- [KONTEN UTAMA KANAN]
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -134, 1, -44)
ContentFrame.Position = UDim2.new(0, 134, 0, 44)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 0
ContentFrame.Parent = MainFrame

local TitleList = Instance.new("TextLabel")
TitleList.Size = UDim2.new(1, 0, 0, 30)
TitleList.Position = UDim2.new(0, 0, 0, 5)
TitleList.BackgroundTransparency = 1
TitleList.Text = "List Emote"
TitleList.TextColor3 = ColorWhite
TitleList.Font = Enum.Font.GothamBold
TitleList.TextSize = 16
TitleList.TextXAlignment = Enum.TextXAlignment.Left
TitleList.Parent = ContentFrame

-- Data Emote
local emotes = {
    {Name = "1. Emote jalan snoop", Id = "110614921871084"},
    {Name = "2. Tertawa", Id = "122240620529815"},
    {Name = "3. Tubuh berputar", Id = "104039491726272"},
    {Name = "4. Aneh", Id = "111020075303418"},
    {Name = "5. Goku's Warmup", Id = "108013663975520"},
    {Name = "6. Goku SSJ", Id = "73708713364616"},
    {Name = "7. POSE ANIME TREND", Id = "111491675811633"}
}

-- Generate List Teks Emote (Tanpa Background)
local yOffset = 40
for _, emote in ipairs(emotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.Position = UDim2.new(0, 0, 0, yOffset)
    btn.BackgroundTransparency = 1
    btn.Text = emote.Name
    btn.TextColor3 = ColorWhite
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ContentFrame

    btn.MouseButton1Click:Connect(function()
        playEmote(emote.Id)
    end)
    
    yOffset = yOffset + 22
end

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)

-- [FOOTER] by AldoVVS
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(0, 100, 0, 20)
FooterLabel.Position = UDim2.new(1, -110, 1, -25)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "by AldoVVS"
FooterLabel.TextColor3 = ColorWhite
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.TextSize = 12
FooterLabel.TextXAlignment = Enum.TextXAlignment.Right
FooterLabel.Parent = MainFrame

-- [TOGGLE LOGIC]
local isVisible = false
local function ToggleUI()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
    OpenButton.Visible = not isVisible
end

OpenButton.MouseButton1Click:Connect(ToggleUI)
CloseBtn.MouseButton1Click:Connect(ToggleUI) -- Bisa tutup dengan klik pojok kanan atas Header
