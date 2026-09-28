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
-- LOGIKA EMOTE DIRECT LOAD & CHECKER
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

local function playEmote(assetId, emoteName)
    -- Clean ID dari karakter non-angka (seperti tanda tanya ?)
    local cleanId = tostring(assetId):gsub("%D", "")
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Cek Rig Type (R6 vs R15)
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        warn("[VOID VAINLY STAR]: Karakter kamu adalah R6. Emote ini membutuhkan R15!")
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopCurrentEmote()

    task.spawn(function()
        -- Direct Animation Object Creation
        local animObject = Instance.new("Animation")
        animObject.AnimationId = "rbxassetid://" .. cleanId

        local success, track = pcall(function()
            return animator:LoadAnimation(animObject)
        end)

        if success and track then
            currentTrack = track
            currentTrack.Priority = Enum.AnimationPriority.Action4
            
            -- Test play
            local playSuccess = pcall(function()
                currentTrack:Play()
            end)

            if playSuccess then
                moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                    if humanoid.MoveDirection.Magnitude > 0 then stopCurrentEmote() end
                end)
                jumpConnection = humanoid.StateChanged:Connect(function(_, state)
                    if state == Enum.HumanoidStateType.Jumping then stopCurrentEmote() end
                end)
            else
                warn("[VOID VAINLY STAR]: ID " .. cleanId .. " diblokir oleh privasi game ini.")
            end
        else
            warn("[VOID VAINLY STAR]: Gagal memuat ID " .. cleanId .. " (" .. emoteName .. ")")
        end
    end)
end

---------------------------------------------------------
-- DESAIN GUI DELTA STYLE
---------------------------------------------------------
local GuiParent = getSafeGui()
if GuiParent:FindFirstChild("VoidVainlyStar_AldoVVS") then
    GuiParent.VoidVainlyStar_AldoVVS:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStar_AldoVVS"
ScreenGui.Parent = GuiParent
ScreenGui.ResetOnSpawn = false

local function applyBorderOnlyGradient(frameObject, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    stroke.Thickness = thickness or 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = frameObject

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
    })
    gradient.Parent = stroke
end

-- Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 48, 0, 48)
OpenButton.Position = UDim2.new(0, 15, 1, -65)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "👑"
OpenButton.TextSize = 22
OpenButton.TextStrokeTransparency = 1
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton
applyBorderOnlyGradient(OpenButton, 2.5)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 280)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame
applyBorderOnlyGradient(MainFrame, 2.5)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(0, 100, 1, 0)
MenuTitle.Position = UDim2.new(0, 15, 0, 0)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextSize = 15
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
MenuTitle.TextStrokeTransparency = 1
MenuTitle.Parent = Header

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, -160, 1, 0)
MainTitle.Position = UDim2.new(0, 100, 0, 0)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "👑VOID VAINLY STAR"
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 15
MainTitle.TextXAlignment = Enum.TextXAlignment.Center
MainTitle.TextStrokeTransparency = 1
MainTitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.TextStrokeTransparency = 1
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Lines
local H_Line = Instance.new("Frame")
H_Line.Size = UDim2.new(1, 0, 0, 3)
H_Line.Position = UDim2.new(0, 0, 0, 40)
H_Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
H_Line.BorderSizePixel = 0
H_Line.Parent = MainFrame

local H_Gradient = Instance.new("UIGradient")
H_Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128))
})
H_Gradient.Parent = H_Line

local V_Line = Instance.new("Frame")
V_Line.Size = UDim2.new(0, 3, 1, -43)
V_Line.Position = UDim2.new(0, 120, 0, 43)
V_Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
V_Line.BorderSizePixel = 0
V_Line.Parent = MainFrame

local V_Gradient = H_Gradient:Clone()
V_Gradient.Parent = V_Line

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -43)
Sidebar.Position = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local function createSidebarButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextStrokeTransparency = 1
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    applyBorderOnlyGradient(btn, 1.5)
    return btn
end

createSidebarButton("EMOTE", 15)
createSidebarButton("MAIN", 50)
createSidebarButton("CONTROL", 85)

-- Content
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -134, 1, -43)
ContentFrame.Position = UDim2.new(0, 134, 0, 43)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 3
ContentFrame.Parent = MainFrame

local TitleList = Instance.new("TextLabel")
TitleList.Size = UDim2.new(1, 0, 0, 25)
TitleList.Position = UDim2.new(0, 0, 0, 5)
TitleList.BackgroundTransparency = 1
TitleList.Text = "List Emote"
TitleList.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleList.Font = Enum.Font.GothamBold
TitleList.TextSize = 15
TitleList.TextXAlignment = Enum.TextXAlignment.Left
TitleList.TextStrokeTransparency = 1
TitleList.Parent = ContentFrame

local emotes = {
    {Name = "1. Emote jalan snoop", Id = "110614921871084"},
    {Name = "2. Tertawa", Id = "122240620529815"},
    {Name = "3. Tubuh berputar", Id = "104039491726272"},
    {Name = "4. Aneh", Id = "111020075303418"},
    {Name = "5. Goku's Warmup", Id = "108013663975520"},
    {Name = "6. Goku SSJ", Id = "73708713364616"},
    {Name = "7. POSE ANIME TREND", Id = "111491675811633"}
}

local yOffset = 35
for _, emote in ipairs(emotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 24)
    btn.Position = UDim2.new(0, 0, 0, yOffset)
    btn.BackgroundTransparency = 1
    btn.Text = emote.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextStrokeTransparency = 1
    btn.Parent = ContentFrame

    btn.MouseButton1Click:Connect(function()
        playEmote(emote.Id, emote.Name)
    end)
    
    yOffset = yOffset + 24
end

ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 15)

-- Footer
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(0, 100, 0, 20)
FooterLabel.Position = UDim2.new(1, -110, 1, -22)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "by AldoVVS"
FooterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.TextSize = 11
FooterLabel.TextXAlignment = Enum.TextXAlignment.Right
FooterLabel.TextStrokeTransparency = 1
FooterLabel.Parent = MainFrame

-- Toggle UI
local isVisible = false
local function ToggleUI()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
    OpenButton.Visible = not isVisible
end

OpenButton.MouseButton1Click:Connect(ToggleUI)
CloseButton.MouseButton1Click:Connect(ToggleUI)
