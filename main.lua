local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local ContextActionService=game:GetService("ContextActionService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local oldGui=playerGui:FindFirstChild("DeltaMobileControls")
if oldGui then oldGui:Destroy() end

local oldConnections=playerGui:FindFirstChild("DeltaMobileConnections")
if oldConnections then oldConnections:Destroy() end

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")

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

local function disableDefaultAnalog()
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then return end

	for _,obj in ipairs(touchGui:GetDescendants()) do
		if obj:IsA("GuiObject") and (
			obj.Name=="DynamicThumbstickFrame" or
			obj.Name=="ThumbstickFrame" or
			obj.Name=="Thumbstick"
		) then
			obj.Visible=false
			obj.Active=false
			obj.Selectable=false
		end
	end
end

local function refreshTouchGui()
	disableDefaultAnalog()
	task.delay(.05,disableDefaultAnalog)
	task.delay(.15,disableDefaultAnalog)
	task.delay(.3,disableDefaultAnalog)
	task.delay(.6,disableDefaultAnalog)
end

refreshTouchGui()

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		task.defer(refreshTouchGui)
	end
end)

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

local btnUp=createButton("Up",UDim2.new(.35,0,0,0),UDim2.new(.3,0,.3,0),"▲")
local btnDown=createButton("Down",UDim2.new(.35,0,.7,0),UDim2.new(.3,0,.3,0),"▼")
local btnLeft=createButton("Left",UDim2.new(0,0,.35,0),UDim2.new(.3,0,.3,0),"◀")
local btnRight=createButton("Right",UDim2.new(.7,0,.35,0),UDim2.new(.3,0,.3,0),"▶")

local btnUL=createButton("UpLeft",UDim2.new(.08,0,.08,0),UDim2.new(.22,0,.22,0),"↖")
local btnUR=createButton("UpRight",UDim2.new(.70,0,.08,0),UDim2.new(.22,0,.22,0),"↗")
local btnDL=createButton("DownLeft",UDim2.new(.08,0,.70,0),UDim2.new(.22,0,.22,0),"↙")
local btnDR=createButton("DownRight",UDim2.new(.70,0,.70,0),UDim2.new(.22,0,.22,0),"↘")

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
	btnWLock.BackgroundColor3=moveState.WLock
		and Color3.fromRGB(0,150,0)
		or Color3.fromRGB(150,0,0)
end

local function isPressInput(input)
	local t=input.UserInputType
	return t==Enum.UserInputType.Touch
		or t==Enum.UserInputType.MouseButton1
end

local function clearInput(input)
	for name,active in pairs(activeInputs) do
		if active==input then
			activeInputs[name]=nil
			moveState[name]=false
		end
	end
end

local function bind(btn,name)
	connect(btn.InputBegan,function(input)
		if not isPressInput(input) then return end
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

local wDebounce=false

connect(btnWLock.InputBegan,function(input)
	if not isPressInput(input) or wDebounce then return end

	wDebounce=true
	moveState.WLock=not moveState.WLock
	updateWLock()

	task.delay(.12,function()
		wDebounce=false
	end)
end)

updateWLock()

local function getCameraDirections()
	local camera=workspace.CurrentCamera

	if not camera then
		return Vector3.new(0,0,-1),Vector3.new(1,0,0)
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

	if look.Magnitude>.001 then
		look=look.Unit
	else
		look=Vector3.new(0,0,-1)
	end

	if right.Magnitude>.001 then
		right=right.Unit
	else
		right=Vector3.new(1,0,0)
	end

	return look,right
end

local diagonalOrder={
	{"UpLeft","UpRight","DownLeft","DownRight"}
}

local function getMoveVector()
	local look,right=getCameraDirections()

	local diagonal=nil

	for _,name in ipairs(diagonalOrder[1]) do
		if moveState[name] then
			diagonal=name
			break
		end
	end

	if diagonal=="UpLeft" then
		return (look-right).Unit
	elseif diagonal=="UpRight" then
		return (look+right).Unit
	elseif diagonal=="DownLeft" then
		return (-look-right).Unit
	elseif diagonal=="DownRight" then
		return (-look+right).Unit
	end

	local move=Vector3.zero

	if moveState.Forward then
		move+=look
	end

	if moveState.Backward then
		move-=look
	end

	if moveState.Left then
		move-=right
	end

	if moveState.Right then
		move+=right
	end

	if moveState.WLock then
		move+=look

		if moveState.Backward then
			move-=look
		end
	end

	if move.Magnitude>.001 then
		return move.Unit
	end

	return Vector3.zero
end

connect(RunService.RenderStepped,function()
	if not character or not humanoid or humanoid.Health<=0 then
		return
	end

	humanoid:Move(getMoveVector(),false)
end)

connect(player.CharacterAdded,function(newCharacter)
	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid")

	for name in pairs(moveState) do
		moveState[name]=false
	end

	for name in pairs(activeInputs) do
		activeInputs[name]=nil
	end

	updateWLock()
	refreshTouchGui()
end)
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local old=pg:FindFirstChild("DeltaMobileErgo")
if old then old:Destroy() end

local x,y,size,step=.70,.70,.30,.05
local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.DisplayOrder=102;gui.Parent=pg

local function btn(p,n,pos,sz,txt,bg,z)
	local b=Instance.new("TextButton")
	b.Name=n;b.Position=pos;b.Size=sz;b.Text=txt
	b.BackgroundColor3=bg or Color3.fromRGB(35,35,35)
	b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=20
	b.AutoButtonColor=false;b.Active=true;b.Selectable=false;b.BorderSizePixel=0;b.ZIndex=z or 10
	local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=b
	b.Parent=p;return b
end

local menu=btn(gui,"OpenMenu",UDim2.new(1,-60,1,-60),UDim2.new(0,48,0,48),"⚙",Color3.fromRGB(30,30,30),50)
local mc=Instance.new("UICorner");mc.CornerRadius=UDim.new(1,0);mc.Parent=menu

local set=Instance.new("Frame")
set.Name="SettingsFrame";set.Size=UDim2.new(0,260,0,300)
set.Position=UDim2.new(.5,-130,.5,-150)
set.BackgroundColor3=Color3.fromRGB(25,25,25)
set.BorderSizePixel=0;set.Visible=false;set.ZIndex=40;set.Parent=gui

local sc=Instance.new("UICorner")
sc.CornerRadius=UDim.new(0,14);sc.Parent=set

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40);title.BackgroundTransparency=1
title.Text="JUMP SETTINGS";title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold;title.TextSize=20
title.ZIndex=41;title.Parent=set

local up=btn(set,"MoveUp",UDim2.new(.5,-30,0,48),UDim2.new(0,60,0,42),"↑",nil,41)
local left=btn(set,"MoveLeft",UDim2.new(.18,0,0,95),UDim2.new(0,60,0,42),"←",nil,41)
local right=btn(set,"MoveRight",UDim2.new(.82,-60,0,95),UDim2.new(0,60,0,42),"→",nil,41)
local down=btn(set,"MoveDown",UDim2.new(.5,-30,0,142),UDim2.new(0,60,0,42),"↓",nil,41)
local plus=btn(set,"SizePlus",UDim2.new(.15,0,0,195),UDim2.new(0,85,0,42),"SIZE +",nil,41)
local minus=btn(set,"SizeMinus",UDim2.new(.52,0,0,195),UDim2.new(0,85,0,42),"SIZE -",nil,41)
local close=btn(set,"Close",UDim2.new(.5,-90,1,-48),UDim2.new(0,180,0,36),"CLOSE",Color3.fromRGB(150,0,0),41)

local jump

local function findJump()
	local touch=pg:FindFirstChild("TouchGui")
	if not touch then return nil end

	local tg=touch:FindFirstChild("TouchControlFrame",true)
	if tg then
		local j=tg:FindFirstChild("JumpButton",true)
		if j and j:IsA("GuiObject") then return j end
	end

	local j=touch:FindFirstChild("JumpButton",true)
	if j and j:IsA("GuiObject") then return j end
end

local function getJump()
	if jump and jump.Parent then return true end
	jump=findJump()
	return jump~=nil
end

local function update()
	if not getJump() then return end

	size=math.clamp(size,.15,.45)
	x=math.clamp(x,0,1-size)
	y=math.clamp(y,0,1-size)

	jump.AnchorPoint=Vector2.new(0,0)
	jump.Position=UDim2.new(x,0,y,0)
	jump.Size=UDim2.new(size,0,size,0)
end

local function move(dx,dy)
	x=x+dx;y=y+dy;update()
end

up.Activated:Connect(function()move(0,-step)end)
down.Activated:Connect(function()move(0,step)end)
left.Activated:Connect(function()move(-step,0)end)
right.Activated:Connect(function()move(step,0)end)

plus.Activated:Connect(function()
	size=size+.05
	update()
end)

minus.Activated:Connect(function()
	size=size-.05
	update()
end)

menu.Activated:Connect(function()
	set.Visible=not set.Visible
	update()
end)

close.Activated:Connect(function()
	set.Visible=false
end)

pg.ChildAdded:Connect(function(c)
	if c.Name=="TouchGui" then
		task.wait(.1)
		jump=nil
		update()
	end
end)

update()

update()
