--[[  
DELTA ULTIMATE FRAMEWORK V2: PRECISION AUTO-WALK & MASTER GUI  
Fixes: Frame Overlap, Stuttering Animations, Teleport-to-Start,   
Floating Toggle Button, and Dynamic UI Scaling.  
]]

local Config = {  
    -- Movement  
    RecordInterval = 0.05, -- Faster recording for smoother playback  
    PlaybackSmoothness = 0.1,  
      
    -- GUI Appearance  
    Theme = "Galaxy Purple",  
    MainFrameSize = UDim2.new(0, 400, 0, 500),  
    HoverScale = 1.03,  
    ClickScale = 0.97,  
      
    -- Button Asset  
    ToggleIcon = "rbxassetid://101640388423900",  
      
    -- Animations  
    AnimationSpeed = 0.4,  
    RainbowSpeed = 1.5,  
}

local Themes = {  
    ["Galaxy Purple"] = { Main = Color3.fromRGB(120, 0, 255), Secondary = Color3.fromRGB(255, 0, 255), Accent = Color3.fromRGB(20, 0, 40), Text = Color3.fromRGB(255, 255, 255) },  
    ["Blue Neon"] = { Main = Color3.fromRGB(0, 150, 255), Secondary = Color3.fromRGB(0, 255, 255), Accent = Color3.fromRGB(0, 0, 30), Text = Color3.fromRGB(255, 255, 255) },  
}

local TweenService = game:GetService("TweenService")  
local RunService = game:GetService("RunService")  
local Players = game:GetService("Players")  
local HttpService = game:GetService("HttpService")

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
-- ADVANCED ANIMATION ENGINE  
-- =============================================================================  
local Engine = {}

function Engine.Tween(obj, time, props)  
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()  
end

function Engine.ApplyButtonEffects(btn)  
    local originalSize = btn.Size  
    btn.MouseEnter:Connect(function()  
        Engine.Tween(btn, Config.AnimationSpeed, {Size = UDim2.new(originalSize.X.Scale * Config.HoverScale, 0, originalSize.Y.Scale * Config.HoverScale, 0)})  
    end)  
    btn.MouseLeave:Connect(function()  
        Engine.Tween(btn, Config.AnimationSpeed, {Size = originalSize})  
    end)  
    btn.MouseButton1Down:Connect(function()  
        Engine.Tween(btn, 0.1, {Size = UDim2.new(originalSize.X.Scale * Config.ClickScale, 0, originalSize.Y.Scale * Config.ClickScale, 0)})  
    end)  
    btn.MouseButton1Up:Connect(function()  
        Engine.Tween(btn, 0.1, {Size = originalSize})  
    end)  
end

-- =============================================================================  
-- PRECISION WALK SYSTEM (NO STUTTER)  
-- =============================================================================  
local WalkS = {}

function WalkS.Start()  
    PathData = {}  
    StartPosition = RootPart.CFrame  
    Recording = true  
    Playing = false  
end

function WalkS.Stop()  
    Recording = false  
end

function WalkS.Rollback()  
    if #PathData > 0 then  
        local last = PathData[#PathData]  
        RootPart.CFrame = last.CFrame  
    end  
end

function WalkS.Play()  
    if #PathData == 0 then return end  
    Playing = true  
    Recording = false

    -- FIXED: Immediate Teleport to Start  
    RootPart.CFrame = StartPosition  
    task.wait(0.3)

    for _, point in ipairs(PathData) do  
        if not Playing then break end  
          
        -- Original Animations are kept by using MoveTo and not anchoring  
        Humanoid.WalkSpeed = point.Speed  
        Humanoid:MoveTo(point.CFrame.Position)  
          
        -- Wait precisely until reach or timeout to avoid lagging/stuttering  
        local alpha = 0  
        while (RootPart.Position - point.CFrame.Position).Magnitude > 0.5 and alpha < 20 do  
            alpha = alpha + 0.05  
            task.wait(0.05)  
        end  
    end  
    Playing = false  
end

RunService.Heartbeat:Connect(function()  
    if Recording then  
        table.insert(PathData, {  
            CFrame = RootPart.CFrame,  
            Speed = Humanoid.WalkSpeed  
        })  
        task.wait(Config.RecordInterval)  
    end  
end)

-- =============================================================================  
-- MODERN MODULAR GUI  
-- =============================================================================  
local Gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)  
Gui.Name = "DeltaUltimate_V2"  
Gui.ResetOnSpawn = false

-- Floating Toggle Button  
local ToggleBtn = Instance.new("ImageButton", Gui)  
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)  
ToggleBtn.Position = UDim2.new(0.9, 0, 0.5, 0)  
ToggleBtn.BackgroundColor3 = CurrentTheme.Main  
ToggleBtn.Image = Config.ToggleIcon  
local TCorner = Instance.new("UICorner", ToggleBtn)  
TCorner.CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", Gui)  
MainFrame.Size = Config.MainFrameSize  
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)  
MainFrame.BackgroundColor3 = CurrentTheme.Accent  
MainFrame.Visible = false  
MainFrame.ClipsDescendants = true

local MCorner = Instance.new("UICorner", MainFrame)  
MCorner.CornerRadius = UDim.new(0, 20)  
local MStroke = Instance.new("UIStroke", MainFrame)  
MStroke.Thickness = 3  
MStroke.Color = CurrentTheme.Main

local Title = Instance.new("TextLabel", MainFrame)  
Title.Size = UDim2.new(1, 0, 0, 60)  
Title.Text = "DELTA WALK PRECISION"  
Title.TextColor3 = CurrentTheme.Text  
Title.BackgroundTransparency = 1  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 22

local Container = Instance.new("ScrollingFrame", MainFrame)  
Container.Size = UDim2.new(1, -40, 1, -80)  
Container.Position = UDim2.new(0, 20, 0, 70)  
Container.BackgroundTransparency = 1  
Container.ScrollBarThickness = 4

local List = Instance.new("UIListLayout", Container)  
List.Padding = UDim.new(0, 12)  
List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, cb)  
    local b = Instance.new("TextButton", Container)  
    b.Size = UDim2.new(1, 0, 0, 45)  
    b.BackgroundColor3 = CurrentTheme.Main  
    b.Text = txt  
    b.TextColor3 = CurrentTheme.Text  
    b.Font = Enum.Font.GothamMedium  
    b.TextSize = 16  
      
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)  
    local s = Instance.new("UIStroke", b)   
    s.Color = CurrentTheme.Secondary  
    s.Thickness = 2  
      
    Engine.ApplyButtonEffects(b)  
    b.MouseButton1Click:Connect(cb)  
    return b  
end

CreateBtn("⏺ Start/Stop Recording", function()  
    if not Recording then WalkS.Start() else WalkS.Stop() end  
end)

CreateBtn("▶ Play Auto Walk", function()  
    WalkS.Play()  
end)

CreateBtn("↩ Rollback Position", function()  
    WalkS.Rollback()  
end)

CreateBtn("💾 Save File", function()  
    writefile("DeltaWalk_Save.json", HttpService:JSONEncode(PathData))  
end)

CreateBtn("🗑 Remove File", function()  
    delfile("DeltaWalk_Save.json")  
end)

-- Open/Close Logic  
ToggleBtn.MouseButton1Click:Connect(function()  
    MainFrame.Visible = not MainFrame.Visible  
    if MainFrame.Visible then  
        MainFrame.Size = UDim2.new(0, 0, 0, 0)  
        Engine.Tween(MainFrame, 0.5, {Size = Config.MainFrameSize})  
    end  
end)

-- Rainbow Effect  
spawn(function()  
    while task.wait(0.1) do  
        local hue = tick() * 0.1 % 1  
        MStroke.Color = Color3.fromHSV(hue, 0.8, 1)  
    end  
end)

print("Delta Ultimate V2 Loaded: Smooth Animations Enabled!") 
