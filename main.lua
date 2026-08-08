-- [[ ALDO KNIGHTXORZ AUTO WALK V4.7 - SMOOTH ROUTE LINE ]] --

local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")

local LocalPlayer=Players.LocalPlayer
local Character,RootPart,Humanoid
local stopPlayback

if _G.AldoKnightXorzV3_Cleanup then
	pcall(_G.AldoKnightXorzV3_Cleanup)
end

if _G.AldoKnightXorzV4_Cleanup then
	pcall(_G.AldoKnightXorzV4_Cleanup)
end

local currentConnections={}

_G.AldoKnightXorzV4_Cleanup=function()

	for _,conn in ipairs(currentConnections) do
		if typeof(conn)=="RBXScriptConnection" then
			conn:Disconnect()
		end
	end

	currentConnections={}

	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Playback")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Playback")

	local playerGui=LocalPlayer:WaitForChild("PlayerGui")

	for _,gui in ipairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and (
			gui.Name=="AldoKnightXorzV3Gui"
			or gui.Name=="AldoKnightXorzV4Gui"
			or gui.Name=="AldoKnightXorzV47Gui"
		) then
			gui:Destroy()
		end
	end
end

local function setupCharacter(char)

	if stopPlayback then
		pcall(function()
			stopPlayback(true)
		end)
	end

	Character=char
	RootPart=char:WaitForChild("HumanoidRootPart")
	Humanoid=char:WaitForChild("Humanoid")

	if Humanoid then
		Humanoid.AutoRotate=true
	end
end

if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end

table.insert(
	currentConnections,
	LocalPlayer.CharacterAdded:Connect(setupCharacter)
)

local CFG={
	NodeInterval=0.18,
	MinDistance=0.6,

	LineColor=Color3.fromRGB(0,255,255),
	AccentColor=Color3.fromRGB(170,0,255),

	SaveFileName="ALDO_KNIGHTXORZ_PURE_V4_7.json",

	MaxJumpAirTime=1.35,
	JumpMinAirTime=0.08,

	LineThickness=0.15,

	LookAhead=0.12,
	PositionSmooth=18,
	RotationSmooth=18,
	MaxCorrectionSpeed=100,

	MinPlaybackDistance=0.035,
	HeightTolerance=0.08,

	-- VISUAL LINE ONLY
	SmoothLineSegments=6
}

local state={
	isRecording=false,
	isPlaying=false,
	isPaused=false,
	isAutoWalk=false,

	playbackID=0,

	timeline={},
	visualNodes={},

	lineVisible=true,
	selectedFile=1,
	savedFiles={},

	startTime=0,
	lastJumpState=false,

	movementSpeed=16,
	replayPrecision=true,

	airBuffer={},
	airStartTime=nil,
	inAir=false,
	routeBroken=false,

	lastValidSpeed=16,

	playbackWalkSpeed=16,
	prePlaybackWalkSpeed=16,
	prePlaybackAutoRotate=true,

	lastPlaybackPosition=nil,
	lastPlaybackYaw=nil
}

local function normalizeTimeline(timeline)

	if #timeline==0 then
		return timeline
	end

	local baseTs=timeline[1].Timestamp or 0
	local lastSpeed=16

	for _,node in ipairs(timeline) do

		node.RelativeTimestamp=
			(node.Timestamp or 0)-baseTs

		if type(node.Speed)=="number"
			and node.Speed>1 then

			lastSpeed=node.Speed
		end

		node.Speed=(
			type(node.Speed)=="number"
			and node.Speed>1
		) and node.Speed or lastSpeed

		node.Yaw=
			type(node.Yaw)=="number"
			and node.Yaw
			or 0

		node.Grounded=
			node.Grounded~=false

		node.Jump=
			node.Jump==true
	end

	return timeline
end

local function saveToDisk()

	local exportData={}

	for slot,data in pairs(state.savedFiles) do

		local encodedTimeline={}

		for _,node in ipairs(data.timeline) do

			table.insert(
				encodedTimeline,
				{
					P={
						math.round(node.Position.X*100)/100,
						math.round(node.Position.Y*100)/100,
						math.round(node.Position.Z*100)/100
					},

					T=math.round(
						(node.Timestamp or 0)*1000
					)/1000,

					J=node.Jump or false,

					S=math.round(
						(node.Speed or 16)*100
					)/100,

					Y=math.round(
						(node.Yaw or 0)*10000
					)/10000,

					G=node.Grounded~=false
				}
			)
		end

		exportData[tostring(slot)]={
			timeline=encodedTimeline
		}
	end

	if writefile then
		pcall(function()
			writefile(
				CFG.SaveFileName,
				HttpService:JSONEncode(exportData)
			)
		end)
	end
end

local function loadFromDisk()

	if not readfile then
		return
	end

	local success,result=pcall(function()
		return readfile(CFG.SaveFileName)
	end)

	if not success or not result then
		return
	end

	local successDecode,decoded=pcall(function()
		return HttpService:JSONDecode(result)
	end)

	if not successDecode or type(decoded)~="table" then
		return
	end

	for slot,data in pairs(decoded) do

		if type(data)=="table"
			and type(data.timeline)=="table" then

			local decodedTimeline={}

			for _,node in ipairs(data.timeline) do

				if node.P then

					table.insert(
						decodedTimeline,
						{
							Position=Vector3.new(
								table.unpack(node.P)
							),

							Timestamp=node.T or 0,
							Jump=node.J or false,
							Speed=node.S or 16,
							Yaw=node.Y or 0,
							Grounded=node.G~=false
						}
					)
				end
			end

			state.savedFiles[tonumber(slot)]={
				timeline=normalizeTimeline(
					decodedTimeline
				)
			}
		end
	end
end

loadFromDisk()

local function getOrCreateRouteFolder()

	local folder=
		workspace:FindFirstChild(
			"KNIGHTXORZ_ROUTE"
		)

	if not folder then

		folder=Instance.new("Folder")
		folder.Name="KNIGHTXORZ_ROUTE"
		folder.Parent=workspace
	end

	return folder
end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="AldoKnightXorzV47Gui"
ScreenGui.ResetOnSpawn=false
ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui")

local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.new(0,55,0,55)
OpenMenu.Position=UDim2.new(0.05,0,0.5,0)
OpenMenu.BackgroundTransparency=1
OpenMenu.Image="rbxassetid://101640388423900"
OpenMenu.Parent=ScreenGui

local OpenCorner=Instance.new("UICorner")
OpenCorner.CornerRadius=UDim.new(0,8)
OpenCorner.Parent=OpenMenu

local OpenStroke=Instance.new("UIStroke")
OpenStroke.Thickness=2
OpenStroke.Color=Color3.fromRGB(255,255,255)
OpenStroke.Parent=OpenMenu

local OpenGradient=Instance.new("UIGradient")

OpenGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(
		0,
		Color3.fromRGB(0,255,255)
	),

	ColorSequenceKeypoint.new(
		1,
		Color3.fromRGB(170,0,255)
	)
})

OpenGradient.Rotation=45
OpenGradient.Parent=OpenMenu

task.spawn(function()

	while OpenMenu and OpenMenu.Parent do
		OpenGradient.Rotation+=1
		task.wait(0.03)
	end
end)

local MainFrame=Instance.new("Frame")
MainFrame.Name="MainFrame"
MainFrame.Size=UDim2.new(0,260,0,540)
MainFrame.Position=UDim2.new(0.75,0,0.15,0)
MainFrame.BackgroundColor3=Color3.fromRGB(15,15,20)
MainFrame.BorderSizePixel=0
MainFrame.Active=true
MainFrame.Visible=true
MainFrame.Parent=ScreenGui

local openMoved=false

table.insert(
	currentConnections,
	OpenMenu.InputChanged:Connect(function(input)

		if input.UserInputType==
			Enum.UserInputType.Touch then

			openMoved=true
		end
	end)
)

table.insert(
	currentConnections,
	OpenMenu.MouseButton1Click:Connect(function()

		if openMoved then
			openMoved=false
			return
		end

		MainFrame.Visible=
			not MainFrame.Visible
	end)
)

local openDragging
local openDragStart
local openStartPos

table.insert(
	currentConnections,
	OpenMenu.InputBegan:Connect(function(input)

		if input.UserInputType==
			Enum.UserInputType.MouseButton1
			or input.UserInputType==
			Enum.UserInputType.Touch then

			openDragging=true
			openDragStart=input.Position
			openStartPos=OpenMenu.Position
			openMoved=false

			local changedConn

			changedConn=
				input.Changed:Connect(function()

					if input.UserInputState==
						Enum.UserInputState.End then

						openDragging=false

						if changedConn then
							changedConn:Disconnect()
						end
					end
				end)
		end
	end)
)

table.insert(
	currentConnections,
	UserInputService.InputChanged:Connect(function(input)

		if input.UserInputType==
			Enum.UserInputType.MouseMovement
			or input.UserInputType==
			Enum.UserInputType.Touch then

			if openDragging then

				local delta=
					input.Position-openDragStart

				if delta.Magnitude>5 then
					openMoved=true
				end

				OpenMenu.Position=UDim2.new(
					openStartPos.X.Scale,
					openStartPos.X.Offset+delta.X,

					openStartPos.Y.Scale,
					openStartPos.Y.Offset+delta.Y
				)
			end
		end
	end)
)

local Corner=Instance.new("UICorner")
Corner.CornerRadius=UDim.new(0,12)
Corner.Parent=MainFrame

local Stroke=Instance.new("UIStroke")
Stroke.Thickness=2
Stroke.Color=CFG.AccentColor
Stroke.Parent=MainFrame

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,0,0,35)
Title.Text="ALDO KNIGHTXORZ V4.7"
Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold
Title.TextSize=14
Title.BackgroundTransparency=1
Title.Parent=MainFrame

local StatusLabel=Instance.new("TextLabel")
StatusLabel.Name="StatusLabel"
StatusLabel.Size=UDim2.new(1,0,0,25)
StatusLabel.Position=UDim2.new(0,0,0,35)
StatusLabel.Text="Status: IDLE | File: 1"
StatusLabel.TextColor3=CFG.LineColor
StatusLabel.Font=Enum.Font.GothamBold
StatusLabel.TextSize=12
StatusLabel.BackgroundTransparency=1
StatusLabel.Parent=MainFrame

local ScrollingContainer=Instance.new("ScrollingFrame")
ScrollingContainer.Size=UDim2.new(1,-10,1,-70)
ScrollingContainer.Position=UDim2.new(0,5,0,65)
ScrollingContainer.BackgroundTransparency=1
ScrollingContainer.BorderSizePixel=0
ScrollingContainer.CanvasSize=UDim2.new(0,0,0,800)
ScrollingContainer.ScrollBarThickness=3
ScrollingContainer.Parent=MainFrame

local UIList=Instance.new("UIListLayout")
UIList.Parent=ScrollingContainer
UIList.HorizontalAlignment=
	Enum.HorizontalAlignment.Center
UIList.Padding=UDim.new(0,6)
UIList.SortOrder=
	Enum.SortOrder.LayoutOrder

local function updateStatus(text)

	if not ScreenGui or not ScreenGui.Parent then
		return
	end

	local frame=
		ScreenGui:FindFirstChild("MainFrame")

	if frame then

		local lbl=
			frame:FindFirstChild("StatusLabel")

		if lbl then

			lbl.Text=
				"Status: "
				..text
				.." | File: "
				..state.selectedFile
		end
	end
end

local function createBtn(text,order,callback)

	local btn=Instance.new("TextButton")

	btn.Size=UDim2.new(0,230,0,35)
	btn.BackgroundColor3=Color3.fromRGB(30,30,40)
	btn.Text=text
	btn.TextColor3=Color3.fromRGB(230,230,230)
	btn.Font=Enum.Font.GothamBold
	btn.TextSize=12
	btn.LayoutOrder=order
	btn.Parent=ScrollingContainer

	local btnCorner=Instance.new("UICorner")
	btnCorner.CornerRadius=UDim.new(0,6)
	btnCorner.Parent=btn

	local btnStroke=Instance.new("UIStroke")
	btnStroke.Thickness=1
	btnStroke.Color=Color3.fromRGB(70,70,90)
	btnStroke.Parent=btn

	table.insert(
		currentConnections,
		btn.MouseButton1Click:Connect(function()

			TweenService:Create(
				btn,
				TweenInfo.new(0.15),
				{
					BackgroundColor3=
						CFG.AccentColor
				}
			):Play()

			task.wait(0.15)

			TweenService:Create(
				btn,
				TweenInfo.new(0.15),
				{
					BackgroundColor3=
						Color3.fromRGB(30,30,40)
				}
			):Play()

			callback()
		end)
	)

	return btn
end

----------------------------------------------------------------
-- LINE RENDERER
-- BAGIAN INI SAJA YANG DIUBAH
----------------------------------------------------------------

local function drawLine(p1,p2)

	local dist=(p1-p2).Magnitude

	if dist<0.05 then
		return
	end

	local part=Instance.new("Part")

	part.Size=Vector3.new(
		CFG.LineThickness,
		CFG.LineThickness,
		dist
	)

	part.CFrame=CFrame.lookAt(
		p1:Lerp(p2,0.5),
		p2
	)

	part.Anchored=true
	part.CanCollide=false
	part.CanTouch=false
	part.CanQuery=false
	part.CastShadow=false
	part.Locked=true

	part.Material=Enum.Material.Neon
	part.Color=CFG.LineColor

	part.Transparency=
		state.lineVisible and 0 or 1

	part.Parent=getOrCreateRouteFolder()
	part.Name="VisualNode"

	table.insert(
		state.visualNodes,
		part
	)
end

local function clearVisuals()

	for _,v in pairs(state.visualNodes) do

		if v then
			v:Destroy()
		end
	end

	state.visualNodes={}

	local folder=
		workspace:FindFirstChild(
			"KNIGHTXORZ_ROUTE"
		)

	if folder then
		folder:ClearAllChildren()
	end
end

local function catmullRom(p0,p1,p2,p3,t)

	local t2=t*t
	local t3=t2*t

	return
		p0*(
			-0.5*t3
			+t2
			-0.5*t
		)
		+
		p1*(
			1.5*t3
			-2.5*t2
			+1
		)
		+
		p2*(
			-1.5*t3
			+2*t2
			+0.5*t
		)
		+
		p3*(
			0.5*t3
			-0.5*t2
		)
end

local function drawSmoothSegment(
	p0,
	p1,
	p2,
	p3,
	segments
)

	segments=
		segments
		or CFG.SmoothLineSegments

	local previous=p1

	for i=1,segments do

		local t=i/segments

		local point=
			catmullRom(
				p0,
				p1,
				p2,
				p3,
				t
			)

		drawLine(
			previous,
			point
		)

		previous=point
	end
end

local function redrawSmoothRoute()

	clearVisuals()

	local count=#state.timeline

	if count<2 then
		return
	end

	for i=1,count-1 do

		local p0=
			state.timeline[
				math.max(i-1,1)
			].Position

		local p1=
			state.timeline[i].Position

		local p2=
			state.timeline[
				math.min(i+1,count)
			].Position

		local p3=
			state.timeline[
				math.min(i+2,count)
			].Position

		drawSmoothSegment(
			p0,
			p1,
			p2,
			p3,
			CFG.SmoothLineSegments
		)
	end
end

----------------------------------------------------------------
-- RECORDING DATA
----------------------------------------------------------------

local function makeNode(
	pos,
	timestamp,
	jump,
	grounded,
	speed,
	yaw
)

	return {
		Position=pos,
		Timestamp=timestamp,
		Jump=jump==true,
		Grounded=grounded~=false,
		Speed=speed or 16,
		Yaw=yaw or 0
	}
end

local function commitNode(node,draw)

	if #state.timeline==0 then

		table.insert(
			state.timeline,
			node
		)

		return
	end

	local last=
		state.timeline[#state.timeline]

	if (node.Position-last.Position).Magnitude<0.05 then

		last.Timestamp=node.Timestamp
		last.Speed=node.Speed
		last.Yaw=node.Yaw
		last.Jump=
			last.Jump or node.Jump
		last.Grounded=node.Grounded

		return
	end

	if node.Timestamp<=last.Timestamp then

		node.Timestamp=
			last.Timestamp+0.001
	end

	if draw then

		drawLine(
			last.Position,
			node.Position
		)
	end

	table.insert(
		state.timeline,
		node
	)
end

local function commitAirBuffer()

	if #state.airBuffer==0 then
		return
	end

	for _,node in ipairs(state.airBuffer) do
		commitNode(node,true)
	end

	state.airBuffer={}
end

local function finishLongFall(landingNode)

	state.airBuffer={}
	state.inAir=false
	state.airStartTime=nil
	state.routeBroken=true

	landingNode.Jump=false
	landingNode.Grounded=true

	if #state.timeline==0 then

		commitNode(
			landingNode,
			false
		)

	else

		local last=
			state.timeline[#state.timeline]

		if (
			landingNode.Position-last.Position
		).Magnitude>=CFG.MinDistance then

			table.insert(
				state.timeline,
				landingNode
			)

		else

			last.Timestamp=
				landingNode.Timestamp

			last.Speed=
				landingNode.Speed

			last.Yaw=
				landingNode.Yaw
		end
	end
end

RunService:BindToRenderStep(
	"AldoKnightXorzV4_Record",
	Enum.RenderPriority.Character.Value,
	function()

		if not state.isRecording
			or not RootPart
			or not Humanoid then

			return
		end

		local pos=RootPart.Position
		local st=Humanoid:GetState()
		local vel=
			RootPart.AssemblyLinearVelocity

		local now=
			tick()-state.startTime

		local grounded=
			Humanoid.FloorMaterial~=
				Enum.Material.Air
			and st~=
				Enum.HumanoidStateType.Freefall
			and st~=
				Enum.HumanoidStateType.Jumping

		local air=not grounded

		local jumpNow=
			st==Enum.HumanoidStateType.Jumping
			or (
				vel.Y>1
				and Humanoid.FloorMaterial==
					Enum.Material.Air
			)

		local jumpTrigger=
			jumpNow
			and not state.lastJumpState

		state.lastJumpState=jumpNow

		local speed=
			Humanoid.WalkSpeed

		if speed>1 then
			state.lastValidSpeed=speed
		else
			speed=state.lastValidSpeed
		end

		local _,yaw,_=
			RootPart.CFrame:ToOrientation()

		local node=
			makeNode(
				pos,
				now,
				jumpTrigger,
				grounded,
				speed,
				yaw
			)

		if #state.timeline==0
			and not state.inAir then

			commitNode(
				node,
				false
			)
		end

		if air then

			if not state.inAir then

				state.inAir=true
				state.airStartTime=now
				state.airBuffer={}
			end

			local lastAir=
				state.airBuffer[
					#state.airBuffer
				]

			if not lastAir
				or (
					now-lastAir.Timestamp
						>=CFG.NodeInterval
					and
					(pos-lastAir.Position).Magnitude
						>=CFG.MinDistance
				)
				or jumpTrigger then

				table.insert(
					state.airBuffer,
					node
				)
			end

		else

			if state.inAir then

				local airDuration=
					now-
					(state.airStartTime or now)

				if airDuration<=CFG.MaxJumpAirTime
					and airDuration>=CFG.JumpMinAirTime
					and (
						#state.airBuffer>0
						or jumpTrigger
					) then

					commitAirBuffer()

					commitNode(
						node,
						true
					)

					state.routeBroken=false

				else

					finishLongFall(node)
				end

				state.airBuffer={}
				state.inAir=false
				state.airStartTime=nil

			else

				local last=
					state.timeline[
						#state.timeline
					]

				if not last
					or (
						now-last.Timestamp
							>=CFG.NodeInterval
						and
						(pos-last.Position).Magnitude
							>=CFG.MinDistance
					) then

					if state.routeBroken then

						commitNode(
							node,
							true
						)

						state.routeBroken=false

					else

						commitNode(
							node,
							true
						)
					end
				end
			end
		end
	end
)

----------------------------------------------------------------
-- PLAYBACK
-- TIDAK DIUBAH
----------------------------------------------------------------

stopPlayback=function(manualStop)

	state.isPlaying=false
	state.isPaused=false
	state.playbackID+=1

	if manualStop then
		state.isAutoWalk=false
	end

	RunService:UnbindFromRenderStep(
		"AldoKnightXorzV4_Playback"
	)

	if Humanoid then

		Humanoid.AutoRotate=
			state.prePlaybackAutoRotate~=false

		Humanoid.WalkSpeed=
			state.prePlaybackWalkSpeed
			or state.movementSpeed

		Humanoid:Move(
			Vector3.zero,
			true
		)
	end

	state.lastPlaybackPosition=nil
	state.lastPlaybackYaw=nil

	updateStatus("IDLE")
end

local function getNodeSpeed(a,b)

	local s1=tonumber(a.Speed) or 0
	local s2=tonumber(b.Speed) or 0

	if s1>1 and s2>1 then

		return s1+(s2-s1)*0.5
	end

	if s1>1 then
		return s1
	end

	if s2>1 then
		return s2
	end

	return state.movementSpeed
end

local function getTimelineTarget(
	index,
	currentTime
)

	local count=#state.timeline

	if count<2 then
		return nil
	end

	while index<count
		and currentTime>=
			state.timeline[
				index+1
			].RelativeTimestamp do

		index+=1
	end

	if index>=count then
		return count,index
	end

	local a=
		state.timeline[index]

	local b=
		state.timeline[index+1]

	local t1=
		a.RelativeTimestamp

	local t2=
		b.RelativeTimestamp

	local duration=
		math.max(
			t2-t1,
			0.001
		)

	local alpha=
		math.clamp(
			(currentTime-t1)/duration,
			0,
			1
		)

	return index,a,b,alpha
end

local function getYaw(a,b,alpha)

	local yawA=a.Yaw or 0
	local yawB=b.Yaw or yawA

	local diff=
		math.atan2(
			math.sin(yawB-yawA),
			math.cos(yawB-yawA)
		)

	return yawA+diff*alpha
end

local function applyPlaybackPosition(
	target,
	dt
)

	if not RootPart then
		return
	end

	local current=
		RootPart.Position

	local delta=
		target-current

	local distance=
		delta.Magnitude

	if distance<
		CFG.MinPlaybackDistance then

		return
	end

	local factor=
		1-math.exp(
			-CFG.PositionSmooth*dt
		)

	factor=
		math.clamp(
			factor,
			0,
			1
		)

	local nextPos=
		current:Lerp(
			target,
			factor
		)

	if distance>
		CFG.MaxCorrectionSpeed*dt then

		nextPos=
			current+
			delta.Unit*
			math.min(
				distance,
				CFG.MaxCorrectionSpeed*dt
			)
	end

	RootPart.CFrame=
		CFrame.new(nextPos)
		*(
			RootPart.CFrame-
			RootPart.CFrame.Position
		)
end

local function applyPlaybackRotation(
	yaw,
	dt
)

	if not RootPart then
		return
	end

	local targetCFrame=
		CFrame.new(
			RootPart.Position
		)
		*CFrame.Angles(
			0,
			yaw,
			0
		)

	local factor=
		1-math.exp(
			-CFG.RotationSmooth*dt
		)

	factor=
		math.clamp(
			factor,
			0,
			1
		)

	RootPart.CFrame=
		RootPart.CFrame:Lerp(
			targetCFrame,
			factor
		)
end

local function executePlayback()

	if #state.timeline<2
		or state.isPlaying
		or not RootPart
		or not Humanoid then

		return
	end

	normalizeTimeline(
		state.timeline
	)

	stopPlayback(false)

	state.isPlaying=true
	state.isPaused=false
	state.playbackID+=1

	local currentPlaybackID=
		state.playbackID

	state.prePlaybackWalkSpeed=
		Humanoid.WalkSpeed

	state.prePlaybackAutoRotate=
		Humanoid.AutoRotate

	state.playbackWalkSpeed=
		state.timeline[1].Speed
		or state.movementSpeed

	Humanoid.AutoRotate=false

	Humanoid.WalkSpeed=
		math.max(
			state.playbackWalkSpeed,
			1
		)

	local startPos=
		state.timeline[1].Position

	local playbackState=
		"WALKING_TO_START"

	local playbackStartTime=0
	local pauseOffset=0

	local currentIndex=1

	local timeoutTimer=
		tick()+25

	updateStatus(
		"WALKING TO START"
	)

	RunService:BindToRenderStep(
		"AldoKnightXorzV4_Playback",
		Enum.RenderPriority.Last.Value,
		function(dt)

			if not state.isPlaying
				or state.playbackID
					~=currentPlaybackID
				or not RootPart
				or not Humanoid then

				stopPlayback(false)
				return
			end

			if state.isPaused then

				pauseOffset+=dt

				Humanoid:Move(
					Vector3.zero,
					true
				)

				return
			end

			if playbackState==
				"WALKING_TO_START"
				or playbackState==
				"RETURNING_TO_START" then

				local currentPos=
					RootPart.Position

				local delta=
					startPos-currentPos

				local horizontal=
					Vector3.new(
						delta.X,
						0,
						delta.Z
					)

				local startSpeed=
					state.timeline[1].Speed
					or state.movementSpeed

				Humanoid.WalkSpeed=
					math.max(
						startSpeed,
						1
					)

				if horizontal.Magnitude>0.03 then

					Humanoid:Move(
						horizontal.Unit,
						false
					)

					local targetYaw=
						math.atan2(
							horizontal.X,
							-horizontal.Z
						)

					applyPlaybackRotation(
						targetYaw,
						dt
					)

				else

					Humanoid:Move(
						Vector3.zero,
						true
					)
				end

				applyPlaybackPosition(
					Vector3.new(
						startPos.X,
						currentPos.Y,
						startPos.Z
					),
					dt
				)

				if stateChanged then
					stateChanged=false
					timeoutTimer=tick()+25
				end

				if (
					RootPart.Position-
					startPos
				).Magnitude<=2
					or tick()>timeoutTimer then

					playbackState="PLAYING"

					playbackStartTime=tick()
					pauseOffset=0
					currentIndex=1

					stateChanged=true

					updateStatus(
						state.isAutoWalk
						and "AUTO WALK"
						or "PLAYING"
					)
				end

				return
			end

			if playbackState~="PLAYING" then
				return
			end

			local currentTime=
				tick()
				-playbackStartTime
				-pauseOffset

			local result=
				getTimelineTarget(
					currentIndex,
					currentTime
				)

			if not result then

				stopPlayback(false)
				return
			end

			if result==#state.timeline then

				if state.isAutoWalk then

					playbackState=
						"RETURNING_TO_START"

					stateChanged=true

					startPos=
						state.timeline[1].Position

					updateStatus(
						"WALKING TO START"
					)

				else

					stopPlayback(false)
				end

				return
			end

			currentIndex=result

			local a=
				result and
				state.timeline[currentIndex]

			local b=
				state.timeline[
					currentIndex+1
				]

			if not a or not b then
				return
			end

			local t1=
				a.RelativeTimestamp

			local t2=
				b.RelativeTimestamp

			local duration=
				math.max(
					t2-t1,
					0.001
				)

			local alpha=
				math.clamp(
					(currentTime-t1)/duration,
					0,
					1
				)

			local targetPos=
				a.Position:Lerp(
					b.Position,
					alpha
				)

			local currentPos=
				RootPart.Position

			local horizontal=
				Vector3.new(
					targetPos.X-currentPos.X,
					0,
					targetPos.Z-currentPos.Z
				)

			local speed=
				getNodeSpeed(a,b)

			if speed<1 then
				speed=
					state.lastValidSpeed
			end

			state.lastValidSpeed=speed

			Humanoid.WalkSpeed=
				math.max(
					speed,
					1
				)

			if horizontal.Magnitude>0.015 then

				Humanoid:Move(
					horizontal.Unit,
					false
				)

			else

				local routeDirection=
					Vector3.new(
						b.Position.X-a.Position.X,
						0,
						b.Position.Z-a.Position.Z
					)

				if routeDirection.Magnitude>0.015 then

					Humanoid:Move(
						routeDirection.Unit,
						false
					)

				else

					Humanoid:Move(
						Vector3.zero,
						true
					)
				end
			end

			local yaw=
				getYaw(
					a,
					b,
					alpha
				)

			applyPlaybackRotation(
				yaw,
				dt
			)

			local verticalTarget=
				targetPos.Y

			local verticalDelta=
				verticalTarget-currentPos.Y

			if a.Jump
				and alpha<0.35 then

				Humanoid.Jump=true

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

			elseif b.Jump
				and alpha>0.65 then

				Humanoid.Jump=true

				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)
			end

			applyPlaybackPosition(
				targetPos,
				dt
			)

			if verticalDelta>2
				and not b.Jump
				and a.Grounded then

				Humanoid.Jump=true
			end

			if verticalDelta<-3
				and not a.Grounded
				and not b.Grounded then

				applyPlaybackPosition(
					targetPos,
					dt
				)
			end

			state.lastPlaybackPosition=
				targetPos

			state.lastPlaybackYaw=
				yaw
		end
	)
end

local function toggleAutoWalk()

	if state.isRecording then
		return
	end

	state.isAutoWalk=
		not state.isAutoWalk

	if state.isAutoWalk then

		updateStatus("AUTO WALK")

		if not state.isPlaying then
			executePlayback()
		end

	else

		stopPlayback(true)
	end
end

createBtn(
	"RECORD START / STOP",
	1,
	function()

		state.isRecording=
			not state.isRecording

		if state.isRecording then

			stopPlayback(true)

			state.timeline={}
			state.airBuffer={}
			state.airStartTime=nil
			state.inAir=false
			state.routeBroken=false

			state.lastValidSpeed=
				Humanoid
				and Humanoid.WalkSpeed
				or 16

			state.startTime=tick()
			state.lastJumpState=false

			clearVisuals()

			updateStatus(
				"RECORDING"
			)

		else

			state.airBuffer={}
			state.inAir=false
			state.airStartTime=nil

			normalizeTimeline(
				state.timeline
			)

			-- Hanya visual line yang digambar ulang.
			redrawSmoothRoute()

			updateStatus("IDLE")
		end
	end
)

createBtn(
	"PLAY ROUTE",
	2,
	function()

		if state.isRecording then
			return
		end

		state.isAutoWalk=false

		executePlayback()
	end
)

createBtn(
	"PAUSE / RESUME",
	3,
	function()

		if not state.isPlaying then
			return
		end

		state.isPaused=
			not state.isPaused

		if state.isPaused then

			updateStatus("PAUSED")

		else

			updateStatus(
				state.isAutoWalk
				and "AUTO WALK"
				or "PLAYING"
			)
		end
	end
)

createBtn(
	"AUTO WALK ON / OFF",
	4,
	function()
		toggleAutoWalk()
	end
)

createBtn(
	"STOP PLAYBACK",
	5,
	function()
		stopPlayback(true)
	end
)

for i=1,5 do

	createBtn(
		"SELECT FILE "..i,
		5+i,
		function()

			state.selectedFile=i

			updateStatus("IDLE")
		end
	)
end

createBtn(
	"SAVE FILE",
	11,
	function()

		if #state.timeline>0 then

			normalizeTimeline(
				state.timeline
			)

			state.savedFiles[
				state.selectedFile
			]={
				timeline=state.timeline
			}

			saveToDisk()

			updateStatus(
				"SAVED FILE "
				..state.selectedFile
			)
		end
	end
)

createBtn(
	"LOAD FILE",
	12,
	function()

		local fileData=
			state.savedFiles[
				state.selectedFile
			]

		if fileData
			and fileData.timeline then

			stopPlayback(true)

			state.timeline=
				normalizeTimeline(
					fileData.timeline
				)

			-- VISUAL LINE SAJA
			redrawSmoothRoute()

			updateStatus(
				"LOADED FILE "
				..state.selectedFile
			)
		end
	end
)

createBtn(
	"CLEAR ROUTE",
	13,
	function()

		stopPlayback(true)

		state.timeline={}
		state.airBuffer={}
		state.inAir=false
		state.routeBroken=false

		clearVisuals()

		updateStatus("CLEARED")
	end
)

createBtn(
	"SHOW / HIDE LINE",
	14,
	function()

		state.lineVisible=
			not state.lineVisible

		local folder=
			workspace:FindFirstChild(
				"KNIGHTXORZ_ROUTE"
			)

		if folder then

			for _,part in ipairs(
				folder:GetChildren()
			) do

				if part:IsA("Part") then

					part.Transparency=
						state.lineVisible
						and 0
						or 1
				end
			end
		end
	end
)
