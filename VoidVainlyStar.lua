task.wait(1)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local function getSafeGui()
    if gethui then return gethui() end
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

---------------------------------------------------------
-- [1] LOGIKA ANIMASI & EKSTRAKSI ASET
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

-- Mengekstrak objek Animation dari ID Marketplace
local function getAnimationObject(assetId)
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)
    end)

    if success and objects then
        for _, v in ipairs(objects) do
            if v:IsA("Animation") then
                return v
            end
            local anim = v:FindFirstChildOfClass("Animation", true)
            if anim then
                return anim
            end
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

    local success, track = pcall(function()
        return animator:LoadAnimation(animObject)
    end)

    if success and track then
        currentTrack = track
        currentTrack.Priority = Enum.AnimationPriority.Action4 -- Paksa override idle/jalan game
        currentTrack:Play()

        -- Berhenti saat gerak
        moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if humanoid.MoveDirection.Magnitude > 0 then
                stopCurrentEmote()
            end
        end)

        -- Berhenti saat lompat
        jumpConnection = humanoid.StateChanged:Connect(function(_, state)
            if state == Enum.HumanoidStateType.Jumping then
                stopCurrentEmote()
            end
        end)
    end
end

---------------------------------------------------------
-- [2] SISTEM UI LIBRARY MOBILE
---------------------------------------------------------
local UILibrary = {}
local Colors = {
    Background = Color3.fromRGB(20, 20, 20),
    ElementBg = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke1 = Color3.fromRGB(0, 255, 255), -- Cyan
    Stroke2 = Color3.fromRGB(128, 0, 128)  -- Ungu
}

local function addGradientStroke(parent, thickness, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 2
    stroke.Parent = parent

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Stroke1),
        ColorSequenceKeypoint.new(1, Colors.Stroke2)
    })
    gradient.Parent = stroke
end

function UILibrary:MakeWindow(config)
    local WindowName = config.Name or "UI"
    local Icon = config.Icon or ""
    
    local GuiParent = getSafeGui()
    if GuiParent:FindFirstChild(WindowName .. "_GUI") then
        GuiParent[WindowName .. "_GUI"]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = WindowName .. "_GUI"
    ScreenGui.Parent = GuiParent
    ScreenGui.ResetOnSpawn = false

    -- Open Button di pojok kiri bawah
    local OpenButton = Instance.new("TextButton")
    OpenButton.Size = UDim2.new(0, 50, 0, 50)
    OpenButton.Position = UDim2.new(0, 15, 1, -65) 
    OpenButton.BackgroundColor3 = Colors.Background
    OpenButton.Text = Icon
    OpenButton.TextSize = 22
    OpenButton.Parent = ScreenGui
    addGradientStroke(OpenButton, 2.5, 25)

    -- Frame Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.85, 0, 0.65, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UISizeConstraint = Instance.new("UISizeConstraint")
    UISizeConstraint.MaxSize = Vector2.new(400, 500)
    UISizeConstraint.Parent = MainFrame
    addGradientStroke(MainFrame, 2.5, 12)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = Icon .. " " .. WindowName
    Title.TextColor3 = Colors.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -45, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 75, 75)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = Header

    -- Container Tombol Scroll
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -50)
    ContentContainer.Position = UDim2.new(0, 10, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 3
    ContentContainer.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ContentContainer

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end)

    -- Logika Buka/Tutup
    local isOpened = false
    local function ToggleUI()
        isOpened = not isOpened
        MainFrame.Visible = isOpened
        OpenButton.Visible = not isOpened
    end

    OpenButton.MouseButton1Click:Connect(ToggleUI)
    CloseButton.MouseButton1Click:Connect(ToggleUI)

    local WindowElements = {}

    function WindowElements:AddButton(btnConfig)
        local BtnName = btnConfig.Name or "Button"
        local Callback = btnConfig.Callback or function() end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.BackgroundColor3 = Colors.ElementBg
        Button.Text = BtnName
        Button.TextColor3 = Colors.Text
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 14
        Button.Parent = ContentContainer
        addGradientStroke(Button, 1.5, 6)

        Button.MouseButton1Click:Connect(function()
            local ts = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
            ts:Play()
            ts.Completed:Wait()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Colors.ElementBg}):Play()
            
            Callback()
        end)
    end

    return WindowElements
end


---------------------------------------------------------
-- [3] EKSEKUSI DATA EMOTE KE DALAM UI LIBRARY
---------------------------------------------------------
local emotes = {
    {Name = "1. Jalan Snoop", Id = "110614921871084"},
    {Name = "2. Tertawa", Id = "122240620529815"},
    {Name = "3. Tubuh Berputar", Id = "104039491726272"},
    {Name = "4. Aneh", Id = "111020075303418"},
    {Name = "5. Goku's Warmup", Id = "108013663975520"},
    {Name = "6. Goku SSJ", Id = "73708713364616"},
    {Name = "7. Pose Anime Trend", Id = "111491675811633"}
}

-- Buat Window dari UI Library
local MyWindow = UILibrary:MakeWindow({
    Name = "EMOTE VOID VAINLY STAR",
    Icon = "👑"
})

-- Memasukkan seluruh tombol Emote satu per satu secara otomatis
for i, emote in ipairs(emotes) do
    MyWindow:AddButton({
        Name = emote.Name,
        Callback = function()
            -- Memanggil fungsi playEmote di atas
            playEmote(emote.Id)
        end
    })
end
