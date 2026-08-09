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
		btnWLock.BackgroundColor3=Color3.fromRGB(0,220,0)
	else
		btnWLock.BackgroundColor3=Color3.fromRGB(220,0,0)
	end
end

local function clearMovement()
	for name in pairs(moveState) do
		if name ~= "WLock" then
			moveState[name]=false
		end
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

local function applyStyle(target)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
	})
	gradient.Rotation = 90
	gradient.Parent = target
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 3
	stroke.Transparency = 0.3
	stroke.Parent = target
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
mainFrame.Position=UDim2.new(0,20,1,-330)
mainFrame.BackgroundTransparency=1
mainFrame.BorderSizePixel=0
mainFrame.Parent=screenGui

local function createButton(name,position,size,text,zIndex)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=position
	button.Size=size
	button.Text=text
	button.BackgroundColor3=Color3.fromRGB(255,255,255)
	
	applyStyle(button)
	
	button.TextColor3=Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0
	button.Font=Enum.Font.GothamBlack
	button.TextSize=36
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

local btnUp=createButton("Up",UDim2.new(.33,0,0,0),UDim2.new(.34,0,.34,0),"▲",10)
local btnDown=createButton("Down",UDim2.new(.33,0,.66,0),UDim2.new(.34,0,.34,0),"▼",10)
local btnLeft=createButton("Left",UDim2.new(0,0,.33,0),UDim2.new(.34,0,.34,0),"◀",10)
local btnRight=createButton("Right",UDim2.new(.66,0,.33,0),UDim2.new(.34,0,.34,0),"▶",10)
local btnUL=createButton("UpLeft",UDim2.new(.05,0,.05,0),UDim2.new(.28,0,.28,0),"↖",11)
local btnUR=createButton("UpRight",UDim2.new(.67,0,.05,0),UDim2.new(.28,0,.28,0),"↗",11)
local btnDL=createButton("DownLeft",UDim2.new(.05,0,.67,0),UDim2.new(.28,0,.28,0),"↙",11)
local btnDR=createButton("DownRight",UDim2.new(.67,0,.67,0),UDim2.new(.28,0,.28,0),"↘",11)

btnWLock=Instance.new("TextButton")
btnWLock.Name="WLock"
btnWLock.Position=UDim2.new(.33,0,.33,0)
btnWLock.Size=UDim2.new(.34,0,.34,0)
btnWLock.Text="W"
btnWLock.BackgroundColor3=Color3.fromRGB(220,0,0)
btnWLock.TextColor3=Color3.new(1,1,1)
btnWLock.Font=Enum.Font.GothamBlack
btnWLock.TextSize=32
btnWLock.AutoButtonColor=false
btnWLock.Active=true
btnWLock.Selectable=false
btnWLock.BorderSizePixel=0
btnWLock.ZIndex=12
btnWLock.Parent=mainFrame
applyStyle(btnWLock)

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
		inputActions[input]=name
		buttonInputs[name][input]=true
		moveState[name]=true
	end)

	connect(button.InputEnded,function(input)
		if inputActions[input] then
			inputActions[input]=nil
			buttonInputs[name][input]=nil
			local stillPressed=false
			for _ in pairs(buttonInputs[name]) do stillPressed=true break end
			moveState[name]=stillPressed
		end
	end)
end

connect(UserInputService.InputEnded,function(input) releaseInput(input) end)
connect(UserInputService.TouchEnded,function(input) releaseInput(input) end)
connect(UserInputService.WindowFocusReleased,function() clearMovement() end)

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
	if forward.Magnitude<0.001 or side.Magnitude<0.001 then return Vector3.zero end
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
		if moveState.WLock then z=1 else return Vector3.zero end
	end
	local movement=side*x+forward*z
	if movement.Magnitude<0.001 then return Vector3.zero end
	return movement.Unit
end

connect(RunService.RenderStepped,function()
	if destroyed or not character or not humanoid or humanoid.Parent~=character or humanoid.Health<=0 then return end
	humanoid:Move(getMoveVector(),false)
end)

