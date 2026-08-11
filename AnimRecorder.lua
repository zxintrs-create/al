local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local state = {
	isRecording = false,
	isPlaying = false,
	isAutoWalk = false,
	autoWalkSpeed = 16,
	recordedFrames = {},
	safePoints = {},
	playbackIndex = 1,
	playbackStartTime = 0,
	lastSafePosition = nil,
	lastSafeRotation = nil,
	visualLines = {},
	speedMultiplier = 1,
	jumpPower = 50,
	fallMultiplier = 1,
	rotateSpeed = 5,
	characterRot = 0,
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimRecorderGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function makeFrame(name, parent, size, pos, color)
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size or UDim2.new(0, 200, 0, 30)
	f.Position = pos or UDim2.new(0, 10, 0, 10)
	f.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function makeButton(name, parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = size or UDim2.new(0, 180, 0, 28)
	b.Position = pos or UDim2.new(0, 10, 0, 5)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 14
	b.Font = Enum.Font.GothamBold
	b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
	b.BorderSizePixel = 0
	b.Parent = parent
	return b
end

local function makeLabel(name, parent, text, pos, size)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size or UDim2.new(0, 180, 0, 20)
	l.Position = pos or UDim2.new(0, 10, 0, 5)
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

local function makeSlider(name, parent, pos, minVal, maxVal, defaultVal)
	local container = makeFrame(name .. "Cont", parent, UDim2.new(0, 180, 0, 36), pos, Color3.fromRGB(40,40,40))
	local label = makeLabel(name .. "Label", container, name .. ": " .. tostring(defaultVal), UDim2.new(0, 5, 0, 2), UDim2.new(0, 170, 0, 14))
	local slider = Instance.new("TextBox")
	slider.Name = name .. "Slider"
	slider.Size = UDim2.new(0, 170, 0, 16)
	slider.Position = UDim2.new(0, 5, 0, 17)
	slider.Text = tostring(defaultVal)
	slider.TextColor3 = Color3.fromRGB(255,255,255)
	slider.TextSize = 12
	slider.Font = Enum.Font.Gotham
	slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
	slider.BorderSizePixel = 0
	slider.ClearTextOnFocus = false
	slider.Parent = container
	return container, label, slider
end

local mainWindow = makeFrame("MainWindow", screenGui, UDim2.new(0, 220, 0, 520), UDim2.new(0, 15, 0, 50), Color3.fromRGB(25, 25, 35))
mainWindow.Active = true
mainWindow.Draggable = true

local title = makeLabel("Title", mainWindow, "ANIM RECORDER v2", UDim2.new(0, 10, 0, 5), UDim2.new(0, 200, 0, 22))
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(100, 200, 255)

local yOff = 32

local btnRecord = makeButton("BtnRecord", mainWindow, "● RECORD", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 90, 0, 28), Color3.fromRGB(180, 40, 40))
local btnPlay = makeButton("BtnPlay", mainWindow, "▶ PLAY", UDim2.new(0, 110, 0, yOff), UDim2.new(0, 90, 0, 28), Color3.fromRGB(40, 120, 40))
yOff = yOff + 34

local btnStop = makeButton("BtnStop", mainWindow, "■ STOP", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 90, 0, 28), Color3.fromRGB(100, 100, 100))
local btnRollback = makeButton("BtnRollback", mainWindow, "↩ ROLLBACK", UDim2.new(0, 110, 0, yOff), UDim2.new(0, 90, 0, 28), Color3.fromRGB(40, 80, 160))
yOff = yOff + 34

local btnClear = makeButton("BtnClear", mainWindow, "✕ CLEAR ALL", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 180, 0, 24), Color3.fromRGB(80, 40, 40))
yOff = yOff + 30

local sep1 = makeFrame("Sep1", mainWindow, UDim2.new(0, 200, 0, 1), UDim2.new(0, 10, 0, yOff), Color3.fromRGB(80, 80, 100))
yOff = yOff + 8

local btnAutoWalk = makeButton("BtnAutoWalk", mainWindow, "◇ AUTO WALK OFF", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 180, 0, 26), Color3.fromRGB(60, 60, 80))
yOff = yOff + 30

local speedCont, speedLabel, speedSlider = makeSlider("Speed", mainWindow, UDim2.new(0, 10, 0, yOff), 1, 200, 16)
yOff = yOff + 40

local jumpCont, jumpLabel, jumpSlider = makeSlider("JumpPower", mainWindow, UDim2.new(0, 10, 0, yOff), 10, 200, 50)
yOff = yOff + 40

local fallCont, fallLabel, fallSlider = makeSlider("FallMult", mainWindow, UDim2.new(0, 10, 0, yOff), 0.5, 10, 1)
yOff = yOff + 40

local rotCont, rotLabel, rotSlider = makeSlider("RotSpeed", mainWindow, UDim2.new(0, 10, 0, yOff), 0.5, 20, 5)
yOff = yOff + 40

local sep2 = makeFrame("Sep2", mainWindow, UDim2.new(0, 200, 0, 1), UDim2.new(0, 10, 0, yOff), Color3.fromRGB(80, 80, 100))
yOff = yOff + 8

local statusLabel = makeLabel("Status", mainWindow, "Status: Idle", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 200, 0, 16))
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
yOff = yOff + 18

local frameCountLabel = makeLabel("FrameCount", mainWindow, "Frames: 0", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 200, 0, 16))
yOff = yOff + 18

local btnToggleLine = makeButton("BtnToggleLine", mainWindow, "◉ VISUAL LINE ON", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 180, 0, 24), Color3.fromRGB(60, 80, 60))
local showVisualLine = true

screenGui.Parent = player:WaitForChild("PlayerGui")

local pathFolder = Instance.new("Folder")
pathFolder.Name = "VisualPathLines"
pathFolder.Parent = workspace

local function createPathSegment(p1, p2, color)
	local dist = (p2 - p1).Magnitude
	if dist < 0.1 then return end

	local mid = (p1 + p2) / 2
	local part = Instance.new("Part")
	part.Name = "PathSegment"
	part.Size = Vector3.new(0.3, 0.3, dist)
	part.CFrame = CFrame.lookAt(mid, p2) * CFrame.Angles(math.rad(90), 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = color or Color3.fromRGB(0, 200, 255)
	part.Transparency = 0.2
	part.BrickColor = BrickColor.new("Really blue")

	local mesh = Instance.new("CylinderMesh")
	mesh.Scale = Vector3.new(1, 1, 1)
	mesh.Parent = part

	part.Parent = pathFolder
	return part
end

local function clearVisualPath()
	for _, v in ipairs(pathFolder:GetChildren()) do
		if v:IsA("BasePart") then
			v:Destroy()
		end
	end
end

local function rebuildVisualPath()
	clearVisualPath()
	if not showVisualLine then return end
	if #state.recordedFrames < 2 then return end

	local color = state.isPlaying and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 200, 255)

	for i = 1, #state.recordedFrames - 1 do
		local f1 = state.recordedFrames[i]
		local f2 = state.recordedFrames[i + 1]
		local p1 = f1.pos
		local p2 = f2.pos

		local t = i / #state.recordedFrames
		local c = Color3.new(0.2 + 0.8 * t, 0.5 + 0.5 * (1 - t), 0.8)
		createPathSegment(p1, p2, c)
	end

	local startMarker = Instance.new("Part")
	startMarker.Name = "StartMarker"
	startMarker.Size = Vector3.new(1, 1, 1)
	startMarker.Shape = Enum.PartType.Ball
	startMarker.Anchored = true
	startMarker.CanCollide = false
	startMarker.BrickColor = BrickColor.new("Bright green")
	startMarker.Material = Enum.Material.Neon
	startMarker.CFrame = CFrame.new(state.recordedFrames[1].pos)
	startMarker.Parent = pathFolder

	local endMarker = Instance.new("Part")
	endMarker.Name = "EndMarker"
	endMarker.Size = Vector3.new(1, 1, 1)
	endMarker.Shape = Enum.PartType.Ball
	endMarker.Anchored = true
	endMarker.CanCollide = false
	endMarker.BrickColor = BrickColor.new("Bright red")
	endMarker.Material = Enum.Material.Neon
	endMarker.CFrame = CFrame.new(state.recordedFrames[#state.recordedFrames].pos)
	endMarker.Parent = pathFolder

	if state.lastSafePosition then
		local safeMarker = Instance.new("Part")
		safeMarker.Name = "SafeMarker"
		safeMarker.Size = Vector3.new(0.8, 0.8, 0.8)
		safeMarker.Shape = Enum.PartType.Ball
		safeMarker.Anchored = true
		safeMarker.CanCollide = false
		safeMarker.BrickColor = BrickColor.new("Bright yellow")
		safeMarker.Material = Enum.Material.Neon
		safeMarker.CFrame = CFrame.new(state.lastSafePosition)
		safeMarker.Parent = pathFolder
	end
end

local function isFalling()
	if not character or not rootPart then return false end
	local pos = rootPart.Position
	-- Raycast ke bawah
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {character}

	local origin = pos + Vector3.new(0, 1, 0)
	local direction = Vector3.new(0, -5, 0)
	local result = workspace:Raycast(origin, direction, rayParams)
	return result == nil
end

local function updateSafePoint()
	if not isFalling() and rootPart then
		state.lastSafePosition = rootPart.Position
		state.lastSafeRotation = rootPart.Orientation
		table.insert(state.safePoints, {
			pos = rootPart.Position,
			rot = rootPart.Orientation
		})
		if #state.safePoints > 20 then
			table.remove(state.safePoints, 1)
		end
	end
end

local function rollbackToSafe()
	if state.lastSafePosition and rootPart then
		rootPart.CFrame = CFrame.new(state.lastSafePosition) * CFrame.Angles(0, math.rad(rootPart.Orientation.Y), 0)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		statusLabel.Text = "Status: Rollbacked to safe point"
		rebuildVisualPath()
	else
		statusLabel.Text = "Status: No safe point!"
	end
end

local function recordFrame()
	if not rootPart then return end
	table.insert(state.recordedFrames, {
		pos = rootPart.Position,
		rot = rootPart.Orientation,
		vel = rootPart.Velocity or Vector3.new(),
		time = tick()
	})
	frameCountLabel.Text = "Frames: " .. #state.recordedFrames

	if showVisualLine and #state.recordedFrames >= 2 then
		local f1 = state.recordedFrames[#state.recordedFrames - 1]
		local f2 = state.recordedFrames[#state.recordedFrames]
		local t = #state.recordedFrames / math.max(#state.recordedFrames, 1)
		local c = Color3.new(0.2 + 0.8 * t, 0.5 + 0.5 * (1 - t), 0.8)
		createPathSegment(f1.pos, f2.pos, c)
	end
end

local function startPlayback()
	if #state.recordedFrames < 2 then
		statusLabel.Text = "Status: Not enough frames!"
		return
	end

	state.isPlaying = true
	state.playbackIndex = 1
	state.playbackStartTime = tick()

	local firstFrame = state.recordedFrames[1]
	if rootPart then
		rootPart.CFrame = CFrame.new(firstFrame.pos) * CFrame.Angles(0, math.rad(firstFrame.rot.Y), 0)
	end

	statusLabel.Text = "Status: Playing..."
	btnPlay.Text = "⏸ PLAYING"
	btnPlay.BackgroundColor3 = Color3.fromRGB(200, 150, 40)
	rebuildVisualPath()

	local playbackConn
	playbackConn = RunService.Heartbeat:Connect(function(dt)
		if not state.isPlaying or not rootPart then
			playbackConn:Disconnect()
			return
		end

		local elapsed = tick() - state.playbackStartTime
		local totalDuration = state.recordedFrames[#state.recordedFrames].time - state.recordedFrames[1].time
		if totalDuration <= 0 then totalDuration = 1 end

		local progress = elapsed / totalDuration
		progress = math.clamp(progress, 0, 1)

		local targetIndex = math.floor(progress * (#state.recordedFrames - 1)) + 1
		targetIndex = math.clamp(targetIndex, 1, #state.recordedFrames - 1)

		local f1 = state.recordedFrames[targetIndex]
		local f2 = state.recordedFrames[targetIndex + 1]

		local segDuration = f2.time - f1.time
		if segDuration <= 0 then segDuration = 0.016 end
		local segElapsed = elapsed - (targetIndex - 1) * (totalDuration / (#state.recordedFrames - 1))
		local segProgress = math.clamp(segElapsed / segDuration, 0, 1)

		local smoothT = segProgress * segProgress * (3 - 2 * segProgress)

		local lerpPos = f1.pos:Lerp(f2.pos, smoothT)
		local lerpRotY = f1.rot.Y + (f2.rot.Y - f1.rot.Y) * smoothT

		rootPart.CFrame = CFrame.new(lerpPos) * CFrame.Angles(0, math.rad(lerpRotY), 0)

		if isFalling() then
			statusLabel.Text = "Status: Fall detected, rolling back..."
			state.isPlaying = false
			btnPlay.Text = "▶ PLAY"
			btnPlay.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
			rollbackToSafe()
			playbackConn:Disconnect()
			return
		end

		updateSafePoint()
			
		if progress >= 1 then
			state.isPlaying = false
			btnPlay.Text = "▶ PLAY"
			btnPlay.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
			statusLabel.Text = "Status: Playback complete"
			playbackConn:Disconnect()

			local firstFramePos = state.recordedFrames[1].pos
			local firstFrameRot = state.recordedFrames[1].rot
			rootPart.CFrame = CFrame.new(firstFramePos) * CFrame.Angles(0, math.rad(firstFrameRot.Y), 0)
			rebuildVisualPath()
		end
	end)
end

local function stopPlayback()
	state.isPlaying = false
	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
	statusLabel.Text = "Status: Stopped"
end

local function stopRecording()
	state.isRecording = false
	btnRecord.Text = "● RECORD"
	btnRecord.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	statusLabel.Text = "Status: Recorded " .. #state.recordedFrames .. " frames"
end

btnRecord.MouseButton1Click:Connect(function()
	if state.isPlaying then return end

	state.isRecording = not state.isRecording

	if state.isRecording then
			
		state.recordedFrames = {}
		clearVisualPath()

		btnRecord.Text = "● RECORDING..."
		btnRecord.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		statusLabel.Text = "Status: Recording..."
		frameCountLabel.Text = "Frames: 0"

		local recordConn
		recordConn = RunService.Heartbeat:Connect(function()
			if not state.isRecording or not rootPart then
				recordConn:Disconnect()
				return
			end
			recordFrame()
			updateSafePoint()
		end)
	else
		stopRecording()
		rebuildVisualPath()
	end
end)

btnPlay.MouseButton1Click:Connect(function()
	if state.isRecording then return end
	if state.isPlaying then
		stopPlayback()
		return
	end
	startPlayback()
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
	state.recordedFrames = {}
	state.safePoints = {}
	state.lastSafePosition = nil
	state.lastSafeRotation = nil
	clearVisualPath()
	frameCountLabel.Text = "Frames: 0"
	statusLabel.Text = "Status: Cleared"
	if state.isPlaying then stopPlayback() end
	if state.isRecording then stopRecording() end
end)

btnAutoWalk.MouseButton1Click:Connect(function()
	state.isAutoWalk = not state.isAutoWalk
	if state.isAutoWalk then
		btnAutoWalk.Text = "◆ AUTO WALK ON"
		btnAutoWalk.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
		humanoid.WalkSpeed = state.autoWalkSpeed
		humanoid.AutoRotate = true

		local lookCF = rootPart.CFrame * CFrame.new(0, 0, -10)
		humanoid:MoveTo(lookCF.Position)
	else
		btnAutoWalk.Text = "◇ AUTO WALK OFF"
		btnAutoWalk.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		humanoid:MoveTo(rootPart.Position) 
	end
end)

btnToggleLine.MouseButton1Click:Connect(function()
	showVisualLine = not showVisualLine
	if showVisualLine then
		btnToggleLine.Text = "◉ VISUAL LINE ON"
		btnToggleLine.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
		rebuildVisualPath()
	else
		btnToggleLine.Text = "○ VISUAL LINE OFF"
		btnToggleLine.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
		clearVisualPath()
	end
end)

speedSlider.FocusLost:Connect(function()
	local val = tonumber(speedSlider.Text) or 16
	val = math.clamp(val, 1, 200)
	state.autoWalkSpeed = val
	speedLabel.Text = "Speed: " .. val
	humanoid.WalkSpeed = val
end)

jumpSlider.FocusLost:Connect(function()
	local val = tonumber(jumpSlider.Text) or 50
	val = math.clamp(val, 10, 200)
	state.jumpPower = val
	jumpLabel.Text = "JumpPower: " .. val
	humanoid.JumpPower = val
end)

fallSlider.FocusLost:Connect(function()
	local val = tonumber(fallSlider.Text) or 1
	val = math.clamp(val, 0.5, 10)
	state.fallMultiplier = val
	fallLabel.Text = "FallMult: " .. val
end)

rotSlider.FocusLost:Connect(function()
	local val = tonumber(rotSlider.Text) or 5
	val = math.clamp(val, 0.5, 20)
	state.rotateSpeed = val
	rotLabel.Text = "RotSpeed: " .. val
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.F5 then
			
		btnRecord.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.F6 then
			
		btnPlay.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.F7 then
	
		btnRollback.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.F8 then
	
		btnAutoWalk.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.F9 then
	
		btnStop.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.F10 then

		btnToggleLine.MouseButton1Click:Fire()
	end
end)

local fallCheckConn
fallCheckConn = RunService.Heartbeat:Connect(function()
	if not rootPart then return end

	if not isFalling() then
		updateSafePoint()
	end

	if isFalling() and not state.isPlaying and not state.isRecording then
		local velY = rootPart.Velocity.Y
		if velY < -30 then
			statusLabel.Text = "Status: Falling! Press F7 to rollback"
		end
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = state.autoWalkSpeed
	humanoid.JumpPower = state.jumpPower

	statusLabel.Text = "Status: Character respawned"
end)

humanoid.WalkSpeed = state.autoWalkSpeed
humanoid.JumpPower = state.jumpPower
statusLabel.Text = "Status: Ready - F5 Record | F6 Play | F7 Rollback | F8 AutoWalk"
frameCountLabel.Text = "Frames: 0"

print("[AnimRecorder] Loaded. Shortcuts: F5=Record F6=Play F7=Rollback F8=AutoWalk F9=Stop F10=VisualLine")
