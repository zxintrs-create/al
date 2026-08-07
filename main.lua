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
local visualNodes = {}
local visualAttachments = {}
local visualBeams = {}
local visualFolder = Instance.new("Folder")
visualFolder.Name = "AutoWalkVisualPath"
visualFolder.Parent = workspace

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoKnightXOzGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenuButton"
openButton.Size = UDim2.new(0, 120, 0, 40)
openButton.Position = UDim2.new(0, 20, 0, 20)
openButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
openButton.Text = "Menu"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 14
openButton.Parent = screenGui

local uiCornerOpen = Instance.new("UICorner")
uiCornerOpen.CornerRadius = UDim.new(0, 8)
uiCornerOpen.Parent = openButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0, 70)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = true
mainFrame.Parent = screenGui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 12)
uiCornerMain.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ALDO KNIGHTXOz"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 2
titleStroke.Parent = titleLabel

local frameLayout = Instance.new("UIListLayout")
frameLayout.Parent = mainFrame
frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
frameLayout.Padding = UDim.new(0, 6)
frameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

titleLabel.LayoutOrder = 0

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Frame: 0 / 0"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.LayoutOrder = 1
statusLabel.Parent = mainFrame

local function applyGradientAnimation(guiObject)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
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
	btn.Size = UDim2.new(0.9, 0, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.LayoutOrder = order
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
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
navFrame.Size = UDim2.new(0.9, 0, 0, 28)
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
cornerLeft.CornerRadius = UDim.new(0, 6)
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
cornerRight.CornerRadius = UDim.new(0, 6)
cornerRight.Parent = btnRight
applyGradientAnimation(btnRight)

local btnCut = createMenuButton("BtnCut", "CUT", 7)
local btnSave = createMenuButton("BtnSave", "SAVE", 8)
local btnLoad = createMenuButton("BtnLoad", "LOAD", 9)

local function toggleMenu()
	mainFrame.Visible = not mainFrame.Visible
end

openButton.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.O then
		toggleMenu()
	end
end)

local function updateStatus()
	statusLabel.Text = "Frame: " .. tostring(currentFrameIndex) .. " / " .. tostring(#recordingData)
end

local function clearVisuals()
	visualFolder:ClearAllChildren()
	visualNodes = {}
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
			beam.Width0 = 0.4
			beam.Width1 = 0.4
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
		beam.Width0 = 0.4
		beam.Width1 = 0.4
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

btnRecord.MouseButton1Click:Connect(function()
	stopAll()
	if currentFrameIndex < #recordingData then
		for i = #recordingData, currentFrameIndex + 1, -1 do
			table.remove(recordingData, i)
		end
		rebuildVisualPath()
	end
	isRecording = true
	recordConnection = RunService.Heartbeat:Connect(function()
		if not isRecording or not RootPart or not Humanoid then return end
		local state = Humanoid:GetState()
		local frameData = {
			cframe = RootPart.CFrame,
			velocity = RootPart.AssemblyLinearVelocity,
			moveDir = Humanoid.MoveDirection,
			walkSpeed = Humanoid.WalkSpeed,
			state = state,
			jump = (state == Enum.HumanoidStateType.Jumping)
		}
		table.insert(recordingData, frameData)
		currentFrameIndex = #recordingData
		addVisualSegment(frameData.cframe)
		updateStatus()
	end)
end)

btnStop.MouseButton1Click:Connect(function()
	stopAll()
	updateStatus()
end)

btnPlay.MouseButton1Click:Connect(function()
	stopAll()
	if #recordingData == 0 then return end
	isPlaying = true
	currentFrameIndex = 1

	playbackConnection = RunService.Heartbeat:Connect(function()
		if not isPlaying then return end
		if currentFrameIndex > #recordingData then
			stopAll()
			return
		end

		local frame = recordingData[currentFrameIndex]
		RootPart.CFrame = frame.cframe
		RootPart.AssemblyLinearVelocity = frame.velocity

		if frame.jump then
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		Humanoid:Move(frame.moveDir, false)

		currentFrameIndex = currentFrameIndex + 1
		updateStatus()
	end)
end)

btnRollback.MouseButton1Click:Connect(function()
	stopAll()
	if #recordingData == 0 then return end
	local removeAmount = math.min(30, #recordingData)
	for i = 1, removeAmount do
		table.remove(recordingData)
	end
	currentFrameIndex = #recordingData
	rebuildVisualPath()
	if currentFrameIndex > 0 then
		RootPart.CFrame = recordingData[currentFrameIndex].cframe
	end
	updateStatus()
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
