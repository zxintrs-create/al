-- [[ ALDO KNIGHTXORZ V4.45 - ULTRA SMOOTH | COMPACT FULL VERSION ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CLEAN OLD VERSIONS
for _, name in ipairs({"AldoKnightXorzV440_Cleanup","AldoKnightXorzV441_Cleanup","AldoKnightXorzV442_Cleanup","AldoKnightXorzV443_Cleanup","AldoKnightXorzV444_Cleanup","AldoKnightXorzV445_Cleanup"}) do
	pcall(function() if _G[name] then _G[name]() end end)
end

local BIND_RECORD = "AldoKnightXorzV445_Record"
local BIND_PLAYBACK = "AldoKnightXorzV445_Playback"
pcall(function()
	RunService:UnbindFromRenderStep(BIND_RECORD)
	RunService:UnbindFromRenderStep(BIND_PLAYBACK)
end)

local CFG = {
	NodeInterval = 1 / 60,
	MinDistance = 0.001,
	PlaybackSpeed = 1,
	EndTolerance = 0.001,
	InterpolationPower = 1,
	LineColor = Color3.fromRGB(0,255,255),
	AccentColor = Color3.fromRGB(170,0,255),
	ButtonColor = Color3.fromRGB(30,30,40),
	RouteFolderName = "KNIGHTXORZ_ROUTE_V445",
	SaveFileName = "ALDO_KNIGHTXORZ_V4_45.json",
	OpenButtonSize = 58
}

local Character, RootPart, Humanoid, Animator, stopPlayback
local state = {
	isRecording = false, isPlaying = false, isPaused = false, isAutoWalk = false,
	kinematicActive = false, playbackID = 0, timeline = {}, visualNodes = {},
	lineVisible = true, selectedFile = 1, savedFiles = {}, memoryStorage = {},
	startTime = 0, lastRecordTime = 0, lastJumpState = false,
	cutStart = 1, cutEnd = 1, playbackTime = 0, playbackStartClock = 0, pauseClock = 0,
	savedRootState = nil, savedHumanoidState = nil
}

local currentConnections = {}
local function addConnection(c) if c then table.insert(currentConnections,c) end return c end

local function setupCharacter(char)
	if stopPlayback then pcall(function() stopPlayback(true) end) end
	Character = char
	Humanoid = char:WaitForChild("Humanoid",10)
	RootPart = char:WaitForChild("HumanoidRootPart",10)
	Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
	if Humanoid and not Animator then pcall(function() Animator = Instance.new("Animator"); Animator.Parent = Humanoid end) end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
addConnection(LocalPlayer.CharacterAdded:Connect(setupCharacter))

local function isCharacterAlive()
	return Character and Character.Parent and RootPart and RootPart.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0
end

local function normalizeTimeline(timeline)
	if not timeline or #timeline == 0 then return timeline end
	local base = timeline[1].Timestamp or 0
	for _, node in ipairs(timeline) do node.RelativeTimestamp = math.max(0,(node.Timestamp or base)-base) end
	return timeline
end

local function cloneTimeline(source)
	local result = {}
	for _, node in ipairs(source or {}) do
		table.insert(result,{
			CFrame=node.CFrame, Position=node.Position, Timestamp=node.Timestamp or 0,
			RelativeTimestamp=node.RelativeTimestamp or 0, Jump=node.Jump == true,
			WalkSpeed=node.WalkSpeed or 16, HumanoidState=node.HumanoidState,
			MovementDirection=node.MovementDirection or Vector3.zero
		})
	end
	return result
end

-- ROUTE
local function getRouteFolder()
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)
	if not folder then folder = Instance.new("Folder"); folder.Name=CFG.RouteFolderName; folder.Parent=workspace end
	return folder
end

local function clearVisuals()
	for _, object in ipairs(state.visualNodes) do if object and object.Parent then object:Destroy() end end
	state.visualNodes = {}
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)
	if folder then folder:ClearAllChildren() end
end

local function createRouteSegment(p1,p2)
	if not p1 or not p2 then return end
	local offset = p2-p1
	local distance = offset.Magnitude
	if distance < CFG.MinDistance then return end
	local line = Instance.new("Part")
	line.Name="VisualNode"; line.Anchored=true; line.CanCollide=false; line.CanTouch=false; line.CanQuery=false
	line.CastShadow=false; line.Material=Enum.Material.Neon; line.Color=CFG.LineColor
	line.Size=Vector3.new(0.055,0.055,distance); line.CFrame=CFrame.lookAt(p1:Lerp(p2,0.5),p2)
	line.Transparency=state.lineVisible and 0 or 1; line.Parent=getRouteFolder()
	table.insert(state.visualNodes,line)
end

local function rebuildRoute()
	clearVisuals()
	if #state.timeline < 2 then return end
	local previousPosition
	for _, node in ipairs(state.timeline) do
		if node.Position then
			if previousPosition then createRouteSegment(previousPosition,node.Position) end
			previousPosition=node.Position
		end
	end
end

-- SAVE / LOAD
local function saveToDisk()
	local exportData = {}
	for slot,data in pairs(state.savedFiles) do
		if data and data.timeline and #data.timeline > 0 then
			local encoded={}
			for _,node in ipairs(data.timeline) do
				if node.CFrame and node.Position then
					local rounded={}
					for _,v in ipairs({node.CFrame:GetComponents()}) do table.insert(rounded,math.round(v*1000)/1000) end
					table.insert(encoded,{
						C=rounded,
						P={math.round(node.Position.X*100)/100,math.round(node.Position.Y*100)/100,math.round(node.Position.Z*100)/100},
						T=math.round((node.Timestamp or 0)*1000)/1000,
						J=node.Jump==true,W=node.WalkSpeed or 16,
						S=tostring(node.HumanoidState or Enum.HumanoidStateType.Running),
						D=node.MovementDirection and {node.MovementDirection.X,node.MovementDirection.Y,node.MovementDirection.Z} or {0,0,0}
					})
				end
			end
			exportData[tostring(slot)]={timeline=encoded}
		end
	end
	state.memoryStorage=exportData
	pcall(function()
		if typeof(writefile)=="function" then writefile(CFG.SaveFileName,HttpService:JSONEncode(exportData)) end
	end)
end

local function loadFromDisk()
	local decoded
	pcall(function()
		if typeof(readfile)=="function" then
			local success,content=pcall(function() return readfile(CFG.SaveFileName) end)
			if success and content and content~="" then
				local ok,result=pcall(function() return HttpService:JSONDecode(content) end)
				if ok then decoded=result end
			end
		end
	end)
	if not decoded and next(state.memoryStorage) then decoded=state.memoryStorage end
	if type(decoded)~="table" then return end

	for slot,data in pairs(decoded) do
		if data and type(data.timeline)=="table" then
			local timeline={}
			for _,node in ipairs(data.timeline) do
				local cf,pos
				if node.C and type(node.C)=="table" and #node.C==12 then
					pcall(function() cf=CFrame.new(table.unpack(node.C)) end)
					if cf then pos=cf.Position end
				elseif node.P and type(node.P)=="table" and #node.P==3 then
					pos=Vector3.new(node.P[1],node.P[2],node.P[3]); cf=CFrame.new(pos)
				end
				if pos and cf then
					local direction=Vector3.zero
					if node.D and type(node.D)=="table" and #node.D==3 then direction=Vector3.new(node.D[1],node.D[2],node.D[3]) end
					table.insert(timeline,{
						CFrame=cf,Position=pos,Timestamp=tonumber(node.T) or 0,RelativeTimestamp=0,
						Jump=node.J==true,WalkSpeed=tonumber(node.W) or 16,HumanoidState=node.S,MovementDirection=direction
					})
				end
			end
			normalizeTimeline(timeline)
			state.savedFiles[tonumber(slot) or slot]={timeline=timeline}
		end
	end
end

loadFromDisk()

-- GUI
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="AldoKnightXorzV445Gui"; ScreenGui.ResetOnSpawn=false; ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.Parent=PlayerGui

local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"; OpenMenu.Size=UDim2.fromOffset(CFG.OpenButtonSize,CFG.OpenButtonSize)
OpenMenu.Position=UDim2.new(0.05,0,0.5,0); OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2; OpenMenu.BorderSizePixel=0; OpenMenu.AutoButtonColor=false; OpenMenu.ZIndex=20; OpenMenu.Parent=ScreenGui
Instance.new("UICorner",OpenMenu).CornerRadius=UDim.new(0,8)
local OpenStroke=Instance.new("UIStroke",OpenMenu); OpenStroke.Thickness=2; OpenStroke.Color=Color3.fromRGB(255,255,255)

local IconImage=Instance.new("ImageLabel",OpenMenu)
IconImage.Name="Icon"; IconImage.Size=UDim2.new(0.8,0,0.8,0); IconImage.Position=UDim2.new(0.1,0,0.1,0)
IconImage.BackgroundTransparency=1; IconImage.Image="rbxassetid://101640388423900"; IconImage.ZIndex=21

local MainFrame=Instance.new("Frame",ScreenGui)
MainFrame.Name="MainFrame"; MainFrame.Size=UDim2.fromOffset(550,325); MainFrame.Position=UDim2.new(0.5,-275,0.5,-162)
MainFrame.BackgroundColor3=Color3.fromRGB(15,15,20); MainFrame.BorderSizePixel=0; MainFrame.Active=true
MainFrame.Visible=false; MainFrame.ZIndex=5
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,12)
local MainStroke=Instance.new("UIStroke",MainFrame); MainStroke.Thickness=2; MainStroke.Color=CFG.AccentColor

-- OPEN BUTTON DRAG
local openDragging,openMoved=false,false
local openDragStart,openStartPos
addConnection(OpenMenu.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		openDragging=true; openMoved=false; openDragStart=input.Position; openStartPos=OpenMenu.Position
	end
end))
addConnection(UserInputService.InputChanged:Connect(function(input)
	if not openDragging then return end
	if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
		local delta=input.Position-openDragStart
		if delta.Magnitude>8 then
			openMoved=true
			OpenMenu.Position=UDim2.new(openStartPos.X.Scale,openStartPos.X.Offset+delta.X,openStartPos.Y.Scale,openStartPos.Y.Offset+delta.Y)
		end
	end
end))
addConnection(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then openDragging=false end
end))

local Title=Instance.new("TextLabel",MainFrame)
Title.Size=UDim2.new(1,0,0,35); Title.Text="ALDO KNIGHTXORZ V4.45 ULTRA SMOOTH"
Title.TextColor3=Color3.fromRGB(255,255,255); Title.Font=Enum.Font.GothamBold; Title.TextSize=13; Title.BackgroundTransparency=1; Title.ZIndex=6

local StatusLabel=Instance.new("TextLabel",MainFrame)
StatusLabel.Name="StatusLabel"; StatusLabel.Size=UDim2.new(1,0,0,25); StatusLabel.Position=UDim2.new(0,0,0,35)
StatusLabel.Text="Status: IDLE"; StatusLabel.TextColor3=CFG.LineColor; StatusLabel.Font=Enum.Font.GothamBold
StatusLabel.TextSize=11; StatusLabel.BackgroundTransparency=1; StatusLabel.ZIndex=6

local ScrollingContainer=Instance.new("ScrollingFrame",MainFrame)
ScrollingContainer.Size=UDim2.new(1,-20,1,-75); ScrollingContainer.Position=UDim2.new(0,10,0,65)
ScrollingContainer.BackgroundTransparency=1; ScrollingContainer.BorderSizePixel=0; ScrollingContainer.ScrollBarThickness=4
ScrollingContainer.ScrollBarImageColor3=CFG.AccentColor; ScrollingContainer.AutomaticCanvasSize=Enum.AutomaticSize.Y
ScrollingContainer.CanvasSize=UDim2.new(); ScrollingContainer.ZIndex=6

local UIGrid=Instance.new("UIGridLayout",ScrollingContainer)
UIGrid.CellSize=UDim2.fromOffset(120,39); UIGrid.CellPadding=UDim2.fromOffset(8,8); UIGrid.SortOrder=Enum.SortOrder.LayoutOrder

local function updateStatus(text)
	if StatusLabel and StatusLabel.Parent then StatusLabel.Text="Status: "..tostring(text).." | File: "..state.selectedFile.." | Cut: "..state.cutStart.."-"..state.cutEnd end
end

local function createButton(text,order,callback)
	local button=Instance.new("TextButton",ScrollingContainer)
	button.Name="Button_"..order; button.Size=UDim2.fromOffset(120,39); button.BackgroundColor3=CFG.ButtonColor
	button.BorderSizePixel=0; button.Text=text; button.TextColor3=Color3.fromRGB(230,230,230)
	button.Font=Enum.Font.GothamBold; button.TextSize=11; button.AutoButtonColor=false; button.LayoutOrder=order; button.ZIndex=8
	Instance.new("UICorner",button).CornerRadius=UDim.new(0,6)
	local stroke=Instance.new("UIStroke",button); stroke.Thickness=1; stroke.Color=Color3.fromRGB(70,70,90)
	addConnection(button.Activated:Connect(function()
		TweenService:Create(button,TweenInfo.new(0.07,Enum.EasingStyle.Quad),{BackgroundColor3=CFG.AccentColor}):Play()
		task.defer(function()
			local success,err=pcall(callback)
			if not success then warn("[ALDO KNIGHTXORZ V4.45]",err) end
			if button.Parent then TweenService:Create(button,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{BackgroundColor3=CFG.ButtonColor}):Play() end
		end)
	end))
	return button
end

addConnection(OpenMenu.Activated:Connect(function()
	if openMoved then openMoved=false; return end
	MainFrame.Visible=not MainFrame.Visible
end))

-- KINEMATIC
local function saveKinematicState()
	if not isCharacterAlive() then return false end
	state.savedRootState={Anchored=RootPart.Anchored,CanCollide=RootPart.CanCollide,CanTouch=RootPart.CanTouch,CanQuery=RootPart.CanQuery}
	state.savedHumanoidState={AutoRotate=Humanoid.AutoRotate,PlatformStand=Humanoid.PlatformStand,WalkSpeed=Humanoid.WalkSpeed,JumpPower=Humanoid.JumpPower,JumpHeight=Humanoid.JumpHeight}
	return true
end

local function zeroRootPhysics()
	if RootPart and RootPart.Parent then pcall(function() RootPart.AssemblyLinearVelocity=Vector3.zero; RootPart.AssemblyAngularVelocity=Vector3.zero end) end
end

local function enableKinematic()
	if not isCharacterAlive() then return false end
	if state.kinematicActive then return true end
	saveKinematicState()
	Humanoid.AutoRotate=false; Humanoid.PlatformStand=false
	RootPart.Anchored=true; RootPart.CanCollide=false; RootPart.CanTouch=false; RootPart.CanQuery=false
	zeroRootPhysics(); state.kinematicActive=true
	return true
end

local function disableKinematic()
	if not state.kinematicActive then return end
	if RootPart and RootPart.Parent then
		local saved=state.savedRootState
		pcall(function()
			RootPart.Anchored=saved and saved.Anchored or false
			RootPart.CanCollide=saved and saved.CanCollide or true
			RootPart.CanTouch=saved and saved.CanTouch or true
			RootPart.CanQuery=saved and saved.CanQuery or true
			RootPart.AssemblyLinearVelocity=Vector3.zero; RootPart.AssemblyAngularVelocity=Vector3.zero
		end)
	end
	if Humanoid and Humanoid.Parent then
		local saved=state.savedHumanoidState
		pcall(function()
			Humanoid.AutoRotate=saved and saved.AutoRotate or true
			Humanoid.PlatformStand=saved and saved.PlatformStand or false
			if saved then Humanoid.WalkSpeed=saved.WalkSpeed; Humanoid.JumpPower=saved.JumpPower; Humanoid.JumpHeight=saved.JumpHeight end
		end)
	end
	state.savedRootState=nil; state.savedHumanoidState=nil; state.kinematicActive=false
end

-- RECORD
local function beginRecording()
	if not isCharacterAlive() then return end
	if state.isPlaying then stopPlayback(true) end
	state.isRecording=true; state.timeline={}; state.startTime=os.clock(); state.lastRecordTime=0
	state.lastJumpState=false; state.cutStart=1; state.cutEnd=1; clearVisuals(); updateStatus("RECORDING")
end

local function finishRecording()
	state.isRecording=false; normalizeTimeline(state.timeline); state.cutStart=1
	state.cutEnd=math.max(1,#state.timeline); rebuildRoute(); updateStatus("IDLE")
end

RunService:BindToRenderStep(BIND_RECORD,Enum.RenderPriority.Character.Value,function()
	if not state.isRecording or not isCharacterAlive() then return end
	local now=os.clock()
	if now-state.lastRecordTime<CFG.NodeInterval then return end
	state.lastRecordTime=now
	local cf=RootPart.CFrame
	local position=cf.Position
	local timestamp=now-state.startTime
	local humanoidState=Humanoid:GetState()
	local jumping=humanoidState==Enum.HumanoidStateType.Jumping or humanoidState==Enum.HumanoidStateType.Freefall
	local jumpTrigger=jumping and not state.lastJumpState
	state.lastJumpState=jumping
	local movement=Humanoid.MoveDirection

	if #state.timeline==0 then
		table.insert(state.timeline,{CFrame=cf,Position=position,Timestamp=timestamp,RelativeTimestamp=0,Jump=jumpTrigger,WalkSpeed=Humanoid.WalkSpeed,HumanoidState=humanoidState,MovementDirection=movement})
		state.cutEnd=1
		return
	end

	local previous=state.timeline[#state.timeline]
	if (position-previous.Position).Magnitude>=CFG.MinDistance or jumpTrigger then
		createRouteSegment(previous.Position,position)
		table.insert(state.timeline,{CFrame=cf,Position=position,Timestamp=timestamp,RelativeTimestamp=0,Jump=jumpTrigger,WalkSpeed=Humanoid.WalkSpeed,HumanoidState=humanoidState,MovementDirection=movement})
		normalizeTimeline(state.timeline); state.cutEnd=#state.timeline
	end
end)

-- PLAYBACK
local function smoothAlpha(alpha)
	alpha=math.clamp(alpha,0,1)
	if CFG.InterpolationPower<=0 then return alpha end
	return alpha*alpha*(3-2*alpha)
end

local function getPlaybackCFrame(timeline,playbackTime)
	local count=#timeline
	if count==0 then return nil end
	if count==1 or playbackTime<=0 then return timeline[1].CFrame end
	local last=timeline[count]
	if playbackTime>=last.RelativeTimestamp then return last.CFrame end

	local low,high=1,count
	while low<=high do
		local middle=math.floor((low+high)/2)
		if timeline[middle].RelativeTimestamp<=playbackTime then low=middle+1 else high=middle-1 end
	end

	local indexA=math.clamp(high,1,count-1)
	local indexB=indexA+1
	local nodeA,nodeB=timeline[indexA],timeline[indexB]
	local duration=nodeB.RelativeTimestamp-nodeA.RelativeTimestamp
	if duration<=0 then return nodeB.CFrame end
	local alpha=math.clamp((playbackTime-nodeA.RelativeTimestamp)/duration,0,1)
	return nodeA.CFrame:Lerp(nodeB.CFrame,smoothAlpha(alpha))
end

stopPlayback=function(manualStop)
	state.isPlaying=false; state.isPaused=false; state.playbackID+=1
	pcall(function() RunService:UnbindFromRenderStep(BIND_PLAYBACK) end)
	disableKinematic()
	if manualStop then state.isAutoWalk=false end
	state.playbackTime=0; state.playbackStartClock=0; state.pauseClock=0
	if isCharacterAlive() then zeroRootPhysics() end
	updateStatus("IDLE")
end

local function executePlayback()
	if state.isRecording or state.isPlaying then return end
	if not isCharacterAlive() then updateStatus("CHARACTER ERROR"); return end
	if #state.timeline<2 then updateStatus("NO ROUTE"); return end
	normalizeTimeline(state.timeline)
	if not enableKinematic() then updateStatus("CHARACTER ERROR"); return end

	state.isPlaying=true; state.isPaused=false; state.playbackID+=1
	local playbackID=state.playbackID
	local timeline=state.timeline
	state.playbackTime=0
	local totalDuration=timeline[#timeline].RelativeTimestamp
	local startCFrame=timeline[1].CFrame

	RootPart.CFrame=startCFrame; zeroRootPhysics()
	state.playbackStartClock=os.clock(); state.pauseClock=0
	updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
	pcall(function() RunService:UnbindFromRenderStep(BIND_PLAYBACK) end)

	RunService:BindToRenderStep(BIND_PLAYBACK,Enum.RenderPriority.Character.Value,function()
		if not state.isPlaying or state.playbackID~=playbackID then return end
		if not isCharacterAlive() then stopPlayback(false); return end
		if state.isPaused then return end

		state.playbackTime=(os.clock()-state.playbackStartClock)*CFG.PlaybackSpeed

		if state.playbackTime>=totalDuration-CFG.EndTolerance then
			RootPart.CFrame=timeline[#timeline].CFrame; zeroRootPhysics()
			if state.isAutoWalk then
				state.playbackTime=0; state.playbackStartClock=os.clock(); RootPart.CFrame=startCFrame; zeroRootPhysics(); updateStatus("AUTO WALK")
				return
			end
			stopPlayback(false); return
		end

		local targetCFrame=getPlaybackCFrame(timeline,state.playbackTime)
		if targetCFrame then RootPart.CFrame=targetCFrame end
		zeroRootPhysics()
	end)
end

local function togglePause()
	if not state.isPlaying then return end
	if not state.isPaused then
		state.isPaused=true; state.pauseClock=os.clock(); updateStatus("PAUSED")
	else
		local pauseDuration=os.clock()-state.pauseClock
		state.playbackStartClock+=pauseDuration
		state.isPaused=false; state.pauseClock=0
		updateStatus(state.isAutoWalk and "AUTO WALK" or "PLAYING")
	end
end

local function toggleAutoWalk()
	if state.isRecording then return end
	if state.isAutoWalk then
		state.isAutoWalk=false; stopPlayback(true); updateStatus("AUTO WALK OFF"); return
	end
	if #state.timeline<2 then updateStatus("NO ROUTE"); return end
	state.isAutoWalk=true; updateStatus("AUTO WALK ON")
	if not state.isPlaying then executePlayback() end
end

-- BUTTONS
createButton("RECORD START",1,function() if state.isRecording then finishRecording() else beginRecording() end end)
createButton("PLAY ROUTE",2,function() if not state.isRecording then state.isAutoWalk=false; if not state.isPlaying then executePlayback() end end)
createButton("PAUSE / RES",3,togglePause)
createButton("AUTO WALK",4,toggleAutoWalk)
createButton("STOP",5,function() stopPlayback(true) end)

createButton("<< CUT",6,function()
	if #state.timeline<=2 then return end
	state.cutStart=math.clamp(state.cutStart+1,1,math.max(1,state.cutEnd-1)); updateStatus("CUT CONFIG")
end)

createButton("CUT >>",7,function()
	if #state.timeline<=2 then return end
	state.cutEnd=math.clamp(state.cutEnd-1,math.min(#state.timeline,state.cutStart+1),#state.timeline); updateStatus("CUT CONFIG")
end)

createButton("APPLY CUT",8,function()
	if #state.timeline<=2 or state.cutStart>=state.cutEnd then return end
	local newTimeline={}
	for i=state.cutStart,state.cutEnd do
		local node=state.timeline[i]
		table.insert(newTimeline,{CFrame=node.CFrame,Position=node.Position,Timestamp=node.Timestamp,RelativeTimestamp=0,Jump=node.Jump,WalkSpeed=node.WalkSpeed,HumanoidState=node.HumanoidState,MovementDirection=node.MovementDirection})
	end
	normalizeTimeline(newTimeline); state.timeline=newTimeline; state.cutStart=1; state.cutEnd=#state.timeline
	rebuildRoute(); updateStatus("CUT APPLIED")
end)

createButton("PUT TOGETHER",9,function()
	local base=state.savedFiles[state.selectedFile]
	if not base or not base.timeline or #base.timeline==0 then updateStatus("BASE FILE EMPTY"); return end
	if #state.timeline==0 then updateStatus("CURRENT ROUTE EMPTY"); return end

	local merged=cloneTimeline(base.timeline)
	normalizeTimeline(merged)
	local offset=merged[#merged].RelativeTimestamp+CFG.NodeInterval
	local baseTimestamp=merged[1].Timestamp

	for _,node in ipairs(state.timeline) do
		local copy=cloneTimeline({node})[1]
		copy.RelativeTimestamp=offset+node.RelativeTimestamp
		copy.Timestamp=baseTimestamp+copy.RelativeTimestamp
		table.insert(merged,copy)
	end

	for i=2,#merged do
		if merged[i].Timestamp<=merged[i-1].Timestamp then merged[i].Timestamp=merged[i-1].Timestamp+CFG.NodeInterval end
	end

	normalizeTimeline(merged); state.timeline=merged; state.cutStart=1; state.cutEnd=#state.timeline
	rebuildRoute(); updateStatus("MERGED ROUTE")
end)

for i=1,5 do
	local fileNumber=i
	createButton("FILE "..i,9+i,function()
		if state.isRecording then return end
		if state.isPlaying then stopPlayback(true) end
		state.selectedFile=fileNumber; state.cutStart=1; state.cutEnd=math.max(1,#state.timeline)
		updateStatus("FILE "..fileNumber.." SELECTED")
	end)
end

createButton("SAVE FILE",15,function()
	if #state.timeline==0 then updateStatus("NOTHING TO SAVE"); return end
	normalizeTimeline(state.timeline)
	state.savedFiles[state.selectedFile]={timeline=cloneTimeline(state.timeline)}
	saveToDisk()
	updateStatus("SAVED FILE "..state.selectedFile)
end)

createButton("LOAD FILE",16,function()
	if state.isRecording then return end
	local data=state.savedFiles[state.selectedFile]
	if not data or not data.timeline or #data.timeline==0 then updateStatus("FILE EMPTY"); return end
	stopPlayback(true)
	state.timeline=cloneTimeline(data.timeline); normalizeTimeline(state.timeline)
	state.cutStart=1; state.cutEnd=#state.timeline
	rebuildRoute(); updateStatus("LOADED FILE "..state.selectedFile)
end)

createButton("CLEAR",17,function()
	stopPlayback(true); state.isRecording=false; state.timeline={}
	state.cutStart=1; state.cutEnd=1; state.lastJumpState=false
	clearVisuals(); updateStatus("CLEARED")
end)

createButton("LINE VISIBLE",18,function()
	state.lineVisible=not state.lineVisible
	local folder=workspace:FindFirstChild(CFG.RouteFolderName)
	if folder then for _,object in ipairs(folder:GetChildren()) do if object.Name=="VisualNode" then object.Transparency=state.lineVisible and 0 or 1 end end end
	updateStatus(state.lineVisible and "LINE ON" or "LINE OFF")
end)

-- CLEANUP
_G.AldoKnightXorzV445_Cleanup=function()
	state.isRecording=false; state.isPlaying=false; state.isPaused=false; state.isAutoWalk=false; state.playbackID+=1
	pcall(function() RunService:UnbindFromRenderStep(BIND_RECORD) end)
	pcall(function() RunService:UnbindFromRenderStep(BIND_PLAYBACK) end)
	disableKinematic()
	for _,connection in ipairs(currentConnections) do pcall(function() connection:Disconnect() end) end
	currentConnections={}; clearVisuals()
	pcall(function() if ScreenGui then ScreenGui:Destroy() end end)
end

updateStatus("IDLE")
