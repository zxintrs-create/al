--[[  
ANIME VANGUARD MOBILE EDITION - DELTA SCRIPT  
Created by: Delta maker script  
Specialty: Fully Touch-Compatible, Anime Flight, Mobile UI  
]]

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local TweenService = game:GetService("TweenService")  
local LocalPlayer = Players.LocalPlayer

local FlyConfig = {  
NormalSpeed = 60,  
SuperSpeed = 150,  
Flying = false,  
CurrentSpeed = 60  
}

local BV, BG

-- Mobile UI Setup  
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)  
ScreenGui.Name = "DeltaMobileFly"

local function createBtn(name, pos, text, color)  
    local btn = Instance.new("TextButton", ScreenGui)  
    btn.Name = name  
    btn.Size = UDim2.new(0, 70, 0, 70)  
    btn.Position = pos  
    btn.Text = text  
    btn.BackgroundColor3 = color  
    btn.TextColor3 = Color3.new(1, 1, 1)  
    btn.Font = Enum.Font.GothamBold  
    btn.TextSize = 14  
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)  
    return btn  
end

local ToggleBtn = createBtn("Toggle", UDim2.new(0.8, 0, 0.6, 0), "FLY", Color3.fromRGB(40, 40, 40))  
local BoostBtn = createBtn("Boost", UDim2.new(0.8, 0, 0.75, 0), "BOOST", Color3.fromRGB(255, 100, 0))  
local UpBtn = createBtn("Up", UDim2.new(0.7, 0, 0.75, 0), "UP", Color3.fromRGB(40, 40, 40))  
local DownBtn = createBtn("Down", UDim2.new(0.7, 0, 0.9, 0), "DOWN", Color3.fromRGB(40, 40, 40))

-- Logic for Mobile Input  
local MobileInputs = {Up = false, Down = false, Boost = false}

UpBtn.MouseButton1Down:Connect(function() MobileInputs.Up = true end)  
UpBtn.MouseButton1Up:Connect(function() MobileInputs.Up = false end)  
DownBtn.MouseButton1Down:Connect(function() MobileInputs.Down = true end)  
DownBtn.MouseButton1Up:Connect(function() MobileInputs.Down = false end)  
BoostBtn.MouseButton1Down:Connect(function() MobileInputs.Boost = true end)  
BoostBtn.MouseButton1Up:Connect(function() MobileInputs.Boost = false end)

local function applyAnimeTilt(char, moveDir)  
    local targetCFrame = BG.CFrame  
    if moveDir.Magnitude > 0 then  
        targetCFrame = targetCFrame * CFrame.Angles(math.rad(-15), 0, 0)  
    end  
    TweenService:Create(BG, TweenInfo.new(0.3), {CFrame = targetCFrame}):Play()  
end

local function startFly()  
    local char = LocalPlayer.Character  
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end  
    local hrp = char.HumanoidRootPart  
    local hum = char:FindFirstChildOfClass("Humanoid")

    BV = Instance.new("BodyVelocity", hrp)  
    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)  
    BV.Velocity = Vector3.new(0, 0, 0)

    BG = Instance.new("BodyGyro", hrp)  
    BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)  
    BG.CFrame = hrp.CFrame

    hum.PlatformStand = true

    task.spawn(function()  
        while FlyConfig.Flying do  
            local camera = workspace.CurrentCamera  
            local moveDir = Vector3.new(0, 0, 0)  
              
            -- Use Humanoid MoveDirection for W/A/S/D emulation on Mobile  
            moveDir = hum.MoveDirection 

            if MobileInputs.Up then moveDir += Vector3.new(0, 1, 0) end  
            if MobileInputs.Down then moveDir -= Vector3.new(0, 1, 0) end

            FlyConfig.CurrentSpeed = MobileInputs.Boost and FlyConfig.SuperSpeed or FlyConfig.NormalSpeed

            if moveDir.Magnitude > 0 then  
                BV.Velocity = moveDir.Unit * FlyConfig.CurrentSpeed  
                applyAnimeTilt(char, moveDir)  
            else  
                BV.Velocity = Vector3.new(0, 0, 0)  
            end

            BG.CFrame = camera.CFrame  
            RunService.RenderStepped:Wait()  
        end  
        BV:Destroy()  
        BG:Destroy()  
        hum.PlatformStand = false  
    end)  
end

ToggleBtn.MouseButton1Click:Connect(function()  
    FlyConfig.Flying = not FlyConfig.Flying  
    ToggleBtn.Text = FlyConfig.Flying and "STOP" or "FLY"  
    ToggleBtn.BackgroundColor3 = FlyConfig.Flying and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)  
    if FlyConfig.Flying then startFly() end  
end)  
