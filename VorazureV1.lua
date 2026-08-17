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
	AnalogX=.14,
	AnalogY=.78,
	AnalogSize=.30,
	Sensitivity=1,
	TouchSupport=4
}

local SHIFT_LOCK_IMAGE="rbxassetid://6031068426"
local OPEN_MENU_IMAGE="rbxassetid://1234567890"

local config={}
for k,v in pairs(defaultConfig) do
	config[k]=v
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE,HttpService:JSONEncode(config))
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
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
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.Position=UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000000
crosshair.Parent=screenGui

local crossCorner=Instance.new("UICorner")
crossCorner.CornerRadius=UDim.new(1,0)
crossCorner.Parent=crosshair

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

	btnShiftLock.BackgroundColor3=_G.ShiftLocked
		and Color3.fromRGB(170,0,255)
		or Color3.new(1,1,1)

	crosshair.Visible=_G.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end
end

connect(btnShiftLock.Activated,toggleShiftLock)

local function getTouchGui()
	return playerGui:FindFirstChild("TouchGui")
end

local function getJump()
	local touchGui=getTouchGui()
	if not touchGui then return nil end

	local jump=touchGui:FindFirstChild("JumpButton",true)
	if jump and jump:IsA("GuiObject") then
		return jump
	end

	return nil
end

local function getAnalog()
	local touchGui=getTouchGui()
	if not touchGui then return nil end

	local frame=touchGui:FindFirstChild("TouchControlFrame",true)
	if not frame then return nil end

	local analog=frame:FindFirstChild("DynamicThumbstickFrame",true)
	if analog and analog:IsA("GuiObject") then
		return analog
	end

	analog=frame:FindFirstChild("ThumbstickFrame",true)
	if analog and analog:IsA("GuiObject") then
		return analog
	end

	return nil
end

local function updateJump()
	if destroyed then return end

	local jump=getJump()
	local camera=workspace.CurrentCamera

	if not jump or not camera then return end

	local viewport=camera.ViewportSize

	if viewport.X<=0 or viewport.Y<=0 then return end

	config.JumpX=math.clamp(config.JumpX,.05,.95)
	config.JumpY=math.clamp(config.JumpY,.05,.95)
	config.JumpSize=math.clamp(config.JumpSize,.05,.50)

	local size=math.max(40,math.floor(viewport.Y*config.JumpSize))

	pcall(function()
		jump.AnchorPoint=Vector2.new(.5,.5)
		jump.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size=UDim2.fromOffset(size,size)
	end)
end

local function updateShift()
	if destroyed then return end
	if not btnShiftLock or not btnShiftLock.Parent then return end

	config.ShiftX=math.clamp(config.ShiftX,.02,.98)
	config.ShiftY=math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize=math.clamp(config.ShiftSize,20,100)

	btnShiftLock.AnchorPoint=Vector2.new(.5,.5)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function updateAnalog()
	if destroyed then return end

	local analog=getAnalog()
	if not analog then return end

	config.AnalogX=math.clamp(config.AnalogX,.02,.45)
	config.AnalogY=math.clamp(config.AnalogY,.55,.95)
	config.AnalogSize=math.clamp(config.AnalogSize,.10,.45)

	pcall(function()
		analog.AnchorPoint=Vector2.new(.5,.5)
		analog.Position=UDim2.new(config.AnalogX,0,config.AnalogY,0)
		analog.Size=UDim2.new(config.AnalogSize,0,config.AnalogSize,0)
	end)
end

local function refreshControls()
	task.defer(function()
		updateJump()
		updateShift()
		updateAnalog()
	end)

	task.delay(.15,function()
		if not destroyed then
			updateJump()
			updateShift()
			updateAnalog()
		end
	end)

	task.delay(.5,function()
		if not destroyed then
			updateJump()
			updateAnalog()
		end
	end)
end

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=1000000
gui.Parent=playerGui

local function makeButton(parent,name,pos,size,text,bg,z)
	local b=Instance.new("TextButton")
	b.Name=name
	b.Position=pos
	b.Size=size
	b.Text=text
	b.BackgroundColor3=bg or Color3.fromRGB(30,30,42)
	b.BackgroundTransparency=.03
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=17
	b.AutoButtonColor=false
	b.Active=true
	b.Selectable=false
	b.BorderSizePixel=0
	b.ZIndex=z or 41
	b.Parent=parent

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,12)
	c.Parent=b

	local s=Instance.new("UIStroke")
	s.Thickness=1.5
	s.Color=Color3.fromRGB(170,0,255)
	s.Transparency=.25
	s.Parent=b

	return b
end

local menu=Instance.new("ImageButton")
menu.Name="OpenMenu"
menu.AnchorPoint=Vector2.new(1,1)
menu.Position=UDim2.new(1,-16,1,-16)
menu.Size=UDim2.fromOffset(60,60)
menu.Image=OPEN_MENU_IMAGE
menu.BackgroundColor3=Color3.fromRGB(25,25,35)
menu.BackgroundTransparency=.05
menu.AutoButtonColor=false
menu.Active=true
menu.Selectable=false
menu.ZIndex=100
menu.Parent=gui

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

local menuStroke=Instance.new("UIStroke")
menuStroke.Thickness=2
menuStroke.Color=Color3.fromRGB(170,0,255)
menuStroke.Parent=menu

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.AnchorPoint=Vector2.new(.5,.5)
settings.Size=UDim2.fromOffset(320,590)
settings.Position=UDim2.new(.5,0,.5,0)
settings.BackgroundColor3=Color3.fromRGB(16,16,25)
settings.BackgroundTransparency=.02
settings.BorderSizePixel=0
settings.Visible=false
settings.Active=true
settings.ZIndex=40
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,18)
settingsCorner.Parent=settings

local settingsStroke=Instance.new("UIStroke")
settingsStroke.Thickness=2
settingsStroke.Color=Color3.fromRGB(170,0,255)
settingsStroke.Transparency=.1
settingsStroke.Parent=settings

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-20,0,42)
title.Position=UDim2.fromOffset(10,4)
title.Text="DELTA MOBILE CONTROLS"
title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold
title.TextSize=18
title.BackgroundTransparency=1
title.ZIndex=41
title.Parent=settings

local cameraSection=Instance.new("Frame")
cameraSection.Size=UDim2.new(1,-20,0,105)
cameraSection.Position=UDim2.fromOffset(10,48)
cameraSection.BackgroundColor3=Color3.fromRGB(27,27,39)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings

local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,28)
cameraTitle.Text="CAMERA SENSITIVITY"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=14
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,25)
sensLabel.Position=UDim2.fromOffset(0,27)
sensLabel.TextColor3=Color3.fromRGB(190,190,205)
sensLabel.Font=Enum.Font.Gotham
sensLabel.TextSize=13
sensLabel.BackgroundTransparency=1
sensLabel.ZIndex=42
sensLabel.Parent=cameraSection

local function applySensitivity()
	sensLabel.Text="Multiplier: "..string.format("%.1f",config.Sensitivity).."x"
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=config.Sensitivity
	end)
end

local sensMinus=makeButton(cameraSection,"Minus",UDim2.new(.06,0,0,62),UDim2.fromOffset(76,34),"-",nil,43)
local sensReset=makeButton(cameraSection,"Reset",UDim2.new(.5,-42,0,62),UDim2.fromOffset(84,34),"RESET",nil,43)
local sensPlus=makeButton(cameraSection,"Plus",UDim2.new(.94,-76,0,62),UDim2.fromOffset(76,34),"+",nil,43)

connect(sensMinus.Activated,function()
	config.Sensitivity=math.clamp(config.Sensitivity-.1,.1,10)
	applySensitivity()
end)

connect(sensPlus.Activated,function()
	config.Sensitivity=math.clamp(config.Sensitivity+.1,.1,10)
	applySensitivity()
end)

connect(sensReset.Activated,function()
	config.Sensitivity=1
	applySensitivity()
end)

local controlSection=Instance.new("Frame")
controlSection.Size=UDim2.new(1,-20,0,370)
controlSection.Position=UDim2.fromOffset(10,163)
controlSection.BackgroundColor3=Color3.fromRGB(27,27,39)
controlSection.BorderSizePixel=0
controlSection.ZIndex=41
controlSection.Parent=settings

local controlCorner=Instance.new("UICorner")
controlCorner.CornerRadius=UDim.new(0,12)
controlCorner.Parent=controlSection

local targetMode="JUMP"

local targetButton=makeButton(
	controlSection,
	"TargetMode",
	UDim2.new(.05,0,0,10),
	UDim2.new(.9,0,0,38),
	"TARGET: JUMP BUTTON",
	Color3.fromRGB(70,150,255),
	43
)

local function updateTargetText()
	if targetMode=="JUMP" then
		targetButton.Text="TARGET: JUMP BUTTON"
		targetButton.BackgroundColor3=Color3.fromRGB(70,150,255)
	elseif targetMode=="SHIFT" then
		targetButton.Text="TARGET: SHIFT LOCK"
		targetButton.BackgroundColor3=Color3.fromRGB(170,0,255)
	else
		targetButton.Text="TARGET: ANALOG BAWAAN"
		targetButton.BackgroundColor3=Color3.fromRGB(50,180,130)
	end
end

connect(targetButton.Activated,function()
	if targetMode=="JUMP" then
		targetMode="SHIFT"
	elseif targetMode=="SHIFT" then
		targetMode="ANALOG"
	else
		targetMode="JUMP"
	end
	updateTargetText()
end)

local moveUp=makeButton(controlSection,"MoveUp",UDim2.new(.5,-34,0,62),UDim2.fromOffset(68,42),"↑",nil,43)
local moveLeft=makeButton(controlSection,"MoveLeft",UDim2.new(.10,0,0,105),UDim2.fromOffset(68,42),"←",nil,43)
local moveRight=makeButton(controlSection,"MoveRight",UDim2.new(.90,-68,0,105),UDim2.fromOffset(68,42),"→",nil,43)
local moveDown=makeButton(controlSection,"MoveDown",UDim2.new(.5,-34,0,148),UDim2.fromOffset(68,42),"↓",nil,43)

local sizePlus=makeButton(controlSection,"SizePlus",UDim2.new(.06,0,0,205),UDim2.fromOffset(88,34),"SIZE +",nil,43)
local center=makeButton(controlSection,"Center",UDim2.new(.5,-44,0,205),UDim2.fromOffset(88,34),"RESET",nil,43)
local sizeMinus=makeButton(controlSection,"SizeMinus",UDim2.new(.94,-88,0,205),UDim2.fromOffset(88,34),"SIZE -",nil,43)

local touchButton=makeButton(
	controlSection,
	"TouchSupport",
	UDim2.new(.05,0,0,252),
	UDim2.new(.9,0,0,36),
	"TOUCH SUPPORT: "..config.TouchSupport.." JARI",
	Color3.fromRGB(70,150,255),
	43
)

local function applyMoveStep(dx,dy)
	if targetMode=="JUMP" then
		config.JumpX=math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY=math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	elseif targetMode=="SHIFT" then
		config.ShiftX=math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY=math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	else
		config.AnalogX=math.clamp(config.AnalogX+dx,.02,.45)
		config.AnalogY=math.clamp(config.AnalogY+dy,.55,.95)
		updateAnalog()
	end
end

connect(moveUp.Activated,function()
	applyMoveStep(0,-.018)
end)

connect(moveDown.Activated,function()
	applyMoveStep(0,.018)
end)

connect(moveLeft.Activated,function()
	applyMoveStep(-.018,0)
end)

connect(moveRight.Activated,function()
	applyMoveStep(.018,0)
end)

connect(sizePlus.Activated,function()
	if targetMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	elseif targetMode=="SHIFT" then
		config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	else
		config.AnalogSize=math.clamp(config.AnalogSize+.025,.10,.45)
		updateAnalog()
	end
end)

connect(sizeMinus.Activated,function()
	if targetMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	elseif targetMode=="SHIFT" then
		config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	else
		config.AnalogSize=math.clamp(config.AnalogSize-.025,.10,.45)
		updateAnalog()
	end
end)

connect(center.Activated,function()
	if targetMode=="JUMP" then
		config.JumpX=defaultConfig.JumpX
		config.JumpY=defaultConfig.JumpY
		config.JumpSize=defaultConfig.JumpSize
		updateJump()
	elseif targetMode=="SHIFT" then
		config.ShiftX=defaultConfig.ShiftX
		config.ShiftY=defaultConfig.ShiftY
		config.ShiftSize=defaultConfig.ShiftSize
		updateShift()
	else
		config.AnalogX=defaultConfig.AnalogX
		config.AnalogY=defaultConfig.AnalogY
		config.AnalogSize=defaultConfig.AnalogSize
		updateAnalog()
	end
end)

connect(touchButton.Activated,function()
	if config.TouchSupport==2 then
		config.TouchSupport=3
	elseif config.TouchSupport==3 then
		config.TouchSupport=4
	else
		config.TouchSupport=2
	end

	touchButton.Text="TOUCH SUPPORT: "..config.TouchSupport.." JARI"
end)

local saveButton=makeButton(
	settings,
	"SaveConfig",
	UDim2.new(.05,0,1,-45),
	UDim2.fromOffset(130,38),
	"SAVE",
	Color3.fromRGB(50,180,100),
	43
)

local closeButton=makeButton(
	settings,
	"Close",
	UDim2.new(.95,-130,1,-45),
	UDim2.fromOffset(130,38),
	"CLOSE",
	Color3.fromRGB(210,70,80),
	43
)

connect(saveButton.Activated,function()
	saveConfig()
	loadConfig()
	applySensitivity()
	updateJump()
	updateShift()
	updateAnalog()

	saveButton.Text="SAVED!"

	task.delay(1,function()
		if saveButton and saveButton.Parent then
			saveButton.Text="SAVE"
		end
	end)
end)

connect(menu.Activated,function()
	settings.Visible=not settings.Visible

	if settings.Visible then
		refreshControls()
	end
end)

connect(closeButton.Activated,function()
	settings.Visible=false
end)

connect(UserInputService.TouchStarted,function(input)
	if destroyed then return end
end)

connect(UserInputService.TouchEnded,function(input)
	if destroyed then return end
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end

	refreshControls()
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		task.delay(.1,function()
			if not destroyed then
				refreshControls()
			end
		end)

		task.delay(.5,function()
			if not destroyed then
				refreshControls()
			end
		end)
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	if humanoid and humanoid.Parent then
		if _G.ShiftLocked then
			local camera=workspace.CurrentCamera
			local root=character and character:FindFirstChild("HumanoidRootPart")

			if camera and root then
				local look=Vector3.new(
					camera.CFrame.LookVector.X,
					0,
					camera.CFrame.LookVector.Z
				)

				if look.Magnitude>.001 then
					root.CFrame=CFrame.lookAt(
						root.Position,
						root.Position+look.Unit
					)
				end
			end

			humanoid.AutoRotate=false
		else
			humanoid.AutoRotate=true
		end

		humanoid.CameraOffset=Vector3.zero
	end
end)

applySensitivity()
updateTargetText()
updateShift()

task.defer(function()
	refreshControls()
end)
