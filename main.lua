local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean GUI lama jika ada
if PlayerGui:FindFirstChild("AldoKnightXOzHub") then
    PlayerGui.AldoKnightXOzHub:Destroy()
end

-- 1. SCREEN GUI UTAMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXOzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

-- Sistem Drag Manual (Hanya untuk OpenMenu & Titik O)
local function makeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

---------------------------------------------------------
-- 2. TOMBOL OPEN MENU (🎭)
---------------------------------------------------------
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Name = "OpenMenuBtn"
OpenMenuBtn.Size = UDim2.new(0, 45, 0, 45)
OpenMenuBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
OpenMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenMenuBtn.Text = "🎭"
OpenMenuBtn.TextSize = 22
OpenMenuBtn.Active = true
OpenMenuBtn.ZIndex = 300
OpenMenuBtn.Parent = ScreenGui

local OpenMenuCorner = Instance.new("UICorner")
OpenMenuCorner.CornerRadius = UDim.new(0, 10)
OpenMenuCorner.Parent = OpenMenuBtn

makeDraggable(OpenMenuBtn)

---------------------------------------------------------
-- 3. TITIK KLIK (O)
---------------------------------------------------------
local TargetPoint = Instance.new("TextButton")
TargetPoint.Name = "TargetPoint"
TargetPoint.Size = UDim2.new(0, 36, 0, 36)
TargetPoint.Position = UDim2.new(0.5, -18, 0.5, -18)
TargetPoint.BackgroundColor3 = Color3.fromRGB(235, 45, 45)
TargetPoint.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPoint.Text = "O"
TargetPoint.Font = Enum.Font.SourceSansBold
TargetPoint.TextSize = 24
TargetPoint.Active = true
TargetPoint.Visible = false
TargetPoint.ZIndex = 200
TargetPoint.Parent = ScreenGui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetPoint

makeDraggable(TargetPoint)

---------------------------------------------------------
-- 4. PANEL GUI UTAMA
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Header / Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "ALDO KNIGHTXOz HUB"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.ZIndex = 11
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

-- Tombol Close (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -33, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(230, 45, 45)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 13
CloseButton.ZIndex = 15
CloseButton.Active = true
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Sub-Title
local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Name = "SubTitleLabel"
SubTitleLabel.Size = UDim2.new(1, 0, 0, 25)
SubTitleLabel.Position = UDim2.new(0, 0, 0, 45)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
SubTitleLabel.Text = "Auto clicker"
SubTitleLabel.Font = Enum.Font.GothamSemibold
SubTitleLabel.TextSize = 13
SubTitleLabel.ZIndex = 12
SubTitleLabel.Parent = MainFrame

-- Set Speed Box
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Name = "SpeedFrame"
SpeedFrame.Size = UDim2.new(0.88, 0, 0, 36)
SpeedFrame.Position = UDim2.new(0.06, 0, 0.40, 0)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
SpeedFrame.ZIndex = 12
SpeedFrame.Parent = MainFrame

local SpeedFrameCorner = Instance.new("UICorner")
SpeedFrameCorner.CornerRadius = UDim.new(0, 6)
SpeedFrameCorner.Parent = SpeedFrame

local SetLabel = Instance.new("TextLabel")
SetLabel.Name = "SetLabel"
SetLabel.Size = UDim2.new(0.3, 0, 1, 0)
SetLabel.Position = UDim2.new(0.05, 0, 0, 0)
SetLabel.BackgroundTransparency = 1
SetLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
SetLabel.Text = "Set"
SetLabel.Font = Enum.Font.Gotham
SetLabel.TextSize = 12
SetLabel.ZIndex = 13
SetLabel.TextXAlignment = Enum.TextXAlignment.Left
SetLabel.Parent = SpeedFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0.6, 0, 1, 0)
SpeedInput.Position = UDim2.new(0.35, 0, 0, 0)
SpeedInput.BackgroundTransparency = 1
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Text = "00.1"
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 13
SpeedInput.ZIndex = 13
SpeedInput.TextXAlignment = Enum.TextXAlignment.Right
SpeedInput.Parent = SpeedFrame

-- PLAY Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.88, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.06, 0, 0.68, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "PLAY"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.ZIndex = 12
ToggleButton.Active = true
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

---------------------------------------------------------
-- 5. ANIMASI GRADIENT
---------------------------------------------------------
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 255))
})
TitleGradient.Parent = TitleLabel

local GradientTween = TweenService:Create(
    TitleGradient,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Rotation = 360 }
)
GradientTween:Play()

---------------------------------------------------------
-- 6. LOGIKA & EVENT HANDLER (METODE FIX TOUCH & MOBILE)
---------------------------------------------------------
local isClicking = false

local function startAutoClicker()
    task.spawn(function()
        while isClicking do
            local topbarInset = GuiService:GetGuiInset()
            local pointPosition = TargetPoint.AbsolutePosition
            local pointSize = TargetPoint.AbsoluteSize
            
            local exactX = pointPosition.X + (pointSize.X / 2)
            local exactY = pointPosition.Y + (pointSize.Y / 2) + topbarInset.Y

            -- Menggunakan VirtualInputManager via TouchTap agar sistem Mobile tidak menganggapnya Mouse
            VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, Vector2.new(exactX, exactY))
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, Vector2.new(exactX, exactY))

            local userDelay = tonumber(SpeedInput.Text) or 0.1
            task.wait(math.max(userDelay, 0.01))
        end
    end)
end

-- Toggle Play / Stop
ToggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        ToggleButton.Text = "STOP"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 190, 80)
        startAutoClicker()
    else
        ToggleButton.Text = "PLAY"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- Open / Close Menu (🎭)
OpenMenuBtn.MouseButton1Click:Connect(function()
    local isVisible = not MainFrame.Visible
    MainFrame.Visible = isVisible
    TargetPoint.Visible = isVisible
end)

-- Tombol Close (X)
CloseButton.MouseButton1Click:Connect(function()
    isClicking = false
    ToggleButton.Text = "PLAY"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    
    MainFrame.Visible = false
    TargetPoint.Visible = false
end)
