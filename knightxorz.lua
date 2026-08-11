local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
	RecordFPS = 30,
	PlayFPS = 60,
	MaxFrames = 9000,
	MaxSafePoints = 50,
	SafePointInterval = 0.2,
	ArrivalDistance = 2.5,
	SnapDistance = 18,
	MinSpeed = 1,
	MaxSpeed = 100,
	JumpPowerMin = 10,
	JumpPowerMax = 150,
	FallMultiplierMin = 0.5,
	FallMultiplierMax = 5,
	RotationMin = 0.5,
	RotationMax = 15,
	DirectionLookAhead = 0.12,
	JumpHeightThreshold = 1.5,
	JumpVelocityThreshold = 10,
	JumpCooldown = 0.35,
	PlaybackCorrection = 16,
	ApproachAcceleration = 10,
	PathPointLimit = 250,
	PathThickness = 0.08,
	MaxDeltaTime = 0.1,
	MinUIScale = 0.72,
	MaxUIScale = 1.05,
	ReferenceHeight = 700
}

local RECORD_INTERVAL = 1 / CONFIG.RecordFPS
local PLAY_INTERVAL = 1 / CONFIG.PlayFPS

local character
local humanoid
local rootPart

local connections = {}

local state = {
	recording = false,
	playing = false,
	autoWalk = false,
	looping = false,
	pingPong = false,

	speed = 16,
	jumpPower = 50,
	fallMultiplier = 1,
	rotationSpeed = 5,

	frames = {},
	frameCount = 0,

	safePoints = {},
	lastSafeCFrame = nil,

	recordElapsed = 0,
	recordAccumulator = 0,
	safeTimer = 0,

	playbackTime = 0,
	playbackDirection = 1,
	playbackStarted = false,
	playAccumulator = 0,
	jumpCooldown = 0,

	lastFallVelocity = nil
}

local showPath = true

local function disconnect(name)
	local connection = connections[name]

	if connection then
		connection:Disconnect()
		connections[name] = nil
	end
end

local function connect(name, connection)
	disconnect(name)
	connections[name] = connection
end

local function isCharacterValid()
	return character
		and character.Parent
		and humanoid
		and humanoid.Parent
		and rootPart
		and rootPart.Parent
end

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")

	humanoid.UseJumpPower = true
	humanoid.WalkSpeed = state.speed
	humanoid.JumpPower = state.jumpPower
	humanoid.AutoRotate = true

	state.lastFallVelocity = nil
end

setupCharacter(player.Character or player.CharacterAdded:Wait())

local oldGui = playerGui:FindFirstChild("ProfessionalMobileRecorder")

if oldGui then
	oldGui:Destroy()
end

local oldPath = workspace:FindFirstChild("ProfessionalRecorderPath")

if oldPath then
	oldPath:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ProfessionalMobileRecorder"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(240, 510)
main.Position = UDim2.new(0, 12, 0.5, -255)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.55
stroke.Color = Color3.fromRGB(90, 90, 110)
stroke.Parent = main

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = main

local function makeLabel(text, position, size)
	local label = Instance.new("TextLabel")
	label.Size = size or UDim2.fromOffset(220, 22)
	label.Position = position
	label.Text = text
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = main
	return label
end

local function makeButton(text, position, size, color)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	return button
end

local function makeBox(value, position)
	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(100, 28)
	box.Position = position
	box.Text = tostring(value)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 13
	box.Font = Enum.Font.Gotham
	box.BackgroundColor3 = Color3.fromRGB(52, 52, 64)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = box

	return box
end

local title = makeLabel(
	"MOBILE MOTION RECORDER",
	UDim2.fromOffset(4, 0),
	UDim2.fromOffset(220, 26)
)

title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(100, 200, 255)

local recordButton = makeButton(
	"● RECORD",
	UDim2.fromOffset(0, 34),
	UDim2.fromOffset(105, 34),
	Color3.fromRGB(175, 45, 45)
)

local playButton = makeButton(
	"▶ PLAY",
	UDim2.fromOffset(115, 34),
	UDim2.fromOffset(105, 34),
	Color3.fromRGB(45, 120, 55)
)

local stopButton = makeButton(
	"■ STOP",
	UDim2.fromOffset(0, 74),
	UDim2.fromOffset(105, 34),
	Color3.fromRGB(75, 75, 88)
)

local rollbackButton = makeButton(
	"↩ ROLLBACK",
	UDim2.fromOffset(115, 74),
	UDim2.fromOffset(105, 34),
	Color3.fromRGB(45, 85, 160)
)

local clearButton = makeButton(
	"✕ CLEAR RECORDING",
	UDim2.fromOffset(0, 114),
	UDim2.fromOffset(220, 32),
	Color3.fromRGB(105, 45, 45)
)

local autoButton = makeButton(
	"◇ AUTO WALK OFF",
	UDim2.fromOffset(0, 152),
	UDim2.fromOffset(220, 32)
)

local loopButton = makeButton(
	"↻ LOOP OFF",
	UDim2.fromOffset(0, 190),
	UDim2.fromOffset(105, 32)
)

local pingButton = makeButton(
	"⇄ PING OFF",
	UDim2.fromOffset(115, 190),
	UDim2.fromOffset(105, 32)
)

local lineButton = makeButton(
	"◉ PATH ON",
	UDim2.fromOffset(0, 228),
	UDim2.fromOffset(220, 32),
	Color3.fromRGB(50, 85, 60)
)

makeLabel("Speed", UDim2.fromOffset(0, 270))
local speedBox = makeBox(16, UDim2.fromOffset(120, 266))

makeLabel("Jump Power", UDim2.fromOffset(0, 306))
local jumpBox = makeBox(50, UDim2.fromOffset(120, 302))

makeLabel("Fall Multiplier", UDim2.fromOffset(0, 342))
local fallBox = makeBox(1, UDim2.fromOffset(120, 338))

makeLabel("Rotation", UDim2.fromOffset(0, 378))
local rotationBox = makeBox(5, UDim2.fromOffset(120, 374))

local statusLabel = makeLabel(
	"Status: Ready",
	UDim2.fromOffset(0, 414),
	UDim2.fromOffset(220, 22)
)

statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

local framesLabel = makeLabel(
	"Frames: 0",
	UDim2.fromOffset(0, 438),
	UDim2.fromOffset(220, 22)
)

local timeLabel = makeLabel(
	"Time: 0.00s",
	UDim2.fromOffset(0, 462),
	UDim2.fromOffset(220, 22)
)

local pathFolder = Instance.new("Folder")
pathFolder.Name = "ProfessionalRecorderPath"
pathFolder.Parent = workspace

local function updateUIScale()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	scale.Scale = math.clamp(
		viewport.Y / CONFIG.ReferenceHeight,
		CONFIG.MinUIScale,
		CONFIG.MaxUIScale
	)
end

updateUIScale()

connect(
	"viewport",
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(updateUIScale)
	end)
)

local function clearPath()
	pathFolder:ClearAllChildren()
end

local function createSegment(a, b)
	local distance = (b - a).Magnitude

	if distance < 0.05 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "PathSegment"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Transparency = 0.45

	part.Size = Vector3.new(
		CONFIG.PathThickness,
		CONFIG.PathThickness,
		distance
	)

	part.CFrame = CFrame.lookAt(
		(a + b) * 0.5,
		b
	)

	part.Parent = pathFolder
end

local function rebuildPath()
	clearPath()

	if not showPath or state.frameCount < 2 then
		return
	end

	local step = math.max(
		1,
		math.ceil(
			state.frameCount / CONFIG.PathPointLimit
		)
	)

	local previous

	for i = 1, state.frameCount, step do
		local frame = state.frames[i]

		if previous then
			createSegment(previous, frame.position)
		end

		previous = frame.position
	end

	local last = state.frames[state.frameCount]

	if last and previous
		and (last.position - previous).Magnitude > 0.05 then

		createSegment(previous, last.position)
	end
end

local function isGrounded()
	return isCharacterValid()
		and humanoid.FloorMaterial ~= Enum.Material.Air
end

local function clearFrames()
	table.clear(state.frames)
	state.frameCount = 0
end

local function resetPlayback()
	state.playbackTime = 0
	state.playbackDirection = 1
	state.playbackStarted = false
	state.playAccumulator = 0
	state.jumpCooldown = 0
end

local function addSafePoint(force)
	if not isCharacterValid() then
		return
	end

	if not force and not isGrounded() then
		return
	end

	if not force
		and state.safeTimer < CONFIG.SafePointInterval then
		return
	end

	state.safeTimer = 0

	local cf = rootPart.CFrame

	state.safePoints[#state.safePoints + 1] = cf

	if #state.safePoints > CONFIG.MaxSafePoints then
		table.remove(state.safePoints, 1)
	end

	state.lastSafeCFrame = cf
end

local function recordFrame(timestamp)
	if not isCharacterValid() then
		return false
	end

	if state.frameCount >= CONFIG.MaxFrames then
		return false
	end

	state.frameCount += 1

	state.frames[state.frameCount] = {
		position = rootPart.Position,
		cframe = rootPart.CFrame,
		velocity = rootPart.AssemblyLinearVelocity,
		grounded = isGrounded(),
		humanoidState = humanoid:GetState().Name,
		time = timestamp
	}

	framesLabel.Text =
		"Frames: " .. state.frameCount

	return true
end

local function getDuration()
	if state.frameCount < 2 then
		return 0
	end

	return state.frames[state.frameCount].time
end

local function getFrame(time)
	local count = state.frameCount

	if count <= 0 then
		return nil
	end

	if count == 1 then
		return state.frames[1]
	end

	local frames = state.frames
	local total = frames[count].time

	if time <= 0 then
		return frames[1]
	end

	if time >= total then
		return frames[count]
	end

	local low = 1
	local high = count

	while low <= high do
		local middle = math.floor(
			(low + high) * 0.5
		)

		if frames[middle].time < time then
			low = middle + 1
		else
			high = middle - 1
		end
	end

	local bIndex = math.clamp(low, 2, count)
	local aIndex = bIndex - 1

	local a = frames[aIndex]
	local b = frames[bIndex]

	local deltaTime = b.time - a.time

	if deltaTime <= 0 then
		return a
	end

	local alpha = math.clamp(
		(time - a.time) / deltaTime,
		0,
		1
	)

	return {
		position = a.position:Lerp(b.position, alpha),
		cframe = a.cframe:Lerp(b.cframe, alpha),
		velocity = a.velocity:Lerp(b.velocity, alpha),
		grounded = alpha < 0.5 and a.grounded or b.grounded,
		humanoidState =
			alpha < 0.5
			and a.humanoidState
			or b.humanoidState
	}
end

local function getDirection(time)
	local current = getFrame(time)

	if not current then
		return Vector3.zero
	end

	local targetTime = math.clamp(
		time + CONFIG.DirectionLookAhead * state.playbackDirection,
		0,
		getDuration()
	)

	local target = getFrame(targetTime)

	if not target then
		return Vector3.zero
	end

	local delta = target.position - current.position

	local horizontal = Vector3.new(
		delta.X,
		0,
		delta.Z
	)

	if horizontal.Magnitude < 0.05 then
		return Vector3.zero
	end

	return horizontal.Unit
end

local function getRecordedSpeed(time)
	local current = getFrame(time)

	if not current then
		return state.speed
	end

	local nextTime = math.clamp(
		time + PLAY_INTERVAL * state.playbackDirection,
		0,
		getDuration()
	)

	local nextFrame = getFrame(nextTime)

	if not nextFrame then
		return state.speed
	end

	local deltaTime = math.abs(nextTime - time)

	if deltaTime <= 0.001 then
		return state.speed
	end

	local delta = nextFrame.position - current.position

	local horizontal = Vector3.new(
		delta.X,
		0,
		delta.Z
	)

	local speed = horizontal.Magnitude / deltaTime

	if speed < 0.1 then
		return state.speed
	end

	return math.clamp(
		speed,
		CONFIG.MinSpeed,
		CONFIG.MaxSpeed
	)
end

local function moveToFrame(frame, dt)
	if not frame or not isCharacterValid() then
		return
	end

	local currentPosition = rootPart.Position
	local distance = (frame.position - currentPosition).Magnitude

	if distance > CONFIG.SnapDistance then
		character:PivotTo(frame.cframe)
		rootPart.AssemblyLinearVelocity = frame.velocity
		return
	end

	local positionAlpha = math.clamp(
		1 - math.exp(-CONFIG.PlaybackCorrection * dt),
		0,
		1
	)

	local position = currentPosition:Lerp(
		frame.position,
		positionAlpha
	)

	local currentRotation =
		rootPart.CFrame - rootPart.Position

	local targetRotation =
		frame.cframe - frame.cframe.Position

	local rotationAlpha = math.clamp(
		1 - math.exp(-state.rotationSpeed * dt),
		0,
		1
	)

	local rotation = currentRotation:Lerp(
		targetRotation,
		rotationAlpha
	)

	character:PivotTo(
		CFrame.new(position) * rotation
	)
end

local function approachStart(dt)
	local first = state.frames[1]

	if not first or not isCharacterValid() then
		return false
	end

	local delta = first.position - rootPart.Position

	local horizontal = Vector3.new(
		delta.X,
		0,
		delta.Z
	)

	local distance = horizontal.Magnitude

	if distance <= CONFIG.ArrivalDistance then
		character:PivotTo(first.cframe)

		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero

		state.playbackStarted = true
		state.playbackTime = 0
		state.playAccumulator = 0

		statusLabel.Text = "Status: Playing"

		return true
	end

	if horizontal.Magnitude > 0.05 then
		local direction = horizontal.Unit

		humanoid.WalkSpeed = math.clamp(
			distance * 2,
			CONFIG.MinSpeed,
			state.speed
		)

		humanoid:Move(direction, false)

		local targetRotation = CFrame.lookAt(
			rootPart.Position,
			rootPart.Position + direction
		)

		local alpha = math.clamp(
			1 - math.exp(-CONFIG.ApproachAcceleration * dt),
			0,
			1
		)

		character:PivotTo(
			rootPart.CFrame:Lerp(
				targetRotation,
				alpha
			)
		)
	end

	return false
end

local function processJump(currentFrame, nextFrame)
	if not currentFrame
		or not nextFrame
		or not isCharacterValid() then
		return
	end

	if state.jumpCooldown > 0 then
		return
	end

	if not isGrounded() then
		return
	end

	local heightDelta =
		nextFrame.position.Y
		- currentFrame.position.Y

	local shouldJump =
		heightDelta >= CONFIG.JumpHeightThreshold
		or nextFrame.velocity.Y >= CONFIG.JumpVelocityThreshold
		or nextFrame.humanoidState == "Jumping"

	if shouldJump then
		humanoid.Jump = true
		state.jumpCooldown = CONFIG.JumpCooldown
	end
end

local function stopPlayback(message)
	state.playing = false
	state.playbackStarted = false
	state.playAccumulator = 0

	disconnect("playback")

	if isCharacterValid() then
		humanoid:Move(Vector3.zero, false)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = state.speed
	end

	playButton.Text = "▶ PLAY"
	playButton.BackgroundColor3 = Color3.fromRGB(45, 120, 55)

	statusLabel.Text = message or "Status: Stopped"
end

local function finishPlayback()
	if not state.looping then
		stopPlayback("Status: Complete")
		return
	end

	if state.pingPong then
		state.playbackDirection *= -1

		if state.playbackDirection > 0 then
			state.playbackTime = 0
		else
			state.playbackTime = getDuration()
		end
	else
		state.playbackDirection = 1
		state.playbackTime = 0
	end

	state.playAccumulator = 0
	state.jumpCooldown = 0
end

local function startPlayback()
	if state.recording or state.playing then
		return
	end

	if state.frameCount < 2 then
		statusLabel.Text = "Status: Need recording"
		return
	end

	if not isCharacterValid() then
		statusLabel.Text = "Status: Character unavailable"
		return
	end

	state.playing = true
	state.playbackStarted = false
	state.playbackTime = 0
	state.playbackDirection = 1
	state.playAccumulator = 0
	state.jumpCooldown = 0

	humanoid.AutoRotate = false

	playButton.Text = "■ PLAYING"
	playButton.BackgroundColor3 = Color3.fromRGB(190, 140, 40)

	statusLabel.Text = "Status: Going to start"

	connect(
		"playback",
		RunService.Heartbeat:Connect(function(dt)
			if not state.playing then
				return
			end

			dt = math.min(dt, CONFIG.MaxDeltaTime)

			if not isCharacterValid() then
				stopPlayback("Status: Character unavailable")
				return
			end

			local total = getDuration()

			if total <= 0 then
				stopPlayback("Status: Invalid recording")
				return
			end

			if not state.playbackStarted then
				approachStart(dt)
				return
			end

			state.playAccumulator += dt

			local current = getFrame(state.playbackTime)

			if not current then
				stopPlayback("Status: Playback error")
				return
			end

			state.jumpCooldown =
				math.max(0, state.jumpCooldown - dt)

			local substeps = 0

			while state.playAccumulator >= PLAY_INTERVAL
				and substeps < 6 do

				state.playAccumulator -= PLAY_INTERVAL
				substeps += 1

				local nextTime = math.clamp(
					state.playbackTime
						+ PLAY_INTERVAL * state.playbackDirection,
					0,
					total
				)

				local nextFrame = getFrame(nextTime)

				processJump(current, nextFrame)

				state.playbackTime = nextTime

				if state.playbackDirection > 0
					and state.playbackTime >= total then

					state.playbackTime = total
					finishPlayback()
					break

				elseif state.playbackDirection < 0
					and state.playbackTime <= 0 then

					state.playbackTime = 0
					finishPlayback()
					break
				end

				current = getFrame(state.playbackTime)

				if not current then
					break
				end
			end

			if not state.playing then
				return
			end

			local displayFrame =
				getFrame(state.playbackTime)

			if not displayFrame then
				return
			end

			moveToFrame(displayFrame, dt)

			local direction =
				getDirection(state.playbackTime)

			if direction.Magnitude > 0.05 then
				humanoid.WalkSpeed =
					getRecordedSpeed(state.playbackTime)
			else
				humanoid.WalkSpeed = state.speed
			end

			local recordedVelocity =
				displayFrame.velocity

			local velocity =
				rootPart.AssemblyLinearVelocity

			if displayFrame.grounded then
				rootPart.AssemblyLinearVelocity =
					Vector3.new(
						velocity.X,
						math.max(velocity.Y, -2),
						velocity.Z
					)
			elseif recordedVelocity.Y < 0 then
				rootPart.AssemblyLinearVelocity =
					Vector3.new(
						velocity.X,
						recordedVelocity.Y
							* state.fallMultiplier,
						velocity.Z
					)
			end

			timeLabel.Text = string.format(
				"Time: %.2fs / %.2fs",
				state.playbackTime,
				total
			)
		end)
	)
end

local function stopRecording()
	if not state.recording then
		return
	end

	state.recording = false

	disconnect("recording")

	recordButton.Text = "● RECORD"
	recordButton.BackgroundColor3 = Color3.fromRGB(175, 45, 45)

	if state.frameCount > 1 then
		statusLabel.Text =
			"Status: Recorded "
			.. state.frameCount
			.. " frames"

		rebuildPath()
	else
		statusLabel.Text = "Status: Recording too short"
		clearFrames()
	end
end

local function startRecording()
	if state.recording or state.playing then
		return
	end

	if not isCharacterValid() then
		statusLabel.Text = "Status: Character unavailable"
		return
	end

	state.recording = true

	clearFrames()

	state.safePoints = {}
	state.lastSafeCFrame = nil

	state.recordElapsed = 0
	state.recordAccumulator = 0
	state.safeTimer = 0

	resetPlayback()
	clearPath()

	framesLabel.Text = "Frames: 0"
	timeLabel.Text = "Time: 0.00s"

	recordButton.Text = "● RECORDING"
	recordButton.BackgroundColor3 = Color3.fromRGB(240, 45, 45)

	statusLabel.Text = "Status: Recording"

	recordFrame(0)
	addSafePoint(true)

	connect(
		"recording",
		RunService.Heartbeat:Connect(function(dt)
			if not state.recording then
				return
			end

			dt = math.min(dt, CONFIG.MaxDeltaTime)

			if not isCharacterValid() then
				stopRecording()
				statusLabel.Text = "Status: Character unavailable"
				return
			end

			state.recordElapsed += dt
			state.recordAccumulator += dt
			state.safeTimer += dt

			while state.recordAccumulator >= RECORD_INTERVAL do
				state.recordAccumulator -= RECORD_INTERVAL

				local timestamp =
					state.recordElapsed
					- state.recordAccumulator

				if not recordFrame(timestamp) then
					stopRecording()
					statusLabel.Text = "Status: Frame limit reached"
					return
				end
			end

			addSafePoint(false)

			timeLabel.Text = string.format(
				"Time: %.2fs",
				state.recordElapsed
			)

			if state.frameCount >= CONFIG.MaxFrames then
				stopRecording()
				statusLabel.Text = "Status: Frame limit reached"
			end
		end)
	)
end

local function stopEverything()
	if state.recording then
		stopRecording()
	end

	if state.playing then
		stopPlayback()
	end

	if isCharacterValid() then
		humanoid:Move(Vector3.zero, false)
		humanoid.WalkSpeed = state.speed
		humanoid.AutoRotate = true
	end

	statusLabel.Text = "Status: Idle"
end

local function rollback()
	if not isCharacterValid()
		or not state.lastSafeCFrame then

		statusLabel.Text = "Status: No safe point"
		return
	end

	stopEverything()

	character:PivotTo(state.lastSafeCFrame)

	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	humanoid:Move(Vector3.zero, false)
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = state.speed

	resetPlayback()

	statusLabel.Text = "Status: Rolled back"
end

local function toggleRecord()
	if state.recording then
		stopRecording()
	else
		startRecording()
	end
end

local function togglePlay()
	if state.playing then
		stopPlayback()
	else
		startPlayback()
	end
end

local function toggleAutoWalk()
	state.autoWalk = not state.autoWalk

	if state.autoWalk then
		autoButton.Text = "◆ AUTO WALK ON"
		autoButton.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
	else
		autoButton.Text = "◇ AUTO WALK OFF"
		autoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

		if isCharacterValid() then
			humanoid:Move(Vector3.zero, false)
		end
	end
end

local function toggleLoop()
	state.looping = not state.looping

	if state.looping then
		loopButton.Text = "↻ LOOP ON"
		loopButton.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
	else
		loopButton.Text = "↻ LOOP OFF"
		loopButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	end
end

local function togglePingPong()
	state.pingPong = not state.pingPong

	if state.pingPong then
		state.looping = true

		pingButton.Text = "⇄ PING ON"
		pingButton.BackgroundColor3 = Color3.fromRGB(40, 120, 55)

		loopButton.Text = "↻ LOOP ON"
		loopButton.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
	else
		pingButton.Text = "⇄ PING OFF"
		pingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	end
end

local function togglePath()
	showPath = not showPath

	if showPath then
		lineButton.Text = "◉ PATH ON"
		lineButton.BackgroundColor3 = Color3.fromRGB(50, 85, 60)
		rebuildPath()
	else
		lineButton.Text = "○ PATH OFF"
		lineButton.BackgroundColor3 = Color3.fromRGB(80, 55, 55)
		clearPath()
	end
end

local function applySpeed(value)
	local number = tonumber(value)

	if not number then
		speedBox.Text = tostring(state.speed)
		return
	end

	state.speed = math.clamp(
		number,
		CONFIG.MinSpeed,
		CONFIG.MaxSpeed
	)

	speedBox.Text = tostring(state.speed)

	if not state.playing
		and isCharacterValid() then

		humanoid.WalkSpeed = state.speed
	end
end

local function applyJump(value)
	local number = tonumber(value)

	if not number then
		jumpBox.Text = tostring(state.jumpPower)
		return
	end

	state.jumpPower = math.clamp(
		number,
		CONFIG.JumpPowerMin,
		CONFIG.JumpPowerMax
	)

	jumpBox.Text = tostring(state.jumpPower)

	if isCharacterValid() then
		humanoid.JumpPower = state.jumpPower
	end
end

local function applyFall(value)
	local number = tonumber(value)

	if not number then
		fallBox.Text = tostring(state.fallMultiplier)
		return
	end

	state.fallMultiplier = math.clamp(
		number,
		CONFIG.FallMultiplierMin,
		CONFIG.FallMultiplierMax
	)

	fallBox.Text = tostring(state.fallMultiplier)
end

local function applyRotation(value)
	local number = tonumber(value)

	if not number then
		rotationBox.Text = tostring(state.rotationSpeed)
		return
	end

	state.rotationSpeed = math.clamp(
		number,
		CONFIG.RotationMin,
		CONFIG.RotationMax
	)

	rotationBox.Text = tostring(state.rotationSpeed)
end

local function clearRecording()
	stopEverything()

	clearFrames()

	state.safePoints = {}
	state.lastSafeCFrame = nil

	resetPlayback()
	clearPath()

	framesLabel.Text = "Frames: 0"
	timeLabel.Text = "Time: 0.00s"
	statusLabel.Text = "Status: Cleared"
end

recordButton.Activated:Connect(toggleRecord)
playButton.Activated:Connect(togglePlay)
stopButton.Activated:Connect(stopEverything)
rollbackButton.Activated:Connect(rollback)
clearButton.Activated:Connect(clearRecording)

autoButton.Activated:Connect(toggleAutoWalk)
loopButton.Activated:Connect(toggleLoop)
pingButton.Activated:Connect(togglePingPong)
lineButton.Activated:Connect(togglePath)

speedBox.FocusLost:Connect(function()
	applySpeed(speedBox.Text)
end)

jumpBox.FocusLost:Connect(function()
	applyJump(jumpBox.Text)
end)

fallBox.FocusLost:Connect(function()
	applyFall(fallBox.Text)
end)

rotationBox.FocusLost:Connect(function()
	applyRotation(rotationBox.Text)
end)

local menuButton = Instance.new("TextButton")
menuButton.Size = UDim2.fromOffset(48, 48)
menuButton.Position = UDim2.new(1, -60, 0, 12)
menuButton.Text = "☰"
menuButton.TextSize = 23
menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
menuButton.Font = Enum.Font.GothamBold
menuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
menuButton.BorderSizePixel = 0
menuButton.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuButton

menuButton.Activated:Connect(function()
	main.Visible = not main.Visible
end)

local dragging = false
local dragStart
local startPosition

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch
		and input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragStart

	main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

connect(
	"character",
	player.CharacterAdded:Connect(function(char)
		disconnect("recording")
		disconnect("playback")

		state.recording = false
		state.playing = false
		state.autoWalk = false

		resetPlayback()
		setupCharacter(char)

		recordButton.Text = "● RECORD"
		recordButton.BackgroundColor3 = Color3.fromRGB(175, 45, 45)

		playButton.Text = "▶ PLAY"
		playButton.BackgroundColor3 = Color3.fromRGB(45, 120, 55)

		autoButton.Text = "◇ AUTO WALK OFF"
		autoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

		statusLabel.Text = "Status: Respawned"
	end)
)

connect(
	"heartbeat",
	RunService.Heartbeat:Connect(function(dt)
		if not isCharacterValid() then
			return
		end

		dt = math.min(dt, CONFIG.MaxDeltaTime)

		if not state.recording
			and not state.playing then

			state.safeTimer += dt
			addSafePoint(false)
		end

		if state.autoWalk
			and not state.recording
			and not state.playing then

			local look = rootPart.CFrame.LookVector

			local direction = Vector3.new(
				look.X,
				0,
				look.Z
			)

			if direction.Magnitude > 0.05 then
				humanoid.WalkSpeed = state.speed
				humanoid:Move(direction.Unit, false)
			end
		end

		if not state.playing
			and state.fallMultiplier ~= 1
			and humanoid:GetState()
				== Enum.HumanoidStateType.Freefall then

			local velocity =
				rootPart.AssemblyLinearVelocity

			if velocity.Y < 0 then
				if not state.lastFallVelocity then
					state.lastFallVelocity = velocity.Y
				end

				local target =
					state.lastFallVelocity
					* state.fallMultiplier

				rootPart.AssemblyLinearVelocity =
					Vector3.new(
						velocity.X,
						target,
						velocity.Z
					)
			else
				state.lastFallVelocity = nil
			end
		else
			state.lastFallVelocity = nil
		end
	end)
)

UserInputService.TouchStarted:Connect(function()
	if main.Visible then
		main.Active = true
	end
end)

statusLabel.Text = "Status: Ready"
framesLabel.Text = "Frames: 0"
timeLabel.Text = "Time: 0.00s"

speedBox.Text = tostring(state.speed)
jumpBox.Text = tostring(state.jumpPower)
fallBox.Text = tostring(state.fallMultiplier)
rotationBox.Text = tostring(state.rotationSpeed)
