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
	RootPart = Character:WaitForChild("HumanoidRootPart")
	Humanoid = Character:WaitForChild("Humanoid")
end)

local recordingData = {}
local isRecording = false
local isPlaying = false
local currentFrameIndex = 1
local playbackTime = 0

local visualAttachments = {}
local visualBeams = {}
local visualFolder = Instance.new("Folder")
visualFolder.Name = "AutoWalkVisualPath"
visualFolder.Parent = workspace

local wasGrounded = true

local function clearVisuals()
	visualFolder:ClearAllChildren()
	visualAttachments = {}
	visualBeams = {}
end

local function rebuildVisualPath()
	clearVisuals()
	for i = 1, #recordingData do
		local frame = recordingData[i]
		local att = Instance.new("Attachment")
		att.WorldCFrame = frame.cframe
		att.Parent = visualFolder
		table.insert(visualAttachments, att)

		if i > 1 then
			local beam = Instance.new("Beam")
			beam.Attachment0 = visualAttachments[i - 1]
			beam.Attachment1 = att
			beam.Width0 = 0.3
			beam.Width1 = 0.3
			beam.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255))
			beam.FaceCamera = true
			beam.Parent = visualFolder
			table.insert(visualBeams, beam)
		end
	end
end

local function addVisualSegment(cframe)
	local att = Instance.new("Attachment")
	att.WorldCFrame = cframe
	att.Parent = visualFolder
	table.insert(visualAttachments, att)

	local count = #visualAttachments
	if count > 1 then
		local beam = Instance.new("Beam")
		beam.Attachment0 = visualAttachments[count - 1]
		beam.Attachment1 = att
		beam.Width0 = 0.3
		beam.Width1 = 0.3
		beam.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255))
		beam.FaceCamera = true
		beam.Parent = visualFolder
		table.insert(visualBeams, beam)
	end
end

local recordConnection = nil
local playbackConnection = nil

local function stopAll()
	isRecording = false
	isPlaying = false
	if recordConnection then
		recordConnection:Disconnect()
		recordConnection = nil
	end
	if playbackConnection then
		playbackConnection:Disconnect()
		playbackConnection = nil
	end
end

local function startRecording()
	stopAll()
	if currentFrameIndex < #recordingData then
		for i = #recordingData, currentFrameIndex + 1, -1 do
			table.remove(recordingData, i)
		end
		rebuildVisualPath()
	end

	isRecording = true
	local startTime = os.clock()
	wasGrounded = Humanoid.FloorMaterial ~= Enum.Material.Air

	recordConnection = RunService.Heartbeat:Connect(function(dt)
		if not isRecording or not RootPart or not Humanoid then return end

		local state = Humanoid:GetState()
		local isGrounded = (Humanoid.FloorMaterial ~= Enum.Material.Air)
		local jumpStart = (state == Enum.HumanoidStateType.Jumping)
		local landing = (not wasGrounded and isGrounded)
		wasGrounded = isGrounded

		local frameData = {
			timestamp = os.clock() - startTime,
			position = RootPart.Position,
			cframe = RootPart.CFrame,
			rotation = RootPart.CFrame.Rotation,
			velocity = RootPart.AssemblyLinearVelocity,
			moveDir = Humanoid.MoveDirection,
			walkSpeed = Humanoid.WalkSpeed,
			state = state,
			jumpStart = jumpStart,
			landing = landing,
			grounded = isGrounded
		}

		table.insert(recordingData, frameData)
		currentFrameIndex = #recordingData
		addVisualSegment(frameData.cframe)
	end)
end

local function startPlayback()
	stopAll()
	if #recordingData == 0 then return end

	isPlaying = true
	currentFrameIndex = 1
	playbackTime = recordingData[1].timestamp
	RootPart.CFrame = recordingData[1].cframe

	playbackConnection = RunService.Heartbeat:Connect(function(dt)
		if not isPlaying or #recordingData == 0 then return end

		playbackTime = playbackTime + dt

		while currentFrameIndex < #recordingData and recordingData[currentFrameIndex + 1].timestamp <= playbackTime do
			currentFrameIndex = currentFrameIndex + 1
		end

		if currentFrameIndex >= #recordingData then
			stopAll()
			return
		end

		local currFrame = recordingData[currentFrameIndex]
		local nextFrame = recordingData[currentFrameIndex + 1]

		local duration = nextFrame.timestamp - currFrame.timestamp
		local alpha = 0
		if duration > 0 then
			alpha = math.clamp((playbackTime - currFrame.timestamp) / duration, 0, 1)
		end

		Humanoid.WalkSpeed = currFrame.walkSpeed

		if currFrame.jumpStart then
			Humanoid.Jump = true
		end

		local interpMoveDir = currFrame.moveDir:Lerp(nextFrame.moveDir, alpha)
		if interpMoveDir.Magnitude > 0.05 then
			Humanoid:Move(interpMoveDir, false)
		else
			Humanoid:Move(Vector3.zero, false)
		end

		local targetCFrame = currFrame.cframe:Lerp(nextFrame.cframe, alpha)
		local currentCF = RootPart.CFrame
		local correctedCF = currentCF:Lerp(CFrame.new(currentCF.Position) * targetCFrame.Rotation, 0.25)
		RootPart.CFrame = correctedCF

		if (RootPart.Position - targetCFrame.Position).Magnitude > 4 then
			RootPart.CFrame = targetCFrame
		end
	end)
end

local function rollbackTimeline()
	stopAll()
	if #recordingData == 0 then return end
	local removeCount = math.min(30, #recordingData)
	for i = 1, removeCount do
		table.remove(recordingData)
	end
	currentFrameIndex = #recordingData
	rebuildVisualPath()
	if currentFrameIndex > 0 then
		RootPart.CFrame = recordingData[currentFrameIndex].cframe
	end
end

local function cutTimeline()
	stopAll()
	if #recordingData == 0 or currentFrameIndex >= #recordingData then return end
	for i = #recordingData, currentFrameIndex + 1, -1 do
		table.remove(recordingData, i)
	end
	rebuildVisualPath()
end

local savedData = {}

local function saveData()
	savedData = {}
	for i, v in ipairs(recordingData) do
		table.insert(savedData, {
			timestamp = v.timestamp,
			position = v.position,
			cframe = v.cframe,
			rotation = v.rotation,
			velocity = v.velocity,
			moveDir = v.moveDir,
			walkSpeed = v.walkSpeed,
			state = v.state,
			jumpStart = v.jumpStart,
			landing = v.landing,
			grounded = v.grounded
		})
	end
end

local function loadData()
	stopAll()
	recordingData = {}
	for i, v in ipairs(savedData) do
		table.insert(recordingData, {
			timestamp = v.timestamp,
			position = v.position,
			cframe = v.cframe,
			rotation = v.rotation,
			velocity = v.velocity,
			moveDir = v.moveDir,
			walkSpeed = v.walkSpeed,
			state = v.state,
			jumpStart = v.jumpStart,
			landing = v.landing,
			grounded = v.grounded
		})
	end
	currentFrameIndex = #recordingData
	rebuildVisualPath()
	if currentFrameIndex > 0 then
		RootPart.CFrame = recordingData[currentFrameIndex].cframe
	end
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoKnightXOzGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenuButton"
openButton.Size = UDim2.new(0, 120, 0, 35)
openButton.Position = UDim2.new(0, 15, 0, 15)
openButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
openButton.Text = "Menu"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 13
openButton.Parent = screenGui

local uiCornerOpen = Instance.new("UICorner")
uiCornerOpen.CornerRadius = UDim.new(0, 6)
uiCornerOpen.Parent = openButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 350)
mainFrame.Position = UDim2.new(0, 15, 0, 60)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = true
mainFrame.Parent = screenGui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 8)
uiCornerMain.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ALDO KNIGHTXOz"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.LayoutOrder = 0
titleLabel.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 2
titleStroke.Parent = titleLabel

local frameLayout = Instance.new("UIListLayout")
frameLayout.Parent = mainFrame
frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
frameLayout.Padding = UDim.new(0, 5)
frameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0, 18)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Frame: 0 / 0"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.LayoutOrder = 1
statusLabel.Parent = mainFrame

local function updateStatus()
	statusLabel.Text = "Frame: " .. tostring(currentFrameIndex) .. " / " .. tostring(#recordingData)
end

RunService.RenderStepped:Connect(function()
	if not isRecording and not isPlaying then
		updateStatus()
	end
end)

local function applyGradientAnimation(guiObject)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = guiObject

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 100))
	})
	gradient.Rotation = 0
	gradient.Parent = stroke

	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local tween = TweenService:Create(gradient, tweenInfo, {Rotation = 360})
	tween:Play()
end

applyGradientAnimation(mainFrame)
applyGradientAnimation(openButton)

local function createMenuButton(name, text, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.9, 0, 0, 25)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.LayoutOrder = order
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn

	applyGradientAnimation(btn)
	return btn
end

local btnRecord = createMenuButton("BtnRecord", "RECORD", 2)
local btnStop = createMenuButton("BtnStop", "STOP", 3)
local btnPlay = createMenuButton("BtnPlay", "PLAY", 4)
local btnRollback = createMenuButton("BtnRollback", "ROLLBACK", 5)

local navFrame = Instance.new("Frame")
navFrame.Name = "NavFrame"
navFrame.Size = UDim2.new(0.9, 0, 0, 25)
navFrame.BackgroundTransparency = 1
navFrame.LayoutOrder = 6
navFrame.Parent = mainFrame

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
navLayout.Parent = navFrame

local btnLeft = Instance.new("TextButton")
btnLeft.Size = UDim2.new(0.48, 0, 1, 0)
btnLeft.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnLeft.Text = "<<"
btnLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLeft.Font = Enum.Font.GothamBold
btnLeft.Parent = navFrame
local cornerLeft = Instance.new("UICorner")
cornerLeft.CornerRadius = UDim.new(0, 5)
cornerLeft.Parent = btnLeft
applyGradientAnimation(btnLeft)

local btnRight = Instance.new("TextButton")
btnRight.Size = UDim2.new(0.48, 0, 1, 0)
btnRight.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnRight.Text = ">>"
btnRight.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRight.Font = Enum.Font.GothamBold
btnRight.Parent = navFrame
local cornerRight = Instance.new("UICorner")
cornerRight.CornerRadius = UDim.new(0, 5)
cornerRight.Parent = btnRight
applyGradientAnimation(btnRight)

local btnCut = createMenuButton("BtnCut", "CUT", 7)
local btnSave = createMenuButton("BtnSave", "SAVE", 8)
local btnLoad = createMenuButton("BtnLoad", "LOAD", 9)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.O then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

btnRecord.MouseButton1Click:Connect(startRecording)
btnStop.MouseButton1Click:Connect(stopAll)
btnPlay.MouseButton1Click:Connect(startPlayback)
btnRollback.MouseButton1Click:Connect(rollbackTimeline)

btnLeft.MouseButton1Click:Connect(function()
	if #recordingData == 0 then return end
	currentFrameIndex = math.clamp(currentFrameIndex - 10, 1, #recordingData)
	RootPart.CFrame = recordingData[currentFrameIndex].cframe
end)

btnRight.MouseButton1Click:Connect(function()
	if #recordingData == 0 then return end
	currentFrameIndex = math.clamp(currentFrameIndex + 10, 1, #recordingData)
	RootPart.CFrame = recordingData[currentFrameIndex].cframe
end)

btnCut.MouseButton1Click:Connect(cutTimeline)
btnSave.MouseButton1Click:Connect(saveData)
btnLoad.MouseButton1Click:Connect(loadData)

print("ALDO KNIGHTXOz")	updateStatus()
end)

btnLeft.MouseButton1Click:Connect(function()
	if #recordingData == 0 then return end
	currentFrameIndex = math.clamp(currentFrameIndex - 10, 1, #recordingData)
	RootPart.CFrame = recordingData[currentFrameIndex].cframe
	updateStatus()
end)

btnRight.MouseButton1Click:Connect(function()
	if #recordingData == 0 then return end
	currentFrameIndex = math.clamp(currentFrameIndex + 10, 1, #recordingData)
	RootPart.CFrame = recordingData[currentFrameIndex].cframe
	updateStatus()
end)

btnCut.MouseButton1Click:Connect(function()
	stopAll()
	if #recordingData == 0 or currentFrameIndex >= #recordingData then return end
	for i = #recordingData, currentFrameIndex + 1, -1 do
		table.remove(recordingData, i)
	end
	rebuildVisualPath()
	updateStatus()
end)

local savedData = {}

btnSave.MouseButton1Click:Connect(function()
	savedData = {}
	for i, v in ipairs(recordingData) do
		table.insert(savedData, {
			cframe = v.cframe,
			velocity = v.velocity,
			moveDir = v.moveDir,
			walkSpeed = v.walkSpeed,
			state = v.state,
			jump = v.jump
		})
	end
	updateStatus()
end)

btnLoad.MouseButton1Click:Connect(function()
	stopAll()
	recordingData = {}
	for i, v in ipairs(savedData) do
		table.insert(recordingData, {
			cframe = v.cframe,
			velocity = v.velocity,
			moveDir = v.moveDir,
			walkSpeed = v.walkSpeed,
			state = v.state,
			jump = v.jump
		})
	end
	currentFrameIndex = #recordingData
	rebuildVisualPath()
	if currentFrameIndex > 0 then
		RootPart.CFrame = recordingData[currentFrameIndex].cframe
	end
	updateStatus()
end)

print("ALDO KNIGHTXOz")
