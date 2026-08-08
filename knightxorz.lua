--============================================================
-- ALDO KNIGHTXORZ V4.53
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("KNIGHTXORZ V4.53")

local RECORD_BIND = "AldoKnightXorz_Record"
local PLAYBACK_BIND = "AldoKnightXorz_Playback"

pcall(function()
	RunService:UnbindFromRenderStep(RECORD_BIND)
	RunService:UnbindFromRenderStep(PLAYBACK_BIND)
end)

for _, name in ipairs({
	"AldoKnightXorzV440Gui",
	"AldoKnightXorzV450Gui",
	"AldoKnightXorzV451Gui",
	"AldoKnightXorzV451FinalGui",
	"AldoKnightXorzV452Gui",
	"AldoKnightXorzV453Gui",
}) do
	local old = PlayerGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local CFG = {

	-- RECORD
	RecordSampleRate = 0.045,
	MinDistance = 0.045,
	DirectionThreshold = 0.10,
	SpeedThreshold = 0.35,

	-- PLAYBACK
	PlaybackSpeedMultiplier = 1,

	-- MOVEMENT
	MovementTolerance = 2.75,
	HardCorrectionDistance = 6,
	CorrectionCooldown = 0.18,

	-- START
	StartDistance = 2.5,
	StartTimeout = 20,

	-- ROUTE
	LineThickness = 0.12,
	LineColor = Color3.fromRGB(0,255,255),

	-- GUI
	MainWidth = 550,
	MainHeight = 325,

	AccentA = Color3.fromRGB(0,255,255),
	AccentB = Color3.fromRGB(170,0,255),

	PanelColor = Color3.fromRGB(12,12,20),
	ButtonColor = Color3.fromRGB(25,25,38)
}

--============================================================
-- STATE
-- PENTING:
-- STATE DIBUAT SEBELUM SetupCharacter()
--============================================================

local State = {

	Recording = false,
	Playing = false,
	Paused = false,
	AutoWalk = false,

	LineVisible = true,

	SelectedFile = 1,

	Timeline = {},
	JumpEvents = {},

	SavedFiles = {},

	VisualNodes = {},

	RecordStart = 0,
	LastRecordTime = 0,
	LastPosition = nil,

	CurrentElapsed = 0,

	PlaybackToken = 0,

	OriginalWalkSpeed = 16,
	PlaybackWalkSpeed = 16,

	LastCorrection = 0,

	CurrentNodeIndex = 1,

	FinishHandled = false,

	LastJumpEventIndex = 1,
	PlaybackJumpIndex = 1,

	PlaybackConnectionActive = false
}

--============================================================
-- CHARACTER
--============================================================

local Character
local Humanoid
local RootPart

local CharacterConnections = {}

local function DisconnectCharacterConnections()

	for _, connection in ipairs(CharacterConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(CharacterConnections)
end

local function CharacterAlive()

	return
		Character
		and Character.Parent
		and Humanoid
		and Humanoid.Parent
		and Humanoid.Health > 0
		and RootPart
		and RootPart.Parent
end

--============================================================
-- STATUS
--============================================================

local StatusLabel

local function SetStatus(text)

	if StatusLabel and StatusLabel.Parent then

		StatusLabel.Text =
			"STATUS  •  "
			.. tostring(text)
			.. "  •  FILE "
			.. tostring(State.SelectedFile)

	end
end

--============================================================
-- CHARACTER SETUP
--============================================================

local function SetupCharacter(char)

	DisconnectCharacterConnections()

	Character = char

	Humanoid = char:WaitForChild(
		"Humanoid",
		10
	)

	RootPart = char:WaitForChild(
		"HumanoidRootPart",
		10
	)

	if not Humanoid or not RootPart then
		return
	end

	Humanoid.AutoRotate = true

	State.OriginalWalkSpeed =
		Humanoid.WalkSpeed

	--========================================================
	-- REAL JUMP EVENT
	--========================================================

	table.insert(
		CharacterConnections,

		Humanoid.StateChanged:Connect(
			function(oldState,newState)

				if not State then
					return
				end

				if not State.Recording then
					return
				end

				if newState ==
					Enum.HumanoidStateType.Jumping
				then

					local now =
						os.clock()

					table.insert(
						State.JumpEvents,
						{
							Timestamp =
								math.max(
									0,
									now
									-
									State.RecordStart
								),

							Type = "Jump"
						}
					)

				end
			end
		)
	)
end

--============================================================
-- INITIAL CHARACTER
--============================================================

if Player.Character then
	SetupCharacter(Player.Character)
end

--============================================================
-- ROUTE FOLDER
--============================================================

local RouteFolder =
	workspace:FindFirstChild(
		"KNIGHTXORZ_ROUTE"
	)

if not RouteFolder then

	RouteFolder =
		Instance.new("Folder")

	RouteFolder.Name =
		"KNIGHTXORZ_ROUTE"

	RouteFolder.Parent =
		workspace
end

--============================================================
-- UTILITY
--============================================================

local function CopyCFrame(cf)

	if not cf then
		return nil
	end

	return CFrame.new(
		cf:GetComponents()
	)
end

local function CloneVector3(v)

	if not v then
		return Vector3.zero
	end

	return Vector3.new(
		v.X,
		v.Y,
		v.Z
	)
end

local function CloneTimeline(source)

	local result = {}

	for _,node in ipairs(source) do

		table.insert(
			result,
			{
				CFrame =
					CopyCFrame(
						node.CFrame
					),

				Position =
					CloneVector3(
						node.Position
					),

				Timestamp =
					node.Timestamp or 0,

				RelativeTimestamp =
					node.RelativeTimestamp or 0,

				WalkSpeed =
					node.WalkSpeed or 16,

				MoveDirection =
					CloneVector3(
						node.MoveDirection
					),

				HumanoidState =
					node.HumanoidState
			}
		)
	end

	return result
end

local function CloneJumpEvents(source)

	local result = {}

	for _,event in ipairs(source or {}) do

		table.insert(
			result,
			{
				Timestamp =
					event.Timestamp or 0,

				Type =
					event.Type or "Jump"
			}
		)
	end

	return result
end

local function NormalizeTimeline(timeline)

	if #timeline == 0 then
		return timeline
	end

	table.sort(
		timeline,
		function(a,b)
			return
				(a.Timestamp or 0)
				<
				(b.Timestamp or 0)
		end
	)

	local first =
		timeline[1].Timestamp or 0

	for _,node in ipairs(timeline) do

		node.Timestamp =
			node.Timestamp or first

		node.RelativeTimestamp =
			math.max(
				0,
				node.Timestamp - first
			)

		if not node.Position
			and node.CFrame
		then
			node.Position =
				node.CFrame.Position
		end

		if not node.Position then
			node.Position =
				Vector3.zero
		end

		if not node.CFrame then
			node.CFrame =
				CFrame.new(
					node.Position
				)
		end

		if not node.MoveDirection then
			node.MoveDirection =
				Vector3.zero
		end

		if not node.WalkSpeed then
			node.WalkSpeed = 16
		end
	end

	return timeline
end

local function NormalizeJumpEvents(events)

	table.sort(
		events,
		function(a,b)
			return
				(a.Timestamp or 0)
				<
				(b.Timestamp or 0)
		end
	)

	local last = 0

	for _,event in ipairs(events) do

		event.Timestamp =
			math.max(
				event.Timestamp or 0,
				last
			)

		last =
			event.Timestamp
	end

	return events
end

local function GetTimelineDuration()

	if #State.Timeline == 0 then
		return 0
	end

	NormalizeTimeline(
		State.Timeline
	)

	return math.max(
		State.Timeline[
			#State.Timeline
		].RelativeTimestamp or 0,
		0
	)
end

--============================================================
-- VISUAL ROUTE
--============================================================

local function ClearVisuals()

	for _,part in ipairs(
		State.VisualNodes
	) do

		if part and part.Parent then
			part:Destroy()
		end
	end

	table.clear(
		State.VisualNodes
	)

	for _,child in ipairs(
		RouteFolder:GetChildren()
	) do
		child:Destroy()
	end
end

local function DrawLine(a,b)

	if not a or not b then
		return
	end

	local distance =
		(b-a).Magnitude

	if distance < 0.03 then
		return
	end

	local part =
		Instance.new("Part")

	part.Name =
		"KnightXorzRouteLine"

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false

	part.Material =
		Enum.Material.Neon

	part.Color =
		CFG.LineColor

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
		State.LineVisible
		and 0
		or 1

	part.Parent =
		RouteFolder

	table.insert(
		State.VisualNodes,
		part
	)
end

local function RedrawRoute()

	ClearVisuals()

	if #State.Timeline < 2 then
		return
	end

	for i = 2,#State.Timeline do

		local a =
			State.Timeline[i-1]

		local b =
			State.Timeline[i]

		if a.Position and b.Position then
			DrawLine(
				a.Position,
				b.Position
			)
		end
	end
end

--============================================================
-- RECORD NODE
--============================================================

local function AddRecordNode(force)

	if not CharacterAlive() then
		return
	end

	local now =
		os.clock()

	local elapsed =
		now - State.RecordStart

	local cf =
		RootPart.CFrame

	local position =
		RootPart.Position

	local humanoidState =
		Humanoid:GetState()

	local moveDirection =
		Humanoid.MoveDirection

	local walkSpeed =
		Humanoid.WalkSpeed

	--========================================================
	-- FIRST NODE
	--========================================================

	if #State.Timeline == 0 then

		table.insert(
			State.Timeline,
			{
				CFrame =
					CopyCFrame(cf),

				Position =
					CloneVector3(position),

				Timestamp =
					now,

				RelativeTimestamp =
					0,

				WalkSpeed =
					walkSpeed,

				MoveDirection =
					CloneVector3(
						moveDirection
					),

				HumanoidState =
					humanoidState.Name
			}
		)

		State.LastRecordTime =
			now

		State.LastPosition =
			position

		return
	end

	--========================================================
	-- SAMPLE RATE
	--========================================================

	if not force then

		if
			now
			-
			State.LastRecordTime
			<
			CFG.RecordSampleRate
		then
			return
		end
	end

	local last =
		State.Timeline[
			#State.Timeline
		]

	local lastPosition =
		last.Position
		or
		Vector3.zero

	local lastDirection =
		last.MoveDirection
		or
		Vector3.zero

	local distance =
		(position-lastPosition).Magnitude

	local directionDifference =
		(
			moveDirection
			-
			lastDirection
		).Magnitude

	local speedDifference =
		math.abs(
			walkSpeed
			-
			(last.WalkSpeed or walkSpeed)
		)

	local stateChanged =
		last.HumanoidState
		~=
		humanoidState.Name

	local shouldRecord =
		force
		or distance >= CFG.MinDistance
		or directionDifference >= CFG.DirectionThreshold
		or speedDifference >= CFG.SpeedThreshold
		or stateChanged

	if not shouldRecord then
		return
	end

	table.insert(
		State.Timeline,
		{
			CFrame =
				CopyCFrame(cf),

			Position =
				CloneVector3(position),

			Timestamp =
				now,

			RelativeTimestamp =
				elapsed,

			WalkSpeed =
				walkSpeed,

			MoveDirection =
				CloneVector3(
					moveDirection
				),

			HumanoidState =
				humanoidState.Name
		}
	)

	State.LastRecordTime =
		now

	State.LastPosition =
		position

	if last.Position then

		DrawLine(
			last.Position,
			position
		)

	end
end

--============================================================
-- RECORD HEARTBEAT
--============================================================

local RecordHeartbeatConnection

RecordHeartbeatConnection =
	RunService.Heartbeat:Connect(
		function()

			if not State.Recording then
				return
			end

			if not CharacterAlive() then
				return
			end

			AddRecordNode(false)
		end
	)

--============================================================
-- NODE SEARCH
--============================================================

local function GetNodePair(time)

	local timeline =
		State.Timeline

	local count =
		#timeline

	if count == 0 then
		return nil,nil,0,0
	end

	if count == 1 then

		return
			timeline[1],
			timeline[1],
			0,
			1
	end

	if time <= 0 then

		return
			timeline[1],
			timeline[2],
			0,
			1
	end

	local duration =
		GetTimelineDuration()

	if time >= duration then

		return
			timeline[count],
			timeline[count],
			1,
			count
	end

	local low = 1
	local high = count

	while low < high do

		local middle =
			math.floor(
				(low + high) / 2
			)

		local nodeTime =
			timeline[middle]
			.RelativeTimestamp
			or 0

		if nodeTime < time then
			low =
				middle + 1
		else
			high =
				middle
		end
	end

	local index2 =
		math.clamp(
			low,
			2,
			count
		)

	local index1 =
		index2 - 1

	local a =
		timeline[index1]

	local b =
		timeline[index2]

	local t1 =
		a.RelativeTimestamp or 0

	local t2 =
		b.RelativeTimestamp or 0

	local range =
		t2 - t1

	local alpha = 0

	if range > 0 then
		alpha =
			(time-t1)/range
	end

	alpha =
		math.clamp(
			alpha,
			0,
			1
		)

	return
		a,
		b,
		alpha,
		index1
end

--============================================================
-- PLAYBACK DATA
--============================================================

local function GetPlaybackData(time)

	local a,b,alpha,index =
		GetNodePair(time)

	if not a then
		return nil
	end

	if not b or a == b then

		return {

			Position =
				a.Position,

			LookVector =
				a.CFrame.LookVector,

			MoveDirection =
				a.MoveDirection
				or Vector3.zero,

			WalkSpeed =
				a.WalkSpeed or 16,

			NodeIndex =
				index
		}
	end

	local position =
		a.Position:Lerp(
			b.Position,
			alpha
		)

	local moveDirection =
		a.MoveDirection:Lerp(
			b.MoveDirection
			or Vector3.zero,
			alpha
		)

	local speed =
		(a.WalkSpeed or 16)
		+
		(
			(b.WalkSpeed or 16)
			-
			(a.WalkSpeed or 16)
		)
		*
		alpha

	local look =
		a.CFrame.LookVector:Lerp(
			b.CFrame.LookVector,
			alpha
		)

	if look.Magnitude < 0.01 then
		look =
			a.CFrame.LookVector
	end

	return {

		Position =
			position,

		LookVector =
			look.Unit,

		MoveDirection =
			moveDirection,

		WalkSpeed =
			math.max(
				speed,
				0
			),

		NodeIndex =
			index
	}
end

--============================================================
-- JUMP PLAYBACK
--============================================================

local function TriggerRecordedJump()

	if not CharacterAlive() then
		return
	end

	local currentState =
		Humanoid:GetState()

	if
		currentState ==
		Enum.HumanoidStateType.Jumping
		or
		currentState ==
		Enum.HumanoidStateType.Freefall
	then
		return
	end

	Humanoid.Jump =
		true

	pcall(function()
		Humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end)
end

local function ProcessJumpEvents(
	oldTime,
	newTime
)

	local events =
		State.JumpEvents

	while
		State.PlaybackJumpIndex
		<=
		#events
	do

		local event =
			events[
				State.PlaybackJumpIndex
			]

		local eventTime =
			event.Timestamp or 0

		if eventTime > newTime then
			break
		end

		if eventTime >= oldTime then

			if event.Type == "Jump" then
				TriggerRecordedJump()
			end

		end

		State.PlaybackJumpIndex += 1
	end
end

--============================================================
-- STOP PLAYBACK
--============================================================

local function StopPlayback(manual)

	State.PlaybackToken += 1

	State.Playing = false
	State.Paused = false

	State.CurrentElapsed = 0
	State.CurrentNodeIndex = 1

	State.FinishHandled = false

	State.PlaybackJumpIndex = 1

	State.PlaybackConnectionActive =
		false

	pcall(function()
		RunService:UnbindFromRenderStep(
			PLAYBACK_BIND
		)
	end)

	if manual then
		State.AutoWalk = false
	end

	if CharacterAlive() then

		Humanoid.AutoRotate =
			true

		Humanoid:Move(
			Vector3.zero,
			true
		)

		Humanoid.WalkSpeed =
			State.OriginalWalkSpeed
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

	local started =
		os.clock()

	Humanoid.AutoRotate =
		true

	Humanoid.WalkSpeed =
		State.OriginalWalkSpeed

	while
		State.Playing
		and State.PlaybackToken == token
		and CharacterAlive()
	do

		if State.Paused then

			Humanoid:Move(
				Vector3.zero,
				true
			)

			RunService.Heartbeat:Wait()

			continue
		end

		local offset =
			position
			-
			RootPart.Position

		local horizontal =
			Vector3.new(
				offset.X,
				0,
				offset.Z
			)

		local distance =
			horizontal.Magnitude

		if distance <= CFG.StartDistance then

			Humanoid:Move(
				Vector3.zero,
				true
			)

			return true
		end

		if distance > 0.05 then

			Humanoid:Move(
				horizontal.Unit,
				false
			)

		else

			Humanoid:Move(
				Vector3.zero,
				true
			)
		end

		if
			os.clock()-started
			>= CFG.StartTimeout
		then
			return false
		end

		RunService.Heartbeat:Wait()
	end

	return false
end

--============================================================
-- RETURN TO START
--============================================================

local function ReturnToStart(
	position,
	token
)

	if not CharacterAlive() then
		return false
	end

	local started =
		os.clock()

	Humanoid.AutoRotate =
		true

	Humanoid.WalkSpeed =
		State.OriginalWalkSpeed

	while
		State.Playing
		and State.AutoWalk
		and State.PlaybackToken == token
		and CharacterAlive()
	do

		if State.Paused then

			Humanoid:Move(
				Vector3.zero,
				true
			)

			RunService.Heartbeat:Wait()

			continue
		end

		local offset =
			position
			-
			RootPart.Position

		local horizontal =
			Vector3.new(
				offset.X,
				0,
				offset.Z
			)

		local distance =
			horizontal.Magnitude

		if distance <= CFG.StartDistance then

			Humanoid:Move(
				Vector3.zero,
				true
			)

			return true
		end

		if distance > 0.05 then

			Humanoid:Move(
				horizontal.Unit,
				false
			)

		else

			Humanoid:Move(
				Vector3.zero,
				true
			)
		end

		if
			os.clock()-started
			>= CFG.StartTimeout
		then
			return false
		end

		RunService.Heartbeat:Wait()
	end

	return false
end

--============================================================
-- PLAYBACK
--============================================================

local function StartPlaybackRun(token)

	if not CharacterAlive() then
		return false
	end

	if #State.Timeline < 2 then
		return false
	end

	local duration =
		GetTimelineDuration()

	if duration <= 0 then
		return false
	end

	local elapsed = 0
	local lastTime = -0.000001

	State.CurrentElapsed = 0
	State.CurrentNodeIndex = 1
	State.FinishHandled = false
	State.PlaybackJumpIndex = 1

	State.PlaybackConnectionActive =
		true

	Humanoid.AutoRotate =
		true

	SetStatus(
		State.AutoWalk
		and "AUTO WALK"
		or "PLAYING"
	)

	--========================================================
	-- PLAYBACK RENDER LOOP
	--========================================================

	RunService:BindToRenderStep(
		PLAYBACK_BIND,

		Enum.RenderPriority.Character.Value + 3,

		function(dt)

			if
				not State.Playing
				or State.PlaybackToken ~= token
				or not CharacterAlive()
			then

				pcall(function()
					RunService:UnbindFromRenderStep(
						PLAYBACK_BIND
					)
				end)

				State.PlaybackConnectionActive =
					false

				return
			end

			--================================================
			-- PAUSE
			--================================================

			if State.Paused then

				Humanoid:Move(
					Vector3.zero,
					true
				)

				return
			end

			--================================================
			-- TIME
			--================================================

			local safeDt =
				math.clamp(
					dt,
					0,
					0.1
				)

			local newTime =
				math.min(
					elapsed
					+
					safeDt
					*
					CFG.PlaybackSpeedMultiplier,
					duration
				)

			--================================================
			-- JUMP EVENTS
			--================================================

			ProcessJumpEvents(
				lastTime,
				newTime
			)

			lastTime =
				newTime

			elapsed =
				newTime

			State.CurrentElapsed =
				elapsed

			--================================================
			-- TARGET
			--================================================

			local data =
				GetPlaybackData(
					elapsed
				)

			if data then

				State.CurrentNodeIndex =
					data.NodeIndex or 1

				--================================================
				-- SPEED
				--================================================

				Humanoid.WalkSpeed =
					math.max(
						data.WalkSpeed,
						0
					)

				--================================================
				-- MOVEMENT
				--================================================

				local direction =
					data.MoveDirection
					or Vector3.zero

				if direction.Magnitude > 1 then
					direction =
						direction.Unit
				end

				if direction.Magnitude > 0.025 then

					Humanoid:Move(
						direction,
						false
					)

				else

					Humanoid:Move(
						Vector3.zero,
						true
					)
				end

				--================================================
				-- ROTATION
				--================================================

				local look =
					data.LookVector

				if
					look
					and
					look.Magnitude > 0.01
				then

					local flat =
						Vector3.new(
							look.X,
							0,
							look.Z
						)

					if flat.Magnitude > 0.01 then

						Humanoid.AutoRotate =
							false

						local current =
							RootPart.CFrame

						local desired =
							CFrame.lookAt(
								current.Position,
								current.Position
								+
								flat.Unit
							)

						RootPart.CFrame =
							current:Lerp(
								desired,
								math.clamp(
									safeDt * 10,
									0,
									1
								)
							)
					end
				end

				--================================================
				-- DRIFT
				--================================================

				local offset =
					data.Position
					-
					RootPart.Position

				local horizontalDifference =
					Vector3.new(
						offset.X,
						0,
						offset.Z
					)

				local horizontalDistance =
					horizontalDifference.Magnitude

				--================================================
				-- HARD CORRECTION
				--================================================

				if
					horizontalDistance
					>=
					CFG.HardCorrectionDistance
				then

					if
						os.clock()
						-
						State.LastCorrection
						>=
						CFG.CorrectionCooldown
					then

						local current =
							RootPart.Position

						local target =
							data.Position

						local corrected =
							Vector3.new(
								target.X,
								current.Y,
								target.Z
							)

						local oldCFrame =
							RootPart.CFrame

						local velocity =
							RootPart.AssemblyLinearVelocity

						RootPart.CFrame =
							CFrame.new(
								corrected
							)
							*
							CFrame.Angles(
								0,
								select(
									2,
									oldCFrame:ToEulerAnglesYXZ()
								),
								0
							)

						RootPart.AssemblyLinearVelocity =
							velocity

						State.LastCorrection =
							os.clock()
					end

				--================================================
				-- SOFT CORRECTION
				--================================================

				elseif
					horizontalDistance
					>=
					CFG.MovementTolerance
				then

					if
						os.clock()
						-
						State.LastCorrection
						>=
						CFG.CorrectionCooldown
					then

						local current =
							RootPart.Position

						local target =
							data.Position

						local difference =
							Vector3.new(
								target.X-current.X,
								0,
								target.Z-current.Z
							)

						local corrected =
							current
							+
							difference
							*
							0.35

						local velocity =
							RootPart.AssemblyLinearVelocity

						local rotationOnly =
							RootPart.CFrame
							- RootPart.Position

						RootPart.CFrame =
							CFrame.new(
								corrected
							)
							*
							rotationOnly

						RootPart.AssemblyLinearVelocity =
							velocity

						State.LastCorrection =
							os.clock()
					end
				end
			end

			--================================================
			-- FINISH
			--================================================

			if
				elapsed >= duration
				and
				not State.FinishHandled
			then

				State.FinishHandled =
					true

				pcall(function()
					RunService:UnbindFromRenderStep(
						PLAYBACK_BIND
					)
				end)

				State.PlaybackConnectionActive =
					false

				Humanoid:Move(
					Vector3.zero,
					true
				)

				Humanoid.AutoRotate =
					true

				--================================================
				-- AUTO WALK LOOP
				--================================================

				if State.AutoWalk then

					task.spawn(
						function()

							if
								not State.Playing
								or
								State.PlaybackToken
								~=
								token
							then
								return
							end

							local reached =
								ReturnToStart(
									State.Timeline[1].Position,
									token
								)

							if not reached then

								if
									State.Playing
									and
									State.PlaybackToken
									==
									token
								then

									StopPlayback(
										false
									)
								end

								return
							end

							if
								not State.Playing
								or
								not State.AutoWalk
								or
								State.PlaybackToken
								~=
								token
							then
								return
							end

							State.FinishHandled =
								false

							StartPlaybackRun(
								token
							)
						end
					)

				else

					StopPlayback(false)

				end
			end
		end
	)

	return true
end

--============================================================
-- EXECUTE PLAYBACK
--============================================================

local function ExecutePlayback()

	if State.Recording then

		SetStatus(
			"STOP RECORD FIRST"
		)

		return
	end

	if State.Playing then
		return
	end

	if not CharacterAlive() then

		SetStatus(
			"NO CHARACTER"
		)

		return
	end

	if #State.Timeline < 2 then

		SetStatus(
			"NO ROUTE"
		)

		return
	end

	NormalizeTimeline(
		State.Timeline
	)

	NormalizeJumpEvents(
		State.JumpEvents
	)

	local duration =
		GetTimelineDuration()

	if duration <= 0 then

		SetStatus(
			"INVALID ROUTE"
		)

		return
	end

	--========================================================
	-- SAVE ORIGINAL SPEED
	--========================================================

	State.OriginalWalkSpeed =
		Humanoid.WalkSpeed

	State.PlaybackWalkSpeed =
		State.Timeline[1].WalkSpeed
		or
		State.OriginalWalkSpeed

	--========================================================
	-- TOKEN
	--========================================================

	State.PlaybackToken += 1

	local token =
		State.PlaybackToken

	State.Playing =
		true

	State.Paused =
		false

	State.CurrentElapsed =
		0

	State.FinishHandled =
		false

	State.LastCorrection =
		0

	State.PlaybackJumpIndex =
		1

	--========================================================
	-- WALK START
	--========================================================

	SetStatus(
		"WALKING TO START"
	)

	local reached =
		WalkToStart(
			State.Timeline[1].Position,
			token
		)

	if
		not reached
		or
		not State.Playing
		or
		State.PlaybackToken ~= token
	then

		if State.Playing then
			StopPlayback(false)
		end

		return
	end

	--========================================================
	-- START
	--========================================================

	local started =
		StartPlaybackRun(
			token
		)

	if not started then

		if State.Playing then
			StopPlayback(false)
		end

		return
	end
end

--============================================================
-- GUI
--============================================================

local ScreenGui =
	Instance.new("ScreenGui")

ScreenGui.Name =
	"AldoKnightXorzV453Gui"

ScreenGui.ResetOnSpawn =
	false

ScreenGui.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
	PlayerGui

--============================================================
-- OPEN BUTTON
--============================================================

local OpenButton =
	Instance.new("TextButton")

OpenButton.Name =
	"OpenMenu"

OpenButton.Size =
	UDim2.fromOffset(
		58,
		58
	)

OpenButton.Position =
	UDim2.new(
		0.035,
		0,
		0.5,
		-29
	)

OpenButton.Text =
	"AK"

OpenButton.Font =
	Enum.Font.GothamBlack

OpenButton.TextSize =
	15

OpenButton.TextColor3 =
	Color3.new(1,1,1)

OpenButton.BackgroundColor3 =
	CFG.PanelColor

OpenButton.AutoButtonColor =
	false

OpenButton.Active =
	true

OpenButton.Parent =
	ScreenGui

local OpenCorner =
	Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(
		0,
		14
	)

OpenCorner.Parent =
	OpenButton

local OpenStroke =
	Instance.new("UIStroke")

OpenStroke.Thickness =
	2

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
	UDim2.fromOffset(
		CFG.MainWidth,
		CFG.MainHeight
	)

MainFrame.Position =
	UDim2.new(
		0.5,
		-CFG.MainWidth/2,
		0.5,
		-CFG.MainHeight/2
	)

MainFrame.BackgroundColor3 =
	CFG.PanelColor

MainFrame.BorderSizePixel =
	0

MainFrame.Active =
	true

MainFrame.Visible =
	true

MainFrame.Parent =
	ScreenGui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(
		0,
		18
	)

MainCorner.Parent =
	MainFrame

local MainStroke =
	Instance.new("UIStroke")

MainStroke.Thickness =
	2

MainStroke.Color =
	CFG.AccentB

MainStroke.Parent =
	MainFrame

local MainGradient =
	Instance.new("UIGradient")

MainGradient.Rotation =
	35

MainGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(
				10,
				20,
				35
			)
		),

		ColorSequenceKeypoint.new(
			0.45,
			Color3.fromRGB(
				24,
				10,
				40
			)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(
				8,
				25,
				32
			)
		)
	})

MainGradient.Parent =
	MainFrame

--============================================================
-- TITLE
--============================================================

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.new(
		1,
		-30,
		0,
		38
	)

Title.Position =
	UDim2.fromOffset(
		15,
		8
	)

Title.BackgroundTransparency =
	1

Title.Text =
	"ALDO KNIGHTXORZ"

Title.Font =
	Enum.Font.GothamBlack

Title.TextSize =
	17

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

Title.Active =
	true

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
			Color3.new(
				1,
				1,
				1
			)
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
	UDim2.new(
		1,
		-30,
		0,
		25
	)

StatusLabel.Position =
	UDim2.fromOffset(
		15,
		43
	)

StatusLabel.BackgroundTransparency =
	1

StatusLabel.Text =
	"STATUS • IDLE • FILE 1"

StatusLabel.Font =
	Enum.Font.GothamBold

StatusLabel.TextSize =
	11

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

Container.Name =
	"ButtonContainer"

Container.Size =
	UDim2.new(
		1,
		-30,
		1,
		-82
	)

Container.Position =
	UDim2.fromOffset(
		15,
		73
	)

Container.BackgroundTransparency =
	1

Container.BorderSizePixel =
	0

Container.ScrollBarThickness =
	3

Container.ScrollBarImageColor3 =
	CFG.AccentA

Container.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

Container.CanvasSize =
	UDim2.new()

Container.Parent =
	MainFrame

local Grid =
	Instance.new("UIGridLayout")

Grid.CellSize =
	UDim2.fromOffset(
		120,
		39
	)

Grid.CellPadding =
	UDim2.fromOffset(
		8,
		8
	)

Grid.SortOrder =
	Enum.SortOrder.LayoutOrder

Grid.Parent =
	Container

--============================================================
-- BUTTON CREATOR
--============================================================

local function CreateButton(
	text,
	order,
	callback
)

	local button =
		Instance.new("TextButton")

	button.Name =
		"Button_" .. tostring(order)

	button.Size =
		UDim2.fromOffset(
			120,
			39
		)

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

	button.TextSize =
		10

	button.AutoButtonColor =
		false

	button.Active =
		true

	button.Parent =
		Container

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			9
		)

	corner.Parent =
		button

	local stroke =
		Instance.new("UIStroke")

	stroke.Thickness =
		1

	stroke.Color =
		Color3.fromRGB(
			70,
			70,
			95
		)

	stroke.Parent =
		button

	button.Activated:Connect(
		function()

			--================================================
			-- BUTTON FEEDBACK
			--================================================

			button.BackgroundColor3 =
				CFG.AccentB

			task.delay(
				0.1,
				function()

					if
						button
						and
						button.Parent
					then

						button.BackgroundColor3 =
							CFG.ButtonColor

					end
				end
			)

			--================================================
			-- CALLBACK
			--================================================

			local success,err =
				pcall(callback)

			if not success then

				warn(
					"[KNIGHTXORZ]",
					err
				)

				SetStatus(
					"ERROR"
				)
			end
		end
	)

	return button
end

--============================================================
-- RECORD
--============================================================

CreateButton(
	"● RECORD",
	1,

	function()

		--====================================================
		-- STOP RECORD
		--====================================================

		if State.Recording then

			State.Recording =
				false

			AddRecordNode(true)

			NormalizeTimeline(
				State.Timeline
			)

			NormalizeJumpEvents(
				State.JumpEvents
			)

			RedrawRoute()

			SetStatus(
				"RECORDED "
				..
				#State.Timeline
				..
				" NODES / "
				..
				#State.JumpEvents
				..
				" JUMPS"
			)

			return
		end

		--====================================================
		-- START NEW RECORD
		--====================================================

		StopPlayback(true)

		State.Timeline =
			{}

		State.JumpEvents =
			{}

		State.LastJumpEventIndex =
			1

		ClearVisuals()

		if not CharacterAlive() then

			SetStatus(
				"NO CHARACTER"
			)

			return
		end

		State.RecordStart =
			os.clock()

		State.LastRecordTime =
			0

		State.LastPosition =
			nil

		State.Recording =
			true

		SetStatus(
			"RECORDING"
		)

		AddRecordNode(true)
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

			SetStatus(
				"STOP RECORD FIRST"
			)

			return
		end

		State.AutoWalk =
			false

		ExecutePlayback()
	end
)

--============================================================
-- PAUSE / RESUME
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

			Humanoid:Move(
				Vector3.zero,
				true
			)

			SetStatus(
				"PAUSED"
			)

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

			SetStatus(
				"STOP RECORD FIRST"
			)

			return
		end

		if State.AutoWalk then

			State.AutoWalk =
				false

			StopPlayback(true)

			return
		end

		State.AutoWalk =
			true

		if not State.Playing then
			ExecutePlayback()
		else
			SetStatus(
				"AUTO WALK"
			)
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
		"FILE " .. i,
		5 + i,

		function()

			if State.Playing then
				StopPlayback(true)
			end

			State.SelectedFile =
				i

			SetStatus(
				"IDLE"
			)
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

			SetStatus(
				"NO DATA"
			)

			return
		end

		NormalizeTimeline(
			State.Timeline
		)

		NormalizeJumpEvents(
			State.JumpEvents
		)

		State.SavedFiles[
			State.SelectedFile
		] = {

			Timeline =
				CloneTimeline(
					State.Timeline
				),

			JumpEvents =
				CloneJumpEvents(
					State.JumpEvents
				),

			SavedAt =
				os.time()
		}

		SetStatus(
			"SAVED FILE "
			..
			State.SelectedFile
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

			SetStatus(
				"FILE EMPTY"
			)

			return
		end

		StopPlayback(true)

		State.Timeline =
			CloneTimeline(
				data.Timeline
			)

		State.JumpEvents =
			CloneJumpEvents(
				data.JumpEvents
			)

		NormalizeTimeline(
			State.Timeline
		)

		NormalizeJumpEvents(
			State.JumpEvents
		)

		RedrawRoute()

		SetStatus(
			"LOADED FILE "
			..
			State.SelectedFile
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

		State.Timeline =
			{}

		State.JumpEvents =
			{}

		ClearVisuals()

		SetStatus(
			"CLEARED"
		)
	end
)

--============================================================
-- LINE
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

			if
				part
				and
				part.Parent
			then

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
-- DRAG GUI
--============================================================

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(
	function(input)

		if
			input.UserInputType
			==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			dragging =
				true

			dragStart =
				input.Position

			startPosition =
				MainFrame.Position

		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)

		if not dragging then
			return
		end

		if
			input.UserInputType
			==
			Enum.UserInputType.MouseMovement
			or
			input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			local delta =
				input.Position
				-
				dragStart

			MainFrame.Position =
				UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset
					+
					delta.X,

					startPosition.Y.Scale,
					startPosition.Y.Offset
					+
					delta.Y
				)
		end
	end
)

UserInputService.InputEnded:Connect(
	function(input)

		if
			input.UserInputType
			==
			Enum.UserInputType.MouseButton1
			or
			input.UserInputType
			==
			Enum.UserInputType.Touch
		then

			dragging =
				false

		end
	end
)

--============================================================
-- OPEN / CLOSE
--============================================================

OpenButton.Activated:Connect(
	function()

		MainFrame.Visible =
			not MainFrame.Visible

	end
)

--============================================================
-- GRADIENT ANIMATION
--============================================================

task.spawn(
	function()

		while
			ScreenGui
			and
			ScreenGui.Parent
		do

			local targetRotation =
				MainGradient.Rotation
				+
				360

			local tween =
				TweenService:Create(
					MainGradient,

					TweenInfo.new(
						5,
						Enum.EasingStyle.Linear
					),

					{
						Rotation =
							targetRotation
					}
				)

			tween:Play()
			tween.Completed:Wait()

			if
				MainGradient
				and
				MainGradient.Parent
			then

				MainGradient.Rotation =
					MainGradient.Rotation
					% 360

			else
				break
			end
		end
	end
)

task.spawn(
	function()

		while
			ScreenGui
			and
			ScreenGui.Parent
		do

			local targetRotation =
				OpenGradient.Rotation
				+
				360

			local tween =
				TweenService:Create(
					OpenGradient,

					TweenInfo.new(
						3,
						Enum.EasingStyle.Linear
					),

					{
						Rotation =
							targetRotation
					}
				)

			tween:Play()
			tween.Completed:Wait()

			if
				OpenGradient
				and
				OpenGradient.Parent
			then

				OpenGradient.Rotation =
					OpenGradient.Rotation
					% 360

			else
				break
			end
		end
	end
)

--============================================================
-- CHARACTER RESPAWN
--============================================================

Player.CharacterAdded:Connect(
	function(char)

		--====================================================
		-- INVALIDATE OLD PLAYBACK
		--====================================================

		State.PlaybackToken += 1

		State.Playing =
			false

		State.Paused =
			false

		State.Recording =
			false

		State.AutoWalk =
			false

		State.FinishHandled =
			false

		State.PlaybackConnectionActive =
			false

		pcall(function()
			RunService:UnbindFromRenderStep(
				PLAYBACK_BIND
			)
		end)

		SetupCharacter(char)

		if Humanoid then

			Humanoid.AutoRotate =
				true

		end

		SetStatus(
			"IDLE"
		)
	end
)

--============================================================
-- GUI CLEANUP
--============================================================

ScreenGui.AncestryChanged:Connect(
	function(_,parent)

		if parent then
			return
		end

		State.PlaybackToken += 1

		State.Recording =
			false

		State.Playing =
			false

		pcall(function()

			RunService:UnbindFromRenderStep(
				RECORD_BIND
			)

			RunService:UnbindFromRenderStep(
				PLAYBACK_BIND
			)

		end)

		if RecordHeartbeatConnection then

			pcall(function()
				RecordHeartbeatConnection:Disconnect()
			end)

			RecordHeartbeatConnection =
				nil
		end

		DisconnectCharacterConnections()

	end
)

--============================================================
-- FINAL
--============================================================

SetStatus(
	"IDLE"
)

print(
	"KNIGHTXORZ V4.53 READY"
)
