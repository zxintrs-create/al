local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up GUI lama jika ada
if PlayerGui:FindFirstChild("AldoKnightXOzHub") then
    PlayerGui.AldoKnightXOzHub:Destroy()
end

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXOzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

---------------------------------------------------------
-- 1. TITIK KLIK (O) - BISA DIGESER
---------------------------------------------------------
local TargetPoint = Instance.new("TextButton")
TargetPoint.Name = "TargetPoint"
TargetPoint.Size = UDim2.new(0, 35, 0, 35)
TargetPoint.Position = UDim2.new(0.5, -17, 0.5, -17)
TargetPoint.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TargetPoint.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPoint.Text = "O"
TargetPoint.Font = Enum.Font.SourceSansBold
TargetPoint.TextSize = 22
TargetPoint.Active = true
TargetPoint.Draggable = true -- Bisa digeser ke mana saja
TargetPoint.Parent = ScreenGui

-- Corner Modifier
local UICornerTarget = Instance.new("UICorner")
UICornerTarget.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
UICornerTarget.Parent = TargetPoint

---------------------------------------------------------
-- 2. PANEL GUI UTAMA ("ALDO KNIGHTXOz HUB")
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Panel utama bisa digeser
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Title Hub
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
TitleLabel.Text = "ALDO KNIGHTXOz HUB"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 8)
UICornerTitle.Parent = TitleLabel

-- Input Kecepatan (Delay/Interval dalam detik)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0.8, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.1, 0, 0.3, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Delay Klik (contoh: 0.1)"
SpeedInput.Text = "0.1"
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.Parent = MainFrame

-- Tombol Play / Off
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.6, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 6)
UICornerBtn.Parent = ToggleButton

---------------------------------------------------------
-- 3. LOGIKA AUTO CLICKER
---------------------------------------------------------
local isClicking = false

local function startClicking()
    task.spawn(function()
        while isClicking do
            -- Mengambil posisi tengah dari titik 'O'
            local targetPos = TargetPoint.AbsolutePosition
            local targetSize = TargetPoint.AbsoluteSize
            local clickX = targetPos.X + (targetSize.X / 2)
            local clickY = targetPos.Y + (targetSize.Y / 2) + 36 -- Offset Gui Inset

            -- Eksekusi Klik Virtual tanpa menggeser kursor asli/layar
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

            -- Membaca delay dari input box
            local delayTime = tonumber(SpeedInput.Text) or 0.1
            task.wait(math.max(delayTime, 0.01))
        end
    end)
end

-- Toggle ON/OFF saat tombol diklik
ToggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        ToggleButton.Text = "STATUS: ON (PLAY)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        startClicking()
    else
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
