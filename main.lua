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
		if typeof(c)=="RBXScriptConnection" then c:Disconnect() end
	end
	currentConnections={}
	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV3_Playback")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV4_Playback")
	local pg=LocalPlayer:WaitForChild("PlayerGui")
	for _,g in ipairs(pg:GetChildren()) do
		if g:IsA("ScreenGui") and (g.Name=="AldoKnightXorzV3Gui" or g.Name=="AldoKnightXorzV4Gui" or g.Name=="AldoKnightXorzV47Gui") then
			g:Destroy()
		end
	end
end

local function setupCharacter(char)
	if stopPlayback then stopPlayback(true) end
	Character=char
	RootPart=char:WaitForChild("HumanoidRootPart")
	Humanoid=char:WaitForChild("Humanoid")
	Humanoid.AutoRotate=true
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
table.insert(currentConnections,LocalPlayer.CharacterAdded:Connect(setupCharacter))

local CFG={
	NodeInterval=0.12,
	MinDistance=0.35,
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
	movementSpeed=16,
	replayPrecision=true
}

local function normalizeTimeline(t)
	if #t==0 then return t end

	local base=t[1].Timestamp

	for i,n in ipairs(t) do
		n.RelativeTimestamp=(n.Timestamp or 0)-base

		if n.Yaw==nil then
			n.Yaw=0
		end

		if n.Phase==nil then
			n.Phase=n.Jump and "Jump" or "Ground"
		end

		if n.VerticalVelocity==nil then
			n.VerticalVelocity=0
		end
	end

	return t
end

local function saveToDisk()
	local out={}

	for slot,data in pairs(state.savedFiles) do
		local tl={}

		for _,n in ipairs(data.timeline) do
			table.insert(tl,{
				P={
					math.round(n.Position.X*100)/100,
					math.round(n.Position.Y*100)/100,
					math.round(n.Position.Z*100)/100
				},
				T=math.round((n.Timestamp or 0)*1000)/1000,
				J=n.Jump or false,
				R=n.Yaw or 0,
				V=math.round((n.VerticalVelocity or 0)*100)/100,
				S=n.Phase or "Ground"
			})
		end

		out[tostring(slot)]={timeline=tl}
	end

	if writefile then
		pcall(function()
			writefile(CFG.SaveFileName,HttpService:JSONEncode(out))
		end)
	end
end

local function loadFromDisk()
	if not readfile then return end

	local ok,result=pcall(function()
		return readfile(CFG.SaveFileName)
	end)

	if not ok or not result then return end

	local ok2,decoded=pcall(function()
		return HttpService:JSONDecode(result)
	end)

	if not ok2 or type(decoded)~="table" then return end

	for slot,data in pairs(decoded) do
		if type(data)=="table" and type(data.timeline)=="table" then
			local tl={}

			for _,n in ipairs(data.timeline) do
				if n.P then
					table.insert(tl,{
						Position=Vector3.new(unpack(n.P)),
						Timestamp=tonumber(n.T) or 0,
						Jump=n.J or false,
						Yaw=tonumber(n.R) or 0,
						VerticalVelocity=tonumber(n.V) or 0,
						Phase=n.S or (n.J and "Jump" or "Ground")
					})
				end
			end

			state.savedFiles[tonumber(slot)]={
				timeline=normalizeTimeline(tl)
			}
		end
	end
end

loadFromDisk()

local function getOrCreateRouteFolder()
	local f=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

	if not f then
		f=Instance.new("Folder")
		f.Name="KNIGHTXORZ_ROUTE"
		f.Parent=workspace
	end

	return f
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

local openMoved=false

table.insert(currentConnections,OpenMenu.MouseButton1Click:Connect(function()
	if openMoved then
		openMoved=false
		return
	end
	MainFrame.Visible=not MainFrame.Visible
end))

local openDragging,openDragStart,openStartPos

table.insert(currentConnections,OpenMenu.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		openDragging=true
		openDragStart=input.Position
		openStartPos=OpenMenu.Position
		openMoved=false

		local cc
		cc=input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then
				openDragging=false
				if cc then cc:Disconnect() end
			end
		end)
	end
end))

table.insert(currentConnections,UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
		if openDragging then
			local d=input.Position-openDragStart

			if d.Magnitude>5 then
				openMoved=true
			end

			OpenMenu.Position=UDim2.new(
				openStartPos.X.Scale,
				openStartPos.X.Offset+d.X,
				openStartPos.Y.Scale,
				openStartPos.Y.Offset+d.Y
			)
		end
	end
end))

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
UIList.HorizontalAlignment=Enum.HorizontalAlignment.Center
UIList.Padding=UDim.new(0,6)
UIList.SortOrder=Enum.SortOrder.LayoutOrder

local function updateStatus(text)
	if not ScreenGui or not ScreenGui.Parent then return end

	local lbl=MainFrame:FindFirstChild("StatusLabel")

	if lbl then
		lbl.Text="Status: "..text.." | File: "..state.selectedFile
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
		TweenService:Create(btn,TweenInfo.new(0.12),{
			BackgroundColor3=CFG.AccentColor
		}):Play()

		task.wait(0.12)

		TweenService:Create(btn,TweenInfo.new(0.12),{
			BackgroundColor3=Color3.fromRGB(30,30,40)
		}):Play()

		callback()
	end))

	return btn
end

local function drawLine(p1,p2)
	local dist=(p1-p2).Magnitude

	if dist<0.1 then return end

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
	part.Transparency=state.lineVisible and 0 or 1
	part.Name="VisualNode"
	part.Parent=getOrCreateRouteFolder()

	table.insert(state.visualNodes,part)
end

local function clearVisuals()
	for _,v in ipairs(state.visualNodes) do
		if v then v:Destroy() end
	end

	state.visualNodes={}

	local folder=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")
	if folder then folder:ClearAllChildren() end
end

local function getPhase(humanoid,root)
	local stateType=humanoid:GetState()
	local velocity=root.AssemblyLinearVelocity

	if stateType==Enum.HumanoidStateType.Jumping then
		return "Jump"
	end

	if stateType==Enum.HumanoidStateType.Freefall then
		if velocity.Y>0 then
			return "Jump"
		end
		return "Fall"
	end

	if humanoid.FloorMaterial==Enum.Material.Air then
		if velocity.Y>1 then
			return "Jump"
		end
		return "Fall"
	end

	return "Ground"
end

RunService:BindToRenderStep(
	"AldoKnightXorzV4_Record",
	Enum.RenderPriority.Character.Value,
	function()
		if not state.isRecording or not RootPart or not Humanoid then return end

		local now=tick()-state.startTime
		local pos=RootPart.Position
		local velocity=RootPart.AssemblyLinearVelocity
		local phase=getPhase(Humanoid,RootPart)

		local grounded=Humanoid.FloorMaterial~=Enum.Material.Air
		local jumpTrigger=false

		if not grounded and state.lastGrounded and phase=="Jump" then
			jumpTrigger=true
		end

		state.lastGrounded=grounded

		local _,yaw,_=RootPart.CFrame:ToOrientation()

		if #state.timeline==0 then
			table.insert(state.timeline,{
				Position=pos,
				Timestamp=now,
				Jump=jumpTrigger,
				Yaw=yaw,
				VerticalVelocity=velocity.Y,
				Phase=phase
			})
			return
		end

		local last=state.timeline[#state.timeline]
		local dist=(pos-last.Position).Magnitude
		local dt=now-last.Timestamp

		if dt>=CFG.NodeInterval or dist>=CFG.MinDistance or jumpTrigger or phase~=last.Phase then
			drawLine(last.Position,pos)

			table.insert(state.timeline,{
				Position=pos,
				Timestamp=now,
				Jump=jumpTrigger,
				Yaw=yaw,
				VerticalVelocity=velocity.Y,
				Phase=phase
			})
		end
	end
)

local function lerpAngle(a,b,t)
	local d=(b-a+math.pi)%(math.pi*2)-math.pi
	return a+d*t
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
	if #state.timeline<2 or state.isPlaying or not RootPart or not Humanoid then return end

	normalizeTimeline(state.timeline)
	stopPlayback(false)

	state.isPlaying=true
	state.isPaused=false
	state.playbackID+=1

	local playbackID=state.playbackID
	local startPos=state.timeline[1].Position
	local startYaw=state.timeline[1].Yaw or 0
	local started=false
	local playbackStart=0
	local pauseOffset=0
	local currentIndex=1
	local lastJumpTime=-1
	local lastYaw=startYaw

	Humanoid.WalkSpeed=state.movementSpeed
	Humanoid.AutoRotate=false

	updateStatus("WALKING TO START")

	RunService:BindToRenderStep(
		"AldoKnightXorzV4_Playback",
		Enum.RenderPriority.Character.Value+1,
		function(dt)
			if not state.isPlaying or state.playbackID~=playbackID or not RootPart or not Humanoid then
				return
			end

			if state.isPaused then
				pauseOffset+=dt
				Humanoid:Move(Vector3.zero,false)
				return
			end

			if not started then
				local d=Vector3.new(
					startPos.X-RootPart.Position.X,
					0,
					startPos.Z-RootPart.Position.Z
				)

				if d.Magnitude>1.5 then
					Humanoid:Move(d.Unit,false)

					local target=CFrame.lookAt(
						RootPart.Position,
						RootPart.Position+d.Unit
					)

					RootPart.CFrame=RootPart.CFrame:Lerp(target,0.2)
					return
				end

				started=true
				playbackStart=tick()
				pauseOffset=0
				currentIndex=1
				lastYaw=startYaw

				updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
			end

			local elapsed=tick()-playbackStart-pauseOffset
			local lastNode=state.timeline[#state.timeline]

			if elapsed>=lastNode.RelativeTimestamp then
				local finalPos=lastNode.Position
				local finalYaw=lastNode.Yaw or lastYaw

				RootPart.CFrame=CFrame.new(finalPos)*CFrame.Angles(0,finalYaw,0)
				Humanoid:Move(Vector3.zero,false)

				if state.isAutoWalk then
					started=false
					playbackStart=tick()
					pauseOffset=0
					currentIndex=1
					updateStatus("WALKING TO START")
				else
					stopPlayback(false)
				end

				return
			end

			while currentIndex<#state.timeline and elapsed>=state.timeline[currentIndex+1].RelativeTimestamp do
				currentIndex+=1
			end

			local a=state.timeline[currentIndex]
			local b=state.timeline[math.min(currentIndex+1,#state.timeline)]

			local span=b.RelativeTimestamp-a.RelativeTimestamp

			local alpha=0

			if span>0 then
				alpha=math.clamp(
					(elapsed-a.RelativeTimestamp)/span,
					0,
					1
				)
			end

			local pos=a.Position:Lerp(b.Position,alpha)
			local yawA=a.Yaw or lastYaw
			local yawB=b.Yaw or yawA
			local yaw=lerpAngle(yawA,yawB,alpha)

			lastYaw=yaw

			local horizontal=Vector3.new(
				b.Position.X-a.Position.X,
				0,
				b.Position.Z-a.Position.Z
			)

			if horizontal.Magnitude>0.001 then
				Humanoid:Move(horizontal.Unit,false)
			else
				Humanoid:Move(Vector3.zero,false)
			end

			local phase=a.Phase or "Ground"
			local nextPhase=b.Phase or phase

			local jumpTime=a.RelativeTimestamp

			if a.Jump and jumpTime~=lastJumpTime and elapsed>=jumpTime then
				Humanoid.Jump=true
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				lastJumpTime=jumpTime
			end

			local targetY=pos.Y

			if phase=="Ground" and nextPhase=="Ground" then
				targetY=pos.Y
			elseif phase=="Jump" or phase=="Fall" or nextPhase=="Jump" or nextPhase=="Fall" then
				targetY=pos.Y
			end

			local targetCFrame=
				CFrame.new(
					pos.X,
					targetY,
					pos.Z
				)*
				CFrame.Angles(0,yaw,0)

			RootPart.CFrame=targetCFrame
		end
	)
end

local function toggleAutoWalk()
	if state.isRecording then return end

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

createBtn("RECORD START / STOP",1,function()
	state.isRecording=not state.isRecording

	if state.isRecording then
		stopPlayback(true)

		state.timeline={}
		state.lastJumpState=false
		state.lastGrounded=true
		state.startTime=tick()

		clearVisuals()
		updateStatus("RECORDING")
	else
		normalizeTimeline(state.timeline)
		updateStatus("IDLE")
	end
end)

createBtn("PLAY ROUTE",2,function()
	if state.isRecording then return end

	state.isAutoWalk=false
	executePlayback()
end)

createBtn("PAUSE / RESUME",3,function()
	if not state.isPlaying then return end

	state.isPaused=not state.isPaused

	if state.isPaused then
		updateStatus("PAUSED")
	else
		updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
	end
end)

createBtn("AUTO WALK ON / OFF",4,function()
	toggleAutoWalk()
end)

createBtn("STOP PLAYBACK",5,function()
	stopPlayback(true)
end)

for i=1,5 do
	createBtn("SELECT FILE "..i,5+i,function()
		state.selectedFile=i
		updateStatus("IDLE")
	end)
end

createBtn("SAVE FILE",11,function()
	if #state.timeline>0 then
		normalizeTimeline(state.timeline)

		state.savedFiles[state.selectedFile]={
			timeline=state.timeline
		}

		saveToDisk()
		updateStatus("SAVED FILE "..state.selectedFile)
	end
end)

createBtn("LOAD FILE",12,function()
	local data=state.savedFiles[state.selectedFile]

	if data and data.timeline then
		stopPlayback(true)

		state.timeline=normalizeTimeline(data.timeline)
		clearVisuals()

		for i=2,#state.timeline do
			drawLine(
				state.timeline[i-1].Position,
				state.timeline[i].Position
			)
		end

		updateStatus("LOADED FILE "..state.selectedFile)
	end
end)

createBtn("CLEAR ROUTE",13,function()
	stopPlayback(true)
	state.timeline={}
	clearVisuals()
	updateStatus("CLEARED")
end)

createBtn("SHOW / HIDE LINE",14,function()
	state.lineVisible=not state.lineVisible

	local folder=workspace:FindFirstChild("KNIGHTXORZ_ROUTE")

	if folder then
		for _,part in ipairs(folder:GetChildren()) do
			if part:IsA("Part") then
				part.Transparency=state.lineVisible and 0 or 1
			end
		end
	end
end)
