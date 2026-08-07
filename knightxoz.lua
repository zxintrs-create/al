local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local RootPart = Character:WaitForChild("HumanoidRootPart")  
local Humanoid = Character:WaitForChild("Humanoid")

-- // CONFIG & STATE // --  
local CFG = {  
    NodeInterval = 0.05,  
    LineColor = Color3.fromRGB(0, 255, 255),  
    AccentColor = Color3.fromRGB(170, 0, 255),  
    MaxError = 0.05  
}

local state = {  
    isRecording = false,  
    isPlaying = false,  
    timeline = {},  
    visualNodes = {}  
}

-- // PREMIUM GUI SYSTEM // --  
local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "DeltaPremiumHub"  
ScreenGui.ResetOnSpawn = false  
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")  
MainFrame.Size = UDim2.new(0, 220, 0, 280)  
MainFrame.Position = UDim2.new(0.85, 0, 0.5, -140)  
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)  
MainFrame.BorderSizePixel = 0  
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")  
Corner.CornerRadius = UDim.new(0, 15)  
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")  
Stroke.Thickness = 2  
Stroke.Color = CFG.AccentColor  
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")  
Title.Size = UDim2.new(1, 0, 0, 40)  
Title.Text = "DELTA AUTO-WALK V3"  
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 16  
Title.BackgroundTransparency = 1  
Title.Parent = MainFrame

local UIList = Instance.new("UIListLayout")  
UIList.Parent = MainFrame  
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center  
UIList.Padding = UDim.new(0, 10)  
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper to create premium buttons  
local function createBtn(text, order, callback)  
    local btn = Instance.new("TextButton")  
    btn.Size = UDim2.new(0, 180, 0, 45)  
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)  
    btn.Text = text  
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)  
    btn.Font = Enum.Font.Gotham  
    btn.TextSize = 14  
    btn.LayoutOrder = order  
    btn.Parent = MainFrame  
      
    local btnCorner = Instance.new("UICorner")  
    btnCorner.CornerRadius = UDim.new(0, 8)  
    btnCorner.Parent = btn  
      
    local btnStroke = Instance.new("UIStroke")  
    btnStroke.Thickness = 1  
    btnStroke.Color = Color3.fromRGB(60, 60, 70)  
    btnStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()  
        -- Simple hover effect  
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CFG.AccentColor}):Play()  
        task.wait(0.1)  
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()  
        callback()  
    end)  
    return btn  
end

-- // VISUAL LINE LOGIC // --  
local function drawLine(p1, p2)  
    local dist = (p1 - p2).Magnitude  
    if dist < 0.1 then return end  
      
    local part = Instance.new("Part")  
    part.Size = Vector3.new(0.1, 0.1, dist)  
    part.CFrame = CFrame.new(p1:Lerp(p2, 0.5), p2)  
    part.Anchored = true  
    part.CanCollide = false  
    part.Material = Enum.Material.Neon  
    part.Color = CFG.LineColor  
    part.Parent = workspace:FindFirstChild("DeltaVisuals") or Instance.new("Folder", workspace)  
    part.Name = "VisualNode"  
    table.insert(state.visualNodes, part)  
end

local function clearVisuals()  
    for _, v in pairs(state.visualNodes) do v:Destroy() end  
    state.visualNodes = {}  
end

-- // CORE ENGINE // --

-- RECORDING  
RunService.Heartbeat:Connect(function()  
    if not state.isRecording then return end  
      
    local now = tick()  
    if #state.timeline == 0 or (tick() - state.timeline[#state.timeline].T >= CFG.NodeInterval) then  
        local cf = RootPart.CFrame  
        local st = Humanoid:GetState()  
          
        if #state.timeline > 0 then  
            drawLine(state.timeline[#state.timeline].CFrame.Position, cf.Position)  
        end  
          
        table.insert(state.timeline, {T = tick(), CFrame = cf, State = st})  
    end  
end)

-- PLAYBACK  
local function startPlayback()  
    if #state.timeline == 0 or state.isPlaying then return end  
    state.isPlaying = true  
      
    -- Disable character movement  
    Humanoid.WalkSpeed = 0  
      
    for i = 1, #state.timeline do  
        if not state.isPlaying then break end  
        local data = state.timeline[i]  
          
        -- Ultra-smooth lerp movement  
        local targetCF = data.CFrame  
        local duration = CFG.NodeInterval  
          
        local tween = TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})  
        tween:Play()  
          
        if data.State == Enum.HumanoidStateType.Jumping then  
            Humanoid.Jump = true  
        end  
          
        task.wait(duration)  
    end  
      
    state.isPlaying = false  
    Humanoid.WalkSpeed = 16  
end

-- ROLLBACK (STITCHING)  
local function executeRollback()  
    local safeIndex = #state.timeline  
      
    for i = #state.timeline, 2, -1 do  
        local current = state.timeline[i]  
        local prev = state.timeline[i-1]  
        local dist = (current.CFrame.Position - prev.CFrame.Position).Magnitude  
          
        if dist > 5 or current.State == Enum.HumanoidStateType.FallingDown or current.State == Enum.HumanoidStateType.Freefall then  
            safeIndex = i - 1  
        else  
            break  
        end  
    end  
      
    -- Slice timeline  
    for i = #state.timeline, safeIndex + 1, -1 do  
        table.remove(state.timeline, i)  
        if state.visualNodes[i] then  
            state.visualNodes[i]:Destroy()  
            table.remove(state.visualNodes, i)  
        end  
    end  
      
    if #state.timeline > 0 then  
        RootPart.CFrame = state.timeline[#state.timeline].CFrame  
    end  
end

-- // GUI BUTTONS // --  
createBtn("RECORD START/STOP", 1, function()  
    state.isRecording = not state.isRecording  
    if state.isRecording then  
        state.timeline = {}  
        clearVisuals()  
    end  
end)

createBtn("PLAYBACK", 2, function()  
    startPlayback()  
end)

createBtn("ROLLBACK (STITCH)", 3, function()  
    executeRollback()  
end)

createBtn("CLEAR DATA", 4, function()  
    state.timeline = {}  
    clearVisuals()  
    state.isPlaying = false  
end)

print("I'M KNIGHTXORz")
