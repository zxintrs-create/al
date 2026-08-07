--========================================================--
-- R15 ADVANCED GHOST REPLAY SYSTEM V4
-- FULL SINGLE LOCAL SCRIPT - MOBILE & R15 OPTIMIZED
--========================================================--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

-- Core Settings & State
local RECORD_FPS = 30
local RECORD_INTERVAL = 1 / RECORD_FPS
local MAX_RECORD_FRAMES = 9000 -- Max 5 Menit (30 FPS * 300s)

local RecordData = {}
local SavedData = {}

local Recording = false
local Playing = false
local Paused = false

local CutIndex = 1
local RecordStart = 0
local RecordTimer = 0
local PlaybackElapsed = 0

local ActiveConnections = {}
local ActiveTweens = {}
local ActiveGhostTracks = {}
local GhostCharacter = nil

-- Character Reload Handler
local function SetupCharacter(newChar)
	Character = newChar
	RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
	Humanoid = newChar:WaitForChild("Humanoid", 10)
	if Humanoid then
		Animator = Humanoid:WaitForChild("Animator", 10)
	end
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)

----------------------------------------------------
-- 1. UTILITY & CLEANUP
----------------------------------------------------
local function CleanupTweens()
	for _, tween in ipairs(ActiveTweens) do
		pcall(function()
			tween:Cancel()
			tween:Destroy()
		end)
	end
	table.clear(ActiveTweens)
end

local function StopGhostAnimations()
	for _, track in pairs(ActiveGhostTracks) do
		pcall(function()
			track:Stop(0)
			track:Destroy()
		end)
	end
	table.clear(ActiveGhostTracks)
end

local function CleanupGhost()
	StopGhostAnimations()
	if GhostCharacter then
		GhostCharacter:Destroy()
		GhostCharacter = nil
	end
end

----------------------------------------------------
-- 2. GHOST CLONE SYSTEM (R15 COMPATIBLE)
----------------------------------------------------
local function CreateGhostClone()
	CleanupGhost()
	if not Character then return nil end

	local oldArchivable = Character.Archivable
	Character.Archivable = true
	
	local clone = Character:Clone()
	Character.Archivable = oldArchivable
	
	clone.Name = "Replay_Ghost_R15"

	-- Hilangkan Script internal, Animate script asli, dan sesuaikan Fisika
	for _, desc in ipairs(clone:GetDescendants()) do
		if desc:IsA("LuaSourceContainer") then
			desc:Destroy()
		elseif desc:IsA("BasePart") then
			desc.CanCollide = false
			desc.CanQuery = false
			desc.CanTouch = false
			desc.Anchored = true
			desc.Transparency = math.clamp(desc.Transparency + 0.35, 0.35, 0.85)
			desc.Material = Enum.Material.Forcefield
			desc.Color = Color3.fromRGB(0, 240, 255)
		end
	end

	-- Pastikan Ghost Memiliki Humanoid & Animator aktif
	local gHumanoid = clone:FindFirstChildOfClass("Humanoid")
	if gHumanoid then
		gHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		gHumanoid.EvaluateStateMachine = false
		local gAnimator = gHumanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", gHumanoid)
	end

	clone.Parent = workspace
	GhostCharacter = clone
	return clone
end

----------------------------------------------------
-- 3. NEON UI STYLING & ANIMATIONS
----------------------------------------------------
local function PremiumNeonBorder(guiObject)
	local outerStroke = Instance.new("UIStroke")
	outerStroke.Name = "OuterGlowStroke"
	outerStroke.Thickness = 3
	outerStroke.Transparency = 0.4
	outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outerStroke.Parent = guiObject

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Name = "InnerNeonStroke"
	innerStroke.Thickness = 2
	innerStroke.Transparency = 0
	innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	innerStroke.Parent = guiObject

	local neonGradient = Instance.new("UIGradient")
	neonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(160, 32, 240)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 240, 255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 100, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 20, 147))
	})
	neonGradient.Rotation = 45
	neonGradient.Parent = innerStroke

	local outerGradient = neonGradient:Clone()
	outerGradient.Parent = outerStroke

	local rotTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local rotTween = TweenService:Create(neonGradient, rotTweenInfo, {Rotation = 405})
	local rotTweenOuter = TweenService:Create(outerGradient, rotTweenInfo, {Rotation = 405})
	rotTween:Play()
	rotTweenOuter:Play()

	local pulseInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local pulseTween = TweenService:Create(outerStroke, pulseInfo, {Transparency = 0.8, Thickness = 5})
	pulseTween:Play()

	table.insert(ActiveTweens, rotTween)
	table.insert(ActiveTweens, rotTweenOuter)
	table.insert(ActiveTweens, pulseTween)
end

local function ApplyButtonEffects(button)
	PremiumNeonBorder(button)
	local baseSize = button.Size
	local hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(button, hoverInfo, {
			Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset + 4, baseSize.Y.Scale, baseSize.Y.Offset + 2),
			BackgroundColor3 = Color3.fromRGB(35, 15, 55)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, hoverInfo, {
			Size = baseSize,
			BackgroundColor3 = Color3.fromRGB(15, 10, 25)
		}):Play()
	end)

	button.Activated:Connect(function()
		local pressTween = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset - 2, baseSize.Y.Scale, baseSize.Y.Offset - 2),
			BackgroundColor3 = Color3.fromRGB(80, 20, 120)
		})
		pressTween:Play()
		task.delay(0.08, function()
			TweenService:Create(button, hoverInfo, {
				Size = baseSize,
				BackgroundColor3 = Color3.fromRGB(15, 10, 25)
			}):Play()
		end)
	end)
end

----------------------------------------------------
-- 4. GUI CONSTRUCTION
----------------------------------------------------
local ExistingGui = LocalPlayer.PlayerGui:FindFirstChild("R15_ReplaySystem_UI")
if ExistingGui then ExistingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R15_ReplaySystem_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local OpenMenu = Instance.new("TextButton")
OpenMenu.Name = "OpenMenuButton"
OpenMenu.Size = UDim2.new(0, 80, 0, 40)
OpenMenu.Position = UDim2.new(0, 15, 0.5, -20)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
OpenMenu.Text = "MENU"
OpenMenu.TextColor3 = Color3.fromRGB(0, 240, 255)
OpenMenu.TextScaled = true
OpenMenu.Font = Enum.Font.GothamBold
OpenMenu.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = OpenMenu
ApplyButtonEffects(OpenMenu)

local Main = Instance.new("Frame")
Main.Name = "MainPanel"
Main.Size = UDim2.new(0, 270, 0, 490)
Main.Position = UDim2.new(0.5, -135, 1.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
Main.BackgroundTransparency = 0.1
Main.Visible = false
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 8)
mainPadding.PaddingBottom = UDim.new(0, 8)
mainPadding.PaddingLeft = UDim.new(0, 8)
mainPadding.PaddingRight = UDim.new(0, 8)
mainPadding.Parent = Main

PremiumNeonBorder(Main)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "R15 REPLAY ENGINE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 255))
})
titleGradient.Parent = Title

local StatusPanel = Instance.new("Frame")
StatusPanel.Name = "StatusPanel"
StatusPanel.Size = UDim2.new(1, -10, 0, 50)
StatusPanel.Position = UDim2.new(0, 5, 0, 32)
StatusPanel.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
StatusPanel.BackgroundTransparency = 0.3
StatusPanel.Parent = Main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = StatusPanel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0.5, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: IDLE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.Parent = StatusPanel

local FrameLabel = Instance.new("TextLabel")
FrameLabel.Name = "FrameLabel"
FrameLabel.Size = UDim2.new(1, 0, 0.5, 0)
FrameLabel.Position = UDim2.new(0, 0, 0.5, 0)
FrameLabel.BackgroundTransparency = 1
FrameLabel.Text = "FRAMES: 0 | DURATION: 0.0s"
FrameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FrameLabel.Font = Enum.Font.Gotham
FrameLabel.TextSize = 11
FrameLabel.Parent = StatusPanel

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -90)
Container.Position = UDim2.new(0, 0, 0, 90)
Container.BackgroundTransparency = 1
Container.Parent = Main

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = Container

local function CreateButton(text, layoutOrder)
	local b = Instance.new("TextButton")
	b.Name = text .. "Button"
	b.Size = UDim2.new(1, -10, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.LayoutOrder = layoutOrder
	b.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = b

	ApplyButtonEffects(b)
	return b
end

local RecordButton = CreateButton("RECORD", 1)
local StopButton = CreateButton("STOP", 2)

local PlayControlRow = Instance.new("Frame")
PlayControlRow.Size = UDim2.new(1, -10, 0, 30)
PlayControlRow.BackgroundTransparency = 1
PlayControlRow.LayoutOrder = 3
PlayControlRow.Parent = Container

local pcLayout = Instance.new("UIListLayout")
pcLayout.FillDirection = Enum.FillDirection.Horizontal
pcLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
pcLayout.Parent = PlayControlRow

local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.48, 0, 1, 0)
PlayButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PlayButton.Text = "PLAY GHOST"
PlayButton.TextColor3 = Color3.fromRGB(0, 255, 100)
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 11
PlayButton.Parent = PlayControlRow
ApplyButtonEffects(PlayButton)

local PauseButton = Instance.new("TextButton")
PauseButton.Size = UDim2.new(0.48, 0, 1, 0)
PauseButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PauseButton.Text = "PAUSE"
PauseButton.TextColor3 = Color3.fromRGB(255, 200, 0)
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 11
PauseButton.Parent = PlayControlRow
ApplyButtonEffects(PauseButton)

local NavRow = Instance.new("Frame")
NavRow.Size = UDim2.new(1, -10, 0, 30)
NavRow.BackgroundTransparency = 1
NavRow.LayoutOrder = 4
NavRow.Parent = Container

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
navLayout.Parent = NavRow

local BackButton = Instance.new("TextButton")
BackButton.Size = UDim2.new(0.48, 0, 1, 0)
BackButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
BackButton.Text = "<< SEEK"
BackButton.TextColor3 = Color3.fromRGB(0, 240, 255)
BackButton.Font = Enum.Font.GothamBold
BackButton.TextSize = 11
BackButton.Parent = NavRow
ApplyButtonEffects(BackButton)

local ForwardButton = Instance.new("TextButton")
ForwardButton.Size = UDim2.new(0.48, 0, 1, 0)
ForwardButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
ForwardButton.Text = "SEEK >>"
ForwardButton.TextColor3 = Color3.fromRGB(0, 240, 255)
ForwardButton.Font = Enum.Font.GothamBold
ForwardButton.TextSize = 11
ForwardButton.Parent = NavRow
ApplyButtonEffects(ForwardButton)

local CutButton = CreateButton("TRIM TIMELINE", 5)

local SaveLoadRow = Instance.new("Frame")
SaveLoadRow.Size = UDim2.new(1, -10, 0, 30)
SaveLoadRow.BackgroundTransparency = 1
SaveLoadRow.LayoutOrder = 6
SaveLoadRow.Parent = Container

local slLayout = Instance.new("UIListLayout")
slLayout.FillDirection = Enum.FillDirection.Horizontal
slLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
slLayout.Parent = SaveLoadRow

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.48, 0, 1, 0)
SaveButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SaveButton.Text = "SAVE DATA"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 11
SaveButton.Parent = SaveLoadRow
ApplyButtonEffects(SaveButton)

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(0.48, 0, 1, 0)
LoadButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
LoadButton.Text = "LOAD DATA"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 11
LoadButton.Parent = SaveLoadRow
ApplyButtonEffects(LoadButton)

----------------------------------------------------
-- 5. MENU TOGGLE ANIMATION
----------------------------------------------------
local menuOpen = false
local animInFlight = false

local function ToggleMenu()
	if animInFlight then return end
	animInFlight = true

	if not menuOpen then
		Main.Visible = true
		local tween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, -135, 0.5, -245)
		})
		tween:Play()
		tween.Completed:Connect(function()
			menuOpen = true
			animInFlight = false
		end)
	else
		local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -135, 1.2, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			Main.Visible = false
			menuOpen = false
			animInFlight = false
		end)
	end
end

OpenMenu.Activated:Connect(ToggleMenu)

----------------------------------------------------
-- 6. ANIMATION & RECORD ENGINE
----------------------------------------------------
local function GetActiveAnimations()
	local activeAnimList = {}
	if Animator then
		local playingTracks = Animator:GetPlayingAnimationTracks()
		for _, track in ipairs(playingTracks) do
			if track.Animation and track.Animation.AnimationId ~= "" then
				table.insert(activeAnimList, {
					AnimationId = track.Animation.AnimationId,
					TimePosition = track.TimePosition,
					Speed = track.Speed,
					Weight = track.WeightTarget,
					IsPlaying = track.IsPlaying
				})
			end
		end
	end
	return activeAnimList
end

local function CaptureFrame()
	if not RootPart or not Humanoid or not Character then return end
	if #RecordData >= MAX_RECORD_FRAMES then
		Recording = false
		StatusLabel.Text = "STATUS: MAX MEMORY REACHED"
		return
	end

	local currentState = Humanoid:GetState()
	local frame = {
		Time = os.clock() - RecordStart,
		CFrame = RootPart.CFrame,
		Position = RootPart.Position,
		Rotation = RootPart.Orientation,
		Velocity = RootPart.AssemblyLinearVelocity,
		HumanoidState = currentState,
		Animations = GetActiveAnimations()
	}

	table.insert(RecordData, frame)

	StatusLabel.Text = "STATUS: RECORDING"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	FrameLabel.Text = string.format("FRAMES: %d | DURATION: %.1fs", #RecordData, frame.Time)
end

local function StopPlayback()
	Playing = false
	Paused = false
	if ActiveConnections["Playback"] then
		ActiveConnections["Playback"]:Disconnect()
		ActiveConnections["Playback"] = nil
	end
	CleanupGhost()
	StatusLabel.Text = "STATUS: IDLE"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
end

local function StopRecord()
	Recording = false
	if ActiveConnections["Record"] then
		ActiveConnections["Record"]:Disconnect()
		ActiveConnections["Record"] = nil
	end
	if not Playing then
		StatusLabel.Text = "STATUS: STOPPED"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	end
end

local function StartRecord()
	StopPlayback()
	StopRecord()

	table.clear(RecordData)
	CutIndex = 1

	if not RootPart or not Humanoid then return end

	Recording = true
	RecordStart = os.clock()
	RecordTimer = 0
	
	CaptureFrame()

	ActiveConnections["Record"] = RunService.Heartbeat:Connect(function(dt)
		if Recording then
			RecordTimer = RecordTimer + dt
			while RecordTimer >= RECORD_INTERVAL do
				RecordTimer = RecordTimer - RECORD_INTERVAL
				CaptureFrame()
			end
		end
	end)
end

RecordButton.Activated:Connect(StartRecord)
StopButton.Activated:Connect(function()
	StopRecord()
	StopPlayback()
end)

----------------------------------------------------
-- 7. PLAYBACK & ANIMATION SYNCHRONIZATION ENGINE
----------------------------------------------------
local function SyncGhostAnimations(ghostAnimator, animDataList)
	if not ghostAnimator then return end

	local currentActiveIds = {}

	for _, animInfo in ipairs(animDataList) do
		local animId = animInfo.AnimationId
		currentActiveIds[animId] = true

		local track = ActiveGhostTracks[animId]
		if not track then
			local animObj = Instance.new("Animation")
			animObj.AnimationId = animId
			local success, loadedTrack = pcall(function()
				return ghostAnimator:LoadAnimation(animObj)
			end)
			
			if success and loadedTrack then
				track = loadedTrack
				ActiveGhostTracks[animId] = track
				track:Play(0.1, animInfo.Weight, animInfo.Speed)
			end
		end

		if track then
			if not track.IsPlaying then
				track:Play(0.1, animInfo.Weight, animInfo.Speed)
			end
			track:AdjustSpeed(animInfo.Speed)
			track:AdjustWeight(animInfo.Weight, 0.1)

			-- Sync Waktu Animasi apabila terjadi desinkronisasi > 0.15s
			if math.abs(track.TimePosition - animInfo.TimePosition) > 0.15 then
				track.TimePosition = animInfo.TimePosition
			end
		end
	end

	-- Hentikan animasi yang sudah tidak aktif pada frame ini
	for animId, track in pairs(ActiveGhostTracks) do
		if not currentActiveIds[animId] then
			track:Stop(0.1)
			ActiveGhostTracks[animId] = nil
		end
	end
end

local function StartPlayback()
	if #RecordData < 2 then return end

	StopRecord()
	
	if not Playing then
		CleanupGhost()
		local ghost = CreateGhostClone()
		if not ghost then return end
		
		Playing = true
		Paused = false
		PlaybackElapsed = 0
	else
		Paused = false
	end

	StatusLabel.Text = "STATUS: PLAYING (GHOST)"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)

	local ghostRoot = GhostCharacter:WaitForChild("HumanoidRootPart", 5)
	local ghostHumanoid = GhostCharacter:FindFirstChildOfClass("Humanoid")
	local ghostAnimator = ghostHumanoid and ghostHumanoid:FindFirstChildOfClass("Animator")

	if not ghostRoot or not ghostAnimator then return end

	local totalDuration = RecordData[#RecordData].Time - RecordData[1].Time
	local playbackStartTime = os.clock() - PlaybackElapsed

	if ActiveConnections["Playback"] then ActiveConnections["Playback"]:Disconnect() end

	ActiveConnections["Playback"] = RunService.Heartbeat:Connect(function()
		if not Playing or Paused or not GhostCharacter or not ghostRoot then return end

		PlaybackElapsed = os.clock() - playbackStartTime
		if PlaybackElapsed >= totalDuration then
			StopPlayback()
			return
		end

		local targetTime = RecordData[1].Time + PlaybackElapsed
		local i1, i2 = 1, #RecordData

		for i = 1, #RecordData - 1 do
			if RecordData[i].Time <= targetTime and RecordData[i + 1].Time >= targetTime then
				i1 = i
				i2 = i + 1
				break
			end
		end

		local f1 = RecordData[i1]
		local f2 = RecordData[i2]
		local span = f2.Time - f1.Time
		local alpha = (span > 0) and ((targetTime - f1.Time) / span) or 0
		alpha = math.clamp(alpha, 0, 1)

		-- Interpolasi CFrame posisi & rotasi Ghost
		ghostRoot.CFrame = f1.CFrame:Lerp(f2.CFrame, alpha)

		-- Sinkronisasi Animasi R15
		SyncGhostAnimations(ghostAnimator, f1.Animations)

		FrameLabel.Text = string.format("FRAME: %d/%d | TIME: %.1fs", i1, #RecordData, PlaybackElapsed)
	end)
end

PlayButton.Activated:Connect(StartPlayback)

PauseButton.Activated:Connect(function()
	if Playing and not Paused then
		Paused = true
		StatusLabel.Text = "STATUS: PAUSED"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		for _, track in pairs(ActiveGhostTracks) do
			track:AdjustSpeed(0)
		end
	end
end)

----------------------------------------------------
-- 8. SEEK, TRIM, SAVE & LOAD
----------------------------------------------------
local function UpdatePreviewPosition()
	CutIndex = math.clamp(CutIndex, 1, math.max(1, #RecordData))
	if RecordData[CutIndex] then
		if not GhostCharacter then
			CreateGhostClone()
		end
		if GhostCharacter then
			local gRoot = GhostCharacter:FindFirstChild("HumanoidRootPart")
			local gHum = GhostCharacter:FindFirstChildOfClass("Humanoid")
			local gAnim = gHum and gHum:FindFirstChildOfClass("Animator")

			if gRoot then gRoot.CFrame = RecordData[CutIndex].CFrame end
			if gAnim then SyncGhostAnimations(gAnim, RecordData[CutIndex].Animations) end
		end
		FrameLabel.Text = string.format("NAV: %d/%d | TIME: %.1fs", CutIndex, #RecordData, RecordData[CutIndex].Time)
	end
end

BackButton.Activated:Connect(function()
	if #RecordData == 0 then return end
	StopRecord()
	Playing = false
	Paused = true
	CutIndex = math.max(1, CutIndex - 15)
	UpdatePreviewPosition()
end)

ForwardButton.Activated:Connect(function()
	if #RecordData == 0 then return end
	StopRecord()
	Playing = false
	Paused = true
	CutIndex = math.min(#RecordData, CutIndex + 15)
	UpdatePreviewPosition()
end)

CutButton.Activated:Connect(function()
	if #RecordData == 0 or CutIndex >= #RecordData then return end
	StopRecord()
	StopPlayback()

	for i = #RecordData, CutIndex + 1, -1 do
		table.remove(RecordData, i)
	end

	StatusLabel.Text = "STATUS: TRIMMED"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	FrameLabel.Text = string.format("FRAMES: %d", #RecordData)
end)

SaveButton.Activated:Connect(function()
	if #RecordData == 0 then return end
	SavedData = table.clone(RecordData)
	StatusLabel.Text = "STATUS: DATA SAVED"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
end)

LoadButton.Activated:Connect(function()
	if #SavedData == 0 then return end
	StopRecord()
	StopPlayback()

	RecordData = table.clone(SavedData)
	CutIndex = 1

	StatusLabel.Text = "STATUS: DATA LOADED"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
	FrameLabel.Text = string.format("FRAMES: %d", #RecordData)
end)

----------------------------------------------------
-- 9. CLEANUP HANDLER
----------------------------------------------------
ScreenGui.Destroying:Connect(function()
	StopRecord()
	StopPlayback()
	CleanupTweens()
	CleanupGhost()
end)
