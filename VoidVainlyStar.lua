local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama jika script dieksekusi ulang
if CoreGui:FindFirstChild("VoidVainlyStarGUI") then
    CoreGui.VoidVainlyStarGUI:Destroy()
end

local emotes = {
    {Name = "1. Jalan Snoop", Id = "110614921871084"},
    {Name = "2. Tertawa", Id = "122240620529815"},
    {Name = "3. Tubuh Berputar", Id = "104039491726272"},
    {Name = "4. Aneh", Id = "111020075303418"},
    {Name = "5. Goku's Warmup", Id = "108013663975520"},
    {Name = "6. Goku SSJ", Id = "73708713364616"},
    {Name = "7. Pose Anime Trend", Id = "111491675811633"}
}

-- [1] PEMBUATAN UI UTAMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStarGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Tombol Open (Bulat, Pojok Kiri Bawah)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 1, -65)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenButton.Text = "👑"
OpenButton.TextSize = 22
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- Frame Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UISizeConstraint = Instance.new("UISizeConstraint")
UISizeConstraint.MaxSize = Vector2.new(400, 500)
UISizeConstraint.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Border Gradient (Cyan ke Ungu)
local function applyBorderGradient(parent)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Thickness = 2.5
    UIStroke.Parent = parent

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
    })
    UIGradient.Parent = UIStroke
end

applyBorderGradient(MainFrame)
applyBorderGradient(OpenButton)

-- Header / Label Judul Lengkap
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 EMOTE VOID VAINLY STAR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Tombol Close
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

-- Frame List Scroll
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- [2] LOGIKA ANIMASI & INTERUPSI
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

local function playEmote(animId)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopCurrentEmote()

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animId

    currentTrack = animator:LoadAnimation(animation)
    currentTrack.Priority = Enum.AnimationPriority.Action
    currentTrack:Play()

    moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            stopCurrentEmote()
        end
    end)

    jumpConnection = humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping then
            stopCurrentEmote()
        end
    end)
end

-- [3] LIST TOMBOL EMOTE
for i, emote in ipairs(emotes) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = emote.Name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    applyBorderGradient(Btn)

    Btn.MouseButton1Click:Connect(function()
        playEmote(emote.Id)
    end)
end

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

-- [4] TOGGLE UI
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)
