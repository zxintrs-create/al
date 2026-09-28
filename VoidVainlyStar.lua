-- [FORGE] ⚔️ Instant Kill & Auto Loot Script
-- Delta Executor Compatible
-- Teknik: RemoteEvent Flooding + Parameter Exploit

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Konfigurasi Utama
local Config = {
    Damage = 467000000000000000, -- Damage per hit (exploited value)
    AttackSpeed = 0.01, -- Delay antar serangan (detik)
    MaxTargets = 50, -- Target maksimum per scan
    KillRadius = 500, -- Radius deteksi NPC
    AutoLoot = true, -- Auto ambil loot
    AutoUpgrade = true, -- Auto upgrade senjata
    SpamRemote = true, -- Spam RemoteEvent untuk insta kill
    ShowUI = true, -- Tampilkan UI kontrol
}

-- Cache NPC
local npcCache = {}
local lastNPCScan = 0

-- Fungsi: Scan NPC di sekitar
local function scanNPCs()
    local now = tick()
    if now - lastNPCScan < 0.5 then return npcCache end
    lastNPCScan = now
    npcCache = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= character then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - rootPart.Position).Magnitude
                if dist <= Config.KillRadius then
                    table.insert(npcCache, {model = obj, hrp = hrp, humanoid = obj:FindFirstChild("Humanoid")})
                end
            end
        end
    end
    return npcCache
end

-- Fungsi: Spam RemoteEvent untuk insta kill
local function spamRemoteEvent()
    local remotes = {}

    -- Cari semua RemoteEvent di ReplicatedStorage dan workspace
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, obj)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, obj)
        end
    end

    -- Cari RemoteEvent dengan nama yang mirip serangan/combat
    local attackRemotes = {}
    for _, remote in ipairs(remotes) do
        local name = remote.Name:lower()
        if name:find("attack") or name:find("hit") or name:find("damage") or name:find("combat") or name:find("sword") or name:find("loot") or name:find("kill") or name:find("npc") then
            table.insert(attackRemotes, remote)
        end
    end

    -- Jika tidak ada remote yang cocok, spam semua RemoteEvent
    if #attackRemotes == 0 then attackRemotes = remotes end

    -- Spam setiap remote dengan parameter yang valid
    for _, remote in ipairs(attackRemotes) do
        pcall(function()
            -- Coba kirim parameter berdasarkan pola umum game forge
            remote:FireServer("Attack", character)
            remote:FireServer("Hit", character)
            remote:FireServer("Damage", Config.Damage)
            remote:FireServer("NPCDied", nil)
            remote:FireServer("Loot", nil)
            remote:FireServer() -- Fire tanpa parameter juga
        end)
    end
end

-- Fungsi: Insta kill NPC terdekat
local function instaKillNPC(npc)
    if npc and npc.humanoid then
        pcall(function()
            npc.humanoid.Health = 0
        end)
        pcall(function()
            npc:Destroy()
        end)
    end
end

-- Fungsi: Auto loot
local function autoLoot()
    if not Config.AutoLoot then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Value") then
            local value = obj:FindFirstChild("Value")
            if value and value:IsA("NumberValue") or value and value:IsA("IntValue") then
                pcall(function()
                    value.Value = value.Value + 999999
                end)
            end
        end
        -- Auto collect items di ground
        if obj:IsA("BasePart") and obj.Name:lower():find("loot") or obj.Name:lower():find("coin") or obj.Name:lower():find("gem") then
            pcall(function()
                obj.CFrame = rootPart.CFrame
            end)
        end
    end
end

-- Fungsi: Auto upgrade senjata
local function autoUpgrade()
    if not Config.AutoUpgrade then return end
    -- Cari GUI upgrade dan klik otomatis
    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local name = gui.Name:lower()
            if name:find("upgrade") or name:find("evolve") or name:find("forging") or name:find("enhance") then
                pcall(function()
                    gui.Parent.Parent:FindFirstChild("ClickDetector") or fireclickdetector(gui)
                end)
            end
        end
    end
end

-- Fungsi: Main loop
local function mainLoop()
    while task.wait(Config.AttackSpeed) do
        scanNPCs()

        -- Spam remote event untuk insta kill
        if Config.SpamRemote then
            spamRemoteEvent()
        end

        -- Kill NPC yang terdeteksi
        for i, npc in ipairs(npcCache) do
            if i <= Config.MaxTargets then
                instaKillNPC(npc)
            end
        end

        -- Auto loot
        autoLoot()

        -- Auto upgrade
        autoUpgrade()
    end
end

-- UI Kontrol
local function createUI()
    if not Config.ShowUI then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ForgeKillUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0, 10, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "⚔️ FORGE INSTA KILL"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: ACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local npcCountLabel = Instance.new("TextLabel")
    npcCountLabel.Name = "NPCCount"
    npcCountLabel.Size = UDim2.new(1, -10, 0, 20)
    npcCountLabel.Position = UDim2.new(0, 5, 0, 55)
    npcCountLabel.BackgroundTransparency = 1
    npcCountLabel.Text = "NPC: 0"
    npcCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    npcCountLabel.Font = Enum.Font.Gotham
    npcCountLabel.TextSize = 12
    npcCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    npcCountLabel.Parent = frame

    local dmgLabel = Instance.new("TextLabel")
    dmgLabel.Name = "Damage"
    dmgLabel.Size = UDim2.new(1, -10, 0, 20)
    dmgLabel.Position = UDim2.new(0, 5, 0, 75)
    dmgLabel.BackgroundTransparency = 1
    dmgLabel.Text = "Damage: " .. tostring(Config.Damage)
    dmgLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    dmgLabel.Font = Enum.Font.Gotham
    dmgLabel.TextSize = 12
    dmgLabel.TextXAlignment = Enum.TextXAlignment.Left
    dmgLabel.Parent = frame

    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.05, 0, 0, 105)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    toggleBtn.Text = "STOP/START"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.Parent = frame

    local running = true
    toggleBtn.MouseButton1Click:Connect(function()
        running = not running
        toggleBtn.Text = running and "STOP" or "START"
        toggleBtn.BackgroundColor3 = running and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(50, 180, 50)
    end)

    -- Speed slider label
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -10, 0, 20)
    speedLabel.Position = UDim2.new(0, 5, 0, 145)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. Config.AttackSpeed .. "s"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 11
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = frame

    -- Update UI setiap 0.5 detik
    task.spawn(function()
        while task.wait(0.5) do
            if not running then task.wait(0.1) continue end
            local npcs = scanNPCs()
            npcCountLabel.Text = "NPC: " .. #npcs
            dmgLabel.Text = "Damage: " .. tostring(Config.Damage)
        end
    end)

    -- Drag frame
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Start
createUI()
task.spawn(mainLoop)

print("[ALL FOR ONE")
