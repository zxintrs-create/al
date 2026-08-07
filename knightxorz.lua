--============================================================
-- ALDO KNIGHTXORZ V4.30
-- STUDIO / STUDIO LITE
-- PREMIUM ARC-LENGTH RECORD PLAYBACK
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- CLEAN OLD VERSION
--============================================================

pcall(function()
	RunService:UnbindFromRenderStep("AldoKnightXorzV430_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV430_Playback")
end)

pcall(function()
	local old = PlayerGui:FindFirstChild("AldoKnightXorzV430Gui")
	if old then
		old:Destroy()
	end
end)

pcall(function()
	local old = PlayerGui:FindFirstChild("AldoKnightXorzV429Gui")
	if old then
		old:Destroy()
	end
end)

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local RootPart

local function SetupCharacter(char)

	Character = char

	Humanoid = char:WaitForChild("Humanoid", 10)
	RootPart = char:WaitForChild("HumanoidRootPart", 10)

	if Humanoid then
		Humanoid.AutoRotate = true
	end
end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)

	SetupCharacter(char)

	task.wait(0.2)

	if Humanoid then
		Humanoid.AutoRotate = true
	end
end)

local function CharacterAlive()

	return Character
		and Character.Parent
		and Humanoid
		and Humanoid.Parent
		and Humanoid.Health > 0
		and RootPart
		and RootPart.Parent
end

--============================================================
-- CONFIG
--============================================================

local CFG = {

	NodeInterval = 0.12,
	MinDistance = 0.45,

	CurveSamples = 24,

	ArcLookupSamples = 8,

	RotationSmoothSpeed = 9,

	LookAheadDistance = 1.5,

	StartTimeout = 25,

	LineThickness = 0.12,

	LineColor = Color3.fromRGB(0,255,255),

	AccentA = Color3.fromRGB(0,255,255),

	AccentB = Color3.fromRGB(170,0,255),

	PanelColor = Color3.fromRGB(12,12,20),

	ButtonColor = Color3.fromRGB(25,25,38)
}

--============================================================
-- STATE
--============================================================

local State = {

	Recording = false,

	Playing = false,

	Paused = false,

	AutoWalk = false,

	LineVisible = true,

	SelectedFile = 1,

	Timeline = {},

	SavedFiles = {},

	VisualNodes = {},

	RecordStart = 0,

	LastJump = false,

	PlaybackToken = 0,

	MovementSpeed = 16,

	PauseTime = 0,

	PauseStarted = nil
}

--============================================================
-- UTILITY
--============================================================

local function CopyCFrame(cf)

	if not cf then
		return nil
	end

	return CFrame.new(cf:GetComponents())
end

local function CloneTimeline(source)

	local result = {}

	for _, node in ipairs(source) do

		table.insert(result, {

			CFrame = CopyCFrame(node.CFrame),

			Position = node.Position,

			Timestamp = node.Timestamp,

			RelativeTimestamp = node.RelativeTimestamp,

			Jump = node.Jump
		})
	end

	return result
end

local function NormalizeTimeline(timeline)

	if #timeline == 0 then
		return timeline
	end

	local firstTime = timeline[1].Timestamp or 0

	for _, node in ipairs(timeline) do

		node.RelativeTimestamp =
			(node.Timestamp or 0) - firstTime
	end

	return timeline
end

--============================================================
-- ROUTE FOLDER
--============================================================

local RouteFolder =
	workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

if not RouteFolder then

	RouteFolder = Instance.new("Folder")
	RouteFolder.Name = "KNIGHTXORZ_ROUTE"
	RouteFolder.Parent = workspace
end

--============================================================
-- VISUAL ROUTE
--============================================================

local function ClearVisuals()

	for _, part in ipairs(State.VisualNodes) do

		if part and part.Parent then
			part:Destroy()
		end
	end

	State.VisualNodes = {}

	for _, child in ipairs(RouteFolder:GetChildren()) do
		child:Destroy()
	end
end

local function DrawLine(a,b)

	local distance = (b-a).Magnitude

	if distance < 0.05 then
		return
	end

	local part = Instance.new("Part")

	part.Name = "KnightXorzRouteLine"

	part.Anchored = true

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	part.CastShadow = false

	part.Material = Enum.Material.Neon

	part.Color = CFG.LineColor

	part.Size =
		Vector3.new(
			CFG.LineThickness,
			CFG.LineThickness,
			distance
		)

	part.CFrame =
		CFrame.lookAt(
			(a+b)/2,
			b
		)

	part.Transparency =
		State.LineVisible and 0 or 1

	part.Parent = RouteFolder

	table.insert(
		State.VisualNodes,
		part
	)
end

local function RedrawRoute()

	ClearVisuals()

	for i = 2,#State.Timeline do

		DrawLine(
			State.Timeline[i-1].Position,
			State.Timeline[i].Position
		)
	end
end

--============================================================
-- RECORD
--============================================================

RunService:BindToRenderStep(
	"AldoKnightXorzV430_Record",
	Enum.RenderPriority.Character.Value,
	function()

		if not State.Recording then
			return
		end

		if not CharacterAlive() then
			return
		end

		local cf = RootPart.CFrame
		local pos = cf.Position

		local timestamp =
			os.clock() - State.RecordStart

		local velocity =
			RootPart.AssemblyLinearVelocity

		local humanoidState =
			Humanoid:GetState()

		local airborne =
			Humanoid.FloorMaterial ==
			Enum.Material.Air

		local jumping =
			(
				airborne
				and velocity.Y > 1
			)
			or humanoidState ==
				Enum.HumanoidStateType.Jumping

		local jumpTrigger =
			jumping
			and not State.LastJump

		State.LastJump = jumping

		if #State.Timeline == 0 then

			table.insert(
				State.Timeline,
				{
					CFrame = CopyCFrame(cf),
					Position = pos,
					Timestamp = timestamp,
					RelativeTimestamp = 0,
					Jump = jumpTrigger
				}
			)

			return
		end

		local last =
			State.Timeline[#State.Timeline]

		local distance =
			(pos-last.Position).Magnitude

		local timeDelta =
			timestamp-last.Timestamp

		if
			(
				timeDelta >= CFG.NodeInterval
				and distance >= CFG.MinDistance
			)
			or jumpTrigger
		then

			table.insert(
				State.Timeline,
				{
					CFrame = CopyCFrame(cf),
					Position = pos,
					Timestamp = timestamp,
					RelativeTimestamp = 0,
					Jump = jumpTrigger
				}
			)

			DrawLine(
				last.Position,
				pos
			)
		end
	end
)

--============================================================
-- CATMULL-ROM
--============================================================

local function GetPoint(index)

	local count = #State.Timeline

	if count == 0 then
		return Vector3.zero
	end

	index =
		math.clamp(
			index,
			1,
			count
		)

	return State.Timeline[index].Position
end

local function GetSafePoint(index)

	local count = #State.Timeline

	if count <= 1 then
		return GetPoint(1)
	end

	if index < 1 then

		local p1 = GetPoint(1)
		local p2 = GetPoint(2)

		return p1-(p2-p1)
	end

	if index > count then

		local p1 = GetPoint(count)
		local p0 = GetPoint(count-1)

		return p1+(p1-p0)
	end

	return GetPoint(index)
end

local function Centripetal(
	p0,
	p1,
	p2,
	p3,
	t
)

	local alpha = 0.5

	local function Param(a,b)

		return math.max(
			(b-a).Magnitude ^ alpha,
			0.00001
		)
	end

	local t0 = 0

	local t1 =
		t0+Param(p0,p1)

	local t2 =
		t1+Param(p1,p2)

	local t3 =
		t2+Param(p2,p3)

	local localT =
		t1+(t2-t1)*math.clamp(t,0,1)

	local function LerpParam(
		a,
		b,
		ta,
		tb
	)

		if math.abs(tb-ta)<0.00001 then
			return a
		end

		local u =
			(localT-ta)/(tb-ta)

		return a+(b-a)*u
	end

	local A1 =
		LerpParam(
			p0,
			p1,
			t0,
			t1
		)

	local A2 =
		LerpParam(
			p1,
			p2,
			t1,
			t2
		)

	local A3 =
		LerpParam(
			p2,
			p3,
			t2,
			t3
		)

	local B1 =
		LerpParam(
			A1,
			A2,
			t0,
			t2
		)

	local B2 =
		LerpParam(
			A2,
			A3,
			t1,
			t3
		)

	return LerpParam(
		B1,
		B2,
		t1,
		t2
	)
end

local function CurvePosition(
	segment,
	alpha
)

	return Centripetal(
		GetSafePoint(segment-1),
		GetSafePoint(segment),
		GetSafePoint(segment+1),
		GetSafePoint(segment+2),
		alpha
	)
end

--============================================================
-- ARC LENGTH CACHE
--============================================================

local function BuildArcCache()

	local cache = {}

	local count = #State.Timeline

	if count < 2 then
		return cache,0
	end

	local total = 0

	table.insert(
		cache,
		{
			Length = 0,
			Segment = 1,
			Alpha = 0
		}
	)

	for segment = 1,count-1 do

		local previous =
			CurvePosition(
				segment,
				0
			)

		for sample = 1,CFG.CurveSamples do

			local alpha =
				sample/CFG.CurveSamples

			local current =
				CurvePosition(
					segment,
					alpha
				)

			total +=
				(current-previous).Magnitude

			table.insert(
				cache,
				{
					Length = total,
					Segment = segment,
					Alpha = alpha
				}
			)

			previous = current
		end
	end

	return cache,total
end

--============================================================
-- ARC LOOKUP
--============================================================

local function ArcPosition(
	cache,
	totalLength,
	distance
)

	if #cache == 0 then
		return State.Timeline[1].Position
	end

	distance =
		math.clamp(
			distance,
			0,
			totalLength
		)

	local low = 1
	local high = #cache

	while low < high do

		local middle =
			math.floor(
				(low+high)/2
			)

		if cache[middle].Length <
			distance
		then

			low = middle+1

		else

			high = middle
		end
	end

	local current = cache[low]
	local previous = cache[math.max(low-1,1)]

	local range =
		current.Length-
		previous.Length

	local factor = 0

	if range > 0 then

		factor =
			(distance-previous.Length)
			/range
	end

	local alpha =
		previous.Alpha+
		(current.Alpha-previous.Alpha)
		*factor

	return CurvePosition(
		current.Segment,
		alpha
	)
end

--============================================================
-- TIMESTAMP → ARC LENGTH TABLE
--============================================================

local function BuildTimeArcTable(
	cache,
	totalLength
)

	local tableResult = {}

	local totalTime =
		State.Timeline[#State.Timeline]
		.RelativeTimestamp

	if totalTime <= 0 then
		totalTime = 0.01
	end

	for i = 0,CFG.ArcLookupSamples do

		local time =
			totalTime*
			(i/CFG.ArcLookupSamples)

		local low = 1
		local high = #State.Timeline

		while low < high do

			local mid =
				math.floor(
					(low+high)/2
				)

			if
				(State.Timeline[mid]
				.RelativeTimestamp or 0)
				< time
			then
				low = mid+1
			else
				high = mid
			end
		end

		local current =
			State.Timeline[low]

		local previous =
			State.Timeline[
				math.max(low-1,1)
			]

		local t0 =
			previous.RelativeTimestamp or 0

		local t1 =
			current.RelativeTimestamp or 0

		local f = 0

		if t1 > t0 then

			f =
				(time-t0)
				/(t1-t0)
		end

		local p0 =
			previous.Position

		local p1 =
			current.Position

		local rawDistance =
			(p0:Lerp(p1,f)-
			State.Timeline[1].Position).Magnitude

		table.insert(
			tableResult,
			{
				Time = time,
				ApproxDistance = rawDistance
			}
		)
	end

	return tableResult,totalTime
end

--============================================================
-- BETTER TIME → ARC SOLVER
--============================================================

local function GetDistanceForTime(
	time,
	totalLength,
	totalTime
)

	if totalTime <= 0 then
		return 0
	end

	local count = #State.Timeline

	if count < 2 then
		return 0
	end

	time =
		math.clamp(
			time,
			0,
			totalTime
		)

	local low = 1
	local high = count

	while low < high do

		local mid =
			math.floor(
				(low+high)/2
			)

		if
			(State.Timeline[mid]
			.RelativeTimestamp or 0)
			< time
		then

			low = mid+1

		else

			high = mid
		end
	end

	local i2 = low
	local i1 = math.max(i2-1,1)

	local n1 = State.Timeline[i1]
	local n2 = State.Timeline[i2]

	local t1 =
		n1.RelativeTimestamp or 0

	local t2 =
		n2.RelativeTimestamp or 0

	local f = 0

	if t2 > t1 then

		f =
			(time-t1)
			/(t2-t1)
	end

	-- The original recording segment defines
	-- how much time is spent between nodes.

	-- Find arc-length boundaries of this segment
	-- through a local numerical approximation.

	local p1 = n1.Position
	local p2 = n2.Position

	local directDistance =
		(p2-p1).Magnitude

	if directDistance <= 0.001 then

		return 0
	end

	-- Approximate route distance using
	-- cumulative curve distance.

	local targetFraction = f

	-- Blend by original segment timing.
	-- This preserves recorded timing while
	-- the curve supplies the smooth path.

	local cumulative = 0
	local segmentIndex = 1

	for s = 1,count-1 do

		local a =
			State.Timeline[s].Position

		local b =
			State.Timeline[s+1].Position

		local d =
			(b-a).Magnitude

		if s < i1 then
			cumulative += d
		elseif s == i1 then
			cumulative += d*f
			break
		end
	end

	local ratio =
		cumulative /
		math.max(
			(State.Timeline[count].Position-
			State.Timeline[1].Position).Magnitude,
			0.001
		)

	-- Scale against actual curve length.
	-- This avoids using linear progress over
	-- total route duration.

	return math.clamp(
		ratio*totalLength,
		0,
		totalLength
	)
end

--============================================================
-- DIRECTION
--============================================================

local function GetDirection(
	cache,
	totalLength,
	distance
)

	local sample =
		math.max(
			CFG.LookAheadDistance,
			totalLength*0.004
		)

	local current =
		ArcPosition(
			cache,
			totalLength,
			distance
		)

	local ahead =
		ArcPosition(
			cache,
			totalLength,
			math.min(
				distance+sample,
				totalLength
			)
		)

	local direction =
		ahead-current

	if direction.Magnitude < 0.01 then

		local behind =
			ArcPosition(
				cache,
				totalLength,
				math.max(
					distance-sample,
					0
				)
			)

		direction =
			current-behind
	end

	if direction.Magnitude < 0.01 then
		return Vector3.zero
	end

	return direction.Unit
end

--============================================================
-- ROTATION
--============================================================

local function SmoothRotation(
	current,
	target,
	dt
)

	local alpha =
		1-math.exp(
			-CFG.RotationSmoothSpeed*dt
		)

	return current:Lerp(
		target,
		math.clamp(alpha,0,1)
	)
end

--============================================================
-- STATUS GUI PLACEHOLDER
--============================================================

local StatusLabel

local function SetStatus(text)

	if StatusLabel then

		StatusLabel.Text =
			"STATUS  •  "
			..text
			.."  •  FILE "
			..State.SelectedFile
	end
end

--============================================================
-- STOP
--============================================================

local function StopPlayback(

	manual
)

	State.Playing = false
	State.Paused = false
	State.PlaybackToken += 1

	if manual then
		State.AutoWalk = false
	end

	pcall(function()

		RunService:UnbindFromRenderStep(
			"AldoKnightXorzV430_Playback"
		)
	end)

	if CharacterAlive() then

		Humanoid.AutoRotate = true

		Humanoid:Move(
			Vector3.zero,
			true
		)

		RootPart.AssemblyLinearVelocity =
			Vector3.zero

		RootPart.AssemblyAngularVelocity =
			Vector3.zero
	end

	SetStatus("IDLE")
end

--============================================================
-- WALK TO START
--============================================================

local function WalkToStart(
	position,
	token
)

	if not CharacterAlive() then
		return false
	end

	Humanoid.AutoRotate = true

	Humanoid.WalkSpeed =
		State.MovementSpeed

	Humanoid:MoveTo(position)

	local start =
		os.clock()

	while
		State.Playing
		and State.PlaybackToken == token
		and CharacterAlive()
	do

		if State.Paused then
			RunService.Heartbeat:Wait()
			continue
		end

		local distance =
			(RootPart.Position-position)
			.Magnitude

		if distance <= 1.5 then
			return true
		end

		if os.clock()-start >
			CFG.StartTimeout
		then

			return distance <= 5
		end

		RunService.Heartbeat:Wait()
	end

	return false
end

--============================================================
-- PLAYBACK
--============================================================

local function ExecutePlayback()

	if #State.Timeline < 2 then

		SetStatus("NO ROUTE")
		return
	end

	if State.Playing then
		return
	end

	if not CharacterAlive() then
		return
	end

	NormalizeTimeline(State.Timeline)

	State.Playing = true
	State.Paused = false
	State.PlaybackToken += 1

	local token =
		State.PlaybackToken

	local timeline =
		State.Timeline

	local cache,totalLength =
		BuildArcCache()

	if totalLength <= 0 then

		StopPlayback(false)
		return
	end

	local startPosition =
		timeline[1].Position

	SetStatus("WALKING TO START")

	local reached =
		WalkToStart(
			startPosition,
			token
		)

	if not reached
		or not State.Playing
		or State.PlaybackToken ~= token
	then

		StopPlayback(false)
		return
	end

	--========================================================
	-- PLAYBACK CONTROL
	--========================================================

	Humanoid.AutoRotate = false

	Humanoid.WalkSpeed =
		State.MovementSpeed

	local startTime =
		os.clock()

	local pausedDuration = 0
	local pauseStarted = nil

	local totalTime =
		timeline[#timeline]
		.RelativeTimestamp

	if totalTime <= 0 then
		totalTime = 0.01
	end

	local currentRotation =
		RootPart.CFrame -
		RootPart.CFrame.Position

	local lastPosition =
		RootPart.Position

	local lastJumpIndex = 0

	SetStatus(
		State.AutoWalk
		and "AUTO WALK"
		or "PLAYING"
	)

	RunService:BindToRenderStep(

		"AldoKnightXorzV430_Playback",

		Enum.RenderPriority.Character.Value+2,

		function(dt)

			if
				not State.Playing
				or State.PlaybackToken ~= token
				or not CharacterAlive()
			then

				StopPlayback(false)
				return
			end

			--================================================
			-- PAUSE
			--================================================

			if State.Paused then

				if not pauseStarted then
					pauseStarted = os.clock()
				end

				RootPart.AssemblyLinearVelocity =
					Vector3.zero

				RootPart.AssemblyAngularVelocity =
					Vector3.zero

				RootPart.CFrame =
					CFrame.new(lastPosition)
					*currentRotation

				Humanoid:Move(
					Vector3.zero,
					true
				)

				return
			end

			if pauseStarted then

				pausedDuration +=
					os.clock()-pauseStarted

				pauseStarted = nil
			end

			--================================================
			-- ORIGINAL RECORDING TIME
			--================================================

			local elapsed =
				os.clock()
				-startTime
				-pausedDuration

			local progress =
				math.clamp(
					elapsed/totalTime,
					0,
					1
				)

			--================================================
			-- IMPORTANT:
			-- TIME IS FROM RECORDING.
			-- CURVE ONLY DETERMINES PATH.
			--================================================

			local targetDistance =
				GetDistanceForTime(
					elapsed,
					totalLength,
					totalTime
				)

			local targetPosition =
				ArcPosition(
					cache,
					totalLength,
					targetDistance
				)

			--================================================
			-- ROTATION
			--================================================

			local direction =
				GetDirection(
					cache,
					totalLength,
					targetDistance
				)

			if direction.Magnitude > 0.001 then

				local targetRotation =
					CFrame.lookAt(
						Vector3.zero,
						direction,
						Vector3.yAxis
					)

				currentRotation =
					SmoothRotation(
						currentRotation,
						targetRotation,
						dt
					)
			end

			--================================================
			-- JUMP EVENT
			--================================================

			local currentIndex = 1

			for i = 2,#timeline do

				if
					(timeline[i].RelativeTimestamp or 0)
					<= elapsed
				then

					currentIndex = i

				else
					break
				end
			end

			if
				currentIndex > lastJumpIndex
				and timeline[currentIndex].Jump
			then

				Humanoid.Jump = true

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

				lastJumpIndex =
					currentIndex
			end

			--================================================
			-- APPLY POSITION
			--================================================

			local finalPosition =
				targetPosition

			if progress >= 0.999 then

				finalPosition =
					timeline[#timeline].Position

				currentRotation =
					timeline[#timeline].CFrame
					-
					timeline[#timeline].CFrame.Position
			end

			local finalCFrame =
				CFrame.new(finalPosition)
				*currentRotation

			-- Stop Humanoid from competing
			-- with recorded position.

			Humanoid:Move(
				Vector3.zero,
				true
			)

			RootPart.CFrame =
				finalCFrame

			RootPart.AssemblyLinearVelocity =
				Vector3.zero

			RootPart.AssemblyAngularVelocity =
				Vector3.zero

			lastPosition =
				finalPosition

			--================================================
			-- FINISH
			--================================================

			if progress >= 1 then

				RootPart.CFrame =
					timeline[#timeline].CFrame

				RootPart.AssemblyLinearVelocity =
					Vector3.zero

				RootPart.AssemblyAngularVelocity =
					Vector3.zero

				if State.AutoWalk then

					Humanoid.AutoRotate = true

					SetStatus(
						"WALKING TO START"
					)

					local returnStart =
						os.clock()

					Humanoid:MoveTo(
						startPosition
					)

					task.spawn(function()

						while
							State.Playing
							and State.PlaybackToken == token
						do

							if State.Paused then

								task.wait()
								continue
							end

							if not CharacterAlive() then
								break
							end

							local distance =
								(
									RootPart.Position
									-startPosition
								).Magnitude

							if distance <= 1.5 then

								Humanoid.AutoRotate =
									false

								startTime =
									os.clock()

								pausedDuration = 0

								lastJumpIndex = 0

								lastPosition =
									RootPart.Position

								currentRotation =
									RootPart.CFrame
									-RootPart.CFrame.Position

								SetStatus(
									"AUTO WALK"
								)

								break
							end

							if
								os.clock()-returnStart
								> CFG.StartTimeout
							then

								StopPlayback(false)
								break
							end

							RunService.Heartbeat:Wait()
						end
					end)

				else

					StopPlayback(false)
				end
			end
		end
	)
end

--============================================================
-- GUI
--============================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"AldoKnightXorzV430Gui"

ScreenGui.ResetOnSpawn = false

ScreenGui.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
	PlayerGui

--============================================================
-- OPEN BUTTON
--============================================================

local OpenButton =
	Instance.new("TextButton")

OpenButton.Name = "OpenMenu"

OpenButton.Size =
	UDim2.fromOffset(58,58)

OpenButton.Position =
	UDim2.new(
		0.035,
		0,
		0.5,
		-29
	)

OpenButton.Text = "AK"

OpenButton.Font =
	Enum.Font.GothamBlack

OpenButton.TextSize = 15

OpenButton.TextColor3 =
	Color3.new(1,1,1)

OpenButton.BackgroundColor3 =
	CFG.PanelColor

OpenButton.AutoButtonColor = false

OpenButton.Parent =
	ScreenGui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(0,14)

OpenCorner.Parent =
	OpenButton

local OpenStroke =
	Instance.new("UIStroke")

OpenStroke.Thickness = 2

OpenStroke.Color =
	CFG.AccentA

OpenStroke.Parent =
	OpenButton

local OpenGradient =
	Instance.new("UIGradient")

OpenGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			CFG.AccentA
		),

		ColorSequenceKeypoint.new(
			0.5,
			CFG.AccentB
		),

		ColorSequenceKeypoint.new(
			1,
			CFG.AccentA
		)
	})

OpenGradient.Parent =
	OpenButton

--============================================================
-- MAIN FRAME
--============================================================

local MainFrame =
	Instance.new("Frame")

MainFrame.Name =
	"MainFrame"

MainFrame.Size =
	UDim2.fromOffset(550,325)

MainFrame.Position =
	UDim2.new(
		0.5,
		-275,
		0.5,
		-162
	)

MainFrame.BackgroundColor3 =
	CFG.PanelColor

MainFrame.BorderSizePixel = 0

MainFrame.Active = true

MainFrame.Parent =
	ScreenGui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0,18)

MainCorner.Parent =
	MainFrame

local MainStroke =
	Instance.new("UIStroke")

MainStroke.Thickness = 2

MainStroke.Color =
	CFG.AccentB

MainStroke.Parent =
	MainFrame

local MainGradient =
	Instance.new("UIGradient")

MainGradient.Rotation = 35

MainGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(10,20,35)
		),

		ColorSequenceKeypoint.new(
			0.45,
			Color3.fromRGB(24,10,40)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(8,25,32)
		)
	})

MainGradient.Parent =
	MainFrame

--============================================================
-- GRADIENT ANIMATION
--============================================================

task.spawn(function()

	while ScreenGui.Parent do

		local tween =
			TweenService:Create(
				MainGradient,
				TweenInfo.new(
					5,
					Enum.EasingStyle.Linear
				),
				{
					Rotation =
						MainGradient.Rotation+360
				}
			)

		tween:Play()
		tween.Completed:Wait()

		MainGradient.Rotation =
			MainGradient.Rotation%360
	end
end)

--============================================================
-- TITLE
--============================================================

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.new(1,-30,0,38)

Title.Position =
	UDim2.fromOffset(15,8)

Title.BackgroundTransparency = 1

Title.Text =
	"ALDO KNIGHTXORZ"

Title.Font =
	Enum.Font.GothamBlack

Title.TextSize = 17

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.TextColor3 =
	Color3.new(1,1,1)

Title.Parent =
	MainFrame

local TitleGradient =
	Instance.new("UIGradient")

TitleGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			CFG.AccentA
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.new(1,1,1)
		),

		ColorSequenceKeypoint.new(
			1,
			CFG.AccentB
		)
	})

TitleGradient.Parent =
	Title

--============================================================
-- STATUS
--============================================================

StatusLabel =
	Instance.new("TextLabel")

StatusLabel.Size =
	UDim2.new(1,-30,0,25)

StatusLabel.Position =
	UDim2.fromOffset(15,43)

StatusLabel.BackgroundTransparency = 1

StatusLabel.Text =
	"STATUS  •  IDLE  •  FILE 1"

StatusLabel.Font =
	Enum.Font.GothamBold

StatusLabel.TextSize = 11

StatusLabel.TextXAlignment =
	Enum.TextXAlignment.Left

StatusLabel.TextColor3 =
	CFG.LineColor

StatusLabel.Parent =
	MainFrame

--============================================================
-- BUTTON CONTAINER
--============================================================

local Container =
	Instance.new("ScrollingFrame")

Container.Size =
	UDim2.new(1,-30,1,-82)

Container.Position =
	UDim2.fromOffset(15,73)

Container.BackgroundTransparency = 1

Container.BorderSizePixel = 0

Container.ScrollBarThickness = 3

Container.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

Container.CanvasSize =
	UDim2.new()

Container.Parent =
	MainFrame

local Grid =
	Instance.new("UIGridLayout")

Grid.CellSize =
	UDim2.fromOffset(120,39)

Grid.CellPadding =
	UDim2.fromOffset(8,8)

Grid.SortOrder =
	Enum.SortOrder.LayoutOrder

Grid.Parent =
	Container

--============================================================
-- BUTTON
--============================================================

local function CreateButton(
	text,
	order,
	callback
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.fromOffset(120,39)

	button.LayoutOrder =
		order

	button.BackgroundColor3 =
		CFG.ButtonColor

	button.Text =
		text

	button.TextColor3 =
		Color3.fromRGB(
			235,
			235,
			245
		)

	button.Font =
		Enum.Font.GothamBold

	button.TextSize = 10

	button.AutoButtonColor = false

	button.Parent =
		Container

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0,9)

	corner.Parent =
		button

	local stroke =
		Instance.new("UIStroke")

	stroke.Thickness = 1

	stroke.Color =
		Color3.fromRGB(
			70,
			70,
			95
		)

	stroke.Parent =
		button

	button.MouseEnter:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.12),
			{
				BackgroundColor3 =
					Color3.fromRGB(
						45,
						30,
						65
					)
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.12),
			{
				BackgroundColor3 =
					CFG.ButtonColor
			}
		):Play()
	end)

	button.Activated:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.08),
			{
				BackgroundColor3 =
					CFG.AccentB
			}
		):Play()

		task.delay(
			0.1,
			function()

				if button.Parent then

					TweenService:Create(
						button,
						TweenInfo.new(0.12),
						{
							BackgroundColor3 =
								CFG.ButtonColor
						}
					):Play()
				end
			end
		)

		callback()
	end)

	return button
end

--============================================================
-- RECORD
--============================================================

CreateButton(
	"● RECORD",
	1,
	function()

		if State.Recording then

			State.Recording = false

			NormalizeTimeline(
				State.Timeline
			)

			SetStatus("IDLE")

		else

			StopPlayback(true)

			State.Timeline = {}

			ClearVisuals()

			State.RecordStart =
				os.clock()

			State.LastJump = false

			State.Recording = true

			SetStatus("RECORDING")
		end
	end
)

--============================================================
-- PLAY
--============================================================

CreateButton(
	"▶ PLAY",
	2,
	function()

		if State.Recording then
			return
		end

		State.AutoWalk = false

		ExecutePlayback()
	end
)

--============================================================
-- PAUSE
--============================================================

CreateButton(
	"Ⅱ PAUSE / RESUME",
	3,
	function()

		if not State.Playing then
			return
		end

		State.Paused =
			not State.Paused

		if State.Paused then

			SetStatus("PAUSED")

		else

			SetStatus(
				State.AutoWalk
				and "AUTO WALK"
				or "PLAYING"
			)
		end
	end
)

--============================================================
-- AUTO WALK
--============================================================

CreateButton(
	"↻ AUTO WALK",
	4,
	function()

		if State.Recording then
			return
		end

		State.AutoWalk =
			not State.AutoWalk

		if State.AutoWalk then

			if not State.Playing then
				ExecutePlayback()
			end

		else

			StopPlayback(true)
		end
	end
)

--============================================================
-- STOP
--============================================================

CreateButton(
	"■ STOP",
	5,
	function()

		StopPlayback(true)
	end
)

--============================================================
-- FILE 1-5
--============================================================

for i = 1,5 do

	CreateButton(
		"FILE "..i,
		5+i,
		function()

			State.SelectedFile = i

			SetStatus("IDLE")
		end
	)
end

--============================================================
-- SAVE
--============================================================

CreateButton(
	"↓ SAVE FILE",
	11,
	function()

		if #State.Timeline == 0 then
			return
		end

		NormalizeTimeline(
			State.Timeline
		)

		State.SavedFiles[
			State.SelectedFile
		] = {

			Timeline =
				CloneTimeline(
					State.Timeline
				)
		}

		SetStatus(
			"SAVED FILE "
			..State.SelectedFile
		)
	end
)

--============================================================
-- LOAD
--============================================================

CreateButton(
	"↑ LOAD FILE",
	12,
	function()

		local data =
			State.SavedFiles[
				State.SelectedFile
			]

		if not data then
			SetStatus("FILE EMPTY")
			return
		end

		StopPlayback(true)

		State.Timeline =
			CloneTimeline(
				data.Timeline
			)

		NormalizeTimeline(
			State.Timeline
		)

		RedrawRoute()

		SetStatus(
			"LOADED FILE "
			..State.SelectedFile
		)
	end
)

--============================================================
-- CLEAR
--============================================================

CreateButton(
	"× CLEAR",
	13,
	function()

		StopPlayback(true)

		State.Timeline = {}

		ClearVisuals()

		SetStatus("CLEARED")
	end
)

--============================================================
-- LINE VISIBLE
--============================================================

CreateButton(
	"◈ LINE VISIBLE",
	14,
	function()

		State.LineVisible =
			not State.LineVisible

		for _,part in ipairs(
			State.VisualNodes
		) do

			if part and part.Parent then

				part.Transparency =
					State.LineVisible
					and 0
					or 1
			end
		end

		SetStatus(
			State.LineVisible
			and "LINE ON"
			or "LINE OFF"
		)
	end
)

--============================================================
-- DRAG MAIN FRAME
--============================================================

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)

	if
		input.UserInputType ==
			Enum.UserInputType.MouseButton1
		or input.UserInputType ==
			Enum.UserInputType.Touch
	then

		dragging = true

		dragStart =
			input.Position

		startPosition =
			MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if
		input.UserInputType ==
			Enum.UserInputType.MouseMovement
		or input.UserInputType ==
			Enum.UserInputType.Touch
	then

		local delta =
			input.Position-dragStart

		MainFrame.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset+delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset+delta.Y
			)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if
		input.UserInputType ==
			Enum.UserInputType.MouseButton1
		or input.UserInputType ==
			Enum.UserInputType.Touch
	then

		dragging = false
	end
end)

--============================================================
-- OPEN / CLOSE
--============================================================

OpenButton.Activated:Connect(function()

	MainFrame.Visible =
		not MainFrame.Visible
end)

--============================================================
-- OPEN BUTTON GRADIENT
--============================================================

task.spawn(function()

	while ScreenGui.Parent do

		local tween =
			TweenService:Create(
				OpenGradient,
				TweenInfo.new(
					3,
					Enum.EasingStyle.Linear
				),
				{
					Rotation =
						OpenGradient.Rotation+360
				}
			)

		tween:Play()
		tween.Completed:Wait()

		OpenGradient.Rotation =
			OpenGradient.Rotation%360
	end
end)

--============================================================
-- FINAL
--============================================================

SetStatus("IDLE")
