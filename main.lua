--[[  
ANIME VANGUARD MOBILE EDITION - SUPERHERO FLY (EMOTE VERSION)
]]

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local TweenService = game:GetService("TweenService")  
local LocalPlayer = Players.LocalPlayer

local FlyConfig = {  
    Speed = 80,  
    Flying = false  
}

-- ID Animasi / Emote
local AnimIds = {  
    FlyIdle = "rbxassetid://139058906415119", -- Diam di udara / Mendarat
    FlyMove = "rbxassetid://117931620432186"  -- Saat Analog diarahkan
}

local BV, BG
local activeIdleTrack, activeMoveTrack

-- 1. Setup Mobile UI (1 Tombol "PLAY FLY")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperheroFlyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainBtn = Instance.new("TextButton", ScreenGui)  
MainBtn.Name = "FlyToggleBtn"  
MainBtn.Size = UDim2.new(0, 120, 0, 50)  
MainBtn.Position = UDim2.new(0.8, 0, 0.5, 0)  
MainBtn.Text = "PLAY FLY"  
MainBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)  
MainBtn.TextColor3 = Color3.new(1, 1, 1)  
MainBtn.Font = Enum.Font.GothamBold  
MainBtn.TextSize = 14  
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0.3, 0)

-- 2. Load Animasi Ke Character
local function setupAnimations(hum)
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    
    local animIdle = Instance.new("Animation")
    animIdle.AnimationId = AnimIds.FlyIdle
    
    local animMove = Instance.new("Animation")
    animMove.AnimationId = AnimIds.FlyMove
    
    activeIdleTrack = animator:LoadAnimation(animIdle)
    activeMoveTrack = animator:LoadAnimation(animMove)
    
    -- Priority Action agar menimpa gerakan/pose standar
    activeIdleTrack.Priority = Enum.AnimationPriority.Action
    activeMoveTrack.Priority = Enum.AnimationPriority.Action
end

local function stopAnimations()
    if activeIdleTrack then activeIdleTrack:Stop() end
    if activeMoveTrack then activeMoveTrack:Stop() end
end

-- 3. Logika Utama Terbang
local function startFly()  
    local char = LocalPlayer.Character  
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end  
    local hrp = char.HumanoidRootPart  
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hum then return end

    setupAnimations(hum)

    BV = Instance.new("BodyVelocity")  
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)  
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.Parent = hrp

    BG = Instance.new("BodyGyro")  
    BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)  
    BG.CFrame = hrp.CFrame
    BG.Parent = hrp

    hum.PlatformStand = true

    task.spawn(function()  
        local isMovingAnim = false

        while FlyConfig.Flying do  
            local camera = workspace.CurrentCamera  
            local moveDir = hum.MoveDirection -- Membaca pergerakan Analog Mobile

            -- JIKA ANALOG DIARAHKAN (BERGERAK)
            if moveDir.Magnitude > 0 then  
                BV.Velocity = moveDir.Unit * FlyConfig.Speed  
                
                -- Karakter miring ke depan mengikuti arah kamera
                BG.CFrame = camera.CFrame * CFrame.Angles(math.rad(-60), 0, 0)
                
                -- Mainkan animasi bergerak (ID: 117931620432186)
                if not isMovingAnim then
                    isMovingAnim = true
                    if activeIdleTrack then activeIdleTrack:Stop() end
                    if activeMoveTrack then activeMoveTrack:Play() end
                end

            -- JIKA ANALOG DIAM (DI UDARA)
            else  
                BV.Velocity = Vector3.new(0, 0, 0)  
                BG.CFrame = camera.CFrame
                
                -- Mainkan animasi diam/mendarat (ID: 139058906415119)
                if isMovingAnim or not activeIdleTrack.IsPlaying then
                    isMovingAnim = false
                    if activeMoveTrack then activeMoveTrack:Stop() end
                    if activeIdleTrack then activeIdleTrack:Play() end
                end
            end

            RunService.RenderStepped:Wait()  
        end  

        -- Bersihkan saat Fly dimatikan
        stopAnimations()
        if BV then BV:Destroy() end  
        if BG then BG:Destroy() end  
        hum.PlatformStand = false  
    end)  
end

-- 4. Event Tombol UI
MainBtn.MouseButton1Click:Connect(function()  
    FlyConfig.Flying = not FlyConfig.Flying  
    
    if FlyConfig.Flying then
        MainBtn.Text = "STOP"  
        MainBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        startFly() 
    else
        MainBtn.Text = "PLAY FLY"  
        MainBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        stopAnimations()
    end  
end)
