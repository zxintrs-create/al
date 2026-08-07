--========================================================--
-- ADVANCED R15 GHOST REPLAY ENGINE (CYBER NEON EDITION)
-- LocalScript - Standalone / Complete / Mobile Responsive
--========================================================--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Animator = Humanoid and Humanoid:WaitForChild("Animator", 10)

-- Configuration & Constants
local RECORD_FPS = 30
local RECORD_INTERVAL = 1 / RECORD_FPS
local MAX_RECORD_FRAMES = 9000 -- 5 Minutes at 30 FPS

-- Engine State Management
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

----------------------------------------------------
-- 1. DYNAMIC CHARACTER REBINDING & CLEANUP
----------------------------------------------------
local function StopPlayback()
	Playing = false
	Paused = false
	if ActiveConnections["Playback"] then
		pcall(function() ActiveConnections["Playback"]:Disconnect() end)
		ActiveConnections["Playback"] = nil
	end
	
	for id, track in pairs(ActiveGhostTracks) do
		pcall(function()
			track:Stop(0)
			track:Destroy()
		end)
	end
	table.clear(ActiveGhostTracks)

	if GhostCharacter then
		pcall(function() GhostCharacter:Destroy() end)
		GhostCharacter = nil
	end
end

local function StopRecord()
	Recording = false
	if ActiveConnections["Record"] then
		pcall(function() ActiveConnections["Record"]:Disconnect() end)
		ActiveConnections["Record"] = nil
	end
end

local function RebindCharacter(newChar)
	if not newChar then return end
	StopRecord()
	StopPlayback()

	Character = newChar
	RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
	Humanoid = newChar:WaitForChild("Humanoid", 10)
	if Humanoid then
		Animator = Humanoid:WaitForChild("Animator", 10)
	end
end

LocalPlayer.CharacterAdded:Connect(RebindCharacter)

local function CleanupTweens()
	for _, tween in ipairs(ActiveTweens) do
		pcall(function()
			tween:Cancel()
			tween:Destroy()
		end)
	end
	table.clear(ActiveTweens)
end

----------------------------------------------------
-- 2. GHOST CLONE CREATOR
----------------------------------------------------
local function CreateGhostClone()
	StopPlayback()

	if not Character or not RootPart or not Character:IsDescendantOf(workspace) then 
		return nil 
	end

	local oldArchivable = Character.Archivable
	Character.Archivable = true
	
	local success, clone = pcall(function()
		return Character:Clone()
	end)
	
	pcall(function()
		Character.Archivable = oldArchivable
	end)

	if not success or not clone then return nil end
	
	clone.Name = "Replay_Ghost_Cyan"

	for _, desc in ipairs(clone:GetDescendants()) do
		pcall(function()
			if desc:IsA("LuaSourceContainer") then
				desc:Destroy()
			elseif desc:IsA("BasePart") then
				desc.CanCollide = false
				desc.CanQuery = false
				desc.CanTouch = false
				desc.Anchored = true
				desc.Transparency = 0.45
				desc.Material = Enum.Material.ForceField
				desc.Color = Color3.fromRGB(0, 240, 255)
			end
		end)
	end

	local gHumanoid = clone:FindFirstChildOfClass("Humanoid")
	if gHumanoid then
		gHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		gHumanoid.EvaluateStateMachine = false
		if not gHumanoid:FindFirstChildOfClass("Animator") then
			Instance.new("Animator", gHumanoid)
		end
	end

	clone.Parent = workspace
	GhostCharacter = clone
	return clone
end

----------------------------------------------------
-- 3. UI STYLING ENGINE (CYBER NEON)
----------------------------------------------------
local function ApplyNeonGlow(guiObject)
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
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 240, 255)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(160, 32, 240)),
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

local function ApplyTouchEffects(button)
	ApplyNeonGlow(button)
	local baseSize = button.Size

	button.Activated:Connect(function()
		local pressTween = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(baseSize.X.Scale, baseSize.X.Offset - 2, baseSize.Y.Scale, baseSize.Y.Offset - 2),
			BackgroundColor3 = Color3.fromRGB(60, 20, 90)
		})
		pressTween:Play()
		
		task.delay(0.08, function()
			pcall(function()
				TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = baseSize,
					BackgroundColor3 = Color3.fromRGB(15, 10, 25)
				}):Play()
			end)
		end)
	end)
end

----------------------------------------------------
-- 4. GUI CONSTRUCTION
----------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

local ExistingGui = PlayerGui:FindFirstChild("R15_AdvancedGhostReplay_UI")
if ExistingGui then 
	ExistingGui:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R15_AdvancedGhostReplay_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

local OpenMenu = Instance.new("TextButton")
OpenMenu.Name = "OpenMenuButton"
OpenMenu.Size = UDim2.new(0, 90, 0, 40)
OpenMenu.Position = UDim2.new(0, 15, 0.5, -20)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
OpenMenu.Text = "OPEN MENU"
OpenMenu.TextColor3 = Color3.fromRGB(0, 240, 255)
OpenMenu.TextScaled = true
OpenMenu.Font = Enum.Font.GothamBold
OpenMenu.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = OpenMenu
ApplyTouchEffects(OpenMenu)

local Main = Instance.new("Frame")
Main.Name = "MainPanel"
Main.Size = UDim2.new(0, 280, 0, 500)
Main.Position = UDim2.new(0.5, -140, 1.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
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

ApplyNeonGlow(Main)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0, 26)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -30, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "R15 GHOST REPLAY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = HeaderFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
})
titleGradient.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -26, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 40, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.Parent = HeaderFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

local StatusPanel = Instance.new("Frame")
StatusPanel.Name = "StatusPanel"
StatusPanel.Size = UDim2.new(1, -10, 0, 48)
StatusPanel.Position = UDim2.new(0, 5, 0, 32)
StatusPanel.BackgroundColor3 = Color3.fromRGB(20, 12, 35)
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
Container.Size = UDim2.new(1, 0, 1, -88)
Container.Position = UDim2.new(0, 0, 0, 88)
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
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.LayoutOrder = layoutOrder
	b.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = b

	ApplyTouchEffects(b)
	return b
end

local RecordButton = CreateButton("RECORD", 1)
local StopButton = CreateButton("STOP", 2)

local PlayRow = Instance.new("Frame")
PlayRow.Size = UDim2.new(1, -10, 0, 30)
PlayRow.BackgroundTransparency = 1
PlayRow.LayoutOrder = 3
PlayRow.Parent = Container

local prLayout = Instance.new("UIListLayout")
prLayout.FillDirection = Enum.FillDirection.Horizontal
prLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
prLayout.Parent = PlayRow

local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.48, 0, 1, 0)
PlayButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PlayButton.Text = "PLAY GHOST"
PlayButton.TextColor3 = Color3.fromRGB(0, 255, 120)
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 10
PlayButton.Parent = PlayRow
ApplyTouchEffects(PlayButton)

local PauseButton = Instance.new("TextButton")
PauseButton.Size = UDim2.new(0.48, 0, 1, 0)
PauseButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PauseButton.Text = "PAUSE"
PauseButton.TextColor3 = Color3.fromRGB(255, 200, 0)
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 10
PauseButton.Parent = PlayRow
ApplyTouchEffects(PauseButton)

local SeekRow = Instance.new("Frame")
SeekRow.Size = UDim2.new(1, -10, 0, 30)
SeekRow.BackgroundTransparency = 1
SeekRow.LayoutOrder = 4
SeekRow.Parent = Container

local srLayout = Instance.new("UIListLayout")
srLayout.FillDirection = Enum.FillDirection.Horizontal
srLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
srLayout.Parent = SeekRow

local SeekBackButton = Instance.new("TextButton")
SeekBackButton.Size = UDim2.new(0.48, 0, 1, 0)
SeekBackButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SeekBackButton.Text = "SEEK BACK"
SeekBackButton.TextColor3 = Color3.fromRGB(0, 240, 255)
SeekBackButton.Font = Enum.Font.GothamBold
SeekBackButton.TextSize = 10
SeekBackButton.Parent = SeekRow
ApplyTouchEffects(SeekBackButton)

local SeekForwardButton = Instance.new("TextButton")
SeekForwardButton.Size = UDim2.new(0.48, 0, 1, 0)
SeekForwardButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SeekForwardButton.Text = "SEEK FORWARD"
SeekForwardButton.TextColor3 = Color3.fromRGB(0, 240, 255)
SeekForwardButton.Font = Enum.Font.GothamBold
SeekForwardButton.TextSize = 10
SeekForwardButton.Parent = SeekRow
ApplyTouchEffects(SeekForwardButton)

local TrimButton = CreateButton("TRIM TIMELINE", 5)

local StorageRow = Instance.new("Frame")
StorageRow.Size = UDim2.new(1, -10, 0, 30)
StorageRow.BackgroundTransparency = 1
StorageRow.LayoutOrder = 6
StorageRow.Parent = Container

local stLayout = Instance.new("UIListLayout")
stLayout.FillDirection = Enum.FillDirection.Horizontal
stLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
stLayout.Parent = StorageRow

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.48, 0, 1, 0)
SaveButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SaveButton.Text = "SAVE DATA"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 10
SaveButton.Parent = StorageRow
ApplyTouchEffects(SaveButton)

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(0.48, 0, 1, 0)
LoadButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
LoadButton.Text = "LOAD DATA"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 10
LoadButton.Parent = StorageRow
ApplyTouchEffects(LoadButton)

----------------------------------------------------
-- 5. PANEL ANIMATION & TOGGLE SYSTEM
----------------------------------------------------
local menuOpen = false
local isAnimating = false

local function OpenPanel()
	if isAnimating or menuOpen then return end
	isAnimating = true
	Main.Visible = true

	local openTween = TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -140, 0.5, -250)
	})
	openTween:Play()
	openTween.Completed:Connect(function()
		menuOpen = true
		isAnimating = false
	end)
end

local function ClosePanel()
	if isAnimating or not menuOpen then return end
	isAnimating = true

	local closeTween = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -140, 1.2, 0)
	})
	closeTween:Play()
	closeTween.Completed:Connect(function()
		Main.Visible = false
		menuOpen = false
		isAnimating = false
	end)
end

OpenMenu.Activated:Connect(function()
	if menuOpen then
		ClosePanel()
	else
		OpenPanel()
	end
end)

CloseButton.Activated:Connect(ClosePanel)

----------------------------------------------------
-- 6. RECORD ENGINE
----------------------------------------------------
local function FetchActiveAnimations()
	local activeAnimList = {}
	if Animator then
		local success, playingTracks = pcall(function()
			return Animator:GetPlayingAnimationTracks()
		end)
		if success and playingTracks then
			for _, track in ipairs(playingTracks) do
				pcall(function()
					if track.Animation and track.Animation.AnimationId ~= "" then
						table.insert(activeAnimList, {
							AnimationId = track.Animation.AnimationId,
							TimePosition = track.TimePosition,
							Speed = track.Speed,
							Weight = track.WeightTarget
						})
					end
				end)
			end
		end
	end
	return activeAnimList
end

local function CaptureFrame()
	if not RootPart or not Humanoid or not Character or not RootPart:IsDescendantOf(workspace) then return end
	
	if #RecordData >= MAX_RECORD_FRAMES then
		StopRecord()
		StatusLabel.Text = "STATUS: MAX DURATION"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end

	local currentState = Enum.HumanoidStateType.None
	pcall(function()
		currentState = Humanoid:GetState()
	end)

	local frame = {
		Time = os.clock() - RecordStart,
		CFrame = RootPart.CFrame,
		Position = RootPart.Position,
		Rotation = RootPart.Orientation,
		Velocity = RootPart.AssemblyLinearVelocity,
		HumanoidState = currentState,
		Animations = FetchActiveAnimations()
	}

	table.insert(RecordData, frame)

	StatusLabel.Text = "STATUS: RECORDING"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	FrameLabel.Text = string.format("FRAMES: %d | DURATION: %.1fs", #RecordData, frame.Time)
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
	StatusLabel.Text = "STATUS: IDLE"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
end)

----------------------------------------------------
-- 7. REPLAY & ANIMATION SYNCHRONIZATION ENGINE
----------------------------------------------------
local function SynchronizeGhostAnimations(ghostAnimator, animDataList)
	if not ghostAnimator then return end

	local activeIdsThisFrame = {}

	for _, animInfo in ipairs(animDataList) do
		local animId = animInfo.AnimationId
		activeIdsThisFrame[animId] = true

		local track = ActiveGhostTracks[animId]
		if not track then
			local animObj = Instance.new("Animation")
			animObj.AnimationId = animId
			local ok, loadedTrack = pcall(function()
				return ghostAnimator:LoadAnimation(animObj)
			end)

			if ok and loadedTrack then
				track = loadedTrack
				ActiveGhostTracks[animId] = track
				pcall(function()
					track:Play(0.1, animInfo.Weight, animInfo.Speed)
				end)
			end
		end

		if track then
			pcall(function()
				if not track.IsPlaying then
					track:Play(0.1, animInfo.Weight, animInfo.Speed)
				end
				track:AdjustSpeed(animInfo.Speed)
				track:AdjustWeight(animInfo.Weight, 0.1)

				if math.abs(track.TimePosition - animInfo.TimePosition) > 0.15 then
					track.TimePosition = animInfo.TimePosition
				end
			end)
		end
	end

	for animId, track in pairs(ActiveGhostTracks) do
		if not activeIdsThisFrame[animId] then
			pcall(function()
				track:Stop(0.1)
			end)
			ActiveGhostTracks[animId] = nil
		end
	end
end

local function StartPlayback()
	if #RecordData < 2 then return end

	StopRecord()

	if not Playing then
		StopPlayback()
		local ghost = CreateGhostClone()
		if not ghost then return end

		Playing = true
		Paused = false
		PlaybackElapsed = 0
	else
		Paused = false
	end

	StatusLabel.Text = "STATUS: PLAYING"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)

	local ghostRoot = GhostCharacter:WaitForChild("HumanoidRootPart", 5)
	local ghostHumanoid = GhostCharacter:FindFirstChildOfClass("Humanoid")
	local ghostAnimator = ghostHumanoid and ghostHumanoid:FindFirstChildOfClass("Animator")

	if not ghostRoot or not ghostAnimator then return end

	local totalDuration = RecordData[#RecordData].Time - RecordData[1].Time
	local playbackStartTime = os.clock() - PlaybackElapsed

	if ActiveConnections["Playback"] then
		pcall(function() ActiveConnections["Playback"]:Disconnect() end)
		ActiveConnections["Playback"] = nil
	end

	ActiveConnections["Playback"] = RunService.Heartbeat:Connect(function()
		if not Playing or Paused or not GhostCharacter or not ghostRoot then return end

		PlaybackElapsed = os.clock() - playbackStartTime
		if PlaybackElapsed >= totalDuration then
			StopPlayback()
			StatusLabel.Text = "STATUS: IDLE"
			StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
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

		ghostRoot.CFrame = f1.CFrame:Lerp(f2.CFrame, alpha)
		SynchronizeGhostAnimations(ghostAnimator, f1.Animations)

		FrameLabel.Text = string.format("FRAME: %d/%d | DURATION: %.1fs", i1, #RecordData, PlaybackElapsed)
	end)
end

PlayButton.Activated:Connect(StartPlayback)

PauseButton.Activated:Connect(function()
	if Playing and not Paused then
		Paused = true
		StatusLabel.Text = "STATUS: PAUSED"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		for _, track in pairs(ActiveGhostTracks) do
			pcall(function()
				track:AdjustSpeed(0)
			end)
		end
	end
end)

----------------------------------------------------
-- 8. SEEK, TRIM, SAVE & LOAD
----------------------------------------------------
local function UpdatePreviewState()
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
			if gAnim then SynchronizeGhostAnimations(gAnim, RecordData[CutIndex].Animations) end
		end
		FrameLabel.Text = string.format("SEEK: %d/%d | TIME: %.1fs", CutIndex, #RecordData, RecordData[CutIndex].Time)
	end
end

SeekBackButton.Activated:Connect(function()
	if #RecordData == 0 then return end
	StopRecord()
	Playing = false
	Paused = true
	CutIndex = math.max(1, CutIndex - 15)
	UpdatePreviewState()
end)

SeekForwardButton.Activated:Connect(function()
	if #RecordData == 0 then return end
	StopRecord()
	Playing = false
	Paused = true
	CutIndex = math.min(#RecordData, CutIndex + 15)
	UpdatePreviewState()
end)

TrimButton.Activated:Connect(function()
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
	
	SavedData = {}
	for i, frame in ipairs(RecordData) do
		local animsCopy = {}
		for _, anim in ipairs(frame.Animations) do
			table.insert(animsCopy, {
				AnimationId = anim.AnimationId,
				TimePosition = anim.TimePosition,
				Speed = anim.Speed,
				Weight = anim.Weight
			})
		end
		table.insert(SavedData, {
			Time = frame.Time,
			CFrame = frame.CFrame,
			Position = frame.Position,
			Rotation = frame.Rotation,
			Velocity = frame.Velocity,
			HumanoidState = frame.HumanoidState,
			Animations = animsCopy
		})
	end

	StatusLabel.Text = "STATUS: SAVED"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
end)

LoadButton.Activated:Connect(function()
	if #SavedData == 0 then return end
	StopRecord()
	StopPlayback()

	RecordData = {}
	for i, frame in ipairs(SavedData) do
		local animsCopy = {}
		for _, anim in ipairs(frame.Animations) do
			table.insert(animsCopy, {
				AnimationId = anim.AnimationId,
				TimePosition = anim.TimePosition,
				Speed = anim.Speed,
				Weight = anim.Weight
			})
		end
		table.insert(RecordData, {
			Time = frame.Time,
			CFrame = frame.CFrame,
			Position = frame.Position,
			Rotation = frame.Rotation,
			Velocity = frame.Velocity,
			HumanoidState = frame.HumanoidState,
			Animations = animsCopy
		})
	end

	CutIndex = 1

	StatusLabel.Text = "STATUS: LOADED"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
	FrameLabel.Text = string.format("FRAMES: %d", #RecordData)
end)

----------------------------------------------------
-- 9. CLEANUP ON DESTROY
----------------------------------------------------
ScreenGui.Destroying:Connect(function()
	StopRecord()
	StopPlayback()
	CleanupTweens()
end)
