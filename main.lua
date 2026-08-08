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
		if gui:IsA("ScreenGui") then
			if gui.Name=="AldoKnightXorzV3Gui"
			or gui.Name=="AldoKnightXorzV4Gui"
			or gui.Name=="AldoKnightXorzV47Gui" then
				gui:Destroy()
			end
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

table.insert(currentConnections,LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG={
	NodeInterval=0.10,
	MinDistance=0.35,

	FallTime=0.75,
	FallSpeed=-14,

	LineColor=Color3.fromRGB(0,255,255),
	AccentColor=Color3.fromRGB(170,0,255),

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
	airNodes={},
	lastValidIndex=1,

	movementSpeed=16,
	replayPrecision=true
}

local function normalizeTimeline(timeline)
	if #timeline==0 then
		return timeline
	end

	local baseTs=timeline[1].Timestamp or 0

	for _,node in ipairs(timeline) do
		node.RelativeTimestamp=(node.Timestamp or 0)-baseTs
		node.Yaw=node.Yaw or 0
		node.Speed=node.Speed or 0
		node.VerticalVelocity=node.VerticalVelocity or 0
		node.Jump=node.Jump or false
		node.Phase=node.Phase or "Ground"
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
				V=node.VerticalVelocity or 0,
				S=node.Speed or 0,
				PHS=node.Phase or "Ground"
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
		if type(data)=="table" and type(data.timeline)=="table" then
			local decodedTimeline={}

			for _,node in ipairs(data.timeline) do
				if node.P then
					decodedTimeline[#decodedTimeline+1]={
						Position=Vector3.new(unpack(node.P)),
						Timestamp=tonumber(node.T) or 0,
						Jump=node.J or false,
						Yaw=tonumber(node.R) or 0,
						VerticalVelocity=tonumber(node.V) or 0,
						Speed=tonumber(node.S) or 0,
						Phase=node.PHS or "Ground"
					}
				end
			end

			state.savedFiles[tonumber(slot)]={
				timeline=normalizeTimeline(decodedTimeline)
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

		local changedConn
		changedConn=input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then
				openDragging=false

				if changedConn then
					changedConn:Disconnect()
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

	local frame=ScreenGui:FindFirstChild("MainFrame")

	if frame then
		local lbl=frame:FindFirstChild("StatusLabel")

		if lbl then
			lbl.Text="Status: "..text.." | File: "..state.selectedFile
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

	table.insert(currentConnections,btn.MouseButton1Click:Connect(function()
		TweenService:Create(
			btn,
			TweenInfo.new(0.15),
			{BackgroundColor3=CFG.AccentColor}
		):Play()

		task.wait(0.15)

		TweenService:Create(
			btn,
			TweenInfo.new(0.15),
			{BackgroundColor3=Color3.fromRGB(30,30,40)}
		):Play()

		callback()
	end))

	return btn
end

local function drawLine(p1,p2)
	local dist=(p1-p2).Magnitude

	if dist<0.15 then
		return
	end

	local part=Instance.new("Part")
	part.Size=Vector3.new(0.15,0.15,dist)
	part.CFrame=CFrame.new(p1:Lerp(p2,0.5),p2)
	part.Anchored=true
	part.CanCollide=false
	part.CanQuery=false
	part.CastShadow=false
	part.Locked=true
	part.Material=Enum.Material.Neon
	part.Color=CFG.LineColor
	part.Parent=getOrCreateRouteFolder()
	part.Name="VisualNode"
	part.Transparency=state.lineVisible and 0 or 1

	table.insert(state.visualNodes,part)
end

local function clearVisuals()
	for _,v in ipairs(state.visualNodes) do
		if v then
			v:Destroy()
		end
	end

	state.visualNodes={}

	local folder=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

	if folder then
		folder:ClearAllChildren()
	end
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

local function getYaw()
	if not RootPart then
		return 0
	end

	local _,yaw,_=RootPart.CFrame:ToOrientation()
	return yaw
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
		if velocityY<0 then
			return "Fall"
		end

		return "Jump"
	end

	if Humanoid.FloorMaterial==Enum.Material.Air then
		if velocityY<0 then
			return "Fall"
		end

		return "Jump"
	end

	return "Ground"
end

local function removeAirNodes()
	if #state.airNodes==0 then
		return
	end

	local removeLookup={}

	for _,node in ipairs(state.airNodes) do
		removeLookup[node]=true
	end

	local newTimeline={}

	for _,node in ipairs(state.timeline) do
		if not removeLookup[node] then
			newTimeline[#newTimeline+1]=node
		end
	end

	state.timeline=newTimeline
	state.airNodes={}

	if #state.timeline>0 then
		state.lastValidIndex=#state.timeline
	else
		state.lastValidIndex=1
	end

	rebuildVisuals()
end

local function addRecordNode(pos,timestamp,jump,phase,velocity,yaw,speed)
	local last=state.timeline[#state.timeline]

	if not last then
		local node={
			Position=pos,
			Timestamp=timestamp,
			Jump=jump,
			Phase=phase,
			VerticalVelocity=velocity,
			Yaw=yaw,
			Speed=speed
		}

		table.insert(state.timeline,node)

		if phase=="Ground" then
			state.lastValidIndex=#state.timeline
		else
			table.insert(state.airNodes,node)
		end

		return
	end

	local distance=(pos-last.Position).Magnitude
	local timeDiff=timestamp-last.Timestamp

	if jump
	or phase~=last.Phase
	or timeDiff>=CFG.NodeInterval
	or distance>=CFG.MinDistance then

		local node={
			Position=pos,
			Timestamp=timestamp,
			Jump=jump,
			Phase=phase,
			VerticalVelocity=velocity,
			Yaw=yaw,
			Speed=speed
		}

		table.insert(state.timeline,node)

		drawLine(last.Position,pos)

		if phase=="Ground" then
			state.lastValidIndex=#state.timeline
		else
			table.insert(state.airNodes,node)
		end
	end
end

RunService:BindToRenderStep(
	"AldoKnightXorzV4_Record",
	Enum.RenderPriority.Character.Value,
	function()
		if not state.isRecording or not RootPart or not Humanoid then
			return
		end

		local pos=RootPart.Position
		local velocity=RootPart.AssemblyLinearVelocity
		local now=tick()-state.startTime

		local horizontalVelocity=Vector3.new(
			velocity.X,
			0,
			velocity.Z
		)

		local speed=horizontalVelocity.Magnitude
		local phase=getPhase()
		local grounded=Humanoid.FloorMaterial~=Enum.Material.Air

		if not grounded then
			if not state.airStartTime then
				state.airStartTime=now
				state.airNodes={}
			end

			local airDuration=now-state.airStartTime

			if airDuration>CFG.FallTime
			and velocity.Y<CFG.FallSpeed then
				return
			end
		else
			if state.airStartTime then
				local airDuration=now-state.airStartTime

				if airDuration>CFG.FallTime then
					removeAirNodes()
				end

				state.airStartTime=nil
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

		addRecordNode(
			pos,
			now,
			jumpTrigger,
			phase,
			velocity.Y,
			getYaw(),
			speed
		)
	end
)

local function angleDifference(a,b)
	return math.atan2(
		math.sin(b-a),
		math.cos(b-a)
	)
end

local function lerpYaw(a,b,alpha)
	return a+angleDifference(a,b)*alpha
end

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
		Humanoid.AutoRotate=true
		Humanoid:Move(Vector3.zero,true)
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

	state.isPlaying=true
	state.isPaused=false
	state.playbackID+=1

	local currentPlaybackID=state.playbackID

	local playbackState="WALKING_TO_START"
	local stateChanged=true

	local startPos=state.timeline[1].Position

	local playbackStartTime=0
	local pauseOffset=0

	local currentIndex=1
	local currentSegmentTime=0

	local lastTarget=RootPart.Position
	local currentYaw=getYaw()

	local originalWalkSpeed=Humanoid.WalkSpeed

	updateStatus("WALKING TO START")

	RunService:BindToRenderStep(
		"AldoKnightXorzV4_Playback",
		Enum.RenderPriority.Last.Value,
		function(dt)

			if not state.isPlaying
			or state.playbackID~=currentPlaybackID
			or not RootPart
			or not Humanoid then

				stopPlayback(false)
				return
			end

			if state.isPaused then
				pauseOffset+=dt
				Humanoid:Move(Vector3.zero,true)
				return
			end

			if playbackState=="WALKING_TO_START"
			or playbackState=="RETURNING_TO_START" then

				if stateChanged then
					Humanoid:MoveTo(startPos)
					stateChanged=false
				end

				local dist=(RootPart.Position-startPos).Magnitude

				if dist<=1.5 then
					playbackState="PLAYING"
					playbackStartTime=tick()
					pauseOffset=0
					currentIndex=1
					currentSegmentTime=0
					lastTarget=RootPart.Position
					currentYaw=state.timeline[1].Yaw or getYaw()
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

			local count=#state.timeline

			if currentIndex>=count then
				if state.isAutoWalk then
					playbackState="RETURNING_TO_START"
					stateChanged=true
					updateStatus("WALKING TO START")
					return
				else
					stopPlayback(false)
					return
				end
			end

			local currentNode=state.timeline[currentIndex]
			local nextNode=state.timeline[currentIndex+1]

			local segmentVector=
				nextNode.Position-currentNode.Position

			local segmentDistance=segmentVector.Magnitude

			if segmentDistance<0.05 then
				currentIndex+=1
				currentSegmentTime=0
				return
			end

			local recordedTime=
				(nextNode.Timestamp-currentNode.Timestamp)

			if recordedTime<=0.001 then
				recordedTime=
					segmentDistance/
					math.max(
						currentNode.Speed,
						1
					)
			end

			local recordSpeed=currentNode.Speed or 0

			if recordSpeed<1 then
				recordSpeed=
					segmentDistance/
					math.max(recordedTime,0.016)
			end

			recordSpeed=math.max(recordSpeed,1)

			local effectiveTime=recordedTime

			if effectiveTime>1.5 then
				effectiveTime=
					segmentDistance/
					recordSpeed
			end

			effectiveTime=math.max(
				effectiveTime,
				0.016
			)

			currentSegmentTime+=dt

			local alpha=
				math.clamp(
					currentSegmentTime/effectiveTime,
					0,
					1
				)

			local targetPosition=
				currentNode.Position:Lerp(
					nextNode.Position,
					alpha
				)

			local movementDelta=
				targetPosition-lastTarget

			local horizontalDelta=Vector3.new(
				movementDelta.X,
				0,
				movementDelta.Z
			)

			local horizontalDirection=
				Vector3.new(
					segmentVector.X,
					0,
					segmentVector.Z
				)

			if horizontalDirection.Magnitude>0.01 then
				horizontalDirection=
					horizontalDirection.Unit

				Humanoid:Move(
					horizontalDirection,
					false
				)
			end

			local yawA=currentNode.Yaw or currentYaw
			local yawB=nextNode.Yaw or yawA

			currentYaw=
				lerpYaw(
					yawA,
					yawB,
					alpha
				)

			Humanoid.AutoRotate=false

			local lookDirection=
				Vector3.new(
					math.sin(currentYaw),
					0,
					math.cos(currentYaw)
				)

			if lookDirection.Magnitude>0.01 then
				local targetRotation=
					CFrame.lookAt(
						RootPart.Position,
						RootPart.Position+lookDirection
					)

				local rotationAlpha=
					math.clamp(dt*12,0,1)

				RootPart.CFrame=
					RootPart.CFrame:Lerp(
						targetRotation,
						rotationAlpha
					)
			end

			local phase=currentNode.Phase

			if currentNode.Jump then
				Humanoid.Jump=true
				Humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)
			elseif phase=="Jump"
			and currentNode.VerticalVelocity>1 then
				Humanoid.Jump=true
			end

			lastTarget=targetPosition

			if alpha>=0.999 then
				currentIndex+=1
				currentSegmentTime=0
			end
		end
	)
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
			state.airStartTime=nil
			state.lastGrounded=true
			state.lastValidIndex=1
			state.startTime=tick()

			clearVisuals()

			updateStatus("RECORDING")
		else
			normalizeTimeline(state.timeline)

			state.airNodes={}
			state.airStartTime=nil

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

		if fileData
		and fileData.timeline then

			stopPlayback(true)

			state.timeline=
				normalizeTimeline(
					fileData.timeline
				)

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
		state.airStartTime=nil
		state.lastValidIndex=1

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
			for _,part in ipairs(folder:GetChildren()) do
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
