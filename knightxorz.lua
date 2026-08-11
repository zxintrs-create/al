local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local animator = humanoid:WaitForChild("Animator")

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
	jumpPower = 50,
	activePlaybackTracks = {}
}

-- GUI Setup
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

local mainWindow = makeFrame("MainWindow", screenGui, UDim2.new(0, 220, 0, 380), UDim2.new(0, 15, 0, 50), Color3.fromRGB(25, 25, 35))
mainWindow.Active = true
mainWindow.Draggable = true

local title = makeLabel("Title", mainWindow, "ANIM RECORDER v3 (FIXED)", UDim2.new(0, 10, 0, 5), UDim2.new(0, 200, 0, 22))
title.TextSize = 14
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

local statusLabel = makeLabel("Status", mainWindow, "Status: Idle", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 200, 0, 16))
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
yOff = yOff + 18

local frameCountLabel = makeLabel("FrameCount", mainWindow, "Frames: 0", UDim2.new(0, 10, 0, yOff), UDim2.new(0, 200, 0, 16))

screenGui.Parent = player:WaitForChild("PlayerGui")

local pathFolder = Instance.new("Folder")
pathFolder.Name = "VisualPathLines"
pathFolder.Parent = workspace

local function clearVisualPath()
	for _, v in ipairs(pathFolder:GetChildren()) do
		v:Destroy()
	end
end

-- Fungsi Mengambil Animasi Aktif
local function getActiveAnimIDs()
	local animIDs = {}
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			if track.Animation and track.IsPlaying then
				table.insert(animIDs, {
					id = track.Animation.AnimationId,
					speed = track.Speed,
					weight = track.WeightCurrent
				})
			end
		end
	end
	return animIDs
end

-- Stop Semua Animasi Playback
local function stopPlaybackAnims()
	for _, track in ipairs(state.activePlaybackTracks) do
		track:Stop()
		track:Destroy()
	end
	state.activePlaybackTracks = {}
end

-- Recording Frame
local function recordFrame()
	if not rootPart or not humanoid then return end
	table.insert(state.recordedFrames, {
		cframe = rootPart.CFrame,
		anims = getActiveAnimIDs(),
		time = tick()
	})
	frameCountLabel.Text = "Frames: " .. #state.recordedFrames
end

-- Playback System yang Diperbaiki
local function startPlayback()
	if #state.recordedFrames < 2 then
		statusLabel.Text = "Status: Not enough frames!"
		return
	end

	state.isPlaying = true
	state.playbackIndex = 1
	state.playbackStartTime = tick()

	local firstFrame = state.recordedFrames[1]
	local recordStartTime = firstFrame.time
	local totalDuration = state.recordedFrames[#state.recordedFrames].time - recordStartTime

	rootPart.CFrame = firstFrame.cframe
	statusLabel.Text = "Status: Playing..."
	btnPlay.Text = "⏸ PLAYING"
	btnPlay.BackgroundColor3 = Color3.fromRGB(200, 150, 40)

	local currentPlayingTracks = {}

	local playbackConn
	playbackConn = RunService.Heartbeat:Connect(function()
		if not state.isPlaying or not rootPart or not humanoid then
			stopPlaybackAnims()
			playbackConn:Disconnect()
			return
		end

		local elapsed = tick() - state.playbackStartTime

		if elapsed >= totalDuration then
			state.isPlaying = false
			btnPlay.Text = "▶ PLAY"
			btnPlay.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
			statusLabel.Text = "Status: Playback complete"
			stopPlaybackAnims()
			playbackConn:Disconnect()

			rootPart.CFrame = state.recordedFrames[#state.recordedFrames].cframe
			return
		end

		-- Cari Index Frame
		local targetIdx = state.playbackIndex
		while targetIdx < #state.recordedFrames and (state.recordedFrames[targetIdx + 1].time - recordStartTime) <= elapsed do
			targetIdx = targetIdx + 1
		end
		state.playbackIndex = targetIdx

		local f1 = state.recordedFrames[targetIdx]
		local f2 = state.recordedFrames[math.min(targetIdx + 1, #state.recordedFrames)]

		local f1Time = f1.time - recordStartTime
		local f2Time = f2.time - recordStartTime

		local segDuration = f2Time - f1Time
		local segProgress = segDuration > 0 and math.clamp((elapsed - f1Time) / segDuration, 0, 1) or 0

		-- Lerp CFrame Presisi
		rootPart.CFrame = f1.cframe:Lerp(f2.cframe, segProgress)

		-- Trigger Animasi yang Terekam
		if f1.anims then
			for _, animData in ipairs(f1.anims) do
				if not currentPlayingTracks[animData.id] then
					local newAnim = Instance.new("Animation")
					newAnim.AnimationId = animData.id
					local track = animator:LoadAnimation(newAnim)
					track:Play()
					track:AdjustSpeed(animData.speed or 1)
					currentPlayingTracks[animData.id] = track
					table.insert(state.activePlaybackTracks, track)
				end
			end
		end
	end)
end

local function stopPlayback()
	state.isPlaying = false
	btnPlay.Text = "▶ PLAY"
	btnPlay.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
	statusLabel.Text = "Status: Stopped"
	stopPlaybackAnims()
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
		end)
	else
		stopRecording()
	end
end)

btnPlay.MouseButton1Click:Connect(function()
	if state.isRecording then return end
	if state.isPlaying then
		stopPlayback()
	else
		startPlayback()
	end
end)

btnStop.MouseButton1Click:Connect(function()
	if state.isRecording then stopRecording() end
	if state.isPlaying then stopPlayback() end
	statusLabel.Text = "Status: Idle"
end)

btnClear.MouseButton1Click:Connect(function()
	state.recordedFrames = {}
	clearVisualPath()
	frameCountLabel.Text = "Frames: 0"
	statusLabel.Text = "Status: Cleared"
	if state.isPlaying then stopPlayback() end
	if state.isRecording then stopRecording() end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	animator = humanoid:WaitForChild("Animator")
end)
