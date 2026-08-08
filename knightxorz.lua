-- [[ ALDO KNIGHTXORZ V4.44 FULL VERSION - ULTIMATE SMOOTH FIX ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- CLEAN OLD VERSION
----------------------------------------------------------------
pcall(function()
	if _G.AldoKnightXorzV444_Cleanup then
		_G.AldoKnightXorzV444_Cleanup()
	end
end)

pcall(function()
	RunService:UnbindFromRenderStep("AldoKnightXorzV444_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV444_Playback")
end)

----------------------------------------------------------------
-- CHARACTER & STATE
----------------------------------------------------------------
local Character, RootPart, Humanoid, Animator
local stopPlayback

local CFG = {
	NodeInterval = 1 / 60,
	MinDistance = 0.001,
	PlaybackSpeed = 1,
	EndTolerance = 0.001,
	InterpolationPower = 1,
	LineColor = Color3.fromRGB(0, 255, 255),
	AccentColor = Color3.fromRGB(170, 0, 255),
	ButtonColor = Color3.fromRGB(30, 30, 40),
	RouteFolderName = "KNIGHTXORZ_ROUTE_V444",
	SaveFileName = "ALDO_KNIGHTXORZ_V4_44.json",
	OpenButtonSize = 58
}

local state = {
	isRecording = false,
	isPlaying = false,
	isPaused = false,
	isAutoWalk = false,
	kinematicActive = false,
	playbackID = 0,
	timeline = {},
	visualNodes = {},
	lineVisible = true,
	selectedFile = 1,
	savedFiles = {},
	memoryStorage = {},
	startTime = 0,
	lastRecordTime = 0,
	lastJumpState = false,
	cutStart = 1,
	cutEnd = 1,
	playbackTime = 0
}

local currentConnections = {}
local function addConnection(connection)
	if connection then
		table.insert(currentConnections, connection)
	end
	return connection
end

local function setupCharacter(char)
	if stopPlayback then
		pcall(function() stopPlayback(true) end)
	end
	Character = char
	Humanoid = char:WaitForChild("Humanoid", 10)
	RootPart = char:WaitForChild("HumanoidRootPart", 10)
	Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
end

if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end

addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
	setupCharacter(char)
end))

local function isCharacterAlive()
	return Character and Character.Parent and RootPart and RootPart.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0
end

local function normalizeTimeline(timeline)
	if not timeline or #timeline == 0 then return timeline end
	local base = timeline[1].Timestamp or 0
	for _, node in ipairs(timeline) do
		node.RelativeTimestamp = math.max(0, (node.Timestamp or base) - base)
	end
	return timeline
end

local function cloneTimeline(source)
	local result = {}
	for _, node in ipairs(source or {}) do
		table.insert(result, {
			CFrame = node.CFrame,
			Position = node.Position,
			Timestamp = node.Timestamp or 0,
			RelativeTimestamp = node.RelativeTimestamp or 0,
			Jump = node.Jump == true,
			WalkSpeed = node.WalkSpeed or 16,
			HumanoidState = node.HumanoidState,
			MovementDirection = node.MovementDirection or Vector3.zero
		})
	end
	return result
end

----------------------------------------------------------------
-- VISUAL ROUTE SYSTEM
----------------------------------------------------------------
local function getRouteFolder()
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = CFG.RouteFolderName
		folder.Parent = workspace
	end
	return folder
end

local function clearVisuals()
	for _, object in ipairs(state.visualNodes) do
		if object and object.Parent then object:Destroy() end
	end
	state.visualNodes = {}
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)
	if folder then folder:ClearAllChildren() end
end

local function createRouteSegment(p1, p2)
	if not p1 or not p2 then return end
	local offset = p2 - p1
	local distance = offset.Magnitude
	if distance < CFG.MinDistance then return end

	local folder = getRouteFolder()
	local line = Instance.new("Part")
	line.Name = "VisualNode"
	line.Anchored = true
	line.CanCollide = false
	line.CanTouch = false
	line.CanQuery = false
	line.CastShadow = false
	line.Material = Enum.Material.Neon
	line.Color = CFG.LineColor
	line.Size = Vector3.new(0.055, 0.055, distance)
	line.CFrame = CFrame.lookAt(p1:Lerp(p2, 0.5), p2)
	line.Transparency = state.lineVisible and 0 or 1
	line.Parent = folder

	table.insert(state.visualNodes, line)
end

local function rebuildRoute()
	clearVisuals()
	if #state.timeline < 2 then return end
	local previousPosition
	for _, node in ipairs(state.timeline) do
		if node.Position then
			if previousPosition then
				createRouteSegment(previousPosition, node.Position)
			end
			previousPosition = node.Position
		end
	end
end

----------------------------------------------------------------
-- SAVE & LOAD
----------------------------------------------------------------
local function saveToDisk()
	local exportData = {}
	for slot, data in pairs(state.savedFiles) do
		if data and data.timeline and #data.timeline > 0 then
			local encoded = {}
			for _, node in ipairs(data.timeline) do
				if node.CFrame and node.Position then
					local comps = {node.CFrame:GetComponents()}
					local rounded = {}
					for _, v in ipairs(comps) do table.insert(rounded, math.round(v * 1000) / 1000) end
					table.insert(encoded, {
						C = rounded,
						P = {math.round(node.Position.X*100)/100, math.round(node.Position.Y*100)/100, math.round(node.Position.Z*100)/100},
						T = math.round((node.Timestamp or 0)*1000)/1000,
						J = node.Jump == true,
						W = node.WalkSpeed or 16,
						S = tostring(node.HumanoidState or Enum.HumanoidStateType.Running),
						D = node.MovementDirection and {node.MovementDirection.X, node.MovementDirection.Y, node.MovementDirection.Z} or {0,0,0}
					})
				end
			end
			exportData[tostring(slot)] = {timeline = encoded}
		end
	end
	state.memoryStorage = exportData
	pcall(function()
		if typeof(writefile) == "function" then
			writefile(CFG.SaveFileName, HttpService:JSONEncode(exportData))
		end
	end)
end

local function loadFromDisk()
	local decoded
	pcall(function()
		if typeof(readfile) == "function" then
			local success, content = pcall(function() return readfile(CFG.SaveFileName) end)
			if success and content then
				decoded = HttpService:JSONDecode(content)
			end
		end
	end)
	if not decoded and next(state.memoryStorage) then decoded = state.memoryStorage end
	if type(decoded) ~= "table" then return end

	for slot, data in pairs(decoded) do
		if data and type(data.timeline) == "table" then
			local timeline = {}
			for _, node in ipairs(data.timeline) do
				local cf, pos
				if node.C and #node.C == 12 then
					pcall(function() cf = CFrame.new(table.unpack(node.C)) end)
					if cf then pos = cf.Position end
				elseif node.P and #node.P == 3 then
					pos = Vector3.new(node.P[1], node.P[2], node.P[3])
					cf = CFrame.new(pos)
				end
				if pos and cf then
					table.insert(timeline, {
						CFrame = cf, Position = pos, Timestamp = tonumber(node.T) or 0,
						RelativeTimestamp = 0, Jump = node.J == true, WalkSpeed = tonumber(node.W) or 16,
						HumanoidState = node.S, MovementDirection = Vector3.zero
					})
				end
			end
			normalizeTimeline(timeline)
			state.savedFiles[tonumber(slot) or slot] = {timeline = timeline}
		end
	end
end
loadFromDisk()

----------------------------------------------------------------
-- GUI SETUP
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AldoKnightXorzV444Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local OpenMenu = Instance.new("ImageButton", ScreenGui)
OpenMenu.Size = UDim2.fromOffset(CFG.OpenButtonSize, CFG.OpenButtonSize)
OpenMenu.Position = UDim2.new(0.05, 0, 0.5, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenMenu.BackgroundTransparency = 0.2
OpenMenu.ZIndex = 20
Instance.new("UICorner", OpenMenu).CornerRadius = UDim.new(0, 8)
local OpenStroke = Instance.new("UIStroke", OpenMenu)
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(255, 255, 255)

local IconImage = Instance.new("ImageLabel", OpenMenu)
IconImage.Size = UDim2.new(0.8, 0, 0.8, 0)
IconImage.Position = UDim2.new(0.1, 0, 0.1, 0)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxassetid://101640388423900"
IconImage.ZIndex = 21

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.fromOffset(550, 325)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -162)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Visible = false
MainFrame.ZIndex = 5
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = CFG.AccentColor

-- Draggable Open Button
local openDragging, openMoved, openDragStart, openStartPos = false, false, nil, nil
addConnection(OpenMenu.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		openDragging = true; openMoved = false; openDragStart = input.Position; openStartPos = OpenMenu.Position
	end
end))
addConnection(UserInputService.InputChanged:Connect(function(input)
	if not openDragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - openDragStart
		if delta.Magnitude > 8 then
			openMoved = true
			OpenMenu.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
		end
	end
end))
addConnection(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then openDragging = false end
end))
addConnection(OpenMenu.Activated:Connect(function()
	if openMoved then openMoved = false; return end
	MainFrame.Visible = not MainFrame.Visible
end))

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ALDO KNIGHTXORZ V4.44 FULL (ULTIMATE SMOOTH)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.Text = "Status: IDLE | File: 1"
StatusLabel.TextColor3 = CFG.LineColor
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.BackgroundTransparency = 1

local ScrollingContainer = Instance.new("ScrollingFrame", MainFrame)
ScrollingContainer.Size = UDim2.new(1, -20, 1, -75)
ScrollingContainer.Position = UDim2.new(0, 10, 0, 65)
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.BorderSizePixel = 0
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIGrid = Instance.new("UIGridLayout", ScrollingContainer)
UIGrid.CellSize = UDim2.fromOffset(120, 39)
UIGrid.CellPadding = UDim2.fromOffset(8, 8)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder

local function updateStatus(text)
	if StatusLabel and StatusLabel.Parent then
		StatusLabel.Text = "Status: " .. tostring(text) .. " | File: " .. tostring(state.selectedFile) .. " | Cut: " .. tostring(state.cutStart) .. "-" .. tostring(state.cutEnd)
	end
end

local function createButton(text, order, callback)
	local button = Instance.new("TextButton", ScrollingContainer)
	button.Size = UDim2.fromOffset(120, 39)
	button.BackgroundColor3 = CFG.ButtonColor
	button.Text = text
	button.TextColor3 = Color3.fromRGB(230, 230, 230)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 11
	button.AutoButtonColor = false
	button.LayoutOrder = order
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
	local stroke = Instance.new("UIStroke", button)
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(70, 70, 90)

	addConnection(button.Activated:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.07), {BackgroundColor3 = CFG.AccentColor}):Play()
		task.defer(function()
			pcall(callback)
			if button.Parent then
				TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = CFG.ButtonColor}):Play()
			end
		end)
	end))
	return button
end

----------------------------------------------------------------
-- KINEMATIC ENGINE (FIX UTAMA JITTER/PATAH-PATAH)
----------------------------------------------------------------
local function enableKinematic()
	if not isCharacterAlive() then return false end
	if state.kinematicActive then return true end

	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false

	RootPart.Anchored = true
	RootPart.CanCollide = false
	RootPart.CanTouch = false
	RootPart.CanQuery = false
	
	RootPart.AssemblyLinearVelocity = Vector3.zero
	RootPart.AssemblyAngularVelocity = Vector3.zero

	state.kinematicActive = true
	return true
end

local function disableKinematic()
	if not state.kinematicActive then return end
	if RootPart and RootPart.Parent then
		RootPart.Anchored = false
		RootPart.CanCollide = true
		RootPart.CanTouch = true
		RootPart.CanQuery = true
	end
	if Humanoid and Humanoid.Parent then
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
	end
	state.kinematicActive = false
end

----------------------------------------------------------------
-- RECORDING SYSTEM
----------------------------------------------------------------
local function beginRecording()
	if not isCharacterAlive() then return end
	if state.isPlaying then stopPlayback(true) end
	state.isRecording = true
	state.timeline = {}
	state.startTime = os.clock()
	state.lastRecordTime = 0
	state.lastJumpState = false
	clearVisuals()
	updateStatus("RECORDING")
end

local function finishRecording()
	state.isRecording = false
	normalizeTimeline(state.timeline)
	state.cutStart = 1
	state.cutEnd = math.max(1, #state.timeline)
	rebuildRoute()
	updateStatus("IDLE")
end

RunService:BindToRenderStep("AldoKnightXorzV444_Record", Enum.RenderPriority.Character.Value, function()
	if not state.isRecording or not isCharacterAlive() then return end
	local now = os.clock()
	if now - state.lastRecordTime < CFG.NodeInterval then return end
	state.lastRecordTime = now

	local cf = RootPart.CFrame
	local pos = cf.Position
	local timestamp = now - state.startTime
	local humanoidState = Humanoid:GetState()
	local jumping = humanoidState == Enum.HumanoidStateType.Jumping or humanoidState == Enum.HumanoidStateType.Freefall
	local jumpTrigger = jumping and not state.lastJumpState
	state.lastJumpState = jumping

	if #state.timeline == 0 then
		table.insert(state.timeline, {
			CFrame = cf, Position = pos, Timestamp = timestamp, RelativeTimestamp = 0,
			Jump = jumpTrigger, WalkSpeed = Humanoid.WalkSpeed, HumanoidState = humanoidState
		})
		return
	end

	local prev = state.timeline[#state.timeline]
	if (pos - prev.Position).Magnitude >= CFG.MinDistance or jumpTrigger then
		createRouteSegment(prev.Position, pos)
		table.insert(state.timeline, {
			CFrame = cf, Position = pos, Timestamp = timestamp, RelativeTimestamp = 0,
			Jump = jumpTrigger, WalkSpeed = Humanoid.WalkSpeed, HumanoidState = humanoidState
		})
		normalizeTimeline(state.timeline)
		state.cutEnd = #state.timeline
	end
end)

----------------------------------------------------------------
-- PLAYBACK & INTERPOLATION ENGINE
----------------------------------------------------------------
local function getPlaybackCFrame(timeline, time)
	local count = #timeline
	if count == 0 then return nil end
	if count == 1 or time <= 0 then return timeline[1].CFrame end
	local last = timeline[count]
	if time >= last.RelativeTimestamp then return last.CFrame end

	local low, high = 1, count
	while low <= high do
		local mid = math.floor((low + high) / 2)
		if timeline[mid].RelativeTimestamp <= time then
			low = mid + 1
		else
			high = mid - 1
		end
	end

	local idxA = math.clamp(high, 1, count - 1)
	local idxB = idxA + 1
	local nA, nB = timeline[idxA], timeline[idxB]
	local duration = nB.RelativeTimestamp - nA.RelativeTimestamp
	if duration <= 0 then return nB.CFrame end

	local alpha = math.clamp((time - nA.RelativeTimestamp) / duration, 0, 1)
	if CFG.InterpolationPower > 0 then
		alpha = alpha * alpha * (3 - 2 * alpha)
	end
	return nA.CFrame:Lerp(nB.CFrame, alpha)
end

stopPlayback = function(manualStop)
	state.isPlaying = false
	state.isPaused = false
	state.playbackID += 1
	pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV444_Playback") end)
	disableKinematic()
	if manualStop then state.isAutoWalk = false end
	state.playbackTime = 0
	if isCharacterAlive() then
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end
	updateStatus("IDLE")
end

local function executePlayback()
	if state.isRecording or state.isPlaying or not isCharacterAlive() then return end
	if #state.timeline < 2 then updateStatus("NO ROUTE"); return end

	normalizeTimeline(state.timeline)
	if not enableKinematic() then updateStatus("ERROR"); return end

	state.isPlaying = true
	state.isPaused = false
	state.playbackID += 1
	local pID = state.playbackID
	local timeline = state.timeline
	state.playbackTime = 0

	local totalDuration = timeline[#timeline].RelativeTimestamp
	local startCF = timeline[1].CFrame

	RootPart.CFrame = startCF
	updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")

	pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV444_Playback") end)

	-- MENGGUNAKAN Enum.RenderPriority.Camera.Value AGAR 100% SINKRON DAN MULUS
	RunService:BindToRenderStep("AldoKnightXorzV444_Playback", Enum.RenderPriority.Camera.Value, function(dt)
		if not state.isPlaying or state.playbackID ~= pID then return end
		if not isCharacterAlive() then stopPlayback(false); return end
		if state.isPaused then return end

		dt = math.clamp(dt, 0.001, 0.033)
		state.playbackTime += dt * CFG.PlaybackSpeed

		if state.playbackTime >= totalDuration - CFG.EndTolerance then
			RootPart.CFrame = timeline[#timeline].CFrame
			if state.isAutoWalk then
				state.playbackTime = 0
				RootPart.CFrame = startCF
				return
			else
				stopPlayback(false)
				return
			end
		end

		local targetCF = getPlaybackCFrame(timeline, state.playbackTime)
		if targetCF then
			RootPart.CFrame = targetCF
		end
	end)
end

----------------------------------------------------------------
-- BUTTONS MAPPING
----------------------------------------------------------------
createButton("RECORD START", 1, function()
	if state.isRecording then finishRecording() else beginRecording() end
end)

createButton("PLAY ROUTE", 2, function()
	if state.isRecording then return end
	state.isAutoWalk = false
	if not state.isPlaying then executePlayback() end
end)

createButton("PAUSE / RES", 3, function()
	if not state.isPlaying then return end
	state.isPaused = not state.isPaused
	updateStatus(state.isPaused and "PAUSED" or "PLAYING")
end)

createButton("AUTO WALK", 4, function()
	if state.isRecording then return end
	state.isAutoWalk = not state.isAutoWalk
	updateStatus(state.isAutoWalk and "AUTO WALK ON" or "AUTO WALK OFF")
	if state.isAutoWalk and not state.isPlaying then executePlayback() end
end)

createButton("STOP", 5, function()
	stopPlayback(true)
end)

createButton("<< CUT", 6, function()
	if #state.timeline <= 2 then return end
	state.cutStart = math.clamp(state.cutStart + 1, 1, math.max(1, state.cutEnd - 1))
	updateStatus("CUT CONFIG")
end)

createButton("CUT >>", 7, function()
	if #state.timeline <= 2 then return end
	state.cutEnd = math.clamp(state.cutEnd - 1, math.min(#state.timeline, state.cutStart + 1), #state.timeline)
	updateStatus("CUT CONFIG")
end)

createButton("APPLY CUT", 8, function()
	if #state.timeline <= 2 or state.cutStart >= state.cutEnd then return end
	local newTL = {}
	for i = state.cutStart, state.cutEnd do
		table.insert(newTL, cloneTimeline({state.timeline[i]})[1])
	end
	normalizeTimeline(newTL)
	state.timeline = newTL
	state.cutStart = 1
	state.cutEnd = #state.timeline
	rebuildRoute()
	updateStatus("CUT APPLIED")
end)

createButton("PUT TOGETHER", 9, function()
	local base = state.savedFiles[state.selectedFile]
	if not base or #base.timeline == 0 or #state.timeline == 0 then
		updateStatus("EMPTY DATA")
		return
	end
	local merged = cloneTimeline(base.timeline)
	normalizeTimeline(merged)
	local offset = merged[#merged].RelativeTimestamp + CFG.NodeInterval
	local baseTs = merged[1].Timestamp

	for _, node in ipairs(state.timeline) do
		local copy = cloneTimeline({node})[1]
		copy.RelativeTimestamp = offset + node.RelativeTimestamp
		copy.Timestamp = baseTs + copy.RelativeTimestamp
		table.insert(merged, copy)
	end
	normalizeTimeline(merged)
	state.timeline = merged
	state.cutStart = 1
	state.cutEnd = #state.timeline
	rebuildRoute()
	updateStatus("MERGED")
end)

for i = 1, 5 do
	local fNum = i
	createButton("FILE " .. tostring(i), 9 + i, function()
		if state.isRecording then return end
		if state.isPlaying then stopPlayback(true) end
		state.selectedFile = fNum
		state.cutStart = 1
		state.cutEnd = math.max(1, #state.timeline)
		updateStatus("FILE " .. tostring(fNum))
	end)
end

createButton("SAVE FILE", 15, function()
	if #state.timeline == 0 then updateStatus("EMPTY"); return end
	normalizeTimeline(state.timeline)
	state.savedFiles[state.selectedFile] = {timeline = cloneTimeline(state.timeline)}
	saveToDisk()
	updateStatus("SAVED FILE " .. tostring(state.selectedFile))
end)

createButton("LOAD FILE", 16, function()
	if state.isRecording then return end
	local data = state.savedFiles[state.selectedFile]
	if not data or #data.timeline == 0 then updateStatus("EMPTY"); return end
	stopPlayback(true)
	state.timeline = cloneTimeline(data.timeline)
	normalizeTimeline(state.timeline)
	state.cutStart = 1
	state.cutEnd = #state.timeline
	rebuildRoute()
	updateStatus("LOADED FILE " .. tostring(state.selectedFile))
end)

createButton("CLEAR", 17, function()
	stopPlayback(true)
	state.timeline = {}
	state.cutStart = 1
	state.cutEnd = 1
	clearVisuals()
	updateStatus("CLEARED")
end)

createButton("LINE VISIBLE", 18, function()
	state.lineVisible = not state.lineVisible
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)
	if folder then
		for _, obj in ipairs(folder:GetChildren()) do
			if obj.Name == "VisualNode" then obj.Transparency = state.lineVisible and 0 or 1 end
		end
	end
	updateStatus(state.lineVisible and "LINE ON" or "LINE OFF")
end)

----------------------------------------------------------------
-- GLOBAL CLEANUP REGISTRATION
----------------------------------------------------------------
_G.AldoKnightXorzV444_Cleanup = function()
	state.isRecording = false
	state.isPlaying = false
	pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV444_Record") end)
	pcall(function() RunService:UnbindFromRenderStep("AldoKnightXorzV444_Playback") end)
	disableKinematic()
	for _, conn in ipairs(currentConnections) do
		pcall(function() conn:Disconnect() end)
	end
	currentConnections = {}
	clearVisuals()
	pcall(function() ScreenGui:Destroy() end)
end

updateStatus("IDLE")
