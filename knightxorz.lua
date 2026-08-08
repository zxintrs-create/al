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
	if obj then obj:Destroy() end
end

_G.DeltaMobileControlsCleanup=function()
	destroyed=true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
	destroyGui("KnightXorzSensGui")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")
destroyGui("KnightXorzSensGui")

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
	if not btnWLock or not btnWLock.Parent then return end

	btnWLock.BackgroundColor3=moveState.WLock
		and Color3.fromRGB(0,150,0)
		or Color3.fromRGB(150,0,0)
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
	if not input then return end

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

local btnUp=createButton("Up",UDim2.new(.35,0,0,0),UDim2.new(.3,0,.3,0),"▲",10)
local btnDown=createButton("Down",UDim2.new(.35,0,.7,0),UDim2.new(.3,0,.3,0),"▼",10)
local btnLeft=createButton("Left",UDim2.new(0,0,.35,0),UDim2.new(.3,0,.3,0),"◀",10)
local btnRight=createButton("Right",UDim2.new(.7,0,.35,0),UDim2.new(.3,0,.3,0),"▶",10)

local btnUL=createButton("UpLeft",UDim2.new(.08,0,.08,0),UDim2.new(.22,0,.22,0),"↖",11)
local btnUR=createButton("UpRight",UDim2.new(.70,0,.08,0),UDim2.new(.22,0,.22,0),"↗",11)
local btnDL=createButton("DownLeft",UDim2.new(.08,0,.70,0),UDim2.new(.22,0,.22,0),"↙",11)
local btnDR=createButton("DownRight",UDim2.new(.70,0,.70,0),UDim2.new(.22,0,.22,0),"↘",11)

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
		if destroyed or not isPressInput(input) then return end
		if inputActions[input] then return end

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
	if destroyed then return end

	moveState.WLock=not moveState.WLock
	updateWLock()
end)

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

	if moveState.UpLeft then x-=1; z+=1 end
	if moveState.UpRight then x+=1; z+=1 end
	if moveState.DownLeft then x-=1; z-=1 end
	if moveState.DownRight then x+=1; z-=1 end

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

connect(RunService.RenderStepped,function()
	if destroyed then return end
	if not character or not character.Parent then return end
	if not humanoid or humanoid.Parent~=character then return end
	if humanoid.Health<=0 then return end

	humanoid:Move(getMoveVector(),false)
end)

--==================================================
-- ERGO / ONE MENU
--==================================================

local x=.70
local y=.70
local size=.30
local step=.018
local jumpButton=nil

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

-- ONE OPEN MENU
local menu=makeButton(
	gui,
	"OpenMenu",
	UDim2.new(1,-60,1,-60),
	UDim2.fromOffset(48,48),
	"⚙",
	Color3.fromRGB(30,30,30),
	50
)

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

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

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,14)
settingsCorner.Parent=settings

local settingsStroke=Instance.new("UIStroke")
settingsStroke.Color=Color3.fromRGB(70,70,70)
settingsStroke.Thickness=1
settingsStroke.Parent=settings

--==================================================
-- CAMERA SENSI SECTION
--==================================================

local cameraSection=Instance.new("Frame")
cameraSection.Name="CameraSensiSetting"
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.Size=UDim2.new(1,-20,0,190)
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
cameraTitle.TextSize=17
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local CFG={
	DefaultSens=1,
	MinSens=.1,
	MaxSens=10,
	AccentColor=Color3.fromRGB(170,0,255),
	ButtonColor=Color3.fromRGB(45,45,55)
}

local state={
	CurrentSens=CFG.DefaultSens
}

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

local function sensButton(text,pos)
	return makeButton(
		cameraSection,
		text,
		pos,
		UDim2.fromOffset(75,38),
		text,
		CFG.ButtonColor,
		43
	)
end

local sensMinus=sensButton("-",UDim2.new(.10,0,0,90))
local sensReset=sensButton("RESET",UDim2.new(.5,-37,0,90))
local sensPlus=sensButton("+",UDim2.new(.90,-75,0,90))

local function updateSensitivity(amount)
	state.CurrentSens=math.clamp(
		state.CurrentSens+amount,
		CFG.MinSens,
		CFG.MaxSens
	)

	sensLabel.Text=
		"Multiplier: "..string.format("%.1f",state.CurrentSens).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=state.CurrentSens
	end)
end

sensMinus.Activated:Connect(function()
	updateSensitivity(-.1)
end)

sensPlus.Activated:Connect(function()
	updateSensitivity(.1)
end)

sensReset.Activated:Connect(function()
	state.CurrentSens=CFG.DefaultSens

	sensLabel.Text="Multiplier: 1.0x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CFG.DefaultSens
	end)
end)

updateSensitivity(0)

--==================================================
-- JUMP SECTION
--==================================================

local jumpSection=Instance.new("Frame")
jumpSection.Name="JumpSetting"
jumpSection.Position=UDim2.fromOffset(10,210)
jumpSection.Size=UDim2.new(1,-20,0,235)
jumpSection.BackgroundColor3=Color3.fromRGB(32,32,38)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings

local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection

local jumpTitle=Instance.new("TextLabel")
jumpTitle.Size=UDim2.new(1,0,0,40)
jumpTitle.Text="JUMP SETTING"
jumpTitle.TextColor3=Color3.new(1,1,1)
jumpTitle.Font=Enum.Font.GothamBold
jumpTitle.TextSize=17
jumpTitle.BackgroundTransparency=1
jumpTitle.ZIndex=42
jumpTitle.Parent=jumpSection

local function jumpControl(name,pos,text)
	return makeButton(
		jumpSection,
		name,
		pos,
		UDim2.fromOffset(58,38),
		text,
		Color3.fromRGB(45,45,55),
		43
	)
end

local moveUp=jumpControl("MoveUp",UDim2.new(.5,-29,0,45),"↑")
local moveLeft=jumpControl("MoveLeft",UDim2.new(.12,0,0,88),"←")
local moveRight=jumpControl("MoveRight",UDim2.new(.88,-58,0,88),"→")
local moveDown=jumpControl("MoveDown",UDim2.new(.5,-29,0,131),"↓")

local sizePlus=jumpControl("SizePlus",UDim2.new(.08,0,0,180),"SIZE +")
sizePlus.Size=UDim2.fromOffset(85,32)

local sizeMinus=jumpControl("SizeMinus",UDim2.new(.92,-85,0,180),"SIZE -")
sizeMinus.Size=UDim2.fromOffset(85,32)

local center=jumpControl("Center",UDim2.new(.5,-42,0,180),"CENTER")
center.Size=UDim2.fromOffset(80,32)

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
-- JUMP FUNCTIONS
--==================================================

local function findJump()
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then return nil end

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
	if destroyed or updatingJump then return end

	local jump=getJump()
	local camera=workspace.CurrentCamera

	if not jump or not camera then return end

	local viewport=camera.ViewportSize

	if viewport.X<=0 or viewport.Y<=0 then return end

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
-- ONE MENU CONTROL
--==================================================

connect(menu.Activated,function()
	if destroyed then return end

	settings.Visible=not settings.Visible
end)

connect(close.Activated,function()
	settings.Visible=false
end)

--==================================================
-- JUMP REFRESH
--==================================================

local function refreshJump()
	jumpButton=nil

	task.defer(updateJump)
	task.delay(.1,updateJump)
	task.delay(.25,updateJump)
	task.delay(.5,updateJump)
	task.delay(1,updateJump)
end

connect(player.CharacterAdded,function(newCharacter)
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

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		refreshJump()
	end
end)

connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	task.defer(updateJump)
end)

task.spawn(function()
	for _=1,200 do
		if destroyed then return end

		if getJump() then
			updateJump()
			return
		end

		task.wait(.1)
	end
end)

updateWLock()
updateJump()
