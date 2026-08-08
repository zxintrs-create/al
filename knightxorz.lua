-- [[ ALDO KNIGHTXORZ V4.30 ADVANCED OPTIMIZED EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character, RootPart, Humanoid

local stopPlayback

-- Universal Cleanup (Extended range up to 50)
for i = 3, 50 do
    pcall(function()
        if _G["AldoKnightXorzV" .. i .. "_Cleanup"] then
            _G["AldoKnightXorzV" .. i .. "_Cleanup"]()
        end
    end)
end
if _G.AldoKnightXorzV430_Cleanup then pcall(_G.AldoKnightXorzV430_Cleanup) end

local currentConnections = {}
_G.AldoKnightXorzV430_Cleanup = function()
    for _, conn in ipairs(currentConnections) do
        if typeof(conn) == "RBXScriptConnection" then 
            pcall(function() conn:Disconnect() end) 
        end
    end
    currentConnections = {}
    
    for vNum = 4, 430 do
        pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV" .. vNum .. "_Record") end)
        pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV" .. vNum .. "_Playback") end)
    end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:find("AldoKnightXorz") then
                gui:Destroy()
            end
        end
    end
end

local function isCharacterAlive()
    return Character 
        and Character.Parent 
        and RootPart 
        and RootPart.Parent 
        and Humanoid 
        and Humanoid.Parent 
        and Humanoid.Health > 0
end

local function setupCharacter(char)
    if stopPlayback then stopPlayback(true) end
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid.AutoRotate = true end
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

table.insert(currentConnections, LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG = {
    NodeInterval = 1 / 30, -- Stable 30 FPS Recording
    MinDistance = 0.15,
    LineColor = Color3.fromRGB(0, 255, 255),
    AccentColor = Color3.fromRGB(170, 0, 255),
    SaveFileName = "ALDO_KNIGHTXORZ_PURE_V4_30.json"
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
    cutStart = 1,
    cutEnd = 1
}

local function cloneTimeline(tbl)
    local clone = {}
    for _, node in ipairs(tbl) do
        table.insert(clone, {
            CFrame = node.CFrame,
            Position = node.Position,
            Timestamp = node.Timestamp,
            RelativeTimestamp = node.RelativeTimestamp,
            Jump = node.Jump,
            WalkSpeed = node.WalkSpeed,
            HumanoidState = node.HumanoidState,
            MovementDirection = node.MovementDirection
        })
    end
    return clone
end

local function normalizeTimeline(timeline)
    if #timeline == 0 then return timeline end
    local baseTs = timeline[1].Timestamp
    for _, node in ipairs(timeline) do
        node.RelativeTimestamp = node.Timestamp - baseTs
    end
    return timeline
end

local function saveToDisk()
    local exportData = {}
    for slot, data in pairs(state.savedFiles) do
        if data and data.timeline then
            local encodedTimeline = {}
            for _, node in ipairs(data.timeline) do
                local cf = node.CFrame or CFrame.new(node.Position)
                local comps = {cf:GetComponents()}
                local roundedComps = {}
                for _, v in ipairs(comps) do
                    table.insert(roundedComps, math.round(v * 1000) / 1000)
                end
                
                table.insert(encodedTimeline, {
                    C = roundedComps,
                    P = {
                        math.round(node.Position.X * 100) / 100,
                        math.round(node.Position.Y * 100) / 100,
                        math.round(node.Position.Z * 100) / 100
                    },
                    T = math.round(node.Timestamp * 1000) / 1000,
                    J = node.Jump or false,
                    W = node.WalkSpeed or 16,
                    S = tostring(node.HumanoidState or Enum.HumanoidStateType.Running),
                    D = node.MovementDirection and {node.MovementDirection.X, node.MovementDirection.Y, node.MovementDirection.Z} or {0,0,0}
                })
            end
            exportData[tostring(slot)] = { timeline = encodedTimeline }
        end
    end
    
    pcall(function()
        if writefile then
            writefile(CFG.SaveFileName, HttpService:JSONEncode(exportData))
        end
    end)
end

local function loadFromDisk()
    pcall(function()
        if readfile then
            local success, result = pcall(function() return readfile(CFG.SaveFileName) end)
            if success and result then
                local successDecode, decoded = pcall(function() return HttpService:JSONDecode(result) end)
                if successDecode and type(decoded) == "table" then
                    for slot, data in pairs(decoded) do
                        if data and data.timeline then
                            local decodedTimeline = {}
                            for _, node in ipairs(data.timeline) do
                                local targetCf, pos
                                if node.C and type(node.C) == "table" and #node.C == 12 then
                                    targetCf = CFrame.new(table.unpack(node.C))
                                    pos = targetCf.Position
                                elseif node.P then
                                    pos = Vector3.new(table.unpack(node.P))
                                    targetCf = CFrame.new(pos)
                                end
                                
                                local dir = Vector3.zero
                                if node.D and #node.D == 3 then
                                    dir = Vector3.new(table.unpack(node.D))
                                end
                                
                                if pos then
                                    table.insert(decodedTimeline, {
                                        CFrame = targetCf,
                                        Position = pos,
                                        Timestamp = node.T,
                                        Jump = node.J or false,
                                        WalkSpeed = node.W or 16,
                                        HumanoidState = node.S or Enum.HumanoidStateType.Running,
                                        MovementDirection = dir
                                    })
                                end
                            end
                            state.savedFiles[tonumber(slot) or slot] = { timeline = normalizeTimeline(decodedTimeline) }
                        end
                    end
                end
            end
        end
    end)
end

loadFromDisk()

local function getOrCreateRouteFolder()
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "KNIGHTXORZ_ROUTE"
        folder.Parent = workspace
    end
    return folder
end

local function clearVisuals()
    for _, v in pairs(state.visualNodes) do
        if v and v.Parent then v:Destroy() end
    end
    state.visualNodes = {}
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")
    if folder then folder:ClearAllChildren() end
end

-- Optimized Batch Route & Walkway Generation (Prevents Lag Spikes)
local function buildOptimizedRoute()
    clearVisuals()
    if #state.timeline < 2 then return end

    local folder = getOrCreateRouteFolder()
    local batchSize = 15 -- Group segments to reduce part count and relieve mobile device hardware limits
    
    for i = 1, #state.timeline - 1, batchSize do
        local endIndex = math.min(i + batchSize - 1, #state.timeline)
        local pStart = state.timeline[i].Position
        local pEnd = state.timeline[endIndex].Position
        local dist = (pStart - pEnd).Magnitude
        
        if dist > 0.1 then
            -- Continuous Transparent Walkway Platform
            local walkway = Instance.new("Part")
            walkway.Size = Vector3.new(1.5, 0.2, dist)
            walkway.CFrame = CFrame.new(pStart:Lerp(pEnd, 0.5), pEnd)
            walkway.Anchored = true
            walkway.CanCollide = true
            walkway.CanTouch = false
            walkway.CanQuery = false
            walkway.CastShadow = false
            walkway.Locked = true
            walkway.Material = Enum.Material.SmoothPlastic
            walkway.Color = CFG.LineColor
            walkway.Transparency = 0.95
            walkway.Name = "RouteWalkway"
            walkway.Parent = folder
            table.insert(state.visualNodes, walkway)

            -- Visual Line Guide
            local linePart = Instance.new("Part")
            linePart.Size = Vector3.new(0.12, 0.12, dist)
            linePart.CFrame = walkway.CFrame
            linePart.Anchored = true
            linePart.CanCollide = false
            linePart.CanQuery = false
            linePart.CastShadow = false
            linePart.Locked = true
            linePart.Material = Enum.Material.Neon
            linePart.Color = CFG.LineColor
            linePart.Transparency = state.lineVisible and 0 or 1
            linePart.Name = "VisualNode"
            linePart.Parent = folder
            table.insert(state.visualNodes, linePart)
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXorzV430Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- OPEN MENU BUTTON (58x58)
--========================================================
local OpenMenu = Instance.new("ImageButton")
OpenMenu.Name = "OpenMenu"
OpenMenu.Size = UDim2.fromOffset(58, 58)
OpenMenu.Position = UDim2.new(0.05, 0, 0.5, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenMenu.BackgroundTransparency = 0.2
OpenMenu.ZIndex = 10
OpenMenu.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(255, 255, 255)
OpenStroke.Parent = OpenMenu

local IconImage = Instance.new("ImageLabel")
IconImage.Name = "Icon"
IconImage.Size = UDim2.new(0.8, 0, 0.8, 0)
IconImage.Position = UDim2.new(0.1, 0, 0.1, 0)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxassetid://101640388423900"
IconImage.ZIndex = 11
IconImage.Parent = OpenMenu

--========================================================
-- MAIN FRAME (550x325)
--========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(550, 325)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -162.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local openMoved = false
table.insert(currentConnections, OpenMenu.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        openMoved = true
    end
end))

table.insert(currentConnections, OpenMenu.Activated:Connect(function()
    if openMoved then
        openMoved = false
        return
    end
    MainFrame.Visible = not MainFrame.Visible
end))

local openDragging, openDragStart, openStartPos
table.insert(currentConnections, OpenMenu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openDragging = true
        openDragStart = input.Position
        openStartPos = OpenMenu.Position
        openMoved = false
        local changedConn
        changedConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                openDragging = false
                if changedConn then changedConn:Disconnect() end
            end
        end)
    end
end))

table.insert(currentConnections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if openDragging then
            local delta = input.Position - openDragStart
            if delta.Magnitude > 5 then
                openMoved = true
            end
            OpenMenu.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
        end
    end
end))

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = CFG.AccentColor
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ALDO KNIGHTXORZ V4.30 OPTIMIZED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.ZIndex = 3
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.Text = "Status: IDLE | File: 1 | Cut: 1-1"
StatusLabel.TextColor3 = CFG.LineColor
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.ZIndex = 3
StatusLabel.Parent = MainFrame

local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Size = UDim2.new(1, -20, 1, -75)
ScrollingContainer.Position = UDim2.new(0, 10, 0, 65)
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.BorderSizePixel = 0
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.XY
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.ZIndex = 3
ScrollingContainer.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.fromOffset(120, 39)
UIGrid.CellPadding = UDim2.fromOffset(8, 8)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder
UIGrid.Parent = ScrollingContainer

local function updateStatus(text)
    if not ScreenGui or not ScreenGui.Parent then return end
    local frame = ScreenGui:FindFirstChild("MainFrame")
    if frame then
        local lbl = frame:FindFirstChild("StatusLabel")
        if lbl then
            lbl.Text = "Status: " .. text .. " | File: " .. state.selectedFile .. " | Cut: " .. state.cutStart .. "-" .. state.cutEnd
        end
    end
end

local function createBtn(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(120, 39)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.ZIndex = 4
    btn.Parent = ScrollingContainer

    local btnCorner = Instance.new("UICorner")  
    btnCorner.CornerRadius = UDim.new(0, 6)  
    btnCorner.Parent = btn  
        
    local btnStroke = Instance.new("UIStroke")  
    btnStroke.Thickness = 1  
    btnStroke.Color = Color3.fromRGB(70, 70, 90)  
    btnStroke.Parent = btn  

    table.insert(currentConnections, btn.Activated:Connect(function()  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CFG.AccentColor}):Play()  
        task.wait(0.15)  
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()  
        callback()  
    end))  
    return btn
end

local lastRecordTick = 0
pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV430_Record") end)
RunService:BindToRenderStep("AldoKnightXorzV430_Record", Enum.RenderPriority.Character.Value, function()
    if not state.isRecording or not isCharacterAlive() then return end

    local now = tick()
    if now - lastRecordTick < CFG.NodeInterval then return end
    lastRecordTick = now

    local cf = RootPart.CFrame
    local pos = cf.Position  
    local st = Humanoid:GetState()  
    local vel = RootPart.AssemblyLinearVelocity  
    local currentTimestamp = now - state.startTime  
      
    local isJumping = (Humanoid.FloorMaterial == Enum.Material.Air and vel.Y > 1) or (st == Enum.HumanoidStateType.Jumping) or (st == Enum.HumanoidStateType.Freefall and vel.Y > 2)  
    local jumpTrigger = false  
    if isJumping and not state.lastJumpState then  
        jumpTrigger = true  
    end  
    state.lastJumpState = isJumping  

    local moveDir = Humanoid.MoveDirection

    if #state.timeline == 0 then  
        table.insert(state.timeline, {  
            CFrame = cf,
            Position = pos,  
            Timestamp = currentTimestamp,
            RelativeTimestamp = 0,
            Jump = jumpTrigger,
            WalkSpeed = Humanoid.WalkSpeed,
            HumanoidState = st,
            MovementDirection = moveDir
        })  
        state.cutStart = 1
        state.cutEnd = 1
    else  
        local lastNode = state.timeline[#state.timeline]  
        local dist = (pos - lastNode.Position).Magnitude  
        local timeDiff = currentTimestamp - lastNode.Timestamp  
            
        if (timeDiff >= CFG.NodeInterval and dist >= CFG.MinDistance) or jumpTrigger then  
            table.insert(state.timeline, {  
                CFrame = cf,
                Position = pos,  
                Timestamp = currentTimestamp,
                RelativeTimestamp = 0,
                Jump = jumpTrigger,
                WalkSpeed = Humanoid.WalkSpeed,
                HumanoidState = st,
                MovementDirection = moveDir
            })  
            normalizeTimeline(state.timeline)
            state.cutEnd = #state.timeline
        end  
    end
end)

stopPlayback = function(manualStop)
    state.isPlaying = false
    state.isPaused = false
    state.playbackID = state.playbackID + 1
    if manualStop then
        state.isAutoWalk = false
    end

    pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV430_Playback") end)
      
    if isCharacterAlive() and Humanoid then  
        Humanoid.AutoRotate = true  
        Humanoid:Move(Vector3.zero, true)  
    end  
    updateStatus("IDLE")
end

local function executePlayback()
    if #state.timeline < 2 or state.isPlaying or not isCharacterAlive() then return end

    stopPlayback(false)  
    state.isPlaying = true  
    state.isPaused = false  
    state.playbackID = state.playbackID + 1  
    local currentPlaybackID = state.playbackID  

    local playbackState = "WALKING_TO_START"  
    local stateChanged = true  
      
    local startPos = state.timeline[1].Position  
    local playbackStartTime = 0  
    local pauseOffset = 0  
    local currentIndex = 1  
    local timeoutTimer = tick() + 25  
    local pausedCFrame = nil

    updateStatus("WALKING TO START")  

    pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV430_Playback") end)
    RunService:BindToRenderStep("AldoKnightXorzV430_Playback", Enum.RenderPriority.Camera.Value - 1, function(dt)  
        if not state.isPlaying or state.playbackID ~= currentPlaybackID or not isCharacterAlive() then  
            stopPlayback(false)  
            return  
        end  
          
        if state.isPaused then  
            pauseOffset = pauseOffset + dt  
            if playbackState == "PLAYING" and pausedCFrame and RootPart then
                RootPart.CFrame = pausedCFrame
                RootPart.AssemblyLinearVelocity = Vector3.zero
                RootPart.AssemblyAngularVelocity = Vector3.zero
            elseif Humanoid then  
                Humanoid:Move(Vector3.zero, true)  
            end
            return  
        else
            pausedCFrame = nil
        end

        if playbackState == "WALKING_TO_START" or playbackState == "RETURNING_TO_START" then  
            if stateChanged then  
                Humanoid:MoveTo(startPos)  
                stateChanged = false  
            end  
              
            local dist = (RootPart.Position - startPos).Magnitude  
            if dist <= 1.5 or tick() > timeoutTimer then  
                if dist > 5.0 and tick() > timeoutTimer then  
                    updateStatus("ABORTED: STUCK")  
                    stopPlayback(false)  
                    return  
                end  
                playbackState = "PLAYING"  
                playbackStartTime = tick()  
                pauseOffset = 0  
                currentIndex = 1  
                stateChanged = true  
                updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")  
            end  
        elseif playbackState == "PLAYING" then  
            local currentTime = tick() - playbackStartTime - pauseOffset  

            while currentIndex < #state.timeline and currentTime >= state.timeline[currentIndex + 1].RelativeTimestamp do  
                currentIndex = currentIndex + 1  
                if state.timeline[currentIndex].Jump and Humanoid then  
                    Humanoid.Jump = true  
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)  
                end  
            end  

            if currentIndex >= #state.timeline then  
                if state.isAutoWalk then  
                    playbackState = "RETURNING_TO_START"  
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
            
            if currentNode.WalkSpeed then
                Humanoid.WalkSpeed = currentNode.WalkSpeed
            end

            local timeDiff = nextNode.RelativeTimestamp - currentNode.RelativeTimestamp  
              
            local alpha = 0  
            if timeDiff > 0 then  
                alpha = math.clamp((currentTime - currentNode.RelativeTimestamp) / timeDiff, 0, 1)  
            end  

            local targetPos = currentNode.Position:Lerp(nextNode.Position, alpha)  
            local currentPos = RootPart.Position  
            local direction = (targetPos - currentPos)  
            local totalDist = direction.Magnitude  

            -- Physics-First Stability Engine (No aggressive teleport loops)
            if totalDist > 4.0 then
                RootPart.CFrame = CFrame.new(targetPos)
            else
                RootPart.CFrame = RootPart.CFrame:Lerp(CFrame.new(targetPos, targetPos + direction), 0.3)
            end

            if totalDist > 0.15 then  
                Humanoid.AutoRotate = false  
                local horizontal = Vector3.new(direction.X, 0, direction.Z)  
                if horizontal.Magnitude > 0 then  
                    Humanoid:Move(horizontal.Unit, false)  
                end  
                if direction.Y > 1.8 then  
                    Humanoid.Jump = true  
                end  
            else  
                Humanoid:Move(Vector3.zero, true)  
            end  

            if currentNode.CFrame and nextNode.CFrame then
                pausedCFrame = currentNode.CFrame:Lerp(nextNode.CFrame, alpha)
            else
                pausedCFrame = CFrame.new(targetPos)
            end
        end  
    end)
end

local function toggleAutoWalk()
    if state.isRecording then return end
    state.isAutoWalk = not state.isAutoWalk
    if state.isAutoWalk then
        updateStatus("AUTO WALK")
        if not state.isPlaying then
            executePlayback()
        end
    else
        stopPlayback(true)
    end
end

createBtn("RECORD START", 1, function()
    state.isRecording = not state.isRecording
    if state.isRecording then
        stopPlayback(true)
        state.timeline = {}
        clearVisuals()
        state.startTime = tick()
        state.lastJumpState = false
        updateStatus("RECORDING")
    else
        normalizeTimeline(state.timeline)
        state.cutStart = 1
        state.cutEnd = #state.timeline
        buildOptimizedRoute()
        updateStatus("IDLE")
    end
end)

createBtn("PLAY ROUTE", 2, function()
    if state.isRecording then return end
    state.isAutoWalk = false
    executePlayback()
end)

createBtn("PAUSE / RES", 3, function()
    if not state.isPlaying then return end
    state.isPaused = not state.isPaused
    if state.isPaused then
        updateStatus("PAUSED")
    else
        updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
    end
end)

createBtn("AUTO WALK", 4, function()
    toggleAutoWalk()
end)

createBtn("STOP", 5, function()
    stopPlayback(true)
end)

createBtn("<< CUT", 6, function()
    if #state.timeline > 2 then
        state.cutStart = math.clamp(state.cutStart + 1, 1, state.cutEnd - 1)
        updateStatus("CUT CONFIG")
    end
end)

createBtn("CUT >>", 7, function()
    if #state.timeline > 2 then
        state.cutEnd = math.clamp(state.cutEnd - 1, state.cutStart + 1, #state.timeline)
        updateStatus("CUT CONFIG")
    end
end)

createBtn("APPLY CUT", 8, function()
    if #state.timeline > 2 and state.cutStart < state.cutEnd then
        local newTimeline = {}
        for i = 1, #state.timeline do
            if i < state.cutStart or i > state.cutEnd then
                table.insert(newTimeline, state.timeline[i])
            end
        end
        state.timeline = normalizeTimeline(newTimeline)
        buildOptimizedRoute()
        state.cutStart = 1
        state.cutEnd = #state.timeline
        updateStatus("CUT APPLIED")
    end
end)

createBtn("PUT TOGETHER", 9, function()
    if #state.savedFiles > 0 or #state.timeline > 2 then
        local base = state.savedFiles[state.selectedFile]
        if base and base.timeline and #base.timeline > 0 then
            local merged = cloneTimeline(base.timeline)
            local offsetTime = merged[#merged].RelativeTimestamp
            
            for _, node in ipairs(state.timeline) do
                local clonedNode = cloneTimeline({node})[1]
                clonedNode.RelativeTimestamp = offsetTime + node.RelativeTimestamp
                table.insert(merged, clonedNode)
            end
            state.timeline = normalizeTimeline(merged)
        else
            local merged = {}
            for _, node in ipairs(state.timeline) do
                table.insert(merged, node)
            end
            state.timeline = normalizeTimeline(merged)
        end
        
        buildOptimizedRoute()
        updateStatus("MERGED ROUTE")
    end
end)

for i = 1, 5 do
    createBtn("FILE " .. i, 9 + i, function()
        state.selectedFile = i
        updateStatus("IDLE")
    end)
end

createBtn("SAVE FILE", 15, function()
    if #state.timeline > 0 then
        normalizeTimeline(state.timeline)
        state.savedFiles[state.selectedFile] = {
            timeline = cloneTimeline(state.timeline)
        }
        saveToDisk()
        updateStatus("SAVED FILE " .. state.selectedFile)
    end
end)

createBtn("LOAD FILE", 16, function()
    local fileData = state.savedFiles[state.selectedFile]
    if fileData and fileData.timeline then
        stopPlayback(true)
        state.timeline = normalizeTimeline(cloneTimeline(fileData.timeline))
        buildOptimizedRoute()
        state.cutStart = 1
        state.cutEnd = #state.timeline
        updateStatus("LOADED FILE " .. state.selectedFile)
    end
end)

createBtn("CLEAR", 17, function()
    stopPlayback(true)
    state.timeline = {}
    clearVisuals()
    updateStatus("CLEARED")
end)

createBtn("LINE VISIBLE", 18, function()
    state.lineVisible = not state.lineVisible
    local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE")
    if folder then
        for _, part in ipairs(folder:GetChildren()) do
            if part.Name == "VisualNode" then
                part.Transparency = state.lineVisible and 0 or 1
            end
        end
    end
end)
