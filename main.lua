local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
ScreenGui.DisplayOrder = 10
ScreenGui.Parent = PlayerGui

-- 2. TITIK KLIK (O) - BISA DIGESER
local TargetPoint = Instance.new("TextButton")
TargetPoint.Name = "TargetPoint"
TargetPoint.Size = UDim2.new(0, 32, 0, 32)
TargetPoint.Position = UDim2.new(0.5, -16, 0.5, -16)
TargetPoint.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
TargetPoint.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPoint.Text = "O"
TargetPoint.Font = Enum.Font.SourceSansBold
TargetPoint.TextSize = 22
TargetPoint.Active = true
TargetPoint.Draggable = true
TargetPoint.ZIndex = 100
TargetPoint.Parent = ScreenGui

local UICornerTarget = Instance.new("UICorner")
UICornerTarget.CornerRadius = UDim.new(1, 0)
UICornerTarget.Parent = TargetPoint

-- 3. PANEL GUI UTAMA ("ALDO KNIGHTXOz HUB")
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 90
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Judul HUB
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "ALDO KNIGHTXOz HUB"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.ZIndex = 91
TitleLabel.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 8)
UICornerTitle.Parent = TitleLabel

-- Input Kecepatan
local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0.85, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.075, 0, 0.32, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Delay Klik (contoh: 0.1)"
SpeedInput.Text = "0.1"
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.ZIndex = 91
SpeedInput.Parent = MainFrame

-- Tombol Play / Off
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.85, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.075, 0, 0.62, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.ZIndex = 91
ToggleButton.Parent = ToggleButton

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 6)
UICornerBtn.Parent = ToggleButton
ToggleButton.Parent = MainFrame

-- 4. EFEK ANIMASI UIGRADIENT PRO
local function addGradientAnimation(parentGui)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),   -- Neon Cyan
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 50, 255)), -- Purple
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 255))    -- Neon Cyan
    })
    gradient.Parent = parentGui

    -- Rotasi terus menerus
    local rotationTween = TweenService:Create(
        gradient,
        TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        { Rotation = 360 }
    )
    rotationTween:Play()
end

-- Terapkan Efek Gradient ke Judul dan Frame Utama
addGradientAnimation(TitleLabel)

-- 5. LOGIKA AUTO CLICKER & POSISI PRESISI
local isClicking = false

local function startClicking()
    task.spawn(function()
        while isClicking do
            -- Mengatasi Offset Topbar agar posisi kursor pas di titik O
            local guiInset = GuiService:GetGuiInset()
            local absolutePos = TargetPoint.AbsolutePosition
            local absoluteSize = TargetPoint.AbsoluteSize
            
            local exactX = absolutePos.X + (absoluteSize.X / 2)
            local exactY = absolutePos.Y + (absoluteSize.Y / 2) + guiInset.Y

            -- Simulasi Klik Virtual
            VirtualInputManager:SendMouseButtonEvent(exactX, exactY, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(exactX, exactY, 0, false, game, 1)

            -- Membaca Delay Kecepatan
            local delayTime = tonumber(SpeedInput.Text) or 0.1
            task.wait(math.max(delayTime, 0.01))
        end
    end)
end

-- On/Off Toggle
ToggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        ToggleButton.Text = "STATUS: ON (PLAY)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 190, 80)
        startClicking()
    else
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)
