-- [[ ALDO KNIGHTXORZ AUTO WALK ]] --

local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")

local LocalPlayer=Players.LocalPlayer
local Character,RootPart,Humanoid
local stopPlayback

if _G.AldoKnightXorzV3_Cleanup then pcall(_G.AldoKnightXorzV3_Cleanup) end
if _G.AldoKnightXorzV4_Cleanup then pcall(_G.AldoKnightXorzV4_Cleanup) end

local currentConnections={}

_G.AldoKnightXorzV4_Cleanup=function()
	for _,c in ipairs(currentConnections) do
		if typeof(c)=="RBXScriptConnection" then
			c:Disconnect()
		end
	end

	currentConnections={}

	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Playback")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Playback")

	local pg=LocalPlayer:WaitForChild("PlayerGui")

	for _,gui in ipairs(pg:GetChildren()) do
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
	Humanoid.AutoRotate=true
end

if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end

table.insert(currentConnections,LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG={
	NodeInterval=0.12,
	MinDistance=0.35,

	FallTime=0.65,
	FallVerticalSpeed=-12,

	LineColor=Color3.fromRGB(0,255,255),
	AccentColor=Color3.fromRGB(170,0,255),

	PositionSmooth=22,
	RotationSmooth=22,

	SaveFileName="ALDO_KNIGHTXORZ_PURE_V4_7.json"
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
	lastGrounded=true,

	airStartTime=nil,
	airStartPosition=nil,
	airNodes={},

	lastValidNode=nil,

	movementSpeed=16,
	replayPrecision=true
}

local function normalizeTimeline(timeline)
	if #timeline==0 then
		return timeline
	end

	local base=timeline[1].Timestamp or 0

	for _,node in ipairs(timeline) do
		node.RelativeTimestamp=(node.Timestamp or 0)-base
		node.Yaw=node.Yaw or 0
		node.Phase=node.Phase or "Ground"
		node.VerticalVelocity=node.VerticalVelocity or 0
		node.Jump=node.Jump or false
	end

	return timeline
end

local function saveToDisk()
	local exportData={}

	for slot,data in pairs(state.savedFiles) do
		local encodedTimeline={}

		for _,node in ipairs(data.timeline) do
			encodedTimeline[#encodedTimeline+1]={
				P={
					math.round(node.Position.X*100)/100,
					math.round(node.Position.Y*100)/100,
					math.round(node.Position.Z*100)/100
				},
				T=math.round((node.Timestamp or 0)*1000)/1000,
				J=node.Jump or false,
				R=node.Yaw or 0,
				V=math.round((node.VerticalVelocity or 0)*100)/100,
				S=node.Phase or "Ground"
			}
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

	local ok,result=pcall(function()
		return readfile(CFG.SaveFileName)
	end)

	if not ok or not result then
		return
	end

	local okDecode,decoded=pcall(function()
		return HttpService:JSONDecode(result)
	end)

	if not okDecode or type(decoded)~="table" then
		return
	end

	for slot,data in pairs(decoded) do
		if type(data)=="table" and type(data.timeline)=="table" then
			local timeline={}

			for _,node in ipairs(data.timeline) do
				if node.P then
					timeline[#timeline+1]={
						Position=Vector3.new(unpack(node.P)),
						Timestamp=tonumber(node.T) or 0,
						Jump=node.J or false,
						Yaw=tonumber(node.R) or 0,
						VerticalVelocity=tonumber(node.V) or 0,
						Phase=node.S or "Ground"
					}
				end
			end

			state.savedFiles[tonumber(slot)]={
				timeline=normalizeTimeline(timeline)
			}
		end
	end
end

loadFromDisk()

local function getOrCreateRouteFolder()
	local folder=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

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
	ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(170,0,255))
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

local Corner=Instance.new("UICorner")
Corner.CornerRadius=UDim.new(0,12)
Corner.Parent=MainFrame

local Stroke=Instance.new("UIStroke")
Stroke.Thickness=2
Stroke.Color=CFG.AccentColor
Stroke.Parent=MainFrame

local openMoved=false
local openDragging=false
local openDragStart
local openStartPos

table.insert(currentConnections,OpenMenu.MouseButton1Click:Connect(function()
	if openMoved then
		openMoved=false
		return
	end

	MainFrame.Visible=not MainFrame.Visible
end))

table.insert(currentConnections,OpenMenu.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1
		or input.UserInputType==Enum.UserInputType.Touch then

		openDragging=true
		openDragStart=input.Position
		openStartPos=OpenMenu.Position
		openMoved=false

		local changed
		changed=input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then
				openDragging=false

				if changed then
					changed:Disconnect()
				end
			end
		end)
	end
end))

table.insert(currentConnections,UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement
		or input.UserInputType==Enum.UserInputType.Touch then

		if openDragging then
			local delta=input.Position-openDragStart

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
end))

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
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Center
UIList.Padding=UDim.new(0,6)
UIList.SortOrder=Enum.SortOrder.LayoutOrder

local function updateStatus(text)
	if not ScreenGui or not ScreenGui.Parent then
		return
	end

	local label=MainFrame:FindFirstChild("StatusLabel")

	if label then
		label.Text="Status: "..text.." | File: "..state.selectedFile
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

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,6)
	c.Parent=btn

	local s=Instance.new("UIStroke")
	s.Thickness=1
	s.Color=Color3.fromRGB(70,70,90)
	s.Parent=btn

	table.insert(currentConnections,btn.MouseButton1Click:Connect(function()
		TweenService:Create(
			btn,
			TweenInfo.new(0.12),
			{BackgroundColor3=CFG.AccentColor}
		):Play()

		task.wait(0.12)

		TweenService:Create(
			btn,
			TweenInfo.new(0.12),
			{BackgroundColor3=Color3.fromRGB(30,30,40)}
		):Play()

		callback()
	end))

	return btn
end

local function drawLine(p1,p2)
	local dist=(p1-p2).Magnitude

	if dist<0.1 then
		return
	end

	local part=Instance.new("Part")
	part.Name="VisualNode"
	part.Size=Vector3.new(0.15,0.15,dist)
	part.CFrame=CFrame.new(
		p1:Lerp(p2,0.5),
		p2
	)
	part.Anchored=true
	part.CanCollide=false
	part.CanQuery=false
	part.CastShadow=false
	part.Locked=true
	part.Material=Enum.Material.Neon
	part.Color=CFG.LineColor
	part.Transparency=state.lineVisible and 0 or 1
	part.Parent=getOrCreateRouteFolder()

	state.visualNodes[#state.visualNodes+1]=part
end

local function rebuildVisuals()
	clearVisuals()

	for i=2,#state.timeline do
		drawLine(
			state.timeline[i-1].Position,
			state.timeline[i].Position
		)
	end
end

function clearVisuals()
	for _,part in ipairs(state.visualNodes) do
		if part then
			part:Destroy()
		end
	end

	state.visualNodes={}

	local folder=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

	if folder then
		folder:ClearAllChildren()
	end
end

local function getPhase()
	if not Humanoid or not RootPart then
		return "Ground"
	end

	local humanoidState=Humanoid:GetState()
	local velocityY=RootPart.AssemblyLinearVelocity.Y

	if humanoidState==Enum.HumanoidStateType.Jumping then
		return "Jump"
	end

	if humanoidState==Enum.HumanoidStateType.Freefall then
		if velocityY>=0 then
			return "Jump"
		end

		return "Fall"
	end

	if Humanoid.FloorMaterial==Enum.Material.Air then
		if velocityY>=0 then
			return "Jump"
		end

		return "Fall"
	end

	return "Ground"
end

local function getYaw()
	if not RootPart then
		return 0
	end

	local _,yaw,_=RootPart.CFrame:ToOrientation()

	return yaw
end

local function removeAirNodes()
	if #state.airNodes==0 then
		return
	end

	local removeSet={}

	for _,node in ipairs(state.airNodes) do
		removeSet[node]=true
	end

	local newTimeline={}

	for _,node in ipairs(state.timeline) do
		if not removeSet[node] then
			newTimeline[#newTimeline+1]=node
		end
	end

	state.timeline=newTimeline
	state.airNodes={}

	rebuildVisuals()

	state.lastValidNode=state.timeline[#state.timeline]
end

local function appendNode(pos,timestamp,jump,phase,velocity,yaw)
	local node={
		Position=pos,
		Timestamp=timestamp,
		Jump=jump or false,
		Phase=phase or "Ground",
		VerticalVelocity=velocity or 0,
		Yaw=yaw or 0
	}

	state.timeline[#state.timeline+1]=node

	return node
end

local function recordNode(pos,now,jump,phase,velocity,yaw,isAir)
	local last=state.timeline[#state.timeline]

	if not last then
		local node=appendNode(
			pos,
			now,
			jump,
			phase,
			velocity,
			yaw
		)

		state.lastValidNode=node

		if isAir then
			state.airNodes={node}
		end

		return
	end

	local distance=(pos-last.Position).Magnitude
	local timeDiff=now-last.Timestamp

	if jump or
		phase~=last.Phase or
		timeDiff>=CFG.NodeInterval or
		distance>=CFG.MinDistance then

		local node=appendNode(
			pos,
			now,
			jump,
			phase,
			velocity,
			yaw
		)

		if isAir then
			state.airNodes[#state.airNodes+1]=node
		end

		if phase=="Ground" then
			state.lastValidNode=node
		end

		drawLine(last.Position,node.Position)
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

		local now=tick()-state.startTime
		local pos=RootPart.Position
		local velocity=RootPart.AssemblyLinearVelocity
		local phase=getPhase()
		local grounded=Humanoid.FloorMaterial~=Enum.Material.Air

		if grounded then
			if state.airStartTime then
				local airDuration=now-state.airStartTime

				if airDuration>CFG.FallTime
					and state.lastValidNode then

					removeAirNodes()
				end

				state.airStartTime=nil
				state.airStartPosition=nil
				state.airNodes={}
			end
		else
			if not state.airStartTime then
				state.airStartTime=now
				state.airStartPosition=pos
				state.airNodes={}
			end
		end

		local jumpTrigger=false

		if not grounded
			and state.lastGrounded
			and phase=="Jump" then

			jumpTrigger=true
		end

		state.lastGrounded=grounded

		local isAir=not grounded

		if not grounded
			and state.airStartTime
			and now-state.airStartTime>CFG.FallTime
			and velocity.Y<CFG.FallVerticalSpeed then

			return
		end

		recordNode(
			pos,
			now,
			jumpTrigger,
			phase,
			velocity.Y,
			getYaw(),
			isAir
		)
	end
)

local function lerpAngle(a,b,t)
	local diff=(b-a+math.pi)%(math.pi*2)-math.pi

	return a+diff*t
end

local function smoothVector(current,target,speed,dt)
	local alpha=1-math.exp(-speed*dt)

	return current:Lerp(target,alpha)
end

local function moveTowardsRoute(pos,target)
	local direction=target-pos

	local horizontal=Vector3.new(
		direction.X,
		0,
		direction.Z
	)

	if horizontal.Magnitude>0.01 then
		Humanoid:Move(horizontal.Unit,false)
	else
		Humanoid:Move(Vector3.zero,false)
	end
end

stopPlayback=function(manualStop)
	state.isPlaying=false
	state.isPaused=false
	state.playbackID+=1

	if manualStop then
		state.isAutoWalk=false
	end

	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Playback")

	if Humanoid then
		Humanoid.AutoRotate=true
		Humanoid:Move(Vector3.zero,false)
	end

	updateStatus("IDLE")
end

local function executePlayback()
	if #state.timeline<2
		or state.isPlaying
		or not RootPart
		or not Humanoid then
		return
	end

	normalizeTimeline(state.timeline)

	state.isPlaying=false
	state.playbackID+=1

	local playbackID=state.playbackID

	state.isPlaying=true
	state.isPaused=false

	local index=1
	local routePosition=RootPart.Position
	local routeYaw=state.timeline[1].Yaw or 0

	local jumpIndex=-1
	local playDistance=0

	local connection

	Humanoid.AutoRotate=false
	Humanoid.WalkSpeed=state.movementSpeed

	updateStatus("PLAYING")

	connection=RunService.Heartbeat:Connect(function(dt)
		if not state.isPlaying
			or state.playbackID~=playbackID
			or not RootPart
			or not Humanoid then

			if connection then
				connection:Disconnect()
			end

			return
		end

		if state.isPaused then
			Humanoid:Move(Vector3.zero,false)
			return
		end

		local count=#state.timeline

		if count<2 then
			stopPlayback(false)

			if connection then
				connection:Disconnect()
			end

			return
		end

		while index<count do
			local a=state.timeline[index]
			local b=state.timeline[index+1]

			local segment=(b.Position-a.Position).Magnitude

			if segment<0.01 then
				index+=1
			else
				break
			end
		end

		if index>=count then
			if state.isAutoWalk then
				index=1
				routePosition=state.timeline[1].Position
				routeYaw=state.timeline[1].Yaw or routeYaw
				jumpIndex=-1
				playDistance=0
				updateStatus("AUTO WALK")
			else
				stopPlayback(false)

				if connection then
					connection:Disconnect()
				end

				return
			end
		end

		local a=state.timeline[index]
		local b=state.timeline[index+1]

		local segmentVector=b.Position-a.Position
		local segmentLength=segmentVector.Magnitude

		if segmentLength<0.01 then
			index+=1
			return
		end

		local direction=segmentVector.Unit

		local speedDistance=state.movementSpeed*dt

		local currentDistance=(routePosition-a.Position):Dot(direction)

		local desiredDistance=currentDistance+speedDistance

		local alpha=math.clamp(
			desiredDistance/segmentLength,
			0,
			1
		)

		local target=a.Position:Lerp(
			b.Position,
			alpha
		)

		routePosition=smoothVector(
			routePosition,
			target,
			CFG.PositionSmooth,
			dt
		)

		local yawA=a.Yaw or routeYaw
		local yawB=b.Yaw or yawA

		routeYaw=lerpAngle(
			yawA,
			yawB,
			alpha
		)

		moveTowardsRoute(
			RootPart.Position,
			routePosition
		)

		local currentPhase=a.Phase or "Ground"

		if a.Jump and jumpIndex~=index then
			Humanoid.Jump=true
			Humanoid:ChangeState(
				Enum.HumanoidStateType.Jumping
			)

			jumpIndex=index
		end

		if currentPhase=="Jump" then
			Humanoid.Jump=false
		elseif currentPhase=="Fall" then
			Humanoid.Jump=false
		end

		local rotationAlpha=1-math.exp(
			-CFG.RotationSmooth*dt
		)

		local currentCF=RootPart.CFrame

		local targetCF=
			CFrame.new(routePosition)*
			CFrame.Angles(0,routeYaw,0)

		RootPart.CFrame=currentCF:Lerp(
			targetCF,
			rotationAlpha
		)

		if alpha>=0.999 then
			index+=1
			playDistance=0
		end
	end)

	table.insert(currentConnections,connection)
end

local function toggleAutoWalk()
	if state.isRecording then
		return
	end

	state.isAutoWalk=not state.isAutoWalk

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
		state.isRecording=not state.isRecording

		if state.isRecording then
			stopPlayback(true)

			state.timeline={}
			state.airNodes={}
			state.lastValidNode=nil
			state.airStartTime=nil
			state.airStartPosition=nil
			state.lastJumpState=false
			state.lastGrounded=true
			state.startTime=tick()

			clearVisuals()

			updateStatus("RECORDING")
		else
			normalizeTimeline(state.timeline)

			state.airNodes={}

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

		state.isPaused=not state.isPaused

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
			normalizeTimeline(state.timeline)

			state.savedFiles[state.selectedFile]={
				timeline=state.timeline
			}

			saveToDisk()

			updateStatus(
				"SAVED FILE "..state.selectedFile
			)
		end
	end
)

createBtn(
	"LOAD FILE",
	12,
	function()
		local fileData=
			state.savedFiles[state.selectedFile]

		if fileData and fileData.timeline then
			stopPlayback(true)

			state.timeline=
				normalizeTimeline(fileData.timeline)

			rebuildVisuals()

			updateStatus(
				"LOADED FILE "..state.selectedFile
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
		state.airNodes={}
		state.lastValidNode=nil

		clearVisuals()

		updateStatus("CLEARED")
	end
)

createBtn(
	"SHOW / HIDE LINE",
	14,
	function()
		state.lineVisible=not state.lineVisible

		local folder=
			workspace:FindFirstChild(
				"KNIGHTXORZ_ROUTE"
			)

		if folder then
			for _,part in ipairs(folder:GetChildren()) do
				if part:IsA("Part") then
					part.Transparency=
						state.lineVisible and 0 or 1
				end
			end
		end
	end
)
