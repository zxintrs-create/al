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
-- LOGIKA EMOTE
---------------------------------------------------------
local currentEmoteTrack = nil
local moveConnection = nil
local jumpConnection = nil

local function stopCurrentEmote()
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end
    if moveConnection then moveConnection:Disconnect() moveConnection = nil end
    if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
end

local function playEmote(assetId, emoteName)
    local cleanId = tostring(assetId):gsub("%D", "")
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

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
        local animObject = nil
        
        local successObj, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. cleanId)
        end)

        if successObj and objects and #objects > 0 then
            for _, obj in ipairs(objects) do
                if obj:IsA("Animation") then
                    animObject = obj
                    break
                elseif obj:FindFirstChildOfClass("Animation") then
                    animObject = obj:FindFirstChildOfClass("Animation")
                    break
                end
            end
        end

        if not animObject then
            animObject = Instance.new("Animation")
            animObject.AnimationId = "rbxassetid://" .. cleanId
        end

        local successLoad, track = pcall(function()
            return animator:LoadAnimation(animObject)
        end)

        if successLoad and track then
            currentEmoteTrack = track
            currentEmoteTrack.Priority = Enum.AnimationPriority.Action4
            
            local playSuccess = pcall(function()
                currentEmoteTrack:Play()
            end)

            if playSuccess then
                moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                    if humanoid.MoveDirection.Magnitude > 0 then stopCurrentEmote() end
                end)
                jumpConnection = humanoid.StateChanged:Connect(function(_, state)
                    if state == Enum.HumanoidStateType.Jumping then stopCurrentEmote() end
                end)
            else
                warn("[VOID VAINLY STAR]: Emote " .. emoteName .. " diblokir oleh sistem game.")
            end
        else
            warn("[VOID VAINLY STAR]: Gagal memuat ID " .. cleanId .. " (" .. emoteName .. ")")
        end
    end)
end

---------------------------------------------------------
-- DESAIN GUI DELTA STYLE (KHUSUS EMOTE)
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
OpenButton.Active = true
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

-- Header Bar
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
MainTitle.Text = "👑 VOID VAINLY STAR"
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
CloseButton.Active = true
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Separator Lines
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

-- Sidebar (Hanya Menyisakan Tombol Emote)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -43)
Sidebar.Position = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local TabEmoteBtn = Instance.new("TextButton")
TabEmoteBtn.Size = UDim2.new(1, -20, 0, 32)
TabEmoteBtn.Position = UDim2.new(0, 10, 0, 15)
TabEmoteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabEmoteBtn.Text = "EMOTE"
TabEmoteBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
TabEmoteBtn.Font = Enum.Font.GothamBold
TabEmoteBtn.TextSize = 12
TabEmoteBtn.TextStrokeTransparency = 1
TabEmoteBtn.Active = true
TabEmoteBtn.Parent = Sidebar

local TabEmoteCorner = Instance.new("UICorner")
TabEmoteCorner.CornerRadius = UDim.new(0, 6)
TabEmoteCorner.Parent = TabEmoteBtn
applyBorderOnlyGradient(TabEmoteBtn, 1.5)

---------------------------------------------------------
-- HALAMAN EMOTE
---------------------------------------------------------
local EmotePage = Instance.new("Frame")
EmotePage.Size = UDim2.new(1, -130, 1, -70)
EmotePage.Position = UDim2.new(0, 130, 0, 43)
EmotePage.BackgroundTransparency = 1
EmotePage.Visible = true
EmotePage.Parent = MainFrame

local TitleEmote = Instance.new("TextLabel")
TitleEmote.Size = UDim2.new(1, -15, 0, 25)
TitleEmote.Position = UDim2.new(0, 0, 0, 5)
TitleEmote.BackgroundTransparency = 1
TitleEmote.Text = "List Emote"
TitleEmote.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleEmote.Font = Enum.Font.GothamBold
TitleEmote.TextSize = 15
TitleEmote.TextXAlignment = Enum.TextXAlignment.Left
TitleEmote.TextStrokeTransparency = 1
TitleEmote.Parent = EmotePage

local EmoteScroll = Instance.new("ScrollingFrame")
EmoteScroll.Size = UDim2.new(1, -15, 1, -35)
EmoteScroll.Position = UDim2.new(0, 0, 0, 32)
EmoteScroll.BackgroundTransparency = 1
EmoteScroll.ScrollBarThickness = 3
EmoteScroll.Parent = EmotePage

local EmoteLayout = Instance.new("UIListLayout")
EmoteLayout.Padding = UDim.new(0, 6)
EmoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
EmoteLayout.Parent = EmoteScroll

EmoteLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, EmoteLayout.AbsoluteContentSize.Y + 10)
end)

local emotes = {
    {Name = "1. Emote jalan snoop", Id = "110614921871084"},
    {Name = "2. Tertawa", Id = "122240620529815"},
    {Name = "3. Tubuh berputar", Id = "104039491726272"},
    {Name = "4. Aneh", Id = "111020075303418"},
    {Name = "5. Goku's Warmup", Id = "108013663975520"},
    {Name = "6. Goku SSJ", Id = "73708713364616"},
    {Name = "7. POSE ANIME TREND", Id = "111491675811633"},
    {Name = "8. aura mengambang", Id = "106708015414624"},
    {Name = "9. moon walk", Id = "111378664166805"},
    {Name = "10. Kemenangan = 24kGoldn", Id = "9178397781"},
    {Name = "11. LOLA NIMBUS", Id = "10147924028"}
}

for i, emote in ipairs(emotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "   " .. emote.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextStrokeTransparency = 1
    btn.Active = true
    btn.LayoutOrder = i
    btn.Parent = EmoteScroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    applyBorderOnlyGradient(btn, 1)

    btn.Activated:Connect(function()
        playEmote(emote.Id, emote.Name)
    end)
end

---------------------------------------------------------
-- FOOTER
---------------------------------------------------------
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(0, 120, 0, 20)
FooterLabel.Position = UDim2.new(1, -130, 1, -25)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "by AldoVVS"
FooterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.TextSize = 11
FooterLabel.TextXAlignment = Enum.TextXAlignment.Right
FooterLabel.TextStrokeTransparency = 1
FooterLabel.ZIndex = 10
FooterLabel.Parent = MainFrame

---------------------------------------------------------
-- TOGGLE UI
---------------------------------------------------------
local isVisible = false
local function ToggleUI()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
    OpenButton.Visible = not isVisible
end

OpenButton.Activated:Connect(ToggleUI)
CloseButton.Activated:Connect(ToggleUI)
