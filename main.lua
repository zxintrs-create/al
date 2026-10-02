-- LocalScript: AutoParryVoidVainlyStar (STABLE & ROCK SOLID)
-- FIX: KEMBALI KE FONDASI DASAR. DETEKSI BOLA AKURAT, TANPA MATEMATIKA RUMIT.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local success, vim = pcall(function() return game:GetService("VirtualInputManager") end)
local VirtualInputManager = success and vim or nil

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = Workspace.CurrentCamera

---
-- KONFIGURASI
local BASE_RADIUS = 8          -- Radius dasar (studs)
local SPEED_COMPENSATION = 0.05 -- Kompensasi kecepatan untuk 30 FPS / 80 Ping
local MAX_RADIUS = 16          -- Batas maksimal radius agar tidak false-positive

-- WARNA TEMA
local COLOR_CYAN = Color3.fromRGB(0, 240, 255)
local COLOR_PURPLE = Color3.fromRGB(170, 60, 255)
local COLOR_DEEP_MOON = Color3.fromRGB(18, 12, 35)
local PARRY_FLASH_COLOR = Color3.fromRGB(255, 80, 180)

-- STATE (DEFAULT OFF)
local isParryEnabled = false 
local isCameraEnabled = false
local visualAuraPart = nil
local cachedBall = nil
local parriedBalls = {} 

-- Kamera Defaults
local defaultMinZoom = 0.5
local defaultMaxZoom = 128
local defaultFOV = 70

---
-- HELPER FUNCTIONS
local function isAlive(obj) return obj and typeof(obj) == "Instance" and obj:IsDescendantOf(game) end
local function isBallInWorkspace(ball)
    if not isAlive(ball) then return false end
    local inWS = false
    pcall(function() inWS = ball:IsDescendantOf(Workspace) end)
    return inWS
end
local function safeGetPosition(part)
    if not isBallInWorkspace(part) then return nil end
    local pos; local s = pcall(function() pos = part.Position end)
    return s and pos or nil
end
local function getCameraBall()
    if isBallInWorkspace(cachedBall) then return cachedBall end
    return Workspace:FindFirstChild("Part")
end

---
-- 1. UI SETUP
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui"); screenGui.Name = "AutoParryControlGui"; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true
pcall(function() screenGui.Parent = playerGui end)

local openMenuBtn = Instance.new("TextButton"); openMenuBtn.Name = "OpenMenuAutoPerry"; openMenuBtn.AnchorPoint = Vector2.new(0.5, 0)
openMenuBtn.Size = UDim2.new(0, 160, 0, 36); openMenuBtn.Position = UDim2.new(0.5, 0, 0, 0)
openMenuBtn.BackgroundColor3 = COLOR_DEEP_MOON; openMenuBtn.TextColor3 = COLOR_CYAN; openMenuBtn.Text = "🌙 VOID MOON"
openMenuBtn.Font = Enum.Font.GothamBold; openMenuBtn.TextSize = 14; openMenuBtn.ZIndex = 5; openMenuBtn.Parent = screenGui
local openCorner = Instance.new("UICorner"); openCorner.CornerRadius = UDim.new(0, 8); openCorner.Parent = openMenuBtn
local openStroke = Instance.new("UIStroke"); openStroke.Color = COLOR_PURPLE; openStroke.Thickness = 1.5; openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; openStroke.Parent = openMenuBtn
local openGradient = Instance.new("UIGradient"); openGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 25, 50)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 15, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 70))}); openGradient.Parent = openMenuBtn
local openTextStroke = Instance.new("UIStroke"); openTextStroke.Color = Color3.fromRGB(0, 0, 0); openTextStroke.Thickness = 1.5; openTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; openTextStroke.Parent = openMenuBtn

local mainFrame = Instance.new("Frame"); mainFrame.Name = "MainFrameAutoPerry"; mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 250, 0, 260); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = COLOR_DEEP_MOON; mainFrame.Visible = false; mainFrame.Active = false; mainFrame.Draggable = false; mainFrame.ZIndex = 1; mainFrame.Parent = screenGui
local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 12); frameCorner.Parent = mainFrame
local frameStroke = Instance.new("UIStroke"); frameStroke.Color = COLOR_CYAN; frameStroke.Thickness = 1.5; frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; frameStroke.Parent = mainFrame
local frameGradient = Instance.new("UIGradient"); frameGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 15, 35)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 15, 65)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 30, 55))}); frameGradient.Rotation = 45; frameGradient.Parent = mainFrame

local titleLabel = Instance.new("TextLabel"); titleLabel.Size = UDim2.new(1, 0, 0, 36); titleLabel.Position = UDim2.new(0, 0, 0, 6)
titleLabel.BackgroundTransparency = 1; titleLabel.TextColor3 = COLOR_CYAN; titleLabel.Text = "🌙 VOID MOON STAR"
titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 16; titleLabel.ZIndex = 3; titleLabel.Parent = mainFrame
local titleTextStroke = Instance.new("UIStroke"); titleTextStroke.Color = Color3.fromRGB(0, 0, 0); titleTextStroke.Thickness = 2; titleTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; titleTextStroke.Parent = titleLabel

local statusLabel = Instance.new("TextLabel"); statusLabel.Size = UDim2.new(1, 0, 0, 25); statusLabel.Position = UDim2.new(0, 0, 0, 42)
statusLabel.BackgroundTransparency = 1; statusLabel.TextColor3 = Color3.fromRGB(255, 90, 140); statusLabel.Text = "Status: NONAKTIF"
statusLabel.Font = Enum.Font.GothamMedium; statusLabel.TextSize = 15; statusLabel.ZIndex = 3; statusLabel.Parent = mainFrame
local statusTextStroke = Instance.new("UIStroke"); statusTextStroke.Color = Color3.fromRGB(0, 0, 0); statusTextStroke.Thickness = 1.5; statusTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; statusTextStroke.Parent = statusLabel

local infoLabel = Instance.new("TextLabel"); infoLabel.Size = UDim2.new(1, 0, 0, 20); infoLabel.Position = UDim2.new(0, 0, 0, 70)
infoLabel.BackgroundTransparency = 1; infoLabel.TextColor3 = Color3.fromRGB(220, 220, 255); infoLabel.Text = "Stable Build | Safe Move | Hard Lock"
infoLabel.Font = Enum.Font.Gotham; infoLabel.TextSize = 11; infoLabel.ZIndex = 3; infoLabel.Parent = mainFrame
local infoTextStroke = Instance.new("UIStroke"); infoTextStroke.Color = Color3.fromRGB(0, 0, 0); infoTextStroke.Thickness = 1.2; infoTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; infoTextStroke.Parent = infoLabel

local toggleBtn = Instance.new("TextButton"); toggleBtn.Name = "ToggleButton"; toggleBtn.Size = UDim2.new(0.88, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.06, 0, 0, 100); toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); toggleBtn.Text = "AUTO PARRY: OFF"
toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 15; toggleBtn.ZIndex = 3; toggleBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 10); btnCorner.Parent = toggleBtn
local btnStroke = Instance.new("UIStroke"); btnStroke.Color = COLOR_PURPLE; btnStroke.Thickness = 1; btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; btnStroke.Parent = toggleBtn
local btnGradient = Instance.new("UIGradient"); btnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))}); btnGradient.Parent = toggleBtn
local toggleTextStroke = Instance.new("UIStroke"); toggleTextStroke.Color = Color3.fromRGB(0, 0, 0); toggleTextStroke.Thickness = 1.5; toggleTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; toggleTextStroke.Parent = toggleBtn

local camToggleBtn = Instance.new("TextButton"); camToggleBtn.Name = "CameraToggleButton"; camToggleBtn.Size = UDim2.new(0.88, 0, 0, 45)
camToggleBtn.Position = UDim2.new(0.06, 0, 0, 160); camToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
camToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); camToggleBtn.Text = "CAMERA TRACK: OFF"
camToggleBtn.Font = Enum.Font.GothamBold; camToggleBtn.TextSize = 15; camToggleBtn.ZIndex = 3; camToggleBtn.Parent = mainFrame
local camBtnCorner = Instance.new("UICorner"); camBtnCorner.CornerRadius = UDim.new(0, 10); camBtnCorner.Parent = camToggleBtn
local camBtnStroke = Instance.new("UIStroke"); camBtnStroke.Color = COLOR_PURPLE; camBtnStroke.Thickness = 1; camBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; camBtnStroke.Parent = camToggleBtn
local camBtnGradient = Instance.new("UIGradient"); camBtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 15, 15))}); camBtnGradient.Parent = camToggleBtn
local camToggleTextStroke = Instance.new("UIStroke"); camToggleTextStroke.Color = Color3.fromRGB(0, 0, 0); camToggleTextStroke.Thickness = 1.5; camToggleTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; camToggleTextStroke.Parent = camToggleBtn

---
-- 2. VISUAL AURA & STATE MANAGEMENT
local function destroyVisualAura() if isAlive(visualAuraPart) then pcall(function() visualAuraPart:Destroy() end) end; visualAuraPart = nil end
local function updateVisualAura()
    if not isParryEnabled then destroyVisualAura() return end
    local char = player.Character; if not isAlive(char) then destroyVisualAura() return end  
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not isAlive(hrp) then destroyVisualAura() return end  
    local diameter = BASE_RADIUS * 2 
    if not isAlive(visualAuraPart) then  
        pcall(function()  
            local sphere = Instance.new("Part"); sphere.Name = "ParryRangeAura"; sphere.Shape = Enum.PartType.Ball; sphere.Material = Enum.Material.ForceField  
            sphere.Color = COLOR_CYAN; sphere.Transparency = 0.5; sphere.CanCollide = false; sphere.CanQuery = false; sphere.CanTouch = false; sphere.CastShadow = false; sphere.Anchored = false  
            sphere.Size = Vector3.new(diameter, diameter, diameter)  
            local weld = Instance.new("WeldConstraint"); weld.Part0 = hrp; weld.Part1 = sphere; weld.Parent = sphere  
            sphere.CFrame = hrp.CFrame; sphere.Parent = char; visualAuraPart = sphere  
        end)  
    end
end

local function applyParryState()
    if isParryEnabled then
        toggleBtn.Text = "AUTO PARRY: ON"; toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
        btnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 240)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 40, 240))})
        statusLabel.Text = "Status: AKTIF (Stable Build)"; statusLabel.TextColor3 = COLOR_CYAN; updateVisualAura()
    else
        toggleBtn.Text = "AUTO PARRY: OFF"; toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
        btnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))})
        statusLabel.Text = "Status: NONAKTIF (Hard Lock)"; statusLabel.TextColor3 = Color3.fromRGB(255, 90, 140); destroyVisualAura()
        parriedBalls = {} -- Reset total saat OFF
    end
end

local function applyCameraState()
    if isCameraEnabled then
        local ball = getCameraBall(); if ball then camera.CameraSubject = ball end
        camera.CameraType = Enum.CameraType.Custom; camera.CameraMinZoomDistance = 10; camera.CameraMaxZoomDistance = 50; camera.FieldOfView = 70
        camToggleBtn.Text = "CAMERA TRACK: ON"; camToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        camBtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 180, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 90, 15))})
    else
        local char = player.Character; local hum = char and char:FindFirstChild("Humanoid"); if hum then camera.CameraSubject = hum end
        camera.CameraType = Enum.CameraType.Custom; camera.CameraMinZoomDistance = defaultMinZoom; camera.CameraMaxZoomDistance = defaultMaxZoom; camera.FieldOfView = defaultFOV
        camToggleBtn.Text = "CAMERA TRACK: OFF"; camToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        camBtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 15, 15))})
    end
end

openMenuBtn.MouseButton1Click:Connect(function() if isAlive(mainFrame) then mainFrame.Visible = not mainFrame.Visible end end)
toggleBtn.MouseButton1Click:Connect(function() if isParryEnabled then isParryEnabled = false else isParryEnabled = true end; applyParryState() end)
camToggleBtn.MouseButton1Click:Connect(function() if isCameraEnabled then isCameraEnabled = false else isCameraEnabled = true end; applyCameraState() end)

---
-- 3. DETEKSI BOLA YANG AKURAT (KEMBALI KE VERSI STABIL)
local function isBallPart(obj)
    if not isBallInWorkspace(obj) then return nil end
    local targetPart = nil  
    if obj:IsA("BasePart") then targetPart = obj  
    elseif obj:IsA("Model") then targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end  
    if not isBallInWorkspace(targetPart) then return nil end  
    
    -- Cek bentuk bola
    local isShapeBall = false  
    pcall(function() if targetPart:IsA("Part") and targetPart.Shape == Enum.PartType.Ball then isShapeBall = true end end)  
    if isShapeBall then return targetPart end  
    
    -- Cek nama (termasuk "Part" karena banyak game memakai nama ini)
    local nameLower = targetPart.Name:lower()  
    if nameLower == "ball" or nameLower:find("ball") or nameLower:find("blade") or nameLower:find("realball") or nameLower == "part" then return targetPart end  
    
    return nil
end

local function getWorkspaceBall()
    if isBallInWorkspace(cachedBall) then return cachedBall end
    cachedBall = nil  
    
    -- Cari di folder khusus dulu
    local ballsFolder = Workspace:FindFirstChild("Balls") or Workspace:FindFirstChild("BallFolder") or Workspace:FindFirstChild("Projectiles")
    if isAlive(ballsFolder) then  
        for _, child in ipairs(ballsFolder:GetChildren()) do  
            local valid = isBallPart(child)  
            if valid then 
                cachedBall = valid 
                if isCameraEnabled then camera.CameraSubject = valid end 
                return cachedBall 
            end  
        end  
    end  

    -- Fallback: Cari di Workspace
    for _, child in ipairs(Workspace:GetChildren()) do  
        if child:IsA("BasePart") or child:IsA("Model") then
            local valid = isBallPart(child)  
            if valid then 
                cachedBall = valid 
                if isCameraEnabled then camera.CameraSubject = valid end 
                return cachedBall 
            end  
        end  
    end  
    return nil
end

Workspace.DescendantAdded:Connect(function(descendant)
    if isBallInWorkspace(descendant) then
        local valid = isBallPart(descendant)
        if valid then cachedBall = valid; if isCameraEnabled then camera.CameraSubject = valid end end
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if cachedBall and (descendant == cachedBall or descendant == cachedBall.Parent or not isBallInWorkspace(cachedBall)) then cachedBall = nil end
    if parriedBalls[descendant] then parriedBalls[descendant] = nil end
end)

---
-- 4. FUNGSI EKSEKUSI (HARD LOCK)
local function fireGameParryRemotes()
    if not isParryEnabled then return end -- HARD LOCK
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Net")
        if remotes then
            local parryRemote = remotes:FindFirstChild("ParryButtonPress") or remotes:FindFirstChild("ParryAttempt") or remotes:FindFirstChild("Parry")
            if parryRemote and parryRemote:IsA("RemoteEvent") then parryRemote:FireServer() end
        end
    end)
end

local function clickGuiObject(btn)
    if not isAlive(btn) then return end
    if typeof(firesignal) == "function" then pcall(function() firesignal(btn.Activated) end); pcall(function() firesignal(btn.MouseButton1Click) end) end  
    if typeof(getconnections) == "function" then pcall(function() for _, c in ipairs(getconnections(btn.Activated)) do if c and c.Function then pcall(function() c:Fire() end) end end; for _, c in ipairs(getconnections(btn.MouseButton1Click)) do if c and c.Function then pcall(function() c:Fire() end) end end) end
    if VirtualInputManager then pcall(function() local p = btn.AbsolutePosition; local s = btn.AbsoluteSize; if p and s then local x = p.X + (s.X/2); local y = p.Y + (s.Y/2); VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, x, y); task.wait(0.0001); VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, x, y); VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game); task.wait(0.0001); VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game) end end) end
end

local function executeAutoClick()
    if not isParryEnabled then return end -- HARD LOCK
    if VirtualInputManager then pcall(function() VirtualInputManager:SendKeyEvent(Enum.KeyCode.F, true, false, game); task.wait(0.0001); VirtualInputManager:SendKeyEvent(Enum.KeyCode.F, false, false, game) end) end  
    local curPlayerGui = player:FindFirstChild("PlayerGui"); if isAlive(curPlayerGui) then local ib = curPlayerGui:FindFirstChild("INPUT_BUTTONS") or curPlayerGui:FindFirstChild("MobileUI"); if isAlive(ib) then local tf = ib:FindFirstChild("TouchFrame") or ib; local db = tf:FindFirstChild("Deflect_Button") or tf:FindFirstChild("ParryButton"); if isAlive(db) then clickGuiObject(db); local ibtn = db:FindFirstChild("Button") or db:FindFirstChildWhichIsA("GuiButton"); if ibtn then clickGuiObject(ibtn) end end end end
end

---
-- 5. MAIN LOOP (STABIL & AMAN)
player.CharacterAdded:Connect(function(newCharacter) character = newCharacter; humanoid = newCharacter:WaitForChild("Humanoid"); task.wait(0.2); applyParryState(); applyCameraState() end)

RunService.PreRender:Connect(function()
    local now = tick(); local slowTime = now * 1.5; local rotAngle = (now * 25) % 360; local sineWave = (math.sin(slowTime) + 1) / 2; local pulsedColor = COLOR_CYAN:Lerp(COLOR_PURPLE, sineWave)  
    if isAlive(frameGradient) then frameGradient.Rotation = rotAngle end; if isAlive(openGradient) then openGradient.Rotation = -rotAngle end; if isAlive(btnGradient) then btnGradient.Rotation = rotAngle end; if isAlive(camBtnGradient) then camBtnGradient.Rotation = rotAngle end 
    if isAlive(frameStroke) then frameStroke.Color = pulsedColor end; if isAlive(openStroke) then openStroke.Color = COLOR_PURPLE:Lerp(COLOR_CYAN, sineWave) end; if isAlive(btnStroke) then btnStroke.Color = pulsedColor end; if isAlive(camBtnStroke) then camBtnStroke.Color = pulsedColor end  
end)

RunService.Heartbeat:Connect(function()
    if not isParryEnabled then return end -- HARD LOCK UTAMA
    local char = player.Character; if not isAlive(char) then return end  
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not isAlive(hrp) then return end  
    if not isAlive(visualAuraPart) then updateVisualAura() end  
    
    local ball = getWorkspaceBall(); if not isBallInWorkspace(ball) then 
        if isAlive(visualAuraPart) then visualAuraPart.Color = COLOR_CYAN:Lerp(COLOR_PURPLE, (math.sin(tick() * 1.5) + 1) / 2) end
        return 
    end  
    
    local ballPos = safeGetPosition(ball); local hrpPos = safeGetPosition(hrp); if not ballPos or not hrpPos then return end  
    local distance = (ballPos - hrpPos).Magnitude  

    -- 🔥 RADIUS DINAMIS SEDERHANA (KOMPENSASI 30 FPS & PING) 🔥
    -- Jika bola cepat, radius membesar. Jika lambat, radius mengecil.
    local velMag = ball.AssemblyLinearVelocity.Magnitude
    local dynamicRadius = BASE_RADIUS + (velMag * SPEED_COMPENSATION)
    dynamicRadius = math.clamp(dynamicRadius, BASE_RADIUS, MAX_RADIUS)

    if distance <= dynamicRadius then  
        if not parriedBalls[ball] then
            parriedBalls[ball] = true
            if isAlive(visualAuraPart) then visualAuraPart.Color = PARRY_FLASH_COLOR end  
            
            task.spawn(function()
                if not isParryEnabled then return end -- CEK ULANG DI DALAM THREAD
                fireGameParryRemotes()
                executeAutoClick()
            end)
        end
    else
        if parriedBalls[ball] then parriedBalls[ball] = nil end
        if isAlive(visualAuraPart) then visualAuraPart.Color = COLOR_CYAN:Lerp(COLOR_PURPLE, (math.sin(tick() * 1.5) + 1) / 2) end
    end
end)

applyParryState()
applyCameraState()
