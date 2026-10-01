-- LocalScript: AutoParryVoidVainlyStar (PURE DISTANCE TRIGGER & ZERO COOLDOWN)
-- UPDATE: AREA ADALAH BATAS MUTLAK & HAPUS TOTAL COOLDOWN

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local success, vim = pcall(function() return game:GetService("VirtualInputManager") end)
local VirtualInputManager = success and vim or nil

local player = Players.LocalPlayer

---
-- PENGATURAN / CONFIGURATION
local BASE_PARRY_DISTANCE = 6      -- Radius jarak mutlak (studs). Area visual = batas trigger.

-- WARNA TEMA: LAZY CYAN & PURPLE MOON
local COLOR_CYAN = Color3.fromRGB(0, 240, 255)
local COLOR_PURPLE = Color3.fromRGB(170, 60, 255)
local COLOR_DEEP_MOON = Color3.fromRGB(18, 12, 35)
local PARRY_FLASH_COLOR = Color3.fromRGB(255, 80, 180)

-- STATE TUNGGAL
local isFeatureEnabled = false 
local visualAuraPart = nil
local cachedBall = nil

---
-- HELPER FUNCTIONS
local function isAlive(obj)
    return obj and typeof(obj) == "Instance" and obj:IsDescendantOf(game)
end

local function isBallInWorkspace(ball)
    if not isAlive(ball) then return false end
    local inWorkspace = false
    pcall(function() inWorkspace = ball:IsDescendantOf(Workspace) end)
    return inWorkspace
end

local function safeGetPosition(part)
    if not isBallInWorkspace(part) then return nil end
    local pos
    local successPos = pcall(function() pos = part.Position end)
    return successPos and pos or nil
end

---
-- 1. PEMBUATAN MENU UI
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoParryControlGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
pcall(function() screenGui.Parent = playerGui end)

-- Tombol Open Menu
local openMenuBtn = Instance.new("TextButton")
openMenuBtn.Name = "OpenMenuAutoPerry"
openMenuBtn.AnchorPoint = Vector2.new(0.5, 0)
openMenuBtn.Size = UDim2.new(0, 160, 0, 36)
openMenuBtn.Position = UDim2.new(0.5, 0, 0, 0)
openMenuBtn.BackgroundColor3 = COLOR_DEEP_MOON
openMenuBtn.TextColor3 = COLOR_CYAN
openMenuBtn.Text = "🌙 VOID MOON"
openMenuBtn.Font = Enum.Font.GothamBold
openMenuBtn.TextSize = 14
openMenuBtn.ZIndex = 5
openMenuBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openMenuBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = COLOR_PURPLE
openStroke.Thickness = 1.5
openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
openStroke.Parent = openMenuBtn

local openGradient = Instance.new("UIGradient")
openGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 25, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 15, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 70))
})
openGradient.Parent = openMenuBtn

local openTextStroke = Instance.new("UIStroke")
openTextStroke.Color = Color3.fromRGB(0, 0, 0)
openTextStroke.Thickness = 1.5
openTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
openTextStroke.Parent = openMenuBtn

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrameAutoPerry"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 250, 0, 210)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = COLOR_DEEP_MOON
mainFrame.Visible = false
mainFrame.Active = false
mainFrame.Draggable = false
mainFrame.ZIndex = 1
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = COLOR_CYAN
frameStroke.Thickness = 1.5
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = mainFrame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 15, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 15, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 30, 55))
})
frameGradient.Rotation = 45
frameGradient.Parent = mainFrame

-- Label Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.Position = UDim2.new(0, 0, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = COLOR_CYAN
titleLabel.Text = "🌙 VOID MOON STAR"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.ZIndex = 3
titleLabel.Parent = mainFrame

local titleTextStroke = Instance.new("UIStroke")
titleTextStroke.Color = Color3.fromRGB(0, 0, 0)
titleTextStroke.Thickness = 2
titleTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
titleTextStroke.Parent = titleLabel

-- Label Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 42)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 90, 140)
statusLabel.Text = "Status: NONAKTIF"
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 15
statusLabel.ZIndex = 3
statusLabel.Parent = mainFrame

local statusTextStroke = Instance.new("UIStroke")
statusTextStroke.Color = Color3.fromRGB(0, 0, 0)
statusTextStroke.Thickness = 1.5
statusTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
statusTextStroke.Parent = statusLabel

-- Label Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.Position = UDim2.new(0, 0, 0, 70)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
infoLabel.Text = "Pure Distance Trigger | 0 Cooldown"
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.ZIndex = 3
infoLabel.Parent = mainFrame

local infoTextStroke = Instance.new("UIStroke")
infoTextStroke.Color = Color3.fromRGB(0, 0, 0)
infoTextStroke.Thickness = 1.2
infoTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
infoTextStroke.Parent = infoLabel

-- Tombol Toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0.88, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.06, 0, 0.62, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "AUTO PARRY + CLICK: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
toggleBtn.ZIndex = 3
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = COLOR_PURPLE
btnStroke.Thickness = 1
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = toggleBtn

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))
})
btnGradient.Parent = toggleBtn

local toggleTextStroke = Instance.new("UIStroke")
toggleTextStroke.Color = Color3.fromRGB(0, 0, 0)
toggleTextStroke.Thickness = 1.5
toggleTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
toggleTextStroke.Parent = toggleBtn

---
-- 2. MANAGEMENT VISUAL AURA
local function destroyVisualAura()
    if isAlive(visualAuraPart) then
        pcall(function() visualAuraPart:Destroy() end)
    end
    visualAuraPart = nil
end

local function updateVisualAura()
    if not isFeatureEnabled then
        destroyVisualAura()
        return
    end

    local character = player.Character  
    if not isAlive(character) then destroyVisualAura() return end  

    local hrp = character:FindFirstChild("HumanoidRootPart")  
    if not isAlive(hrp) then destroyVisualAura() return end  

    local diameter = BASE_PARRY_DISTANCE * 2  

    if not isAlive(visualAuraPart) then  
        pcall(function()  
            local sphere = Instance.new("Part")  
            sphere.Name = "ParryRangeAura"  
            sphere.Shape = Enum.PartType.Ball  
            sphere.Material = Enum.Material.ForceField  
            sphere.Color = COLOR_CYAN  
            sphere.Transparency = 0.5  
            sphere.CanCollide = false  
            sphere.CanQuery = false  
            sphere.CanTouch = false  
            sphere.CastShadow = false  
            sphere.Anchored = false  
            sphere.Size = Vector3.new(diameter, diameter, diameter)  

            local weld = Instance.new("WeldConstraint")  
            weld.Part0 = hrp  
            weld.Part1 = sphere  
            weld.Parent = sphere  

            sphere.CFrame = hrp.CFrame  
            sphere.Parent = character  
            visualAuraPart = sphere  
        end)  
    end
end

---
-- EVENT INTERAKSI UI
openMenuBtn.MouseButton1Click:Connect(function()
    if isAlive(mainFrame) then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    isFeatureEnabled = not isFeatureEnabled

    if isFeatureEnabled then  
        btnGradient.Color = ColorSequence.new({  
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 240)),  
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 40, 240))  
        })  
        toggleBtn.Text = "AUTO PARRY + CLICK: ON"  
        statusLabel.Text = "Status: AKTIF (Pure Distance)"  
        statusLabel.TextColor3 = COLOR_CYAN  
        updateVisualAura()  
    else  
        btnGradient.Color = ColorSequence.new({  
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)),  
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))  
        })  
        toggleBtn.Text = "AUTO PARRY + CLICK: OFF"  
        statusLabel.Text = "Status: NONAKTIF"  
        statusLabel.TextColor3 = Color3.fromRGB(255, 90, 140)  
        destroyVisualAura()  
    end
end)

---
-- 3. DETEKSI BOLA
local function isBallPart(obj)
    if not isBallInWorkspace(obj) then return nil end

    local targetPart = nil  
    if obj:IsA("BasePart") then targetPart = obj  
    elseif obj:IsA("Model") then targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end  

    if not isBallInWorkspace(targetPart) then return nil end  

    local isShapeBall = false  
    pcall(function() if targetPart:IsA("Part") and targetPart.Shape == Enum.PartType.Ball then isShapeBall = true end end)  
    if isShapeBall then return targetPart end  

    local nameLower = obj.Name:lower()  
    if nameLower == "ball" or nameLower:find("ball") or nameLower:find("blade") or nameLower:find("realball") then return targetPart end  

    return nil
end

local function getWorkspaceBall()
    if isBallInWorkspace(cachedBall) then return cachedBall end
    cachedBall = nil  

    local ballsFolder = Workspace:FindFirstChild("Balls") or Workspace:FindFirstChild("BallFolder")  
    if isAlive(ballsFolder) then  
        for _, child in ipairs(ballsFolder:GetChildren()) do  
            local valid = isBallPart(child)  
            if valid and child:GetAttribute("realBall") ~= false then cachedBall = valid return cachedBall end  
        end  
    end  

    for _, child in ipairs(Workspace:GetChildren()) do  
        if isAlive(child) and child ~= Workspace.CurrentCamera and not child:IsA("Accessory") then  
            local valid = isBallPart(child)  
            if valid then cachedBall = valid return cachedBall end  
        end  
    end  

    return nil
end

local function isBallTargetingMe(ball)
    if not isBallInWorkspace(ball) or not isAlive(player.Character) then return false end

    local targetAttr = ball:GetAttribute("Target") or ball:GetAttribute("target")  
    if targetAttr then  
        if targetAttr == player.Name or targetAttr == player.Character.Name or targetAttr == player.Character then return true end  
    end  

    local targetVal = ball:FindFirstChild("Target") or ball:FindFirstChild("target")  
    if targetVal then  
        if targetVal:IsA("ObjectValue") and targetVal.Value == player.Character then return true end  
        if targetVal:IsA("StringValue") and (targetVal.Value == player.Name or targetVal.Value == player.Character.Name) then return true end  
    end  

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")  
    if isAlive(hrp) then  
        local vel = ball.AssemblyLinearVelocity  
        if vel.Magnitude > 2 then  
            local dirToPlayer = (hrp.Position - ball.Position).Unit  
            local ballDir = vel.Unit  
            if ballDir:Dot(dirToPlayer) > 0.55 then return true end  
        end  
    end  
    return false
end

Workspace.DescendantAdded:Connect(function(descendant)
    if isBallInWorkspace(descendant) then
        local valid = isBallPart(descendant)
        if valid then cachedBall = valid end
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if cachedBall and (descendant == cachedBall or descendant == cachedBall.Parent or not isBallInWorkspace(cachedBall)) then
        cachedBall = nil
    end
end)

---
-- 4. FUNGSI EKSEKUSI (NO COOLDOWN)
local function fireGameParryRemotes()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Net")
        if remotes then
            local parryRemote = remotes:FindFirstChild("ParryButtonPress")
                or remotes:FindFirstChild("ParryAttempt")
                or remotes:FindFirstChild("Parry")
            if parryRemote and parryRemote:IsA("RemoteEvent") then
                parryRemote:FireServer()
            end
        end
    end)
end

local function clickGuiObject(btn)
    if not isAlive(btn) then return end
    if typeof(firesignal) == "function" then  
        pcall(function() firesignal(btn.Activated) end)  
        pcall(function() firesignal(btn.MouseButton1Click) end)  
    end  
    if typeof(getconnections) == "function" then  
        pcall(function()  
            for _, connection in ipairs(getconnections(btn.Activated)) do  
                if connection and connection.Function then pcall(function() connection:Fire() end) end  
            end  
        end)  
    end
end

local function executeAutoClick()
    if VirtualInputManager then  
        pcall(function()  
            VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.F, true, game)  
            VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.F, false, game)  
        end)  
    end  

    local curPlayerGui = player:FindFirstChild("PlayerGui")  
    if isAlive(curPlayerGui) then  
        local inputButtons = curPlayerGui:FindFirstChild("INPUT_BUTTONS") or curPlayerGui:FindFirstChild("MobileUI")  
        if isAlive(inputButtons) then  
            local touchFrame = inputButtons:FindFirstChild("TouchFrame") or inputButtons  
            local deflectBtn = touchFrame:FindFirstChild("Deflect_Button") or touchFrame:FindFirstChild("ParryButton")  
            if isAlive(deflectBtn) then  
                clickGuiObject(deflectBtn)  
                local innerBtn = deflectBtn:FindFirstChild("Button") or deflectBtn:FindFirstChildWhichIsA("GuiButton")  
                if innerBtn then clickGuiObject(innerBtn) end  
            end  
        end  
    end
end

---
-- 5. MAIN LOOP (PURE DISTANCE & ZERO COOLDOWN)
player.CharacterAdded:Connect(function()
    task.wait(0.2)
    if isFeatureEnabled then updateVisualAura() end
end)

RunService.PreRender:Connect(function()
    local now = tick()

    -- ANIMASI TEMA UI
    local slowTime = now * 1.5  
    local rotAngle = (now * 25) % 360  
    local sineWave = (math.sin(slowTime) + 1) / 2  
    local pulsedColor = COLOR_CYAN:Lerp(COLOR_PURPLE, sineWave)  

    if isAlive(frameGradient) then frameGradient.Rotation = rotAngle end  
    if isAlive(openGradient) then openGradient.Rotation = -rotAngle end  
    if isAlive(btnGradient) then btnGradient.Rotation = rotAngle end  
    if isAlive(frameStroke) then frameStroke.Color = pulsedColor end  
    if isAlive(openStroke) then openStroke.Color = COLOR_PURPLE:Lerp(COLOR_CYAN, sineWave) end  
    if isAlive(btnStroke) then btnStroke.Color = pulsedColor end  

    -- LOGIKA PARRY & CLICK
    if not isFeatureEnabled then return end  

    local character = player.Character  
    if not isAlive(character) then return end  

    local hrp = character:FindFirstChild("HumanoidRootPart")  
    if not isAlive(hrp) then return end  

    if not isAlive(visualAuraPart) then updateVisualAura() end  

    local ball = getWorkspaceBall()  
    if not isBallInWorkspace(ball) then return end  
    if not isBallTargetingMe(ball) then return end  

    local ballPos = safeGetPosition(ball)  
    local hrpPos = safeGetPosition(hrp)  
    if not ballPos or not hrpPos then return end  

    -- 🔥 HITUNG JARAK FISIK MURNI (TANPA PREDIKSI PING) 🔥
    local distance = (ballPos - hrpPos).Magnitude  

    -- 🔥 TRIGGER MURNI: HANYA AKTIF JIKA BOLA MENYENTUH/MASUK AREA 🔥
    if distance <= BASE_PARRY_DISTANCE then  
        
        -- Visual Flash (Warna aura berubah instan saat tersentuh)
        if isAlive(visualAuraPart) then  
            visualAuraPart.Color = PARRY_FLASH_COLOR  
        end  

        -- 🔥 EKSEKUSI LANGSUNG TANPA COOLDOWN SAMA SEKALI 🔥
        -- Dipanggil setiap frame (60+ kali/detik) selama bola ada di dalam area
        fireGameParryRemotes()
        executeAutoClick()
        
    else
        -- Kembalikan warna aura jika bola keluar area
        if isAlive(visualAuraPart) then
            visualAuraPart.Color = pulsedColor
        end
    end
end)
