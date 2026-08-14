local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")

local Player=Players.LocalPlayer
local PlayerGui=Player:WaitForChild("PlayerGui")

local GUI_NAME="VoraZureAutoWalk"

local Character
local Humanoid
local Root

local recording=false
local playing=false
local looping=false
local returning=false

local recordStart=0
local lastRecordTime=0
local playbackTime=0

local route={}
local jumpEvents={}
local jumpCursor=1

local playbackConnection
local recordConnection
local heartbeatConnection

local visualFolder
local carrier
local startMarker
local endMarker
local playbackMarker

local visualPoints={}
local visualBeams={}

local oldWalkSpeed=16
local oldAutoRotate=true

local RECORD_RATE=1/60
local VISUAL_RATE=0.035
local VISUAL_MIN_DISTANCE=0.18

local function refreshCharacter()
	Character=Player.Character

	if not Character then
		Humanoid=nil
		Root=nil
		return false
	end

	Humanoid=Character:FindFirstChildOfClass("Humanoid")
	Root=Character:FindFirstChild("HumanoidRootPart")

	return Humanoid~=nil and Root~=nil
end

refreshCharacter()

local function vecTable(v)
	return {
		X=v.X,
		Y=v.Y,
		Z=v.Z
	}
end

local function tableVec(v)
	if type(v)~="table" then
		return Vector3.zero
	end

	return Vector3.new(
		tonumber(v.X) or 0,
		tonumber(v.Y) or 0,
		tonumber(v.Z) or 0
	)
end

local function pointPosition(point)
	return tableVec(point.Position)
end

local function pointMove(point)
	local v=tableVec(point.Move)

	local flat=Vector3.new(
		v.X,
		0,
		v.Z
	)

	if flat.Magnitude>1 then
		flat=flat.Unit
	end

	return flat
end

local function clearVisuals()
	if visualFolder then
		visualFolder:Destroy()
	end

	visualFolder=nil
	carrier=nil
	startMarker=nil
	endMarker=nil
	playbackMarker=nil

	table.clear(visualPoints)
	table.clear(visualBeams)
end

local function makeVisualContainer()
	clearVisuals()

	visualFolder=Instance.new("Folder")
	visualFolder.Name="VoraZureAutoWalkRoute"
	visualFolder.Parent=workspace

	carrier=Instance.new("Part")
	carrier.Name="Carrier"
	carrier.Anchored=true
	carrier.CanCollide=false
	carrier.CanTouch=false
	carrier.CanQuery=false
	carrier.Transparency=1
	carrier.Size=Vector3.new(1,1,1)
	carrier.CFrame=CFrame.new()
	carrier.Parent=visualFolder
end

local function makeMarker(name,pos,size,color)
	local p=Instance.new("Part")
	p.Name=name
	p.Shape=Enum.PartType.Ball
	p.Size=Vector3.new(size,size,size)
	p.Position=pos
	p.Anchored=true
	p.CanCollide=false
	p.CanTouch=false
	p.CanQuery=false
	p.Material=Enum.Material.Neon
	p.Color=color
	p.CastShadow=false
	p.Parent=visualFolder

	local light=Instance.new("PointLight")
	light.Range=8
	light.Brightness=1.5
	light.Color=color
	light.Parent=p

	return p
end

local function addVisualPoint(pos,force)
	if not carrier then
		return
	end

	if not force then
		local previous=visualPoints[#visualPoints]

		if previous then
			local worldPosition=carrier.CFrame:PointToWorldSpace(
				previous.Position
			)

			if (worldPosition-pos).Magnitude<VISUAL_MIN_DISTANCE then
				return
			end
		end
	end

	local attachment=Instance.new("Attachment")
	attachment.Position=carrier.CFrame:PointToObjectSpace(pos)
	attachment.Parent=carrier

	visualPoints[#visualPoints+1]=attachment

	if #visualPoints>1 then
		local beam=Instance.new("Beam")
		beam.Attachment0=visualPoints[#visualPoints-1]
		beam.Attachment1=visualPoints[#visualPoints]
		beam.FaceCamera=true
		beam.Segments=2
		beam.Width0=0.14
		beam.Width1=0.14
		beam.LightEmission=1
		beam.LightInfluence=0
		beam.Transparency=NumberSequence.new(0.08)
		beam.Color=ColorSequence.new(
			Color3.fromRGB(160,90,255),
			Color3.fromRGB(70,190,255)
		)
		beam.Parent=visualFolder

		visualBeams[#visualBeams+1]=beam
	end
end

local function createRouteVisual()
	if #route<1 then
		clearVisuals()
		return
	end

	makeVisualContainer()

	local first=pointPosition(route[1])
	local last=pointPosition(route[#route])

	startMarker=makeMarker(
		"START",
		first,
		0.9,
		Color3.fromRGB(80,255,150)
	)

	endMarker=makeMarker(
		"END",
		last,
		0.95,
		Color3.fromRGB(255,75,100)
	)

	playbackMarker=makeMarker(
		"PLAYBACK",
		first,
		0.55,
		Color3.fromRGB(255,200,70)
	)

	playbackMarker.Transparency=0.1

	for i=1,#route do
		addVisualPoint(
			pointPosition(route[i]),
			true
		)
	end
end

local function addJumpEvent(t)
	jumpEvents[#jumpEvents+1]={
		Time=t
	}
end

local function clearJumpEvents()
	table.clear(jumpEvents)
	jumpCursor=1
end

local function triggerJump()
	if not Humanoid or Humanoid.Health<=0 then
		return
	end

	local state=Humanoid:GetState()

	if state==Enum.HumanoidStateType.Jumping
		or state==Enum.HumanoidStateType.Freefall
		or state==Enum.HumanoidStateType.FallingDown then
		return
	end

	Humanoid.Jump=true
end

local function processJumpEvents(previous,current)
	while jumpCursor<=#jumpEvents do
		local event=jumpEvents[jumpCursor]

		if event.Time>current then
			break
		end

		if event.Time>=previous-0.025 then
			triggerJump()
		end

		jumpCursor+=1
	end
end

local function addRecordFrame(force)
	if not recording then
		return
	end

	if not refreshCharacter() then
		return
	end

	if not Root
		or not Root.Parent
		or not Humanoid
		or Humanoid.Health<=0 then
		return
	end

	local now=os.clock()

	if not force
		and now-lastRecordTime<RECORD_RATE then
		return
	end

	lastRecordTime=now

	local t=now-recordStart

	local position=Root.Position
	local move=Humanoid.MoveDirection
	local velocity=Root.AssemblyLinearVelocity
	local state=Humanoid:GetState()

	local previous=route[#route]
	local previousPosition=previous
		and pointPosition(previous)
		or position

	local deltaPosition=
		position-previousPosition

	local horizontalDelta=Vector3.new(
		deltaPosition.X,
		0,
		deltaPosition.Z
	)

	local measuredVelocity=Vector3.zero

	if previous then
		local dt=t-(tonumber(previous.Time) or 0)

		if dt>0.0001 then
			measuredVelocity=
				horizontalDelta/dt
		end
	end

	local jumpStart=
		state==Enum.HumanoidStateType.Jumping
		and (
			not previous
			or previous.State~="Jumping"
		)

	if jumpStart then
		addJumpEvent(t)
	end

	route[#route+1]={
		Time=t,
		Position=vecTable(position),
		Move=vecTable(move),
		Velocity=vecTable(measuredVelocity),
		EngineVelocity=vecTable(velocity),
		State=state.Name
	}

	if endMarker then
		endMarker.Position=position
	end
end

local function stopRecording()
	if not recording then
		return
	end

	recording=false

	if recordConnection then
		recordConnection:Disconnect()
		recordConnection=nil
	end

	addRecordFrame(true)

	createRouteVisual()
end

local function startRecording()
	if recording or playing then
		return
	end

	if not refreshCharacter() then
		return
	end

	route={}
	clearJumpEvents()

	playbackTime=0
	jumpCursor=1

	recordStart=os.clock()
	lastRecordTime=0

	recording=true

	makeVisualContainer()

	local startPosition=Root.Position

	startMarker=makeMarker(
		"START",
		startPosition,
		0.9,
		Color3.fromRGB(80,255,150)
	)

	endMarker=makeMarker(
		"END",
		startPosition,
		0.95,
		Color3.fromRGB(255,75,100)
	)

	playbackMarker=makeMarker(
		"PLAYBACK",
		startPosition,
		0.55,
		Color3.fromRGB(255,200,70)
	)

	playbackMarker.Transparency=0.1

	addRecordFrame(true)

	recordConnection=
		RunService.Heartbeat:Connect(
			function()
				if not recording then
					return
				end

				addRecordFrame(false)

				local point=route[#route]

				if point then
					local now=os.clock()

					if
						visualPoints
						and #visualPoints>0
					then
						local previous=visualPoints[#visualPoints]

						local previousWorld=
							carrier.CFrame:PointToWorldSpace(
								previous.Position
							)

						if
							now-lastRecordTime>=VISUAL_RATE
							or
							(pointPosition(point)-previousWorld).Magnitude>=VISUAL_MIN_DISTANCE
						then
							addVisualPoint(
								pointPosition(point),
								false
							)
						end
					end
				end
			end
		)
end

local function getDuration()
	if #route<2 then
		return 0
	end

	return tonumber(route[#route].Time) or 0
end

local function sampleAt(time)
	if #route<2 then
		return nil
	end

	if time<=0 then
		return {
			Point=route[1],
			Next=route[2],
			Alpha=0
		}
	end

	local duration=getDuration()

	if time>=duration then
		return {
			Point=route[#route-1],
			Next=route[#route],
			Alpha=1
		}
	end

	local low=1
	local high=#route-1
	local index=1

	while low<=high do
		local mid=math.floor((low+high)/2)

		local aTime=tonumber(route[mid].Time) or 0
		local bTime=tonumber(route[mid+1].Time) or aTime

		if time<aTime then
			high=mid-1
		elseif time>bTime then
			low=mid+1
		else
			index=mid
			break
		end
	end

	local a=route[index]
	local b=route[index+1]

	local aTime=tonumber(a.Time) or 0
	local bTime=tonumber(b.Time) or aTime

	local alpha=0

	if bTime>aTime then
		alpha=math.clamp(
			(time-aTime)/(bTime-aTime),
			0,
			1
		)
	end

	return {
		Point=a,
		Next=b,
		Alpha=alpha
	}
end

local function calculatePlaybackState(time)
	local sample=sampleAt(time)

	if not sample then
		return nil
	end

	local a=sample.Point
	local b=sample.Next
	local alpha=sample.Alpha

	local aPosition=pointPosition(a)
	local bPosition=pointPosition(b)

	local position=
		aPosition:Lerp(
			bPosition,
			alpha
		)

	local aVelocity=tableVec(a.Velocity)
	local bVelocity=tableVec(b.Velocity)

	local velocity=
		aVelocity:Lerp(
			bVelocity,
			alpha
		)

	local horizontalVelocity=Vector3.new(
		velocity.X,
		0,
		velocity.Z
	)

	local speed=horizontalVelocity.Magnitude

	local direction=Vector3.zero

	if speed>0.03 then
		direction=horizontalVelocity.Unit
	else
		local moveA=pointMove(a)
		local moveB=pointMove(b)

		direction=
			moveA:Lerp(
				moveB,
				alpha
			)

		direction=Vector3.new(
			direction.X,
			0,
			direction.Z
		)

		if direction.Magnitude>0.03 then
			direction=direction.Unit
		end
	end

	return {
		Position=position,
		Velocity=velocity,
		Direction=direction,
		Speed=speed
	}
end

local function restoreCharacterMovement()
	if Humanoid then
		Humanoid.WalkSpeed=oldWalkSpeed
		Humanoid.AutoRotate=oldAutoRotate
	end
end

local function stopPlayback()
	if not playing then
		return
	end

	playing=false
	returning=false

	if playbackConnection then
		playbackConnection:Disconnect()
		playbackConnection=nil
	end

	playbackTime=0
	jumpCursor=1

	if Humanoid then
		Humanoid:Move(
			Vector3.zero,
			false
		)

		restoreCharacterMovement()
	end

	if playbackMarker
		and route[1] then

		playbackMarker.Position=
			pointPosition(route[1])
	end
end

local function beginReturnToStart()
	returning=true

	local currentPosition=Root.Position
	local startPosition=pointPosition(route[1])

	local direction=Vector3.new(
		startPosition.X-currentPosition.X,
		0,
		startPosition.Z-currentPosition.Z
	)

	if direction.Magnitude>0.03 then
		direction=direction.Unit
	end

	return direction
end

local function updateReturnToStart()
	if not returning then
		return false
	end

	if not Root or not Humanoid then
		return false
	end

	local currentPosition=Root.Position
	local startPosition=pointPosition(route[1])

	local delta=Vector3.new(
		startPosition.X-currentPosition.X,
		0,
		startPosition.Z-currentPosition.Z
	)

	local distance=delta.Magnitude

	if distance<=0.8 then
		returning=false
		playbackTime=0
		jumpCursor=1

		if playbackMarker then
			playbackMarker.Position=currentPosition
		end

		return true
	end

	local direction=delta.Unit

	local targetSpeed=16

	if #route>=2 then
		local first=calculatePlaybackState(0)

		if first and first.Speed>1 then
			targetSpeed=first.Speed
		end
	end

	Humanoid.WalkSpeed=math.clamp(
		targetSpeed,
		1,
		64
	)

	Humanoid:Move(
		direction,
		false
	)

	if playbackMarker then
		playbackMarker.Position=currentPosition
	end

	return false
end

local function startPlayback()
	if playing or recording then
		return
	end

	if #route<2 then
		return
	end

	if not refreshCharacter() then
		return
	end

	oldWalkSpeed=Humanoid.WalkSpeed
	oldAutoRotate=Humanoid.AutoRotate

	Humanoid.AutoRotate=oldAutoRotate

	playbackTime=0
	jumpCursor=1
	returning=false

	playing=true

	playbackConnection=
		RunService:BindToRenderStep(
			"VoraZureAutoWalkPlayback",
			Enum.RenderPriority.Character.Value+20,
			function(dt)
				if not playing then
					return
				end

				if not Root
					or not Root.Parent
					or not Humanoid
					or Humanoid.Health<=0 then

					stopPlayback()
					return
				end

				if returning then
					local reached=
						updateReturnToStart()

					if reached then
						local first=
							calculatePlaybackState(
								0
							)

						if first then
							Humanoid.WalkSpeed=math.clamp(
								first.Speed>0
								and first.Speed
								or oldWalkSpeed,
								1,
								64
							)

							Humanoid:Move(
								first.Direction,
								false
							)
						end
					end

					return
				end

				local previousTime=playbackTime

				playbackTime+=math.clamp(
					dt,
					0,
					0.1
				)

				local duration=getDuration()

				if playbackTime>=duration then
					if looping then
						beginReturnToStart()
						return
					end

					local finalState=
						calculatePlaybackState(
							duration
						)

					if finalState then
						local direction=
							finalState.Direction

						if direction.Magnitude>0.03 then
							Humanoid.WalkSpeed=math.clamp(
								finalState.Speed>0
								and finalState.Speed
								or oldWalkSpeed,
								1,
								64
							)

							Humanoid:Move(
								direction,
								false
							)
						end
					end

					stopPlayback()
					return
				end

				processJumpEvents(
					previousTime,
					playbackTime
				)

				local state=
					calculatePlaybackState(
						playbackTime
					)

				if not state then
					stopPlayback()
					return
				end

				local speed=state.Speed

				if speed<0.5 then
					speed=0
				end

				if speed>0 then
					Humanoid.WalkSpeed=math.clamp(
						speed,
						1,
						64
					)
				else
					Humanoid.WalkSpeed=oldWalkSpeed
				end

				if state.Direction.Magnitude>0.03 then
					Humanoid:Move(
						state.Direction,
						false
					)
				else
					Humanoid:Move(
						Vector3.zero,
						false
					)
				end

				if playbackMarker then
					playbackMarker.Position=
						state.Position
				end
			end
		)

	heartbeatConnection=
		RunService.Heartbeat:Connect(
			function()
				if not playing then
					return
				end

				if not returning
					and playbackTime<getDuration() then

					local state=
						calculatePlaybackState(
							playbackTime
						)

					if state
						and state.Direction.Magnitude>0.03 then

						Humanoid:Move(
							state.Direction,
							false
						)
					end
				end
			end
		)
end

local function setLoop(value)
	looping=value==true
end

local function toggleLoop()
	looping=not looping
end

local function clearRoute()
	stopPlayback()
	stopRecording()

	route={}
	jumpEvents={}
	playbackTime=0
	jumpCursor=1

	clearVisuals()
end

local function destroy()
	stopPlayback()
	stopRecording()

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection=nil
	end

	clearVisuals()

	local gui=PlayerGui:FindFirstChild(GUI_NAME)

	if gui then
		gui:Destroy()
	end
end

pcall(function()
	local old=PlayerGui:FindFirstChild(GUI_NAME)

	if old then
		old:Destroy()
	end
end)

local gui=Instance.new("ScreenGui")
gui.Name=GUI_NAME
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999999
gui.Parent=PlayerGui

local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,330,0,64)
panel.Position=UDim2.new(
	0.5,
	-165,
	1,
	-88
)
panel.BackgroundColor3=Color3.fromRGB(14,15,24)
panel.BorderSizePixel=0
panel.Parent=gui
corner(panel,18)
stroke(panel,0.3)

local layout=Instance.new("UIListLayout")
layout.FillDirection=Enum.FillDirection.Horizontal
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
layout.VerticalAlignment=Enum.VerticalAlignment.Center
layout.Padding=UDim.new(0,5)
layout.Parent=panel

local function button(text,callback)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(0,55,0,48)
	b.BackgroundColor3=Color3.fromRGB(24,25,38)
	b.Text=text
	b.TextSize=18
	b.Font=Enum.Font.GothamBold
	b.TextColor3=Color3.fromRGB(245,245,255)
	b.AutoButtonColor=false
	b.Parent=panel
	corner(b,12)

	b.Activated:Connect(
		function()
			task.spawn(callback)
		end
	)

	return b
end

button(
	"●",
	startRecording
)

button(
	"■",
	stopRecording
)

button(
	"▶",
	startPlayback
)

local loopButton

loopButton=button(
	"↻",
	function()
		toggleLoop()

		loopButton.Text=
			looping
			and "↻ ON"
			or "↻"
	end
)

button(
	"✕",
	clearRoute
)

Player.CharacterAdded:Connect(
	function()
		task.wait(0.2)

		if playing then
			stopPlayback()
		end

		refreshCharacter()
	end
)
