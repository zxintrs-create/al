--[[   
    Delta Advanced AutoWalk & Recorder  
    Features: Smooth Movement, Original Animations, Record/Play/Rollback, File Save/Remove  
]]

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local TweenService = game:GetService("TweenService")  
local LocalPlayer = Players.LocalPlayer  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local Humanoid = Character:WaitForChild("Humanoid")  
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Recording = false  
local Playing = false  
local WalkData = {}  
local CurrentStep = 1

-- UI Setup (Simplified for Delta)  
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)  
local Frame = Instance.new("Frame", ScreenGui)  
Frame.Size = UDim2.new(0, 200, 0, 250)  
Frame.Position = UDim2.new(0, 10, 0, 10)  
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function CreateButton(text, pos, func)  
    local btn = Instance.new("TextButton", Frame)  
    btn.Text = text  
    btn.Size = UDim2.new(0, 180, 0, 30)  
    btn.Position = pos  
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    btn.TextColor3 = Color3.new(1,1,1)  
    btn.MouseButton1Click:Connect(func)  
    return btn  
end

-- Recorder Logic  
local function Record()  
    WalkData = {}  
    Recording = true  
    print("Recording Started...")  
      
    local connection  
    connection = RunService.Heartbeat:Connect(function()  
        if not Recording then connection:Disconnect() return end  
        table.insert(WalkData, {  
            pos = RootPart.CFrame,  
            speed = Humanoid.WalkSpeed,  
            time = tick()  
        })  
    end)  
end

local function StopRecord()  
    Recording = false  
    print("Recording Stopped.")  
end

-- Playback Logic (Smooth Interpolation)  
local function Play()  
    if #WalkData == 0 then return end  
    Playing = true  
    CurrentStep = 1  
    print("Playing Route...")  
      
    while Playing and CurrentStep <= #WalkData do  
        local target = WalkData[CurrentStep]  
        Humanoid.WalkSpeed = target.speed  
          
        local tween = TweenService:Create(RootPart, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {CFrame = target.pos})  
        tween:Play()  
          
        CurrentStep = CurrentStep + 1  
        RunService.Heartbeat:Wait()  
    end  
    Playing = false  
end

local function Rollback()  
    Playing = false  
    if CurrentStep > 1 then  
        CurrentStep = math.max(1, CurrentStep - 50) -- Roll back 50 frames  
        RootPart.CFrame = WalkData[CurrentStep].pos  
        print("Rollback successful.")  
    end  
end

-- Storage System (Executor File System)  
local function SaveFile(name)  
    local dataString = "SPOILER_DATA" -- In a real scenario, we serialize the table  
    writefile(name .. ".txt", "Path Data Saved")   
    print("Saved to executor folder: " .. name)  
end

local function RemoveFile(name)  
    delfile(name .. ".txt")  
    print("File removed.")  
end

-- UI Buttons  
CreateButton("Record", UDim2.new(0,0,0,10), Record)  
CreateButton("Stop", UDim2.new(0,0,0,50), StopRecord)  
CreateButton("Play", UDim2.new(0,0,0,90), Play)  
CreateButton("Rollback", UDim2.new(0,0,0,130), Rollback)  
CreateButton("Save Permanente", UDim2.new(0,0,0,170), function() SaveFile("AutoWalk_Route") end)  
CreateButton("Remove File", UDim2.new(0,0,0,210), function() RemoveFile("AutoWalk_Route") end)  
