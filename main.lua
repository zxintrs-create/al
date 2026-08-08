local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local ContextActionService=game:GetService("ContextActionService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local oldGui=playerGui:FindFirstChild("DeltaMobileControls")
if oldGui then oldGui:Destroy() end

local oldErgo=playerGui:FindFirstChild("DeltaMobileErgo")
if oldErgo then oldErgo:Destroy() end

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")
local root=character:WaitForChild("HumanoidRootPart")

local connections={}

local function connect(signal,fn)
	local c=signal:Connect(fn)
	table.insert(connections,c)
	return c
end

local moveState={
	Forward=false,
	Backward=false,
	Left=false,
	Right=false,
	UpLeft=false,
	UpRight=false,
	DownLeft=false,
	DownRight=false,
	WLock=false
}

local activeInputs={}

local BLOCK_ACTION="KNIGHTXORZ_BLOCK_DEFAULT_MOVEMENT"

pcall(function()
	ContextActionService:UnbindAction(BLOCK_ACTION)
end)

if UserInputService.TouchEnabled then
	ContextActionService:BindActionAtPriority(
		BLOCK_ACTION,
		function()
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.PlayerActions.CharacterForward,
		Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft,
		Enum.PlayerActions.CharacterRight
	)
end

local function clearMovementState()
	for name in pairs(moveState) do
		moveState[name]=false
	end
	table.clear(activeInputs)
end

local function disableDefaultAnalog()
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then
		return
	end

	for _,obj in ipairs(touchGui:GetDescendants()) do
		if obj:IsA("GuiObject") then
			if obj.Name=="DynamicThumbstickFrame"
				or obj.Name=="ThumbstickFrame"
				or obj.Name=="Thumbstick" then
				obj.Visible=false
				obj.Active=false
				obj.Selectable=false
			end
		end
	end
end

local function refreshTouchGui()
	disableDefaultAnalog()
	task.delay(.03,disableDefaultAnalog)
	task.delay(.08,disableDefaultAnalog)
	task.delay(.15,disableDefaultAnalog)
	task.delay(.3,disableDefaultAnalog)
	task.delay(.6,disableDefaultAnalog)
end

refreshTouchGui()

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=100
screenGui.Parent=playerGui

local mainFrame=Instance.new("Frame")
mainFrame.Name="ControlsFrame"
mainFrame.Size=UDim2.new(0,260,0,260)
mainFrame.Position=UDim2.new(0,24,1,-290)
mainFrame.BackgroundTransparency=1
mainFrame.BorderSizePixel=0
mainFrame.Active=false
mainFrame.Parent=screenGui

local function createButton(name,pos,size,text)
	local btn=Instance.new("TextButton")
	btn.Name=name
	btn.Position=pos
	btn.Size=size
	btn.Text=text
	btn.BackgroundColor3=Color3.fromRGB(30,30,30)
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.TextSize=24
	btn.AutoButtonColor=false
	btn.Active=true
	btn.Selectable=false
	btn.BorderSizePixel=0
	btn.ZIndex=10

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,12)
	corner.Parent=btn

	btn.Parent=mainFrame

	return btn
end

local btnUp=createButton(
	"Up",
	UDim2.new(.35,0,0,0),
	UDim2.new(.3,0,.3,0),
	"▲"
)

local btnDown=createButton(
	"Down",
	UDim2.new(.35,0,.7,0),
	UDim2.new(.3,0,.3,0),
	"▼"
)

local btnLeft=createButton(
	"Left",
	UDim2.new(0,0,.35,0),
	UDim2.new(.3,0,.3,0),
	"◀"
)

local btnRight=createButton(
	"Right",
	UDim2.new(.7,0,.35,0),
	UDim2.new(.3,0,.3,0),
	"▶"
)

local btnUL=createButton(
	"UpLeft",
	UDim2.new(.08,0,.08,0),
	UDim2.new(.22,0,.22,0),
	"↖"
)

local btnUR=createButton(
	"UpRight",
	UDim2.new(.70,0,.08,0),
	UDim2.new(.22,0,.22,0),
	"↗"
)

local btnDL=createButton(
	"DownLeft",
	UDim2.new(.08,0,.70,0),
	UDim2.new(.22,0,.22,0),
	"↙"
)

local btnDR=createButton(
	"DownRight",
	UDim2.new(.70,0,.70,0),
	UDim2.new(.22,0,.22,0),
	"↘"
)

local btnWLock=Instance.new("TextButton")
btnWLock.Name="WLock"
btnWLock.Position=UDim2.new(.35,0,.35,0)
btnWLock.Size=UDim2.new(.3,0,.3,0)
btnWLock.Text="W"
btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
btnWLock.TextColor3=Color3.new(1,1,1)
btnWLock.Font=Enum.Font.GothamBold
btnWLock.TextSize=24
btnWLock.AutoButtonColor=false
btnWLock.Active=true
btnWLock.Selectable=false
btnWLock.BorderSizePixel=0
btnWLock.ZIndex=11

local centerCorner=Instance.new("UICorner")
centerCorner.CornerRadius=UDim.new(1,0)
centerCorner.Parent=btnWLock
btnWLock.Parent=mainFrame

local function updateWLock()
	if moveState.WLock then
		btnWLock.BackgroundColor3=Color3.fromRGB(0,150,0)
	else
		btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
	end
end

local function isPressInput(input)
	return input.UserInputType==Enum.UserInputType.Touch
		or input.UserInputType==Enum.UserInputType.MouseButton1
end

local function clearInput(input)
	if not input then
		table.clear(activeInputs)
		return
	end

	for name,active in pairs(activeInputs) do
		if active==input then
			activeInputs[name]=nil
			moveState[name]=false
		end
	end
end

local function bind(btn,name)
	connect(btn.InputBegan,function(input)
		if not isPressInput(input) then
			return
		end

		activeInputs[name]=input
		moveState[name]=true
	end)

	connect(btn.InputEnded,function(input)
		if activeInputs[name]==input then
			activeInputs[name]=nil
			moveState[name]=false
		end
	end)
end

bind(btnUp,"Forward")
bind(btnDown,"Backward")
bind(btnLeft,"Left")
bind(btnRight,"Right")
bind(btnUL,"UpLeft")
bind(btnUR,"UpRight")
bind(btnDL,"DownLeft")
bind(btnDR,"DownRight")

connect(UserInputService.InputEnded,clearInput)
connect(UserInputService.TouchEnded,clearInput)

local wDebounce=false

connect(btnWLock.InputBegan,function(input)
	if not isPressInput(input) then
		return
	end

	if wDebounce then
		return
	end

	wDebounce=true
	moveState.WLock=not moveState.WLock
	updateWLock()

	task.delay(.12,function()
		wDebounce=false
	end)
end)

updateWLock()

local function getMoveVector()
	local camera=workspace.CurrentCamera

	if not camera then
		return Vector3.zero
	end

	local look=Vector3.new(
		camera.CFrame.LookVector.X,
		0,
		camera.CFrame.LookVector.Z
	)

	local right=Vector3.new(
		camera.CFrame.RightVector.X,
		0,
		camera.CFrame.RightVector.Z
	)

	if look.Magnitude<.001 or right.Magnitude<.001 then
		return Vector3.zero
	end

	look=look.Unit
	right=right.Unit

	local move=Vector3.zero

	if moveState.WLock then
		move=move+look
	end

	if moveState.Forward then
		move=move+look
	end

	if moveState.Backward then
		move=move-look
	end

	if moveState.Left then
		move=move-right
	end

	if moveState.Right then
		move=move+right
	end

	if moveState.UpLeft then
		move=move+look-right
	end

	if moveState.UpRight then
		move=move+look+right
	end

	if moveState.DownLeft then
		move=move-look-right
	end

	if moveState.DownRight then
		move=move-look+right
	end

	if move.Magnitude>.001 then
		return move.Unit
	end

	return Vector3.zero
end

local AIR_RESPONSE=18
local AIR_BRAKE=3
local AIR_MAX_SPEED=100

connect(RunService.RenderStepped,function(dt)
	if not character
		or not character.Parent
		or not humanoid
		or not root then
		return
	end

	if humanoid.Health<=0 then
		return
	end

	local move=getMoveVector()
	local state=humanoid:GetState()

	local airborne=
		state==Enum.HumanoidStateType.Freefall
		or state==Enum.HumanoidStateType.Jumping

	if not airborne then
		humanoid:Move(move,false)
		return
	end

	local velocity=root.AssemblyLinearVelocity

	local horizontal=Vector3.new(
		velocity.X,
		0,
		velocity.Z
	)

	if move.Magnitude>.001 then
		local speed=math.clamp(
			humanoid.WalkSpeed,
			0,
			AIR_MAX_SPEED
		)

		local target=move*speed
		local response=1-math.exp(-AIR_RESPONSE*dt)

		local newHorizontal=horizontal:Lerp(
			target,
			response
		)

		root.AssemblyLinearVelocity=Vector3.new(
			newHorizontal.X,
			velocity.Y,
			newHorizontal.Z
		)
	else
		local brake=math.exp(-AIR_BRAKE*dt)

		local newHorizontal=horizontal*brake

		root.AssemblyLinearVelocity=Vector3.new(
			newHorizontal.X,
			velocity.Y,
			newHorizontal.Z
		)
	end
end)

connect(player.CharacterAdded,function(newCharacter)
	clearMovementState()
	clearInput(nil)

	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid")
	root=newCharacter:WaitForChild("HumanoidRootPart")

	updateWLock()
	refreshTouchGui()
end)

local x=.70
local y=.70
local size=.30
local step=.018

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=102
gui.Parent=playerGui

local function makeButton(parent,name,pos,sz,text,bg,z)
	local b=Instance.new("TextButton")
	b.Name=name
	b.Position=pos
	b.Size=sz
	b.Text=text
	b.BackgroundColor3=bg or Color3.fromRGB(35,35,35)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=20
	b.AutoButtonColor=false
	b.Active=true
	b.Selectable=false
	b.BorderSizePixel=0
	b.ZIndex=z or 10

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,10)
	c.Parent=b

	b.Parent=parent

	return b
end

local menu=makeButton(
	gui,
	"OpenMenu",
	UDim2.new(1,-60,1,-60),
	UDim2.new(0,48,0,48),
	"⚙",
	Color3.fromRGB(30,30,30),
	50
)

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

local set=Instance.new("Frame")
set.Name="SettingsFrame"
set.Size=UDim2.new(0,280,0,340)
set.Position=UDim2.new(.5,-140,.5,-170)
set.BackgroundColor3=Color3.fromRGB(25,25,25)
set.BorderSizePixel=0
set.Visible=false
set.ZIndex=40
set.Parent=gui

local setCorner=Instance.new("UICorner")
setCorner.CornerRadius=UDim.new(0,14)
setCorner.Parent=set

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="JUMP SETTINGS"
title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold
title.TextSize=20
title.ZIndex=41
title.Parent=set

local up=makeButton(
	set,
	"MoveUp",
	UDim2.new(.5,-30,0,48),
	UDim2.new(0,60,0,42),
	"↑",
	nil,
	41
)

local left=makeButton(
	set,
	"MoveLeft",
	UDim2.new(.12,0,0,95),
	UDim2.new(0,60,0,42),
	"←",
	nil,
	41
)

local right=makeButton(
	set,
	"MoveRight",
	UDim2.new(.88,-60,0,95),
	UDim2.new(0,60,0,42),
	"→",
	nil,
	41
)

local down=makeButton(
	set,
	"MoveDown",
	UDim2.new(.5,-30,0,142),
	UDim2.new(0,60,0,42),
	"↓",
	nil,
	41
)

local plus=makeButton(
	set,
	"SizePlus",
	UDim2.new(.08,0,0,200),
	UDim2.new(0,90,0,42),
	"SIZE +",
	nil,
	41
)

local minus=makeButton(
	set,
	"SizeMinus",
	UDim2.new(.92,-90,0,200),
	UDim2.new(0,90,0,42),
	"SIZE -",
	nil,
	41
)

local centerX=makeButton(
	set,
	"CenterX",
	UDim2.new(.5,-45,0,250),
	UDim2.new(0,90,0,36),
	"CENTER",
	nil,
	41
)

local close=makeButton(
	set,
	"Close",
	UDim2.new(.5,-90,1,-45),
	UDim2.new(0,180,0,34),
	"CLOSE",
	Color3.fromRGB(150,0,0),
	41
)

local jump=nil

local function findJump()
	local touch=playerGui:FindFirstChild("TouchGui")

	if not touch then
		return nil
	end

	local j=touch:FindFirstChild("JumpButton",true)

	if j and j:IsA("GuiObject") then
		return j
	end

	return nil
end

local function getJump()
	if jump
		and jump.Parent
		and jump:IsDescendantOf(playerGui)
		and jump:IsA("GuiObject") then
		return true
	end

	jump=findJump()

	return jump~=nil
end

local function updateJump()
	if not getJump() then
		return
	end

	local camera=workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport=camera.ViewportSize

	if viewport.X<=0 or viewport.Y<=0 then
		return
	end

	size=math.clamp(size,.05,.70)
	x=math.clamp(x,-1,2)
	y=math.clamp(y,-1,2)

	local pixelSize=math.max(
		1,
		math.floor(viewport.Y*size)
	)

	jump.AnchorPoint=Vector2.new(.5,.5)

	jump.Position=UDim2.new(
		x,
		0,
		y,
		0
	)

	jump.Size=UDim2.fromOffset(
		pixelSize,
		pixelSize
	)
end

local holding={
	[up]=false,
	[down]=false,
	[left]=false,
	[right]=false
}

local holdInputs={
	[up]=nil,
	[down]=nil,
	[left]=nil,
	[right]=nil
}

local function clearHoldInputs()
	for button in pairs(holding) do
		holding[button]=false
		holdInputs[button]=nil
	end
end

local function isControlInput(input)
	return input.UserInputType==Enum.UserInputType.Touch
		or input.UserInputType==Enum.UserInputType.MouseButton1
end

local function holdMove(button,dx,dy)
	connect(button.InputBegan,function(input)
		if not isControlInput(input) then
			return
		end

		holdInputs[button]=input
		holding[button]=true

		x=math.clamp(x+dx,-1,2)
		y=math.clamp(y+dy,-1,2)

		updateJump()
	end)

	connect(button.InputEnded,function(input)
		if holdInputs[button]==input then
			holdInputs[button]=nil
			holding[button]=false
		end
	end)
end

holdMove(up,0,-step)
holdMove(down,0,step)
holdMove(left,-step,0)
holdMove(right,step,0)

connect(UserInputService.InputEnded,function(input)
	for button,active in pairs(holdInputs) do
		if active==input then
			holdInputs[button]=nil
			holding[button]=false
		end
	end
end)

connect(UserInputService.TouchEnded,function(input)
	for button,active in pairs(holdInputs) do
		if active==input then
			holdInputs[button]=nil
			holding[button]=false
		end
	end
end)

connect(RunService.RenderStepped,function()
	local moved=false

	if holding[up] then
		y=math.clamp(y-step,-1,2)
		moved=true
	end

	if holding[down] then
		y=math.clamp(y+step,-1,2)
		moved=true
	end

	if holding[left] then
		x=math.clamp(x-step,-1,2)
		moved=true
	end

	if holding[right] then
		x=math.clamp(x+step,-1,2)
		moved=true
	end

	if moved then
		updateJump()
	end
end)

connect(plus.Activated,function()
	size=math.clamp(size+.05,.05,.70)
	updateJump()
end)

connect(minus.Activated,function()
	size=math.clamp(size-.05,.05,.70)
	updateJump()
end)

connect(centerX.Activated,function()
	x=.5
	y=.5
	updateJump()
end)

connect(menu.Activated,function()
	set.Visible=not set.Visible
	updateJump()
end)

connect(close.Activated,function()
	set.Visible=false
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		clearMovementState()
		clearHoldInputs()

		task.delay(.1,function()
			jump=nil
			refreshTouchGui()
			updateJump()
		end)
	end
end)

task.spawn(function()
	for i=1,100 do
		if getJump() then
			updateJump()
			break
		end

		task.wait(.1)
	end
end)

connect(
	workspace:GetPropertyChangedSignal("CurrentCamera"),
	function()
		task.defer(updateJump)
	end
)

updateJump()
