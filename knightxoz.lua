-- [[ ALDO KNIGHTXORZ ]] --    

local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local Players = game:GetService("Players")  

local LocalPlayer = Players.LocalPlayer  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local RootPart = Character:WaitForChild("HumanoidRootPart")  
local Humanoid = Character:WaitForChild("Humanoid")  

LocalPlayer.CharacterAdded:Connect(function(newChar)  
    Character = newChar  
    RootPart = newChar:WaitForChild("HumanoidRootPart")  
    Humanoid = newChar:WaitForChild("Humanoid")  
end)  

local CFG = {  
    NodeInterval = 0.1,  
    MinDistance = 0.8,  
    LineColor = Color3.fromRGB(0, 255, 255),  
    AccentColor = Color3.fromRGB(170, 0, 255),  
}  

local state = {  
    isRecording = false,  
    isPlaying = false,  
    isPaused = false,  
    isAutoWalk = false,  
    timeline = {},  
    visualNodes = {},  
    lineVisible = true,  
    selectedSlot = 1,  
    savedSlots = {}  
}  

local function getOrCreateRouteFolder()  
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")  
    if not folder then  
        folder = Instance.new("Folder")  
        folder.Name = "KNIGHTXORZ_ROUTE"  
        folder.Parent = workspace  
    end  
    return folder  
end  

local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "AldoKnightXorzGui"  
ScreenGui.ResetOnSpawn = false  
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")  

local MainFrame = Instance.new("Frame")  
MainFrame.Size = UDim2.new(0, 240, 0, 480)  
MainFrame.Position = UDim2.new(0.8, 0, 0.2, 0)  
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  
MainFrame.BorderSizePixel = 0  
MainFrame.Active = true  
MainFrame.Parent = ScreenGui  

local Corner = Instance.new("UICorner")  
Corner.CornerRadius = UDim.new(0, 12)  
Corner.Parent = MainFrame  

local Stroke = Instance.new("UIStroke")  
Stroke.Thickness = 2  
Stroke.Color = CFG.AccentColor  
Stroke.Parent = MainFrame  

local Title = Instance.new("TextLabel")  
Title.Size = UDim2.new(1, 0, 0, 40)  
Title.Text = "ALDO KNIGHTXORZ"  
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 16  
Title.BackgroundTransparency = 1  
Title.Parent = MainFrame  

local StatusLabel = Instance.new("TextLabel")  
StatusLabel.Size = UDim2.new(1, 0, 0, 25)  
StatusLabel.Position = UDim2.new(0, 0, 0, 40)  
StatusLabel.Text = "Status: IDLE | Slot: 1"  
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)  
StatusLabel.Font = Enum.Font.GothamBold  
StatusLabel.TextSize = 12  
StatusLabel.BackgroundTransparency = 1  
StatusLabel.Parent = MainFrame  

local ScrollingContainer = Instance.new("ScrollingFrame")  
ScrollingContainer.Size = UDim2.new(1, -10, 1, -75)  
ScrollingContainer.Position = UDim2.new(0, 5, 0, 70)  
ScrollingContainer.BackgroundTransparency = 1  
ScrollingContainer.BorderSizePixel = 0  
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 600)  
ScrollingContainer.ScrollBarThickness = 4  
ScrollingContainer.Parent = MainFrame  

local UIList = Instance.new("UIListLayout")  
UIList.Parent = ScrollingContainer  
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center  
UIList.Padding = UDim.new(0, 8)  
UIList.SortOrder = Enum.SortOrder.LayoutOrder  

local function updateStatus(text)  
    StatusLabel.Text = "Status: " .. text .. " | Slot: " .. state.selectedSlot  
end  

local function createBtn(text, order, callback)  
    local btn = Instance.new("TextButton")  
    btn.Size = UDim2.new(0, 205, 0, 38)  
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  
    btn.Text = text  
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)  
    btn.Font = Enum.Font.GothamBold  
    btn.TextSize = 13  
    btn.LayoutOrder = order  
    btn.Parent = ScrollingContainer  
      
    local btnCorner = Instance.new("UICorner")  
    btnCorner.CornerRadius = UDim.new(0, 6)  
    btnCorner.Parent = btn  
      
    local btnStroke = Instance.new("UIStroke")  
    btnStroke.Thickness = 1  
    btnStroke.Color = Color3.fromRGB(70, 70, 90)  
    btnStroke.Parent = btn  

    btn.MouseButton1Click:Connect(function()  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CFG.AccentColor}):Play()  
        task.wait(0.15)  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()  
        callback()  
    end)  
    return btn  
end  

local dragging, dragInput, dragStart, startPos  
MainFrame.InputBegan:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
        dragging = true  
        dragStart = input.Position  
        startPos = MainFrame.Position  
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                dragging = false  
            end  
        end)  
    end  
end)  

UserInputService.InputChanged:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
        if dragging then  
            local delta = input.Position - dragStart  
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
        end  
    end  
end)  

local function drawLine(p1, p2)  
    local dist = (p1 - p2).Magnitude  
    if dist < 0.2 then return end  
      
    local part = Instance.new("Part")  
    part.Size = Vector3.new(0.15, 0.15, dist)  
    part.CFrame = CFrame.new(p1:Lerp(p2, 0.5), p2)  
    part.Anchored = true  
    part.CanCollide = false  
    part.Material = Enum.Material.Neon  
    part.Color = CFG.LineColor  
    part.Parent = getOrCreateRouteFolder()  
    part.Name = "VisualNode"  
    part.Transparency = state.lineVisible and 0 or 1  
    table.insert(state.visualNodes, part)  
end  

local function clearVisuals()  
    for _, v in pairs(state.visualNodes) do  
        if v then v:Destroy() end  
    end  
    state.visualNodes = {}  
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")  
    if folder then folder:ClearAllChildren() end  
end  

RunService.Heartbeat:Connect(function()  
    if not state.isRecording then return end  
      
    local now = tick()  
    local cf = RootPart.CFrame  
    local st = Humanoid:GetState()  
      
    if #state.timeline == 0 then  
        table.insert(state.timeline, {T = now, CFrame = cf, State = st})  
    else  
        local lastNode = state.timeline[#state.timeline]  
        local dist = (cf.Position - lastNode.CFrame.Position).Magnitude  
          
        if (now - lastNode.T >= CFG.NodeInterval) and (dist >= CFG.MinDistance) then  
            drawLine(lastNode.CFrame.Position, cf.Position)  
            table.insert(state.timeline, {T = now, CFrame = cf, State = st})  
        end  
    end  
end)  

local function executePlayback()  
    if #state.timeline < 2 or state.isPlaying then return end  
    state.isPlaying = true  
    state.isPaused = false  
    updateStatus("PLAYING")  

    task.spawn(function()  
        RootPart.CFrame = state.timeline[1].CFrame  
        task.wait(0.1)  

        for i = 1, #state.timeline do  
            if not state.isPlaying then break end  
            while state.isPaused do  
                task.wait(0.1)  
                if not state.isPlaying then break end  
            end  

            local node = state.timeline[i]  
              
            if node.State == Enum.HumanoidStateType.Jumping then  
                Humanoid.Jump = true  
            end  

            Humanoid:MoveTo(node.CFrame.Position)  

            local startTime = tick()  
            repeat  
                task.wait(0.05)  
                if not state.isPlaying then break end  
                while state.isPaused do task.wait(0.1) end  
                local dist = (RootPart.Position - node.CFrame.Position).Magnitude  
                if dist < 2.5 then break end  
            until (tick() - startTime) > 1.2  
        end  

        state.isPlaying = false  
        Humanoid:Move(Vector3.new(0, 0, 0), false)  
        updateStatus("IDLE")  
    end)  
end  

local function toggleAutoWalk()  
    state.isAutoWalk = not state.isAutoWalk  
    if state.isAutoWalk then  
        updateStatus("AUTO WALK")  
        task.spawn(function()  
            while state.isAutoWalk and #state.timeline > 2 do  
                executePlayback()  
                while state.isPlaying do  
                    task.wait(0.2)  
                    if not state.isAutoWalk then break end  
                end  
                task.wait(1)  
            end  
        end)  
    else  
        state.isPlaying = false  
        updateStatus("IDLE")  
    end  
end  

createBtn("RECORD START/STOP", 1, function()  
    state.isRecording = not state.isRecording  
    if state.isRecording then  
        state.timeline = {}  
        clearVisuals()  
        updateStatus("RECORDING")  
    else  
        updateStatus("IDLE")  
    end  
end)  

createBtn("PLAYBACK", 2, function()  
    executePlayback()  
end)  

createBtn("PAUSE / RESUME", 3, function()  
    state.isPaused = not state.isPaused  
    if state.isPaused then  
        updateStatus("PAUSED")  
        Humanoid:Move(Vector3.new(0, 0, 0), false)  
    else  
        updateStatus(state.isPlaying and "PLAYING" or "IDLE")  
    end  
end)  

createBtn("AUTO WALK ON/OFF", 4, function()  
    toggleAutoWalk()  
end)  

for i = 1, 5 do  
    createBtn("SELECT SLOT " .. i, 4 + i, function()  
        state.selectedSlot = i  
        updateStatus("SLOT " .. i)  
    end)  
end  

createBtn("SAVE FILE", 10, function()  
    if #state.timeline > 0 then  
        state.savedSlots[state.selectedSlot] = {  
            timeline = state.timeline  
        }  
        updateStatus("SAVED SLOT " .. state.selectedSlot)  
    end  
end)  

createBtn("LOAD FILE", 11, function()  
    local slotData = state.savedSlots[state.selectedSlot]  
    if slotData and slotData.timeline then  
        state.timeline = slotData.timeline  
        clearVisuals()  
        for i = 2, #state.timeline do  
            drawLine(state.timeline[i-1].CFrame.Position, state.timeline[i].CFrame.Position)  
        end  
        updateStatus("LOADED SLOT " .. state.selectedSlot)  
    end  
end)  

createBtn("CLEAR ROUTE", 12, function()  
    state.timeline = {}  
    clearVisuals()  
    updateStatus("CLEARED")  
end)  

createBtn("HIDE / SHOW LINE", 13, function()  
    state.lineVisible = not state.lineVisible  
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")  
    if folder then  
        for _, part in ipairs(folder:GetChildren()) do  
            if part:IsA("Part") then  
                part.Transparency = state.lineVisible and 0 or 1  
            end  
        end  
    end  
end)  

print("I'M KNIGHTXORz")
