local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local CONFIG_FILE="DeltaMobileConfig.json"

local defaultConfig={
	JumpX=.85,
	JumpY=.75,
	JumpSize=.30,
	ShiftX=.75,
	ShiftY=.65,
	ShiftSize=35,
	AnalogX=.16,
	AnalogY=.76,
	AnalogSize=120,
	Sensitivity=1,
	TouchSupport=3
}

local SHIFT_LOCK_IMAGE="rbxassetid://6031068426"
local OPEN_MENU_IMAGE="rbxassetid://1234567890"

local config={}
for k,v in pairs(defaultConfig) do
	config[k]=v
end

local function saveConfig()
	pcall(function()
		if type(writefile)=="function" then
			writefile(CONFIG_FILE,HttpService:JSONEncode(config))
		end
	end)
end

local function loadConfig()
	pcall(function()
		if type(readfile)=="function" and type(isfile)=="function" and isfile(CONFIG_FILE) then
			local data=HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(data)=="table" then
				for k,v in pairs(data) do
					if defaultConfig[k]~=nil and type(v)==type(defaultConfig[k]) then
						config[k]=v
					end
				end
			end
		end
	end)
end

loadConfig()

config.JumpX=math.clamp(tonumber(config.JumpX) or defaultConfig.JumpX,.05,.95)
config.JumpY=math.clamp(tonumber(config.JumpY) or defaultConfig.JumpY,.05,.95)
config.JumpSize=math.clamp(tonumber(config.JumpSize) or defaultConfig.JumpSize,.05,.50)
config.ShiftX=math.clamp(tonumber(config.ShiftX) or defaultConfig.ShiftX,.02,.98)
config.ShiftY=math.clamp(tonumber(config.ShiftY) or defaultConfig.ShiftY,.02,.98)
config.ShiftSize=math.clamp(tonumber(config.ShiftSize) or defaultConfig.ShiftSize,20,100)
config.AnalogX=math.clamp(tonumber(config.AnalogX) or defaultConfig.AnalogX,.05,.50)
config.AnalogY=math.clamp(tonumber(config.AnalogY) or defaultConfig.AnalogY,.45,.95)
config.AnalogSize=math.clamp(tonumber(config.AnalogSize) or defaultConfig.AnalogSize,80,220)
config.Sensitivity=math.clamp(tonumber(config.Sensitivity) or defaultConfig.Sensitivity,.1,10)
config.TouchSupport=math.clamp(math.floor(tonumber(config.TouchSupport) or defaultConfig.TouchSupport),2,4)

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local destroyed=false

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
	for i=#connections,1,-1 do
		pcall(function()
			connections[i]:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyGui(name)
	local gui=playerGui:FindFirstChild(name)
	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
end

_G.DeltaMobileControlsCleanup=function()
	if destroyed then return end
	destroyed=true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")

_G.ShiftLocked=false

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=999999
screenGui.Parent=playerGui

local crosshair=Instance.new("Frame")
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.Position=UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000000
crosshair.Parent=screenGui

local crosshairCorner=Instance.new("UICorner")
crosshairCorner.CornerRadius=UDim.new(1,0)
crosshairCorner.Parent=crosshair

local btnShiftLock=Instance.new("ImageButton")
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(.5,.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image=SHIFT_LOCK_IMAGE
btnShiftLock.ImageColor3=Color3.new(1,1,1)
btnShiftLock.BackgroundColor3=Color3.new(1,1,1)
btnShiftLock.BackgroundTransparency=.2
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.Selectable=false
btnShiftLock.BorderSizePixel=0
btnShiftLock.ZIndex=100000
btnShiftLock.Parent=screenGui

local shiftCorner=Instance.new("UICorner")
shiftCorner.CornerRadius=UDim.new(1,0)
shiftCorner.Parent=btnShiftLock

local shiftStroke=Instance.new("UIStroke")
shiftStroke.Thickness=2
shiftStroke.Color=Color3.new(0,0,0)
shiftStroke.Transparency=.3
shiftStroke.Parent=btnShiftLock

local function toggleShiftLock()
	if destroyed then return end
	_G.ShiftLocked=not _G.ShiftLocked
	crosshair.Visible=_G.ShiftLocked
	btnShiftLock.BackgroundColor3=_G.ShiftLocked and Color3.fromRGB(170,0,255) or Color3.new(1,1,1)
	if humanoid and humanoid.Parent then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end
end

connect(btnShiftLock.Activated,toggleShiftLock)

local analogFrame=Instance.new("Frame")
analogFrame.Name="ClassicAnalog"
analogFrame.AnchorPoint=Vector2.new(.5,.5)
analogFrame.Position=UDim2.new(config.AnalogX,0,config.AnalogY,0)
analogFrame.Size=UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
analogFrame.BackgroundColor3=Color3.fromRGB(35,35,35)
analogFrame.BackgroundTransparency=.38
analogFrame.BorderSizePixel=0
analogFrame.Active=true
analogFrame.ZIndex=100
analogFrame.Parent=screenGui

local analogCorner=Instance.new("UICorner")
analogCorner.CornerRadius=UDim.new(1,0)
analogCorner.Parent=analogFrame

local analogStroke=Instance.new("UIStroke")
analogStroke.Thickness=2
analogStroke.Transparency=.35
analogStroke.Color=Color3.new(1,1,1)
analogStroke.Parent=analogFrame

local analogKnob=Instance.new("Frame")
analogKnob.AnchorPoint=Vector2.new(.5,.5)
analogKnob.Position=UDim2.fromScale(.5,.5)
analogKnob.Size=UDim2.fromScale(.42,.42)
analogKnob.BackgroundColor3=Color3.fromRGB(225,225,225)
analogKnob.BackgroundTransparency=.12
analogKnob.BorderSizePixel=0
analogKnob.ZIndex=101
analogKnob.Parent=analogFrame

local knobCorner=Instance.new("UICorner")
knobCorner.CornerRadius=UDim.new(1,0)
knobCorner.Parent=analogKnob

local analogTouch
local analogVector=Vector2.zero
local analogCenter=Vector2.zero
local analogRadius=1

local function resetAnalog()
	analogTouch=nil
	analogVector=Vector2.zero
	analogKnob.Position=UDim2.fromScale(.5,.5)
end

local function updateAnalogGeometry()
	analogCenter=analogFrame.AbsolutePosition+analogFrame.AbsoluteSize/2
	analogRadius=math.max(1,math.min(analogFrame.AbsoluteSize.X,analogFrame.AbsoluteSize.Y)/2)
end

local function updateAnalog(position)
	local delta=position-analogCenter
	local radius=analogRadius*.68
	if delta.Magnitude>radius then
		delta=delta.Unit*radius
	end
	analogVector=radius>0 and delta/radius or Vector2.zero
	if analogVector.Magnitude<.08 then
		analogVector=Vector2.zero
	end
	local visual=analogVector*.34
	analogKnob.Position=UDim2.new(.5+visual.X,0,.5+visual.Y,0)
end

local function edgeTouch(position)
	local camera=workspace.CurrentCamera
	if not camera then return false end
	local size=camera.ViewportSize
	local ex=math.max(28,size.X*.025)
	local ey=math.max(28,size.Y*.025)
	return position.X<=ex or position.X>=size.X-ex or position.Y<=ey or position.Y>=size.Y-ey
end

local function touchCount()
	local count=0
	for _,input in ipairs(UserInputService:GetTouches()) do
		if input.UserInputState~=Enum.UserInputState.End then
			count+=1
		end
	end
	return count
end

connect(analogFrame.InputBegan,function(input)
	if destroyed or analogTouch then return end
	if input.UserInputType~=Enum.UserInputType.Touch then return end
	if edgeTouch(input.Position) then return end
	if touchCount()>config.TouchSupport then return end
	updateAnalogGeometry()
	analogTouch=input
	updateAnalog(input.Position)
end)

connect(UserInputService.InputChanged,function(input)
	if input==analogTouch and input.UserInputType==Enum.UserInputType.Touch then
		updateAnalog(input.Position)
	end
end)

connect(UserInputService.InputEnded,function(input)
	if input==analogTouch then
		resetAnalog()
	end
end)

connect(UserInputService.TouchEnded,function(input)
	if input==analogTouch then
		resetAnalog()
	end
end)

local cachedForward=Vector3.new(0,0,-1)
local cachedRight=Vector3.new(1,0,0)

local function updateCameraVectors()
	local camera=workspace.CurrentCamera
	if not camera then return end
	local look=camera.CFrame.LookVector
	local right=camera.CFrame.RightVector
	local forward=Vector3.new(look.X,0,look.Z)
	local side=Vector3.new(right.X,0,right.Z)
	if forward.Magnitude>.001 then
		cachedForward=forward.Unit
	end
	if side.Magnitude>.001 then
		cachedRight=side.Unit
	end
end

connect(RunService.RenderStepped,function()
	if destroyed or not character or not character.Parent or not humanoid or humanoid.Health<=0 then
		return
	end

	updateCameraVectors()

	local x=analogVector.X
	local z=-analogVector.Y
	local movement=cachedRight*x+cachedForward*z

	if movement.Magnitude>.001 then
		movement=movement.Unit*math.clamp(analogVector.Magnitude,0,1)
	else
		movement=Vector3.zero
	end

	humanoid:Move(movement,false)

	if _G.ShiftLocked then
		local camera=workspace.CurrentCamera
		local root=character:FindFirstChild("HumanoidRootPart")
		if camera and root then
			local look=Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)
			if look.Magnitude>.001 then
				root.CFrame=CFrame.lookAt(root.Position,root.Position+look.Unit)
			end
		end
		humanoid.AutoRotate=false
	else
		humanoid.AutoRotate=true
	end

	humanoid.CameraOffset=Vector3.zero
end)

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=1000000
gui.Parent=playerGui

local menu=Instance.new("ImageButton")
menu.Name="OpenMenu"
menu.AnchorPoint=Vector2.new(1,1)
menu.Position=UDim2.new(1,-18,1,-18)
menu.Size=UDim2.fromOffset(58,58)
menu.Image=OPEN_MENU_IMAGE
menu.BackgroundColor3=Color3.fromRGB(30,30,40)
menu.BackgroundTransparency=.05
menu.AutoButtonColor=false
menu.ZIndex=100
menu.Parent=gui

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

local menuStroke=Instance.new("UIStroke")
menuStroke.Thickness=2
menuStroke.Transparency=.15
menuStroke.Color=Color3.fromRGB(170,0,255)
menuStroke.Parent=menu

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.AnchorPoint=Vector2.new(.5,.5)
settings.Size=UDim2.fromOffset(320,570)
settings.Position=UDim2.new(.5,0,.5,0)
settings.BackgroundColor3=Color3.fromRGB(18,18,26)
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=200
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,18)
settingsCorner.Parent=settings

local settingsStroke=Instance.new("UIStroke")
settingsStroke.Thickness=2
settingsStroke.Transparency=.15
settingsStroke.Color=Color3.fromRGB(170,0,255)
settingsStroke.Parent=settings

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-30,0,48)
title.Position=UDim2.fromOffset(15,10)
title.BackgroundTransparency=1
title.Text="DELTA MOBILE CONTROLS"
title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold
title.TextSize=18
title.ZIndex=201
title.Parent=settings

local function makeButton(parent,name,pos,size,text)
	local b=Instance.new("TextButton")
	b.Name=name
	b.Position=pos
	b.Size=size
	b.Text=text
	b.BackgroundColor3=Color3.fromRGB(35,35,48)
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=15
	b.AutoButtonColor=false
	b.BorderSizePixel=0
	b.ZIndex=202
	b.Parent=parent
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,10)
	c.Parent=b
	return b
end

local target="JUMP"

local targetButton=makeButton(settings,"Target",UDim2.fromOffset(15,65),UDim2.new(1,-30,0,40),"TARGET: JUMP")

connect(targetButton.Activated,function()
	if target=="JUMP" then
		target="SHIFT"
		targetButton.Text="TARGET: SHIFTLOCK"
	else
		target="JUMP"
		targetButton.Text="TARGET: JUMP"
	end
end)

local jumpTitle=Instance.new("TextLabel")
jumpTitle.Size=UDim2.new(1,-30,0,28)
jumpTitle.Position=UDim2.fromOffset(15,118)
jumpTitle.BackgroundTransparency=1
jumpTitle.Text="POSITION"
jumpTitle.TextXAlignment=Enum.TextXAlignment.Left
jumpTitle.TextColor3=Color3.fromRGB(190,190,210)
jumpTitle.Font=Enum.Font.GothamBold
jumpTitle.TextSize=13
jumpTitle.ZIndex=202
jumpTitle.Parent=settings

local up=makeButton(settings,"Up",UDim2.new(.5,-30,0,150),UDim2.fromOffset(60,42),"↑")
local left=makeButton(settings,"Left",UDim2.new(.5,-95,0,195),UDim2.fromOffset(60,42),"←")
local right=makeButton(settings,"Right",UDim2.new(.5,35,0,195),UDim2.fromOffset(60,42),"→")
local down=makeButton(settings,"Down",UDim2.new(.5,-30,0,240),UDim2.fromOffset(60,42),"↓")

local sizeMinus=makeButton(settings,"SizeMinus",UDim2.fromOffset(15,300),UDim2.fromOffset(90,40),"SIZE -")
local reset=makeButton(settings,"Reset",UDim2.new(.5,-45,0,300),UDim2.fromOffset(90,40),"RESET")
local sizePlus=makeButton(settings,"SizePlus",UDim2.new(1,-105,0,300),UDim2.fromOffset(90,40),"SIZE +")

local analogTitle=Instance.new("TextLabel")
analogTitle.Size=UDim2.new(1,-30,0,28)
analogTitle.Position=UDim2.fromOffset(15,355)
analogTitle.BackgroundTransparency=1
analogTitle.Text="ANALOG"
analogTitle.TextXAlignment=Enum.TextXAlignment.Left
analogTitle.TextColor3=Color3.fromRGB(190,190,210)
analogTitle.Font=Enum.Font.GothamBold
analogTitle.TextSize=13
analogTitle.ZIndex=202
analogTitle.Parent=settings

local analogLeft=makeButton(settings,"AnalogLeft",UDim2.fromOffset(15,390),UDim2.fromOffset(90,40),"LEFT")
local analogRight=makeButton(settings,"AnalogRight",UDim2.new(1,-105,0,390),UDim2.fromOffset(90,40),"RIGHT")
local analogUp=makeButton(settings,"AnalogUp",UDim2.new(.5,-45,0,435),UDim2.fromOffset(90,40),"UP")
local analogDown=makeButton(settings,"AnalogDown",UDim2.new(.5,-45,0,480),UDim2.fromOffset(90,40),"DOWN")

local touchButton=makeButton(settings,"TouchSupport",UDim2.fromOffset(15,525),UDim2.fromOffset(135,35),"TOUCH: "..config.TouchSupport)
local saveButton=makeButton(settings,"Save",UDim2.new(1,-150,0,525),UDim2.fromOffset(135,35),"SAVE")

local jumpButton

local function getJump()
	if jumpButton and jumpButton.Parent and jumpButton:IsDescendantOf(playerGui) then
		return jumpButton
	end
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if touchGui then
		jumpButton=touchGui:FindFirstChild("JumpButton",true)
	end
	return jumpButton
end

local function updateJump()
	local jump=getJump()
	local camera=workspace.CurrentCamera
	if not jump or not camera then return end

	local viewport=camera.ViewportSize
	local size=math.max(40,math.floor(viewport.Y*config.JumpSize))

	pcall(function()
		jump.AnchorPoint=Vector2.new(.5,.5)
		jump.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size=UDim2.fromOffset(size,size)
	end)
end

local function updateShift()
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function updateAnalogPosition()
	analogFrame.Position=UDim2.new(config.AnalogX,0,config.AnalogY,0)
	analogFrame.Size=UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
	updateAnalogGeometry()
	resetAnalog()
end

local function changePosition(dx,dy)
	if target=="JUMP" then
		config.JumpX=math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY=math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	elseif target=="SHIFT" then
		config.ShiftX=math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY=math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	end
end

connect(up.Activated,function()
	changePosition(0,-.018)
end)

connect(down.Activated,function()
	changePosition(0,.018)
end)

connect(left.Activated,function()
	changePosition(-.018,0)
end)

connect(right.Activated,function()
	changePosition(.018,0)
end)

connect(sizePlus.Activated,function()
	if target=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	elseif target=="SHIFT" then
		config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if target=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	elseif target=="SHIFT" then
		config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(reset.Activated,function()
	if target=="JUMP" then
		config.JumpX=defaultConfig.JumpX
		config.JumpY=defaultConfig.JumpY
		config.JumpSize=defaultConfig.JumpSize
		updateJump()
	elseif target=="SHIFT" then
		config.ShiftX=defaultConfig.ShiftX
		config.ShiftY=defaultConfig.ShiftY
		config.ShiftSize=defaultConfig.ShiftSize
		updateShift()
	end
end)

local function changeAnalog(dx,dy)
	config.AnalogX=math.clamp(config.AnalogX+dx,.05,.50)
	config.AnalogY=math.clamp(config.AnalogY+dy,.45,.95)
	updateAnalogPosition()
end

connect(analogLeft.Activated,function()
	changeAnalog(-.018,0)
end)

connect(analogRight.Activated,function()
	changeAnalog(.018,0)
end)

connect(analogUp.Activated,function()
	changeAnalog(0,-.018)
end)

connect(analogDown.Activated,function()
	changeAnalog(0,.018)
end)

connect(touchButton.Activated,function()
	config.TouchSupport+=1
	if config.TouchSupport>4 then
		config.TouchSupport=2
	end
	touchButton.Text="TOUCH: "..config.TouchSupport
end)

local function applySensitivity()
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=config.Sensitivity
	end)
end

connect(saveButton.Activated,function()
	saveConfig()
	loadConfig()
	applySensitivity()
	updateJump()
	updateShift()
	updateAnalogPosition()
	saveButton.Text="SAVED + LOADED"
	task.delay(1,function()
		if saveButton and saveButton.Parent then
			saveButton.Text="SAVE"
		end
	end)
end)

connect(menu.Activated,function()
	settings.Visible=not settings.Visible
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	resetAnalog()

	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end

	task.defer(function()
		updateJump()
		updateShift()
		updateAnalogPosition()
	end)

	task.delay(.25,function()
		if not destroyed then
			updateJump()
			updateShift()
			updateAnalogPosition()
		end
	end)
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		jumpButton=nil
		task.defer(function()
			if not destroyed then
				updateJump()
			end
		end)
	end
end)

updateCameraVectors()
updateJump()
updateShift()
updateAnalogPosition()
applySensitivity()
