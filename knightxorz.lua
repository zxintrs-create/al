local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character
local humanoid
local rootPart
local animator

local state = {
	isRecording = false,
	isPlaying = false,
	isAutoWalk = false,
	isLooping = false,
	autoWalkSpeed = 16,
	jumpPower = 50,
	fallMultiplier = 1,
	rotateSpeed = 5,
	recordedFrames = {},
	safePoints = {},
	lastSafePosition = nil,
	lastSafeRotation = nil,
	recordConnection = nil,
	playbackConnection = nil,
	playbackIndex = 1,
	playbackDirection = 1,
	playbackStarted = false,
	lastPlaybackDirection = Vector3.zero,
	lastPlaybackSpeed = 0,
	jumpCooldown = 0,
	approachSpeed = 16
}

local showVisualLine = true
local recordRate = 1 / 30
local arrivalDistance = 2.5

local function setupCharacter(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	humanoid.WalkSpeed = state.autoWalkSpeed
	humanoid.JumpPower = state.jumpPower
	humanoid.AutoRotate = true
end

setupCharacter(player.Character or player.CharacterAdded:Wait())

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimRecorderGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local pathFolder = Instance.new("Folder")
pathFolder.Name = "VisualPathLines"
pathFolder.Parent = workspace

local function makeFrame(name, parent, size, position, color)
	local object = Instance.new("Frame")
	object.Name = name
	object.Size = size
	object.Position = position
	object.BackgroundColor3 = color
	object.BackgroundTransparency = 0.15
	object.BorderSizePixel = 0
	object.Parent = parent
	return object
end

local function makeButton(name, parent, text, position, size, color)
	local object = Instance.new("TextButton")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Text = text
	object.TextColor3 = Color3.fromRGB(255, 255, 255)
	object.TextSize = 14
	object.Font = Enum.Font.GothamBold
	object.BackgroundColor3 = color
	object.BorderSizePixel = 0
	object.AutoButtonColor = true
	object.Parent = parent
	return object
end

local function makeLabel(name, parent, text, position, size)
	local object = Instance.new("TextLabel")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Text = text
	object.TextColor3 = Color3.fromRGB(200, 200, 200)
	object.TextSize = 12
	object.Font = Enum.Font.Gotham
	object.BackgroundTransparency = 1
	object.BorderSizePixel = 0
	object.TextXAlignment = Enum.TextXAlignment.Left
	object.Parent = parent
	return object
end

local function makeSlider(name, parent, position, defaultValue)
	local container = makeFrame(
		name .. "Container",
		parent,
		UDim2.new(0, 180, 0, 36),
		position,
		Color3.fromRGB(40, 40, 40)
	)

	local label = makeLabel(
		name .. "Label",
		container,
		name .. ": " .. tostring(defaultValue),
		UDim2.new(0, 5, 0, 2),
		UDim2.new(0, 170, 0, 14)
	)

	local box = Instance.new("TextBox")
	box.Name = name .. "Box"
	box.Size = UDim2.new(0, 170, 0, 16)
	box.Position = UDim2.new(0, 5, 0, 17)
	box.Text = tostring(defaultValue)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 12
	box.Font = Enum.Font.Gotham
	box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = container

	return label, box
end

local mainWindow = makeFrame(
	"MainWindow",
	screenGui,
	UDim2.new(0, 220, 0, 555),
	UDim2.new(0, 15, 0, 50),
	Color3.fromRGB(25, 25, 35)
)

mainWindow.Active = true
mainWindow.Draggable = true

local title = makeLabel(
	"Title",
	mainWindow,
	"ANIM RECORDER",
	UDim2.new(0, 10, 0, 5),
	UDim2.new(0, 200, 0, 22)
)

title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(100, 200, 255)

local y = 32

local btnRecord = makeButton(
	"Record",
	mainWindow,
	"● RECORD",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(180, 40, 40)
)

local btnPlay = makeButton(
	"Play",
	mainWindow,
	"▶ PLAY",
	UDim2.new(0, 110, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(40, 120, 40)
)

y += 34

local btnStop = makeButton(
	"Stop",
	mainWindow,
	"■ STOP",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(100, 100, 100)
)

local btnRollback = makeButton(
	"Rollback",
	mainWindow,
	"↩ ROLLBACK",
	UDim2.new(0, 110, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(40, 80, 160)
)

y += 34

local btnClear = makeButton(
	"Clear",
	mainWindow,
	"✕ CLEAR ALL",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 24),
	Color3.fromRGB(80, 40, 40)
)

y += 30

local separator1 = makeFrame(
	"Separator1",
	mainWindow,
	UDim2.new(0, 200, 0, 1),
	UDim2.new(0, 10, 0, y),
	Color3.fromRGB(80, 80, 100)
)

y += 8

local btnAutoWalk = makeButton(
	"AutoWalk",
	mainWindow,
	"◇ AUTO WALK OFF",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 26),
	Color3.fromRGB(60, 60, 80)
)

y += 30

local btnLoop = makeButton(
	"Loop",
	mainWindow,
	"↻ LOOP OFF",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 26),
	Color3.fromRGB(60, 60, 80)
)

y += 30

local speedLabel, speedBox =
	makeSlider("Speed", mainWindow, UDim2.new(0, 10, 0, y), 16)

y += 40

local jumpLabel, jumpBox =
	makeSlider("JumpPower", mainWindow, UDim2.new(0, 10, 0, y), 50)

y += 40

local fallLabel, fallBox =
	makeSlider("FallMult", mainWindow, UDim2.new(0, 10, 0, y), 1)

y += 40

local rotLabel, rotBox =
	makeSlider("RotSpeed", mainWindow, UDim2.new(0, 10, 0, y), 5)

y += 40

local separator2 = makeFrame(
	"Separator2",
	mainWindow,
	UDim2.new(0, 200, 0, 1),
	UDim2.new(0, 10, 0, y),
	Color3.fromRGB(80, 80, 100)
)

y += 8

local statusLabel = makeLabel(
	"Status",
	mainWindow,
	"Status: Idle",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 200, 0, 16)
)

statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

y += 18

local frameCountLabel = makeLabel(
	"FrameCount",
	mainWindow,
	"Frames: 0",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 200, 0, 16)
)

y += 18

local btnToggleLine = makeButton(
	"ToggleLine",
	mainWindow,
	"◉ VISUAL LINE ON",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 24),
	Color3.fromRGB(60, 80, 60)
)

local function clearVisualPath()
	for _, object in ipairs(pathFolder:GetChildren()) do
		object:Destroy()
	end
end

local function createPathSegment(firstPosition, secondPosition, color)
	local distance = (secondPosition - firstPosition).Magnitude

	if distance < 0.05 then
		return
	end

	local segment = Instance.new("Part")
	segment.Name = "VisualPath"
	segment.Size = Vector3.new(0.1, 0.1, distance)
	segment.CFrame = CFrame.lookAt(
		(firstPosition + secondPosition) * 0.5,
		secondPosition
	)
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false
	segment.CanQuery = false
	segment.CastShadow = false
	segment.Locked = true
	segment.Material = Enum.Material.Neon
	segment.Transparency = 0.35
	segment.Color = color
	segment.Parent = pathFolder
end

local function rebuildVisualPath()
	clearVisualPath()

	if not showVisualLine then
		return
	end

	if #state.recordedFrames < 2 then
		return
	end

	for index = 1, #state.recordedFrames - 1 do
		local firstFrame = state.recordedFrames[index]
		local secondFrame = state.recordedFrames[index + 1]

		local alpha = index / (#state.recordedFrames - 1)

		local color = Color3.new(
			0.2 + alpha * 0.8,
			0.5 + (1 - alpha) * 0.5,
			0.8
		)

		createPathSegment(
			firstFrame.position,
			secondFrame.position,
			color
		)
	end
end

local function isGrounded()
	if not humanoid then
		return false
	end

	return humanoid.FloorMaterial ~= Enum.Material.Air
end

local function updateSafePoint()
	if not rootPart or not isGrounded() then
		return
	end

	state.lastSafePosition = rootPart.Position
	state.lastSafeRotation = rootPart.Orientation
end

local function rollbackToSafe()
	if not character or not state.lastSafePosition then
		statusLabel.Text = "Status: No safe point"
		return
	end

	local rotationY = 0

	if state.lastSafeRotation then
		rotationY = math.rad(state.lastSafeRotation.Y)
	end

	character:PivotTo(
		CFrame.new(state.lastSafePosition)
			* CFrame.Angles(0, rotationY, 0)
	)

	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	statusLabel.Text = "Status: Rollback complete"
end

local function recordFrame()
	if not rootPart then
		return
	end

	table.insert(
		state.recordedFrames,
		{
			position = rootPart.Position,
			rotation = rootPart.CFrame.Rotation,
			time = os.clock(),
			grounded = isGrounded()
		}
	)

	frameCountLabel.Text =
		"Frames: " .. tostring(#state.recordedFrames)
end

local function getHorizontal(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end

local function getMovement(index, directionMultiplier)
	if #state.recordedFrames < 2 then
		return Vector3.zero, 0
	end

	local nextIndex = index + directionMultiplier

	if nextIndex < 1 or nextIndex > #state.recordedFrames then
		return Vector3.zero, 0
	end

	local first = state.recordedFrames[index]
	local second = state.recordedFrames[nextIndex]

	local delta = second.position - first.position
	local horizontalDelta = getHorizontal(delta)

	local duration = math.abs(second.time - first.time)

	if duration <= 0 then
		duration = 0.016
	end

	if horizontalDelta.Magnitude < 0.01 then
		return Vector3.zero, 0
	end

	return horizontalDelta.Unit, horizontalDelta.Magnitude / duration
end

local function getApproachDirection(targetPosition)
	if not rootPart then
		return Vector3.zero, 0
	end

	local delta =
		targetPosition - rootPart.Position

	local horizontal =
		getHorizontal(delta)

	local distance =
		horizontal.Magnitude

	if distance <= arrivalDistance then
		return Vector3.zero, distance
	end

	if distance <= 0.01 then
		return Vector3.zero, distance
	end

	return horizontal.Unit, distance
end

local function finishPlayback()
	state.isPlaying = false
	state.playbackStarted = false

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end

	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = state.autoWalkSpeed
	end

	state.lastPlaybackDirection = Vector3.zero
	state.lastPlaybackSpeed = 0
	state.jumpCooldown = 0

	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(40, 120, 40)

	statusLabel.Text = "Status: Playback complete"
end

local function stopPlayback()
	state.isPlaying = false
	state.playbackStarted = false

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end

	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = state.autoWalkSpeed
	end

	state.lastPlaybackDirection = Vector3.zero
	state.lastPlaybackSpeed = 0
	state.jumpCooldown = 0

	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(40, 120, 40)

	statusLabel.Text = "Status: Stopped"
end

local function startPlayback()
	if state.isRecording or state.isPlaying then
		return
	end

	if #state.recordedFrames < 2 then
		statusLabel.Text = "Status: Not enough frames"
		return
	end

	if not character or not humanoid or not rootPart then
		statusLabel.Text = "Status: Character unavailable"
		return
	end

	state.isPlaying = true
	state.playbackStarted = false
	state.playbackIndex = 1
	state.playbackDirection = 1
	state.lastPlaybackDirection = Vector3.zero
	state.lastPlaybackSpeed = 0
	state.jumpCooldown = 0

	humanoid.AutoRotate = true

	btnPlay.Text = "⏸ PLAYING"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(200, 150, 40)

	statusLabel.Text =
		"Status: Walking to start..."

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
	end

	state.playbackConnection =
		RunService.Heartbeat:Connect(function(dt)
			if not state.isPlaying then
				return
			end

			if not character
				or not humanoid
				or not rootPart then

				stopPlayback()
				return
			end

			if not state.playbackStarted then
				local startPosition =
					state.recordedFrames[1].position

				local direction, distance =
					getApproachDirection(
						startPosition
					)

				if distance <= arrivalDistance then
					state.playbackStarted = true
					state.playbackIndex = 1
					state.playbackDirection = 1
					state.lastPlaybackDirection =
						Vector3.zero
					state.lastPlaybackSpeed = 0

					statusLabel.Text =
						"Status: Playing"

					humanoid:Move(
						Vector3.zero,
						false
					)
				else
					humanoid.WalkSpeed =
						state.approachSpeed

					humanoid:Move(
						direction,
						false
					)

					updateSafePoint()
				end

				return
			end

			local directionMultiplier =
				state.playbackDirection

			local movementDirection, recordedSpeed =
				getMovement(
					state.playbackIndex,
					directionMultiplier
				)

			if movementDirection.Magnitude > 0 then
				local smoothedDirection =
					state.lastPlaybackDirection

				if smoothedDirection.Magnitude <= 0 then
					smoothedDirection =
						movementDirection
				else
					smoothedDirection =
						smoothedDirection:Lerp(
							movementDirection,
							math.clamp(
								dt * 12,
								0,
								1
							)
						)
				end

				if smoothedDirection.Magnitude > 0 then
					smoothedDirection =
						smoothedDirection.Unit
				end

				state.lastPlaybackDirection =
					smoothedDirection

				local targetSpeed =
					math.clamp(
						recordedSpeed,
						1,
						200
					)

				local smoothSpeed =
					state.lastPlaybackSpeed

				if smoothSpeed <= 0 then
					smoothSpeed =
						targetSpeed
				else
					smoothSpeed =
						smoothSpeed
						+ (targetSpeed - smoothSpeed)
						* math.clamp(
							dt * 10,
							0,
							1
						)
				end

				state.lastPlaybackSpeed =
					smoothSpeed

				humanoid.WalkSpeed =
					smoothSpeed

				humanoid:Move(
					smoothedDirection,
					false
				)

				state.playbackIndex +=
					state.playbackDirection

				if state.playbackIndex >=
					#state.recordedFrames then

					state.playbackIndex =
						#state.recordedFrames

					if state.isLooping then
						state.playbackDirection = -1
					else
						humanoid:Move(
							Vector3.zero,
							false
						)

						finishPlayback()
						return
					end

				elseif state.playbackIndex <= 1 then

					state.playbackIndex = 1

					if state.isLooping then
						state.playbackDirection = 1
					else
						humanoid:Move(
							Vector3.zero,
							false
						)

						finishPlayback()
						return
					end
				end
			else
				humanoid:Move(
					Vector3.zero,
					false
				)

				state.playbackIndex +=
					state.playbackDirection

				if state.playbackIndex >=
					#state.recordedFrames then

					state.playbackIndex =
						#state.recordedFrames

					if state.isLooping then
						state.playbackDirection = -1
					else
						finishPlayback()
						return
					end

				elseif state.playbackIndex <= 1 then

					state.playbackIndex = 1

					if state.isLooping then
						state.playbackDirection = 1
					else
						finishPlayback()
						return
					end
				end
			end

			state.jumpCooldown =
				math.max(
					0,
					state.jumpCooldown - dt
				)

			local currentIndex =
				math.clamp(
					state.playbackIndex,
					1,
					#state.recordedFrames
				)

			local nextIndex =
				math.clamp(
					currentIndex
						+ state.playbackDirection,
					1,
					#state.recordedFrames
				)

			local currentFrame =
				state.recordedFrames[currentIndex]

			local nextFrame =
				state.recordedFrames[nextIndex]

			if currentFrame
				and nextFrame
				and currentFrame.grounded
				and not nextFrame.grounded
				and state.jumpCooldown <= 0 then

				local heightDifference =
					nextFrame.position.Y
					- currentFrame.position.Y

				if heightDifference > 0.35 then
					humanoid.Jump = true
					state.jumpCooldown = 0.35
				end
			end

			updateSafePoint()
		end)
end

local function stopRecording()
	state.isRecording = false

	if state.recordConnection then
		state.recordConnection:Disconnect()
		state.recordConnection = nil
	end

	btnRecord.Text = "● RECORD"
	btnRecord.BackgroundColor3 =
		Color3.fromRGB(180, 40, 40)

	statusLabel.Text =
		"Status: Recorded "
		.. tostring(#state.recordedFrames)
		.. " frames"

	rebuildVisualPath()
end

local function startRecording()
	if state.isPlaying or state.isRecording then
		return
	end

	state.isRecording = true
	state.recordedFrames = {}
	state.safePoints = {}
	state.lastSafePosition = nil
	state.lastSafeRotation = nil

	clearVisualPath()

	frameCountLabel.Text = "Frames: 0"

	btnRecord.Text = "● RECORDING..."
	btnRecord.BackgroundColor3 =
		Color3.fromRGB(255, 50, 50)

	statusLabel.Text = "Status: Recording"

	recordFrame()
	updateSafePoint()

	local accumulator = 0

	if state.recordConnection then
		state.recordConnection:Disconnect()
	end

	state.recordConnection =
		RunService.Heartbeat:Connect(function(dt)
			if not state.isRecording then
				return
			end

			accumulator += dt

			while accumulator >= recordRate do
				accumulator -= recordRate
				recordFrame()
			end

			updateSafePoint()
		end)
end

local function toggleRecord()
	if state.isRecording then
		stopRecording()
	else
		startRecording()
	end
end

local function togglePlayback()
	if state.isPlaying then
		stopPlayback()
	else
		startPlayback()
	end
end

local function stopEverything()
	if state.isRecording then
		stopRecording()
	end

	if state.isPlaying then
		stopPlayback()
	end

	if humanoid then
		humanoid:Move(Vector3.zero, false)
	end

	statusLabel.Text = "Status: Idle"
end

local function toggleAutoWalk()
	state.isAutoWalk = not state.isAutoWalk

	if state.isAutoWalk then
		btnAutoWalk.Text = "◆ AUTO WALK ON"
		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(40, 120, 40)

		humanoid.WalkSpeed =
			state.autoWalkSpeed
	else
		btnAutoWalk.Text = "◇ AUTO WALK OFF"
		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(60, 60, 80)

		humanoid:Move(
			Vector3.zero,
			false
		)
	end
end

local function toggleLoop()
	state.isLooping = not state.isLooping

	if state.isLooping then
		btnLoop.Text = "↻ LOOP ON"
		btnLoop.BackgroundColor3 =
			Color3.fromRGB(40, 120, 40)
	else
		btnLoop.Text = "↻ LOOP OFF"
		btnLoop.BackgroundColor3 =
			Color3.fromRGB(60, 60, 80)
	end
end

local function toggleVisualLine()
	showVisualLine = not showVisualLine

	if showVisualLine then
		btnToggleLine.Text =
			"◉ VISUAL LINE ON"

		btnToggleLine.BackgroundColor3 =
			Color3.fromRGB(60, 80, 60)

		rebuildVisualPath()
	else
		btnToggleLine.Text =
			"○ VISUAL LINE OFF"

		btnToggleLine.BackgroundColor3 =
			Color3.fromRGB(80, 60, 60)

		clearVisualPath()
	end
end

btnRecord.MouseButton1Click:Connect(toggleRecord)

btnPlay.MouseButton1Click:Connect(togglePlayback)

btnStop.MouseButton1Click:Connect(stopEverything)

btnRollback.MouseButton1Click:Connect(function()
	if state.isPlaying then
		stopPlayback()
	end

	rollbackToSafe()
end)

btnClear.MouseButton1Click:Connect(function()
	if state.isRecording then
		stopRecording()
	end

	if state.isPlaying then
		stopPlayback()
	end

	state.recordedFrames = {}
	state.safePoints = {}
	state.lastSafePosition = nil
	state.lastSafeRotation = nil

	clearVisualPath()

	frameCountLabel.Text = "Frames: 0"
	statusLabel.Text = "Status: Cleared"
end)

btnAutoWalk.MouseButton1Click:Connect(toggleAutoWalk)

btnLoop.MouseButton1Click:Connect(toggleLoop)

btnToggleLine.MouseButton1Click:Connect(toggleVisualLine)

speedBox.FocusLost:Connect(function()
	local value =
		tonumber(speedBox.Text) or 16

	value =
		math.clamp(value, 1, 200)

	state.autoWalkSpeed = value
	state.approachSpeed = value

	speedBox.Text =
		tostring(value)

	speedLabel.Text =
		"Speed: " .. tostring(value)

	if not state.isPlaying then
		humanoid.WalkSpeed = value
	end
end)

jumpBox.FocusLost:Connect(function()
	local value =
		tonumber(jumpBox.Text) or 50

	value =
		math.clamp(value, 10, 200)

	state.jumpPower = value

	jumpBox.Text =
		tostring(value)

	jumpLabel.Text =
		"JumpPower: " .. tostring(value)

	humanoid.JumpPower = value
end)

fallBox.FocusLost:Connect(function()
	local value =
		tonumber(fallBox.Text) or 1

	value =
		math.clamp(value, 0.5, 10)

	state.fallMultiplier = value

	fallBox.Text =
		tostring(value)

	fallLabel.Text =
		"FallMult: " .. tostring(value)
end)

rotBox.FocusLost:Connect(function()
	local value =
		tonumber(rotBox.Text) or 5

	value =
		math.clamp(value, 0.5, 20)

	state.rotateSpeed = value

	rotBox.Text =
		tostring(value)

	rotLabel.Text =
		"RotSpeed: " .. tostring(value)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F5 then
		toggleRecord()

	elseif input.KeyCode == Enum.KeyCode.F6 then
		togglePlayback()

	elseif input.KeyCode == Enum.KeyCode.F7 then
		if state.isPlaying then
			stopPlayback()
		end

		rollbackToSafe()

	elseif input.KeyCode == Enum.KeyCode.F8 then
		toggleAutoWalk()

	elseif input.KeyCode == Enum.KeyCode.F9 then
		stopEverything()

	elseif input.KeyCode == Enum.KeyCode.F10 then
		toggleVisualLine()

	elseif input.KeyCode == Enum.KeyCode.F11 then
		toggleLoop()
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	if state.recordConnection then
		state.recordConnection:Disconnect()
		state.recordConnection = nil
	end

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end

	state.isRecording = false
	state.isPlaying = false
	state.playbackStarted = false
	state.isAutoWalk = false

	setupCharacter(newCharacter)

	btnRecord.Text = "● RECORD"
	btnRecord.BackgroundColor3 =
		Color3.fromRGB(180, 40, 40)

	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(40, 120, 40)

	btnAutoWalk.Text =
		"◇ AUTO WALK OFF"

	btnAutoWalk.BackgroundColor3 =
		Color3.fromRGB(60, 60, 80)

	statusLabel.Text =
		"Status: Character respawned"
end)

RunService.Heartbeat:Connect(function()
	if not character
		or not humanoid
		or not rootPart then
		return
	end

	if not state.isPlaying
		and not state.isRecording
		and not state.isAutoWalk then

		updateSafePoint()
	end

	if state.isAutoWalk
		and not state.isPlaying
		and not state.isRecording then

		local look =
			rootPart.CFrame.LookVector

		local direction =
			Vector3.new(
				look.X,
				0,
				look.Z
			)

		if direction.Magnitude > 0.01 then
			humanoid:Move(
				direction.Unit,
				false
			)
		end
	end
end)

humanoid.WalkSpeed =
	state.autoWalkSpeed

humanoid.JumpPower =
	state.jumpPower

statusLabel.Text =
	"Status: Ready - F5 Record | F6 Play | F7 Rollback | F8 AutoWalk | F11 Loop"

frameCountLabel.Text = "Frames: 0"

print("AldoVz")
