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
local MAIN_BUTTON_COLOR=Color3.fromRGB(255,255,255)
local DIAGONAL_BUTTON_COLOR=Color3.fromRGB(190,190,190)
local PRESSED_COLOR=Color3.fromRGB(70,150,255)
local WLOCK_OFF_COLOR=Color3.fromRGB(220,70,70)
local WLOCK_ON_COLOR=Color3.fromRGB(70,200,100)
local AUTO_OFF_COLOR=Color3.fromRGB(220,220,220)
local AUTO_ON_COLOR=Color3.fromRGB(70,200,100)
local BUTTON_TRANSPARENCY=.15
local BUTTON_TEXT_COLOR=Color3.fromRGB(20,20,20)
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
local buttonDefaults={}
local actionButtons={}
local autoMode=false
local autoReverse=false
local autoIndex=1
local autoAirborne=false
local autoWaitingForGround=false
local autoLastState=Enum.HumanoidStateType.Landed
local autoDirection=nil
local autoSequenceForward={"Forward","Left","Backward","Right"}
local autoSequenceReverse={"Forward","Right","Backward","Left"}
local function isPressInput(input)
	if not input then
		return false
	end

	return input.UserInputType==Enum.UserInputType.Touch
		or input.UserInputType==Enum.UserInputType.MouseButton1
end

local function setButtonVisual(button,pressed)
	if not button or not button.Parent then
		return
	end

	local normalColor=buttonDefaults[button]

	if pressed then
		button.BackgroundColor3=PRESSED_COLOR
	elseif normalColor then
		button.BackgroundColor3=normalColor
	end
end

local function updateWLock()
	if destroyed or not btnWLock or not btnWLock.Parent then
		return
	end

	if moveState.WLock then
		btnWLock.BackgroundColor3=WLOCK_ON_COLOR
	else
		btnWLock.BackgroundColor3=WLOCK_OFF_COLOR
	end
end

local autoButton=nil

local function updateAutoButton()
	if destroyed or not autoButton or not autoButton.Parent then
		return
	end

	if autoMode then
		autoButton.BackgroundColor3=AUTO_ON_COLOR

		if autoReverse then
			autoButton.Text="AUTO ↶"
		else
			autoButton.Text="AUTO ↷"
		end
	else
		autoButton.BackgroundColor3=AUTO_OFF_COLOR
		autoButton.Text="AUTO"
	end
end

local function resetMovementVisuals()
	for button,color in pairs(buttonDefaults) do
		if button and button.Parent then
			button.BackgroundColor3=color
		end
	end

	updateWLock()
	updateAutoButton()
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

	resetMovementVisuals()
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

	local button=actionButtons[action]

	if button then
		setButtonVisual(button,pressed)
	end
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

local function createButton(name,position,size,text,zIndex,bgColor)
	local button=Instance.new("TextButton")

	button.Name=name
	button.Position=position
	button.Size=size
	button.Text=text
	button.BackgroundColor3=bgColor or MAIN_BUTTON_COLOR
	button.BackgroundTransparency=BUTTON_TRANSPARENCY
	button.TextColor3=BUTTON_TEXT_COLOR
	button.Font=Enum.Font.GothamBold
	button.TextSize=28
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=zIndex or 10
	button.Parent=mainFrame

	buttonDefaults[button]=button.BackgroundColor3

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
	10,
	MAIN_BUTTON_COLOR
)

local btnDown=createButton(
	"Down",
	UDim2.new(.33,0,.66,0),
	UDim2.new(.34,0,.34,0),
	"▼",
	10,
	MAIN_BUTTON_COLOR
)

local btnLeft=createButton(
	"Left",
	UDim2.new(0,0,.33,0),
	UDim2.new(.34,0,.34,0),
	"◀",
	10,
	MAIN_BUTTON_COLOR
)

local btnRight=createButton(
	"Right",
	UDim2.new(.66,0,.33,0),
	UDim2.new(.34,0,.34,0),
	"▶",
	10,
	MAIN_BUTTON_COLOR
)

local btnUL=createButton(
	"UpLeft",
	UDim2.new(.03,0,.03,0),
	UDim2.new(.27,0,.27,0),
	"↖",
	11,
	DIAGONAL_BUTTON_COLOR
)

local btnUR=createButton(
	"UpRight",
	UDim2.new(.70,0,.03,0),
	UDim2.new(.27,0,.27,0),
	"↗",
	11,
	DIAGONAL_BUTTON_COLOR
)

local btnDL=createButton(
	"DownLeft",
	UDim2.new(.03,0,.70,0),
	UDim2.new(.27,0,.27,0),
	"↙",
	11,
	DIAGONAL_BUTTON_COLOR
)

local btnDR=createButton(
	"DownRight",
	UDim2.new(.70,0,.70,0),
	UDim2.new(.27,0,.27,0),
	"↘",
	11,
	DIAGONAL_BUTTON_COLOR
)

btnWLock=Instance.new("TextButton")
btnWLock.Name="WLock"
btnWLock.Position=UDim2.new(.33,0,.33,0)
btnWLock.Size=UDim2.new(.34,0,.34,0)
btnWLock.Text="W"
btnWLock.BackgroundColor3=WLOCK_OFF_COLOR
btnWLock.BackgroundTransparency=BUTTON_TRANSPARENCY
btnWLock.TextColor3=BUTTON_TEXT_COLOR
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
	actionButtons[name]=button

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

		setButtonVisual(button,true)
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

	if autoMode then
		autoAirborne=false
		autoWaitingForGround=false
	end
end)

connect(btnWLock.InputBegan,function(input)
	if destroyed or not isPressInput(input) then
		return
	end

	setButtonVisual(btnWLock,true)
end)

connect(btnWLock.InputEnded,function()
	if destroyed then
		return
	end

	updateWLock()
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

	local forward=Vector3.new(
		look.X,
		0,
		look.Z
	)

	local side=Vector3.new(
		right.X,
		0,
		right.Z
	)

	if forward.Magnitude>.001 then
		cachedForward=forward.Unit
	end

	if side.Magnitude>.001 then
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

	if movement.Magnitude<.001 then
		return Vector3.zero
	end

	return movement.Unit
end

local function clearAutoDirection()
	moveState.Forward=false
	moveState.Backward=false
	moveState.Left=false
	moveState.Right=false
	moveState.UpLeft=false
	moveState.UpRight=false
	moveState.DownLeft=false
	moveState.DownRight=false

	for name,button in pairs(actionButtons) do
		setButtonVisual(button,false)
	end
end

local function setAutoDirection(direction)
	clearAutoDirection()

	if direction=="Forward" then
		moveState.Forward=true
	elseif direction=="Backward" then
		moveState.Backward=true
	elseif direction=="Left" then
		moveState.Left=true
	elseif direction=="Right" then
		moveState.Right=true
	end

	autoDirection=direction

	local button=actionButtons[direction]

	if button then
		setButtonVisual(button,true)
	end
end

local function getAutoSequence()
	if autoReverse then
		return autoSequenceReverse
	end

	return autoSequenceForward
end

local function setAutoCurrentDirection()
	if not autoMode then
		return
	end

	local sequence=getAutoSequence()
	autoIndex=math.clamp(autoIndex,1,#sequence)
	setAutoDirection(sequence[autoIndex])
end

local function enableAuto()
	autoMode=true
	autoReverse=false
	autoIndex=1
	autoAirborne=false
	autoWaitingForGround=false
	autoLastState=Enum.HumanoidStateType.Landed

	setAutoCurrentDirection()
	updateAutoButton()
end

local function disableAuto()
	autoMode=false
	autoAirborne=false
	autoWaitingForGround=false
	autoDirection=nil

	clearAutoDirection()

	updateAutoButton()
end

local function toggleAuto()
	if autoMode then
		disableAuto()
	else
		enableAuto()
	end
end

local function switchAutoDirection()
	if not autoMode then
		return
	end

	local sequence=getAutoSequence()

	autoIndex+=1

	if autoIndex>#sequence then
		autoIndex=1
	end

	setAutoCurrentDirection()
end

local function detectAutoJump()
	if not autoMode or not humanoid then
		return
	end

	local state=humanoid:GetState()

	if state==Enum.HumanoidStateType.Jumping
		or state==Enum.HumanoidStateType.Freefall then

		if not autoAirborne then
			autoAirborne=true
			autoWaitingForGround=true
		end

		return
	end

	if autoAirborne
		and autoWaitingForGround
		and (
			state==Enum.HumanoidStateType.Landed
			or state==Enum.HumanoidStateType.Running
			or state==Enum.HumanoidStateType.RunningNoPhysics
			or state==Enum.HumanoidStateType.Climbing
		) then

		autoAirborne=false
		autoWaitingForGround=false

		switchAutoDirection()
	end

	autoLastState=state
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

	if autoMode then
		detectAutoJump()
		currentHumanoid:Move(getMoveVector(),false)
	else
		currentHumanoid:Move(getMoveVector(),false)
	end
end)

local x=.70
local y=.70
local jumpSize=.30
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
	button.BackgroundColor3=bg or Color3.fromRGB(245,245,245)
	button.BackgroundTransparency=.05
	button.TextColor3=Color3.fromRGB(20,20,20)
	button.Font=Enum.Font.GothamBold
	button.TextSize=22
	button.AutoButtonColor=false
	button.Active
