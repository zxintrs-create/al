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
	playbackTime = 0,
	playbackDirection = 1,
	playbackStarted = false,
	smoothDirection = Vector3.zero,
	lastGrounded = true,
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

local function createPathSegment(firstPosition, secondPosition, color)
	local distance = (secondPosition - firstPosition).Magnitude

	if distance < 0.05 then
		return
	end

	local segment = Instance.new("Part")
	segment.Name = "VisualPath"
	segment.Size = Vector3.new(0.08, 0.08, distance)
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
	segment.Transparency = 0.45
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
	state.lastSafeRotation = rootPart.CFrame.Rotation
end

local function rollbackToSafe()
	if not character or not state.lastSafePosition then
		statusLabel.Text = "Status: No safe point"
		return
	end

	character:PivotTo(
		CFrame.new(state.lastSafePosition)
			* state.lastSafeRotation
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

local function normalizeTimes()
	if #state.recordedFrames < 2 then
		return
	end

	local firstTime = state.recordedFrames[1].time

	for _, frame in ipairs(state.recordedFrames) do
		frame.time = frame.time - firstTime
	end
end

local function getTotalDuration()
	if #state.recordedFrames < 2 then
		return 0
	end

	return state.recordedFrames[#state.recordedFrames].time
end

local function sampleFrameAt(targetTime)
	if #state.recordedFrames == 0 then
		return nil
	end

	if #state.recordedFrames == 1 then
		return state.recordedFrames[1]
	end

	targetTime = math.clamp(
		targetTime,
		0,
		getTotalDuration()
	)

	local low = 1
	local high = #state.recordedFrames

	while low <= high do
		local middle = math.floor((low + high) / 2)

		if state.recordedFrames[middle].time < targetTime then
			low = middle + 1
		else
			high = middle - 1
		end
	end

	local secondIndex = math.clamp(
		low,
		2,
		#state.recordedFrames
	)

	local firstIndex = secondIndex - 1

	local firstFrame =
		state.recordedFrames[firstIndex]

	local secondFrame =
		state.recordedFrames[secondIndex]

	local duration =
		secondFrame.time - firstFrame.time

	if duration <= 0 then
		return firstFrame
	end

	local alpha =
		math.clamp(
			(targetTime - firstFrame.time) / duration,
			0,
			1
		)

	return {
		position =
			firstFrame.position:Lerp(
				secondFrame.position,
				alpha
			),

		rotation =
			firstFrame.rotation:Lerp(
				secondFrame.rotation,
				alpha
			),

		grounded =
			alpha < 0.5
			and firstFrame.grounded
			or secondFrame.grounded
	}
end

local function getFrameDirection(index, direction)
	local nextIndex = index + direction

	if nextIndex < 1 or nextIndex > #state.recordedFrames then
		return Vector3.zero, 0
	end

	local first =
		state.recordedFrames[index]

	local second =
		state.recordedFrames[nextIndex]

	local delta =
		second.position - first.position

	local horizontal =
		Vector3.new(
			delta.X,
			0,
			delta.Z
		)

	local duration =
		math.abs(
			second.time - first.time
		)

	if duration <= 0 then
		duration = 1 / 30
	end

	if horizontal.Magnitude <= 0.01 then
		return Vector3.zero, 0
	end

	return horizontal.Unit,
		horizontal.Magnitude / duration
end

local function getNearestPathFrame()
	if #state.recordedFrames == 0 or not rootPart then
		return nil, math.huge
	end

	local bestIndex = 1
	local bestDistance = math.huge

	local currentPosition =
		rootPart.Position

	local startIndex = 1
	local endIndex = #state.recordedFrames

	if state.playbackDirection > 0 then
		startIndex =
			math.max(
				1,
				math.floor(
					state.playbackTime /
					math.max(
						getTotalDuration() /
						#state.recordedFrames,
						0.001
					)
				) - 8
			)

		endIndex =
			math.min(
				#state.recordedFrames,
				startIndex + 30
			)
	else
		endIndex =
			math.min(
				#state.recordedFrames,
				math.floor(
					state.playbackTime /
					math.max(
						getTotalDuration() /
						#state.recordedFrames,
						0.001
					)
				) + 8
			)

		startIndex =
			math.max(
				1,
				endIndex - 30
			)
	end

	for index = startIndex, endIndex do
		local frame =
			state.recordedFrames[index]

		local delta =
			frame.position - currentPosition

		local horizontal =
			Vector3.new(
				delta.X,
				0,
				delta.Z
			)

		local distance =
			horizontal.Magnitude

		if distance < bestDistance then
			bestDistance = distance
			bestIndex = index
		end
	end

	return bestIndex, bestDistance
end

local function getPathDirection()
	if not rootPart or #state.recordedFrames < 2 then
		return Vector3.zero
	end

	local currentFrame =
		sampleFrameAt(state.playbackTime)

	if not currentFrame then
		return Vector3.zero
	end

	local targetDelta =
		currentFrame.position -
		rootPart.Position

	local targetHorizontal =
		Vector3.new(
			targetDelta.X,
			0,
			targetDelta.Z
		)

	local nearestIndex, nearestDistance =
		getNearestPathFrame()

	if nearestIndex then
		local pathDirection, pathSpeed =
			getFrameDirection(
				nearestIndex,
				state.playbackDirection
			)

		local correction =
			Vector3.zero

		if nearestDistance > 0.75
			and targetHorizontal.Magnitude > 0.05 then

			local correctionStrength =
				math.clamp(
					nearestDistance / 3,
					0,
					1
				)

			correction =
				targetHorizontal.Unit *
				correctionStrength
		end

		local result =
			pathDirection + correction

		result =
			Vector3.new(
				result.X,
				0,
				result.Z
			)

		if result.Magnitude > 0.01 then
			return result.Unit, pathSpeed
		end
	end

	if targetHorizontal.Magnitude > 0.05 then
		return targetHorizontal.Unit, state.autoWalkSpeed
	end

	return Vector3.zero, 0
end

local function getGroundAhead(direction, distance)
	if not rootPart or not character then
		return false
	end

	if direction.Magnitude <= 0.01 then
		return true
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.IgnoreWater = false

	local origin =
		rootPart.Position +
		Vector3.new(0, 2.5, 0) +
		direction.Unit * distance

	local result =
		workspace:Raycast(
			origin,
			Vector3.new(0, -7, 0),
			params
		)

	return result ~= nil
end

local function getForwardGround(direction)
	if not rootPart or direction.Magnitude <= 0.01 then
		return true
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.IgnoreWater = false

	local origin =
		rootPart.Position +
		Vector3.new(0, 2, 0)

	local result =
		workspace:Raycast(
			origin,
			direction.Unit * 2.2 +
			Vector3.new(0, -6, 0),
			params
		)

	return result ~= nil
end

local function getApproachDirection(targetPosition)
	if not rootPart then
		return Vector3.zero, math.huge
	end

	local delta =
		targetPosition -
		rootPart.Position

	local horizontal =
		Vector3.new(
			delta.X,
			0,
			delta.Z
		)

	local distance =
		horizontal.Magnitude

	if distance <= 0.01 then
		return Vector3.zero, distance
	end

	return horizontal.Unit, distance
end

local function resetPlaybackState()
	state.playbackTime = 0
	state.playbackDirection = 1
	state.playbackStarted = false
	state.smoothDirection = Vector3.zero
	state.lastGrounded = true
	state.jumpCooldown = 0
end

local function disconnectPlayback()
	if state.playbackConnection then
		state.playbackConnection:Disconnect()
		state.playbackConnection = nil
	end
end

local function finishPlayback()
	state.isPlaying = false
	state.playbackStarted = false

	disconnectPlayback()

	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = state.autoWalkSpeed
	end

	state.smoothDirection = Vector3.zero
	state.jumpCooldown = 0

	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(40, 120, 40)

	statusLabel.Text =
		"Status: Playback complete"
end

local function stopPlayback()
	state.isPlaying = false
	state.playbackStarted = false

	disconnectPlayback()

	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = state.autoWalkSpeed
	end

	state.smoothDirection = Vector3.zero
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
		statusLabel.Text =
			"Status: Not enough frames"
		return
	end

	if not character or not humanoid or not rootPart then
		statusLabel.Text =
			"Status: Character unavailable"
		return
	end

	normalizeTimes()

	resetPlaybackState()

	state.isPlaying = true

	btnPlay.Text = "⏸ PLAYING"
	btnPlay.BackgroundColor3 =
		Color3.fromRGB(200, 150, 40)

	statusLabel.Text =
		"Status: Walking to start..."

	disconnectPlayback()

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

			local totalDuration =
				getTotalDuration()

			if totalDuration <= 0 then
				finishPlayback()
				return
			end

			state.jumpCooldown =
				math.max(
					0,
					state.jumpCooldown - dt
				)

			if not state.playbackStarted then
				local startPosition =
					state.recordedFrames[1].position

				local direction, distance =
					getApproachDirection(
						startPosition
					)

				if distance <= arrivalDistance then
					state.playbackStarted = true
					state.playbackTime = 0
					state.playbackDirection = 1
					state.smoothDirection =
						Vector3.zero

					statusLabel.Text =
						"Status: Playing"
				else
					humanoid.WalkSpeed =
						state.approachSpeed

					if direction.Magnitude > 0.01 then
						local smoothing =
							1 -
							math.exp(
								-dt * 12
							)

						if state.smoothDirection.Magnitude <= 0.01 then
							state.smoothDirection =
								direction
						else
							state.smoothDirection =
								state.smoothDirection:Lerp(
									direction,
									smoothing
								)

							if state.smoothDirection.Magnitude > 0.01 then
								state.smoothDirection =
									state.smoothDirection.Unit
							end
						end

						humanoid:Move(
							state.smoothDirection,
							false
						)
					else
						humanoid:Move(
							Vector3.zero,
							false
						)
					end
				end

				updateSafePoint()
				return
			end

			local direction, recordedSpeed =
				getPathDirection()

			local currentFrame =
				sampleFrameAt(
					state.playbackTime
				)

			local lookAheadTime =
				math.clamp(
					state.playbackTime +
					0.12 *
					state.playbackDirection,
					0,
					totalDuration
				)

			local nextFrame =
				sampleFrameAt(
					lookAheadTime
				)

			if currentFrame and nextFrame then
				local verticalDifference =
					nextFrame.position.Y -
					currentFrame.position.Y

				local currentGrounded =
					isGrounded()

				if verticalDifference > 0.45
					and currentGrounded
					and state.jumpCooldown <= 0 then

					local jumpDirection =
						getApproachDirection(
							nextFrame.position
						)

					if jumpDirection.Magnitude > 0 then
						humanoid.Jump = true
						state.jumpCooldown = 0.4
					end
				end
			end

			if direction.Magnitude > 0.01 then
				local groundAvailable =
					getForwardGround(direction)

				if not groundAvailable
					and isGrounded() then

					local alternate =
						direction

					local right =
						Vector3.new(
							-direction.Z,
							0,
							direction.X
						)

					local left =
						-right

					local rightGround =
						getGroundAhead(
							right,
							1.5
						)

					local leftGround =
						getGroundAhead(
							left,
							1.5
						)

					if rightGround then
						alternate =
							(
								direction +
								right * 0.45
							).Unit

					elseif leftGround then
						alternate =
							(
								direction +
								left * 0.45
							).Unit
					end

					direction = alternate
				end

				local smoothing =
					1 -
					math.exp(
						-dt *
						math.clamp(
							state.rotateSpeed * 3,
							8,
							30
						)
					)

				if state.smoothDirection.Magnitude <= 0.01 then
					state.smoothDirection =
						direction
				else
					state.smoothDirection =
						state.smoothDirection:Lerp(
							direction,
							smoothing
						)

					if state.smoothDirection.Magnitude > 0.01 then
						state.smoothDirection =
							state.smoothDirection.Unit
					end
				end

				local targetSpeed =
					math.clamp(
						recordedSpeed,
						1,
						200
					)

				if targetSpeed < 1 then
					targetSpeed =
						state.autoWalkSpeed
				end

				local speedAlpha =
					1 -
					math.exp(
						-dt * 10
					)

				local currentSpeed =
					humanoid.WalkSpeed

				currentSpeed =
					currentSpeed +
					(
						targetSpeed -
						currentSpeed
					) * speedAlpha

				humanoid.WalkSpeed =
					math.clamp(
						currentSpeed,
						1,
						200
					)

				humanoid:Move(
					state.smoothDirection,
					false
				)
			else
				humanoid:Move(
					Vector3.zero,
					false
				)
			end

			local timeStep =
				dt *
				math.clamp(
					humanoid.WalkSpeed /
					math.max(
						state.autoWalkSpeed,
						1
					),
					0.65,
					1.5
				)

			state.playbackTime +=
				timeStep *
				state.playbackDirection

			if state.playbackTime >= totalDuration then
				state.playbackTime =
					totalDuration

				if state.isLooping then
					state.playbackDirection = -1
					state.smoothDirection =
						Vector3.zero
				else
					finishPlayback()
					return
				end
			elseif state.playbackTime <= 0 then
				state.playbackTime = 0

				if state.isLooping then
					state.playbackDirection = 1
					state.smoothDirection =
						Vector3.zero
				else
					finishPlayback()
					return
				end
			end

			updateSafePoint()

			if isGrounded() then
				state.lastGrounded = true
			else
				state.lastGrounded = false
			end
		end)
end

local function stopRecording()
	state.isRecording = false

	if state.recordConnection then
		state.recordConnection:Disconnect()
		state.recordConnection = nil
	end

	normalizeTimes()

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

	btnRecord.Text =
		"● RECORDING..."

	btnRecord.BackgroundColor3 =
		Color3.fromRGB(255, 50, 50)

	statusLabel.Text =
		"Status: Recording"

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
	state.isAutoWalk =
		not state.isAutoWalk

	if state.isAutoWalk then
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

local function toggleLoop()
	state.isLooping =
		not state.isLooping

	if state.isLooping then
		btnLoop.Text =
			"↻ LOOP ON"

		btnLoop.BackgroundColor3 =
			Color3.fromRGB(40, 120, 40)
	else
		btnLoop.Text =
			"↻ LOOP OFF"

		btnLoop.BackgroundColor3 =
			Color3.fromRGB(60, 60, 80)
	end
end

local function toggleVisualLine()
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

btnRecord.MouseButton1Click:Connect(
	toggleRecord
)

btnPlay.MouseButton1Click:Connect(
	togglePlayback
)

btnStop.MouseButton1Click:Connect(
	stopEverything
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
	toggleAutoWalk
)

btnLoop.MouseButton1Click:Connect(
	toggleLoop
)

btnToggleLine.MouseButton1Click:Connect(
	toggleVisualLine
)

speedBox.FocusLost:Connect(
	function()
		local value =
			tonumber(speedBox.Text) or 16

		value =
			math.clamp(
				value,
				1,
				200
			)

		state.autoWalkSpeed =
			value

		state.approachSpeed =
			value

		speedBox.Text =
			tostring(value)

		speedLabel.Text =
			"Speed: " ..
			tostring(value)

		if not state.isPlaying then
			humanoid.WalkSpeed =
				value
		end
	end
)

jumpBox.FocusLost:Connect(
	function()
		local value =
			tonumber(jumpBox.Text) or 50

		value =
			math.clamp(
				value,
				10,
				200
			)

		state.jumpPower =
			value

		jumpBox.Text =
			tostring(value)

		jumpLabel.Text =
			"JumpPower: " ..
			tostring(value)

		humanoid.JumpPower =
			value
	end
)

fallBox.FocusLost:Connect(
	function()
		local value =
			tonumber(fallBox.Text) or 1

		value =
			math.clamp(
				value,
				0.5,
				10
			)

		state.fallMultiplier =
			value

		fallBox.Text =
			tostring(value)

		fallLabel.Text =
			"FallMult: " ..
			tostring(value)
	end
)

rotBox.FocusLost:Connect(
	function()
		local value =
			tonumber(rotBox.Text) or 5

		value =
			math.clamp(
				value,
				0.5,
				20
			)

		state.rotateSpeed =
			value

		rotBox.Text =
			tostring(value)

		rotLabel.Text =
			"RotSpeed: " ..
			tostring(value)
	end
)

UserInputService.InputBegan:Connect(
	function(input, gameProcessed)
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
	end
)

player.CharacterAdded:Connect(
	function(newCharacter)
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
		state.isAutoWalk = false
		state.playbackStarted = false
		state.smoothDirection = Vector3.zero

		setupCharacter(newCharacter)

		btnRecord.Text =
			"● RECORD"

		btnRecord.BackgroundColor3 =
			Color3.fromRGB(180, 40, 40)

		btnPlay.Text =
			"▶ PLAY"

		btnPlay.BackgroundColor3 =
			Color3.fromRGB(40, 120, 40)

		btnAutoWalk.Text =
			"◇ AUTO WALK OFF"

		btnAutoWalk.BackgroundColor3 =
			Color3.fromRGB(60, 60, 80)

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
	end
)

humanoid.WalkSpeed =
	state.autoWalkSpeed

humanoid.JumpPower =
	state.jumpPower

statusLabel.Text =
	"Status: Ready - F5 Record | F6 Play | F7 Rollback | F8 AutoWalk | F11 Loop"

frameCountLabel.Text =
	"Frames: 0"

print("AldoVz")
