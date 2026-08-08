-- [[ ALDO KNIGHTXORZ: GOD-TIER AUTO WALK V4.8 ]] --  
-- Fixed: Playback Falling Issue | Added: Y-Axis Ground Lock & Lag compensation  
-- Created by Delta maker script

local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local Players = game:GetService("Players")  
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer  
local Character, RootPart, Humanoid

local stopPlayback

-- Cleanup Universal  
if _G.AldoKnightXorz_Cleanup then pcall(_G.AldoKnightXorz_Cleanup) end

local currentConnections = {}  
_G.AldoKnightXorz_Cleanup = function()  
    for _, conn in ipairs(currentConnections) do  
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end  
    end  
    currentConnections = {}

    RunService:UnbindFromRenderStep("AKX_Record")  
    RunService:UnbindFromRenderStep("AKX_Playback")

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")  
    for _, gui in ipairs(playerGui:GetChildren()) do  
        if gui:IsA("ScreenGui") and gui.Name == "AldoKnightXorzV47Gui" then  
            gui:Destroy()  
        end  
    end  
end

local function setupCharacter(char)  
    if stopPlayback then stopPlayback(true) end  
    Character = char  
    RootPart = char:WaitForChild("HumanoidRootPart")  
    Humanoid = char:WaitForChild("Humanoid")  
    if Humanoid then Humanoid.AutoRotate = true end  
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end  
table.insert(currentConnections, LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG = {  
    NodeInterval = 0.15, -- Faster sampling for smoother paths  
    MinDistance = 0.4,  
    LineColor = Color3.fromRGB(0, 255, 255),  
    AccentColor = Color3.fromRGB(170, 0, 255),  
    SaveFileName = "ALDO_KNIGHTXORZ_GODTIER.json",  
    Y_SENSITIVITY = 0.2, -- Tightness of the ground lock  
}

local state = {  
    isRecording = false,  
    isPlaying = false,  
    isPaused = false,  
    isAutoWalk = false,  
    playbackID = 0,  
    timeline = {},  
    visualNodes = {},  
    lineVisible = true,  
    selectedFile = 1,  
    savedFiles = {},  
    startTime = 0,  
    lastJumpState = false,  
    movementSpeed = 16,  
}

-- [ GROUND LOCK LOGIC: Prevent falling by raycasting downwards ]  
local function applyGroundLock(targetPos)  
    if not RootPart then return end  
      
    -- Raycast from above the character to find the actual floor  
    local rayOrigin = RootPart.Position + Vector3.new(0, 2, 0)  
    local rayDirection = Vector3.new(0, -10, 0)  
      
    local rayparams = RaycastParams.new()  
    rayparams.FilterDescendantsInstances = {Character}  
    rayparams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rayOrigin, rayDirection, rayparams)  
      
    if result then  
        local floorY = result.Position.Y + (Humanoid.HipHeight + (RootPart.Size.Y/2))  
        -- Only nudge if the difference is significant to avoid flickering  
        if math.abs(RootPart.Position.Y - floorY) > CFG.Y_SENSITIVITY then  
            RootPart.CFrame = RootPart.CFrame + Vector3.new(0, floorY - RootPart.Position.Y, 0)  
        end  
    end  
end

local function normalizeTimeline(timeline)  
    if #timeline == 0 then return timeline end  
    local baseTs = timeline[1].Timestamp  
    for _, node in ipairs(timeline) do  
        node.RelativeTimestamp = node.Timestamp - baseTs  
    end  
    return timeline  
end

-- [ Save/Load Logic ]  
local function saveToDisk()  
    local exportData = {}  
    for slot, data in pairs(state.savedFiles) do  
        local encodedTimeline = {}  
        for _, node in ipairs(data.timeline) do  
            table.insert(encodedTimeline, {  
                P = {math.round(node.Position.X * 100) / 100, math.round(node.Position.Y * 100) / 100, math.round(node.Position.Z * 100) / 100},  
                T = math.round(node.Timestamp * 1000) / 1000,  
                J = node.Jump  
            })  
        end  
        exportData[tostring(slot)] = { timeline = encodedTimeline }  
    end  
    if writefile then pcall(function() writefile(CFG.SaveFileName, HttpService:JSONEncode(exportData)) end) end  
end

local function loadFromDisk()  
    if readfile then  
        local success, result = pcall(function() return readfile(CFG.SaveFileName) end)  
        if success and result then  
            local successDecode, decoded = pcall(function() return HttpService:JSONDecode(result) end)  
            if successDecode and type(decoded) == "table" then  
                for slot, data in pairs(decoded) do  
                    local decodedTimeline = {}  
                    for _, node in ipairs(data.timeline) do  
                        table.insert(decodedTimeline, {Position = Vector3.new(unpack(node.P)), Timestamp = node.T, Jump = node.J or false})  
                    end  
                    state.savedFiles[tonumber(slot)] = { timeline = normalizeTimeline(decodedTimeline) }  
                end  
            end  
        end  
    end  
end  
loadFromDisk()

-- [ UI SETUP ]  
local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "AldoKnightXorzV47Gui"  
ScreenGui.ResetOnSpawn = false  
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- (GUI elements kept similar to original for consistency, focusing logic improvements)  
local OpenMenu = Instance.new("ImageButton")  
OpenMenu.Size = UDim2.new(0, 55, 0, 55)  
OpenMenu.Position = UDim2.new(0.05, 0, 0.5, 0)  
OpenMenu.BackgroundTransparency = 1  
OpenMenu.Image = "rbxassetid://101640388423900"  
OpenMenu.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")  
OpenCorner.CornerRadius = UDim.new(0, 8)  
OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")  
OpenStroke.Thickness = 2  
OpenStroke.Color = Color3.fromRGB(255, 255, 255)  
OpenStroke.Parent = OpenMenu

local OpenGradient = Instance.new("UIGradient")  
OpenGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 0, 255))})  
OpenGradient.Rotation = 45  
OpenGradient.Parent = OpenMenu

task.spawn(function()  
    while OpenMenu and OpenMenu.Parent do  
        OpenGradient.Rotation += 1  
        task.wait(0.03)  
    end  
end)

local MainFrame = Instance.new("Frame")  
MainFrame.Size = UDim2.new(0, 260, 0, 540)  
MainFrame.Position = UDim2.new(0.75, 0, 0.15, 0)  
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  
MainFrame.Visible = true  
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")  
Corner.CornerRadius = UDim.new(0, 12)  
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")  
Stroke.Thickness = 2  
Stroke.Color = CFG.AccentColor  
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")  
Title.Size = UDim2.new(1, 0, 0, 35)  
Title.Text = "ALDO KNIGHTXORZ V4.8 (GOD-TIER)"  
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 14  
Title.BackgroundTransparency = 1  
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")  
StatusLabel.Size = UDim2.new(1, 0, 0, 25)  
StatusLabel.Position = UDim2.new(0, 0, 0, 35)  
StatusLabel.Text = "Status: IDLE | File: 1"  
StatusLabel.TextColor3 = CFG.LineColor  
StatusLabel.Font = Enum.Font.GothamBold  
StatusLabel.TextSize = 12  
StatusLabel.BackgroundTransparency = 1  
StatusLabel.Parent = MainFrame

local ScrollingContainer = Instance.new("ScrollingFrame")  
ScrollingContainer.Size = UDim2.new(1, -10, 1, -70)  
ScrollingContainer.Position = UDim2.new(0, 5, 0, 65)  
ScrollingContainer.BackgroundTransparency = 1  
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 800)  
ScrollingContainer.ScrollBarThickness = 3  
ScrollingContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")  
UIList.Parent = ScrollingContainer  
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center  
UIList.Padding = UDim.new(0, 6)

local function updateStatus(text)  
    StatusLabel.Text = "Status: " .. text .. " | File: " .. state.selectedFile  
end

local function createBtn(text, order, callback)  
    local btn = Instance.new("TextButton")  
    btn.Size = UDim2.new(0, 230, 0, 35)  
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  
    btn.Text = text  
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)  
    btn.Font = Enum.Font.GothamBold  
    btn.TextSize = 12  
    btn.LayoutOrder = order  
    btn.Parent = ScrollingContainer  
    local btnCorner = Instance.new("UICorner")  
    btnCorner.CornerRadius = UDim.new(0, 6)  
    btnCorner.Parent = btn  
    btn.MouseButton1Click:Connect(function()  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CFG.AccentColor}):Play()  
        task.wait(0.15)  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()  
        callback()  
    end)  
    return btn  
end

-- [ Recording Logic ]  
RunService:BindToRenderStep("AKX_Record", Enum.RenderPriority.Character.Value, function()  
    if not state.isRecording or not RootPart or not Humanoid then return end  
    local pos = RootPart.Position  
    local st = Humanoid:GetState()  
    local vel = RootPart.AssemblyLinearVelocity  
    local currentTimestamp = tick() - state.startTime

    local isJumping = (Humanoid.FloorMaterial == Enum.Material.Air and vel.Y > 1) or (st == Enum.HumanoidStateType.Jumping)  
    local jumpTrigger = false  
    if isJumping and not state.lastJumpState then jumpTrigger = true end  
    state.lastJumpState = isJumping

    if #state.timeline == 0 then  
        table.insert(state.timeline, {Position = pos, Timestamp = currentTimestamp, Jump = jumpTrigger})  
    else  
        local lastNode = state.timeline[#state.timeline]  
        local dist = (pos - lastNode.Position).Magnitude  
        local timeDiff = currentTimestamp - lastNode.Timestamp  
        if (timeDiff >= CFG.NodeInterval and dist >= CFG.MinDistance) or jumpTrigger then  
            table.insert(state.timeline, {Position = pos, Timestamp = currentTimestamp, Jump = jumpTrigger})  
        end  
    end  
end)

stopPlayback = function(manualStop)  
    state.isPlaying = false  
    state.isPaused = false  
    state.playbackID = state.playbackID + 1  
    if manualStop then state.isAutoWalk = false end  
    RunService:UnbindFromRenderStep("AKX_Playback")  
    if Humanoid then Humanoid.AutoRotate = true end  
    updateStatus("IDLE")  
end

-- [ GOD-TIER PLAYBACK ENGINE ]  
local function executePlayback()  
    if #state.timeline < 2 or state.isPlaying or not RootPart or not Humanoid then return end

    stopPlayback(false)  
    state.isPlaying = true  
    state.playbackID = state.playbackID + 1  
    local currentPlaybackID = state.playbackID  
    Humanoid.WalkSpeed = state.movementSpeed

    local playbackState = "WALKING_TO_START"  
    local stateChanged = true  
    local startPos = state.timeline[1].Position  
    local playbackStartTime = 0  
    local pauseOffset = 0  
    local currentIndex = 1  
    local timeoutTimer = tick() + 25

    updateStatus("WALKING TO START")

    RunService:BindToRenderStep("AKX_Playback", Enum.RenderPriority.Last.Value, function(dt)  
        if not state.isPlaying or state.playbackID ~= currentPlaybackID or not RootPart or not Humanoid then  
            stopPlayback(false)  
            return  
        end

        if state.isPaused then  
            pauseOffset = pauseOffset + dt  
            Humanoid:Move(Vector3.zero, true)  
            return  
        end

        if playbackState == "WALKING_TO_START" then  
            if stateChanged then Humanoid:MoveTo(startPos) stateChanged = false end  
            if (RootPart.Position - startPos).Magnitude <= 2 or tick() > timeoutTimer then  
                playbackState = "PLAYING"  
                playbackStartTime = tick()  
                currentIndex = 1  
                stateChanged = true  
                updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")  
            end  
        elseif playbackState == "PLAYING" then  
            local currentTime = tick() - playbackStartTime - pauseOffset

            while currentIndex < #state.timeline and currentTime >= state.timeline[currentIndex + 1].RelativeTimestamp do  
                currentIndex = currentIndex + 1  
                if state.timeline[currentIndex].Jump then  
                    Humanoid.Jump = true  
                end  
            end

            if currentIndex >= #state.timeline then  
                if state.isAutoWalk then  
                    playbackState = "WALKING_TO_START"  
                    stateChanged = true  
                    timeoutTimer = tick() + 25  
                    updateStatus("WALKING TO START")  
                else  
                    stopPlayback(false)  
                end  
                return  
            end

            local currentNode = state.timeline[currentIndex]  
            local nextNode = state.timeline[currentIndex + 1]  
            local timeDiff = nextNode.RelativeTimestamp - currentNode.RelativeTimestamp  
            local alpha = (timeDiff > 0) and math.clamp((currentTime - currentNode.RelativeTimestamp) / timeDiff, 0, 1) or 1

            local targetPos = currentNode.Position:Lerp(nextNode.Position, alpha)  
              
            -- Step 1: Apply Ground Lock (Fixes falling/drifting)  
            applyGroundLock(targetPos)

            -- Step 2: Precise Directional Movement  
            local direction = (targetPos - RootPart.Position)  
            if direction.Magnitude > 0.1 then  
                local moveDir = Vector3.new(direction.X, 0, direction.Z).Unit  
                Humanoid:Move(moveDir, false)  
                  
                -- Dynamic Jump for obstacles  
                if direction.Y > 1.5 then Humanoid.Jump = true end  
            else  
                Humanoid:Move(Vector3.zero, true)  
            end  
        end  
    end)  
end

-- [ buttons logic from original ]  
createBtn("RECORD START / STOP", 1, function()  
    state.isRecording = not state.isRecording  
    if state.isRecording then  
        stopPlayback(true)  
        state.timeline = {}  
        state.startTime = tick()  
        updateStatus("RECORDING")  
    else  
        normalizeTimeline(state.timeline)  
        updateStatus("IDLE")  
    end  
end)

createBtn("PLAY ROUTE", 2, function()  
    if state.isRecording then return end  
    state.isAutoWalk = false  
    executePlayback()  
end)

createBtn("PAUSE / RESUME", 3, function()  
    if not state.isPlaying then return end  
    state.isPaused = not state.isPaused  
    updateStatus(state.isPaused and "PAUSED" or (state.isAutoWalk and "AUTO WALK" or "PLAYING"))  
end)

createBtn("AUTO WALK ON / OFF", 4, function()  
    state.isAutoWalk = not state.isAutoWalk  
    if state.isAutoWalk then executePlayback() else stopPlayback(true) end  
end)

createBtn("STOP PLAYBACK", 5, function() stopPlayback(true) end)

for i = 1, 5 do  
    createBtn("SELECT FILE " .. i, 5 + i, function()  
        state.selectedFile = i  
        updateStatus("IDLE")  
    end)  
end

createBtn("SAVE FILE", 11, function()  
    if #state.timeline > 0 then  
        normalizeTimeline(state.timeline)  
        state.savedFiles[state.selectedFile] = { timeline = state.timeline }  
        saveToDisk()  
        updateStatus("SAVED FILE " .. state.selectedFile)  
    end  
end)

createBtn("LOAD FILE", 12, function()  
    local fileData = state.savedFiles[state.selectedFile]  
    if fileData then  
        stopPlayback(true)  
        state.timeline = normalizeTimeline(fileData.timeline)  
        updateStatus("LOADED FILE " .. state.selectedFile)  
    end  
end)

createBtn("CLEAR ROUTE", 13, function()  
    stopPlayback(true)  
    state.timeline = {}  
    updateStatus("CLEARED")  
end)

print("HEAVELYNE ART")  
