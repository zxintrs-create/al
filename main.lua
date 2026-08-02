-- ====================================================================
-- SCRIPT NAME : ALDO KNIGHTXOz HUB - AUTO CLICKER SYSTEM
-- AUTHOR      : ALDO KNIGHTXOz
-- DESCRIPTION : Complete Local Auto Clicker with Draggable GUI & Precision 'O'
-- ====================================================================

-----------------------------------------------------------------------
-- SECTION 1: IMPORT SERVICES & PLAYER VARIABLES
-----------------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-----------------------------------------------------------------------
-- SECTION 2: CLEANUP EXISTING GUI
-----------------------------------------------------------------------
-- Membersihkan instance lama agar tidak terjadi duplikasi GUI di layar
if PlayerGui:FindFirstChild("AldoKnightXOzHub") then
    PlayerGui.AldoKnightXOzHub:Destroy()
end

-----------------------------------------------------------------------
-- SECTION 3: CREATE MAIN SCREENGUI CONTAINER
-----------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXOzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-----------------------------------------------------------------------
-- SECTION 4: CUSTOM DRAGGABLE SYSTEM (SMOOTH & ANTI-BUG)
-----------------------------------------------------------------------
-- System drag kustom agar GUI dan Titik O bisa digeser tanpa bentrok dengan Roblox
local function attachDraggableSystem(guiObject)
    local isDragging = false
    local dragInput = nil
    local dragStartPos = nil
    local startGuiPos = nil

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            startGuiPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
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
        if input == dragInput and isDragging then
            local deltaPosition = input.Position - dragStartPos
            guiObject.Position = UDim2.new(
                startGuiPos.X.Scale,
                startGuiPos.X.Offset + deltaPosition.X,
                startGuiPos.Y.Scale,
                startGuiPos.Y.Offset + deltaPosition.Y
            )
        end
    end)
end

-----------------------------------------------------------------------
-- SECTION 5: CREATE TARGET POINT BUTTON ("O")
-----------------------------------------------------------------------
local TargetPoint = Instance.new("TextButton")
TargetPoint.Name = "TargetPoint"
TargetPoint.Size = UDim2.new(0, 36, 0, 36)
TargetPoint.Position = UDim2.new(0.5, -18, 0.5, -18)
TargetPoint.BackgroundColor3 = Color3.fromRGB(235, 45, 45)
TargetPoint.BorderColor3 = Color3.fromRGB(255, 255, 255)
TargetPoint.BorderSizePixel = 1
TargetPoint.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPoint.Text = "O"
TargetPoint.Font = Enum.Font.SourceSansBold
TargetPoint.TextSize = 24
TargetPoint.Active = true
TargetPoint.AutoButtonColor = false
TargetPoint.ZIndex = 200
TargetPoint.Parent = ScreenGui

-- Rounded Circle Frame
local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetPoint

-- Stroke Effect untuk Titik O
local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 2
TargetStroke.Color = Color3.fromRGB(255, 255, 255)
TargetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TargetStroke.Parent = TargetPoint

-- Pasang sistem drag pada titik O
attachDraggableSystem(TargetPoint)

-----------------------------------------------------------------------
-- SECTION 6: CREATE MAIN PANEL FRAME ("ALDO KNIGHTXOz HUB")
-----------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 195)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Parent = MainFrame

-- Pasang sistem drag pada Panel Utama
attachDraggableSystem(MainFrame)

-----------------------------------------------------------------------
-- SECTION 7: CREATE TITLE BAR & HEADER
-----------------------------------------------------------------------
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
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

-----------------------------------------------------------------------
-- SECTION 8: CREATE CLOSE BUTTON (X)
-----------------------------------------------------------------------
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

-----------------------------------------------------------------------
-- SECTION 9: CREATE SPEED INPUT BOX
-----------------------------------------------------------------------
local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0.88, 0, 0, 36)
SpeedInput.Position = UDim2.new(0.06, 0, 0.32, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
SpeedInput.BorderColor3 = Color3.fromRGB(50, 50, 70)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
SpeedInput.PlaceholderText = "Delay Klik Detik (ex: 0.1)"
SpeedInput.Text = "0.1"
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.ZIndex = 12
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedInput

-----------------------------------------------------------------------
-- SECTION 10: CREATE PLAY/OFF TOGGLE BUTTON
-----------------------------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.88, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.06, 0, 0.64, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.ZIndex = 12
ToggleButton.Active = true
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

-----------------------------------------------------------------------
-- SECTION 11: UIGRADIENT PRO ANIMATION ENGINE
-----------------------------------------------------------------------
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 230, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 230, 255))
})
TitleGradient.Parent = TitleLabel

-- Loop Animasi Rotasi Gradient
local GradientTween = TweenService:Create(
    TitleGradient,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    { Rotation = 360 }
)
GradientTween:Play()

-----------------------------------------------------------------------
-- SECTION 12: AUTO CLICKER LOGIC & PRECISION SYSTEM
-----------------------------------------------------------------------
local isClicking = false

local function executePrecisionClick()
    task.spawn(function()
        while isClicking do
            -- Mengatasi offset topbar Roblox agar titik klik 100% pas di tengah 'O'
            local topbarInset = GuiService:GetGuiInset()
            local pointPosition = TargetPoint.AbsolutePosition
            local pointSize = TargetPoint.AbsoluteSize
            
            local calculateExactX = pointPosition.X + (pointSize.X / 2)
            local calculateExactY = pointPosition.Y + (pointSize.Y / 2) + topbarInset.Y

            -- Eksekusi Klik Mouse Virtual (Press & Release)
            VirtualInputManager:SendMouseButtonEvent(calculateExactX, calculateExactY, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(calculateExactX, calculateExactY, 0, false, game, 1)

            -- Membaca Delay Kecepatan dari TextBox
            local userDelay = tonumber(SpeedInput.Text) or 0.1
            task.wait(math.max(userDelay, 0.01))
        end
    end)
end

-----------------------------------------------------------------------
-- SECTION 13: EVENT LISTENERS & CONNECTIONS
-----------------------------------------------------------------------
-- Handler Tombol Status ON / OFF
ToggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        ToggleButton.Text = "STATUS: ON (PLAY)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 190, 80)
        executePrecisionClick()
    else
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

-- Handler Tombol Close (X)
CloseButton.MouseButton1Click:Connect(function()
    isClicking = false
    ScreenGui:Destroy()
end)

-- Finish Setup Notification
print("ALDO KNIGHTXOz HUB Loaded Successfully!")
