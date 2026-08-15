local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local TextChatService=game:GetService("TextChatService")
local HttpService=game:GetService("HttpService")
local VirtualUser=game:GetService("VirtualUser")

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")

local CONFIG_FILE="VoraZureConfig.json"
local ROUTE_FILE="VoraZureRoutes.json"
local PLAYBACK_BIND="VoraZure_AutoWalk_Playback"

local CONFIG={
	Language="Indonesia",
	Gradient=0,
	AntiAFK=false,
	NaturalAnimation=true,
	AntiJitter=true,
	AntiGlitch=true,
	AntiLag=true,
	AntiOutTrack=true
}

local COLORS={
	Background=Color3.fromRGB(235,240,250),
	Panel=Color3.fromRGB(248,250,255),
	Panel2=Color3.fromRGB(235,240,250),
	Card=Color3.fromRGB(255,255,255),
	Text=Color3.fromRGB(25,30,45),
	SubText=Color3.fromRGB(90,100,120),
	Accent=Color3.fromRGB(65,140,255),
	Accent2=Color3.fromRGB(80,190,255),
	Success=Color3.fromRGB(55,190,110),
	Danger=Color3.fromRGB(235,65,75),
	Warning=Color3.fromRGB(245,165,45)
}

local Character
local Humanoid
local Root

local route={}
local savedRoutes={}

local isRecording=false
local isPlaying=false

local recordConnection
local playbackConnection
local antiAFKConnection
local characterConnection

local recordStart=0
local lastRecordClock=0
local lastRecordPosition=nil
local lastRecordState=nil

local playbackIndex=1
local playbackElapsed=0
local playbackLastPosition=nil
local playbackDirection=Vector3.zero
local playbackJumpCursor=1

local jumpEvents={}
local routeLengths={}
local totalRouteLength=0

local selectedPlayer=nil
local spectating=false

local ScreenGui
local Main
local Gradient
local OpenButton
local Floating
local AutoStatus
local FPSLabel
local PingLabel
local LanguageButton

local menuOpen=true
local menuTween=nil

local dragging=false
local dragMoved=false
local dragStart=nil
local dragStartPosition=nil

local RouteVisualFolder
local RouteCarrier
local StartMarker
local EndMarker
local PlaybackMarker

local RouteVisualPoints={}
local RouteVisualBeams={}

local routeVisualLastPosition=nil
local routeVisualLastClock=0

local LINE_SAMPLE_INTERVAL=0.035
local LINE_MIN_DISTANCE=0.22
local MAX_ROUTE_VISUAL_POINTS=1400
local RECORD_INTERVAL=1/60

-- =========================================================
-- LINE RECOVERY / ANTI STUCK
-- =========================================================

local RECOVERY_DISTANCE=4.5
local RECOVERY_REACH_DISTANCE=0.9
local RECOVERY_STUCK_TIME=0.45
local RECOVERY_SEARCH_BACK=35
local RECOVERY_SEARCH_FORWARD=90

local isRecovering=false
local recoveryStartedAt=0
local recoveryLastPosition=nil
local recoveryStuckTime=0
local recoveryTargetPosition=nil

local function refreshCharacter()
	Character=LocalPlayer.Character

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

local function safeWriteFile(path,data)
	if type(writefile)~="function" then
		return false
	end

	return pcall(function()
		writefile(path,data)
	end)
end

local function safeReadFile(path)
	if type(isfile)~="function"
		or type(readfile)~="function" then
		return nil
	end

	local ok,result=pcall(function()
		if isfile(path) then
			return readfile(path)
		end

		return nil
	end)

	if ok then
		return result
	end

	return nil
end

local function safeDeleteFile(path)
	if type(isfile)~="function"
		or type(delfile)~="function" then
		return
	end

	pcall(function()
		if isfile(path) then
			delfile(path)
		end
	end)
end

local function saveConfig()
	local ok,data=pcall(function()
		return HttpService:JSONEncode(CONFIG)
	end)

	if ok then
		safeWriteFile(CONFIG_FILE,data)
	end
end

local function loadConfig()
	local data=safeReadFile(CONFIG_FILE)

	if not data then
		return
	end

	local ok,decoded=pcall(function()
		return HttpService:JSONDecode(data)
	end)

	if ok and type(decoded)=="table" then
		for key,value in pairs(decoded) do
			if CONFIG[key]~=nil
				and typeof(value)==typeof(CONFIG[key]) then
				CONFIG[key]=value
			end
		end
	end

	CONFIG.Gradient=math.clamp(
		tonumber(CONFIG.Gradient) or 0,
		0,
		4
	)
end

local function saveRoutes()
	local ok,data=pcall(function()
		return HttpService:JSONEncode(savedRoutes)
	end)

	if ok then
		safeWriteFile(ROUTE_FILE,data)
	end
end

local function loadRoutes()
	local data=safeReadFile(ROUTE_FILE)

	if not data then
		return
	end

	local ok,decoded=pcall(function()
		return HttpService:JSONDecode(data)
	end)

	if ok and type(decoded)=="table" then
		savedRoutes=decoded
	end
end

loadConfig()
loadRoutes()

local function tween(object,properties,duration)
	if not object or not object.Parent then
		return nil
	end

	local ok,result=pcall(function()
		return TweenService:Create(
			object,
			TweenInfo.new(
				duration or 0.25,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),
			properties
		)
	end)

	if ok then
		return result
	end

	return nil
end

local function corner(object,radius)
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,radius or 10)
	c.Parent=object
	return c
end

local function stroke(object,transparency)
	local s=Instance.new("UIStroke")
	s.Color=Color3.fromRGB(120,130,155)
	s.Transparency=transparency or 0.65
	s.Thickness=1
	s.Parent=object
	return s
end

local function padding(object,amount)
	local p=Instance.new("UIPadding")

	p.PaddingTop=UDim.new(0,amount)
	p.PaddingBottom=UDim.new(0,amount)
	p.PaddingLeft=UDim.new(0,amount)
	p.PaddingRight=UDim.new(0,amount)

	p.Parent=object

	return p
end

local function vecToTable(v)
	return {
		X=v.X,
		Y=v.Y,
		Z=v.Z
	}
end

local function tableToVec(v)
	if type(v)~="table" then
		return Vector3.zero
	end

	return Vector3.new(
		tonumber(v.X) or 0,
		tonumber(v.Y) or 0,
		tonumber(v.Z) or 0
	)
end

local function getPointPosition(point)
	if type(point)~="table" then
		return Vector3.zero
	end

	return tableToVec(point.Position)
end

local function getPointMove(point)
	if type(point)~="table" then
		return Vector3.zero
	end

	local v=tableToVec(point.MoveDirection)

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

local function getPointLook(point)
	if type(point)~="table" then
		return Vector3.zero
	end

	local v=tableToVec(point.Look)

	local flat=Vector3.new(
		v.X,
		0,
		v.Z
	)

	if flat.Magnitude<0.01 then
		return Vector3.zero
	end

	return flat.Unit
end

local function isJumpPoint(point)
	if type(point)~="table" then
		return false
	end

	return point.Jump==true
		or point.State=="Jumping"
		or point.State=="Freefall"
		or point.State=="FallingDown"
end

local function setAutoStatus(text,color)
	if AutoStatus and AutoStatus.Parent then
		AutoStatus.Text=text
		AutoStatus.TextColor3=color or COLORS.Success
	end
end

local function clearRouteVisuals()
	if RouteVisualFolder then
		RouteVisualFolder:Destroy()
	end

	RouteVisualFolder=nil
	RouteCarrier=nil
	StartMarker=nil
	EndMarker=nil
	PlaybackMarker=nil

	table.clear(RouteVisualPoints)
	table.clear(RouteVisualBeams)

	routeVisualLastPosition=nil
	routeVisualLastClock=0
end

local function createVisualContainer()
	clearRouteVisuals()

	RouteVisualFolder=Instance.new("Folder")
	RouteVisualFolder.Name="VoraZureAutoWalkRoute"
	RouteVisualFolder.Parent=workspace

	RouteCarrier=Instance.new("Part")
	RouteCarrier.Name="RouteCarrier"
	RouteCarrier.Size=Vector3.new(1,1,1)
	RouteCarrier.Transparency=1
	RouteCarrier.Anchored=true
	RouteCarrier.CanCollide=false
	RouteCarrier.CanTouch=false
	RouteCarrier.CanQuery=false
	RouteCarrier.CastShadow=false
	RouteCarrier.CFrame=CFrame.new()
	RouteCarrier.Parent=RouteVisualFolder
end

local function createMarker(name,position,size,color)
	if not RouteVisualFolder then
		createVisualContainer()
	end

	local part=Instance.new("Part")

	part.Name=name
	part.Shape=Enum.PartType.Ball
	part.Size=Vector3.new(size,size,size)
	part.Position=position
	part.Anchored=true
	part.CanCollide=false
	part.CanTouch=false
	part.CanQuery=false
	part.CastShadow=false
	part.Material=Enum.Material.Neon
	part.Color=color
	part.Transparency=0.03
	part.Parent=RouteVisualFolder

	local light=Instance.new("PointLight")
	light.Range=9
	light.Brightness=1.5
	light.Color=color
	light.Parent=part

	return part
end

local function createVisualPoint(position)
	if not RouteVisualFolder
		or not RouteCarrier then
		return
	end

	if #RouteVisualPoints>=MAX_ROUTE_VISUAL_POINTS then
		return
	end

	local attachment=Instance.new("Attachment")

	attachment.Name=
		"RoutePoint_"..
		tostring(#RouteVisualPoints+1)

	attachment.Position=position
	attachment.Parent=RouteCarrier

	RouteVisualPoints[#RouteVisualPoints+1]=attachment

	if #RouteVisualPoints>1 then
		local beam=Instance.new("Beam")

		beam.Name=
			"RouteLine_"..
			tostring(#RouteVisualBeams+1)

		beam.Attachment0=
			RouteVisualPoints[#RouteVisualPoints-1]

		beam.Attachment1=
			attachment

		beam.FaceCamera=true
		beam.LightEmission=1
		beam.LightInfluence=0
		beam.Segments=2
		beam.Width0=0.15
		beam.Width1=0.15
		beam.Transparency=NumberSequence.new(0.08)

		beam.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				COLORS.Accent
			),
			ColorSequenceKeypoint.new(
				1,
				COLORS.Accent2
			)
		})

		beam.Parent=RouteVisualFolder

		RouteVisualBeams[#RouteVisualBeams+1]=beam
	end
end

local function beginRouteVisuals(position)
	createVisualContainer()

	StartMarker=createMarker(
		"START",
		position,
		0.9,
		COLORS.Success
	)

	EndMarker=createMarker(
		"END",
		position,
		0.95,
		COLORS.Danger
	)

	PlaybackMarker=createMarker(
		"PLAYBACK",
		position,
		0.65,
		COLORS.Warning
	)

	PlaybackMarker.Transparency=0.12

	createVisualPoint(position)

	routeVisualLastPosition=position
	routeVisualLastClock=os.clock()
end

local function addRouteVisualPoint(position,force)
	if not RouteVisualFolder then
		beginRouteVisuals(position)
		return
	end

	local now=os.clock()

	if not force then
		if now-routeVisualLastClock<LINE_SAMPLE_INTERVAL then
			return
		end

		if routeVisualLastPosition
			and (
				position-routeVisualLastPosition
			).Magnitude<LINE_MIN_DISTANCE then
			return
		end
	end

	createVisualPoint(position)

	routeVisualLastPosition=position
	routeVisualLastClock=now

	if EndMarker and EndMarker.Parent then
		EndMarker.Position=position
	end
end

local function rebuildRouteVisuals()
	if #route==0 then
		clearRouteVisuals()
		return
	end

	createVisualContainer()

	local first=getPointPosition(route[1])
	local last=getPointPosition(route[#route])

	StartMarker=createMarker(
		"START",
		first,
		0.9,
		COLORS.Success
	)

	EndMarker=createMarker(
		"END",
		last,
		0.95,
		COLORS.Danger
	)

	PlaybackMarker=createMarker(
		"PLAYBACK",
		first,
		0.65,
		COLORS.Warning
	)

	PlaybackMarker.Transparency=0.12

	local step=math.max(
		1,
		math.ceil(
			#route/MAX_ROUTE_VISUAL_POINTS
		)
	)

	local lastIndex=0

	for i=1,#route,step do
		createVisualPoint(
			getPointPosition(route[i])
		)

		lastIndex=i
	end

	if lastIndex~=#route then
		createVisualPoint(
			getPointPosition(route[#route])
		)
	end

	routeVisualLastPosition=last
	routeVisualLastClock=os.clock()
end

local function rebuildRouteLengths()
	table.clear(routeLengths)

	totalRouteLength=0

	if #route==0 then
		return
	end

	routeLengths[1]=0

	for i=2,#route do
		local a=getPointPosition(route[i-1])
		local b=getPointPosition(route[i])

		totalRouteLength+=
			(b-a).Magnitude

		routeLengths[i]=totalRouteLength
	end
end

local function getRouteDuration()
	if #route<2 then
		return 0
	end

	return math.max(
		tonumber(route[#route].Time) or 0,
		0
	)
end

local function getRouteSampleByTime(timeValue)
	if #route<2 then
		return nil
	end

	local duration=getRouteDuration()

	timeValue=math.clamp(
		timeValue,
		0,
		duration
	)

	local low=1
	local high=#route-1
	local index=1

	while low<=high do
		local mid=math.floor(
			(low+high)/2
		)

		local aTime=
			tonumber(route[mid].Time)
			or 0

		local bTime=
			tonumber(route[mid+1].Time)
			or aTime

		if timeValue<aTime then
			high=mid-1
		elseif timeValue>bTime then
			low=mid+1
		else
			index=mid
			break
		end

		index=math.clamp(
			low,
			1,
			#route-1
		)
	end

	local a=route[index]
	local b=route[index+1]

	local aTime=
		tonumber(a.Time)
		or 0

	local bTime=
		tonumber(b.Time)
		or aTime

	local alpha=0

	if bTime>aTime then
		alpha=math.clamp(
			(timeValue-aTime)/
			(bTime-aTime),
			0,
			1
		)
	end

	local position=
		getPointPosition(a):Lerp(
			getPointPosition(b),
			alpha
		)

	local move=
		getPointMove(a):Lerp(
			getPointMove(b),
			alpha
		)

	if move.Magnitude>1 then
		move=move.Unit
	end

	local look=
		getPointLook(a):Lerp(
			getPointLook(b),
			alpha
		)

	if look.Magnitude>0.01 then
		look=look.Unit
	end

	local delta=
		getPointPosition(b)-
		getPointPosition(a)

	local pathDirection=Vector3.new(
		delta.X,
		0,
		delta.Z
	)

	if pathDirection.Magnitude>0.02 then
		pathDirection=pathDirection.Unit
	end

	if move.Magnitude<0.02 then
		move=pathDirection
	end

	return {
		Position=position,
		Move=move,
		Look=look,
		PathDirection=pathDirection,
		Jump=
			isJumpPoint(a)
			or isJumpPoint(b),
		Index=index,
		Alpha=alpha
	}
end

-- =========================================================
-- CARI INDEX TERDEKAT
-- =========================================================

local function getNearestRouteIndex(position,startIndex)
	if #route<2 then
		return 1
	end

	local base=math.clamp(
		startIndex or 1,
		1,
		#route-1
	)

	local minIndex=math.max(
		1,
		base-RECOVERY_SEARCH_BACK
	)

	local maxIndex=math.min(
		#route-1,
		base+RECOVERY_SEARCH_FORWARD
	)

	local bestIndex=base
	local bestDistance=math.huge

	for i=minIndex,maxIndex do
		local p=getPointPosition(route[i])

		local flatTarget=Vector3.new(
			p.X,
			position.Y,
			p.Z
		)

		local flatPosition=Vector3.new(
			position.X,
			position.Y,
			position.Z
		)

		local d=
			(flatTarget-flatPosition).Magnitude

		if d<bestDistance then
			bestDistance=d
			bestIndex=i
		end
	end

	return bestIndex
end

-- =========================================================
-- CARI POSISI TERDEKAT PADA LINE/SEGMENT
-- =========================================================

local function getClosestPointOnSegment(position,a,b)
	local aPos=getPointPosition(a)
	local bPos=getPointPosition(b)

	local flatA=Vector3.new(
		aPos.X,
		position.Y,
		aPos.Z
	)

	local flatB=Vector3.new(
		bPos.X,
		position.Y,
		bPos.Z
	)

	local flatP=Vector3.new(
		position.X,
		position.Y,
		position.Z
	)

	local segment=flatB-flatA
	local lengthSquared=
		segment:Dot(segment)

	local alpha=0

	if lengthSquared>0.0001 then
		alpha=math.clamp(
			(flatP-flatA):Dot(segment)/
			lengthSquared,
			0,
			1
		)
	end

	local closestFlat=
		flatA+
		segment*alpha

	local closestY=
		aPos.Y+
		(bPos.Y-aPos.Y)*alpha

	local closest=Vector3.new(
		closestFlat.X,
		closestY,
		closestFlat.Z
	)

	return closest,alpha
end

local function getNearestRoutePoint(position,startIndex)
	if #route<2 then
		return nil
	end

	local base=math.clamp(
		startIndex or 1,
		1,
		#route-1
	)

	local minIndex=math.max(
		1,
		base-RECOVERY_SEARCH_BACK
	)

	local maxIndex=math.min(
		#route-1,
		base+RECOVERY_SEARCH_FORWARD
	)

	local bestPosition=nil
	local bestIndex=base
	local bestAlpha=0
	local bestDistance=math.huge

	for i=minIndex,maxIndex do
		local a=route[i]
		local b=route[i+1]

		local closest,alpha=
			getClosestPointOnSegment(
				position,
				a,
				b
			)

		local flatDelta=Vector3.new(
			closest.X-position.X,
			0,
			closest.Z-position.Z
		)

		local distance=
			flatDelta.Magnitude

		if distance<bestDistance then
			bestDistance=distance
			bestPosition=closest
			bestIndex=i
			bestAlpha=alpha
		end
	end

	if not bestPosition then
		return nil
	end

	local aTime=
		tonumber(
			route[bestIndex].Time
		) or 0

	local bTime=
		tonumber(
			route[bestIndex+1].Time
		) or aTime

	local routeTime=
		aTime+
		(bTime-aTime)*bestAlpha

	return {
		Position=bestPosition,
		Index=bestIndex,
		Alpha=bestAlpha,
		Time=routeTime,
		Distance=bestDistance
	}
end

local function getRecoveryDirection(position,nearest)
	if not nearest then
		return Vector3.zero
	end

	local delta=Vector3.new(
		nearest.Position.X-position.X,
		0,
		nearest.Position.Z-position.Z
	)

	if delta.Magnitude<0.05 then
		return Vector3.zero
	end

	return delta.Unit
end

local function buildJumpEvents()
	table.clear(jumpEvents)

	if #route==0 then
		return
	end

	for i,point in ipairs(route) do
		if isJumpPoint(point) then
			jumpEvents[#jumpEvents+1]={
				Time=
					tonumber(point.Time)
					or 0,
				Index=i
			}
		end
	end
end

local function triggerJump()
	if not Humanoid
		or Humanoid.Health<=0 then
		return
	end

	local state=Humanoid:GetState()

	if state==Enum.HumanoidStateType.Jumping
		or state==Enum.HumanoidStateType.Freefall
		or state==Enum.HumanoidStateType.FallingDown then
		return
	end

	pcall(function()
		Humanoid.Jump=true
	end)
end

local function processJumpEvents(previousTime,currentTime)
	while playbackJumpCursor<=#jumpEvents do
		local event=
			jumpEvents[playbackJumpCursor]

		local eventTime=
			tonumber(event.Time)
			or 0

		if eventTime>currentTime then
			break
		end

		if eventTime>=previousTime-0.04 then
			triggerJump()
		end

		playbackJumpCursor+=1
	end
end

local function getPlaybackDirection(sample,currentPosition)
	if not sample then
		return Vector3.zero
	end

	local targetDelta=
		Vector3.new(
			sample.Position.X-currentPosition.X,
			0,
			sample.Position.Z-currentPosition.Z
		)

	local targetDirection=Vector3.zero

	if targetDelta.Magnitude>0.03 then
		targetDirection=targetDelta.Unit
	end

	local recorded=sample.Move

	if recorded.Magnitude>0.03 then
		local blend=
			CONFIG.NaturalAnimation
			and 0.34
			or 0.18

		if targetDirection.Magnitude>0.03 then
			targetDirection=
				targetDirection*(1-blend)+
				recorded*blend

			if targetDirection.Magnitude>0.03 then
				targetDirection=targetDirection.Unit
			end
		else
			targetDirection=recorded.Unit
		end
	end

	if sample.PathDirection.Magnitude>0.03 then
		local pathBlend=
			CONFIG.NaturalAnimation
			and 0.24
			or 0.12

		if targetDirection.Magnitude>0.03 then
			targetDirection=
				targetDirection*(1-pathBlend)+
				sample.PathDirection*pathBlend

			if targetDirection.Magnitude>0.03 then
				targetDirection=targetDirection.Unit
			end
		else
			targetDirection=sample.PathDirection
		end
	end

	if CONFIG.AntiOutTrack
		and targetDelta.Magnitude>2 then

		local correction=math.clamp(
			(targetDelta.Magnitude-2)/12,
			0,
			0.6
		)

		targetDirection=
			targetDirection*(1-correction)+
			targetDelta.Unit*correction

		if targetDirection.Magnitude>0.03 then
			targetDirection=targetDirection.Unit
		end
	end

	if targetDirection.Magnitude>0.03 then
		return targetDirection
	end

	return playbackDirection
end

local function stopPlayback()
	if not isPlaying then
		return
	end

	isPlaying=false

	pcall(function()
		RunService:UnbindFromRenderStep(
			PLAYBACK_BIND
		)
	end)

	if playbackConnection then
		playbackConnection:Disconnect()
		playbackConnection=nil
	end

	playbackIndex=1
	playbackElapsed=0
	playbackLastPosition=nil
	playbackDirection=Vector3.zero
	playbackJumpCursor=1

	isRecovering=false
	recoveryStartedAt=0
	recoveryLastPosition=nil
	recoveryStuckTime=0
	recoveryTargetPosition=nil

	if Humanoid and Humanoid.Parent then
		pcall(function()
			Humanoid:Move(
				Vector3.zero,
				false
			)
		end)
	end

	if PlaybackMarker
		and #route>0 then

		PlaybackMarker.Position=
			getPointPosition(route[1])
	end

	setAutoStatus(
		"STATUS : IDLE • "..tostring(#route).." POINTS",
		COLORS.Success
	)
end

local function recordCurrentSample(force)
	if not isRecording then
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
		and now-lastRecordClock<RECORD_INTERVAL then
		return
	end

	lastRecordClock=now

	local elapsed=now-recordStart
	local position=Root.Position
	local move=Humanoid.MoveDirection
	local look=Root.CFrame.LookVector
	local velocity=Root.AssemblyLinearVelocity
	local state=Humanoid:GetState()

	local jump=
		state==Enum.HumanoidStateType.Jumping
		or (
			velocity.Y>5
			and Humanoid.FloorMaterial==Enum.Material.Air
		)

	local last=route[#route]

	if last
		and CONFIG.AntiJitter
		and not force
		and not jump then

		local distance=
			(position-getPointPosition(last)).Magnitude

		local moveChange=
			(move-getPointMove(last)).Magnitude

		local stateChanged=
			state.Name~=last.State

		if distance<0.018
			and moveChange<0.018
			and not stateChanged then
			return
		end
	end

	if jump
		and state==Enum.HumanoidStateType.Jumping
		and lastRecordState~=
			Enum.HumanoidStateType.Jumping then

		jumpEvents[#jumpEvents+1]={
			Time=elapsed,
			Index=#route+1
		}
	end

	lastRecordState=state.Name

	route[#route+1]={
		Time=elapsed,
		Position=vecToTable(position),
		MoveDirection=vecToTable(move),
		Look=vecToTable(look),
		Velocity=vecToTable(velocity),
		State=state.Name,
		Jump=jump
	}

	addRouteVisualPoint(
		position,
		force
	)

	if EndMarker and EndMarker.Parent then
		EndMarker.Position=position
	end
end

local function stopRecording()
	if not isRecording then
		return
	end

	isRecording=false

	if recordConnection then
		recordConnection:Disconnect()
		recordConnection=nil
	end

	if Root
		and Root.Parent
		and Humanoid
		and Humanoid.Health>0 then

		recordCurrentSample(true)
	end

	rebuildRouteLengths()
	buildJumpEvents()

	if EndMarker
		and EndMarker.Parent
		and #route>0 then

		EndMarker.Position=
			getPointPosition(route[#route])
	end

	setAutoStatus(
		"STATUS : RECORD COMPLETE • "..tostring(#route).." POINTS",
		COLORS.Success
	)
end

local function startRecording()
	if isRecording or isPlaying then
		return
	end

	if not refreshCharacter() then
		setAutoStatus(
			"STATUS : CHARACTER NOT READY",
			COLORS.Warning
		)
		return
	end

	route={}
	savedRoutes.Current=nil

	table.clear(routeLengths)
	table.clear(jumpEvents)

	playbackIndex=1
	playbackElapsed=0
	playbackLastPosition=nil
	playbackDirection=Vector3.zero
	playbackJumpCursor=1

	isRecovering=false
	recoveryStartedAt=0
	recoveryLastPosition=nil
	recoveryStuckTime=0
	recoveryTargetPosition=nil

	recordStart=os.clock()
	lastRecordClock=0
	lastRecordPosition=Root.Position
	lastRecordState=Humanoid:GetState().Name

	isRecording=true

	beginRouteVisuals(
		Root.Position
	)

	recordCurrentSample(true)

	recordConnection=
		RunService.Heartbeat:Connect(
			function()
				if not isRecording then
					return
				end

				if not Root
					or not Root.Parent
					or not Humanoid
					or Humanoid.Health<=0 then

					stopRecording()
					return
				end

				recordCurrentSample(false)
			end
		)

	setAutoStatus(
		"STATUS : RECORDING • START LOCKED",
		COLORS.Warning
	)
end

local function initializePlayback()
	if #route<2 then
		return false
	end

	rebuildRouteLengths()

	if totalRouteLength<=0 then
		return false
	end

	buildJumpEvents()

	playbackIndex=1
	playbackElapsed=0
	playbackLastPosition=Root.Position

	playbackDirection=
		getPointMove(route[1])

	if playbackDirection.Magnitude<0.03 then
		playbackDirection=
			getPointLook(route[1])
	end

	if playbackDirection.Magnitude<0.03
		and #route>=2 then

		local delta=
			getPointPosition(route[2])-
			getPointPosition(route[1])

		local flat=Vector3.new(
			delta.X,
			0,
			delta.Z
		)

		if flat.Magnitude>0.03 then
			playbackDirection=flat.Unit
		end
	end

	playbackJumpCursor=1

	isRecovering=false
	recoveryStartedAt=0
	recoveryLastPosition=nil
	recoveryStuckTime=0
	recoveryTargetPosition=nil

	return true
end

local function startPlayback()
	if isPlaying or isRecording then
		return
	end

	if #route<2 then
		setAutoStatus(
			"STATUS : ROUTE TERLALU PENDEK",
			COLORS.Warning
		)
		return
	end

	if not refreshCharacter() then
		setAutoStatus(
			"STATUS : CHARACTER NOT READY",
			COLORS.Warning
		)
		return
	end

	if not initializePlayback() then
		setAutoStatus(
			"STATUS : ROUTE INVALID",
			COLORS.Danger
		)
		return
	end

	if PlaybackMarker then
		PlaybackMarker.Position=
			getPointPosition(route[1])
	end

	isPlaying=true

	setAutoStatus(
		"STATUS : PLAYING • START → END",
		COLORS.Success
	)

	pcall(function()
		RunService:UnbindFromRenderStep(
			PLAYBACK_BIND
		)
	end)

	RunService:BindToRenderStep(
		PLAYBACK_BIND,
		Enum.RenderPriority.Character.Value+30,
		function(dt)
			if not isPlaying then
				return
			end

			if not Root
				or not Root.Parent
				or not Humanoid
				or not Humanoid.Parent
				or Humanoid.Health<=0 then

				stopPlayback()
				return
			end

			local safeDt=math.clamp(
				dt,
				1/240,
				0.1
			)

			local previousElapsed=
				playbackElapsed

			playbackElapsed+=safeDt

			local duration=getRouteDuration()

			if playbackElapsed>=duration then
				local finalPoint=route[#route]
				local finalPosition=
					getPointPosition(finalPoint)

				local currentPosition=Root.Position

				local endVector=Vector3.new(
					finalPosition.X-currentPosition.X,
					0,
					finalPosition.Z-currentPosition.Z
				)

				local endDistance=endVector.Magnitude

				if endDistance>0.10 then
					local endDirection=endVector.Unit

					local endBlend=math.clamp(
						endDistance/3,
						0,
						1
					)

					playbackDirection=endDirection

					pcall(function()
						Humanoid:Move(
							endDirection*endBlend,
							false
						)
					end)

					if PlaybackMarker then
						PlaybackMarker.Position=
							currentPosition:Lerp(
								finalPosition,
								math.clamp(
									1-endDistance/3,
									0,
									1
								)
							)
					end

					playbackElapsed=duration

					return
				end

				pcall(function()
					Humanoid:Move(
						Vector3.zero,
						false
					)
				end)

				if PlaybackMarker then
					PlaybackMarker.Position=
						finalPosition
				end

				stopPlayback()
				return
			end

			processJumpEvents(
				previousElapsed,
				playbackElapsed
			)

			local sample=
				getRouteSampleByTime(
					playbackElapsed
				)

			if not sample then
				stopPlayback()
				return
			end

			playbackIndex=sample.Index

			local currentPosition=Root.Position

			-- =================================================
			-- LINE RECOVERY
			-- =================================================

			local nearestLine=
				getNearestRoutePoint(
					currentPosition,
					playbackIndex
				)

			local lineDistance=
				nearestLine
				and nearestLine.Distance
				or math.huge

			if not isRecovering
				and lineDistance>RECOVERY_DISTANCE then

				isRecovering=true

				recoveryStartedAt=os.clock()
				recoveryLastPosition=currentPosition
				recoveryStuckTime=0

				recoveryTargetPosition=
					nearestLine
					and nearestLine.Position
					or nil

				if nearestLine then
					playbackIndex=
						math.clamp(
							nearestLine.Index,
							1,
							#route-1
						)

					playbackElapsed=
						math.max(
							0,
							tonumber(
								nearestLine.Time
							)
							or playbackElapsed
						)

					playbackDirection=
						getRecoveryDirection(
							currentPosition,
							nearestLine
						)
				end
			end

			-- =================================================
			-- RECOVERY MODE
			-- =================================================

			if isRecovering then
				local recoveryPoint=
					getNearestRoutePoint(
						currentPosition,
						playbackIndex
					)

				if recoveryPoint then
					recoveryTargetPosition=
						recoveryPoint.Position

					local recoveryDirection=
						getRecoveryDirection(
							currentPosition,
							recoveryPoint
						)

					local recoveryDistance=
						recoveryPoint.Distance

					if recoveryDirection.Magnitude>0.03 then
						playbackDirection=
							recoveryDirection
					end

					pcall(function()
						Humanoid:Move(
							playbackDirection,
							false
						)
					end)

					-- Sudah kembali dekat LINE.
					if recoveryDistance<=RECOVERY_REACH_DISTANCE then
						playbackIndex=
							math.clamp(
								recoveryPoint.Index,
								1,
								#route-1
							)

						playbackElapsed=
							math.max(
								0,
								tonumber(
									recoveryPoint.Time
								)
								or playbackElapsed
							)

						playbackDirection=
							getPointMove(
								route[
									playbackIndex
								]
							)

						if playbackDirection.Magnitude<0.03 then
							local nextIndex=
								math.min(
									#route,
									playbackIndex+1
								)

							local nextPosition=
								getPointPosition(
									route[nextIndex]
								)

							local lineDelta=
								Vector3.new(
									nextPosition.X-currentPosition.X,
									0,
									nextPosition.Z-currentPosition.Z
								)

							if lineDelta.Magnitude>0.03 then
								playbackDirection=
									lineDelta.Unit
							end
						end

						recoveryTargetPosition=nil
						recoveryLastPosition=currentPosition
						recoveryStuckTime=0
						isRecovering=false

					else
						if recoveryLastPosition then
							local movedDistance=
								(
									currentPosition-
									recoveryLastPosition
								).Magnitude

							if movedDistance<0.04 then
								recoveryStuckTime+=safeDt
							else
								recoveryStuckTime=0
							end
						end

						recoveryLastPosition=
							currentPosition

						if recoveryStuckTime>=RECOVERY_STUCK_TIME then
							local retry=
								getNearestRoutePoint(
									currentPosition,
									playbackIndex+8
								)

							if retry then
								playbackIndex=
									math.clamp(
										retry.Index,
										1,
										#route-1
									)

								playbackElapsed=
									math.max(
										0,
										tonumber(
											retry.Time
										)
										or playbackElapsed
									)

								recoveryTargetPosition=
									retry.Position

								playbackDirection=
									getRecoveryDirection(
										currentPosition,
										retry
									)
							end

							recoveryStuckTime=0
						end
					end
				end

				-- Marker hanya visual.
				-- Marker TIDAK menjadi target gerakan.
				if PlaybackMarker
					and PlaybackMarker.Parent then

					PlaybackMarker.Position=
						recoveryTargetPosition
						or currentPosition
				end

				if Humanoid.PlatformStand then
					Humanoid.PlatformStand=false
				end

				return
			end

			-- =================================================
			-- NORMAL LINE FOLLOWING
			-- =================================================

			local lookAheadTime=
				CONFIG.NaturalAnimation
				and 0.09
				or 0.045

			if CONFIG.AntiLag
				and safeDt>0.05 then

				lookAheadTime+=0.06
			end

			local futureSample=
				getRouteSampleByTime(
					math.min(
						duration,
						playbackElapsed+
						lookAheadTime
					)
				)

			local targetSample=
				futureSample
				or sample

			local direction=
				getPlaybackDirection(
					targetSample,
					currentPosition
				)

			if direction.Magnitude>0.03 then
				playbackDirection=
					direction.Unit
			end

			pcall(function()
				Humanoid:Move(
					playbackDirection,
					false
				)
			end)

			local state=Humanoid:GetState()

			if sample.Jump
				or (
					targetSample.Position.Y-
					currentPosition.Y>1.35
				) then

				if state~=
					Enum.HumanoidStateType.Jumping
					and state~=
					Enum.HumanoidStateType.Freefall
					and state~=
					Enum.HumanoidStateType.FallingDown then

					if sample.Jump
						or targetSample.Position.Y-
						currentPosition.Y>1.35 then

						triggerJump()
					end
				end
			end

			-- Marker kuning hanya mengikuti posisi visual route.
			-- Tidak digunakan untuk steering.
			if PlaybackMarker
				and PlaybackMarker.Parent then

				PlaybackMarker.Position=
					sample.Position
			end

			local errorVector=Vector3.new(
				sample.Position.X-currentPosition.X,
				0,
				sample.Position.Z-currentPosition.Z
			)

			local errorDistance=
				errorVector.Magnitude

			-- Jika keluar dari line, recovery dimulai.
			if CONFIG.AntiOutTrack
				and errorDistance>RECOVERY_DISTANCE then

				local nearest=
					getNearestRoutePoint(
						currentPosition,
						playbackIndex
					)

				if nearest then
					isRecovering=true

					recoveryStartedAt=os.clock()
					recoveryLastPosition=currentPosition
					recoveryStuckTime=0
					recoveryTargetPosition=
						nearest.Position

					playbackIndex=
						math.clamp(
							nearest.Index,
							1,
							#route-1
						)

					playbackElapsed=
						math.max(
							0,
							tonumber(
								nearest.Time
							)
							or playbackElapsed
						)

					playbackDirection=
						getRecoveryDirection(
							currentPosition,
							nearest
						)
				end
			end

			if Humanoid.PlatformStand then
				Humanoid.PlatformStand=false
			end

			if CONFIG.AntiLag
				and safeDt>0.065 then

				task.defer(
					function()
						if isPlaying
							and not isRecovering
							and Humanoid
							and Humanoid.Parent
							and playbackDirection.Magnitude>0.03 then

							pcall(function()
								Humanoid:Move(
									playbackDirection,
									false
								)
							end)
						end
					end
				)
			end
		end
	)

	playbackConnection=
		RunService.Heartbeat:Connect(
			function()
				if not isPlaying then
					return
				end

				if not Humanoid
					or not Humanoid.Parent
					or Humanoid.Health<=0 then

					stopPlayback()
					return
				end

				if playbackDirection.Magnitude>0.03 then
					pcall(function()
						Humanoid:Move(
							playbackDirection,
							false
						)
					end)
				end
			end
		)
end

local function cutRoute()
	if #route<2 then
		setAutoStatus(
			"STATUS : ROUTE KOSONG",
			COLORS.Warning
		)
		return
	end

	stopRecording()
	stopPlayback()

	local cutIndex=math.clamp(
		playbackIndex+1,
		2,
		#route
	)

	local newRoute={}

	for i=1,cutIndex do
		newRoute[#newRoute+1]=route[i]
	end

	route=newRoute

	rebuildRouteLengths()
	buildJumpEvents()

	playbackIndex=1
	playbackElapsed=0
	playbackJumpCursor=1

	rebuildRouteVisuals()

	setAutoStatus(
		"STATUS : CUT • "..tostring(#route).." POINTS",
		COLORS.Warning
	)
end

local function connectRoute()
	if #route<2 then
		setAutoStatus(
			"STATUS : ROUTE TERLALU PENDEK",
			COLORS.Warning
		)
		return
	end

	stopRecording()
	stopPlayback()

	local first=route[1]
	local last=route[#route]

	local firstPosition=
		getPointPosition(first)

	local lastPosition=
		getPointPosition(last)

	local delta=
		firstPosition-lastPosition

	local horizontalDistance=
		Vector3.new(
			delta.X,
			0,
			delta.Z
		).Magnitude

	if horizontalDistance<0.05 then
		setAutoStatus(
			"STATUS : ROUTE SUDAH TERHUBUNG",
			COLORS.Warning
		)
		return
	end

	rebuildRouteLengths()

	local duration=getRouteDuration()

	local averageSpeed=
		totalRouteLength/
		math.max(
			duration,
			0.1
		)

	route[#route+1]={
		Time=
			duration+
			math.max(
				horizontalDistance/
				math.max(
					averageSpeed,
					1
				),
				0.05
			),

		Position=
			vecToTable(firstPosition),

		MoveDirection=
			first.MoveDirection,

		Look=first.Look,

		Velocity={
			X=0,
			Y=0,
			Z=0
		},

		State="Running",
		Jump=false
	}

	rebuildRouteLengths()
	buildJumpEvents()
	rebuildRouteVisuals()

	setAutoStatus(
		"STATUS : ROUTE CONNECTED • "..tostring(#route).." POINTS",
		COLORS.Success
	)
end

local function saveCurrentRoute()
	if #route<2 then
		setAutoStatus(
			"STATUS : ROUTE KOSONG",
			COLORS.Warning
		)
		return
	end

	rebuildRouteLengths()
	buildJumpEvents()

	savedRoutes.Main={
		Version=2,
		Points=route,
		Jumps=jumpEvents
	}

	saveRoutes()

	setAutoStatus(
		"STATUS : ROUTE SAVED",
		COLORS.Success
	)
end

local function loadCurrentRoute()
	if type(savedRoutes.Main)~="table" then
		setAutoStatus(
			"STATUS : FILE TIDAK DITEMUKAN",
			COLORS.Warning
		)
		return
	end

	stopRecording()
	stopPlayback()

	local points=savedRoutes.Main.Points

	if type(points)~="table" then
		points=savedRoutes.Main
	end

	if type(points)~="table"
		or #points<2 then

		setAutoStatus(
			"STATUS : FILE INVALID",
			COLORS.Danger
		)
		return
	end

	route=points

	if type(savedRoutes.Main.Jumps)=="table" then
		jumpEvents=
			savedRoutes.Main.Jumps
	else
		buildJumpEvents()
	end

	rebuildRouteLengths()

	playbackIndex=1
	playbackElapsed=0
	playbackJumpCursor=1

	rebuildRouteVisuals()

	setAutoStatus(
		"STATUS : ROUTE LOADED • "..tostring(#route).." POINTS",
		COLORS.Success
	)
end

local function removeSavedRoute()
	stopRecording()
	stopPlayback()

	savedRoutes.Main=nil

	safeDeleteFile(ROUTE_FILE)

	route={}
	jumpEvents={}
	routeLengths={}
	totalRouteLength=0

	playbackIndex=1
	playbackElapsed=0
	playbackJumpCursor=1

	clearRouteVisuals()

	setAutoStatus(
		"STATUS : FILE REMOVED",
		COLORS.Danger
	)
end

pcall(function()
	local old=
		PlayerGui:FindFirstChild(
			"VoraZureMobileHub"
		)

	if old then
		old:Destroy()
	end
end)

ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VoraZureMobileHub"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder=999999
ScreenGui.Parent=PlayerGui

Main=Instance.new("Frame")
Main.Name="Main"
Main.Size=UDim2.new(0,390,0,590)
Main.Position=UDim2.new(
	0.5,
	-195,
	0.5,
	-295
)
Main.BackgroundColor3=COLORS.Background
Main.BorderSizePixel=0
Main.ClipsDescendants=true
Main.Parent=ScreenGui

corner(Main,18)
stroke(Main,0.35)

local MainScale=Instance.new("UIScale")
MainScale.Scale=1
MainScale.Parent=Main

Gradient=Instance.new("UIGradient")
Gradient.Rotation=25
Gradient.Parent=Main

local function applyGradient()
	local index=math.clamp(
		tonumber(CONFIG.Gradient) or 0,
		0,
		4
	)

	if index==0 then
		Gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.fromRGB(120,190,255)
			),
			ColorSequenceKeypoint.new(
				0.5,
				Color3.fromRGB(220,245,255)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.fromRGB(190,150,255)
			)
		})
	elseif index==1 then
		Gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.fromRGB(150,220,255)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.fromRGB(110,150,255)
			)
		})
	elseif index==2 then
		Gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.fromRGB(255,150,210)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.fromRGB(175,150,255)
			)
		})
	elseif index==3 then
		Gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.fromRGB(150,245,220)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.fromRGB(140,190,255)
			)
		})
	else
		Gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Color3.fromRGB(255,210,150)
			),
			ColorSequenceKeypoint.new(
				0.5,
				Color3.fromRGB(255,160,190)
			),
			ColorSequenceKeypoint.new(
				1,
				Color3.fromRGB(190,160,255)
			)
		})
	end
end

applyGradient()

task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		if Gradient and Gradient.Parent then
			Gradient.Offset=
				Vector2.new(-1,0)

			local animation=tween(
				Gradient,
				{
					Offset=Vector2.new(1,0)
				},
				4
			)

			if animation then
				animation:Play()
				animation.Completed:Wait()
			else
				task.wait(4)
			end
		else
			task.wait(1)
		end
	end
end)

local TopBar=Instance.new("Frame")
TopBar.Size=UDim2.new(1,0,0,66)
TopBar.BackgroundTransparency=1
TopBar.Parent=Main

local Title=Instance.new("TextLabel")
Title.BackgroundTransparency=1
Title.Position=UDim2.new(0,20,0,8)
Title.Size=UDim2.new(0,220,0,28)
Title.Font=Enum.Font.GothamBold
Title.Text="👑 VORA ZURE"
Title.TextSize=20
Title.TextColor3=COLORS.Text
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=TopBar

local Status=Instance.new("TextLabel")
Status.BackgroundTransparency=1
Status.Position=UDim2.new(0,21,0,36)
Status.Size=UDim2.new(0,180,0,20)
Status.Font=Enum.Font.Gotham
Status.Text="ONLINE • MOBILE"
Status.TextSize=11
Status.TextColor3=COLORS.Success
Status.TextXAlignment=Enum.TextXAlignment.Left
Status.Parent=TopBar

FPSLabel=Instance.new("TextLabel")
FPSLabel.BackgroundTransparency=1
FPSLabel.Position=UDim2.new(1,-170,0,12)
FPSLabel.Size=UDim2.new(0,70,0,20)
FPSLabel.Font=Enum.Font.GothamBold
FPSLabel.Text="FPS --"
FPSLabel.TextSize=12
FPSLabel.TextColor3=COLORS.Text
FPSLabel.Parent=TopBar

PingLabel=Instance.new("TextLabel")
PingLabel.BackgroundTransparency=1
PingLabel.Position=UDim2.new(1,-90,0,12)
PingLabel.Size=UDim2.new(0,70,0,20)
PingLabel.Font=Enum.Font.GothamBold
PingLabel.Text="PING --"
PingLabel.TextSize=12
PingLabel.TextColor3=COLORS.Text
PingLabel.Parent=TopBar

local Avatar=Instance.new("ImageLabel")
Avatar.Size=UDim2.new(0,48,0,48)
Avatar.Position=UDim2.new(0,14,0,75)
Avatar.BackgroundColor3=COLORS.Card
Avatar.BorderSizePixel=0
Avatar.Parent=Main

corner(Avatar,14)

local avatarOK,avatarURL=pcall(function()
	return Players:GetUserThumbnailAsync(
		LocalPlayer.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)
end)

if avatarOK then
	Avatar.Image=avatarURL
end

local DisplayName=Instance.new("TextLabel")
DisplayName.BackgroundTransparency=1
DisplayName.Position=UDim2.new(0,72,0,76)
DisplayName.Size=UDim2.new(0,250,0,24)
DisplayName.Font=Enum.Font.GothamBold
DisplayName.Text=
	"DISPLAY : "..LocalPlayer.DisplayName
DisplayName.TextSize=13
DisplayName.TextColor3=COLORS.Text
DisplayName.TextXAlignment=Enum.TextXAlignment.Left
DisplayName.Parent=Main

local Username=Instance.new("TextLabel")
Username.BackgroundTransparency=1
Username.Position=UDim2.new(0,72,0,100)
Username.Size=UDim2.new(0,250,0,20)
Username.Font=Enum.Font.Gotham
Username.Text=
	"USERNAME : "..LocalPlayer.Name
Username.TextSize=11
Username.TextColor3=COLORS.SubText
Username.TextXAlignment=Enum.TextXAlignment.Left
Username.Parent=Main

local Content=Instance.new("Frame")
Content.Name="Content"
Content.Position=UDim2.new(0,12,0,132)
Content.Size=UDim2.new(1,-24,1,-144)
Content.BackgroundTransparency=1
Content.Parent=Main

local Tabs=Instance.new("Frame")
Tabs.Size=UDim2.new(0,90,1,0)
Tabs.BackgroundColor3=COLORS.Panel
Tabs.BorderSizePixel=0
Tabs.Parent=Content

corner(Tabs,14)

local Pages=Instance.new("Frame")
Pages.Position=UDim2.new(0,100,0,0)
Pages.Size=UDim2.new(1,-100,1,0)
Pages.BackgroundTransparency=1
Pages.Parent=Content

local function createPage(name)
	local page=Instance.new("ScrollingFrame")

	page.Name=name
	page.Size=UDim2.new(1,0,1,0)
	page.BackgroundTransparency=1
	page.BorderSizePixel=0
	page.ScrollBarThickness=3
	page.ScrollBarImageTransparency=0.4
	page.Visible=false
	page.AutomaticCanvasSize=Enum.AutomaticSize.Y
	page.CanvasSize=UDim2.new()
	page.Parent=Pages

	local layout=Instance.new("UIListLayout")
	layout.Padding=UDim.new(0,8)
	layout.SortOrder=Enum.SortOrder.LayoutOrder
	layout.Parent=page

	padding(page,4)

	return page
end

local HomePage=createPage("HOME")
local AutoPage=createPage("AUTO WALK")
local CharacterPage=createPage("CHARACTER")
local ChatPage=createPage("CHAT")
local ProfilePage=createPage("PROFILE")
local SettingsPage=createPage("SETTINGS")

local PagesMap={
	HOME=HomePage,
	["AUTO WALK"]=AutoPage,
	CHARACTER=CharacterPage,
	CHAT=ChatPage,
	PROFILE=ProfilePage,
	SETTINGS=SettingsPage
}

local function createTab(text,icon,order)
	local button=Instance.new("TextButton")

	button.Size=UDim2.new(1,-10,0,42)

	button.Position=UDim2.new(
		0,
		5,
		0,
		(order-1)*47+5
	)

	button.BackgroundColor3=COLORS.Panel
	button.Text=icon.."  "..text
	button.TextSize=10
	button.Font=Enum.Font.GothamBold
	button.TextColor3=COLORS.SubText
	button.AutoButtonColor=false
	button.Parent=Tabs

	corner(button,10)

	return button
end

local TabHome=createTab("HOME","⌂",1)
local TabAuto=createTab("AUTO","◈",2)
local TabCharacter=createTab("CHAR","♙",3)
local TabChat=createTab("CHAT","◉",4)
local TabProfile=createTab("PROFILE","◎",5)
local TabSettings=createTab("SET","⚙",6)

local buttonMap={
	HOME=TabHome,
	["AUTO WALK"]=TabAuto,
	CHARACTER=TabCharacter,
	CHAT=TabChat,
	PROFILE=TabProfile,
	SETTINGS=TabSettings
}

local function switchPage(name)
	local page=PagesMap[name]

	if not page then
		return
	end

	for pageName,currentPage in pairs(PagesMap) do
		currentPage.Visible=
			pageName==name
	end

	for _,child in ipairs(Tabs:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3=COLORS.Panel
			child.TextColor3=COLORS.SubText
		end
	end

	local selected=buttonMap[name]

	if selected then
		selected.BackgroundColor3=COLORS.Accent
		selected.TextColor3=Color3.fromRGB(255,255,255)
	end
end

TabHome.Activated:Connect(function()
	switchPage("HOME")
end)

TabAuto.Activated:Connect(function()
	switchPage("AUTO WALK")
end)

TabCharacter.Activated:Connect(function()
	switchPage("CHARACTER")
end)

TabChat.Activated:Connect(function()
	switchPage("CHAT")
end)

TabProfile.Activated:Connect(function()
	switchPage("PROFILE")
end)

TabSettings.Activated:Connect(function()
	switchPage("SETTINGS")
end)

local function createSection(parent,title,description)
	local frame=Instance.new("Frame")

	frame.Size=UDim2.new(1,-8,0,64)
	frame.BackgroundColor3=COLORS.Panel
	frame.BorderSizePixel=0
	frame.Parent=parent

	corner(frame,12)

	local titleLabel=Instance.new("TextLabel")
	titleLabel.BackgroundTransparency=1
	titleLabel.Position=UDim2.new(0,13,0,8)
	titleLabel.Size=UDim2.new(1,-26,0,22)
	titleLabel.Font=Enum.Font.GothamBold
	titleLabel.Text=title
	titleLabel.TextSize=13
	titleLabel.TextColor3=COLORS.Text
	titleLabel.TextXAlignment=Enum.TextXAlignment.Left
	titleLabel.Parent=frame

	local desc=Instance.new("TextLabel")
	desc.BackgroundTransparency=1
	desc.Position=UDim2.new(0,13,0,31)
	desc.Size=UDim2.new(1,-26,0,20)
	desc.Font=Enum.Font.Gotham
	desc.Text=description or ""
	desc.TextSize=10
	desc.TextColor3=COLORS.SubText
	desc.TextXAlignment=Enum.TextXAlignment.Left
	desc.Parent=frame

	return frame
end

local function createButton(parent,text,callback)
	local button=Instance.new("TextButton")

	button.Size=UDim2.new(1,-8,0,42)
	button.BackgroundColor3=COLORS.Card
	button.Text=text
	button.TextSize=12
	button.Font=Enum.Font.GothamBold
	button.TextColor3=COLORS.Text
	button.AutoButtonColor=false
	button.Parent=parent

	corner(button,10)
	stroke(button,0.75)

	button.MouseEnter:Connect(function()
		local t=tween(
			button,
			{
				BackgroundColor3=COLORS.Accent
			},
			0.15
		)

		if t then
			t:Play()
		end
	end)

	button.MouseLeave:Connect(function()
		local t=tween(
			button,
			{
				BackgroundColor3=COLORS.Card
			},
			0.15
		)

		if t then
			t:Play()
		end
	end)

	button.Activated:Connect(function()
		if callback then
			task.spawn(callback)
		end
	end)

	return button
end

local function createToggle(parent,text,initial,callback)
	local button=Instance.new("TextButton")

	button.Size=UDim2.new(1,-8,0,42)
	button.BackgroundColor3=COLORS.Card
	button.Text=""
	button.AutoButtonColor=false
	button.Parent=parent

	corner(button,10)

	local label=Instance.new("TextLabel")
	label.BackgroundTransparency=1
	label.Position=UDim2.new(0,13,0,0)
	label.Size=UDim2.new(1,-75,1,0)
	label.Font=Enum.Font.GothamBold
	label.Text=text
	label.TextSize=11
	label.TextColor3=COLORS.Text
	label.TextXAlignment=Enum.TextXAlignment.Left
	label.Parent=button

	local state=initial==true

	local indicator=Instance.new("Frame")
	indicator.Size=UDim2.new(0,45,0,23)
	indicator.Position=
		UDim2.new(1,-57,0.5,-11)

	-- OFF = MERAH
	indicator.BackgroundColor3=
		state
		and COLORS.Success
		or COLORS.Danger

	indicator.Parent=button

	corner(indicator,20)

	local dot=Instance.new("Frame")

	dot.Size=UDim2.new(0,17,0,17)

	dot.Position=
		state
		and UDim2.new(1,-20,0.5,-8)
		or UDim2.new(0,3,0.5,-8)

	dot.BackgroundColor3=
		Color3.fromRGB(255,255,255)

	dot.Parent=indicator

	corner(dot,20)

	local function update()
		indicator.BackgroundColor3=
			state
			and COLORS.Success
			or COLORS.Danger

		local target=
			state
			and UDim2.new(1,-20,0.5,-8)
			or UDim2.new(0,3,0.5,-8)

		local t=tween(
			dot,
			{
				Position=target
			},
			0.15
		)

		if t then
			t:Play()
		else
			dot.Position=target
		end

		if callback then
			callback(state)
		end
	end

	button.Activated:Connect(function()
		state=not state
		update()
	end)

	return button
end

createSection(
	HomePage,
	"BERANDA",
	"VORA ZURE • Mobile control center"
)

createButton(
	HomePage,
	"⚡ AUTO WALK",
	function()
		switchPage("AUTO WALK")

		setAutoStatus(
			"STATUS : AUTO WALK READY",
			COLORS.Success
		)
	end
)

createSection(
	HomePage,
	"PLAYER",
	"Informasi pemain aktif"
)

createButton(
	HomePage,
	"👤 "..LocalPlayer.DisplayName,
	function()
		switchPage("PROFILE")
	end
)

createButton(
	HomePage,
	"⚙ CHARACTER",
	function()
		switchPage("CHARACTER")
	end
)

createSection(
	AutoPage,
	"MAIN AUTO WALK",
	"Record, line, START, END dan playback"
)

AutoStatus=Instance.new("TextLabel")
AutoStatus.Size=UDim2.new(1,-8,0,32)
AutoStatus.BackgroundColor3=COLORS.Panel
AutoStatus.Text="STATUS : IDLE"
AutoStatus.Font=Enum.Font.GothamBold
AutoStatus.TextSize=11
AutoStatus.TextColor3=COLORS.Success
AutoStatus.Parent=AutoPage

corner(AutoStatus,10)

createButton(
	AutoPage,
	"● RECORD",
	startRecording
)

createButton(
	AutoPage,
	"■ STOP",
	function()
		stopRecording()
		stopPlayback()
	end
)

createButton(
	AutoPage,
	"▶ PLAY",
	startPlayback
)

createButton(
	AutoPage,
	"✂ CUT ROUTE",
	cutRoute
)

createButton(
	AutoPage,
	"↔ CONNECT ROUTE",
	connectRoute
)

createButton(
	AutoPage,
	"↻ REFRESH PLAY ANIMATION",
	function()
		stopPlayback()

		playbackIndex=1
		playbackElapsed=0
		playbackJumpCursor=1
		playbackDirection=Vector3.zero

		isRecovering=false
		recoveryStartedAt=0
		recoveryLastPosition=nil
		recoveryStuckTime=0
		recoveryTargetPosition=nil

		if PlaybackMarker
			and route[1] then

			PlaybackMarker.Position=
				getPointPosition(route[1])
		end

		setAutoStatus(
			"STATUS : PLAYBACK REFRESHED",
			COLORS.Success
		)
	end
)

createSection(
	AutoPage,
	"FILE",
	"Route persistence"
)

createButton(
	AutoPage,
	"💾 SAVE FILE",
	saveCurrentRoute
)

createButton(
	AutoPage,
	"📂 LOAD FILE",
	loadCurrentRoute
)

createButton(
	AutoPage,
	"🗑 REMOVE FILE",
	removeSavedRoute
)

createSection(
	AutoPage,
	"PLAYBACK PROTECTION",
	"Movement stability"
)

createToggle(
	AutoPage,
	"NATURAL ANIMASI PLAY",
	CONFIG.NaturalAnimation,
	function(v)
		CONFIG.NaturalAnimation=v
		saveConfig()
	end
)

createToggle(
	AutoPage,
	"ANTI JITTER",
	CONFIG.AntiJitter,
	function(v)
		CONFIG.AntiJitter=v
		saveConfig()
	end
)

createToggle(
	AutoPage,
	"ANTI GLITCH",
	CONFIG.AntiGlitch,
	function(v)
		CONFIG.AntiGlitch=v
		saveConfig()
	end
)

createToggle(
	AutoPage,
	"ANTI LAG",
	CONFIG.AntiLag,
	function(v)
		CONFIG.AntiLag=v
		saveConfig()
	end
)

createToggle(
	AutoPage,
	"ANTI OUT TRACK",
	CONFIG.AntiOutTrack,
	function(v)
		CONFIG.AntiOutTrack=v
		saveConfig()
	end
)

Floating=Instance.new("Frame")
Floating.Size=UDim2.new(0,350,0,74)
Floating.Position=
	UDim2.new(
		0.5,
		-175,
		1,
		-94
	)
Floating.BackgroundColor3=COLORS.Panel
Floating.BorderSizePixel=0
Floating.Parent=ScreenGui
Floating.ZIndex=25

corner(Floating,20)
stroke(Floating,0.3)

local floatingLayout=Instance.new("UIListLayout")
floatingLayout.FillDirection=
	Enum.FillDirection.Horizontal
floatingLayout.HorizontalAlignment=
	Enum.HorizontalAlignment.Center
floatingLayout.VerticalAlignment=
	Enum.VerticalAlignment.Center
floatingLayout.Padding=UDim.new(0,5)
floatingLayout.Parent=Floating

local function floatingButton(text,callback)
	local button=Instance.new("TextButton")

	button.Size=UDim2.new(0,46,0,56)
	button.BackgroundColor3=COLORS.Card
	button.Text=text
	button.TextSize=18
	button.Font=Enum.Font.GothamBold
	button.TextColor3=COLORS.Text
	button.AutoButtonColor=false
	button.Parent=Floating
	button.ZIndex=26

	corner(button,12)
	stroke(button,0.7)

	button.Activated:Connect(function()
		if callback then
			task.spawn(callback)
		end
	end)

	return button
end

floatingButton(
	"▶",
	startPlayback
)

floatingButton(
	"●",
	startRecording
)

floatingButton(
	"■",
	function()
		stopRecording()
		stopPlayback()
	end
)

floatingButton(
	"✂",
	cutRoute
)

floatingButton(
	"↔",
	connectRoute
)

floatingButton(
	"‹",
	function()
		if #route==0 then
			return
		end

		playbackIndex=
			math.max(
				1,
				playbackIndex-1
			)

		if route[playbackIndex] then
			playbackElapsed=
				tonumber(
					route[playbackIndex].Time
				)
				or 0

			playbackJumpCursor=1

			if PlaybackMarker then
				PlaybackMarker.Position=
					getPointPosition(
						route[playbackIndex]
					)
			end
		end
	end
)

floatingButton(
	"›",
	function()
		if #route==0 then
			return
		end

		playbackIndex=
			math.min(
				#route,
				playbackIndex+1
			)

		if route[playbackIndex] then
			playbackElapsed=
				tonumber(
					route[playbackIndex].Time
				)
				or 0

			playbackJumpCursor=1

			if PlaybackMarker then
				PlaybackMarker.Position=
					getPointPosition(
						route[playbackIndex]
					)
			end
		end
	end
)

createSection(
	CharacterPage,
	"CHARACTER",
	"Player, spectate dan Anti AFK"
)

createSection(
	CharacterPage,
	"TO PLAYER",
	"Select target player"
)

local PlayerList=Instance.new("Frame")
PlayerList.Size=UDim2.new(1,-8,0,180)
PlayerList.BackgroundColor3=COLORS.Panel
PlayerList.BorderSizePixel=0
PlayerList.Parent=CharacterPage

corner(PlayerList,10)

local PlayerScroll=Instance.new("ScrollingFrame")
PlayerScroll.Size=UDim2.new(1,-10,1,-10)
PlayerScroll.Position=UDim2.new(0,5,0,5)
PlayerScroll.BackgroundTransparency=1
PlayerScroll.BorderSizePixel=0
PlayerScroll.ScrollBarThickness=3
PlayerScroll.AutomaticCanvasSize=
	Enum.AutomaticSize.Y
PlayerScroll.CanvasSize=UDim2.new()
PlayerScroll.Parent=PlayerList

local playerLayout=Instance.new("UIListLayout")
playerLayout.Padding=UDim.new(0,5)
playerLayout.SortOrder=
	Enum.SortOrder.LayoutOrder
playerLayout.Parent=PlayerScroll

local function refreshPlayerList()
	for _,child in ipairs(
		PlayerScroll:GetChildren()
	) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _,player in ipairs(
		Players:GetPlayers()
	) do
		if player~=LocalPlayer then
			local button=Instance.new("TextButton")

			button.Size=
				UDim2.new(1,-5,0,34)

			button.BackgroundColor3=COLORS.Card

			button.Text=
				player.DisplayName
				.."  @"
				..player.Name

			button.TextSize=10
			button.Font=Enum.Font.GothamBold
			button.TextColor3=COLORS.Text
			button.AutoButtonColor=false
			button.Parent=PlayerScroll

			corner(button,8)

			button.Activated:Connect(
				function()
					selectedPlayer=player
				end
			)
		end
	end
end

refreshPlayerList()

Players.PlayerAdded:Connect(
	refreshPlayerList
)

Players.PlayerRemoving:Connect(
	function(player)
		if selectedPlayer==player then
			selectedPlayer=nil
		end

		refreshPlayerList()
	end
)

createButton(
	CharacterPage,
	"↻ REFRESH PLAYER LIST",
	refreshPlayerList
)

createButton(
	CharacterPage,
	"TO SELECTED PLAYER",
	function()
		if not selectedPlayer
			or isPlaying then
			return
		end

		local targetCharacter=
			selectedPlayer.Character

		local targetRoot=
			targetCharacter
			and targetCharacter:FindFirstChild(
				"HumanoidRootPart"
			)

		if targetRoot
			and refreshCharacter() then

			Root.CFrame=
				targetRoot.CFrame*
				CFrame.new(
					0,
					0,
					3
				)
		end
	end
)

createSection(
	CharacterPage,
	"SPECTATE PLAYER",
	"Camera follows selected player"
)

createButton(
	CharacterPage,
	"SPECTATE SELECTED",
	function()
		if not selectedPlayer then
			return
		end

		local targetCharacter=
			selectedPlayer.Character

		local targetHumanoid=
			targetCharacter
			and targetCharacter:FindFirstChildOfClass(
				"Humanoid"
			)

		local camera=workspace.CurrentCamera

		if targetHumanoid and camera then
			camera.CameraSubject=targetHumanoid
			spectating=true
		end
	end
)

createButton(
	CharacterPage,
	"STOP SPECTATE",
	function()
		spectating=false

		refreshCharacter()

		local camera=workspace.CurrentCamera

		if camera and Humanoid then
			camera.CameraSubject=Humanoid
		end
	end
)

local function setAntiAFK(enabled)
	CONFIG.AntiAFK=enabled

	if antiAFKConnection then
		antiAFKConnection:Disconnect()
		antiAFKConnection=nil
	end

	if enabled then
		antiAFKConnection=
			LocalPlayer.Idled:Connect(
				function()
					if not CONFIG.AntiAFK then
						return
					end

					pcall(function()
						VirtualUser:CaptureController()

						VirtualUser:ClickButton2(
							Vector2.new(0,0)
						)
					end)
				end
			)
	end

	saveConfig()
end

createToggle(
	CharacterPage,
	"ANTI AFK",
	CONFIG.AntiAFK,
	setAntiAFK
)

createSection(
	ChatPage,
	"GLOBAL CHAT",
	"Roblox online chat"
)

local ChatBox=Instance.new("ScrollingFrame")
ChatBox.Size=UDim2.new(1,-8,0,250)
ChatBox.BackgroundColor3=COLORS.Panel
ChatBox.BorderSizePixel=0
ChatBox.ScrollBarThickness=3
ChatBox.AutomaticCanvasSize=
	Enum.AutomaticSize.Y
ChatBox.CanvasSize=UDim2.new()
ChatBox.Parent=ChatPage

corner(ChatBox,12)

local ChatLayout=Instance.new("UIListLayout")
ChatLayout.Padding=UDim.new(0,5)
ChatLayout.Parent=ChatBox

local MessageInput=Instance.new("TextBox")
MessageInput.Size=UDim2.new(1,-8,0,42)
MessageInput.BackgroundColor3=COLORS.Card
MessageInput.PlaceholderText="Kirim pesan..."
MessageInput.Text=""
MessageInput.TextSize=11
MessageInput.Font=Enum.Font.Gotham
MessageInput.TextColor3=COLORS.Text
MessageInput.PlaceholderColor3=COLORS.SubText
MessageInput.ClearTextOnFocus=false
MessageInput.Parent=ChatPage

corner(MessageInput,10)

createButton(
	ChatPage,
	"SEND MESSAGE",
	function()
		local message=MessageInput.Text

		if message=="" then
			return
		end

		pcall(function()
			local channels=
				TextChatService:FindFirstChild(
					"TextChannels"
				)

			if not channels then
				return
			end

			local general=
				channels:FindFirstChild(
					"RBXGeneral"
				)

			if general then
				general:SendAsync(message)
				MessageInput.Text=""
			end
		end)
	end
)

createSection(
	ProfilePage,
	"PROFIL",
	"@VORA ZURE"
)

createButton(
	ProfilePage,
	"@VORA ZURE : APA YANG ANDA LAKUKAN?",
	function()
		print(
			"@VORA ZURE > @ALDO : SEDANG BERMAIN"
		)
	end
)

createButton(
	ProfilePage,
	"@ALDO > @VORA ZURE : SEDANG BERMAIN",
	function()
		print(
			"VORA ZURE > ALDO : BERMAIN APA?"
		)
	end
)

createButton(
	ProfilePage,
	"@AZURE > @ALDO : BERMAIN APA?",
	function()
		print(
			"AZURE > ALDO : BERMAIN APA?"
		)
	end
)

createSection(
	SettingsPage,
	"SETTING",
	"Preferensi VORA ZURE"
)

LanguageButton=createButton(
	SettingsPage,
	"BAHASA : "..tostring(CONFIG.Language),
	function()
		CONFIG.Language=
			CONFIG.Language=="Indonesia"
			and "English"
			or "Indonesia"

		LanguageButton.Text=
			"BAHASA : "..tostring(CONFIG.Language)

		saveConfig()
	end
)

createSection(
	SettingsPage,
	"THEMA UI",
	"Animated gradient"
)

local gradientNames={
	"ANIM GRADIENT : DEFAULT",
	"ANIM GRADIENT 1",
	"ANIM GRADIENT 2",
	"ANIM GRADIENT 3",
	"ANIM GRADIENT 4"
}

for index,name in ipairs(
	gradientNames
) do
	createButton(
		SettingsPage,
		name,
		function()
			CONFIG.Gradient=index-1
			applyGradient()
			saveConfig()
		end
	)
end

createSection(
	SettingsPage,
	"SYSTEM",
	"VORA ZURE diagnostics"
)

createButton(
	SettingsPage,
	"REFRESH CHARACTER",
	function()
		refreshCharacter()

		if spectating then
			local camera=workspace.CurrentCamera

			if camera and Humanoid then
				camera.CameraSubject=Humanoid
			end
		end
	end
)

createButton(
	SettingsPage,
	"RESET CONFIG",
	function()
		stopRecording()
		stopPlayback()

		CONFIG.Language="Indonesia"
		CONFIG.Gradient=0
		CONFIG.AntiAFK=false
		CONFIG.NaturalAnimation=true
		CONFIG.AntiJitter=true
		CONFIG.AntiGlitch=true
		CONFIG.AntiLag=true
		CONFIG.AntiOutTrack=true

		setAntiAFK(false)
		applyGradient()

		if LanguageButton then
			LanguageButton.Text=
				"BAHASA : Indonesia"
		end

		saveConfig()

		setAutoStatus(
			"STATUS : CONFIG RESET",
			COLORS.Success
		)
	end
)

OpenButton=Instance.new("TextButton")
OpenButton.Name="OpenButton"
OpenButton.Size=UDim2.new(0,70,0,70)
OpenButton.Position=
	UDim2.new(
		0,
		18,
		0.5,
		-35
	)
OpenButton.BackgroundColor3=COLORS.Accent
OpenButton.Text="👑"
OpenButton.TextSize=29
OpenButton.Font=Enum.Font.GothamBold
OpenButton.TextColor3=
	Color3.fromRGB(255,255,255)
OpenButton.AutoButtonColor=false
OpenButton.Parent=ScreenGui

corner(OpenButton,22)
stroke(OpenButton,0.25)

local function setMenu(state)
	menuOpen=state

	if menuTween then
		pcall(function()
			menuTween:Cancel()
		end)

		menuTween=nil
	end

	if state then
		Main.Visible=true

		Main.Size=
			UDim2.new(
				0,
				390,
				0,
				0
			)

		menuTween=tween(
			Main,
			{
				Size=
					UDim2.new(
						0,
						390,
						0,
						590
					)
			},
			0.25
		)

		if menuTween then
			menuTween:Play()
		else
			Main.Size=
				UDim2.new(
					0,
					390,
					0,
					590
				)
		end
	else
		menuTween=tween(
			Main,
			{
				Size=
					UDim2.new(
						0,
						390,
						0,
						0
					)
			},
			0.2
		)

		if menuTween then
			local active=menuTween

			active.Completed:Connect(
				function()
					if not menuOpen
						and Main
						and Main.Parent then

						Main.Visible=false
					end
				end
			)

			active:Play()
		else
			Main.Visible=false
		end
	end
end

OpenButton.InputBegan:Connect(
	function(input)
		if input.UserInputType==
			Enum.UserInputType.Touch
			or input.UserInputType==
			Enum.UserInputType.MouseButton1 then

			dragging=true
			dragMoved=false
			dragStart=input.Position
			dragStartPosition=
				OpenButton.Position

			input.Changed:Connect(
				function()
					if input.UserInputState==
						Enum.UserInputState.End then

						dragging=false
					end
				end
			)
		end
	end
)

UserInputService.InputChanged:Connect(
	function(input)
		if not dragging then
			return
		end

		if input.UserInputType~=
			Enum.UserInputType.Touch
			and input.UserInputType~=
			Enum.UserInputType.MouseMovement then
			return
		end

		local delta=
			input.Position-
			dragStart

		if delta.Magnitude>8 then
			dragMoved=true
		end

		local camera=workspace.CurrentCamera

		local viewport=
			camera
			and camera.ViewportSize
			or Vector2.new(800,600)

		local size=OpenButton.AbsoluteSize

		local newX=
			dragStartPosition.X.Offset+
			delta.X

		local newY=
			dragStartPosition.Y.Offset+
			delta.Y

		newX=math.clamp(
			newX,
			0,
			math.max(
				0,
				viewport.X-size.X
			)
		)

		newY=math.clamp(
			newY,
			0,
			math.max(
				0,
				viewport.Y-size.Y
			)
		)

		OpenButton.Position=
			UDim2.new(
				0,
				newX,
				0,
				newY
			)
	end
)

OpenButton.Activated:Connect(
	function()
		if dragMoved then
			dragMoved=false
			return
		end

		setMenu(not menuOpen)
	end
)

if characterConnection then
	characterConnection:Disconnect()
	characterConnection=nil
end

characterConnection=
	LocalPlayer.CharacterAdded:Connect(
		function(character)
			if isRecording then
				stopRecording()
			end

			if isPlaying then
				stopPlayback()
			end

			Character=character

			Humanoid=
				character:WaitForChild(
					"Humanoid",
					10
				)

			Root=
				character:WaitForChild(
					"HumanoidRootPart",
					10
				)
		end
	)

local lastFrame=os.clock()
local frameCounter=0

RunService.RenderStepped:Connect(
	function()
		frameCounter+=1

		local now=os.clock()

		if now-lastFrame>=1 then
			FPSLabel.Text=
				"FPS "..tostring(frameCounter)

			frameCounter=0
			lastFrame=now

			local ping=0

			pcall(function()
				ping=math.floor(
					LocalPlayer:GetNetworkPing()*1000
				)
			end)

			PingLabel.Text=
				"PING "..tostring(ping)
		end
	end
)

RunService.Heartbeat:Connect(
	function()
		if not Character
			or not Character.Parent
			or not Humanoid
			or not Root
			or not Root.Parent then
			return
		end

		if not isPlaying
			and CONFIG.AntiGlitch
			and Root.Position.Y<-500 then

			Root.AssemblyLinearVelocity=
				Vector3.zero

			Root.CFrame=
				CFrame.new(
					Root.Position.X,
					10,
					Root.Position.Z
				)
		end

		if not isPlaying
			and Humanoid.PlatformStand then

			Humanoid.PlatformStand=false
		end
	end
)

if CONFIG.AntiAFK then
	setAntiAFK(true)
end

if #route>=2 then
	rebuildRouteLengths()
	buildJumpEvents()
	rebuildRouteVisuals()
end

switchPage("HOME")
setMenu(true)
