--[[  
EXPEDITION ANTARCTICA - ULTIMATE LEGEND SUITE  
Created by: Delta maker script  
Features: Smart Auto-Walk, Auto-Jump, Temperature bypass (if applicable), Original Anim preservation.  
]]

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local LocalPlayer = Players.LocalPlayer

-- CONFIGURATION  
local Config = {  
    WalkSpeed = 16, -- Standard speed to avoid detection  
    JumpPower = 50,  
    SmartJump = true,  
    -- Waypoint data: {Vector3 position, Label}
    Waypoints = {  
        {Vector3.new(450, 15, 450), "Camp Alpha"},  
        {Vector3.new(1200, 45, 1100), "Base Camp"},  
        {Vector3.new(3000, 120, 3000), "The South Pole"}  
    }  
}

local CurrentWaypointIndex = 1  
local IsWalking = false

-- SMART OBSTACLE DETECTION (Raycasting)  
local function detectWall()  
    local char = LocalPlayer.Character  
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end  
      
    local hrp = char.HumanoidRootPart  
    local params = RaycastParams.new()  
    params.FilterDescendantsInstances = {char}  
    params.FilterType = Enum.RaycastFilterType.Exclude  
      
    local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 4, params)  
    return result ~= nil  
end

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))  
local MainFrame = Instance.new("Frame", ScreenGui)  
MainFrame.Size = UDim2.new(0, 200, 0, 100)  
MainFrame.Position = UDim2.new(0.5, -100, 0.8, 0)  
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)  
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)  
Title.Size = UDim2.new(1, 0, 0, 30)  
Title.Text = "ANTARCTICA LEGEND"  
Title.TextColor3 = Color3.new(1, 1, 1)  
Title.BackgroundTransparency = 1  
Title.Font = Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", MainFrame)  
ToggleBtn.Size = UDim2.new(0, 160, 0, 40)  
ToggleBtn.Position = UDim2.new(0.5, -80, 0.4, 0)  
ToggleBtn.Text = "Start Expedition"  
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)  
Instance.new("UICorner", ToggleBtn)

-- MAIN ENGINE  
local function startExpedition()  
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
    local hum = char:WaitForChild("Humanoid")  
    local hrp = char:WaitForChild("HumanoidRootPart")  
      
    hum.WalkSpeed = Config.WalkSpeed

    while IsWalking do  
        local waypointData = Config.Waypoints[CurrentWaypointIndex]  
        
        -- Jika semua waypoint selesai
        if not waypointData then   
            print("Expedition Complete: You reached the South Pole!")  
            IsWalking = false  
            CurrentWaypointIndex = 1 -- Reset indeks
            ToggleBtn.Text = "Start Expedition"  
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  
            break   
        end  
        
        local targetPosition = waypointData[1] -- Mengambil Vector3 dari tabel
          
        -- Move towards target  
        hum:MoveTo(targetPosition)  
          
        -- Auto-Jump Logic  
        if Config.SmartJump and detectWall() then  
            hum.Jump = true  
        end  
          
        -- Check distance to next waypoint  
        if (hrp.Position - targetPosition).Magnitude < 6 then  
            CurrentWaypointIndex = CurrentWaypointIndex + 1  
        end  
          
        task.wait(0.1)  
    end  
end

-- BUTTON EVENT LISTENER
ToggleBtn.MouseButton1Click:Connect(function()  
    IsWalking = not IsWalking  
    if IsWalking then  
        ToggleBtn.Text = "Stop Expedition"  
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)  
        task.spawn(startExpedition) -- Memanggil loop di thread baru
    else  
        ToggleBtn.Text = "Start Expedition"  
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  
    end  
end)
