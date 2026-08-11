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
	autoWalkSpeed = 16,
	jumpPower = 50,
	fallMultiplier = 1,
	rotateSpeed = 5,
	recordedFrames = {},
	safePoints = {},
	lastSafePosition = nil,
	lastSafeRotation = nil,
	playbackIndex = 1,
	playbackStartTime = 0,
	recordConnection = nil,
	playbackConnection = nil,
	oldAutoRotate = true,
	walkTrack = nil
}

local showVisualLine = true

local LINE_HEIGHT = 0.06
local LINE_THICKNESS = 0.18
local RAY_START_HEIGHT = 8
local RAY_LENGTH = 30

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")

	animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
end

setupCharacter(player.Character or player.CharacterAdded:Wait())

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimRecorderGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local function makeFrame(name, parent, size, pos, color)
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = color
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function makeButton(name, parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = size
	b.Position = pos
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 14
	b.Font = Enum.Font.GothamBold
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Parent = parent
	return b
end

local function makeLabel(name, parent, text, pos, size)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = pos
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200, 200, 200)
	l.TextSize = 12
	l.Font = Enum.Font.Gotham
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeSlider(name, parent, pos, defaultValue)
	local container = makeFrame(
		name .. "Cont",
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
	box.Name = name .. "Slider"
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
	"BtnRecord",
	mainWindow,
	"● RECORD",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(180, 40, 40)
)

local btnPlay = makeButton(
	"BtnPlay",
	mainWindow,
	"▶ PLAY",
	UDim2.new(0, 110, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(40, 120, 40)
)

y = y + 34

local btnStop = makeButton(
	"BtnStop",
	mainWindow,
	"■ STOP",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(100, 100, 100)
)

local btnRollback = makeButton(
	"BtnRollback",
	mainWindow,
	"↩ ROLLBACK",
	UDim2.new(0, 110, 0, y),
	UDim2.new(0, 90, 0, 28),
	Color3.fromRGB(40, 80, 160)
)

y = y + 34

local btnClear = makeButton(
	"BtnClear",
	mainWindow,
	"✕ CLEAR ALL",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 24),
	Color3.fromRGB(80, 40, 40)
)

y = y + 30

makeFrame(
	"Sep1",
	mainWindow,
	UDim2.new(0, 200, 0, 1),
	UDim2.new(0, 10, 0, y),
	Color3.fromRGB(80, 80, 100)
)

y = y + 8

local btnAutoWalk = makeButton(
	"BtnAutoWalk",
	mainWindow,
	"◇ AUTO WALK OFF",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 26),
	Color3.fromRGB(60, 60, 80)
)

y = y + 30

local speedLabel, speedSlider =
	makeSlider("Speed", mainWindow, UDim2.new(0, 10, 0, y), 16)

y = y + 40

local jumpLabel, jumpSlider =
	makeSlider("JumpPower", mainWindow, UDim2.new(0, 10, 0, y), 50)

y = y + 40

local fallLabel, fallSlider =
	makeSlider("FallMult", mainWindow, UDim2.new(0, 10, 0, y), 1)

y = y + 40

local rotLabel, rotSlider =
	makeSlider("RotSpeed", mainWindow, UDim2.new(0, 10, 0, y), 5)

y = y + 40

makeFrame(
	"Sep2",
	mainWindow,
	UDim2.new(0, 200, 0, 1),
	UDim2.new(0, 10, 0, y),
	Color3.fromRGB(80, 80, 100)
)

y = y + 8

local statusLabel = makeLabel(
	"Status",
	mainWindow,
	"Status: Idle",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 200, 0, 16)
)

statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

y = y + 18

local frameCountLabel = makeLabel(
	"FrameCount",
	mainWindow,
	"Frames: 0",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 200, 0, 16)
)

y = y + 18

local btnToggleLine = makeButton(
	"BtnToggleLine",
	mainWindow,
	"◉ VISUAL LINE ON",
	UDim2.new(0, 10, 0, y),
	UDim2.new(0, 180, 0, 24),
	Color3.fromRGB(60, 80, 60)
)

local pathFolder = Instance.new("Folder")
pathFolder.Name = "VisualPathLines"
pathFolder.Parent = workspace

local function getLineSurface(position)
	local params = RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		character,
		pathFolder
	}

	params.IgnoreWater = false

	local result = workspace:Raycast(
		position + Vector3.new(0, RAY_START_HEIGHT, 0),
		Vector3.new(0, -RAY_LENGTH, 0),
		params
	)

	if result then
		return result.Position + result.Normal * LINE_HEIGHT
	end

	return position
end

local function clearVisualPath()
	for _, object in ipairs(pathFolder:GetChildren()) do
		object:Destroy()
	end
end

local function createPathSegment(p1, p2, color)
	local a = getLineSurface(p1)
	local b = getLineSurface(p2)

	local difference = b - a
	local distance = difference.Magnitude

	if distance < 0.03 then
		return
	end

	local middle = (a + b) * 0.5

	local part = Instance.new("Part")
	part.Name = "VisualPath"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Transparency = 0.18
	part.Color = color
	part.Size = Vector3.new(
		LINE_THICKNESS,
		LINE_THICKNESS,
		distance
	)
	part.CFrame = CFrame.lookAt(
		middle,
		b
	)
	part.Parent = pathFolder
end

local function createMarker(name, position, color)
	local surface = getLineSurface(position)

	local marker = Instance.new("Part")
	marker.Name = name
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(0.5, 0.5, 0.5)
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.CastShadow = false
	marker.Material = Enum.Material.Neon
	marker.Color = color
	marker.Position = surface
	marker.Parent = pathFolder
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
		local f1 = state.recordedFrames[i]
		local f2 = state.recordedFrames[i + 1]

		local t =
			i / math.max(
				#state.recordedFrames - 1,
				1
			)

		createPathSegment(
			f1.pos,
			f2.pos,
			Color3.new(
				0.2 + 0.8 * t,
				0.5 + 0.5 * (1 - t),
				0.8
			)
		)
	end

	createMarker(
		"StartMarker",
		state.recordedFrames[1].pos,
		Color3.fromRGB(0, 255, 0)
	)

	createMarker(
		"EndMarker",
		state.recordedFrames[#state.recordedFrames].pos,
		Color3.fromRGB(255, 0, 0)
	)
end

local function isGrounded()
	if not rootPart or not character then
		return false
	end

	local params = RaycastParams.new()
	params.FilterType =
		Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances =
		{character}

	local result = workspace:Raycast(
		rootPart.Position + Vector3.new(0, 1, 0),
		Vector3.new(0, -4.5, 0),
		params
	)

	return result ~= nil
end

local function updateSafePoint()
	if not rootPart then
		return
	end

	if not isGrounded() then
		return
	end

	state.lastSafePosition =
		rootPart.Position

	state.lastSafeRotation =
		rootPart.Orientation
end

local function rollbackToSafe()
	if not rootPart or not state.lastSafePosition then
		statusLabel.Text = "Status: No safe point"
		return
	end

	local rotationY = 0

	if state.lastSafeRotation then
		rotationY =
			math.rad(
				state.lastSafeRotation.Y
			)
	end

	rootPart.AssemblyLinearVelocity =
		Vector3.zero

	rootPart.AssemblyAngularVelocity =
		Vector3.zero

	character:PivotTo(
		CFrame.new(
			state.lastSafePosition
		)
			* CFrame.Angles(
				0,
				rotationY,
				0
			)
	)

	statusLabel.Text =
		"Status: Rollback complete"
end

local function getWalkAnimation()
	if not character then
		return nil
	end

	local animate =
		character:FindFirstChild("Animate")

	if not animate then
		return nil
	end

	local runFolder =
		animate:FindFirstChild("run")

	if runFolder then
		local animation =
			runFolder:FindFirstChild("RunAnim")

		if animation and animation:IsA("Animation") then
			return animation
		end
	end

	local walkFolder =
		animate:FindFirstChild("walk")

	if walkFolder then
		local animation =
			walkFolder:FindFirstChild("WalkAnim")

		if animation and animation:IsA("Animation") then
			return animation
		end
	end

	return nil
end

local function stopWalkAnimation()
	if state.walkTrack then
		pcall(function()
			state.walkTrack:Stop(0.12)
			state.walkTrack:Destroy()
		end)

		state.walkTrack = nil
	end
end

local function playWalkAnimation(speed)
	if not animator then
		return
	end

	local animation = getWalkAnimation()

	if not animation then
		return
	end

	local animationSpeed =
		math.clamp(
			speed / 16,
			0.5,
			3
		)

	if state.walkTrack
		and state.walkTrack.IsPlaying then

		state.walkTrack:AdjustSpeed(
			animationSpeed
		)

		return
	end

	stopWalkAnimation()

	local success, track =
		pcall(function()
			return animator:LoadAnimation(
				animation
			)
		end)

	if not success or not track then
		return
	end

	track.Priority =
		Enum.AnimationPriority.Movement

	track.Looped = true

	track:Play(
		0.12,
		1,
		animationSpeed
	)

	state.walkTrack = track
end

local function recordFrame()
	if not rootPart then
		return
	end

	table.insert(
		state.recordedFrames,
		{
			pos = rootPart.Position,
			rot = rootPart.Orientation,
			time = os.clock()
		}
	)

	frameCountLabel.Text =
		"Frames: "
		.. tostring(
			#state.recordedFrames
		)

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
			Color3.fromRGB(
				0,
				200,
				255
			)
		)
	end
end

local function stopRecording()
	if not state.isRecording then
		return
	end

	state.isRecording = false

	if state.recordConnection then
		state.recordConnection:Disconnect()
		state.recordConnection = nil
	end

	btnRecord.Text =
		"● RECORD"

	btnRecord.BackgroundColor3 =
		Color3.fromRGB(
			180,
			40,
			40
		)

	statusLabel.Text =
		"Status: Recorded "
		.. tostring(
			#state.recordedFrames
		)
		.. " frames"

	rebuildVisualPath()
end

local function startRecording()
	if state.isPlaying or not rootPart then
		return
	end

	state.isRecording = true
	state.recordedFrames = {}
	state.safePoints = {}

	state.lastSafePosition =
		rootPart.Position

	state.lastSafeRotation =
		rootPart.Orientation

	clearVisualPath()

	btnRecord.Text =
		"● RECORDING..."

	btnRecord.BackgroundColor3 =
		Color3.fromRGB(
			255,
			50,
			50
		)

	statusLabel.Text =
		"Status: Recording"

	frameCountLabel.Text =
		"Frames: 0"

	recordFrame()

	if state.recordConnection then
		state.recordConnection:Disconnect()
	end

	state.recordConnection =
		RunService.Heartbeat:Connect(
			function()
				if not state.isRecording then
					return
				end

				if not rootPart
					or not rootPart.Parent then
					return
				end

				recordFrame()
				updateSafePoint()
			end
		)
end

local function stopPlayback()
	state.isPlaying = false

	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end

	stopWalkAnimation()

	if humanoid then
		humanoid.AutoRotate =
			state.oldAutoRotate
	end

	if rootPart then
		rootPart.AssemblyLinearVelocity =
			Vector3.zero

		rootPart.AssemblyAngularVelocity =
			Vector3.zero
	end

	btnPlay.Text =
		"▶ PLAY"

	btnPlay.BackgroundColor3 =
		Color3.fromRGB(
			40,
			120,
			40
		)
end

local function startPlayback()
	if state.isRecording
		or state.isPlaying then
		return
	end

	if #state.recordedFrames < 2 then
		statusLabel.Text =
			"Status: Not enough frames"
		return
	end

	if not character
		or not humanoid
		or not rootPart then
		return
	end

	state.isPlaying = true
	state.playbackIndex = 1
	state.playbackStartTime =
		os.clock()

	state.oldAutoRotate =
		humanoid.AutoRotate

	humanoid.AutoRotate = false

	stopWalkAnimation()

	local first =
		state.recordedFrames[1]

	character:PivotTo(
		CFrame.new(first.pos)
			* CFrame.Angles(
				0,
				math.rad(first.rot.Y),
				0
			)
	)

	rootPart.AssemblyLinearVelocity =
		Vector3.zero

	rootPart.AssemblyAngularVelocity =
		Vector3.zero

	btnPlay.Text =
		"⏸ PLAYING"

	btnPlay.BackgroundColor3 =
		Color3.fromRGB(
			200,
			150,
			40
		)

	statusLabel.Text =
		"Status: Playing"

	state.playbackConnection =
		RunService.RenderStepped:Connect(
			function()
				if not state.isPlaying then
					return
				end

				if not character
					or not rootPart
					or not rootPart.Parent then

					stopPlayback()
					return
				end

				local frames =
					state.recordedFrames

				local firstFrame =
					frames[1]

				local lastFrame =
					frames[#frames]

				local elapsed =
					os.clock()
					- state.playbackStartTime

				local totalTime =
					lastFrame.time
					- firstFrame.time

				if totalTime <= 0 then
					totalTime = 0.016
				end

				local targetTime =
					firstFrame.time
					+ elapsed

				local index =
					state.playbackIndex

				while index < #frames - 1
					and frames[index + 1].time <= targetTime do
					index += 1
				end

				state.playbackIndex =
					index

				local a =
					frames[index]

				local b =
					frames[
						math.min(
							index + 1,
							#frames
						)
					]

				local segmentTime =
					b.time - a.time

				local alpha = 0

				if segmentTime > 0 then
					alpha =
						(targetTime - a.time)
						/ segmentTime
				end

				alpha =
					math.clamp(
						alpha,
						0,
						1
					)

				alpha =
					alpha
					* alpha
					* (3 - 2 * alpha)

				local position =
					a.pos:Lerp(
						b.pos,
						alpha
					)

				local angleA =
					math.rad(a.rot.Y)

				local angleB =
					math.rad(b.rot.Y)

				local angleDifference =
					math.atan2(
						math.sin(
							angleB - angleA
						),
						math.cos(
							angleB - angleA
						)
					)

				local rotation =
					angleA
					+ angleDifference
					* alpha

				character:PivotTo(
					CFrame.new(position)
						* CFrame.Angles(
							0,
							rotation,
							0
						)
				)

				rootPart.AssemblyLinearVelocity =
					Vector3.zero

				rootPart.AssemblyAngularVelocity =
					Vector3.zero

				local movement =
					b.pos - a.pos

				local horizontal =
					Vector3.new(
						movement.X,
						0,
						movement.Z
					)

				local movementSpeed = 0

				if segmentTime > 0 then
					movementSpeed =
						horizontal.Magnitude
						/ segmentTime
				end

				if horizontal.Magnitude > 0.015 then
					playWalkAnimation(
						movementSpeed
					)
				else
					stopWalkAnimation()
				end

				if elapsed >= totalTime then
					character:PivotTo(
						CFrame.new(
							lastFrame.pos
						)
							* CFrame.Angles(
								0,
								math.rad(
									lastFrame.rot.Y
								),
								0
							)
					)

					rootPart.AssemblyLinearVelocity =
						Vector3.zero

					rootPart.AssemblyAngularVelocity =
						Vector3.zero

					stopWalkAnimation()

					state.isPlaying = false

					if state.playbackConnection then
						state.playbackConnection:Disconnect()
						state.playbackConnection = nil
					end

					humanoid.AutoRotate =
						state.oldAutoRotate

					btnPlay.Text =
						"▶ PLAY"

					btnPlay.BackgroundColor3 =
						Color3.fromRGB(
							40,
							120,
							40
						)

					statusLabel.Text =
						"Status: Playback complete"
				end
			end
		)
end

local function setAutoWalk(enabled)
	state.isAutoWalk = enabled

	if enabled then
		btnAutoWalk.Text =
			"◆ AUTO WALK ON"

		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(
				40,
				120,
				40
			)

		humanoid.WalkSpeed =
			state.autoWalkSpeed

		humanoid.AutoRotate = true
	else
		btnAutoWalk.Text =
			"◇ AUTO WALK OFF"

		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(
				60,
				60,
				80
			)

		humanoid:Move(
			Vector3.zero,
			false
		)
	end
end

btnRecord.MouseButton1Click:Connect(
	function()
		if state.isRecording then
			stopRecording()
		else
			startRecording()
		end
	end
)

btnPlay.MouseButton1Click:Connect(
	function()
		if state.isPlaying then
			stopPlayback()
		else
			startPlayback()
		end
	end
)

btnStop.MouseButton1Click:Connect(
	function()
		if state.isRecording then
			stopRecording()
		end

		if state.isPlaying then
			stopPlayback()
		end

		statusLabel.Text =
			"Status: Idle"
	end
)

btnRollback.MouseButton1Click:Connect(
	function()
		if state.isPlaying then
			stopPlayback()
		end

		rollbackToSafe()
	end
)

btnClear.MouseButton1Click:Connect(
	function()
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

		frameCountLabel.Text =
			"Frames: 0"

		statusLabel.Text =
			"Status: Cleared"
	end
)

btnAutoWalk.MouseButton1Click:Connect(
	function()
		setAutoWalk(
			not state.isAutoWalk
		)
	end
)

btnToggleLine.MouseButton1Click:Connect(
	function()
		showVisualLine =
			not showVisualLine

		if showVisualLine then
			btnToggleLine.Text =
				"◉ VISUAL LINE ON"

			btnToggleLine.BackgroundColor3 =
				Color3.fromRGB(
					60,
					80,
					60
				)

			rebuildVisualPath()
		else
			btnToggleLine.Text =
				"○ VISUAL LINE OFF"

			btnToggleLine.BackgroundColor3 =
				Color3.fromRGB(
					80,
					60,
					60
				)

			clearVisualPath()
		end
	end
)

speedSlider.FocusLost:Connect(
	function()
		local value =
			tonumber(
				speedSlider.Text
			) or 16

		value =
			math.clamp(
				value,
				1,
				200
			)

		state.autoWalkSpeed =
			value

		speedSlider.Text =
			tostring(value)

		speedLabel.Text =
			"Speed: " .. tostring(value)

		if not state.isPlaying then
			humanoid.WalkSpeed =
				value
		end
	end
)

jumpSlider.FocusLost:Connect(
	function()
		local value =
			tonumber(
				jumpSlider.Text
			) or 50

		value =
			math.clamp(
				value,
				10,
				200
			)

		state.jumpPower =
			value

		jumpSlider.Text =
			tostring(value)

		jumpLabel.Text =
			"JumpPower: " .. tostring(value)

		humanoid.JumpPower =
			value
	end
)

fallSlider.FocusLost:Connect(
	function()
		local value =
			tonumber(
				fallSlider.Text
			) or 1

		value =
			math.clamp(
				value,
				0.5,
				10
			)

		state.fallMultiplier =
			value

		fallSlider.Text =
			tostring(value)

		fallLabel.Text =
			"FallMult: " .. tostring(value)
	end
)

rotSlider.FocusLost:Connect(
	function()
		local value =
			tonumber(
				rotSlider.Text
			) or 5

		value =
			math.clamp(
				value,
				0.5,
				20
			)

		state.rotateSpeed =
			value

		rotSlider.Text =
			tostring(value)

		rotLabel.Text =
			"RotSpeed: " .. tostring(value)
	end
)

UserInputService.InputBegan:Connect(
	function(input, gameProcessed)
		if gameProcessed then
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

			statusLabel.Text =
				"Status: Idle"

		elseif input.KeyCode == Enum.KeyCode.F10 then
			showVisualLine =
				not showVisualLine

			if showVisualLine then
				btnToggleLine.Text =
					"◉ VISUAL LINE ON"

				btnToggleLine.BackgroundColor3 =
					Color3.fromRGB(
						60,
						80,
						60
					)

				rebuildVisualPath()
			else
				btnToggleLine.Text =
					"○ VISUAL LINE OFF"

				btnToggleLine.BackgroundColor3 =
					Color3.fromRGB(
						80,
						60,
						60
					)

				clearVisualPath()
			end
		end
	end
)

player.CharacterAdded:Connect(
	function(char)
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

		stopWalkAnimation()

		setupCharacter(char)

		humanoid.WalkSpeed =
			state.autoWalkSpeed

		humanoid.JumpPower =
			state.jumpPower

		humanoid.AutoRotate = true

		btnRecord.Text =
			"● RECORD"

		btnPlay.Text =
			"▶ PLAY"

		statusLabel.Text =
			"Status: Character respawned"
	end
)

RunService.Heartbeat:Connect(
	function()
		if not character
			or not humanoid
			or not rootPart then
			return
		end

		if not state.isPlaying
			and not state.isRecording
			and isGrounded() then

			updateSafePoint()
		end

		if state.isAutoWalk
			and not state.isPlaying
			and not state.isRecording then

			local direction =
				rootPart.CFrame.LookVector

			local movement =
				Vector3.new(
					direction.X,
					0,
					direction.Z
				)

			if movement.Magnitude > 0 then
				humanoid:Move(
					movement.Unit,
					false
				)
			end
		end
	end
)

humanoid.WalkSpeed =
	state.autoWalkSpeed

humanoid.JumpPower =
	state.jumpPower

statusLabel.Text =
	"Status: Ready - F5 Record | F6 Play | F7 Rollback | F8 AutoWalk"

frameCountLabel.Text =
	"Frames: 0"

print("AldoVz")
