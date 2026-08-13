local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Animator = Humanoid and Humanoid:WaitForChild("Animator", 10)

local RECORD_FPS = 30
local RECORD_INTERVAL = 1 / RECORD_FPS
local MAX_RECORD_FRAMES = 9000

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

local function DisconnectConnection(name)
	if ActiveConnections[name] then
		pcall(function()
			ActiveConnections[name]:Disconnect()
		end)
		ActiveConnections[name] = nil
	end
end

local function StopPlayback()
	Playing = false
	Paused = false

	DisconnectConnection("Playback")

	for id, track in pairs(ActiveGhostTracks) do
		pcall(function()
			track:Stop(0)
			track:Destroy()
		end)
		ActiveGhostTracks[id] = nil
	end

	table.clear(ActiveGhostTracks)

	if GhostCharacter then
		pcall(function()
			GhostCharacter:Destroy()
		end)
		GhostCharacter = nil
	end
end

local function StopRecord()
	Recording = false
	DisconnectConnection("Record")
end

local function RebindCharacter(newChar)
	if not newChar then
		return
	end

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

	Character.Archivable = oldArchivable

	if not success or not clone then
		return nil
	end

	clone.Name = "Replay_Ghost_Cyan"

	for _, desc in ipairs(clone:GetDescendants()) do
		pcall(function()
			if desc:IsA("LuaSourceContainer") then
				desc:Destroy()
			elseif desc:IsA("BasePart") then
				desc.CanCollide = false
				desc.CanQuery = false
				desc.CanTouch = false
				desc.Anchored = false
				desc.Massless = true
				desc.Transparency = 0.45
				desc.Material = Enum.Material.ForceField
				desc.Color = Color3.fromRGB(0, 240, 255)
			end
		end)
	end

	local gHumanoid = clone:FindFirstChildOfClass("Humanoid")

	if gHumanoid then
		gHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		gHumanoid.AutoRotate = false
		gHumanoid.WalkSpeed = 0
		gHumanoid.JumpPower = 0
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		gHumanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
		gHumanoid:ChangeState(Enum.HumanoidStateType.Physics)

		if not gHumanoid:FindFirstChildOfClass("Animator") then
			Instance.new("Animator", gHumanoid)
		end
	end

	local cloneRoot = clone:FindFirstChild("HumanoidRootPart")

	if cloneRoot then
		cloneRoot.CanCollide = false
		cloneRoot.CanQuery = false
		cloneRoot.CanTouch = false
		cloneRoot.Massless = true
	end

	clone.Parent = workspace
	GhostCharacter = clone

	return clone
end

local function ApplyNeonGlow(guiObject)
	local outerStroke = Instance.new("UIStroke")
	outerStroke.Name = "OuterGlowStroke"
	outerStroke.Thickness = 2
	outerStroke.Transparency = 0.4
	outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outerStroke.Parent = guiObject

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Name = "InnerNeonStroke"
	innerStroke.Thickness = 1.5
	innerStroke.Transparency = 0
	innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	innerStroke.Parent = guiObject

	local neonGradient = Instance.new("UIGradient")
	neonGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 32, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
	})
	neonGradient.Rotation = 45
	neonGradient.Parent = innerStroke

	local outerGradient = neonGradient:Clone()
	outerGradient.Parent = outerStroke

	local rotTweenInfo = TweenInfo.new(
		4,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1
	)

	local rotTween = TweenService:Create(
		neonGradient,
		rotTweenInfo,
		{Rotation = 405}
	)

	local rotTweenOuter = TweenService:Create(
		outerGradient,
		rotTweenInfo,
		{Rotation = 405}
	)

	rotTween:Play()
	rotTweenOuter:Play()

	table.insert(ActiveTweens, rotTween)
	table.insert(ActiveTweens, rotTweenOuter)
end

local function BindTouchClick(button, callback)
	button.Active = true

	button.Activated:Connect(function()
		pcall(callback)
	end)
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

if not PlayerGui then
	return
end

local ExistingGui = PlayerGui:FindFirstChild("R15_AdvancedGhostReplay_UI")

if ExistingGui then
	ExistingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R15_AdvancedGhostReplay_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

local OpenMenu = Instance.new("TextButton")
OpenMenu.Name = "OpenMenuButton"
OpenMenu.Size = UDim2.new(0, 95, 0, 38)
OpenMenu.Position = UDim2.new(0, 15, 0.45, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
OpenMenu.Text = "OPEN MENU"
OpenMenu.TextColor3 = Color3.fromRGB(0, 240, 255)
OpenMenu.TextScaled = true
OpenMenu.Font = Enum.Font.GothamBold
OpenMenu.Active = true
OpenMenu.Selectable = true
OpenMenu.ZIndex = 100
OpenMenu.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = OpenMenu

ApplyNeonGlow(OpenMenu)

local Main = Instance.new("Frame")
Main.Name = "MainPanel"
Main.Size = UDim2.new(0, 260, 0, 350)
Main.Position = UDim2.new(0.5, -130, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
Main.BackgroundTransparency = 0.1
Main.Visible = false
Main.ZIndex = 200
Main.Active = false
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = Main

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 6)
mainPadding.PaddingBottom = UDim.new(0, 6)
mainPadding.PaddingLeft = UDim.new(0, 6)
mainPadding.PaddingRight = UDim.new(0, 6)
mainPadding.Parent = Main

ApplyNeonGlow(Main)

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(1, 0, 0, 24)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.ZIndex = 201
HeaderFrame.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -26, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "R15 GHOST REPLAY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 201
Title.Parent = HeaderFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
})
titleGradient.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -24, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 40, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12
CloseButton.Active = true
CloseButton.Selectable = true
CloseButton.ZIndex = 202
CloseButton.Parent = HeaderFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

local StatusPanel = Instance.new("Frame")
StatusPanel.Name = "StatusPanel"
StatusPanel.Size = UDim2.new(1, -8, 0, 40)
StatusPanel.Position = UDim2.new(0, 4, 0, 28)
StatusPanel.BackgroundColor3 = Color3.fromRGB(20, 12, 35)
StatusPanel.BackgroundTransparency = 0.3
StatusPanel.ZIndex = 201
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
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 202
StatusLabel.Parent = StatusPanel

local FrameLabel = Instance.new("TextLabel")
FrameLabel.Name = "FrameLabel"
FrameLabel.Size = UDim2.new(1, 0, 0.5, 0)
FrameLabel.Position = UDim2.new(0, 0, 0.5, 0)
FrameLabel.BackgroundTransparency = 1
FrameLabel.Text = "FRAMES: 0 | DURATION: 0.0s"
FrameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FrameLabel.Font = Enum.Font.Gotham
FrameLabel.TextSize = 10
FrameLabel.ZIndex = 202
FrameLabel.Parent = StatusPanel

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -72)
Container.Position = UDim2.new(0, 0, 0, 72)
Container.BackgroundTransparency = 1
Container.ZIndex = 201
Container.Parent = Main

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = Container

local function CreateButton(text, layoutOrder)
	local b = Instance.new("TextButton")
	b.Name = text .. "Button"
	b.Size = UDim2.new(1, -8, 0, 26)
	b.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 10
	b.Font = Enum.Font.GothamBold
	b.LayoutOrder = layoutOrder
	b.Active = true
	b.Selectable = true
	b.ZIndex = 202
	b.Parent = Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = b

	ApplyNeonGlow(b)

	return b
end

local RecordButton = CreateButton("RECORD", 1)
local StopButton = CreateButton("STOP", 2)

local PlayRow = Instance.new("Frame")
PlayRow.Size = UDim2.new(1, -8, 0, 26)
PlayRow.BackgroundTransparency = 1
PlayRow.LayoutOrder = 3
PlayRow.ZIndex = 201
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
PlayButton.TextSize = 9
PlayButton.Active = true
PlayButton.Selectable = true
PlayButton.ZIndex = 202
PlayButton.Parent = PlayRow
ApplyNeonGlow(PlayButton)

local PauseButton = Instance.new("TextButton")
PauseButton.Size = UDim2.new(0.48, 0, 1, 0)
PauseButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
PauseButton.Text = "PAUSE"
PauseButton.TextColor3 = Color3.fromRGB(255, 200, 0)
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 9
PauseButton.Active = true
PauseButton.Selectable = true
PauseButton.ZIndex = 202
PauseButton.Parent = PlayRow
ApplyNeonGlow(PauseButton)

local SeekRow = Instance.new("Frame")
SeekRow.Size = UDim2.new(1, -8, 0, 26)
SeekRow.BackgroundTransparency = 1
SeekRow.LayoutOrder = 4
SeekRow.ZIndex = 201
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
SeekBackButton.TextSize = 9
SeekBackButton.Active = true
SeekBackButton.Selectable = true
SeekBackButton.ZIndex = 202
SeekBackButton.Parent = SeekRow
ApplyNeonGlow(SeekBackButton)

local SeekForwardButton = Instance.new("TextButton")
SeekForwardButton.Size = UDim2.new(0.48, 0, 1, 0)
SeekForwardButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
SeekForwardButton.Text = "SEEK FORWARD"
SeekForwardButton.TextColor3 = Color3.fromRGB(0, 240, 255)
SeekForwardButton.Font = Enum.Font.GothamBold
SeekForwardButton.TextSize = 9
SeekForwardButton.Active = true
SeekForwardButton.Selectable = true
SeekForwardButton.ZIndex = 202
SeekForwardButton.Parent = SeekRow
ApplyNeonGlow(SeekForwardButton)

local TrimButton = CreateButton("TRIM TIMELINE", 5)

local StorageRow = Instance.new("Frame")
StorageRow.Size = UDim2.new(1, -8, 0, 26)
StorageRow.BackgroundTransparency = 1
StorageRow.LayoutOrder = 6
StorageRow.ZIndex = 201
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
SaveButton.TextSize = 9
SaveButton.Active = true
SaveButton.Selectable = true
SaveButton.ZIndex = 202
SaveButton.Parent = StorageRow
ApplyNeonGlow(SaveButton)

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(0.48, 0, 1, 0)
LoadButton.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
LoadButton.Text = "LOAD DATA"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 9
LoadButton.Active = true
LoadButton.Selectable = true
LoadButton.ZIndex = 202
LoadButton.Parent = StorageRow
ApplyNeonGlow(LoadButton)

BindTouchClick(OpenMenu, function()
	Main.Visible = not Main.Visible
end)

BindTouchClick(CloseButton, function()
	Main.Visible = false
end)

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
	if not RootPart or not Humanoid or not Character or not RootPart:IsDescendantOf(workspace) then
		return
	end

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

	FrameLabel.Text = string.format(
		"FRAMES: %d | DURATION: %.1fs",
		#RecordData,
		frame.Time
	)
end

local function StartRecord()
	StopPlayback()
	StopRecord()

	table.clear(RecordData)

	CutIndex = 1

	if not RootPart or not Humanoid then
		return
	end

	Recording = true
	RecordStart = os.clock()
	RecordTimer = 0

	CaptureFrame()

	ActiveConnections["Record"] = RunService.Heartbeat:Connect(function(dt)
		if not Recording then
			return
		end

		RecordTimer += dt

		while RecordTimer >= RECORD_INTERVAL do
			RecordTimer -= RECORD_INTERVAL
			CaptureFrame()

			if not Recording then
				break
			end
		end
	end)
end

BindTouchClick(RecordButton, StartRecord)

BindTouchClick(StopButton, function()
	StopRecord()
	StopPlayback()

	StatusLabel.Text = "STATUS: IDLE"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
end)

local function GetAnimationMap(animDataList)
	local map = {}

	for _, info in ipairs(animDataList or {}) do
		if info.AnimationId and info.AnimationId ~= "" then
			map[info.AnimationId] = info
		end
	end

	return map
end

local function SynchronizeGhostAnimations(ghostAnimator, animDataList, nextAnimDataList, alpha)
	if not ghostAnimator then
		return
	end

	local currentMap = GetAnimationMap(animDataList)
	local nextMap = GetAnimationMap(nextAnimDataList)
	local activeIds = {}

	for animId, info in pairs(currentMap) do
		activeIds[animId] = true

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
					track.Looped = true
					track:Play(0, info.Weight or 1, info.Speed or 1)
				end)
			end
		end

		if track then
			pcall(function()
				if not track.IsPlaying then
					track:Play(0, info.Weight or 1, info.Speed or 1)
				end

				local nextInfo = nextMap[animId] or info

				local t1 = tonumber(info.TimePosition) or 0
				local t2 = tonumber(nextInfo.TimePosition) or t1
				local interpolatedTime = t1 + (t2 - t1) * alpha

				local speed1 = tonumber(info.Speed) or 1
				local speed2 = tonumber(nextInfo.Speed) or speed1
				local interpolatedSpeed = speed1 + (speed2 - speed1) * alpha

				local weight1 = tonumber(info.Weight) or 1
				local weight2 = tonumber(nextInfo.Weight) or weight1
				local interpolatedWeight = weight1 + (weight2 - weight1) * alpha

				track:AdjustSpeed(interpolatedSpeed)
				track:AdjustWeight(interpolatedWeight, 0.05)

				if math.abs(track.TimePosition - interpolatedTime) > 0.03 then
					track.TimePosition = interpolatedTime
				end
			end)
		end
	end

	for animId, track in pairs(ActiveGhostTracks) do
		if not activeIds[animId] then
			pcall(function()
				track:Stop(0.08)
				track:Destroy()
			end)

			ActiveGhostTracks[animId] = nil
		end
	end
end

local function FindPlaybackFrames(targetTime)
	local count = #RecordData

	if count < 2 then
		return 1, 1, 0
	end

	if targetTime <= RecordData[1].Time then
		return 1, 2, 0
	end

	if targetTime >= RecordData[count].Time then
		return count - 1, count, 1
	end

	local low = 1
	local high = count

	while low <= high do
		local mid = math.floor((low + high) / 2)

		if RecordData[mid].Time <= targetTime then
			low = mid + 1
		else
			high = mid - 1
		end
	end

	local i1 = math.clamp(high, 1, count - 1)
	local i2 = i1 + 1

	local t1 = RecordData[i1].Time
	local t2 = RecordData[i2].Time

	local span = t2 - t1
	local alpha = span > 0 and (targetTime - t1) / span or 0

	return i1, i2, math.clamp(alpha, 0, 1)
end

local function StartPlayback()
	if #RecordData < 2 then
		return
	end

	StopRecord()

	if not Playing then
		StopPlayback()

		local ghost = CreateGhostClone()

		if not ghost then
			return
		end

		Playing = true
		Paused = false
		PlaybackElapsed = 0
	else
		Paused = false
	end

	local ghost = GhostCharacter

	if not ghost then
		return
	end

	local ghostRoot = ghost:FindFirstChild("HumanoidRootPart")
	local ghostHumanoid = ghost:FindFirstChildOfClass("Humanoid")
	local ghostAnimator = ghostHumanoid and ghostHumanoid:FindFirstChildOfClass("Animator")

	if not ghostRoot or not ghostAnimator then
		StopPlayback()
		return
	end

	if ghostHumanoid then
		ghostHumanoid.AutoRotate = false
		ghostHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end

	local totalDuration = RecordData[#RecordData].Time - RecordData[1].Time

	if totalDuration <= 0 then
		StopPlayback()
		return
	end

	local playbackStartTime = os.clock() - PlaybackElapsed

	DisconnectConnection("Playback")

	ActiveConnections["Playback"] = RunService.RenderStepped:Connect(function()
		if not Playing or Paused then
			return
		end

		if not GhostCharacter or not GhostCharacter.Parent then
			StopPlayback()
			return
		end

		PlaybackElapsed = os.clock() - playbackStartTime

		if PlaybackElapsed >= totalDuration then
			local finalFrame = RecordData[#RecordData]

			pcall(function()
				ghostRoot.CFrame = finalFrame.CFrame
			end)

			SynchronizeGhostAnimations(
				ghostAnimator,
				finalFrame.Animations,
				finalFrame.Animations,
				0
			)

			StopPlayback()

			StatusLabel.Text = "STATUS: IDLE"
			StatusLabel.TextColor3 = Color3.fromRGB(0, 240, 255)

			FrameLabel.Text = string.format(
				"FRAMES: %d/%d | DURATION: %.1fs",
				#RecordData,
				#RecordData,
				totalDuration
			)

			return
		end

		local targetTime = RecordData[1].Time + PlaybackElapsed

		local i1, i2, alpha = FindPlaybackFrames(targetTime)

		local f1 = RecordData[i1]
		local f2 = RecordData[i2]

		if not f1 or not f2 then
			return
		end

		local targetCFrame = f1.CFrame:Lerp(f2.CFrame, alpha)

		pcall(function()
			ghostRoot.CFrame = targetCFrame
		end)

		SynchronizeGhostAnimations(
			ghostAnimator,
			f1.Animations,
			f2.Animations,
			alpha
		)

		FrameLabel.Text = string.format(
			"FRAME: %d/%d | DURATION: %.1fs",
			i1,
			#RecordData,
			PlaybackElapsed
		)
	end)

	StatusLabel.Text = "STATUS: PLAYING"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
end

BindTouchClick(PlayButton, StartPlayback)

BindTouchClick(PauseButton, function()
	if not Playing then
		return
	end

	if Paused then
		Paused = false

		StatusLabel.Text = "STATUS: PLAYING"
		StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
	else
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

local function UpdatePreviewState()
	CutIndex = math.clamp(
		CutIndex,
		1,
		math.max(1, #RecordData)
	)

	if not RecordData[CutIndex] then
		return
	end

	if not GhostCharacter then
		CreateGhostClone()
	end

	if GhostCharacter then
		local gRoot = GhostCharacter:FindFirstChild("HumanoidRootPart")
		local gHum = GhostCharacter:FindFirstChildOfClass("Humanoid")
		local gAnim = gHum and gHum:FindFirstChildOfClass("Animator")

		if gHum then
			gHum.AutoRotate = false
			gHum:ChangeState(Enum.HumanoidStateType.Physics)
		end

		if gRoot then
			gRoot.CFrame = RecordData[CutIndex].CFrame
		end

		if gAnim then
			SynchronizeGhostAnimations(
				gAnim,
				RecordData[CutIndex].Animations,
				RecordData[CutIndex].Animations,
				0
			)
		end
	end

	FrameLabel.Text = string.format(
		"SEEK: %d/%d | TIME: %.1fs",
		CutIndex,
		#RecordData,
		RecordData[CutIndex].Time
	)
end

BindTouchClick(SeekBackButton, function()
	if #RecordData == 0 then
		return
	end

	StopRecord()
	StopPlayback()

	Playing = false
	Paused = true

	CutIndex = math.max(1, CutIndex - 15)

	UpdatePreviewState()
end)

BindTouchClick(SeekForwardButton, function()
	if #RecordData == 0 then
		return
	end

	StopRecord()
	StopPlayback()

	Playing = false
	Paused = true

	CutIndex = math.min(
		#RecordData,
		CutIndex + 15
	)

	UpdatePreviewState()
end)

BindTouchClick(TrimButton, function()
	if #RecordData == 0 or CutIndex >= #RecordData then
		return
	end

	StopRecord()
	StopPlayback()

	for i = #RecordData, CutIndex + 1, -1 do
		table.remove(RecordData, i)
	end

	CutIndex = math.min(CutIndex, #RecordData)

	StatusLabel.Text = "STATUS: TRIMMED"
	StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

	FrameLabel.Text = string.format(
		"FRAMES: %d",
		#RecordData
	)
end)

BindTouchClick(SaveButton, function()
	if #RecordData == 0 then
		return
	end

	SavedData = {}

	for _, frame in ipairs(RecordData) do
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

BindTouchClick(LoadButton, function()
	if #SavedData == 0 then
		return
	end

	StopRecord()
	StopPlayback()

	RecordData = {}

	for _, frame in ipairs(SavedData) do
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

	FrameLabel.Text = string.format(
		"FRAMES: %d",
		#RecordData
	)
end)

ScreenGui.Destroying:Connect(function()
	StopRecord()
	StopPlayback()
	CleanupTweens()
end)
