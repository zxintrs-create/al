local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CONFIG_FILE = "DeltaMobileConfig.json"
local defaultConfig = {JumpX = .85, JumpY = .75, JumpSize = .30, Sensitivity = 1, LowPerformance = false}
local OPEN_MENU_IMAGE = "rbxassetid://114480118578175"
local config = {}
for k, v in pairs(defaultConfig) do config[k] = v end

local function saveConfig()
    pcall(function()
        if writefile and type(writefile) == "function" then 
            writefile(CONFIG_FILE, HttpService:JSONEncode(config)) 
        end 
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and type(isfile) == "function" and type(readfile) == "function" and isfile(CONFIG_FILE) then 
            local success, d = pcall(function()
                return HttpService:JSONDecode(readfile(CONFIG_FILE))
            end)
            if success and type(d) == "table" then 
                for k, v in pairs(d) do 
                    if defaultConfig[k] ~= nil and type(v) == type(defaultConfig[k]) then 
                        config[k] = v 
                    end 
                end 
            end 
        end 
    end)
end
loadConfig()

if _G.DeltaMobileControlsCleanup then pcall(_G.DeltaMobileControlsCleanup) end
local connections = {}
local destroyed = false
local function connect(s, f) local c; pcall(function() c = s:Connect(f) end); if c then table.insert(connections, c) end; return c end
local function disconnectAll() for i = #connections, 1, -1 do pcall(function() connections[i]:Disconnect() end) end; table.clear(connections) end
local function destroyGui(n) local g = playerGui:FindFirstChild(n); if g then pcall(function() g:Destroy() end) end end
_G.DeltaMobileControlsCleanup = function() if destroyed then return end; destroyed = true; disconnectAll(); destroyGui("DeltaMobileErgo") end
destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

local gradientObjects = {}
local function registerGradient(g) if g and g:IsA("UIGradient") then gradientObjects[g] = true end end

local function premiumStroke(obj, thickness)
    local old = obj:FindFirstChild("PremiumStroke")
    if old then old:Destroy() end
    local stroke = Instance.new("UIStroke")
    stroke.Name = "PremiumStroke"
    stroke.Thickness = thickness or 2
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = obj
    local gradient = Instance.new("UIGradient")
    gradient.Name = "PremiumGradient"
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(.5, Color3.fromRGB(255, 220, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})
    gradient.Rotation = 0
    gradient.Parent = stroke
    registerGradient(gradient)
    return stroke, gradient
end
local function premium(obj, thickness) return premiumStroke(obj, thickness) end

local function applyJumpPremium(j)
    local overlay = j:FindFirstChild("PremiumJumpStroke")
    if not overlay then
        overlay = Instance.new("Frame")
        overlay.Name = "PremiumJumpStroke"
        overlay.BackgroundTransparency = 1
        overlay.BorderSizePixel = 0
        overlay.Active = false
        overlay.Selectable = false
        overlay.ZIndex = j.ZIndex + 2
        overlay.Parent = j
        local corner = Instance.new("UICorner")
        corner.Name = "Circle"
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = overlay
        local stroke = Instance.new("UIStroke")
        stroke.Name = "PremiumStroke"
        stroke.Thickness = 2.5
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Transparency = 0
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = overlay
        local gradient = Instance.new("UIGradient")
        gradient.Name = "PremiumGradient"
        gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(.5, Color3.fromRGB(255, 220, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})
        gradient.Rotation = 0
        gradient.Parent = stroke
        registerGradient(gradient)
    else
        overlay.Position = UDim2.fromScale(0, 0)
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.AnchorPoint = Vector2.zero
        overlay.Visible = j.Visible
        overlay.ZIndex = j.ZIndex + 2
    end
end

local touchGui
local jumpButton
local function getJump()
    touchGui = playerGui:FindFirstChild("TouchGui")
    if not touchGui then jumpButton = nil return nil end
    jumpButton = touchGui:FindFirstChild("JumpButton", true)
    if jumpButton and jumpButton:IsA("GuiObject") then
        applyJumpPremium(jumpButton)
        return jumpButton
    end
    jumpButton = nil
    return nil
end

local function updateJump()
    if destroyed then return end
    local j = getJump()
    local cam = workspace.CurrentCamera
    if not j or not cam then return end
    local vp = cam.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return end
    config.JumpX = math.clamp(config.JumpX, .05, .95)
    config.JumpY = math.clamp(config.JumpY, .05, .95)
    config.JumpSize = math.clamp(config.JumpSize, .05, .50)
    local size = math.max(40, math.floor(vp.Y * config.JumpSize))
    pcall(function()
        j.AnchorPoint = Vector2.new(.5, .5)
        j.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
        j.Size = UDim2.fromOffset(size, size)
        applyJumpPremium(j)
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaMobileErgo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = playerGui

local function makeButton(p, n, pos, size, text, bg, z)
    local b = Instance.new("TextButton")
    b.Name = n
    b.Position = pos
    b.Size = size
    b.Text = text
    b.BackgroundColor3 = bg or Color3.fromRGB(245, 245, 245)
    b.BackgroundTransparency = .05
    b.TextColor3 = Color3.fromRGB(20, 20, 20)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = false
    b.BorderSizePixel = 0
    b.ZIndex = z or 41
    b.Parent = p
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = b
    premium(b, 1.8)
    return b
end

local menu = Instance.new("ImageButton")
menu.Name = "OpenMenu"
menu.Position = UDim2.new(1, -72, 1, -72)
menu.Size = UDim2.fromOffset(60, 60)
menu.Image = OPEN_MENU_IMAGE
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menu.BackgroundTransparency = .05
menu.AutoButtonColor = false
menu.Active = true
menu.Selectable = false
menu.BorderSizePixel = 0
menu.ZIndex = 100
menu.Parent = gui
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1, 0)
menuCorner.Parent = menu
premium(menu, 2.5)

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(300, 460)
settings.Position = UDim2.new(.5, -150, .5, -230)
settings.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
settings.BackgroundTransparency = .03
settings.BorderSizePixel = 0
settings.Visible = false
settings.Active = false
settings.ZIndex = 40
settings.Parent = gui
local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 16)
settingsCorner.Parent = settings
premium(settings, 2.5)

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1, -20, 0, 130)
cameraSection.Position = UDim2.fromOffset(10, 10)
cameraSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
cameraSection.BorderSizePixel = 0
cameraSection.Active = false
cameraSection.ZIndex = 41
cameraSection.Parent = settings
local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0, 12)
cameraCorner.Parent = cameraSection
premium(cameraSection, 1.5)

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1, 0, 0, 35)
cameraTitle.Text = "CAMERA SENSI SETTING"
cameraTitle.TextColor3 = Color3.new(1, 1, 1)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 15
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1, 0, 0, 25)
sensLabel.Position = UDim2.fromOffset(0, 35)
sensLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 13
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
    sensLabel.Text = "Multiplier: " .. string.format("%.1f", config.Sensitivity) .. "x"
    pcall(function() UserSettings().GameSettings.MouseSensitivity = config.Sensitivity end)
end

local sensMinus = makeButton(cameraSection, "Minus", UDim2.new(.06, 0, 0, 70), UDim2.fromOffset(74, 38), "-", nil, 43)
local sensReset = makeButton(cameraSection, "Reset", UDim2.new(.5, -42, 0, 70), UDim2.fromOffset(84, 38), "RESET", nil, 43)
local sensPlus = makeButton(cameraSection, "Plus", UDim2.new(.94, -74, 0, 70), UDim2.fromOffset(74, 38), "+", nil, 43)
sensMinus.TextSize = 22
sensPlus.TextSize = 22
sensReset.TextSize = 13

connect(sensMinus.Activated, function() config.Sensitivity = math.clamp(config.Sensitivity - .1, .1, 10); applySensitivity() end)
connect(sensPlus.Activated, function() config.Sensitivity = math.clamp(config.Sensitivity + .1, .1, 10); applySensitivity() end)
connect(sensReset.Activated, function() config.Sensitivity = 1; applySensitivity() end)
applySensitivity()

local jumpPosSection = Instance.new("Frame")
jumpPosSection.Size = UDim2.new(1, -20, 0, 115)
jumpPosSection.Position = UDim2.fromOffset(10, 150)
jumpPosSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
jumpPosSection.BorderSizePixel = 0
jumpPosSection.Active = false
jumpPosSection.ZIndex = 41
jumpPosSection.Parent = settings
local jumpPosCorner = Instance.new("UICorner")
jumpPosCorner.CornerRadius = UDim.new(0, 12)
jumpPosCorner.Parent = jumpPosSection
premium(jumpPosSection, 1.5)

local jumpPosTitle = Instance.new("TextLabel")
jumpPosTitle.Size = UDim2.new(1, 0, 0, 32)
jumpPosTitle.Text = "JUMP BUTTON SIZE"
jumpPosTitle.TextColor3 = Color3.new(1, 1, 1)
jumpPosTitle.Font = Enum.Font.GothamBold
jumpPosTitle.TextSize = 15
jumpPosTitle.BackgroundTransparency = 1
jumpPosTitle.ZIndex = 42
jumpPosTitle.Parent = jumpPosSection

local sizePlus = makeButton(jumpPosSection, "SizePlus", UDim2.new(.06, 0, 0, 45), UDim2.fromOffset(86, 35), "SIZE +", nil, 43)
local sizeMinus = makeButton(jumpPosSection, "SizeMinus", UDim2.new(.94, -86, 0, 45), UDim2.fromOffset(86, 35), "SIZE -", nil, 43)
local center = makeButton(jumpPosSection, "Center", UDim2.new(.5, -43, 0, 45), UDim2.fromOffset(86, 35), "RESET", nil, 43)
sizePlus.TextSize = 12
sizeMinus.TextSize = 12
center.TextSize = 12

connect(sizePlus.Activated, function()
    config.JumpSize = math.clamp(config.JumpSize + .05, .05, .50)
    updateJump()
end)
connect(sizeMinus.Activated, function()
    config.JumpSize = math.clamp(config.JumpSize - .05, .05, .50)
    updateJump()
end)
connect(center.Activated, function()
    config.JumpX = defaultConfig.JumpX
    config.JumpY = defaultConfig.JumpY
    config.JumpSize = defaultConfig.JumpSize
    updateJump()
end)

local perfSection = Instance.new("Frame")
perfSection.Size = UDim2.new(1, -20, 0, 85)
perfSection.Position = UDim2.fromOffset(10, 275)
perfSection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
perfSection.BorderSizePixel = 0
perfSection.Active = false
perfSection.ZIndex = 41
perfSection.Parent = settings
local perfCorner = Instance.new("UICorner")
perfCorner.CornerRadius = UDim.new(0, 12)
perfCorner.Parent = perfSection
premium(perfSection, 1.5)

local perfTitle = Instance.new("TextLabel")
perfTitle.Size = UDim2.new(1, 0, 0, 30)
perfTitle.Text = "LOW PERFORMANCE MODE"
perfTitle.TextColor3 = Color3.new(1, 1, 1)
perfTitle.Font = Enum.Font.GothamBold
perfTitle.TextSize = 15
perfTitle.BackgroundTransparency = 1
perfTitle.ZIndex = 42
perfTitle.Parent = perfSection

local perfToggle = makeButton(perfSection, "PerfToggle", UDim2.new(.5, -80, 0, 38), UDim2.fromOffset(160, 35), "STATUS: OFF", Color3.fromRGB(150, 40, 40), 43)
perfToggle.TextColor3 = Color3.new(1, 1, 1)
perfToggle.TextSize = 12

-- Mode Performa Aman (Hanya mematikan Bayangan & Efek Lighting, TANPA menyentuh Karakter/Part)
local function applyLowPerf(state)
    config.LowPerformance = state
    if state then
        perfToggle.Text = "STATUS: ON"
        perfToggle.BackgroundColor3 = Color3.fromRGB(40, 150, 60)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled = false end
            end
        end)
    else
        perfToggle.Text = "STATUS: OFF"
        perfToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        pcall(function()
            Lighting.GlobalShadows = true
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled = true end
            end
        end)
    end
end

connect(perfToggle.Activated, function()
    applyLowPerf(not config.LowPerformance)
end)

if config.LowPerformance then
    applyLowPerf(true)
end

local saveButton = makeButton(settings, "SaveConfig", UDim2.new(.05, 0, 1, -48), UDim2.fromOffset(130, 36), "SAVE", Color3.fromRGB(45, 100, 55), 43)
saveButton.TextColor3 = Color3.new(1, 1, 1)
saveButton.TextSize = 13
local closeButton = makeButton(settings, "Close", UDim2.new(.95, -130, 1, -48), UDim2.fromOffset(130, 36), "CLOSE", Color3.fromRGB(100, 40, 40), 43)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 13

connect(saveButton.Activated, function()
    saveConfig()
    local old = saveButton.Text
    saveButton.Text = "SAVED!"
    task.delay(1, function() if saveButton and saveButton.Parent then saveButton.Text = old end end)
end)
connect(menu.Activated, function() settings.Visible = not settings.Visible end)
connect(closeButton.Activated, function() settings.Visible = false end)
connect(playerGui.ChildAdded, function(c)
    if c.Name == "TouchGui" then
        jumpButton = nil
        task.defer(updateJump)
        task.delay(.2, updateJump)
        task.delay(.5, updateJump)
    end
end)

local MUSIC_LIST = {
    {"DJ BE AS ONE","83435514857435"},
    {"DJ MISSING YOU","119116468910055"},
    {"DJ LET YOU GO WITH A SMILE","87543116048841"},
    {"DJ DRAMA MALAM MINGGU","139226256901949"},
    {"YOU HOLD MY HEART","106106801939821"},
    {"DJ STAY THE SAME BREAKBEAT","74088514222709"},
    {"DJ ALL OF ME IS YOURS BREAKBEAT","104593616947405"},
    {"DJ NO EXPIRATION DATE BREAKBEAT","88762074202384"},
    {"BODY PATA","127435546928911"},
    {"UNTOLD","138621627405792"}
}

local musicGui = Instance.new("Frame")
musicGui.Name = "MusicNodeList"
musicGui.Position = UDim2.fromOffset(12, 72)
musicGui.Size = UDim2.fromOffset(315, 410)
musicGui.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
musicGui.BackgroundTransparency = .03
musicGui.BorderSizePixel = 0
musicGui.Active = false
musicGui.Visible = false
musicGui.ZIndex = 200
musicGui.Parent = gui
local musicCorner = Instance.new("UICorner")
musicCorner.CornerRadius = UDim.new(0, 16)
musicCorner.Parent = musicGui
premium(musicGui, 2.5)

local musicTitle = Instance.new("TextLabel")
musicTitle.Position = UDim2.fromOffset(14, 8)
musicTitle.Size = UDim2.new(1, -28, 0, 26)
musicTitle.BackgroundTransparency = 1
musicTitle.Text = "MUSIC NODE LIST"
musicTitle.TextColor3 = Color3.new(1, 1, 1)
musicTitle.Font = Enum.Font.GothamBold
musicTitle.TextSize = 18
musicTitle.TextXAlignment = Enum.TextXAlignment.Left
musicTitle.ZIndex = 201
musicTitle.Parent = musicGui

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Position = UDim2.fromOffset(14, 38)
searchBox.Size = UDim2.new(1, -28, 0, 32)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Cari judul musik..."
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 150)
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 201
searchBox.Parent = musicGui
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = searchBox
premium(searchBox, 1.2)

local musicList = Instance.new("ScrollingFrame")
musicList.Name = "MusicList"
musicList.Position = UDim2.fromOffset(8, 76)
musicList.Size = UDim2.new(1, -16, 1, -84)
musicList.BackgroundTransparency = 1
musicList.BorderSizePixel = 0
musicList.ScrollBarThickness = 3
musicList.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 0)
musicList.CanvasSize = UDim2.new()
musicList.AutomaticCanvasSize = Enum.AutomaticSize.Y
musicList.ScrollingDirection = Enum.ScrollingDirection.Y
musicList.ZIndex = 201
musicList.Parent = musicGui

local musicLayout = Instance.new("UIListLayout")
musicLayout.Padding = UDim.new(0, 7)
musicLayout.SortOrder = Enum.SortOrder.LayoutOrder
musicLayout.Parent = musicList

local musicPadding = Instance.new("UIPadding")
musicPadding.PaddingTop = UDim.new(0, 2)
musicPadding.PaddingBottom = UDim.new(0, 8)
musicPadding.PaddingLeft = UDim.new(0, 2)
musicPadding.PaddingRight = UDim.new(0, 2)
musicPadding.Parent = musicList

local function copyMusicID(id)
    local ok = false
    pcall(function()
        if setclipboard then setclipboard(id); ok = true
        elseif toclipboard then toclipboard(id); ok = true
        elseif set_clipboard then set_clipboard(id); ok = true
        end
    end)
    return ok
end

local musicItemInstances = {}
local function createMusicItem(index, name, id)
    if destroyed then return end
    local item = Instance.new("Frame")
    item.Name = "Music_" .. index
    item.Size = UDim2.new(1, -4, 0, 70)
    item.BackgroundColor3 = Color3.fromRGB(27, 27, 40)
    item.BorderSizePixel = 0
    item.LayoutOrder = index
    item.Active = false
    item.ZIndex = 202
    item.Parent = musicList
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 11)
    c.Parent = item
    premium(item, 1.3)
    
    local nl = Instance.new("TextLabel")
    nl.Name = "NameLabel"
    nl.Position = UDim2.fromOffset(10, 7)
    nl.Size = UDim2.new(1, -105, 0, 24)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 11
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.TextTruncate = Enum.TextTruncate.AtEnd
    nl.ZIndex = 203
    nl.Parent = item
    
    local il = Instance.new("TextLabel")
    il.Position = UDim2.fromOffset(10, 34)
    il.Size = UDim2.new(1, -105, 0, 22)
    il.BackgroundTransparency = 1
    il.Text = id
    il.TextColor3 = Color3.fromRGB(175, 175, 195)
    il.Font = Enum.Font.Code
    il.TextSize = 11
    il.TextXAlignment = Enum.TextXAlignment.Left
    il.ZIndex = 203
    il.Parent = item
    
    local copy = Instance.new("TextButton")
    copy.Name = "Copy"
    copy.AnchorPoint = Vector2.new(1, .5)
    copy.Position = UDim2.new(1, -8, .5, 0)
    copy.Size = UDim2.fromOffset(78, 38)
    copy.BackgroundColor3 = Color3.fromRGB(100, 40, 170)
    copy.BorderSizePixel = 0
    copy.AutoButtonColor = false
    copy.Text = "COPY"
    copy.TextColor3 = Color3.new(1, 1, 1)
    copy.Font = Enum.Font.GothamBold
    copy.TextSize = 12
    copy.Active = true
    copy.Selectable = false
    copy.ZIndex = 204
    copy.Parent = item
    local cp = Instance.new("UICorner")
    cp.CornerRadius = UDim.new(0, 9)
    cp.Parent = copy
    premium(copy, 1.5)
    
    connect(copy.Activated, function()
        if destroyed then return end
        if copyMusicID(id) then
            copy.Text = "COPIED"
            copy.BackgroundColor3 = Color3.fromRGB(45, 170, 100)
        else
            copy.Text = "COPY ID"
            copy.BackgroundColor3 = Color3.fromRGB(190, 90, 50)
        end
        task.delay(1, function()
            if copy and copy.Parent then
                copy.Text = "COPY"
                copy.BackgroundColor3 = Color3.fromRGB(100, 40, 170)
            end
        end)
    end)
    
    table.insert(musicItemInstances, {Frame = item, Name = name:lower(), Id = id})
    return item
end

for i, d in ipairs(MUSIC_LIST) do createMusicItem(i, d[1], d[2]) end

connect(searchBox:GetPropertyChangedSignal("Text"), function()
    local query = searchBox.Text:lower()
    for _, v in ipairs(musicItemInstances) do
        if query == "" or v.Name:find(query) or v.Id:find(query) then
            v.Frame.Visible = true
        else
            v.Frame.Visible = false
        end
    end
end)

local openMusic = Instance.new("TextButton")
openMusic.Name = "OpenMusic"
openMusic.AnchorPoint = Vector2.new(1, 0)
openMusic.Position = UDim2.new(1, -80, 0, 82)
openMusic.Size = UDim2.fromOffset(58, 58)
openMusic.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
openMusic.BackgroundTransparency = .05
openMusic.BorderSizePixel = 0
openMusic.Text = "♫"
openMusic.TextColor3 = Color3.new(1, 1, 1)
openMusic.TextSize = 28
openMusic.Font = Enum.Font.GothamBold
openMusic.AutoButtonColor = false
openMusic.Active = true
openMusic.Selectable = false
openMusic.ZIndex = 300
openMusic.Parent = gui
local omc = Instance.new("UICorner")
omc.CornerRadius = UDim.new(1, 0)
omc.Parent = openMusic
premium(openMusic, 2.5)

connect(openMusic.Activated, function()
    musicGui.Visible = not musicGui.Visible
end)

connect(RunService.RenderStepped, function()
    if destroyed then return end
    for g in pairs(gradientObjects) do
        if g and g.Parent then
            g.Rotation = (g.Rotation + 1) % 360
        else
            gradientObjects[g] = nil
        end
    end
end)

connect(RunService.RenderStepped, function()
    if destroyed then return end
    local tg = playerGui:FindFirstChild("TouchGui")
    if tg then
        local j = tg:FindFirstChild("JumpButton", true)
        if j and j:IsA("GuiObject") then
            applyJumpPremium(j)
        end
    end
end)

local function refresh()
    task.defer(updateJump)
    task.delay(.2, function() if not destroyed then updateJump() end end)
    task.delay(.5, function() if not destroyed then updateJump() end end)
end

updateJump()
refresh()
