local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local Player=Players.LocalPlayer

local Character
local Humanoid
local RootPart

local CFG={
	NodeInterval=0.05,
	MinDistance=0.08,
	MoveUpdate=0.025,
	ArriveDistance=0.9,
	JumpDistance=3,
	JumpCooldown=0.18,
	RotationSpeed=12,
	PlaybackLookAhead=0.035,
	MaxCatchUpSpeed=2.5,
	SaveFileName="VAINLY_STAR_AUTO_WALK_TRACKING.json"
}

local State={
	Recording=false,
	Playing=false,
	Paused=false,
	AutoLoop=false,
	Timeline={},
	PlayIndex=1,
	RecordStart=0,
	SelectedFile=1,
	Files={},
	LastJump=false,
	Token=0,
	LineVisible=true,
	OriginalWalkSpeed=16,
	PlaybackTime=0,
	PlaybackClock=0,
	LastJumpTime=0,
	RespawnResume=false
}

local Visuals={}
local RouteFolder=workspace:FindFirstChild("VAINLY_STAR_TRACKING_ROUTE")

if not RouteFolder then
	RouteFolder=Instance.new("Folder")
	RouteFolder.Name="VAINLY_STAR_TRACKING_ROUTE"
	RouteFolder.Parent=workspace
end

local function setupCharacter(char)
	Character=char
	Humanoid=char:WaitForChild("Humanoid",8)
	RootPart=char:WaitForChild("HumanoidRootPart",8)
end

local function alive()
	return Character
		and Character.Parent
		and Humanoid
		and Humanoid.Parent
		and Humanoid.Health>0
		and RootPart
		and RootPart.Parent
end

if Player.Character then
	setupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)
	Character=nil
	Humanoid=nil
	RootPart=nil

	State.Token+=1

	local wasPlaying=State.Playing

	State.Recording=false
	State.Playing=false
	State.Paused=false

	setupCharacter(char)

	if wasPlaying and #State.Timeline>=2 then
		task.wait(0.35)

		if alive() then
			State.Playing=false
			State.Paused=false
			task.wait(0.1)
		end
	end
end)

local function cloneTimeline(source)
	local result={}

	for _,node in ipairs(source) do
		result[#result+1]={
			Position=node.Position,
			CFrame=node.CFrame,
			Time=node.Time,
			Jump=node.Jump,
			Freefall=node.Freefall,
			WalkSpeed=node.WalkSpeed,
			Direction=node.Direction
		}
	end

	return result
end

local function normalize()
	if #State.Timeline==0 then
		return
	end

	local base=State.Timeline[1].Time

	for _,node in ipairs(State.Timeline) do
		node.Time=math.max(0,node.Time-base)
	end
end

local function clearRoute()
	for _,v in ipairs(Visuals) do
		if v and v.Parent then
			v:Destroy()
		end
	end

	table.clear(Visuals)
end

local function drawSegment(a,b)
	local distance=(b-a).Magnitude

	if distance<0.03 then
		return
	end

	local part=Instance.new("Part")
	part.Name="VAINLY_STAR_TrackingLine"
	part.Anchored=true
	part.CanCollide=false
	part.CanTouch=false
	part.CanQuery=false
	part.CastShadow=false
	part.Material=Enum.Material.Neon
	part.Color=Color3.fromRGB(170,0,255)
	part.Transparency=State.LineVisible and 0.15 or 1
	part.Size=Vector3.new(0.12,0.12,distance)
	part.CFrame=CFrame.lookAt(a:Lerp(b,0.5),b)
	part.Parent=RouteFolder

	Visuals[#Visuals+1]=part
end

local function rebuildRoute()
	clearRoute()

	for i=2,#State.Timeline do
		drawSegment(
			State.Timeline[i-1].Position,
			State.Timeline[i].Position
		)
	end
end

local function stopMovement()
	if not alive() then
		return
	end

	Humanoid:Move(Vector3.zero,true)
	Humanoid:MoveTo(RootPart.Position)
end

local function stopPlayback()
	State.Playing=false
	State.Paused=false
	State.Token+=1
	State.PlaybackTime=0
	State.PlayIndex=1

	stopMovement()

	if alive() then
		Humanoid.WalkSpeed=State.OriginalWalkSpeed
	end
end

local function recordNode(force)
	if not alive() then
		return
	end

	local now=os.clock()-State.RecordStart
	local cf=RootPart.CFrame
	local pos=cf.Position
	local speed=Humanoid.WalkSpeed
	local direction=Humanoid.MoveDirection
	local humanoidState=Humanoid:GetState()

	local jumping=
		humanoidState==Enum.HumanoidStateType.Jumping

	local freefall=
		humanoidState==Enum.HumanoidStateType.Freefall

	local jump=jumping and not State.LastJump

	State.LastJump=jumping or freefall

	local last=State.Timeline[#State.Timeline]

	if not last then
		State.Timeline[#State.Timeline+1]={
			Position=pos,
			CFrame=cf,
			Time=now,
			Jump=jump,
			Freefall=freefall,
			WalkSpeed=speed,
			Direction=direction
		}

		return
	end

	local distance=(pos-last.Position).Magnitude

	if force or distance>=CFG.MinDistance or jump then
		State.Timeline[#State.Timeline+1]={
			Position=pos,
			CFrame=cf,
			Time=now,
			Jump=jump,
			Freefall=freefall,
			WalkSpeed=speed,
			Direction=direction
		}

		drawSegment(last.Position,pos)
	end
end

pcall(function()
	RunService:UnbindFromRenderStep("VAINLY_STAR_RECORD_TRACKING")
end)

local recordAccumulator=0

RunService:BindToRenderStep(
	"VAINLY_STAR_RECORD_TRACKING",
	Enum.RenderPriority.Character.Value+1,
	function(dt)
		if not State.Recording then
			return
		end

		if not alive() then
			return
		end

		recordAccumulator+=dt

		if recordAccumulator>=CFG.NodeInterval then
			recordAccumulator=0
			recordNode(false)
		end
	end
)

local function startRecord()
	stopPlayback()

	State.Timeline={}
	State.Recording=true
	State.Paused=false
	State.LastJump=false
	State.RecordStart=os.clock()

	recordAccumulator=0

	clearRoute()

	if alive() then
		State.OriginalWalkSpeed=Humanoid.WalkSpeed
		recordNode(true)
	end
end

local function stopRecord()
	if not State.Recording then
		return
	end

	State.Recording=false
	State.LastJump=false

	normalize()
	rebuildRoute()
end

local function getTotalTime()
	if #State.Timeline==0 then
		return 0
	end

	return State.Timeline[#State.Timeline].Time
end

local function getNodeAtTime(t)
	local timeline=State.Timeline
	local count=#timeline

	if count==0 then
		return nil,nil,nil
	end

	if t<=timeline[1].Time then
		return 1,timeline[1],timeline[1]
	end

	if t>=timeline[count].Time then
		return count,timeline[count],nil
	end

	local low=1
	local high=count

	while low<=high do
		local mid=math.floor((low+high)/2)

		if timeline[mid].Time<=t then
			low=mid+1
		else
			high=mid-1
		end
	end

	local index=math.max(1,high)
	local a=timeline[index]
	local b=timeline[index+1]

	return index,a,b
end

local function getPlaybackData(t)
	local index,a,b=getNodeAtTime(t)

	if not a then
		return nil
	end

	if not b then
		return index,a.Position,a.CFrame,a.Direction,a.WalkSpeed,a.Jump,a.Freefall
	end

	local span=b.Time-a.Time

	local alpha=0

	if span>0 then
		alpha=math.clamp(
			(t-a.Time)/span,
			0,
			1
		)
	end

	local position=a.Position:Lerp(
		b.Position,
		alpha
	)

	local cf=a.CFrame:Lerp(
		b.CFrame,
		alpha
	)

	local direction=a.Direction:Lerp(
		b.Direction,
		alpha
	)

	local speed=a.WalkSpeed

	if b.WalkSpeed then
		speed=a.WalkSpeed+(b.WalkSpeed-a.WalkSpeed)*alpha
	end

	return index,position,cf,direction,speed,a.Jump or b.Jump,a.Freefall or b.Freefall
end

local function horizontalDirection(direction,position,target)
	local d=Vector3.new(
		direction.X,
		0,
		direction.Z
	)

	if d.Magnitude>0.05 then
		return d.Unit
	end

	local delta=Vector3.new(
		target.X-position.X,
		0,
		target.Z-position.Z
	)

	if delta.Magnitude>0.05 then
		return delta.Unit
	end

	return Vector3.zero
end

local function performJump()
	if not alive() then
		return
	end

	local now=os.clock()

	if now-State.LastJumpTime<CFG.JumpCooldown then
		return
	end

	State.LastJumpTime=now
	Humanoid.Jump=true
end

local function applyPlaybackMovement(position,cf,direction)
	if not alive() then
		return
	end

	local current=RootPart.Position

	local targetDirection=horizontalDirection(
		direction,
		current,
		position
	)

	local distance=Vector3.new(
		position.X-current.X,
		0,
		position.Z-current.Z
	).Magnitude

	if distance>0.03 then
		local moveDirection=targetDirection

		if moveDirection.Magnitude>0 then
			Humanoid:Move(moveDirection,false)
		else
			Humanoid:Move(Vector3.zero,false)
		end
	else
		Humanoid:Move(Vector3.zero,false)
	end

	local lookDirection=Vector3.new(
		cf.LookVector.X,
		0,
		cf.LookVector.Z
	)

	if lookDirection.Magnitude>0.01 then
		lookDirection=lookDirection.Unit

		local desired=CFrame.lookAt(
			RootPart.Position,
			RootPart.Position+lookDirection
		)

		RootPart.CFrame=RootPart.CFrame:Lerp(
			desired,
			math.clamp(CFG.RotationSpeed*CFG.MoveUpdate,0,1)
		)
	end
end

local function executePlayback()
	if State.Playing then
		return
	end

	if #State.Timeline<2 then
		return
	end

	if not alive() then
		return
	end

	State.Playing=true
	State.Paused=false
	State.Token+=1
	State.PlaybackTime=0
	State.PlayIndex=1
	State.LastJumpTime=0
	State.OriginalWalkSpeed=Humanoid.WalkSpeed

	local token=State.Token
	local totalTime=getTotalTime()

	local playbackStart=os.clock()

	task.spawn(function()
		while State.Playing
			and State.Token==token
			and alive() do

			if State.Paused then
				Humanoid:Move(Vector3.zero,true)
				task.wait(0.03)
				continue
			end

			local elapsed=os.clock()-playbackStart
			State.PlaybackTime=elapsed

			if totalTime>0 and elapsed>=totalTime then
				if State.AutoLoop then
					playbackStart=os.clock()
					State.PlaybackTime=0
					State.PlayIndex=1
					continue
				else
					break
				end
			end

			local index,position,cf,direction,speed,jump,freefall=
				getPlaybackData(State.PlaybackTime)

			if not position then
				break
			end

			State.PlayIndex=index

			if speed and speed>0 then
				Humanoid.WalkSpeed=speed
			end

			if jump then
				performJump()
			end

			applyPlaybackMovement(
				position,
				cf,
				direction
			)

			task.wait(CFG.MoveUpdate)
		end

		if State.Token==token then
			State.Playing=false
			State.Paused=false
			State.PlaybackTime=0
			State.PlayIndex=1

			stopMovement()

			if alive() then
				Humanoid.WalkSpeed=State.OriginalWalkSpeed
			end
		end
	end)
end

local function togglePause()
	if not State.Playing then
		return
	end

	State.Paused=not State.Paused

	if State.Paused then
		stopMovement()
	else
		local remaining=getTotalTime()-State.PlaybackTime

		if remaining<0 then
			State.PlaybackTime=0
		end
	end
end

local function saveFiles()
	local data={}

	for slot,file in pairs(State.Files) do
		if file and file.timeline then
			local timeline={}

			for _,node in ipairs(file.timeline) do
				local p=node.Position
				local cf=node.CFrame

				local c

				if cf then
					c={cf:GetComponents()}
				end

				timeline[#timeline+1]={
					P={
						math.round(p.X*100)/100,
						math.round(p.Y*100)/100,
						math.round(p.Z*100)/100
					},
					C=c,
					T=node.Time or 0,
					J=node.Jump or false,
					F=node.Freefall or false,
					W=node.WalkSpeed or 16,
					D=node.Direction and {
						node.Direction.X,
						node.Direction.Y,
						node.Direction.Z
					} or {0,0,0}
				}
			end

			data[tostring(slot)]={
				timeline=timeline
			}
		end
	end

	pcall(function()
		if writefile then
			writefile(
				CFG.SaveFileName,
				HttpService:JSONEncode(data)
			)
		end
	end)
end

local function loadFiles()
	local raw

	pcall(function()
		if readfile then
			raw=readfile(CFG.SaveFileName)
		end
	end)

	if not raw then
		return
	end

	local success,data=pcall(function()
		return HttpService:JSONDecode(raw)
	end)

	if not success or type(data)~="table" then
		return
	end

	for slot,file in pairs(data) do
		if file and type(file.timeline)=="table" then
			local timeline={}

			for _,node in ipairs(file.timeline) do
				if node.P and #node.P>=3 then
					local position=Vector3.new(
						node.P[1],
						node.P[2],
						node.P[3]
					)

					local cf=CFrame.new(position)

					if node.C and #node.C==12 then
						local ok,result=pcall(function()
							return CFrame.new(table.unpack(node.C))
						end)

						if ok and result then
							cf=result
						end
					end

					local direction=Vector3.zero

					if node.D and #node.D>=3 then
						direction=Vector3.new(
							node.D[1],
							node.D[2],
							node.D[3]
						)
					end

					timeline[#timeline+1]={
						Position=position,
						CFrame=cf,
						Time=node.T or 0,
						Jump=node.J or false,
						Freefall=node.F or false,
						WalkSpeed=node.W or 16,
						Direction=direction
					}
				end
			end

			State.Files[tonumber(slot) or slot]={
				timeline=timeline
			}
		end
	end
end

loadFiles()

local Gui=Instance.new("ScreenGui")
Gui.Name="VAINLY_STAR_AUTO_WALK_TRACKING"
Gui.ResetOnSpawn=false
Gui.Parent=Player:WaitForChild("PlayerGui")

local Open=Instance.new("TextButton")
Open.Size=UDim2.fromOffset(58,58)
Open.Position=UDim2.new(0.04,0,0.5,0)
Open.BackgroundColor3=Color3.fromRGB(20,15,28)
Open.Text="VS"
Open.TextColor3=Color3.fromRGB(255,255,255)
Open.Font=Enum.Font.GothamBold
Open.TextSize=18
Open.Parent=Gui

local OpenCorner=Instance.new("UICorner")
OpenCorner.CornerRadius=UDim.new(0,10)
OpenCorner.Parent=Open

local OpenStroke=Instance.new("UIStroke")
OpenStroke.Color=Color3.fromRGB(170,0,255)
OpenStroke.Thickness=2
OpenStroke.Parent=Open

local Frame=Instance.new("Frame")
Frame.Size=UDim2.fromOffset(430,330)
Frame.Position=UDim2.new(0.5,-215,0.5,-165)
Frame.BackgroundColor3=Color3.fromRGB(15,12,20)
Frame.Visible=false
Frame.Active=true
Frame.Parent=Gui

local FrameCorner=Instance.new("UICorner")
FrameCorner.CornerRadius=UDim.new(0,12)
FrameCorner.Parent=Frame

local FrameStroke=Instance.new("UIStroke")
FrameStroke.Color=Color3.fromRGB(170,0,255)
FrameStroke.Thickness=2
FrameStroke.Parent=Frame

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,0,0,38)
Title.BackgroundTransparency=1
Title.Text="VAINLY STAR AUTO WALK"
Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold
Title.TextSize=15
Title.Parent=Frame

local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(1,-20,0,28)
Status.Position=UDim2.fromOffset(10,38)
Status.BackgroundTransparency=1
Status.Text="IDLE | NODES: 0 | FILE: 1"
Status.TextColor3=Color3.fromRGB(200,80,255)
Status.Font=Enum.Font.GothamBold
Status.TextSize=12
Status.Parent=Frame

local Container=Instance.new("ScrollingFrame")
Container.Size=UDim2.new(1,-20,1,-75)
Container.Position=UDim2.fromOffset(10,70)
Container.BackgroundTransparency=1
Container.BorderSizePixel=0
Container.ScrollBarThickness=4
Container.CanvasSize=UDim2.new(0,0,0,0)
Container.AutomaticCanvasSize=Enum.AutomaticSize.Y
Container.Parent=Frame

local Layout=Instance.new("UIGridLayout")
Layout.CellSize=UDim2.fromOffset(125,40)
Layout.CellPadding=UDim2.fromOffset(7,7)
Layout.Parent=Container

local function updateStatus(text)
	Status.Text=
		text
		.." | NODES: "
		..#State.Timeline
		.." | FILE: "
		..State.SelectedFile
end

local function button(text,callback)
	local b=Instance.new("TextButton")
	b.Size=UDim2.fromOffset(125,40)
	b.BackgroundColor3=Color3.fromRGB(30,25,40)
	b.Text=text
	b.TextColor3=Color3.fromRGB(240,240,240)
	b.Font=Enum.Font.GothamBold
	b.TextSize=11
	b.Parent=Container

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,7)
	c.Parent=b

	local s=Instance.new("UIStroke")
	s.Thickness=1
	s.Color=Color3.fromRGB(80,60,100)
	s.Parent=b

	b.Activated:Connect(function()
		pcall(callback)
	end)

	return b
end

Open.Activated:Connect(function()
	Frame.Visible=not Frame.Visible
end)

button("RECORD START",function()
	if State.Recording then
		stopRecord()
		updateStatus("RECORD STOP")
	else
		startRecord()
		updateStatus("RECORDING")
	end
end)

button("PLAY RECORD",function()
	if State.Recording then
		return
	end

	State.AutoLoop=false

	executePlayback()

	if State.Playing then
		updateStatus("PLAYING RECORD")
	end
end)

button("PAUSE / RESUME",function()
	togglePause()

	if State.Paused then
		updateStatus("PAUSED")
	elseif State.Playing then
		updateStatus("PLAYING")
	else
		updateStatus("IDLE")
	end
end)

button("AUTO LOOP",function()
	if State.Recording then
		return
	end

	State.AutoLoop=not State.AutoLoop

	if State.AutoLoop then
		if not State.Playing then
			executePlayback()
		end

		updateStatus("AUTO LOOP")
	else
		updateStatus("LOOP OFF")
	end
end)

button("STOP",function()
	State.AutoLoop=false
	stopPlayback()
	updateStatus("STOPPED")
end)

button("SAVE FILE",function()
	if #State.Timeline==0 then
		return
	end

	State.Files[State.SelectedFile]={
		timeline=cloneTimeline(State.Timeline)
	}

	saveFiles()
	updateStatus("SAVED")
end)

button("LOAD FILE",function()
	local file=State.Files[State.SelectedFile]

	if not file or not file.timeline then
		return
	end

	stopPlayback()

	State.Timeline=cloneTimeline(file.timeline)

	normalize()
	rebuildRoute()

	updateStatus("LOADED")
end)

for i=1,5 do
	button("FILE "..i,function()
		State.SelectedFile=i
		updateStatus("FILE "..i)
	end)
end

button("CLEAR",function()
	stopPlayback()

	State.Recording=false
	State.Timeline={}
	State.PlayIndex=1
	State.PlaybackTime=0

	clearRoute()

	updateStatus("CLEARED")
end)

button("LINE ON / OFF",function()
	State.LineVisible=not State.LineVisible

	for _,part in ipairs(Visuals) do
		if part and part.Parent then
			part.Transparency=
				State.LineVisible
				and 0.15
				or 1
		end
	end

	updateStatus(
		State.LineVisible
		and "LINE ON"
		or "LINE OFF"
	)
end)

local dragging=false
local dragStart
local frameStart

Title.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1
		or input.UserInputType==Enum.UserInputType.Touch then

		dragging=true
		dragStart=input.Position
		frameStart=Frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType==Enum.UserInputType.MouseMovement
		or input.UserInputType==Enum.UserInputType.Touch then

		local delta=input.Position-dragStart

		Frame.Position=UDim2.new(
			frameStart.X.Scale,
			frameStart.X.Offset+delta.X,
			frameStart.Y.Scale,
			frameStart.Y.Offset+delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1
		or input.UserInputType==Enum.UserInputType.Touch then

		dragging=false
	end
end)
