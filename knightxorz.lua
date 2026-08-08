local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local destroyed=false

local function connect(signal,callback)
	local c=signal:Connect(callback)
	table.insert(connections,c)
	return c
end

local function disconnectAll()
	for _,c in ipairs(connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyGui(name)
	local gui=playerGui:FindFirstChild(name)
	if gui then gui:Destroy() end
end

_G.DeltaMobileControlsCleanup=function()
	destroyed=true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

--==================================================
-- CHARACTER
--==================================================

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")

--==================================================
-- MOVEMENT STATE
--==================================================

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

local inputActions={}
local buttonInputs={}
local btnWLock

local function isPressInput(input)
	return input and (
		input.UserInputType==Enum.UserInputType.Touch
		or input.UserInputType==Enum.UserInputType.MouseButton1
	)
end

local function updateWLock()
	if btnWLock and btnWLock.Parent then
		btnWLock.BackgroundColor3=moveState.WLock
			and Color3.fromRGB(0,150,0)
			or Color3.fromRGB(150,0,0)
	end
end

local function clearMovement()
	for name in pairs(moveState) do
		moveState[name]=false
	end

	table.clear(inputActions)

	for name in pairs(buttonInputs) do
		table.clear(buttonInputs[name])
	end

	updateWLock()
end

local function releaseInput(input)
	local action=inputActions[input]
	if not action then return end

	inputActions[input]=nil

	local inputs=buttonInputs[action]
	if not inputs then
		moveState[action]=false
		return
	end

	inputs[input]=nil

	local pressed=false

	for _ in pairs(inputs) do
		pressed=true
		break
	end

	moveState[action]=pressed
end

--==================================================
-- MOVEMENT GUI
--==================================================

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=100
screenGui.Parent=playerGui

local mainFrame=Instance.new("Frame")
mainFrame.Name="ControlsFrame"
mainFrame.Size=UDim2.fromOffset(260,260)
mainFrame.Position=UDim2.new(0,24,1,-290)
mainFrame.BackgroundTransparency=1
mainFrame.BorderSizePixel=0
mainFrame.Parent=screenGui

local function createMoveButton(name,pos,size,text,z)
	local b=Instance.new("TextButton")
	b.Name=name
	b.Position=pos
	b.Size=size
	b.Text=text
	b.BackgroundColor3=Color3.fromRGB(30,30,30)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=24
	b.AutoButtonColor=false
	b.Active=true
	b.Selectable=false
	b.BorderSizePixel=0
	b.ZIndex=z or 10
	b.Parent=mainFrame

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,12)
	c.Parent=b

	return b
end

local btnUp=createMoveButton("Up",UDim2.new(.35,0,0,0),UDim2.new(.3,0,.3,0),"▲")
local btnDown=createMoveButton("Down",UDim2.new(.35,0,.7,0),UDim2.new(.3,0,.3,0),"▼")
local btnLeft=createMoveButton("Left",UDim2.new(0,0,.35,0),UDim2.new(.3,0,.3,0),"◀")
local btnRight=createMoveButton("Right",UDim2.new(.7,0,.35,0),UDim2.new(.3,0,.3,0),"▶")

local btnUL=createMoveButton("UpLeft",UDim2.new(.08,0,.08,0),UDim2.new(.22,0,.22,0),"↖",11)
local btnUR=createMoveButton("UpRight",UDim2.new(.70,0,.08,0),UDim2.new(.22,0,.22,0),"↗",11)
local btnDL=createMoveButton("DownLeft",UDim2.new(.08,0,.70,0),UDim2.new(.22,0,.22,0),"↙",11)
local btnDR=createMoveButton("DownRight",UDim2.new(.70,0,.70,0),UDim2.new(.22,0,.22,0),"↘",11)

btnWLock=Instance.new("TextButton")
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
btnWLock.ZIndex=12
btnWLock.Parent=mainFrame

local wc=Instance.new("UICorner")
wc.CornerRadius=UDim.new(1,0)
wc.Parent=btnWLock

local movementButtons={
	[btnUp]="Forward",
	[btnDown]="Backward",
	[btnLeft]="Left",
	[btnRight]="Right",
	[btnUL]="UpLeft",
	[btnUR]="UpRight",
	[btnDL]="DownLeft",
	[btnDR]="DownRight"
}

for button,name in pairs(movementButtons) do
	buttonInputs[name]={}

	connect(button.InputBegan,function(input)
		if destroyed or not isPressInput(input) then return end
		if inputActions[input] then return end

		inputActions[input]=name
		buttonInputs[name][input]=true
		moveState[name]=true
	end)

	connect(button.InputEnded,releaseInput)
end

connect(UserInputService.InputEnded,releaseInput)
connect(UserInputService.TouchEnded,releaseInput)

connect(UserInputService.WindowFocusReleased,clearMovement)

connect(btnWLock.Activated,function()
	if destroyed then return end

	moveState.WLock=not moveState.WLock
	updateWLock()
end)

--==================================================
-- MOVEMENT VECTOR
--==================================================

local lastMoveVector=Vector3.zero

local function getMoveVector()
	local camera=workspace.CurrentCamera
	if not camera then return Vector3.zero end

	local look=camera.CFrame.LookVector
	local right=camera.CFrame.RightVector

	local forward=Vector3.new(look.X,0,look.Z)
	local side=Vector3.new(right.X,0,right.Z)

	if forward.Magnitude<.001 or side.Magnitude<.001 then
		return Vector3.zero
	end

	forward=forward.Unit
	side=side.Unit

	local x=0
	local z=0

	if moveState.Forward then z+=1 end
	if moveState.Backward then z-=1 end
	if moveState.Left then x-=1 end
	if moveState.Right then x+=1 end

	if moveState.UpLeft then x-=1;z+=1 end
	if moveState.UpRight then x+=1;z+=1 end
	if moveState.DownLeft then x-=1;z-=1 end
	if moveState.DownRight then x+=1;z-=1 end

	if x==0 and z==0 then
		if moveState.WLock then
			z=1
		else
			return Vector3.zero
		end
	end

	local movement=side*x+forward*z

	if movement.Magnitude<.001 then
		return Vector3.zero
	end

	return movement.Unit
end

-- Hanya update Humanoid saat diperlukan.
connect(RunService.RenderStepped,function()
	if destroyed then return end
	if not humanoid or humanoid.Health<=0 then return end

	local movement=getMoveVector()

	if movement~=lastMoveVector then
		lastMoveVector=movement
		humanoid:Move(movement,false)
	end
end)

--==================================================
-- ONE MENU
--==================================================

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=102
gui.Parent=playerGui

local function makeButton(parent,name,pos,size,text,bg,z)
	local b=Instance.new("TextButton")
	b.Name=name
	b.Position=pos
	b.Size=size
	b.Text=text
	b.BackgroundColor3=bg or Color3.fromRGB(35,35,35)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=18
	b.AutoButtonColor=false
	b.Active=true
	b.Selectable=false
	b.BorderSizePixel=0
	b.ZIndex=z or 41
	b.Parent=parent

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,9)
	c.Parent=b

	return b
end

local menu=makeButton(
	gui,
	"OpenMenu",
	UDim2.new(1,-60,1,-60),
	UDim2.fromOffset(48,48),
	"⚙",
	Color3.fromRGB(30,30,30),
	50
)

local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(1,0)
mc.Parent=menu

--==================================================
-- SETTINGS FRAME
--==================================================

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(300,500)
settings.Position=UDim2.new(.5,-150,.5,-250)
settings.BackgroundColor3=Color3.fromRGB(25,25,25)
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=40
settings.Parent=gui

local sc=Instance.new("UICorner")
sc.CornerRadius=UDim.new(0,14)
sc.Parent=settings

--==================================================
-- CAMERA SENSITIVITY
--==================================================

local cameraSection=Instance.new("Frame")
cameraSection.Name="CameraSensiSetting"
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.Size=UDim2.new(1,-20,0,190)
cameraSection.BackgroundColor3=Color3.fromRGB(32,32,38)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings

local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,12)
cc.Parent=cameraSection

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,40)
cameraTitle.Text="CAMERA SENSI SETTING"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=17
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local CurrentSens=1
local MinSens=.1
local MaxSens=10

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,30)
sensLabel.Position=UDim2.fromOffset(0,42)
sensLabel.Text="Multiplier: 1.0x"
sensLabel.TextColor3=Color3.fromRGB(200,200,200)
sensLabel.Font=Enum.Font.Gotham
sensLabel.TextSize=14
sensLabel.BackgroundTransparency=1
sensLabel.ZIndex=42
sensLabel.Parent=cameraSection

local sensMinus=makeButton(
	cameraSection,
	"Minus",
	UDim2.new(.1,0,0,90),
	UDim2.fromOffset(75,38),
	"-",
	Color3.fromRGB(45,45,55),
	43
)

local sensReset=makeButton(
	cameraSection,
	"Reset",
	UDim2.new(.5,-37,0,90),
	UDim2.fromOffset(75,38),
	"RESET",
	Color3.fromRGB(45,45,55),
	43
)

local sensPlus=makeButton(
	cameraSection,
	"Plus",
	UDim2.new(.9,-75,0,90),
	UDim2.fromOffset(75,38),
	"+",
	Color3.fromRGB(45,45,55),
	43
)

local function applySensitivity()
	sensLabel.Text="Multiplier: "..string.format("%.1f",CurrentSens).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CurrentSens
	end)
end

sensMinus.Activated:Connect(function()
	CurrentSens=math.clamp(CurrentSens-.1,MinSens,MaxSens)
	applySensitivity()
end)

sensPlus.Activated:Connect(function()
	CurrentSens=math.clamp(CurrentSens+.1,MinSens,MaxSens)
	applySensitivity()
end)

sensReset.Activated:Connect(function()
	CurrentSens=1
	applySensitivity()
end)

applySensitivity()

--==================================================
-- JUMP SETTING
--==================================================

local jumpSection=Instance.new("Frame")
jumpSection.Name="JumpSetting"
jumpSection.Position=UDim2.fromOffset(10,210)
jumpSection.Size=UDim2.new(1,-20,0,235)
jumpSection.BackgroundColor3=Color3.fromRGB(32,32,38)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings

local jc=Instance.new("UICorner")
jc.CornerRadius=UDim.new(0,12)
jc.Parent=jumpSection

local jumpTitle=Instance.new("TextLabel")
jumpTitle.Size=UDim2.new(1,0,0,40)
jumpTitle.Text="JUMP SETTING"
jumpTitle.TextColor3=Color3.new(1,1,1)
jumpTitle.Font=Enum.Font.GothamBold
jumpTitle.TextSize=17
jumpTitle.BackgroundTransparency=1
jumpTitle.ZIndex=42
jumpTitle.Parent=jumpSection

local moveUp=makeButton(jumpSection,"MoveUp",UDim2.new(.5,-29,0,45),UDim2.fromOffset(58,38),"↑",nil,43)
local moveLeft=makeButton(jumpSection,"MoveLeft",UDim2.new(.12,0,0,88),UDim2.fromOffset(58,38),"←",nil,43)
local moveRight=makeButton(jumpSection,"MoveRight",UDim2.new(.88,-58,0,88),UDim2.fromOffset(58,38),"→",nil,43)
local moveDown=makeButton(jumpSection,"MoveDown",UDim2.new(.5,-29,0,131),UDim2.fromOffset(58,38),"↓",nil,43)

local sizePlus=makeButton(jumpSection,"SizePlus",UDim2.new(.08,0,0,180),UDim2.fromOffset(85,32),"SIZE +",nil,43)
local center=makeButton(jumpSection,"Center",UDim2.new(.5,-40,0,180),UDim2.fromOffset(80,32),"CENTER",nil,43)
local sizeMinus=makeButton(jumpSection,"SizeMinus",UDim2.new(.92,-85,0,180),UDim2.fromOffset(85,32),"SIZE -",nil,43)

--==================================================
-- JUMP POSITION
--==================================================

local x=.70
local y=.70
local size=.30
local step=.018
local jumpButton=nil
local holding={
	[moveUp]=false,
	[moveDown]=false,
	[moveLeft]=false,
	[moveRight]=false
}

local holdInputs={
	[moveUp]={},
	[moveDown]={},
	[moveLeft]={},
	[moveRight]={}
}

local holdActions={}

local function findJump()
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then return nil end

	local found=touchGui:FindFirstChild("JumpButton",true)

	if found and found:IsA("GuiObject") then
		return found
	end
end

local function getJump()
	if jumpButton
		and jumpButton.Parent
		and jumpButton:IsDescendantOf(playerGui) then
		return jumpButton
	end

	jumpButton=findJump()
	return jumpButton
end

local function updateJump()
	if destroyed then return end

	local jump=getJump()
	local camera=workspace.CurrentCamera

	if not jump or not camera then return end

	local viewport=camera.ViewportSize
	if viewport.Y<=0 then return end

	x=math.clamp(x,.05,.95)
	y=math.clamp(y,.05,.95)
	size=math.clamp(size,.05,.50)

	local pixelSize=math.max(40,math.floor(viewport.Y*size))

	jump.AnchorPoint=Vector2.new(.5,.5)
	jump.Position=UDim2.new(x,0,y,0)
	jump.Size=UDim2.fromOffset(pixelSize,pixelSize)
end

local function releaseHoldInput(input)
	local button=holdActions[input]
	if not button then return end

	holdActions[input]=nil

	local inputs=holdInputs[button]
	if not inputs then
		holding[button]=false
		return
	end

	inputs[input]=nil

	local pressed=false

	for _ in pairs(inputs) do
		pressed=true
		break
	end

	holding[button]=pressed
end

local function bindHoldButton(button,dx,dy)
	connect(button.InputBegan,function(input)
		if destroyed or not isPressInput(input) then return end
		if holdActions[input] then return end

		holdActions[input]=button
		holdInputs[button][input]=true
		holding[button]=true

		x=math.clamp(x+dx,.05,.95)
		y=math.clamp(y+dy,.05,.95)

		updateJump()
	end)

	connect(button.InputEnded,releaseHoldInput)
end

bindHoldButton(moveUp,0,-step)
bindHoldButton(moveDown,0,step)
bindHoldButton(moveLeft,-step,0)
bindHoldButton(moveRight,step,0)

connect(UserInputService.InputEnded,releaseHoldInput)
connect(UserInputService.TouchEnded,releaseHoldInput)

connect(UserInputService.WindowFocusReleased,function()
	for button in pairs(holding) do
		holding[button]=false
		table.clear(holdInputs[button])
	end

	table.clear(holdActions)
end)

-- Update only while moving jump button.
connect(RunService.RenderStepped,function()
	if destroyed then return end

	local moved=false

	if holding[moveUp] then
		y=math.clamp(y-step,.05,.95)
		moved=true
	end

	if holding[moveDown] then
		y=math.clamp(y+step,.05,.95)
		moved=true
	end

	if holding[moveLeft] then
		x=math.clamp(x-step,.05,.95)
		moved=true
	end

	if holding[moveRight] then
		x=math.clamp(x+step,.05,.95)
		moved=true
	end

	if moved then
		updateJump()
	end
end)

sizePlus.Activated:Connect(function()
	size=math.clamp(size+.05,.05,.50)
	updateJump()
end)

sizeMinus.Activated:Connect(function()
	size=math.clamp(size-.05,.05,.50)
	updateJump()
end)

center.Activated:Connect(function()
	x=.70
	y=.70
	updateJump()
end)

--==================================================
-- CLOSE / OPEN
--==================================================

local close=makeButton(
	settings,
	"Close",
	UDim2.new(.5,-90,1,-45),
	UDim2.fromOffset(180,34),
	"CLOSE",
	Color3.fromRGB(150,0,0),
	43
)

connect(menu.Activated,function()
	if destroyed then return end
	settings.Visible=not settings.Visible
end)

connect(close.Activated,function()
	settings.Visible=false
end)

--==================================================
-- CHARACTER / JUMP REFRESH
--==================================================

local function refreshJump()
	jumpButton=nil

	task.defer(updateJump)
	task.delay(.15,updateJump)
	task.delay(.4,updateJump)
end

connect(player.CharacterAdded,function(newCharacter)
	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid")

	lastMoveVector=Vector3.zero
	clearMovement()

	for button in pairs(holding) do
		holding[button]=false
		table.clear(holdInputs[button])
	end

	table.clear(holdActions)

	refreshJump()
end)

connect(player.CharacterRemoving,function()
	clearMovement()
	lastMoveVector=Vector3.zero
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		refreshJump()
	end
end)

connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	task.defer(updateJump)
end)

updateWLock()
refreshJump()
