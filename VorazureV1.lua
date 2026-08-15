local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character, RootPart, Humanoid

local stopPlayback

local function safeCleanup()
pcall(function()
if _G.AldoKnightXorzV437_Cleanup then
_G.AldoKnightXorzV437_Cleanup()
end
end)
end
safeCleanup()

local currentConnections = {}
_G.AldoKnightXorzV437_Cleanup = function()
for _, conn in ipairs(currentConnections) do
if typeof(conn) == "RBXScriptConnection" then
pcall(function() conn:Disconnect() end)
end
end
currentConnections = {}

pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Record") end)  
pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Playback") end)  
  
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)  
if playerGui then  
    for _, gui in ipairs(playerGui:GetChildren()) do  
        if gui:IsA("ScreenGui") and gui.Name == "AldoKnightXorzV437Gui" then  
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
if Humanoid then
Humanoid.AutoRotate = true
end
end

if LocalPlayer.Character then
setupCharacter(LocalPlayer.Character)
end

table.insert(currentConnections, LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG = {
NodeInterval = 1 / 30,
MinDistance = 0.05,
LineColor = Color3.fromRGB(0, 255, 255),
AccentColor = Color3.fromRGB(170, 0, 255),
SaveFileName = "ALDO_KNIGHTXORZ_V4_37.json"
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
cutStart = 1,
cutEnd = 1,
originalWalkSpeed = 16,
memoryStorage = {}
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
  
state.memoryStorage = exportData  
  
pcall(function()  
    if writefile then  
        writefile(CFG.SaveFileName, HttpService:JSONEncode(exportData))  
    end  
end)

end

local function loadFromDisk()
local decoded = nil
pcall(function()
if readfile then
local success, result = pcall(function() return readfile(CFG.SaveFileName) end)
if success and result then
local successDecode, decodedResult = pcall(function() return HttpService:JSONDecode(result) end)
if successDecode then decoded = decodedResult end
end
end
end)

if not decoded and next(state.memoryStorage) ~= nil then  
    decoded = state.memoryStorage  
end  

if decoded and type(decoded) == "table" then  
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

loadFromDisk()

local function getOrCreateRouteFolder()
local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE_V437")
if not folder then
folder = Instance.new("Folder")
folder.Name = "KNIGHTXORZ_ROUTE_V437"
folder.Parent = workspace
end
return folder
end

local function clearVisuals()
for _, v in pairs(state.visualNodes) do
if v and v.Parent then v:Destroy() end
end
state.visualNodes = {}
local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE_V437")
if folder then folder:ClearAllChildren() end
end

local function createRouteSegment(p1, p2)
local dist = (p1 - p2).Magnitude
if dist < 0.05 then return end

local folder = getOrCreateRouteFolder()  

local linePart = Instance.new("Part")  
linePart.Size = Vector3.new(0.08, 0.08, dist)  
linePart.CFrame = CFrame.new(p1:Lerp(p2, 0.5), p2)  
linePart.Anchored = true  
linePart.CanCollide = false  
linePart.CanQuery = false  
linePart.CanTouch = false  
linePart.CastShadow = false  
linePart.Locked = true  
linePart.Material = Enum.Material.Neon  
linePart.Color = CFG.LineColor  
linePart.Transparency = state.lineVisible and 0 or 1  
linePart.Name = "VisualNode"  
linePart.Parent = folder  
table.insert(state.visualNodes, linePart)  

local raycastParams = RaycastParams.new()  
raycastParams.FilterType = Enum.RaycastFilterType.Exclude  
raycastParams.FilterDescendantsInstances = Character and {Character, folder} or {folder}  
raycastParams.IgnoreWater = true  

local midPos = p1:Lerp(p2, 0.5)  
local rayResult = workspace:Raycast(midPos + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), raycastParams)  

if rayResult and rayResult.Position then  
    local groundPos = rayResult.Position + Vector3.new(0, 0.02, 0)  
    local groundMarker = Instance.new("Part")  
    groundMarker.Size = Vector3.new(0.6, 0.03, dist)  
    groundMarker.CFrame = CFrame.new(groundPos, groundPos + (p2 - p1).Unit * 10)  
    groundMarker.Anchored = true  
    groundMarker.CanCollide = false  
    groundMarker.CanQuery = false  
    groundMarker.CanTouch = false  
    groundMarker.CastShadow = false  
    groundMarker.Locked = true  
    groundMarker.Material = Enum.Material.SmoothPlastic  
    groundMarker.Color = CFG.LineColor  
    groundMarker.Transparency = state.lineVisible and 0.3 or 1  
    groundMarker.Name = "GroundMarker"  
    groundMarker.Parent = folder  
    table.insert(state.visualNodes, groundMarker)  
end

end

local function rebuildFullRoute()
clearVisuals()
if #state.timeline < 2 then return end
for i = 2, #state.timeline do
createRouteSegment(state.timeline[i-1].Position, state.timeline[i].Position)
end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoKnightXorzV437Gui"
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
MainFrame.Visible = false
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local openMoved = false
local openDragging, openDragStart, openStartPos

table.insert(currentConnections, OpenMenu.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
openDragging = true
openDragStart = input.Position
openStartPos = OpenMenu.Position
openMoved = false
end
end))

table.insert(currentConnections, UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
if openDragging then
local delta = input.Position - openDragStart
if delta.Magnitude > 4 then
openMoved = true
OpenMenu.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
end
end
end
end))

table.insert(currentConnections, UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
openDragging = false
end
end))

table.insert(currentConnections, OpenMenu.Activated:Connect(function()
if openMoved then
openMoved = false
return
end
MainFrame.Visible = not MainFrame.Visible
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
Title.Text = "ALDO KNIGHTXORZ V4.37 PRODUCTION READY"
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
pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Record") end)
RunService:BindToRenderStep("AldoKnightXorzV437_Record", Enum.RenderPriority.Character.Value, function()
if not state.isRecording or not isCharacterAlive() then return end

local now = tick()  
if now - lastRecordTick < CFG.NodeInterval then return end  
lastRecordTick = now  

local cf = RootPart.CFrame  
local pos = cf.Position    
local st = Humanoid:GetState()    
local currentTimestamp = now - state.startTime    
    
local isJumpingState = (st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall)  
local jumpTrigger = false  
if isJumpingState and not state.lastJumpState then  
    jumpTrigger = true  
end  
state.lastJumpState = isJumpingState  

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
        createRouteSegment(lastNode.Position, pos)  
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

pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Playback") end)  
    
if isCharacterAlive() and Humanoid then    
    Humanoid.AutoRotate = true    
    Humanoid:Move(Vector3.zero, true)    
    Humanoid.WalkSpeed = state.originalWalkSpeed  
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

state.originalWalkSpeed = Humanoid.WalkSpeed
Humanoid.AutoRotate = true

local playbackState = "WALKING_TO_START"
local stateChanged = true

local startPos = state.timeline[1].Position
local playbackStartTime = tick()
local totalPauseDuration = 0
local pauseStartTime = 0
local currentIndex = 1
local lastJumpConsumedIndex = 0
local timeoutTimer = tick() + 30
local lookAheadTime = 0.12
local maxCorrectionDistance = 2.5

local function getNodeAtTime(targetTime, fromIndex)
    local index = math.max(1, math.min(fromIndex or 1, #state.timeline - 1))
    while index < #state.timeline - 1 and targetTime > state.timeline[index + 1].RelativeTimestamp do
        index = index + 1
    end
    return index
end

local function getInterpolatedPosition(targetTime, fromIndex)
    if targetTime <= state.timeline[1].RelativeTimestamp then
        return state.timeline[1].Position
    end

    local lastNode = state.timeline[#state.timeline]
    if targetTime >= lastNode.RelativeTimestamp then
        return lastNode.Position
    end

    local index = getNodeAtTime(targetTime, fromIndex)
    local a = state.timeline[index]
    local b = state.timeline[index + 1]
    local span = b.RelativeTimestamp - a.RelativeTimestamp
    local alpha = span > 0 and math.clamp((targetTime - a.RelativeTimestamp) / span, 0, 1) or 1
    return a.Position:Lerp(b.Position, alpha)
end

updateStatus("WALKING TO START")

pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Playback") end)
RunService:BindToRenderStep("AldoKnightXorzV437_Playback", Enum.RenderPriority.Character.Value - 1, function(dt)
    if not state.isPlaying or state.playbackID ~= currentPlaybackID or not isCharacterAlive() then
        stopPlayback(false)
        return
    end

    if state.isPaused then
        if pauseStartTime == 0 then
            pauseStartTime = tick()
        end
        Humanoid:Move(Vector3.zero, true)
        return
    elseif pauseStartTime > 0 then
        totalPauseDuration = totalPauseDuration + (tick() - pauseStartTime)
        pauseStartTime = 0
    end

    if playbackState == "WALKING_TO_START" or playbackState == "RETURNING_TO_START" then
        Humanoid.AutoRotate = true

        if stateChanged then
            Humanoid:MoveTo(startPos)
            stateChanged = false
        end

        local dist = (RootPart.Position - startPos).Magnitude
        if dist <= 0.75 then
            playbackState = "PLAYING"
            playbackStartTime = tick()
            totalPauseDuration = 0
            currentIndex = 1
            lastJumpConsumedIndex = 0
            stateChanged = true
            updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
        elseif tick() > timeoutTimer then
            if dist > 4.0 then
                updateStatus("ABORTED: STUCK")
                stopPlayback(false)
                return
            end
            stateChanged = true
            timeoutTimer = tick() + 10
        end

    elseif playbackState == "PLAYING" then
        Humanoid.AutoRotate = true

        local currentTime = tick() - playbackStartTime - totalPauseDuration

        while currentIndex < #state.timeline and currentTime >= state.timeline[currentIndex + 1].RelativeTimestamp do
            currentIndex = currentIndex + 1
        end

        if currentIndex >= #state.timeline then
            if state.isAutoWalk then
                playbackState = "RETURNING_TO_START"
                stateChanged = true
                timeoutTimer = tick() + 30
                updateStatus("WALKING TO START")
            else
                stopPlayback(false)
            end
            return
        end

        local currentNode = state.timeline[currentIndex]
        local nextNode = state.timeline[currentIndex + 1]

        local timeDiff = nextNode.RelativeTimestamp - currentNode.RelativeTimestamp
        local alpha = 0
        if timeDiff > 0 then
            alpha = math.clamp((currentTime - currentNode.RelativeTimestamp) / timeDiff, 0, 1)
        end

        if currentNode.WalkSpeed then
            Humanoid.WalkSpeed = currentNode.WalkSpeed
        end

        if currentNode.Jump and lastJumpConsumedIndex ~= currentIndex then
            lastJumpConsumedIndex = currentIndex
            Humanoid.Jump = true
        end

        local targetTime = currentTime + lookAheadTime
        local lookTarget = getInterpolatedPosition(targetTime, currentIndex)
        local currentPos = RootPart.Position

        local tangent = lookTarget - currentPos
        local horizontalTangent = Vector3.new(tangent.X, 0, tangent.Z)

        if horizontalTangent.Magnitude > 0.001 then
            horizontalTangent = horizontalTangent.Unit
        else
            local nextDir = nextNode.Position - currentNode.Position
            local horizontalNext = Vector3.new(nextDir.X, 0, nextDir.Z)
            horizontalTangent = horizontalNext.Magnitude > 0.001 and horizontalNext.Unit or Vector3.zero
        end

        local pathPos = currentNode.Position:Lerp(nextNode.Position, alpha)
        local correction = pathPos - currentPos
        local horizontalCorrection = Vector3.new(correction.X, 0, correction.Z)
        local moveDir = horizontalTangent

        if horizontalCorrection.Magnitude > 0.35 then
            local correctionWeight = math.clamp(horizontalCorrection.Magnitude / maxCorrectionDistance, 0.08, 0.35)
            local blended = horizontalTangent * (1 - correctionWeight) + horizontalCorrection.Unit * correctionWeight
            if blended.Magnitude > 0.001 then
                moveDir = blended.Unit
            end
        end

        if moveDir.Magnitude > 0.001 then
            Humanoid:Move(moveDir, false)
        else
            Humanoid:Move(Vector3.zero, false)
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
rebuildFullRoute()
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
for i = state.cutStart, state.cutEnd do
table.insert(newTimeline, state.timeline[i])
end
state.timeline = normalizeTimeline(newTimeline)
rebuildFullRoute()
state.cutStart = 1
state.cutEnd = #state.timeline
updateStatus("CUT APPLIED")
end
end)

createBtn("PUT TOGETHER", 9, function()
local base = state.savedFiles[state.selectedFile]
if base and base.timeline and #base.timeline > 0 then
local merged = cloneTimeline(base.timeline)
local offsetTime = merged[#merged].RelativeTimestamp + 0.033

for _, node in ipairs(state.timeline) do  
        local clonedNode = cloneTimeline({node})[1]  
        clonedNode.RelativeTimestamp = offsetTime + node.RelativeTimestamp  
        clonedNode.Timestamp = merged[1].Timestamp + clonedNode.RelativeTimestamp  
        table.insert(merged, clonedNode)  
    end  
    state.timeline = normalizeTimeline(merged)  
    rebuildFullRoute()  
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
rebuildFullRoute()
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
local folder = workspace:FindFirstChild("KNIGHTXORZ_ROUTE_V437")
if folder then
for _, part in ipairs(folder:GetChildren()) do
if part.Name == "VisualNode" or part.Name == "GroundMarker" then
part.Transparency = state.lineVisible and (part.Name == "GroundMarker" and 0.3 or 0) or 1
end
end
end
end)
