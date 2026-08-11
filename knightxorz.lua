local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local state = {
	isRecording = false,
	isPlaying = false,
	isAutoWalk = false,
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
	playbackStart = 0,
	playbackIndex = 1,
	walkTrack = nil
}

local showVisualLine = true
local recordInterval = 1 / 30

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimRecorderGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local pathFolder = Instance.new("Folder")
pathFolder.Name = "VisualPathLines"
pathFolder.Parent = workspace

local function makeFrame(name, parent, size, pos, color)
	local object = Instance.new("Frame")
	object.Name = name
	object.Size = size
	object.Position = pos
	object.BackgroundColor3 = color
	object.BackgroundTransparency = 0.15
	object.BorderSizePixel = 0
	object.Parent = parent
	return object
end

local function makeButton(name, parent, text, pos, size, color)
	local object = Instance.new("TextButton")
	object.Name = name
	object.Size = size
	object.Position = pos
	object.Text = text
	object.TextColor3 = Color3.fromRGB(255, 255, 255)
	object.TextSize = 14
	object.Font = Enum.Font.GothamBold
	object.BackgroundColor3 = color
	object.BorderSizePixel = 0
	object.Parent = parent
	return object
end

local function makeLabel(name, parent, text, pos, size)
	local object = Instance.new("TextLabel")
	object.Name = name
	object.Size = size
	object.Position = pos
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

local function makeSlider(name, parent, pos, defaultValue)
	local container = makeFrame(
		name .. "Container",
		parent,
		UDim2.new(0, 180, 0, 36),
		pos,
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
	UDim2.new(0, 220, 0, 520),
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

makeFrame(
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

makeFrame(
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

local function createPathSegment(p1, p2, color)
	local distance = (p2 - p1).Magnitude

	if distance <= 0.05 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "VisualPath"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Locked = true
	part.Material = Enum.Material.Neon
	part.Transparency = 0.25
	part.Color = color
	part.Size = Vector3.new(0.12, 0.12, distance)
	part.CFrame = CFrame.lookAt((p1 + p2) * 0.5, p2)
	part.Parent = pathFolder
end

local function rebuildVisualPath()
	clearVisualPath()

	if not showVisualLine then
		return
	end

	if #state.recordedFrames < 2 then
		return
	end

	for i = 1, #state.recordedFrames - 1 do
		local first = state.recordedFrames[i]
		local second = state.recordedFrames[i + 1]

		local alpha = i / (#state.recordedFrames - 1)

		local color = Color3.new(
			0.2 + 0.8 * alpha,
			0.5 + 0.5 * (1 - alpha),
			0.8
		)

		createPathSegment(
			first.pos,
			second.pos,
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
	if not rootPart then
		return
	end

	if not isGrounded() then
		return
	end

	state.lastSafePosition = rootPart.Position
	state.lastSafeRotation = rootPart.Orientation
end

local function rollbackToSafe()
	if not state.lastSafePosition then
		statusLabel.Text = "Status: No safe point"
		return
	end

	if not character then
		return
	end

	character:PivotTo(
		CFrame.new(state.lastSafePosition)
			* CFrame.Angles(
				0,
				math.rad(state.lastSafeRotation.Y),
				0
			)
	)

	statusLabel.Text = "Status: Rollback complete"
end

local function recordFrame()
	if not rootPart then
		return
	end

	table.insert(
		state.recordedFrames,
		{
			pos = rootPart.Position,
			cframe = rootPart.CFrame,
			time = os.clock()
		}
	)

	frameCountLabel.Text =
		"Frames: "
		.. tostring(#state.recordedFrames)

	if showVisualLine
		and #state.recordedFrames >= 2 then

		local a =
			state.recordedFrames[
				#state.recordedFrames - 1
			]

		local b =
			state.recordedFrames[
				#state.recordedFrames
			]

		createPathSegment(
			a.pos,
			b.pos,
			Color3.fromRGB(0, 200, 255)
		)
	end
end

local function getWalkAnimation()
	local animate = character:FindFirstChild("Animate")

	if not animate then
		return nil
	end

	local walk = animate:FindFirstChild("walk")

	if walk then
		local animation =
			walk:FindFirstChild("WalkAnim")

		if animation
			and animation:IsA("Animation") then
			return animation
		end
	end

	local run = animate:FindFirstChild("run")

	if run then
		local animation =
			run:FindFirstChild("RunAnim")

		if animation
			and animation:IsA("Animation") then
			return animation
		end
	end

	return nil
end

local function stopWalkAnimation()
	if state.walkTrack then
		pcall(function()
			state.walkTrack:Stop(0.1)
			state.walkTrack:Destroy()
		end)

		state.walkTrack = nil
	end
end

local function playWalkAnimation(speed)
	local animator =
		humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local animation = getWalkAnimation()

	if not animation then
		return
	end

	if state.walkTrack then
		if state.walkTrack.IsPlaying then
			state.walkTrack:AdjustSpeed(
				math.clamp(speed / 16, 0.5, 2.5)
			)
			return
		end
	end

	stopWalkAnimation()

	local success, track =
		pcall(function()
			return animator:LoadAnimation(animation)
		end)

	if not success or not track then
		return
	end

	track.Priority =
		Enum.AnimationPriority.Movement

	track.Looped = true

	track:Play(
		0.1,
		1,
		math.clamp(speed / 16, 0.5, 2.5)
	)

	state.walkTrack = track
end

local function startRecording()
	if state.isPlaying then
		return
	end

	state.isRecording = true
	state.recordedFrames = {}
	state.safePoints = {}
	state.lastSafePosition = nil
	state.lastSafeRotation = nil

	clearVisualPath()

	btnRecord.Text = "● RECORDING..."
	btnRecord.BackgroundColor3 =
		Color3.fromRGB(255, 50, 50)

	statusLabel.Text = "Status: Recording"
	frameCountLabel.Text = "Frames: 0"

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

			while accumulator >= recordInterval do
				accumulator -= recordInterval
				recordFrame()
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

local function stopPlayback()
	state.isPlaying = false

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end

	if humanoid then
		humanoid.AutoRotate = true
	end

	stopWalkAnimation()

	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(40, 120, 40)
end

local function startPlayback()
	if state.isRecording then
		return
	end

	if state.isPlaying then
		return
	end

	if #state.recordedFrames < 2 then
		statusLabel.Text =
			"Status: Not enough frames"
		return
	end

	state.isPlaying = true
	state.playbackIndex = 1
	state.playbackStart = os.clock()

	humanoid.AutoRotate = false

	stopWalkAnimation()

	local firstFrame =
		state.recordedFrames[1]

	character:PivotTo(firstFrame.cframe)

	btnPlay.Text = "⏸ PLAYING"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(200, 150, 40)

	statusLabel.Text = "Status: Playing"

	local totalDuration =
		state.recordedFrames[
			#state.recordedFrames
		].time
		- state.recordedFrames[1].time

	state.playbackConnection =
		RunService.Heartbeat:Connect(function()
			if not state.isPlaying then
				return
			end

			local elapsed =
				os.clock() - state.playbackStart

			if elapsed >= totalDuration then
				local last =
					state.recordedFrames[
						#state.recordedFrames
					]

				character:PivotTo(last.cframe)

				state.isPlaying = false

				if state.playbackConnection then
					state.playbackConnection:Disconnect()
					state.playbackConnection = nil
				end

				stopWalkAnimation()

				humanoid.AutoRotate = true

				btnPlay.Text = "▶ PLAY"
				btnPlay.BackgroundColor3 =
					Color3.fromRGB(40, 120, 40)

				statusLabel.Text =
					"Status: Playback complete"

				return
			end

			local targetTime =
				state.recordedFrames[1].time
				+ elapsed

			while
				state.playbackIndex
				< #state.recordedFrames - 1
				and state.recordedFrames[
					state.playbackIndex + 1
				].time <= targetTime
			do
				state.playbackIndex += 1
			end

			local first =
				state.recordedFrames[
					state.playbackIndex
				]

			local second =
				state.recordedFrames[
					math.min(
						state.playbackIndex + 1,
						#state.recordedFrames
					)
				]

			local duration =
				second.time - first.time

			local alpha = 0

			if duration > 0 then
				alpha =
					(targetTime - first.time)
					/ duration
			end

			alpha = math.clamp(alpha, 0, 1)

			local smooth =
				alpha
				* alpha
				* (3 - 2 * alpha)

			local targetCFrame =
				first.cframe:Lerp(
					second.cframe,
					smooth
				)

			character:PivotTo(targetCFrame)

			local distance =
				(
					second.pos
					- first.pos
				).Magnitude

			if distance > 0.01 then
				local speed = 16

				if duration > 0 then
					speed =
						distance / duration
				end

				playWalkAnimation(speed)
			else
				stopWalkAnimation()
			end
		end)
end

local function setAutoWalk(enabled)
	state.isAutoWalk = enabled

	if enabled then
		btnAutoWalk.Text =
			"◆ AUTO WALK ON"

		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(40, 120, 40)

		humanoid.WalkSpeed =
			state.autoWalkSpeed
	else
		btnAutoWalk.Text =
			"◇ AUTO WALK OFF"

		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(60, 60, 80)

		humanoid:Move(
			Vector3.zero,
			false
		)
	end
end

btnRecord.MouseButton1Click:Connect(function()
	if state.isRecording then
		stopRecording()
	else
		startRecording()
	end
end)

btnPlay.MouseButton1Click:Connect(function()
	if state.isPlaying then
		stopPlayback()
	else
		startPlayback()
	end
end)

btnStop.MouseButton1Click:Connect(function()
	if state.isRecording then
		stopRecording()
	end

	if state.isPlaying then
		stopPlayback()
	end

	statusLabel.Text = "Status: Idle"
end)

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

btnAutoWalk.MouseButton1Click:Connect(function()
	setAutoWalk(
		not state.isAutoWalk
	)
end)

btnToggleLine.MouseButton1Click:Connect(function()
	showVisualLine =
		not showVisualLine

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
end)

speedBox.FocusLost:Connect(function()
	local value =
		tonumber(speedBox.Text) or 16

	value =
		math.clamp(value, 1, 200)

	state.autoWalkSpeed = value

	speedBox.Text =
		tostring(value)

	speedLabel.Text =
		"Speed: "
		.. tostring(value)

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
		"JumpPower: "
		.. tostring(value)

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
		"FallMult: "
		.. tostring(value)
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
		"RotSpeed: "
		.. tostring(value)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F5 then
		if state.isRecording then
			stopRecording()
		else
			startRecording()
		end

	elseif input.KeyCode == Enum.KeyCode.F6 then
		if state.isPlaying then
			stopPlayback()
		else
			startPlayback()
		end

	elseif input.KeyCode == Enum.KeyCode.F7 then
		if state.isPlaying then
			stopPlayback()
		end

		rollbackToSafe()

	elseif input.KeyCode == Enum.KeyCode.F8 then
		setAutoWalk(
			not state.isAutoWalk
		)

	elseif input.KeyCode == Enum.KeyCode.F9 then
		if state.isRecording then
			stopRecording()
		end

		if state.isPlaying then
			stopPlayback()
		end

		statusLabel.Text = "Status: Idle"

	elseif input.KeyCode == Enum.KeyCode.F10 then
		showVisualLine =
			not showVisualLine

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

	character = newCharacter
	humanoid =
		character:WaitForChild("Humanoid")

	rootPart =
		character:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed =
		state.autoWalkSpeed

	humanoid.JumpPower =
		state.jumpPower

	humanoid.AutoRotate = true

	stopWalkAnimation()

	btnRecord.Text = "● RECORD"
	btnPlay.Text = "▶ PLAY"

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
		and not state.isRecording then

		updateSafePoint()
	end

	if state.isAutoWalk
		and not state.isPlaying
		and not state.isRecording then

		local direction =
			rootPart.CFrame.LookVector

		direction =
			Vector3.new(
				direction.X,
				0,
				direction.Z
			)

		if direction.Magnitude > 0 then
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
	"Status: Ready - F5 Record | F6 Play | F7 Rollback | F8 AutoWalk"

frameCountLabel.Text = "Frames: 0"

print("AldoVz")
