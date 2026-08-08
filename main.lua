-- [[ HEAVELYNE ART: PREMIUM HUD & PATH SYSTEM ]] --

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character, RootPart, Humanoid
local stopPlayback

-- Cleanup Universal
if _G.HeavelyneArt_Cleanup then pcall(_G.HeavelyneArt_Cleanup) end

local currentConnections = {}
_G.HeavelyneArt_Cleanup = function()
	for _, conn in ipairs(currentConnections) do
		if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
	end
	currentConnections = {}

	RunService:UnbindFromRenderStep("Heavelyne_Record")
	RunService:UnbindFromRenderStep("Heavelyne_Playback")

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and (gui.Name == "HeavelyneArtGui" or gui.Name:find("Heavelyne")) then
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
	NodeInterval = 0.15,
	MinDistance = 0.4,
	LineColor = Color3.fromRGB(0, 255, 255),
	AccentColor = Color3.fromRGB(170, 0, 255),
	SaveFileName = "HEAVELYNE_ART_PATH.json",
	Y_SENSITIVITY = 0.2,
}

local state = {
	isRecording = false,
	isPlaying = false,
	isPaused = false,
	isAutoWalk = false,
	playbackID = 0,
	timeline = {},
	visualNodes = {},
	selectedFile = 1,
	savedFiles = {},
	startTime = 0,
	lastJumpState = false,
	movementSpeed = 16,
}

-- [ GROUND LOCK LOGIC ]
local function applyGroundLock(targetPos)
	if not RootPart then return end
	local rayOrigin = RootPart.Position + Vector3.new(0, 2, 0)
	local rayDirection = Vector3.new(0, -10, 0)
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {Character}
	rayparams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(rayOrigin, rayDirection, rayparams)
	if result then
		local floorY = result.Position.Y + (Humanoid.HipHeight + (RootPart.Size.Y/2))
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

-- [ 1. SCREEN GUI & MAIN CONTAINER ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeavelyneArtGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Floating Open/Close Menu Button (Tanpa Animasi / Statis)
local OpenMenu = Instance.new("ImageButton")
OpenMenu.Name = "OpenMenuButton"
OpenMenu.Size = UDim2.new(0, 50, 0, 50)
OpenMenu.Position = UDim2.new(0.03, 0, 0.4, 0)
OpenMenu.AnchorPoint = Vector2.new(0, 0.5)
OpenMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
OpenMenu.Image = "rbxassetid://101640388423900"
OpenMenu.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(138, 43, 226)
OpenStroke.Parent = OpenMenu

-- Main Hub Frame (Tertutup secara default)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "ContainerFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 360)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local MainStrokeGradient = Instance.new("UIGradient")
MainStrokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 180)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 191, 255))
})
MainStrokeGradient.Offset = Vector2.new(-1, 0)
MainStrokeGradient.Parent = UIStroke

OpenMenu.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- [ 2. TOP BAR ]
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 120, 1, 0)
FpsLabel.Position = UDim2.new(0, 15, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS : 0"
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 13
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 240, 1, 0)
TitleLabel.Position = UDim2.new(0.5, -120, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HEAVELYNE ART"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = TopBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 180)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 191, 255))
})
TitleGradient.Offset = Vector2.new(-1, 0)
TitleGradient.Parent = TitleLabel

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 120, 1, 0)
PingLabel.Position = UDim2.new(1, -135, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "PING : 0"
PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 13
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.Parent = TopBar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 50)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.8
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- [ 3. SIDEBAR MENU PANEL ]
local MenuPanel = Instance.new("Frame")
MenuPanel.Name = "MenuPanel"
MenuPanel.Size = UDim2.new(0, 120, 1, -51)
MenuPanel.Position = UDim2.new(0, 0, 0, 51)
MenuPanel.BackgroundTransparency = 1
MenuPanel.Parent = MainFrame

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 30)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextSize = 13
MenuTitle.Parent = MenuPanel

-- [ 4. CONTENT CONTAINER (MAIN RP INTERFACE) ]
local ContentArea = Instance.new("Frame")
ContentArea.Name = "MainRPContent"
ContentArea.Size = UDim2.new(1, -125, 1, -55)
ContentArea.Position = UDim2.new(0, 125, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 25)
StatusLabel.Position = UDim2.new(0, 5, 0, 0)
StatusLabel.Text = "Status: IDLE | File: 1"
StatusLabel.TextColor3 = CFG.LineColor
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = ContentArea

local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Name = "ScrollingContainer"
ScrollingContainer.Size = UDim2.new(1, -10, 1, -30)
ScrollingContainer.Position = UDim2.new(0, 0, 0, 25)
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.Parent = ContentArea

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollingContainer
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

local function updateStatus(text)
	StatusLabel.Text = "Status: " .. text .. " | File: " .. state.selectedFile
end

local function createBtn(text, order, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 445, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(230, 230, 230)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
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

-- [ Recording Loop ]
RunService:BindToRenderStep("Heavelyne_Record", Enum.RenderPriority.Character.Value, function()
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
	RunService:UnbindFromRenderStep("Heavelyne_Playback")
	if Humanoid then Humanoid.AutoRotate = true end
	updateStatus("IDLE")
end

-- [ Playback Engine ]
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

	RunService:BindToRenderStep("Heavelyne_Playback", Enum.RenderPriority.Last.Value, function(dt)
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
			applyGroundLock(targetPos)

			local direction = (targetPos - RootPart.Position)
			if direction.Magnitude > 0.1 then
				local moveDir = Vector3.new(direction.X, 0, direction.Z).Unit
				Humanoid:Move(moveDir, false)
				if direction.Y > 1.5 then Humanoid.Jump = true end
			else
				Humanoid:Move(Vector3.zero, true)
			end
		end
	end)
end

-- [ Action Buttons Assignment ]
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

-- [ ANIMATION LOOPS (Gradient Flow) ]
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)
local titleTween = TweenService:Create(TitleGradient, tweenInfo, { Offset = Vector2.new(1, 0) })
titleTween:Play()

local frameStrokeTween = TweenService:Create(MainStrokeGradient, tweenInfo, { Offset = Vector2.new(1, 0) })
frameStrokeTween:Play()

-- Real-time FPS & Ping Counter Loop
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
	local currentTime = tick()
	
	if currentTime - lastUpdate >= 1 then
		local fps = math.floor(frameCount / (currentTime - lastUpdate))
		local success, ping = pcall(function()
			return math.floor(LocalPlayer:GetNetworkPing() * 1000)
		end)
		
		FpsLabel.Text = "FPS : " .. fps
		PingLabel.Text = "PING : " .. (success and ping or 0)
		
		frameCount = 0
		lastUpdate = currentTime
	end
end)
