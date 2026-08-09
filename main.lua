local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local destroyed=false
local btnWLock=nil

local function connect(signal,callback)
	local c
	pcall(function()
		c=signal:Connect(callback)
	end)
	if c then
		table.insert(connections,c)
	end
	return c
end

local function disconnectAll()
	for i=1,#connections do
		pcall(function()
			connections[i]:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyGui(name)
	local obj=playerGui:FindFirstChild(name)
	if obj then
		pcall(function()
			obj:Destroy()
		end)
	end
end

_G.DeltaMobileControlsCleanup=function()
	if destroyed then
		return
	end
	destroyed=true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")

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

local function isPressInput(input)
	if not input then
		return false
	end

	local inputType=input.UserInputType
	return inputType==Enum.UserInputType.Touch
		or inputType==Enum.UserInputType.MouseButton1
end

local function updateWLock()
	if destroyed or not btnWLock or not btnWLock.Parent then
		return
	end

	btnWLock.BackgroundColor3=moveState.WLock
		and Color3.fromRGB(0,150,0)
		or Color3.fromRGB(150,0,0)
end

local function clearMovement()
	moveState.Forward=false
	moveState.Backward=false
	moveState.Left=false
	moveState.Right=false
	moveState.UpLeft=false
	moveState.UpRight=false
	moveState.DownLeft=false
	moveState.DownRight=false
	moveState.WLock=false

	table.clear(inputActions)

	for name in pairs(buttonInputs) do
		buttonInputs[name]={}
	end

	updateWLock()
end

local function releaseInput(input)
	if not input then
		return
	end

	local action=inputActions[input]
	if not action then
		return
	end

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

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=100
screenGui.Parent=playerGui

local mainFrame=Instance.new("Frame")
mainFrame.Name="ControlsFrame"
mainFrame.Size=UDim2.fromOffset(300,300)
mainFrame.Position=UDim2.new(0,18,1,-330)
mainFrame.BackgroundTransparency=1
mainFrame.BorderSizePixel=0
mainFrame.Parent=screenGui

local function createButton(name,position,size,text,zIndex)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=position
	button.Size=size
	button.Text=text
	button.BackgroundColor3=Color3.fromRGB(30,30,30)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=28
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=zIndex or 10
	button.Parent=mainFrame

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,14)
	corner.Parent=button

	return button
end

local btnUp=createButton(
	"Up",
	UDim2.new(.33,0,0,0),
	UDim2.new(.34,0,.34,0),
	"▲",
	10
)

local btnDown=createButton(
	"Down",
	UDim2.new(.33,0,.66,0),
	UDim2.new(.34,0,.34,0),
	"▼",
	10
)

local btnLeft=createButton(
	"Left",
	UDim2.new(0,0,.33,0),
	UDim2.new(.34,0,.34,0),
	"◀",
	10
)

local btnRight=createButton(
	"Right",
	UDim2.new(.66,0,.33,0),
	UDim2.new(.34,0,.34,0),
	"▶",
	10
)

local btnUL=createButton(
	"UpLeft",
	UDim2.new(.03,0,.03,0),
	UDim2.new(.27,0,.27,0),
	"↖",
	11
)

local btnUR=createButton(
	"UpRight",
	UDim2.new(.70,0,.03,0),
	UDim2.new(.27,0,.27,0),
	"↗",
	11
)

local btnDL=createButton(
	"DownLeft",
	UDim2.new(.03,0,.70,0),
	UDim2.new(.27,0,.27,0),
	"↙",
	11
)

local btnDR=createButton(
	"DownRight",
	UDim2.new(.70,0,.70,0),
	UDim2.new(.27,0,.27,0),
	"↘",
	11
)

btnWLock=Instance.new("TextButton")
btnWLock.Name="WLock"
btnWLock.Position=UDim2.new(.33,0,.33,0)
btnWLock.Size=UDim2.new(.34,0,.34,0)
btnWLock.Text="W"
btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
btnWLock.TextColor3=Color3.new(1,1,1)
btnWLock.Font=Enum.Font.GothamBold
btnWLock.TextSize=28
btnWLock.AutoButtonColor=false
btnWLock.Active=true
btnWLock.Selectable=false
btnWLock.BorderSizePixel=0
btnWLock.ZIndex=12
btnWLock.Parent=mainFrame

local centerCorner=Instance.new("UICorner")
centerCorner.CornerRadius=UDim.new(1,0)
centerCorner.Parent=btnWLock

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
		if destroyed or not isPressInput(input) then
			return
		end

		if inputActions[input] then
			return
		end

		inputActions[input]=name
		buttonInputs[name][input]=true
		moveState[name]=true
	end)

	connect(button.InputEnded,function(input)
		releaseInput(input)
	end)
end

connect(UserInputService.InputEnded,function(input)
	releaseInput(input)
end)

connect(UserInputService.TouchEnded,function(input)
	releaseInput(input)
end)

connect(UserInputService.WindowFocusReleased,function()
	clearMovement()
end)

connect(btnWLock.Activated,function()
	if destroyed then
		return
	end

	moveState.WLock=not moveState.WLock
	updateWLock()
end)

local cachedForward=Vector3.new(0,0,-1)
local cachedSide=Vector3.new(1,0,0)

local function updateCameraVectors()
	if destroyed then
		return
	end

	local camera=workspace.CurrentCamera
	if not camera then
		return
	end

	local look=camera.CFrame.LookVector
	local right=camera.CFrame.RightVector

	local forward=Vector3.new(look.X,0,look.Z)
	local side=Vector3.new(right.X,0,right.Z)

	if forward.Magnitude>0.001 then
		cachedForward=forward.Unit
	end

	if side.Magnitude>0.001 then
		cachedSide=side.Unit
	end
end

local function getMoveVector()
	local x=0
	local z=0

	if moveState.Forward then
		z+=1
	end

	if moveState.Backward then
		z-=1
	end

	if moveState.Left then
		x-=1
	end

	if moveState.Right then
		x+=1
	end

	if moveState.UpLeft then
		x-=1
		z+=1
	end

	if moveState.UpRight then
		x+=1
		z+=1
	end

	if moveState.DownLeft then
		x-=1
		z-=1
	end

	if moveState.DownRight then
		x+=1
		z-=1
	end

	if x==0 and z==0 then
		if moveState.WLock then
			return cachedForward
		end
		return Vector3.zero
	end

	local movement=cachedSide*x+cachedForward*z

	if movement.Magnitude<0.001 then
		return Vector3.zero
	end

	return movement.Unit
end

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	local currentCharacter=character
	local currentHumanoid=humanoid

	if not currentCharacter
		or not currentCharacter.Parent
		or not currentHumanoid
		or currentHumanoid.Parent~=currentCharacter
		or currentHumanoid.Health<=0 then
		return
	end

	updateCameraVectors()
	currentHumanoid:Move(getMoveVector(),false)
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

local function makeButton(parent,name,position,sizeValue,text,bg,zIndex)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=position
	button.Size=sizeValue
	button.Text=text
	button.BackgroundColor3=bg or Color3.fromRGB(35,35,35)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=22
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=zIndex or 41
	button.Parent=parent

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,12)
	corner.Parent=button

	return button
end

local menu=makeButton(
	gui,
	"OpenMenu",
	UDim2.new(1,-72,1,-72),
	UDim2.fromOffset(60,60),
	"⚙",
	Color3.fromRGB(30,30,30),
	100
)

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(300,520)
settings.Position=UDim2.new(.5,-150,.5,-260)
settings.BackgroundColor3=Color3.fromRGB(25,25,25)
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=40
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings

local cameraSection=Instance.new("Frame")
cameraSection.Name="CameraSensiSetting"
cameraSection.Size=UDim2.new(1,-20,0,180)
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3=Color3.fromRGB(32,32,38)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings

local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,40)
cameraTitle.Text="CAMERA SENSI SETTING"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=18
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local CurrentSens=1
local MinSens=.1
local MaxSens=10

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,30)
sensLabel.Position=UDim2.fromOffset(0,40)
sensLabel.Text="Multiplier: 1.0x"
sensLabel.TextColor3=Color3.fromRGB(200,200,200)
sensLabel.Font=Enum.Font.Gotham
sensLabel.TextSize=14
sensLabel.BackgroundTransparency=1
sensLabel.ZIndex=42
sensLabel.Parent=cameraSection

local function createSensButton(name,pos,sizeValue,text)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=pos
	button.Size=sizeValue
	button.Text=text
	button.BackgroundColor3=Color3.fromRGB(35,35,45)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=18
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=43
	button.Parent=cameraSection

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,8)
	corner.Parent=button

	return button
end

local sensMinus=createSensButton(
	"Minus",
	UDim2.new(.06,0,0,90),
	UDim2.fromOffset(76,42),
	"-"
)

local sensReset=createSensButton(
	"Reset",
	UDim2.new(.5,-42,0,90),
	UDim2.fromOffset(84,42),
	"RESET"
)

local sensPlus=createSensButton(
	"Plus",
	UDim2.new(.94,-76,0,90),
	UDim2.fromOffset(76,42),
	"+"
)

local function applySensitivity()
	sensLabel.Text="Multiplier: "..string.format("%.1f",CurrentSens).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CurrentSens
	end)
end

local function updateSensitivity(amount)
	CurrentSens=math.clamp(CurrentSens+amount,MinSens,MaxSens)
	applySensitivity()
end

connect(sensMinus.Activated,function()
	if destroyed then
		return
	end
	updateSensitivity(-.1)
end)

connect(sensPlus.Activated,function()
	if destroyed then
		return
	end
	updateSensitivity(.1)
end)

connect(sensReset.Activated,function()
	if destroyed then
		return
	end
	CurrentSens=1
	applySensitivity()
end)

applySensitivity()

local jumpSection=Instance.new("Frame")
jumpSection.Name="JumpSetting"
jumpSection.Size=UDim2.new(1,-20,0,250)
jumpSection.Position=UDim2.fromOffset(10,200)
jumpSection.BackgroundColor3=Color3.fromRGB(32,32,38)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings

local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundTransparency=1
title.Text="JUMP SETTINGS"
title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold
title.TextSize=20
title.ZIndex=42
title.Parent=jumpSection

local moveUp=makeButton(
	jumpSection,
	"MoveUp",
	UDim2.new(.5,-34,0,48),
	UDim2.fromOffset(68,46),
	"↑",
	nil,
	43
)

local moveLeft=makeButton(
	jumpSection,
	"MoveLeft",
	UDim2.new(.10,0,0,95),
	UDim2.fromOffset(68,46),
	"←",
	nil,
	43
)

local moveRight=makeButton(
	jumpSection,
	"MoveRight",
	UDim2.new(.90,-68,0,95),
	UDim2.fromOffset(68,46),
	"→",
	nil,
	43
)

local moveDown=makeButton(
	jumpSection,
	"MoveDown",
	UDim2.new(.5,-34,0,142),
	UDim2.fromOffset(68,46),
	"↓",
	nil,
	43
)

local sizePlus=makeButton(
	jumpSection,
	"SizePlus",
	UDim2.new(.06,0,0,200),
	UDim2.fromOffset(88,34),
	"SIZE +",
	nil,
	43
)

local sizeMinus=makeButton(
	jumpSection,
	"SizeMinus",
	UDim2.new(.94,-88,0,200),
	UDim2.fromOffset(88,34),
	"SIZE -",
	nil,
	43
)

local center=makeButton(
	jumpSection,
	"Center",
	UDim2.new(.5,-44,0,200),
	UDim2.fromOffset(88,34),
	"CENTER",
	nil,
	43
)

local jumpButton=nil

local function findJump()
	local touchGui=playerGui:FindFirstChild("TouchGui")

	if not touchGui then
		return nil
	end

	local found=touchGui:FindFirstChild("JumpButton",true)

	if found and found:IsA("GuiObject") then
		return found
	end

	return nil
end

local function getJump()
	if jumpButton
		and jumpButton.Parent
		and jumpButton:IsDescendantOf(playerGui)
		and jumpButton:IsA("GuiObject") then
		return jumpButton
	end

	jumpButton=findJump()
	return jumpButton
end

local updatingJump=false
local lastJumpX=nil
local lastJumpY=nil
local lastJumpSize=nil

local function updateJump()
	if destroyed or updatingJump then
		return
	end

	local jump=getJump()
	local camera=workspace.CurrentCamera

	if not jump or not camera then
		return
	end

	local viewport=camera.ViewportSize

	if viewport.X<=0 or viewport.Y<=0 then
		return
	end

	x=math.clamp(x,.05,.95)
	y=math.clamp(y,.05,.95)
	size=math.clamp(size,.05,.50)

	local pixelSize=math.max(40,math.floor(viewport.Y*size))

	if lastJumpX==x
		and lastJumpY==y
		and lastJumpSize==pixelSize then
		return
	end

	updatingJump=true

	pcall(function()
		jump.AnchorPoint=Vector2.new(.5,.5)
		jump.Position=UDim2.new(x,0,y,0)
		jump.Size=UDim2.fromOffset(pixelSize,pixelSize)
	end)

	lastJumpX=x
	lastJumpY=y
	lastJumpSize=pixelSize

	updatingJump=false
end

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

local function clearHoldInputs()
	holding[moveUp]=false
	holding[moveDown]=false
	holding[moveLeft]=false
	holding[moveRight]=false

	holdInputs[moveUp]={}
	holdInputs[moveDown]={}
	holdInputs[moveLeft]={}
	holdInputs[moveRight]={}

	table.clear(holdActions)
end

local function releaseHoldInput(input)
	if not input then
		return
	end

	local button=holdActions[input]

	if not button then
		return
	end

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
		if destroyed or not isPressInput(input) then
			return
		end

		if holdActions[input] then
			return
		end

		holdActions[input]=button
		holdInputs[button][input]=true
		holding[button]=true

		x=math.clamp(x+dx,.05,.95)
		y=math.clamp(y+dy,.05,.95)

		updateJump()
	end)

	connect(button.InputEnded,function(input)
		releaseHoldInput(input)
	end)
end

bindHoldButton(moveUp,0,-step)
bindHoldButton(moveDown,0,step)
bindHoldButton(moveLeft,-step,0)
bindHoldButton(moveRight,step,0)

connect(UserInputService.InputEnded,function(input)
	releaseHoldInput(input)
end)

connect(UserInputService.TouchEnded,function(input)
	releaseHoldInput(input)
end)

connect(UserInputService.WindowFocusReleased,function()
	clearHoldInputs()
end)

local jumpMoveAccumulator=0

connect(RunService.RenderStepped,function(deltaTime)
	if destroyed then
		return
	end

	if not (
		holding[moveUp]
		or holding[moveDown]
		or holding[moveLeft]
		or holding[moveRight]
	) then
		return
	end

	jumpMoveAccumulator+=deltaTime

	if jumpMoveAccumulator<.016 then
		return
	end

	jumpMoveAccumulator=0

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

connect(sizePlus.Activated,function()
	if destroyed then
		return
	end

	size=math.clamp(size+.05,.05,.50)
	updateJump()
end)

connect(sizeMinus.Activated,function()
	if destroyed then
		return
	end

	size=math.clamp(size-.05,.05,.50)
	updateJump()
end)

connect(center.Activated,function()
	if destroyed then
		return
	end

	x=.70
	y=.70

	lastJumpX=nil
	lastJumpY=nil
	lastJumpSize=nil

	updateJump()
end)

local close=makeButton(
	settings,
	"Close",
	UDim2.new(.5,-95,1,-45),
	UDim2.fromOffset(190,38),
	"CLOSE",
	Color3.fromRGB(150,0,0),
	43
)

connect(menu.Activated,function()
	if destroyed then
		return
	end

	settings.Visible=not settings.Visible
end)

connect(close.Activated,function()
	if destroyed then
		return
	end

	settings.Visible=false
end)

local refreshToken=0

local function refreshJump()
	if destroyed then
		return
	end

	refreshToken+=1

	local token=refreshToken

	jumpButton=nil
	lastJumpX=nil
	lastJumpY=nil
	lastJumpSize=nil

	task.defer(function()
		if destroyed or token~=refreshToken then
			return
		end

		updateJump()
	end)

	task.delay(.1,function()
		if destroyed or token~=refreshToken then
			return
		end

		updateJump()
	end)

	task.delay(.25,function()
		if destroyed or token~=refreshToken then
			return
		end

		updateJump()
	end)

	task.delay(.5,function()
		if destroyed or token~=refreshToken then
			return
		end

		updateJump()
	end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then
		return
	end

	character=newCharacter

	local newHumanoid

	pcall(function()
		newHumanoid=newCharacter:WaitForChild("Humanoid",10)
	end)

	if destroyed then
		return
	end

	if newHumanoid then
		humanoid=newHumanoid
	else
		humanoid=nil
	end

	clearMovement()
	clearHoldInputs()
	updateWLock()
	refreshJump()
end)

connect(player.CharacterRemoving,function()
	clearMovement()
	clearHoldInputs()
	humanoid=nil
	character=nil
end)

connect(playerGui.ChildAdded,function(child)
	if destroyed then
		return
	end

	if child.Name=="TouchGui" then
		refreshJump()
	end
end)

connect(
	workspace:GetPropertyChangedSignal("CurrentCamera"),
	function()
		if destroyed then
			return
		end

		updateCameraVectors()

		task.defer(function()
			if not destroyed then
				refreshJump()
			end
		end)
	end
)

local lastViewportX=0
local lastViewportY=0

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	local camera=workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport=camera.ViewportSize

	if viewport.X~=lastViewportX
		or viewport.Y~=lastViewportY then

		lastViewportX=viewport.X
		lastViewportY=viewport.Y

		lastJumpX=nil
		lastJumpY=nil
		lastJumpSize=nil

		updateJump()
	end
end)

updateCameraVectors()
updateWLock()
updateJump()
