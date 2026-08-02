--[[  
    DELTA MASTER FRAMEWORK: AUTO-WALK RECORDER & ADVANCED GUI ANIMATION  
    Features: Precision Record, Original Animations, File Management,   
    Professional UI Animation Framework, RGB/Neon Themes, Mobile Optimized.  
]]

-- =============================================================================  
-- CONFIGURATION SECTION  
-- =============================================================================  
local Config = {  
    -- AutoWalk Settings  
    RecordInterval = 0.1,  
    InterpolationSpeed = 0.2,  
    DefaultSpeed = 16,  
      
    -- UI Animation Settings  
    Theme = "Galaxy Purple", -- Options: "Galaxy Purple", "Blue Neon", "Cyber", "RGB"  
    AnimationSpeed = 0.3,  
    HoverScale = 1.05,  
    ClickScale = 0.95,  
    RainbowSpeed = 2,  
    GlowIntensity = 0.5,  
      
    -- Performance  
    EnablePerformanceMode = true,  
    EnableMobileOptimization = true,  
}

-- Theme Color Palettes  
local Themes = {  
    ["Galaxy Purple"] = { Main = Color3.fromRGB(120, 0, 255), Secondary = Color3.fromRGB(255, 0, 255), Accent = Color3.fromRGB(40, 0, 80), Text = Color3.fromRGB(255, 255, 255) },  
    ["Blue Neon"] = { Main = Color3.fromRGB(0, 150, 255), Secondary = Color3.fromRGB(0, 255, 255), Accent = Color3.fromRGB(0, 0, 50), Text = Color3.fromRGB(255, 255, 255) },  
    ["Cyber"] = { Main = Color3.fromRGB(255, 255, 0), Secondary = Color3.fromRGB(255, 0, 0), Accent = Color3.fromRGB(20, 20, 20), Text = Color3.fromRGB(255, 255, 0) },  
    ["RGB"] = { Main = Color3.fromRGB(255, 255, 255), Secondary = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(0, 0, 0), Text = Color3.fromRGB(255, 255, 255) }  
}

-- =============================================================================  
-- SERVICES & VARIABLES  
-- =============================================================================  
local TweenService = game:GetService("TweenService")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local HttpService = game:GetService("HttpService")  
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local Humanoid = Character:WaitForChild("Humanoid")  
local RootPart = Character:WaitForChild("HumanoidRootPart")

local CurrentTheme = Themes[Config.Theme]  
local Recording = false  
local Playing = false  
local PathData = {}  
local StartPosition = nil

-- =============================================================================  
-- UI ANIMATION FRAMEWORK (The Core)  
-- =============================================================================  
local Framework = {}

function Framework.Tween(obj, time, props)  
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()  
end

function Framework.ApplyHover(obj)  
    if not obj:IsA("GuiObject") then return end  
      
    obj.MouseEnter:Connect(function()  
        Framework.Tween(obj, Config.AnimationSpeed, {Size = UDim2.new(Config.HoverScale, 0, Config.HoverScale, 0)})  
        if obj:FindFirstChildOfClass("UIStroke") then  
            Framework.Tween(obj:FindFirstChildOfClass("UIStroke"), Config.AnimationSpeed, {Thickness = 3, Color = CurrentTheme.Secondary})  
        end  
    end)  
      
    obj.MouseLeave:Connect(function()  
        Framework.Tween(obj, Config.AnimationSpeed, {Size = UDim2.new(1, 0, 1, 0)}) -- Assuming scale 1  
        if obj:FindFirstChildOfClass("UIStroke") then  
            Framework.Tween(obj:FindFirstChildOfClass("UIStroke"), Config.AnimationSpeed, {Thickness = 2, Color = CurrentTheme.Main})  
        end  
    end)  
end

function Framework.ApplyClick(obj)  
    if not obj:IsA("GuiButton") then return end  
    obj.MouseButton1Down:Connect(function()  
        Framework.Tween(obj, 0.1, {Size = UDim2.new(Config.ClickScale, 0, Config.ClickScale, 0)})  
    end)  
    obj.MouseButton1Up:Connect(function()  
        Framework.Tween(obj, 0.1, {Size = UDim2.new(1, 0, 1, 0)})  
    end)  
end

function Framework.RainbowStroke(obj)  
    spawn(function()  
        while obj and obj.Parent do  
            local hue = tick() * 0.2 % 1  
            local color = Color3.fromHSV(hue, 0.8, 1)  
            Framework.Tween(obj, 0.1, {Color = color})  
            task.wait(0.1)  
        end  
    end)  
end

-- =============================================================================  
-- AUTO-WALK LOGIC (Precision & Animation)  
-- =============================================================================  
local WalkSystem = {}

function WalkSystem.StartRecording()  
    PathData = {}  
    StartPosition = RootPart.CFrame  
    Recording = true  
    Playing = false  
    print("Recording started...")  
end

function WalkSystem.StopRecording()  
    Recording = false  
    print("Recording stopped. Points saved: " .. #PathData)  
end

function WalkSystem.Rollback()  
    if #PathData > 0 then  
        local lastPoint = PathData[#PathData]  
        RootPart.CFrame = lastPoint.CFrame  
        print("Rolled back to last stable point.")  
    end  
end

function WalkSystem.Play()  
    if #PathData == 0 then return end  
    Playing = true  
    Recording = false  
      
    -- Teleport to start  
    RootPart.CFrame = StartPosition  
    task.wait(0.5)  
      
    for i, point in ipairs(PathData) do  
        if not Playing then break end  
          
        -- Smooth movement using Lerp/Tween to preserve animations  
        local targetCFrame = point.CFrame  
        local distance = (RootPart.Position - targetCFrame.Position).Magnitude  
          
        Humanoid:MoveTo(targetCFrame.Position)  
          
        -- Adjust speed based on recorded speed  
        Humanoid.WalkSpeed = point.Speed  
          
        -- Wait until we reach the point or timeout  
        local timeout = 0  
        while (RootPart.Position - targetCFrame.Position).Magnitude > 1 and timeout < 20 do  
            timeout = timeout + 0.1  
            task.wait(0.05)  
        end  
    end  
    Playing = false  
end

-- Recording Loop  
RunService.Heartbeat:Connect(function()  
    if Recording then  
        table.insert(PathData, {  
            CFrame = RootPart.CFrame,  
            Speed = Humanoid.WalkSpeed,  
            Time = tick()  
        })  
        task.wait(Config.RecordInterval)  
    end  
end)

-- File Management  
function WalkSystem.SaveFile(filename)  
    local data = HttpService:JSONEncode({  
        Start = {RootPart.CFrame:GetComponents()},  
        Points = {}  
    })  
    -- Convert PathData to serializable table first  
    for _, p in ipairs(PathData) do  
        table.insert(data, {CFrame = p.CFrame:GetComponents(), Speed = p.Speed})  
    end  
    writefile(filename .. ".json", data)  
end

function WalkSystem.RemoveFile(filename)  
    delfile(filename .. ".json")  
end

-- =============================================================================  
-- MAIN GUI CONSTRUCTION  
-- =============================================================================  
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))  
ScreenGui.Name = "DeltaFramework_UI"  
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)  
MainFrame.Size = UDim2.new(0, 250, 0, 350)  
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)  
MainFrame.BackgroundColor3 = CurrentTheme.Accent  
MainFrame.BorderSizePixel = 0  
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner", MainFrame)  
UICorner.CornerRadius = UDim.new(0, 15)

local UIStroke = Instance.new("UIStroke", MainFrame)  
UIStroke.Thickness = 2  
UIStroke.Color = CurrentTheme.Main

local Title = Instance.new("TextLabel", MainFrame)  
Title.Size = UDim2.new(1, 0, 0, 50)  
Title.Text = "DELTA AUTO-WALK PRO"  
Title.TextColor3 = CurrentTheme.Text  
Title.BackgroundTransparency = 1  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 18

local ButtonContainer = Instance.new("ScrollingFrame", MainFrame)  
ButtonContainer.Size = UDim2.new(1, -20, 1, -70)  
ButtonContainer.Position = UDim2.new(0, 10, 0, 60)  
ButtonContainer.BackgroundTransparency = 1  
ButtonContainer.CanvasSize = UDim2.new(0, 0, 1.5, 0)  
ButtonContainer.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", ButtonContainer)  
UIList.Padding = UDim.new(0, 10)  
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, callback)  
    local btn = Instance.new("TextButton", ButtonContainer)  
    btn.Size = UDim2.new(1, 0, 0, 40)  
    btn.BackgroundColor3 = CurrentTheme.Main  
    btn.Text = text  
    btn.TextColor3 = CurrentTheme.Text  
    btn.Font = Enum.Font.GothamMedium  
    btn.TextSize = 14  
      
    local bCorner = Instance.new("UICorner", btn)  
    bCorner.CornerRadius = UDim.new(0, 8)  
      
    local bStroke = Instance.new("UIStroke", btn)  
    bStroke.Color = CurrentTheme.Secondary  
      
    Framework.ApplyHover(btn)  
    Framework.ApplyClick(btn)  
      
    btn.MouseButton1Click:Connect(callback)  
    return btn  
end

CreateButton("⏺ Record", function()  
    if not Recording then WalkSystem.StartRecording() else WalkSystem.StopRecording() end  
end)

CreateButton("▶ Play", function()  
    WalkSystem.Play()  
end)

CreateButton("↩ Rollback", function()  
    WalkSystem.Rollback()  
end)

CreateButton("💾 Save Path", function()  
    WalkSystem.SaveFile("MyWalkPath")  
end)

CreateButton("🗑 Remove Path", function()  
    WalkSystem.RemoveFile("MyWalkPath")  
end)

-- Apply Global Animations  
Framework.RainbowStroke(UIStroke)

-- Loading Animation  
local LoadingFrame = Instance.new("Frame", ScreenGui)  
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)  
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)  
LoadingFrame.ZIndex = 10

local LoadText = Instance.new("TextLabel", LoadingFrame)  
LoadText.Size = UDim2.new(1, 0, 1, 0)  
LoadText.Text = "Loading Delta Framework..."  
LoadText.TextColor3 = Color3.fromRGB(255,255,255)  
LoadText.BackgroundTransparency = 1  
LoadText.Font = Enum.Font.GothamBold  
LoadText.TextSize = 24

Framework.Tween(LoadingFrame, 1, {BackgroundTransparency = 1})  
Framework.Tween(LoadText, 1, {TextTransparency = 1})  
task.wait(1)  
LoadingFrame:Destroy()

print("Delta Master Framework Loaded Successfully!")  
