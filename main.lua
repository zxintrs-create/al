-- LocalScript: AutoParryVoidVainlyStar (GAME-SPECIFIC BUILD)
-- DISESUAIKAN UNTUK: Bola="Part" di Workspace, UI=INPUT_BUTTONS>TouchFrame>Deflect_Button>Button
-- FITUR: Targeting Filter, Vector Prediction, Dynamic Hitbox, Clash Sync
-- TANPA AUTO-FACE | HARD LOCK ON/OFF | 30 FPS + 80ms Ping Optimized

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
-- KONFIGURASI SPESIFIK DEVICE (30 FPS + 80ms Ping)
local CONFIG = {
    BASE_RADIUS = 8,
    PING_SEC = 0.08,          -- 80ms dalam detik
    SAFETY_BUFFER = 3,
    MAX_RADIUS = 18,
    DOT_THRESHOLD = 0.15,     -- Rendah untuk 30 FPS (lebih forgiving)
    CLASH_DIST = 6,
    CLASH_PLAYER_DIST = 12,
    MAX_CPS = 22,             -- Aman dari anti-kick
    MIN_CLASH_CPS = 12,
    CPS_BOOST = 4,
}

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

-- CLASH STATE
local isClashSpamming = false
local lastBallVelocity = nil
local lastDeflectTime = 0
local detectedOpponentCPS = 12

-- Kamera Defaults
local defaultMinZoom = 0.5
local defaultMaxZoom = 128
local defaultFOV = 70

---
-- HELPER
local function isAlive(obj) return obj and typeof(obj) == "Instance" and obj:IsDescendantOf(game) end
local function isBallInWorkspace(ball)
    if not isAlive(ball) then return false end
    local inWS = false; pcall(function() inWS = ball:IsDescendantOf(Workspace) end)
    return inWS
end
local function safeGetPosition(part)
    if not isBallInWorkspace(part) then return nil end
    local pos; local s = pcall(function() pos = part.Position end)
    return s and pos or nil
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
local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0, 8); oc.Parent = openMenuBtn
local os_ = Instance.new("UIStroke"); os_.Color = COLOR_PURPLE; os_.Thickness = 1.5; os_.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; os_.Parent = openMenuBtn
local og = Instance.new("UIGradient"); og.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 25, 50)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 15, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 70))}); og.Parent = openMenuBtn
local ots = Instance.new("UIStroke"); ots.Color = Color3.fromRGB(0, 0, 0); ots.Thickness = 1.5; ots.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; ots.Parent = openMenuBtn

local mainFrame = Instance.new("Frame"); mainFrame.Name = "MainFrameAutoPerry"; mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0, 250, 0, 260); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = COLOR_DEEP_MOON; mainFrame.Visible = false; mainFrame.Active = false; mainFrame.Draggable = false; mainFrame.ZIndex = 1; mainFrame.Parent = screenGui
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 12); fc.Parent = mainFrame
local fs = Instance.new("UIStroke"); fs.Color = COLOR_CYAN; fs.Thickness = 1.5; fs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; fs.Parent = mainFrame
local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 15, 35)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 15, 65)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 30, 55))}); fg.Rotation = 45; fg.Parent = mainFrame

local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, 0, 0, 36); tl.Position = UDim2.new(0, 0, 0, 6)
tl.BackgroundTransparency = 1; tl.TextColor3 = COLOR_CYAN; tl.Text = "🌙 VOID MOON STAR"
tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.ZIndex = 3; tl.Parent = mainFrame
local tts = Instance.new("UIStroke"); tts.Color = Color3.fromRGB(0, 0, 0); tts.Thickness = 2; tts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; tts.Parent = tl

local sl = Instance.new("TextLabel"); sl.Size = UDim2.new(1, 0, 0, 25); sl.Position = UDim2.new(0, 0, 0, 42)
sl.BackgroundTransparency = 1; sl.TextColor3 = Color3.fromRGB(255, 90, 140); sl.Text = "Status: NONAKTIF"
sl.Font = Enum.Font.GothamMedium; sl.TextSize = 15; sl.ZIndex = 3; sl.Parent = mainFrame
local sts = Instance.new("UIStroke"); sts.Color = Color3.fromRGB(0, 0, 0); sts.Thickness = 1.5; sts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; sts.Parent = sl

local il = Instance.new("TextLabel"); il.Size = UDim2.new(1, 0, 0, 20); il.Position = UDim2.new(0, 0, 0, 70)
il.BackgroundTransparency = 1; il.TextColor3 = Color3.fromRGB(220, 220, 255); il.Text = "Vector Predict | Dynamic Hitbox | Clash"
il.Font = Enum.Font.Gotham; il.TextSize = 11; il.ZIndex = 3; il.Parent = mainFrame
local its = Instance.new("UIStroke"); its.Color = Color3.fromRGB(0, 0, 0); its.Thickness = 1.2; its.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; its.Parent = il

local tb = Instance.new("TextButton"); tb.Name = "ToggleButton"; tb.Size = UDim2.new(0.88, 0, 0, 45)
tb.Position = UDim2.new(0.06, 0, 0, 100); tb.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
tb.TextColor3 = Color3.fromRGB(255, 255, 255); tb.Text = "AUTO PARRY: OFF"
tb.Font = Enum.Font.GothamBold; tb.TextSize = 15; tb.ZIndex = 3; tb.Parent = mainFrame
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = tb
local bs = Instance.new("UIStroke"); bs.Color = COLOR_PURPLE; bs.Thickness = 1; bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; bs.Parent = tb
local bg = Instance.new("UIGradient"); bg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))}); bg.Parent = tb
local tbs_ = Instance.new("UIStroke"); tbs_.Color = Color3.fromRGB(0, 0, 0); tbs_.Thickness = 1.5; tbs_.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; tbs_.Parent = tb

local cb = Instance.new("TextButton"); cb.Name = "CameraToggleButton"; cb.Size = UDim2.new(0.88, 0, 0, 45)
cb.Position = UDim2.new(0.06, 0, 0, 160); cb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cb.TextColor3 = Color3.fromRGB(255, 255, 255); cb.Text = "CAMERA TRACK: OFF"
cb.Font = Enum.Font.GothamBold; cb.TextSize = 15; cb.ZIndex = 3; cb.Parent = mainFrame
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 10); cbc.Parent = cb
local cbs = Instance.new("UIStroke"); cbs.Color = COLOR_PURPLE; cbs.Thickness = 1; cbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; cbs.Parent = cb
local cbg = Instance.new("UIGradient"); cbg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 15, 15))}); cbg.Parent = cb
local cts = Instance.new("UIStroke"); cts.Color = Color3.fromRGB(0, 0, 0); cts.Thickness = 1.5; cts.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; cts.Parent = cb

---
-- 2. VISUAL AURA & STATE
local function destroyVisualAura() if isAlive(visualAuraPart) then pcall(function() visualAuraPart:Destroy() end) end; visualAuraPart = nil end
local function updateVisualAura()
    if not isParryEnabled then destroyVisualAura() return end
    local char = player.Character; if not isAlive(char) then destroyVisualAura() return end  
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not isAlive(hrp) then destroyVisualAura() return end  
    local diameter = CONFIG.BASE_RADIUS * 2 
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
        tb.Text = "AUTO PARRY: ON"; tb.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
        bg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 240)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 40, 240))})
        sl.Text = "Status: AKTIF (Advanced)"; sl.TextColor3 = COLOR_CYAN; updateVisualAura()
    else
        tb.Text = "AUTO PARRY: OFF"; tb.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
        bg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 30, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 15, 90))})
        sl.Text = "Status: NONAKTIF (Hard Lock)"; sl.TextColor3 = Color3.fromRGB(255, 90, 140); destroyVisualAura()
        parriedBalls = {}; isClashSpamming = false
    end
end

local function applyCameraState()
    if isCameraEnabled then
        if isBallInWorkspace(cachedBall) then camera.CameraSubject = cachedBall end
        camera.CameraType = Enum.CameraType.Custom; camera.CameraMinZoomDistance = 10; camera.CameraMaxZoomDistance = 50; camera.FieldOfView = 70
        cb.Text = "CAMERA TRACK: ON"; cb.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        cbg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 180, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 90, 15))})
    else
        local char = player.Character; local hum = char and char:FindFirstChild("Humanoid"); if hum then camera.CameraSubject = hum end
        camera.CameraType = Enum.CameraType.Custom; camera.CameraMinZoomDistance = defaultMinZoom; camera.CameraMaxZoomDistance = defaultMaxZoom; camera.FieldOfView = defaultFOV
        cb.Text = "CAMERA TRACK: OFF"; cb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        cbg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 15, 15))})
    end
end

openMenuBtn.MouseButton1Click:Connect(function() if isAlive(mainFrame) then mainFrame.Visible = not mainFrame.Visible end end)
tb.MouseButton1Click:Connect(function() if isParryEnabled then isParryEnabled = false else isParryEnabled = true end; applyParryState() end)
cb.MouseButton1Click:Connect(function() if isCameraEnabled then isCameraEnabled = false else isCameraEnabled = true end; applyCameraState() end)

---
-- 3. DETEKSI BOLA SPESIFIK GAME INI
-- Bola bernama "Part", tapi Baseplate juga Part. Filter: ukuran kecil + bukan Baseplate
local function isGameBall(obj)
    if not isAlive(obj) then return false end
    if not obj:IsA("BasePart") then return false end
    if obj.Name ~= "Part" then return false end
    -- Filter: Baseplate biasanya sangat besar (>50 studs). Bola game ini kecil (~2-4 studs)
    local size = obj.Size
    if size.X > 10 or size.Y > 10 or size.Z > 10 then return false end
    -- Filter tambahan: Baseplate biasanya Anchored=true dan CanCollide=true dengan warna abu-abu tertentu
    -- Bola game ini bisa bergerak (AssemblyLinearVelocity != 0 saat aktif) atau berada di posisi tertentu
    return true
end

local function getWorkspaceBall()
    if isBallInWorkspace(cachedBall) and isGameBall(cachedBall) then return cachedBall end
    cachedBall = nil  
    -- Cari di Workspace langsung (sesuai screenshot)
    for _, child in ipairs(Workspace:GetChildren()) do  
        if isGameBall(child) then 
            cachedBall = child 
            if isCameraEnabled then camera.CameraSubject = child end 
            return cachedBall 
        end  
    end  
    return nil
end

Workspace.DescendantAdded:Connect(function(descendant)
    if isGameBall(descendant) then 
        cachedBall = descendant 
        if isCameraEnabled then camera.CameraSubject = descendant end 
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if cachedBall and (descendant == cachedBall or not isBallInWorkspace(cachedBall)) then cachedBall = nil end
    if parriedBalls[descendant] then parriedBalls[descendant] = nil end
end)

---
-- 4. TARGETING FILTER
local function isBallTargetingMe(ball, hrpPos)
    -- Cek atribut Target (jika ada)
    local target = ball:GetAttribute("Target") or ball:GetAttribute("target")
    if target then
        if typeof(target) == "string" and (target == player.Name or target == player.UserId) then return true end
        if typeof(target) == "Instance" and target == player.Character then return true end
    end
    local tVal = ball:FindFirstChild("Target") or ball:FindFirstChild("target")
    if tVal then
        if tVal:IsA("ObjectValue") and tVal.Value == player.Character then return true end
        if tVal:IsA("StringValue") and (tVal.Value == player.Name) then return true end
    end
    
    -- Vector Prediction: Dot Product
    local vel = ball.AssemblyLinearVelocity
    if vel.Magnitude < 5 then return true end -- Bola diam/dekat = anggap targeting
    local dirToPlayer = (hrpPos - ball.Position).Unit
    local velDir = vel.Unit
    local dot = velDir:Dot(dirToPlayer)
    return dot > CONFIG.DOT_THRESHOLD -- 0.15 untuk 30 FPS (forgiving)
end

---
-- 5. DYNAMIC HITBOX
local function getDynamicRadius(velMag)
    local R = (velMag * CONFIG.PING_SEC) + CONFIG.SAFETY_BUFFER
    return math.clamp(R, CONFIG.BASE_RADIUS, CONFIG.MAX_RADIUS)
end

---
-- 6. EKSEKUSI (HARD LOCK)
local function fireGameParryRemotes()
    if not isParryEnabled then return end
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Net")
        if remotes then
            local pr = remotes:FindFirstChild("ParryButtonPress") or remotes:FindFirstChild("ParryAttempt") or remotes:FindFirstChild("Parry")
            if pr and pr:IsA("RemoteEvent") then pr:FireServer() end
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
    if not isParryEnabled then return end
    if VirtualInputManager then pcall(function() VirtualInputManager:SendKeyEvent(Enum.KeyCode.F, true, false, game); task.wait(0.0001); VirtualInputManager:SendKeyEvent(Enum.KeyCode.F, false, false, game) end) end  
    -- Sesuai screenshot: INPUT_BUTTONS > TouchFrame > Deflect_Button > Button
    local curPlayerGui = player:FindFirstChild("PlayerGui")
    if isAlive(curPlayerGui) then  
        local ib = curPlayerGui:FindFirstChild("INPUT_BUTTONS")
        if isAlive(ib) then  
            local tf = ib:FindFirstChild("TouchFrame")
            if isAlive(tf) then
                local db = tf:FindFirstChild("Deflect_Button")
                if isAlive(db) then  
                    clickGuiObject(db)  
                    local ibtn = db:FindFirstChild("Button")
                    if isAlive(ibtn) then clickGuiObject(ibtn) end
                end  
            end
        end  
    end
end

local function runClashSpam(targetCPS)
    if isClashSpamming then return end
    isClashSpamming = true
    task.spawn(function()
        local interval = 1 / targetCPS
        while isClashSpamming and isParryEnabled do
            fireGameParryRemotes()
            executeAutoClick()
            task.wait(interval)
        end
        isClashSpamming = false
    end)
end
local function stopClashSpam() isClashSpamming = false end

---
-- 7. MAIN LOOP
player.CharacterAdded:Connect(function(newCharacter) 
    character = newCharacter; humanoid = newCharacter:WaitForChild("Humanoid")
    task.wait(0.2); applyParryState(); applyCameraState() 
end)

RunService.PreRender:Connect(function()
    local now = tick(); local slowTime = now * 1.5; local rotAngle = (now * 25) % 360; local sineWave = (math.sin(slowTime) + 1) / 2; local pulsedColor = COLOR_CYAN:Lerp(COLOR_PURPLE, sineWave)  
    if isAlive(fg) then fg.Rotation = rotAngle end; if isAlive(og) then og.Rotation = -rotAngle end; if isAlive(bg) then bg.Rotation = rotAngle end; if isAlive(cbg) then cbg.Rotation = rotAngle end 
    if isAlive(fs) then fs.Color = pulsedColor end; if isAlive(os_) then os_.Color = COLOR_PURPLE:Lerp(COLOR_CYAN, sineWave) end; if isAlive(bs) then bs.Color = pulsedColor end; if isAlive(cbs) then cbs.Color = pulsedColor end  
end)

RunService.Heartbeat:Connect(function()
    if not isParryEnabled then return end
    local char = player.Character; if not isAlive(char) then return end  
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not isAlive(hrp) then return end  
    if not isAlive(visualAuraPart) then updateVisualAura() end  
    
    local ball = getWorkspaceBall()
    if not isBallInWorkspace(ball) then 
        stopClashSpam()
        if isAlive(visualAuraPart) then visualAuraPart.Color = COLOR_CYAN:Lerp(COLOR_PURPLE, (math.sin(tick() * 1.5) + 1) / 2) end
        return 
    end  
    
    local ballPos = safeGetPosition(ball); local hrpPos = safeGetPosition(hrp)
    if not ballPos or not hrpPos then return end  
    local distance = (ballPos - hrpPos).Magnitude  

    -- TARGETING FILTER
    if not isBallTargetingMe(ball, hrpPos) then 
        stopClashSpam()
        return 
    end
    
    -- DYNAMIC HITBOX
    local velMag = ball.AssemblyLinearVelocity.Magnitude
    local dynamicRadius = getDynamicRadius(velMag)
    
    -- CLASH DETECTION
    local lastStriker = ball:GetAttribute("LastStruckBy") or ball:GetAttribute("Owner") or ball:GetAttribute("Striker") or ball:GetAttribute("LastHit")
    local isClashing = false
    if lastStriker then
        local strikerChar = nil
        if typeof(lastStriker) == "Instance" and lastStriker:IsA("Player") then strikerChar = lastStriker.Character
        elseif typeof(lastStriker) == "string" then local p = Players:FindFirstChild(lastStriker); if p then strikerChar = p.Character end end
        if strikerChar then
            local sHRP = strikerChar:FindFirstChild("HumanoidRootPart")
            if sHRP and distance < CONFIG.CLASH_DIST then
                if (sHRP.Position - hrpPos).Magnitude < CONFIG.CLASH_PLAYER_DIST then isClashing = true end
            end
        end
    end
    
    if isClashing then
        -- Track CPS via ball velocity direction change (deflection)
        local currentVel = ball.AssemblyLinearVelocity
        if lastBallVelocity and currentVel.Magnitude > 10 and lastBallVelocity.Magnitude > 10 then
            local currentDir = currentVel.Unit; local lastDir = lastBallVelocity.Unit
            if currentDir:Dot(lastDir) < -0.3 then -- Bola berbalik arah = deflect
                local now = tick(); local dt = now - lastDeflectTime
                if dt > 0.04 and dt < 1.0 then 
                    detectedOpponentCPS = math.clamp(1 / dt, 8, 20)
                    lastDeflectTime = now 
                end
            end
        end
        lastBallVelocity = currentVel
        
        local targetCPS = math.min(detectedOpponentCPS + CONFIG.CPS_BOOST, CONFIG.MAX_CPS)
        targetCPS = math.max(targetCPS, CONFIG.MIN_CLASH_CPS)
        runClashSpam(targetCPS)
    else
        stopClashSpam(); lastBallVelocity = nil
        
        -- NORMAL PARRY
        if distance <= dynamicRadius then  
            if not parriedBalls[ball] then
                parriedBalls[ball] = true
                if isAlive(visualAuraPart) then visualAuraPart.Color = PARRY_FLASH_COLOR end  
                task.spawn(function()
                    if not isParryEnabled then return end
                    fireGameParryRemotes()
                    executeAutoClick()
                end)
            end
        else
            if parriedBalls[ball] then parriedBalls[ball] = nil end
            if isAlive(visualAuraPart) then visualAuraPart.Color = COLOR_CYAN:Lerp(COLOR_PURPLE, (math.sin(tick() * 1.5) + 1) / 2) end
        end
    end
end)

applyParryState()
applyCameraState()
