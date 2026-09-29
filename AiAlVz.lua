task.wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE = "DeltaMobileConfig.json"

local defaultConfig = {
    JumpX = 0.85,
    JumpY = 0.75,
    JumpSize = 65,
    ShiftX = 0.75,
    ShiftY = 0.65,
    ShiftSize = 35
}

local config = {}
for k, v in pairs(defaultConfig) do
    config[k] = v
end

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(config))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    if defaultConfig[k] ~= nil and type(v) == type(defaultConfig[k]) then
                        config[k] = v
                    end
                end
            end
        end
    end)
end

loadConfig()

if _G.VoidVainlyStarCleanup then
    pcall(_G.VoidVainlyStarCleanup)
end

local connections = {}
local gradientObjects = {}
local destroyed = false

local function connect(signal, callback)
    local c
    pcall(function()
        c = signal:Connect(callback)
    end)
    if c then
        table.insert(connections, c)
    end
    return c
end

local function disconnectAll()
    for i = #connections, 1, -1 do
        pcall(function()
            connections[i]:Disconnect()
        end)
    end
    table.clear(connections)
end

local function getSafeGui()
    if gethui then
        return gethui()
    end

    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if success and coreGui then
        return coreGui
    end

    return PlayerGui
end

_G.VoidVainlyStarCleanup = function()
    if destroyed then return end

    destroyed = true

    disconnectAll()

    local gui = PlayerGui:FindFirstChild("VoidVainlyStar_AldoVVS")

    if not gui and gethui then
        local hui = gethui()
        gui = hui and hui:FindFirstChild("VoidVainlyStar_AldoVVS")
    end

    if gui then
        pcall(function()
            gui:Destroy()
        end)
    end

    local ctrlGui = PlayerGui:FindFirstChild("DeltaMobileControls")

    if ctrlGui then
        pcall(function()
            ctrlGui:Destroy()
        end)
    end
end

local function destroyGui(name)
    local gui = PlayerGui:FindFirstChild(name)

    if gui then
        pcall(function()
            gui:Destroy()
        end)
    end
end

destroyGui("VoidVainlyStar_AldoVVS")
destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")
destroyGui("DeltaClickMarkerGui")

local PREMIUM_COLORS = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 229, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(147, 51, 234)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 229, 255))
})

local function addBorderOnlyGradient(obj, thickness)
    if not obj or not obj:IsA("GuiObject") then return end

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness or 2
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = obj

    local gradient = Instance.new("UIGradient")
    gradient.Color = PREMIUM_COLORS
    gradient.Rotation = 0
    gradient.Parent = stroke

    gradientObjects[gradient] = true
end

local function makeButton(parent, name, pos, size, text, bg, z)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = pos
    button.Size = size
    button.Text = text
    button.BackgroundColor3 = bg or Color3.fromRGB(18, 18, 22)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = false
    button.BorderSizePixel = 0
    button.ZIndex = z or 43
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    addBorderOnlyGradient(button, 1.5)

    return button
end

---------------------------------------------------------
-- LOGIKA EMOTE
---------------------------------------------------------

local currentEmoteTrack = nil
local moveConnection = nil
local jumpConnection = nil

local function stopCurrentEmote()
    if currentEmoteTrack then
        pcall(function()
            currentEmoteTrack:Stop()
            currentEmoteTrack:Destroy()
        end)
        currentEmoteTrack = nil
    end

    if moveConnection then
        pcall(function()
            moveConnection:Disconnect()
        end)
        moveConnection = nil
    end

    if jumpConnection then
        pcall(function()
            jumpConnection:Disconnect()
        end)
        jumpConnection = nil
    end
end

local function playEmote(assetId, emoteName)
    local cleanId = tostring(assetId):gsub("%D", "")

    if cleanId == "" then
        return
    end

    local character = LocalPlayer.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopCurrentEmote()

    local animObject = Instance.new("Animation")
    animObject.AnimationId = "rbxassetid://" .. cleanId

    local successLoad, track = pcall(function()
        return animator:LoadAnimation(animObject)
    end)

    if not successLoad or not track then
        pcall(function()
            animObject:Destroy()
        end)
        return
    end

    currentEmoteTrack = track
    currentEmoteTrack.Priority = Enum.AnimationPriority.Action4
    currentEmoteTrack.Looped = true

    local playSuccess = pcall(function()
        currentEmoteTrack:Play(0.1, 1, 1)
    end)

    if not playSuccess then
        stopCurrentEmote()
        return
    end

    moveConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if currentEmoteTrack and humanoid.MoveDirection.Magnitude > 0.05 then
            stopCurrentEmote()
        end
    end)

    jumpConnection = humanoid.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping
            or state == Enum.HumanoidStateType.Freefall
            or state == Enum.HumanoidStateType.Climbing then
            stopCurrentEmote()
        end
    end)

    task.spawn(function()
        local thisTrack = track

        task.wait(0.1)

        if currentEmoteTrack ~= thisTrack then
            pcall(function()
                animObject:Destroy()
            end)
            return
        end

        while currentEmoteTrack == thisTrack
            and thisTrack.Parent
            and not destroyed do
            task.wait(0.25)
        end

        pcall(function()
            animObject:Destroy()
        end)
    end)
end

---------------------------------------------------------
-- DESAIN GUI UTAMA
---------------------------------------------------------

local GuiParent = getSafeGui()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidVainlyStar_AldoVVS"
ScreenGui.Parent = GuiParent
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 48, 0, 48)
OpenButton.Position = UDim2.new(0, 15, 1, -65)
OpenButton.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
OpenButton.Text = "👑"
OpenButton.TextSize = 22
OpenButton.Active = true
OpenButton.Selectable = false
OpenButton.ZIndex = 100
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

addBorderOnlyGradient(OpenButton, 2.5)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 310)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

addBorderOnlyGradient(MainFrame, 2.5)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ZIndex = 51
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
MenuTitle.ZIndex = 52
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
MainTitle.ZIndex = 52
MainTitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Active = true
CloseButton.Selectable = false
CloseButton.ZIndex = 52
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local H_Line = Instance.new("Frame")
H_Line.Size = UDim2.new(1, 0, 0, 3)
H_Line.Position = UDim2.new(0, 0, 0, 40)
H_Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
H_Line.BorderSizePixel = 0
H_Line.ZIndex = 51
H_Line.Parent = MainFrame

local H_Gradient = Instance.new("UIGradient")
H_Gradient.Color = PREMIUM_COLORS
H_Gradient.Parent = H_Line

local V_Line = Instance.new("Frame")
V_Line.Size = UDim2.new(0, 3, 1, -43)
V_Line.Position = UDim2.new(0, 120, 0, 43)
V_Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
V_Line.BorderSizePixel = 0
V_Line.ZIndex = 51
V_Line.Parent = MainFrame

local V_Gradient = H_Gradient:Clone()
V_Gradient.Parent = V_Line

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -43)
Sidebar.Position = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundTransparency = 1
Sidebar.ZIndex = 51
Sidebar.Parent = MainFrame

local TabEmoteBtn = Instance.new("TextButton")
TabEmoteBtn.Size = UDim2.new(1, -20, 0, 32)
TabEmoteBtn.Position = UDim2.new(0, 10, 0, 15)
TabEmoteBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabEmoteBtn.Text = "EMOTE"
TabEmoteBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
TabEmoteBtn.Font = Enum.Font.GothamBold
TabEmoteBtn.TextSize = 12
TabEmoteBtn.AutoButtonColor = false
TabEmoteBtn.Active = true
TabEmoteBtn.Selectable = false
TabEmoteBtn.ZIndex = 52
TabEmoteBtn.Parent = Sidebar

local TabEmoteCorner = Instance.new("UICorner")
TabEmoteCorner.CornerRadius = UDim.new(0, 6)
TabEmoteCorner.Parent = TabEmoteBtn

addBorderOnlyGradient(TabEmoteBtn, 1.5)

local TabMainBtn = Instance.new("TextButton")
TabMainBtn.Size = UDim2.new(1, -20, 0, 32)
TabMainBtn.Position = UDim2.new(0, 10, 0, 55)
TabMainBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabMainBtn.Text = "MAIN"
TabMainBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TabMainBtn.Font = Enum.Font.GothamBold
TabMainBtn.TextSize = 12
TabMainBtn.AutoButtonColor = false
TabMainBtn.Active = true
TabMainBtn.Selectable = false
TabMainBtn.ZIndex = 52
TabMainBtn.Parent = Sidebar

local TabMainCorner = Instance.new("UICorner")
TabMainCorner.CornerRadius = UDim.new(0, 6)
TabMainCorner.Parent = TabMainBtn

addBorderOnlyGradient(TabMainBtn, 1.5)

---------------------------------------------------------
-- HALAMAN EMOTE
---------------------------------------------------------

local EmotePage = Instance.new("Frame")
EmotePage.Size = UDim2.new(1, -130, 1, -70)
EmotePage.Position = UDim2.new(0, 130, 0, 43)
EmotePage.BackgroundTransparency = 1
EmotePage.Visible = true
EmotePage.ZIndex = 51
EmotePage.Active = true
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
TitleEmote.ZIndex = 52
TitleEmote.Parent = EmotePage

local EmoteScroll = Instance.new("ScrollingFrame")
EmoteScroll.Size = UDim2.new(1, -15, 1, -35)
EmoteScroll.Position = UDim2.new(0, 0, 0, 32)
EmoteScroll.BackgroundTransparency = 1
EmoteScroll.BorderSizePixel = 0
EmoteScroll.ScrollBarThickness = 3
EmoteScroll.Active = true
EmoteScroll.ZIndex = 52
EmoteScroll.Parent = EmotePage

local EmoteLayout = Instance.new("UIListLayout")
EmoteLayout.Padding = UDim.new(0, 6)
EmoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
EmoteLayout.Parent = EmoteScroll

connect(EmoteLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    EmoteScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        EmoteLayout.AbsoluteContentSize.Y + 10
    )
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
    local btn = makeButton(
        EmoteScroll,
        "Emote_" .. i,
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, -10, 0, 32),
        "   " .. emote.Name,
        Color3.fromRGB(18, 18, 22),
        53
    )

    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i
    btn.Active = true
    btn.Selectable = false
    btn.AutoButtonColor = false

    local emoteId = emote.Id
    local emoteName = emote.Name

    connect(btn.InputBegan, function(input)
        if destroyed then return end

        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.Touch
            or inputType == Enum.UserInputType.MouseButton1 then

            btn.BackgroundColor3 = Color3.fromRGB(0, 229, 255)

            task.defer(function()
                if not destroyed and btn and btn.Parent then
                    playEmote(emoteId, emoteName)

                    task.delay(0.12, function()
                        if not destroyed and btn and btn.Parent then
                            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                        end
                    end)
                end
            end)
        end
    end)

    connect(btn.InputEnded, function(input)
        local inputType = input.UserInputType

        if inputType == Enum.UserInputType.Touch
            or inputType == Enum.UserInputType.MouseButton1 then

            if btn and btn.Parent then
                btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            end
        end
    end)
end

---------------------------------------------------------
-- HALAMAN MAIN
---------------------------------------------------------

local MainPage = Instance.new("ScrollingFrame")
MainPage.Size = UDim2.new(1, -130, 1, -55)
MainPage.Position = UDim2.new(0, 130, 0, 48)
MainPage.BackgroundTransparency = 1
MainPage.Visible = false
MainPage.ScrollBarThickness = 3
MainPage.Active = true
MainPage.ZIndex = 51
MainPage.CanvasSize = UDim2.fromOffset(0, 150)
MainPage.Parent = MainFrame

local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0, 8)
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Parent = MainPage

---------------------------------------------------------
-- CUSTOM CONTROLLER
---------------------------------------------------------

local CustomSection = Instance.new("Frame")
CustomSection.Name = "CustomSection"
CustomSection.Size = UDim2.new(1, -15, 0, 65)
CustomSection.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
CustomSection.BorderSizePixel = 0
CustomSection.LayoutOrder = 1
CustomSection.ZIndex = 52
CustomSection.Parent = MainPage

local CustomCorner = Instance.new("UICorner")
CustomCorner.CornerRadius = UDim.new(0, 8)
CustomCorner.Parent = CustomSection

addBorderOnlyGradient(CustomSection, 1.5)

local CustomTitle = Instance.new("TextLabel")
CustomTitle.Size = UDim2.new(1, 0, 0, 28)
CustomTitle.Text = "  CONTROLLER CUSTOM"
CustomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CustomTitle.Font = Enum.Font.GothamBold
CustomTitle.TextSize = 13
CustomTitle.TextXAlignment = Enum.TextXAlignment.Left
CustomTitle.BackgroundTransparency = 1
CustomTitle.ZIndex = 53
CustomTitle.Parent = CustomSection

local toggleCustom = makeButton(
    CustomSection,
    "ToggleCustom",
    UDim2.fromOffset(8, 30),
    UDim2.new(1, -16, 0, 32),
    "OFF",
    Color3.fromRGB(100, 40, 40),
    54
)

_G.ShiftLocked = false

local isCustomActive = false

local ctrlGui = Instance.new("ScreenGui")
ctrlGui.Name = "DeltaMobileControls"
ctrlGui.ResetOnSpawn = false
ctrlGui.IgnoreGuiInset = true
ctrlGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ctrlGui.DisplayOrder = 999999
ctrlGui.Enabled = false
ctrlGui.Parent = PlayerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.Position = UDim2.new(.5, -3, .5, -3)
crosshair.BackgroundColor3 = Color3.new(1, 1, 1)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = ctrlGui

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1, 0)
cc.Parent = crosshair

local btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(.5, .5)
btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
btnShiftLock.Image = "rbxassetid://6031068426"
btnShiftLock.ImageColor3 = Color3.new(1, 1, 1)
btnShiftLock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btnShiftLock.BackgroundTransparency = .2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = false
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = ctrlGui

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(1, 0)
sc.Parent = btnShiftLock

local ss = Instance.new("UIStroke")
ss.Thickness = 2
ss.Color = Color3.new(0, 0, 0)
ss.Transparency = .3
ss.Parent = btnShiftLock

local function toggleShiftLock()
    if destroyed or not isCustomActive then return end

    _G.ShiftLocked = not _G.ShiftLocked

    btnShiftLock.BackgroundColor3 =
        _G.ShiftLocked
        and Color3.fromRGB(147, 51, 234)
        or Color3.fromRGB(255, 255, 255)

    crosshair.Visible = _G.ShiftLocked

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.AutoRotate = not _G.ShiftLocked
        hum.CameraOffset = Vector3.zero
    end
end

connect(btnShiftLock.MouseButton1Click, toggleShiftLock)

local btnJump = Instance.new("TextButton")
btnJump.Name = "JumpButton"
btnJump.AnchorPoint = Vector2.new(.5, .5)
btnJump.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
btnJump.Size = UDim2.fromOffset(config.JumpSize, config.JumpSize)
btnJump.Text = "JUMP"
btnJump.TextColor3 = Color3.new(1, 1, 1)
btnJump.Font = Enum.Font.GothamBold
btnJump.TextSize = 14
btnJump.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
btnJump.BackgroundTransparency = 0.2
btnJump.AutoButtonColor = false
btnJump.Active = true
btnJump.Selectable = false
btnJump.BorderSizePixel = 0
btnJump.ZIndex = 100000
btnJump.Parent = ctrlGui

local jc = Instance.new("UICorner")
jc.CornerRadius = UDim.new(1, 0)
jc.Parent = btnJump

local js = Instance.new("UIStroke")
js.Thickness = 2
js.Color = Color3.new(0, 0, 0)
js.Transparency = 0.3
js.Parent = btnJump

connect(btnJump.MouseButton1Click, function()
    if destroyed or not isCustomActive then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.Jump = true
    end
end)

connect(btnJump.MouseButton1Down, function()
    if destroyed or not isCustomActive then return end
    btnJump.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
end)

connect(btnJump.MouseButton1Up, function()
    if destroyed or not isCustomActive then return end
    btnJump.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
end)

---------------------------------------------------------
-- JUMP SETTING
---------------------------------------------------------

local JumpSettingBtn = Instance.new("TextButton")
JumpSettingBtn.Name = "JumpSettingButton"
JumpSettingBtn.Size = UDim2.new(0, 36, 0, 36)
JumpSettingBtn.Position = UDim2.new(1, -55, 0, 15)
JumpSettingBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
JumpSettingBtn.Text = "⚙️"
JumpSettingBtn.TextSize = 18
JumpSettingBtn.Active = true
JumpSettingBtn.Selectable = false
JumpSettingBtn.ZIndex = 150000
JumpSettingBtn.Parent = ctrlGui

local JSBtnCorner = Instance.new("UICorner")
JSBtnCorner.CornerRadius = UDim.new(1, 0)
JSBtnCorner.Parent = JumpSettingBtn

addBorderOnlyGradient(JumpSettingBtn, 2)

local JumpSettingPanel = Instance.new("Frame")
JumpSettingPanel.Size = UDim2.new(0, 260, 0, 200)
JumpSettingPanel.AnchorPoint = Vector2.new(0.5, 0.5)
JumpSettingPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
JumpSettingPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
JumpSettingPanel.Visible = false
JumpSettingPanel.ZIndex = 200000
JumpSettingPanel.Parent = ctrlGui

local JSPCorner = Instance.new("UICorner")
JSPCorner.CornerRadius = UDim.new(0, 10)
JSPCorner.Parent = JumpSettingPanel

addBorderOnlyGradient(JumpSettingPanel, 2)

local JSPTitle = Instance.new("TextLabel")
JSPTitle.Size = UDim2.new(1, 0, 0, 35)
JSPTitle.BackgroundTransparency = 1
JSPTitle.Text = "⚙️ JUMP SETTING"
JSPTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
JSPTitle.Font = Enum.Font.GothamBold
JSPTitle.TextSize = 14
JSPTitle.ZIndex = 200001
JSPTitle.Parent = JumpSettingPanel

local JSPClose = Instance.new("TextButton")
JSPClose.Size = UDim2.new(0, 24, 0, 24)
JSPClose.Position = UDim2.new(1, -30, 0, 6)
JSPClose.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
JSPClose.Text = "X"
JSPClose.TextColor3 = Color3.fromRGB(255, 255, 255)
JSPClose.Font = Enum.Font.GothamBold
JSPClose.TextSize = 12
JSPClose.Active = true
JSPClose.Selectable = false
JSPClose.ZIndex = 200001
JSPClose.Parent = JumpSettingPanel

local JSPCloseCorner = Instance.new("UICorner")
JSPCloseCorner.CornerRadius = UDim.new(0, 4)
JSPCloseCorner.Parent = JSPClose

local function createSettingOption(name, posY, btnTextPlus, btnTextMinus, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 200001
    lbl.Parent = JumpSettingPanel

    local plusBtn = makeButton(
        JumpSettingPanel,
        name .. "Plus",
        UDim2.new(1, -55, 0, posY),
        UDim2.new(0, 45, 0, 25),
        btnTextPlus,
        nil,
        200001
    )

    local minusBtn = makeButton(
        JumpSettingPanel,
        name .. "Minus",
        UDim2.new(1, -105, 0, posY),
        UDim2.new(0, 45, 0, 25),
        btnTextMinus,
        nil,
        200001
    )

    connect(plusBtn.MouseButton1Click, function()
        callback(true)
    end)

    connect(minusBtn.MouseButton1Click, function()
        callback(false)
    end)
end

createSettingOption("Ukuran Jump", 45, "+5", "-5", function(isPlus)
    config.JumpSize = math.clamp(
        config.JumpSize + (isPlus and 5 or -5),
        40,
        120
    )

    btnJump.Size = UDim2.fromOffset(config.JumpSize, config.JumpSize)
    saveConfig()
end)

createSettingOption("Geser Kanan/Kiri", 85, "Kanan", "Kiri", function(isPlus)
    config.JumpX = math.clamp(
        config.JumpX + (isPlus and 0.02 or -0.02),
        0.5,
        0.98
    )

    btnJump.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
    saveConfig()
end)

createSettingOption("Geser Atas/Bawah", 125, "Bawah", "Atas", function(isPlus)
    config.JumpY = math.clamp(
        config.JumpY + (isPlus and 0.02 or -0.02),
        0.2,
        0.95
    )

    btnJump.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
    saveConfig()
end)

connect(JumpSettingBtn.MouseButton1Click, function()
    if destroyed or not isCustomActive then return end
    JumpSettingPanel.Visible = not JumpSettingPanel.Visible
end)

connect(JSPClose.MouseButton1Click, function()
    JumpSettingPanel.Visible = false
end)

---------------------------------------------------------
-- MOVEMENT FRAME
---------------------------------------------------------

local mainFrame = Instance.new("Frame")
mainFrame.Name = "ControlsFrame"
mainFrame.Size = UDim2.fromOffset(300, 300)
mainFrame.Position = UDim2.new(0, 18, 1, -330)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ctrlGui

local buttonDefaults = {}
local activeInputs = {}

local moveState = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    WLock = false
}

local function visual(button, pressed)
    if not button or not button.Parent then return end

    if pressed then
        button.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
    else
        button.BackgroundColor3 =
            buttonDefaults[button]
            or Color3.fromRGB(255, 255, 255)
    end
end

local function createMoveButton(name, pos, size, text)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = pos
    b.Size = size
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundTransparency = .15
    b.TextColor3 = Color3.fromRGB(20, 20, 20)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 28
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = false
    b.BorderSizePixel = 0
    b.ZIndex = 20
    b.Parent = mainFrame

    buttonDefaults[b] = b.BackgroundColor3

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = b

    return b
end

local btnUp = createMoveButton(
    "Up",
    UDim2.new(.33, 0, 0, 0),
    UDim2.new(.34, 0, .34, 0),
    "▲"
)

local btnDown = createMoveButton(
    "Down",
    UDim2.new(.33, 0, .66, 0),
    UDim2.new(.34, 0, .34, 0),
    "▼"
)

local btnLeft = createMoveButton(
    "Left",
    UDim2.new(0, 0, .33, 0),
    UDim2.new(.34, 0, .34, 0),
    "◀"
)

local btnRight = createMoveButton(
    "Right",
    UDim2.new(.66, 0, .33, 0),
    UDim2.new(.34, 0, .34, 0),
    "▶"
)

local btnWLock = Instance.new("TextButton")
btnWLock.Name = "WLock"
btnWLock.AnchorPoint = Vector2.new(.5, .5)
btnWLock.Position = UDim2.new(1, 42, .5, 0)
btnWLock.Size = UDim2.fromOffset(62, 62)
btnWLock.Text = "W"
btnWLock.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
btnWLock.BackgroundTransparency = .10
btnWLock.TextColor3 = Color3.new(1, 1, 1)
btnWLock.Font = Enum.Font.GothamBold
btnWLock.TextSize = 25
btnWLock.AutoButtonColor = false
btnWLock.Active = true
btnWLock.Selectable = false
btnWLock.BorderSizePixel = 0
btnWLock.ZIndex = 30
btnWLock.Parent = mainFrame

local wc = Instance.new("UICorner")
wc.CornerRadius = UDim.new(1, 0)
wc.Parent = btnWLock

connect(btnWLock.MouseButton1Click, function()
    if destroyed or not isCustomActive then return end

    moveState.WLock = not moveState.WLock

    btnWLock.BackgroundColor3 =
        moveState.WLock
        and Color3.fromRGB(0, 229, 255)
        or Color3.fromRGB(147, 51, 234)
end)

local function setDirection(direction, state)
    moveState[direction] = state

    if direction == "Forward" then
        visual(btnUp, state)
    elseif direction == "Backward" then
        visual(btnDown, state)
    elseif direction == "Left" then
        visual(btnLeft, state)
    elseif direction == "Right" then
        visual(btnRight, state)
    end
end

local function releaseInput(input)
    local data = activeInputs[input]

    if not data then return end

    activeInputs[input] = nil
    setDirection(data.direction, false)
end

local function bindDirection(button, direction)
    connect(button.InputBegan, function(input)
        if destroyed or not isCustomActive then return end

        local t = input.UserInputType

        if t ~= Enum.UserInputType.Touch
            and t ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if activeInputs[input] then return end

        activeInputs[input] = {
            direction = direction,
            button = button
        }

        setDirection(direction, true)
    end)

    connect(button.InputEnded, function(input)
        releaseInput(input)
    end)
end

bindDirection(btnUp, "Forward")
bindDirection(btnDown, "Backward")
bindDirection(btnLeft, "Left")
bindDirection(btnRight, "Right")

connect(UserInputService.InputEnded, function(input)
    releaseInput(input)
end)

connect(UserInputService.TouchEnded, function(input)
    releaseInput(input)
end)

connect(toggleCustom.MouseButton1Click, function()
    isCustomActive = not isCustomActive

    if isCustomActive then
        toggleCustom.Text = "ON"
        toggleCustom.BackgroundColor3 = Color3.fromRGB(45, 120, 80)
        ctrlGui.Enabled = true
    else
        toggleCustom.Text = "OFF"
        toggleCustom.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        ctrlGui.Enabled = false

        _G.ShiftLocked = false
        crosshair.Visible = false
        JumpSettingPanel.Visible = false

        for direction in pairs(moveState) do
            if direction ~= "WLock" then
                moveState[direction] = false
            end
        end

        moveState.WLock = false

        visual(btnUp, false)
        visual(btnDown, false)
        visual(btnLeft, false)
        visual(btnRight, false)

        btnWLock.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
    end
end)

---------------------------------------------------------
-- CAMERA / MOVEMENT UPDATER
---------------------------------------------------------

local cachedForward = Vector3.new(0, 0, -1)
local cachedSide = Vector3.new(1, 0, 0)

local function updateCameraVectors()
    local camera = workspace.CurrentCamera

    if not camera then return end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector

    local forward = Vector3.new(look.X, 0, look.Z)
    local side = Vector3.new(right.X, 0, right.Z)

    if forward.Magnitude > .001 then
        cachedForward = forward.Unit
    end

    if side.Magnitude > .001 then
        cachedSide = side.Unit
    end
end

local smoothX = 0
local smoothZ = 0

connect(RunService.RenderStepped, function()
    if destroyed or not isCustomActive then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not char or not hum or hum.Health <= 0 then
        return
    end

    updateCameraVectors()

    local x, z = 0, 0

    if moveState.Forward then z += 1 end
    if moveState.Backward then z -= 1 end
    if moveState.Left then x -= 1 end
    if moveState.Right then x += 1 end

    if x == 0 and z == 0 then
        if moveState.WLock then
            smoothX = 0
            smoothZ = 1
            hum:Move(cachedForward, false)
        else
            smoothX = 0
            smoothZ = 0
            hum:Move(Vector3.zero, false)
        end
    else
        local lerpSpeed = 0.95

        smoothX += (x - smoothX) * lerpSpeed
        smoothZ += (z - smoothZ) * lerpSpeed

        if math.abs(smoothX) < .005 then
            smoothX = 0
        end

        if math.abs(smoothZ) < .005 then
            smoothZ = 0
        end

        if smoothX ~= 0 or smoothZ ~= 0 then
            local movement = cachedSide * smoothX + cachedForward * smoothZ

            if movement.Magnitude >= .001 then
                hum:Move(movement.Unit, false)
            end
        end
    end

    if _G.ShiftLocked then
        local camera = workspace.CurrentCamera
        local root = char:FindFirstChild("HumanoidRootPart")

        if camera and root then
            local _, y = camera.CFrame:ToOrientation()
            root.CFrame =
                CFrame.new(root.Position)
                * CFrame.Angles(0, y, 0)
        end

        hum.AutoRotate = false
    else
        hum.AutoRotate = true
    end

    hum.CameraOffset = Vector3.zero
end)

---------------------------------------------------------
-- NAVIGASI TAB SIDEBAR
---------------------------------------------------------

connect(TabEmoteBtn.MouseButton1Click, function()
    if destroyed then return end

    EmotePage.Visible = true
    MainPage.Visible = false

    TabEmoteBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TabEmoteBtn.TextColor3 = Color3.fromRGB(0, 229, 255)

    TabMainBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    TabMainBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

connect(TabMainBtn.MouseButton1Click, function()
    if destroyed then return end

    EmotePage.Visible = false
    MainPage.Visible = true

    TabMainBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TabMainBtn.TextColor3 = Color3.fromRGB(0, 229, 255)

    TabEmoteBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    TabEmoteBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

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
FooterLabel.ZIndex = 60
FooterLabel.Parent = MainFrame

---------------------------------------------------------
-- TOGGLE UI UTAMA
---------------------------------------------------------

local isVisible = false

local function ToggleUI()
    isVisible = not isVisible

    MainFrame.Visible = isVisible
    OpenButton.Visible = not isVisible
end

connect(OpenButton.MouseButton1Click, ToggleUI)
connect(CloseButton.MouseButton1Click, ToggleUI)

---------------------------------------------------------
-- GRADIENT ANIMATION
---------------------------------------------------------

connect(RunService.RenderStepped, function()
    if destroyed then return end

    for gradient in pairs(gradientObjects) do
        if gradient and gradient.Parent then
            gradient.Rotation = (gradient.Rotation + 0.8) % 360
        else
            gradientObjects[gradient] = nil
        end
    end
end)
