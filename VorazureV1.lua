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
    memoryStorage = {},
    playbackOriginalAnchored = false,
    playbackPause = nil,
    playbackResume = nil,
    playbackCancel = nil
}

local premiumColorSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CFG.LineColor),
    ColorSequenceKeypoint.new(0.5, CFG.AccentColor),
    ColorSequenceKeypoint.new(1, CFG.LineColor)
})

local function applyAnimatedGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = premiumColorSeq
    gradient.Rotation = 45
    gradient.Parent = parent

    local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(gradient, tweenInfo, {Offset = Vector2.new(0.8, 0.8)})
    tween:Play()
    return gradient
end

local function captureAnimationSnapshot()
    local snapshot = {}
    if not Humanoid then return snapshot end

    local ok, tracks = pcall(function()
        return Humanoid:GetPlayingAnimationTracks()
    end)
    if not ok or type(tracks) ~= "table" then return snapshot end

    for _, track in ipairs(tracks) do
        local animationId = ""
        pcall(function()
            if track.Animation then
                animationId = track.Animation.AnimationId or ""
            end
        end)

        if animationId ~= "" then
            table.insert(snapshot, {
                AnimationId = animationId,
                TimePosition = tonumber(track.TimePosition) or 0,
                Speed = tonumber(track.Speed) or 1,
                Weight = tonumber(track.WeightCurrent) or 1,
                Looped = track.Looped == true,
                IsPlaying = track.IsPlaying == true
            })
        end
    end
    return snapshot
end

local function cloneAnimations(list)
    local out = {}
    if type(list) ~= "table" then return out end
    for _, a in ipairs(list) do
        if type(a) == "table" and a.AnimationId then
            table.insert(out, {
                AnimationId = a.AnimationId,
                TimePosition = tonumber(a.TimePosition) or 0,
                Speed = tonumber(a.Speed) or 1,
                Weight = tonumber(a.Weight) or 1,
                Looped = a.Looped == true,
                IsPlaying = a.IsPlaying == true
            })
        end
    end
    return out
end

local animationCache = {}

local function getAnimationTrack(animationId)
    if not isCharacterAlive() or animationId == "" then return nil end

    local cached = animationCache[animationId]
    if cached and cached.Parent then return cached end

    local animation = Instance.new("Animation")
    animation.AnimationId = animationId

    local ok, track = pcall(function()
        return Humanoid:LoadAnimation(animation)
    end)

    animation:Destroy()

    if ok and track then
        animationCache[animationId] = track
        return track
    end
    return nil
end

local function applyAnimationSnapshot(snapshot, segmentProgress)
    if type(snapshot) ~= "table" or not isCharacterAlive() then return end

    local desired = {}
    for _, a in ipairs(snapshot) do
        if a.AnimationId and a.AnimationId ~= "" then
            desired[a.AnimationId] = a
            local track = getAnimationTrack(a.AnimationId)

            if track then
                pcall(function() track.Looped = a.Looped == true end)

                if a.IsPlaying then
                    if not track.IsPlaying then
                        track:Play(0.05, math.max(a.Weight or 1, 0), math.max(a.Speed or 1, 0.01))
                        pcall(function()
                            local targetTime = (a.TimePosition or 0) + (segmentProgress or 0)
                            track.TimePosition = math.max(targetTime, 0)
                        end)
                    else
                        track:AdjustSpeed(math.max(a.Speed or 1, 0.01))
                        track:AdjustWeight(math.max(a.Weight or 1, 0), 0.05)
                        if segmentProgress and math.abs(track.TimePosition - ((a.TimePosition or 0) + segmentProgress)) > 0.15 then
                            pcall(function()
                                track.TimePosition = math.max((a.TimePosition or 0) + segmentProgress, 0)
                            end)
                        end
                    end
                elseif track.IsPlaying then
                    track:Stop(0.05)
                end
            end
        end
    end

    for id, track in pairs(animationCache) do
        if track and track.Parent and not desired[id] and track.IsPlaying then
            pcall(function() track:Stop(0.05) end)
        end
    end
end

local function clearAnimationCache()
    for id, track in pairs(animationCache) do
        if track then
            pcall(function()
                track:Stop(0)
                track:Destroy()
            end)
        end
        animationCache[id] = nil
    end
end

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
            MovementDirection = node.MovementDirection,
            Animations = cloneAnimations(node.Animations)
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

                table.insert(encodedTimeline, {
                    C = comps,
                    P = {node.Position.X, node.Position.Y, node.Position.Z},
                    T = node.Timestamp,
                    J = node.Jump or false,
                    W = node.WalkSpeed or 16,
                    S = tostring(node.HumanoidState or Enum.HumanoidStateType.Running),
                    D = node.MovementDirection and {node.MovementDirection.X, node.MovementDirection.Y, node.MovementDirection.Z} or {0, 0, 0},
                    A = cloneAnimations(node.Animations)
                })
            end
            exportData[tostring(slot)] = {timeline = encodedTimeline}
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

    if not decoded and next(state.memoryStorage) ~= nil then decoded = state.memoryStorage end  

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
                      
                    local parsedState = Enum.HumanoidStateType.Running
                    if node.S then
                        for _, enumVal in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                            if tostring(enumVal) == node.S or enumVal.Name == node.S then
                                parsedState = enumVal
                                break
                            end
                        end
                    end

                    if pos then  
                        table.insert(decodedTimeline, {  
                            CFrame = targetCf,  
                            Position = pos,  
                            Timestamp = node.T,  
                            Jump = node.J or false,  
                            WalkSpeed = node.W or 16,  
                            HumanoidState = parsedState,  
                            MovementDirection = dir,
                            Animations = cloneAnimations(node.A)
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenMenu = Instance.new("ImageButton")
OpenMenu.Name = "OpenMenu"
OpenMenu.Size = UDim2.fromOffset(58, 58)
OpenMenu.Position = UDim2.new(0.05, 0, 0.5, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenMenu.ZIndex = 10
OpenMenu.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(255, 255, 255)
OpenStroke.Parent = OpenMenu
applyAnimatedGradient(OpenStroke)

local IconImage = Instance.new("ImageLabel")
IconImage.Name = "Icon"
IconImage.Size = UDim2.new(0.8, 0, 0.8, 0)
IconImage.Position = UDim2.new(0.1, 0, 0.1, 0)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxassetid://101640388423900"
IconImage.ZIndex = 11
IconImage.Parent = OpenMenu

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(620, 365)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -182.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0
MainScale.Parent = MainFrame

-- Premium MainFrame Border
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Parent = MainFrame
applyAnimatedGradient(Stroke)

-- Dragging Logic for OpenMenu
local openMoved = false
local openDragging, openDragStart, openStartPos

table.insert(currentConnections, OpenMenu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openDragging = true
        openDragStart = input.Position
        openStartPos = OpenMenu.Position
        openMoved = false
        TweenService:Create(OpenMenu, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Size = UDim2.fromOffset(52, 52)}):Play()
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
        TweenService:Create(OpenMenu, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(58, 58)}):Play()
    end
end))

table.insert(currentConnections, OpenMenu.Activated:Connect(function()
    if openMoved then
        openMoved = false
        return
    end
    if MainFrame.Visible then
        TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0}):Play()
        task.delay(0.25, function() MainFrame.Visible = false end)
    else
        MainFrame.Visible = true
        MainScale.Scale = 0.8
        TweenService:Create(MainScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end))

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ALDO KNIGHTXORZ V4.37 PRODUCTION READY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.ZIndex = 3
Title.Parent = MainFrame
applyAnimatedGradient(Title)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.Text = "Status: IDLE | File: 1 | Cut: 1-1"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.ZIndex = 3
StatusLabel.Parent = MainFrame

local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(1, -20, 1, -75)
ControlFrame.Position = UDim2.new(0, 10, 0, 65)
ControlFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
ControlFrame.BorderSizePixel = 0
ControlFrame.ZIndex = 3
ControlFrame.Parent = MainFrame

local ControlCorner = Instance.new("UICorner")
ControlCorner.CornerRadius = UDim.new(0, 10)
ControlCorner.Parent = ControlFrame

local ControlStroke = Instance.new("UIStroke")
ControlStroke.Thickness = 1
ControlStroke.Color = Color3.fromRGB(55, 55, 75)
ControlStroke.Parent = ControlFrame

local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Name = "ActionContainer"
ScrollingContainer.Size = UDim2.new(1, -12, 1, -12)
ScrollingContainer.Position = UDim2.fromOffset(6, 6)
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.BorderSizePixel = 0
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.ZIndex = 4
ScrollingContainer.Parent = ControlFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.fromOffset(120, 39)
UIGrid.CellPadding = UDim2.fromOffset(8, 8)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder
UIGrid.Parent = ScrollingContainer

-- File Modal Frame Setup
local FileFrame = Instance.new("Frame")
FileFrame.Name = "FileFrame"
FileFrame.Size = UDim2.fromOffset(285, 300)
FileFrame.Position = UDim2.new(0.5, -142.5, 0.5, -150)
FileFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
FileFrame.BorderSizePixel = 0
FileFrame.Visible = false
FileFrame.ZIndex = 20
FileFrame.Parent = MainFrame

local FileScale = Instance.new("UIScale")
FileScale.Scale = 1
FileScale.Parent = FileFrame

local FileCorner = Instance.new("UICorner")
FileCorner.CornerRadius = UDim.new(0, 12)
FileCorner.Parent = FileFrame

local FileStroke = Instance.new("UIStroke")
FileStroke.Thickness = 2
FileStroke.Color = Color3.fromRGB(255, 255, 255)
FileStroke.Parent = FileFrame
applyAnimatedGradient(FileStroke)

local FileTitle = Instance.new("TextLabel")
FileTitle.Name = "FileTitle"
FileTitle.Size = UDim2.new(1, -48, 0, 34)
FileTitle.Position = UDim2.fromOffset(10, 4)
FileTitle.BackgroundTransparency = 1
FileTitle.Text = "FILES"
FileTitle.TextColor3 = CFG.LineColor
FileTitle.Font = Enum.Font.GothamBold
FileTitle.TextSize = 13
FileTitle.TextXAlignment = Enum.TextXAlignment.Left
FileTitle.ZIndex = 21
FileTitle.Parent = FileFrame

local FileClose = Instance.new("TextButton")
FileClose.Name = "FileClose"
FileClose.Size = UDim2.fromOffset(32, 28)
FileClose.Position = UDim2.new(1, -38, 0, 7)
FileClose.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FileClose.Text = "X"
FileClose.TextColor3 = Color3.fromRGB(230, 230, 230)
FileClose.Font = Enum.Font.GothamBold
FileClose.TextSize = 12
FileClose.ZIndex = 21
FileClose.Parent = FileFrame

local FileCloseCorner = Instance.new("UICorner")
FileCloseCorner.CornerRadius = UDim.new(0, 6)
FileCloseCorner.Parent = FileClose

local FileContainer = Instance.new("ScrollingFrame")
FileContainer.Name = "FileContainer"
FileContainer.Size = UDim2.new(1, -20, 1, -48)
FileContainer.Position = UDim2.fromOffset(10, 40)
FileContainer.BackgroundTransparency = 1
FileContainer.BorderSizePixel = 0
FileContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FileContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
FileContainer.ScrollBarThickness = 4
FileContainer.ZIndex = 21
FileContainer.Parent = FileFrame

local FileLayout = Instance.new("UIListLayout")
FileLayout.Padding = UDim.new(0, 7)
FileLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FileLayout.SortOrder = Enum.SortOrder.LayoutOrder
FileLayout.Parent = FileContainer

local function updateStatus(text)
    if not ScreenGui or not ScreenGui.Parent then return end
    local frame = ScreenGui:FindFirstChild("MainFrame")
    if frame then
        local lbl = frame:FindFirstChild("StatusLabel")
        if lbl then
            lbl.Text = "Status: " .. text .. " | File: " .. state.selectedFile .. " | Cut: " .. state.cutStart .. "-" .. state.cutEnd
            
            if text == "IDLE" then lbl.TextColor3 = Color3.fromRGB(150, 150, 170)
            elseif text == "RECORDING" then lbl.TextColor3 = Color3.fromRGB(255, 50, 80)
            elseif text == "PLAYING" or text == "AUTO WALK" then lbl.TextColor3 = CFG.LineColor
            elseif text == "PAUSED" then lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
            else lbl.TextColor3 = CFG.AccentColor end
        end
    end
end

local function createBtn(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(120, 39)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.ZIndex = 5
    btn.Parent = ScrollingContainer

    local btnScale = Instance.new("UIScale", btn)

    local btnCorner = Instance.new("UICorner")    
    btnCorner.CornerRadius = UDim.new(0, 8)    
    btnCorner.Parent = btn    
          
    local btnStroke = Instance.new("UIStroke")    
    btnStroke.Thickness = 1    
    btnStroke.Color = Color3.fromRGB(60, 60, 80)    
    btnStroke.Parent = btn    

    table.insert(currentConnections, btn.Activated:Connect(function()    
        TweenService:Create(btnScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.92}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CFG.AccentColor}):Play()    
        task.delay(0.15, function()
            if btn and btn.Parent then
                TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Scale = 1}):Play()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
            end
        end)
        task.defer(callback)    
    end))    
    return btn
end

local function createFileBtn(textValue, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "FileButton_" .. tostring(order)
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = textValue
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.ZIndex = 22
    btn.Parent = FileContainer

    local btnScale = Instance.new("UIScale", btn)

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(60, 60, 80)
    btnStroke.Parent = btn

    table.insert(currentConnections, btn.Activated:Connect(function()
        TweenService:Create(btnScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.95}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CFG.AccentColor}):Play()
        task.delay(0.15, function()
            if btn and btn.Parent then
                TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Scale = 1}):Play()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
            end
        end)
        task.defer(callback)
    end))
    return btn
end

local FileButton = createBtn("FILE", 10, function()
    if FileFrame.Visible then
        TweenService:Create(FileScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0}):Play()
        task.delay(0.2, function() FileFrame.Visible = false end)
    else
        FileFrame.Visible = true
        FileScale.Scale = 0.8
        TweenService:Create(FileScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end)
FileButton.Name = "FileButton"

table.insert(currentConnections, FileClose.Activated:Connect(function()
    TweenService:Create(FileScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = 0}):Play()
    task.delay(0.2, function() FileFrame.Visible = false end)
end))

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
            MovementDirection = moveDir,
            Animations = captureAnimationSnapshot()
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
                MovementDirection = moveDir,
                Animations = captureAnimationSnapshot()
            })    
            normalizeTimeline(state.timeline)  
            state.cutEnd = #state.timeline  
        end    
    end
end)

stopPlayback = function(manualStop)
    local wasPlaying = state.isPlaying
    state.isPlaying = false
    state.isPaused = false
    state.playbackID = state.playbackID + 1
    if manualStop then
        state.isAutoWalk = false
    end

    if state.playbackCancel then pcall(state.playbackCancel) end

    pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV437_Playback") end)  
        
    if isCharacterAlive() and Humanoid then    
        Humanoid.AutoRotate = true    
        Humanoid:Move(Vector3.zero, true)    
        Humanoid.WalkSpeed = state.originalWalkSpeed
        if wasPlaying then
            RootPart.Anchored = state.playbackOriginalAnchored
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
        end
        clearAnimationCache()
    end    
    updateStatus("IDLE")
end

local function executePlayback()
    if #state.timeline < 2 or state.isPlaying or not isCharacterAlive() then return end
    if state.playbackCancel then pcall(state.playbackCancel) end

    state.isPlaying = true
    state.isPaused = false
    state.playbackID = state.playbackID + 1

    local playbackID = state.playbackID
    local timeline = state.timeline
    local firstNode = timeline[1]
    
    state.originalWalkSpeed = Humanoid.WalkSpeed

    local currentIndex = 1
    local activeTween = nil
    local activeConnection = nil
    local wasAnchored = RootPart.Anchored
    local wasAutoRotate = Humanoid.AutoRotate
    local finished = false
    local paused = false

    state.playbackOriginalAnchored = wasAnchored

    local function disconnectTween()
        if activeConnection then
            pcall(function() activeConnection:Disconnect() end)
            activeConnection = nil
        end
    end

    local function cancelTween()
        disconnectTween()
        if activeTween then
            pcall(function() activeTween:Cancel() end)
            activeTween = nil
        end
    end

    local function restore()
        cancelTween()
        if isCharacterAlive() then
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
            RootPart.Anchored = wasAnchored
            Humanoid.AutoRotate = wasAutoRotate
            Humanoid.WalkSpeed = state.originalWalkSpeed
            Humanoid:Move(Vector3.zero, false)
            clearAnimationCache()
        end
    end

    local function applyRecordedNode(node, duration)
        if not isCharacterAlive() or not node then return end
        if node.WalkSpeed then Humanoid.WalkSpeed = tonumber(node.WalkSpeed) or Humanoid.WalkSpeed end
        
        Humanoid.AutoRotate = false

        if node.Jump then
            pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end

        if node.Animations then
            applyAnimationSnapshot(node.Animations, 0)
        end
    end

    local function finishPlayback()
        if finished then return end
        finished = true
        cancelTween()

        if not isCharacterAlive() then
            state.isPlaying = false
            state.isPaused = false
            return
        end

        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero

        if state.isAutoWalk then
            local finalNode = timeline[#timeline]
            local startCF = firstNode.CFrame or CFrame.new(firstNode.Position)
            local endCF = finalNode.CFrame or CFrame.new(finalNode.Position)
            local distance = (endCF.Position - startCF.Position).Magnitude
            local speed = math.max(tonumber(finalNode.WalkSpeed) or state.originalWalkSpeed or 16, 1)

            RootPart.Anchored = true
            Humanoid.AutoRotate = false
            Humanoid:Move(Vector3.zero, false)

            if distance <= 0.001 then
                RootPart.AssemblyLinearVelocity = Vector3.zero
                RootPart.AssemblyAngularVelocity = Vector3.zero
                RootPart.Anchored = wasAnchored
                Humanoid.AutoRotate = wasAutoRotate
                state.isPlaying = false
                state.isPaused = false
                state.playbackID = state.playbackID + 1
                updateStatus("IDLE")
                if state.isAutoWalk then task.defer(executePlayback) end
                return
            end

            local duration = math.max(distance / speed, 1 / 30)
            activeTween = TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = startCF})
            activeConnection = activeTween.Completed:Connect(function(playbackState)
                disconnectTween()
                activeTween = nil
                if playbackState ~= Enum.PlaybackState.Completed then return end
                if not state.isPlaying or state.playbackID ~= playbackID then return end

                RootPart.AssemblyLinearVelocity = Vector3.zero
                RootPart.AssemblyAngularVelocity = Vector3.zero
                RootPart.Anchored = wasAnchored
                Humanoid.AutoRotate = wasAutoRotate

                state.isPlaying = false
                state.isPaused = false
                state.playbackID = state.playbackID + 1
                updateStatus("IDLE")

                if state.isAutoWalk then task.defer(executePlayback) end
            end)
            activeTween:Play()
            updateStatus("WALKING TO START")
            return
        end

        state.isPlaying = false
        state.isPaused = false
        state.playbackID = state.playbackID + 1
        restore()
        updateStatus("IDLE")
    end

    local function playSegment(index)
        if not state.isPlaying or state.playbackID ~= playbackID then return end
        if not isCharacterAlive() then
            state.isPlaying = false
            return
        end

        if index >= #timeline then
            currentIndex = #timeline
            applyRecordedNode(timeline[currentIndex], 0)
            finishPlayback()
            return
        end

        currentIndex = index
        local node = timeline[index]
        local nextNode = timeline[index + 1]
        local toCF = nextNode.CFrame or CFrame.new(nextNode.Position)

        local t0 = tonumber(node.RelativeTimestamp) or 0
        local t1 = tonumber(nextNode.RelativeTimestamp) or t0
        local duration = math.max(t1 - t0, 1 / 240)

        applyRecordedNode(node, duration)

        RootPart.Anchored = true
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero

        activeTween = TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = toCF})
        activeConnection = activeTween.Completed:Connect(function(playbackState)
            disconnectTween()
            activeTween = nil
            if playbackState ~= Enum.PlaybackState.Completed then return end
            if not state.isPlaying or state.playbackID ~= playbackID then return end
            
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
            
            playSegment(index + 1)
        end)
        activeTween:Play()
    end

    local function beginStartTransition()
        if not isCharacterAlive() then
            state.isPlaying = false
            return
        end

        currentIndex = 1
        finished = false
        paused = false

        local startCF = firstNode.CFrame or CFrame.new(firstNode.Position)
        local currentCF = RootPart.CFrame

        RootPart.Anchored = true
        Humanoid.AutoRotate = false
        Humanoid:Move(Vector3.zero, false)
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero

        local distance = (currentCF.Position - startCF.Position).Magnitude
        local dot = math.clamp(currentCF.LookVector:Dot(startCF.LookVector), -1, 1)
        local rotationDifference = math.acos(dot)

        if distance <= 0.001 and rotationDifference <= 0.000001 then
            applyRecordedNode(firstNode, 0)
            updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
            playSegment(1)
            return
        end

        local speed = math.max(tonumber(firstNode.WalkSpeed) or state.originalWalkSpeed or 16, 1)
        local duration = math.max(distance / speed, 1 / 30)

        activeTween = TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = startCF})
        activeConnection = activeTween.Completed:Connect(function(playbackState)
            disconnectTween()
            activeTween = nil
            if playbackState ~= Enum.PlaybackState.Completed then return end
            if not state.isPlaying or state.playbackID ~= playbackID then return end
            if not isCharacterAlive() then
                state.isPlaying = false
                return
            end

            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
            applyRecordedNode(firstNode, 0)
            updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
            playSegment(1)
        end)
        activeTween:Play()
    end

    state.playbackCancel = function()
        state.isPlaying = false
        state.isPaused = false
        state.playbackID = state.playbackID + 1
        state.playbackCancel = nil
        state.playbackPause = nil
        state.playbackResume = nil
        restore()
        updateStatus("IDLE")
    end

    state.playbackPause = function()
        if not state.isPlaying or not activeTween or paused then return end
        paused = true
        state.isPaused = true
        pcall(function() activeTween:Pause() end)
        updateStatus("PAUSED")
    end

    state.playbackResume = function()
        if not state.isPlaying or not activeTween or not paused then return end
        paused = false
        state.isPaused = false
        applyRecordedNode(timeline[currentIndex], 0)
        pcall(function() activeTween:Play() end)
        updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
    end

    RootPart.Anchored = true
    Humanoid.AutoRotate = false
    beginStartTransition()
end

local function toggleAutoWalk()
    if state.isRecording then return end
    state.isAutoWalk = not state.isAutoWalk
    if state.isAutoWalk then
        updateStatus("AUTO WALK")
        if not state.isPlaying then executePlayback() end
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
        if state.playbackPause then state.playbackPause() end
    else
        if state.playbackResume then state.playbackResume() end
    end
end)

createBtn("AUTO WALK", 4, function() toggleAutoWalk() end)
createBtn("STOP", 5, function() stopPlayback(true) end)

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
    createFileBtn("FILE " .. i, i, function()
        state.selectedFile = i
        updateStatus("IDLE")
    end)
end

createFileBtn("SAVE FILE", 7, function()
    if #state.timeline > 0 then
        normalizeTimeline(state.timeline)
        state.savedFiles[state.selectedFile] = {timeline = cloneTimeline(state.timeline)}
        saveToDisk()
        updateStatus("SAVED FILE " .. state.selectedFile)
    end
end)

createFileBtn("LOAD FILE", 8, function()
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
