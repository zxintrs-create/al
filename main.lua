local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== FLAG SCRIPT =====
if _G.AutoWalkScriptLoaded then return end
_G.AutoWalkScriptLoaded = true

-- ===== DATA GLOBAL =====
_G.recordData = _G.recordData or {} -- simpan rekaman
_G.recording = false
_G.playing = false
_G.looping = false
_G.keyValid = _G.keyValid or false -- key sudah valid?

-- ===== KEY SYSTEM =====
local correctKey = "letmein" -- ganti dengan key yang kamu inginkan

local function showKeyPrompt(callback)
    local keyGUI = Instance.new("ScreenGui")
    keyGUI.Name = "KeyPrompt"
    keyGUI.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    frame.Parent = keyGUI

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 50)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = "Enter Key:"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 40)
    textBox.Position = UDim2.new(0, 10, 0, 60)
    textBox.PlaceholderText = "Key..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(0,0,0)
    textBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 18
    textBox.Parent = frame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0,100,0,30)
    submitBtn.Position = UDim2.new(0.5, -50, 1, -40)
    submitBtn.Text = "Submit"
    submitBtn.Font = Enum.Font.SourceSansBold
    submitBtn.TextSize = 18
    submitBtn.BackgroundColor3 = Color3.fromRGB(80,200,120)
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Parent = frame

    submitBtn.MouseButton1Click:Connect(function()
        if textBox.Text == correctKey then
            keyGUI:Destroy()
            _G.keyValid = true -- tandai key sudah valid
            callback(true)
        else
            textBox.Text = ""
            label.Text = "Wrong Key!"
        end
    end)
end

-- ===== FUNGSI KARAKTER =====
local character, humanoid, hrp
local function getChar()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end
getChar()

player.CharacterAdded:Connect(function()
    getChar()
    -- hanya minta key lagi jika belum valid
    if not _G.keyValid then
        showKeyPrompt(createGUI)
    else
        createGUI()
    end
end)

-- ===== FUNGSI GUI =====
function createGUI()
    if _G.AutoWalkGUI then
        _G.AutoWalkGUI:Destroy()
    end

    _G.AutoWalkGUI = Instance.new("ScreenGui")
    _G.AutoWalkGUI.Name = "AutoWalkGUI"
    _G.AutoWalkGUI.Parent = player:WaitForChild("PlayerGui")
    _G.AutoWalkGUI.Enabled = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 200)
    mainFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = _G.AutoWalkGUI

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(200,50,50)
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-60,1,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "I CAN BROKE UR GAME"
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0,30,1,0)
    minimizeBtn.Position = UDim2.new(1,-60,0,0)
    minimizeBtn.Text = "_"
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.TextSize = 18
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minimizeBtn.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,1,0)
    closeBtn.Position = UDim2.new(1,-30,0,0)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Parent = titleBar

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-20,0,20)
    status.Position = UDim2.new(0,10,0,170)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(255,255,255)
    status.Text = "Idle"
    status.Parent = mainFrame

    local buttons = {}

    local function makeButton(text,posY,callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,200,0,30)
        btn.Position = UDim2.new(0,10,0,posY)
        btn.BackgroundColor3 = Color3.fromRGB(80,120,200)
        btn.TextColor3 = Color3.fromRGB(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = text
        btn.Parent = mainFrame
        btn.MouseButton1Click:Connect(callback)
        table.insert(buttons,btn)
        return btn
    end

    -- ===== FUNGSI REKAMAN =====
    local conn
    local function startRecord()
        _G.recording = true
        _G.recordData = {}
        status.Text = "Recording..."
        local startTick = tick()
        conn = RunService.Heartbeat:Connect(function()
            if not hrp then return end
            table.insert(_G.recordData,{cf=hrp.CFrame,jump=humanoid.Jump,t=tick()-startTick})
        end)
    end

    local function stopRecord()
        _G.recording = false
        if conn then conn:Disconnect() end
        status.Text = "Recorded "..tostring(#_G.recordData).." steps"
    end

    local function playRecord()
        if #_G.recordData==0 or _G.playing then return end
        _G.playing=true
        status.Text="Playing..."
        local startTick=tick()
        for i,step in ipairs(_G.recordData) do
            if not _G.playing then break end
            local waitTime=(startTick+step.t)-tick()
            if waitTime>0 then task.wait(waitTime) end

            local targetPos=step.cf.Position
            local dist=(hrp.Position-targetPos).Magnitude
            if dist>15 then hrp.CFrame=step.cf else humanoid:MoveTo(targetPos) end
            if step.jump then humanoid.Jump=true end
        end
        _G.playing=false
        status.Text="Finished"
    end

    local function stopPlay()
        _G.playing=false
        _G.looping=false
        status.Text="Stopped"
    end

    local function loopRecord()
        if #_G.recordData==0 or _G.looping then return end
        _G.looping=true
        status.Text="Looping..."
        task.spawn(function()
            while _G.looping do
                playRecord()
                task.wait(0.1)
            end
        end)
    end

    local function stopLoop()
        _G.looping=false
        status.Text="Stopped Loop"
    end

    -- Tombol
    makeButton("Start Record",40,startRecord)
    makeButton("Stop Record",70,stopRecord)
    makeButton("Play",100,playRecord)
    makeButton("Stop Play",130,stopPlay)
    makeButton("Start Loop",160,loopRecord)
    makeButton("Stop Loop",190,stopLoop)

    -- Minimize
    local minimized=false
    minimizeBtn.MouseButton1Click:Connect(function()
        if minimized then
            for _,btn in pairs(buttons) do btn.Visible=true end
            mainFrame.Size=UDim2.new(0,220,0,200)
            minimized=false
        else
            for _,btn in pairs(buttons) do btn.Visible=false end
            mainFrame.Size=UDim2.new(0,220,0,30)
            minimized=true
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function() _G.AutoWalkGUI:Destroy() end)
end

-- Tampilkan key prompt hanya jika belum valid
if not _G.keyValid then
    showKeyPrompt(createGUI)
else
    createGUI()
end
