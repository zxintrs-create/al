local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

--==================================================
-- CLEANUP
--==================================================

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local destroyed=false
local btnWLock=nil

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
	local obj=playerGui:FindFirstChild(name)
	if obj then
		pcall(function()
			obj:Destroy()
		end)
	end
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
-- MOVEMENT
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

local function isPressInput(input)
	return input and (
		input.UserInputType==Enum.UserInputType.Touch
		or input.UserInputType==Enum.UserInputType.MouseButton1
	)
end

local function updateWLock()
	if not btnWLock or not btnWLock.Parent then
		return
	end

	if moveState.WLock then
		btnWLock.BackgroundColor3=Color3.fromRGB(0,150,0)
	else
		btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
	end
end

local function clearMovement()
	for name in pairs(moveState) do
		moveState[name]=false
	end

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

local function createButton(name,position,size,text,zIndex)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=position
	button.Size=size
	button.Text=text
	button.BackgroundColor3=Color3.fromRGB(30,30,30)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=24
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=zIndex or 10
	button.Parent=mainFrame

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,12)
	corner.Parent=button

	return button
end

local btnUp=createButton(
	"Up",
	UDim2.new(.35,0,0,0),
	UDim2.new(.3,0,.3,0),
	"▲",
	10
)

local btnDown=createButton(
	"Down",
	UDim2.new(.35,0,.7,0),
	UDim2.new(.3,0,.3,0),
	"▼",
	10
)

local btnLeft=createButton(
	"Left",
	UDim2.new(0,0,.35,0),
	UDim2.new(.3,0,.3,0),
	"◀",
	10
)

local btnRight=createButton(
	"Right",
	UDim2.new(.7,0,.35,0),
	UDim2.new(.3,0,.3,0),
	"▶",
	10
)

local btnUL=createButton(
	"UpLeft",
	UDim2.new(.08,0,.08,0),
	UDim2.new(.22,0,.22,0),
	"↖",
	11
)

local btnUR=createButton(
	"UpRight",
	UDim2.new(.70,0,.08,0),
	UDim2.new(.22,0,.22,0),
	"↗",
	11
)

local btnDL=createButton(
	"DownLeft",
	UDim2.new(.08,0,.70,0),
	UDim2.new(.22,0,.22,0),
	"↙",
	11
)

local btnDR=createButton(
	"DownRight",
	UDim2.new(.70,0,.70,0),
	UDim2.new(.22,0,.22,0),
	"↘",
	11
)

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

local function getMoveVector()
	local camera=workspace.CurrentCamera

	if not camera then
		return Vector3.zero
	end

	local look=camera.CFrame.LookVector
	local right=camera.CFrame.RightVector

	local forward=Vector3.new(look.X,0,look.Z)
	local side=Vector3.new(right.X,0,right.Z)

	if forward.Magnitude<0.001
		or side.Magnitude<0.001 then
		return Vector3.zero
	end

	forward=forward.Unit
	side=side.Unit

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
			z=1
		else
			return Vector3.zero
		end
	end

	local movement=side*x+forward*z

	if movement.Magnitude<0.001 then
		return Vector3.zero
	end

	return movement.Unit
end

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	if not character or not character.Parent then
		return
	end

	if not humanoid or humanoid.Parent~=character then
		return
	end

	if humanoid.Health<=0 then
		return
	end

	humanoid:Move(getMoveVector(),false)
end)

--==================================================
-- ONE MENU
-- DeltaMobileErgo
--   OpenMenu
--     SettingsFrame
--       Camera Sensi Setting
--       Jump Setting
--       Close
--==================================================

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
	button.TextSize=20
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=zIndex or 41
	button.Parent=parent

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,10)
	corner.Parent=button

	return button
end

--==================================================
-- OPEN MENU
--==================================================

local menu=makeButton(
	gui,
	"OpenMenu",
	UDim2.new(1,-60,1,-60),
	UDim2.fromOffset(48,48),
	"⚙",
	Color3.fromRGB(30,30,30),
	100
)

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

--==================================================
-- SETTINGS FRAME
--==================================================

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(280,500)
settings.Position=UDim2.new(.5,-140,.5,-250)
settings.BackgroundColor3=Color3.fromRGB(25,25,25)
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=40
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,14)
settingsCorner.Parent=settings

--==================================================
-- CAMERA SENSITIVITY SECTION
--==================================================

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
	button.TextSize=16
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=43
	button.Parent=cameraSection

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,7)
	corner.Parent=button

	return button
end

local sensMinus=createSensButton(
	"Minus",
	UDim2.new(.08,0,0,90),
	UDim2.fromOffset(70,38),
	"-"
)

local sensReset=createSensButton(
	"Reset",
	UDim2.new(.5,-40,0,90),
	UDim2.fromOffset(80,38),
	"RESET"
)

local sensPlus=createSensButton(
	"Plus",
	UDim2.new(.92,-70,0,90),
	UDim2.fromOffset(70,38),
	"+"
)

local function updateSensitivity(amount)
	CurrentSens=math.clamp(
		CurrentSens+amount,
		MinSens,
		MaxSens
	)

	sensLabel.Text=
		"Multiplier: "..string.format("%.1f",CurrentSens).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CurrentSens
	end)
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

	sensLabel.Text=
		"Multiplier: "..string.format("%.1f",CurrentSens).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CurrentSens
	end)
end)

-- Tetap mempertahankan initial apply
updateSensitivity(0)

--==================================================
-- JUMP SETTINGS SECTION
--==================================================

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
	UDim2.new(.5,-30,0,48),
	UDim2.fromOffset(60,42),
	"↑",
	nil,
	43
)

local moveLeft=makeButton(
	jumpSection,
	"MoveLeft",
	UDim2.new(.12,0,0,95),
	UDim2.fromOffset(60,42),
	"←",
	nil,
	43
)

local moveRight=makeButton(
	jumpSection,
	"MoveRight",
	UDim2.new(.88,-60,0,95),
	UDim2.fromOffset(60,42),
	"→",
	nil,
	43
)

local moveDown=makeButton(
	jumpSection,
	"MoveDown",
	UDim2.new(.5,-30,0,142),
	UDim2.fromOffset(60,42),
	"↓",
	nil,
	43
)

local sizePlus=makeButton(
	jumpSection,
	"SizePlus",
	UDim2.new(.08,0,0,200),
	UDim2.fromOffset(80,32),
	"SIZE +",
	nil,
	43
)

local sizeMinus=makeButton(
	jumpSection,
	"SizeMinus",
	UDim2.new(.92,-80,0,200),
	UDim2.fromOffset(80,32),
	"SIZE -",
	nil,
	43
)

local center=makeButton(
	jumpSection,
	"Center",
	UDim2.new(.5,-40,0,200),
	UDim2.fromOffset(80,32),
	"CENTER",
	nil,
	43
)

--==================================================
-- JUMP BUTTON
--==================================================

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

	updatingJump=true

	x=math.clamp(x,.05,.95)
	y=math.clamp(y,.05,.95)
	size=math.clamp(size,.05,.50)

	local pixelSize=math.max(
		40,
		math.floor(viewport.Y*size)
	)

	jump.AnchorPoint=Vector2.new(.5,.5)
	jump.Position=UDim2.new(x,0,y,0)
	jump.Size=UDim2.fromOffset(pixelSize,pixelSize)

	updatingJump=false
end

--==================================================
-- JUMP HOLD INPUT
--==================================================

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
	for button in pairs(holding) do
		holding[button]=false
		holdInputs[button]={}
	end

	table.clear(holdActions)
end

local function releaseHoldInput(input)
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

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

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
	updateJump()
end)

--==================================================
-- CLOSE
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

--==================================================
-- SINGLE OPEN MENU
--==================================================

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

--==================================================
-- JUMP REFRESH
--==================================================

local function refreshJump()
	if destroyed then
		return
	end

	jumpButton=nil

	task.defer(function()
		if not destroyed then
			updateJump()
		end
	end)

	task.delay(.1,function()
		if not destroyed then
			updateJump()
		end
	end)

	task.delay(.25,function()
		if not destroyed then
			updateJump()
		end
	end)

	task.delay(.5,function()
		if not destroyed then
			updateJump()
		end
	end)

	task.delay(1,function()
		if not destroyed then
			updateJump()
		end
	end)
end

--==================================================
-- CHARACTER EVENTS
--==================================================

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then
		return
	end

	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid")

	clearMovement()
	clearHoldInputs()
	updateWLock()
	refreshJump()
end)

connect(player.CharacterRemoving,function()
	clearMovement()
	clearHoldInputs()
end)

--==================================================
-- TOUCH GUI
--==================================================

connect(playerGui.ChildAdded,function(child)
	if destroyed then
		return
	end

	if child.Name=="TouchGui" then
		refreshJump()
	end
end)

--==================================================
-- CAMERA
--==================================================

connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	if destroyed then
		return
	end

	task.defer(function()
		if not destroyed then
			updateJump()
		end
	end)
end)

--==================================================
-- INITIAL
--==================================================

updateWLock()
updateJump()
