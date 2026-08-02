--[[  
GUNUNG EXPRESS - LEGEND AUTO-WALK SYSTEM  
Created by: Delta maker script  
Features: Original Animation Preservation, Standard Walkspeed, Legend Shortcuts, Anti-Detection  
]]

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local TweenService = game:GetService("TweenService")  
local LocalPlayer = Players.LocalPlayer

local Config = {  
    WalkSpeed = 16, -- Kecepatan standar agar tidak terdeteksi  
    UseShortcuts = true, -- Gunakan rute Legend Shortcut  
    Smoothness = 0.1, -- Interpolasi pergerakan  
    Waypoints = {  
        -- Rute Utama (Original Path)  
        {Vector3.new(100, 10, 100), "Start"},  
        {Vector3.new(150, 12, 120), "Checkpoint 1"},  
        {Vector3.new(200, 15, 150), "Checkpoint 2"},  
          
        -- Rute Legend Shortcut (Rahasia)  
        {Vector3.new(170, 13, 110), "Shortcut A"},   
        {Vector3.new(210, 16, 130), "Shortcut B"},  
        {Vector3.new(300, 50, 300), "Peak/Summit"}  
    }  
}

local CurrentWaypointIndex = 1  
local IsWalking = false

-- Fungsi untuk menjaga animasi tetap asli  
local function preserveAnimations()  
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
    local humanoid = char:WaitForChild("Humanoid")  
      
    -- Mematikan modifikasi kecepatan internal agar animasi jalan default tetap sinkron  
    humanoid.WalkSpeed = Config.WalkSpeed  
end

-- Logika Pergerakan Smooth (Lerp/Tween)  
local function moveToWaypoint(targetPos)  
    local char = LocalPlayer.Character  
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end  
      
    local hrp = char.HumanoidRootPart  
    local humanoid = char:FindFirstChildOfClass("Humanoid")  
      
    -- Menggerakkan karakter secara natural menggunakan MoveTo  
    humanoid:MoveTo(targetPos)  
      
    -- Tunggu sampai karakter sampai di waypoint dengan toleransi jarak  
    repeat   
        task.wait()   
    until (hrp.Position - targetPos).Magnitude < 3 or not IsWalking  
end

-- Main Loop untuk Auto-Walk  
local function startAutoWalk()  
    IsWalking = true  
    preserveAnimations()  
      
    while IsWalking do  
        local target = Config.Waypoints[CurrentWaypointIndex]  
        if target then  
            print("Moving to: " .. target[2])  
            moveToWaypoint(target[1])  
              
            -- Logika pemilihan rute berikutnya (Shortcut vs Normal)  
            if Config.UseShortcuts and CurrentWaypointIndex == 2 then  
                CurrentWaypointIndex = 4 -- Lompat ke Shortcut A  
            else  
                CurrentWaypointIndex = CurrentWaypointIndex + 1  
            end  
        else  
            print("Telah mencapai Puncak Gunung Express!")  
            IsWalking = false  
            break  
        end  
    end  
end

-- Simple GUI untuk Toggle  
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)  
local ToggleBtn = Instance.new("TextButton", ScreenGui)  
ToggleBtn.Size = UDim2.new(0, 150, 0, 50)  
ToggleBtn.Position = UDim2.new(0.5, -75, 0.8, 0)  
ToggleBtn.Text = "Start Legend Walk"  
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)  
Instance.new("UICorner", ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()  
    if not IsWalking then  
        ToggleBtn.Text = "Stop Walk"  
        startAutoWalk()  
    else  
        IsWalking = false  
        ToggleBtn.Text = "Start Legend Walk"  
    end  
end)  
