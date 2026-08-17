local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CONFIG_FILE = "DeltaMobileConfig.json"

local defaultConfig = {
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1.0,
	AnalogX = 0.17,
	AnalogY = 0.78,
	AnalogSize = 150,
	TouchSupport = 4
}

-- costum id foto
local SHIFT_LOCK_IMAGE = "rbxassetid://6031068426" -- Ganti angka ini dengan ID gambar Shift Lock kamu
local OPEN_MENU_IMAGE = "rbxassetid://1234567890"  -- Ganti angka ini dengan ID gambar Open Menu kamu

local config = {}
for k, v in pairs(defaultConfig) do
	config[k] = v
end

local function saveConfig()
	if type(writefile) ~= "function" then return false end
	local ok, data = pcall(function()
		return HttpService:JSONEncode(config)
	end)
	if not ok or type(data) ~= "string" then return false end
	return pcall(function()
		writefile(CONFIG_FILE,data)
	end)
end

local function loadConfig()
	if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
	local ok, data = pcall(function()
		if not isfile(CONFIG_FILE) then return nil end
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if not ok or type(data) ~= "table" then return false end
	for k, defaultValue in pairs(defaultConfig) do
		if type(data[k]) == type(defaultValue) then
			config[k] = data[k]
		end
	end
	return true
end

loadConfig()

config.JumpX = math.clamp(tonumber(config.JumpX) or defaultConfig.JumpX,.05,.95)
config.JumpY = math.clamp(tonumber(config.JumpY) or defaultConfig.JumpY,.05,.95)
config.JumpSize = math.clamp(tonumber(config.JumpSize) or defaultConfig.JumpSize,.05,.50)
config.ShiftX = math.clamp(tonumber(config.ShiftX) or defaultConfig.ShiftX,.02,.98)
config.ShiftY = math.clamp(tonumber(config.ShiftY) or defaultConfig.ShiftY,.02,.98)
config.ShiftSize = math.clamp(tonumber(config.ShiftSize) or defaultConfig.ShiftSize,20,100)
config.Sensitivity = math.clamp(tonumber(config.Sensitivity) or defaultConfig.Sensitivity,.1,10)
config.AnalogX = math.clamp(tonumber(config.AnalogX) or defaultConfig.AnalogX,.10,.90)
config.AnalogY = math.clamp(tonumber(config.AnalogY) or defaultConfig.AnalogY,.10,.90)
config.AnalogSize = math.clamp(tonumber(config.AnalogSize) or defaultConfig.AnalogSize,90,220)
config.TouchSupport = math.clamp(math.floor(tonumber(config.TouchSupport) or defaultConfig.TouchSupport),2,4)

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections = {}
local destroyed = false

local function connect(signal, callback)
	local c
	pcall(function()
		c = signal:Connect(callback)
	end)
	if c then
		table.insert(connections, c)
	end
	return c
end

local function disconnectAll()
	for i = #connections, 1, -1 do
		pcall(function()
			connections[i]:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyGui(name)
	local gui = playerGui:FindFirstChild(name)
	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
end

_G.DeltaMobileControlsCleanup = function()
	if destroyed then return end
	destroyed = true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.ShiftLocked = false

local btnShiftLock

local SHIFT_OFF = Color3.fromRGB(255,255,255)
local SHIFT_ON = Color3.fromRGB(170,0,255)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaMobileControls"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = Color3.new(1,1,1)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = screenGui

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1,0)
cc.Parent = crosshair

local function toggleShiftLock()
	if destroyed then return end

	_G.ShiftLocked = not _G.ShiftLocked

	if btnShiftLock and btnShiftLock.Parent then
		btnShiftLock.BackgroundColor3 = _G.ShiftLocked and SHIFT_ON or SHIFT_OFF
	end

	crosshair.Visible = _G.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end
end

-- SHIFT LOCK BUTTON
btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(.5,.5)
btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image = SHIFT_LOCK_IMAGE
btnShiftLock.ImageColor3 = Color3.new(1,1,1)
btnShiftLock.BackgroundColor3 = SHIFT_OFF
btnShiftLock.BackgroundTransparency = .2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = false
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = screenGui

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(1,0)
sc.Parent = btnShiftLock

local ss = Instance.new("UIStroke")
ss.Thickness = 2
ss.Color = Color3.new(0,0,0)
ss.Transparency = .3
ss.Parent = btnShiftLock

connect(btnShiftLock.Activated, toggleShiftLock)

-- CLASSIC ROBLOX MOBILE ANALOG
local analogState = {
	touch = nil,
	x = 0,
	y = 0
}

local trackedTouches = {}
local edgeIgnore = 8
local analogKnob

local function resetAnalog()
	analogState.touch = nil
	analogState.x = 0
	analogState.y = 0
	if analogKnob and analogKnob.Parent then
		analogKnob.Position = UDim2.fromScale(.5,.5)
	end
end

local function trackedCount()
	local count = 0
	for input in pairs(trackedTouches) do
		if input.UserInputState ~= Enum.UserInputState.End then
			count += 1
		end
	end
	return count
end

local function edgeTouch(position)
	local camera = workspace.CurrentCamera
	if not camera then return false end
	local size = camera.ViewportSize
	return position.X <= edgeIgnore
		or position.Y <= edgeIgnore
		or position.X >= size.X-edgeIgnore
		or position.Y >= size.Y-edgeIgnore
end

local analogGui = Instance.new("Frame")
analogGui.Name = "ClassicAnalog"
analogGui.AnchorPoint = Vector2.new(.5,.5)
analogGui.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
analogGui.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
analogGui.BackgroundColor3 = Color3.fromRGB(245,245,245)
analogGui.BackgroundTransparency = .35
analogGui.BorderSizePixel = 0
analogGui.Active = true
analogGui.Selectable = false
analogGui.ZIndex = 20
analogGui.Parent = screenGui

local analogCorner = Instance.new("UICorner")
analogCorner.CornerRadius = UDim.new(1,0)
analogCorner.Parent = analogGui

local analogStroke = Instance.new("UIStroke")
analogStroke.Thickness = 2
analogStroke.Transparency = .35
analogStroke.Color = Color3.fromRGB(255,255,255)
analogStroke.Parent = analogGui

analogKnob = Instance.new("Frame")
analogKnob.Name = "Thumb"
analogKnob.AnchorPoint = Vector2.new(.5,.5)
analogKnob.Position = UDim2.fromScale(.5,.5)
analogKnob.Size = UDim2.fromScale(.42,.42)
analogKnob.BackgroundColor3 = Color3.fromRGB(95,95,105)
analogKnob.BackgroundTransparency = .12
analogKnob.BorderSizePixel = 0
analogKnob.Active = false
analogKnob.ZIndex = 21
analogKnob.Parent = analogGui

local analogKnobCorner = Instance.new("UICorner")
analogKnobCorner.CornerRadius = UDim.new(1,0)
analogKnobCorner.Parent = analogKnob

local function setAnalogPosition(position)
	if destroyed or not analogState.touch then return end

	local center = analogGui.AbsolutePosition + analogGui.AbsoluteSize*.5
	local radius = math.max(1,math.min(analogGui.AbsoluteSize.X,analogGui.AbsoluteSize.Y)*.5)
	local delta = Vector2.new(position.X-center.X,position.Y-center.Y)

	if delta.Magnitude > radius then
		delta = delta.Unit*radius
	end

	analogState.x = math.clamp(delta.X/radius,-1,1)
	analogState.y = math.clamp(delta.Y/radius,-1,1)

	analogKnob.Position = UDim2.new(.5,analogState.x*radius,.5,analogState.y*radius)
end

local function beginAnalog(input)
	if destroyed or analogState.touch then return end
	if input.UserInputType ~= Enum.UserInputType.Touch then return end
	if edgeTouch(input.Position) then return end
	if trackedCount() >= config.TouchSupport then return end

	trackedTouches[input] = true
	analogState.touch = input
	setAnalogPosition(input.Position)
end

local function finishTouch(input)
	trackedTouches[input] = nil
	if input == analogState.touch then
		resetAnalog()
	end
end

connect(analogGui.InputBegan,function(input)
	beginAnalog(input)
end)

connect(UserInputService.InputChanged,function(input)
	if input.UserInputType == Enum.UserInputType.Touch and input == analogState.touch then
		setAnalogPosition(input.Position)
	end
end)

connect(UserInputService.TouchMoved,function(input)
	if input == analogState.touch then
		setAnalogPosition(input.Position)
	end
end)

connect(UserInputService.InputEnded,function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		finishTouch(input)
	end
end)

connect(UserInputService.TouchEnded,function(input)
	finishTouch(input)
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	if analogState.touch and analogState.touch.UserInputState == Enum.UserInputState.End then
		finishTouch(analogState.touch)
	end

	for input in pairs(trackedTouches) do
		if input.UserInputState == Enum.UserInputState.End then
			trackedTouches[input] = nil
		end
	end
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)

local function updateCameraVectors()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local forward = Vector3.new(look.X,0,look.Z)
	local side = Vector3.new(right.X,0,right.Z)

	if forward.Magnitude > .001 then cachedForward = forward.Unit end
	if side.Magnitude > .001 then cachedSide = side.Unit end
end

local function getMoveVector()
	local x = analogState.x
	local z = -analogState.y

	if math.abs(x) < .06 then x = 0 end
	if math.abs(z) < .06 then z = 0 end

	local magnitude = math.sqrt(x*x+z*z)
	if magnitude <= .001 then return Vector3.zero end
	if magnitude > 1 then
		x /= magnitude
		z /= magnitude
		magnitude = 1
	end

	local movement = cachedSide*x + cachedForward*z
	if movement.Magnitude <= .001 then return Vector3.zero end
	return movement.Unit*magnitude
end

local function clearMovement()
	resetAnalog()
	for input in pairs(trackedTouches) do
		trackedTouches[input] = nil
	end
end

connect(RunService.RenderStepped,function()
	if destroyed then return end
	if not character or not character.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end

	updateCameraVectors()
	humanoid:Move(getMoveVector(),false)

	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local root = character:FindFirstChild("HumanoidRootPart")
		if camera and root then
			local look = camera.CFrame.LookVector
			local flat = Vector3.new(look.X,0,look.Z)
			if flat.Magnitude > .001 then
				root.CFrame = CFrame.lookAt(root.Position,root.Position+flat.Unit,Vector3.yAxis)
			end
		end
		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = true
	end

	humanoid.CameraOffset = Vector3.zero
end)

-- SETTINGS
local step = .018
local targetSettingMode = "JUMP"

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaMobileErgo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = playerGui

local function makeButton(parent,name,pos,size,text,bg,z)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = bg or Color3.fromRGB(245,245,245)
	b.BackgroundTransparency = .04
	b.TextColor3 = Color3.fromRGB(20,20,25)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 41
	b.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,12)
	c.Parent = b

	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Transparency = .35
	s.Color = Color3.fromRGB(255,255,255)
	s.Parent = b

	return b
end

local menu = Instance.new("ImageButton")
menu.Name = "OpenMenu"
menu.AnchorPoint = Vector2.new(1,1)
menu.Position = UDim2.new(1,-14,1,-14)
menu.Size = UDim2.fromOffset(60,60)
menu.Image = OPEN_MENU_IMAGE
menu.BackgroundColor3 = Color3.fromRGB(245,245,245)
menu.BackgroundTransparency = .04
menu.AutoButtonColor = false
menu.Active = true
menu.Selectable = false
menu.ZIndex = 100
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1,0)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Thickness = 2
menuStroke.Transparency = .15
menuStroke.Color = Color3.fromRGB(255,255,255)
menuStroke.Parent = menu

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(320,620)
settings.AnchorPoint = Vector2.new(.5,.5)
settings.Position = UDim2.new(.5,0,.5,0)
settings.BackgroundColor3 = Color3.fromRGB(25,25,32)
settings.BackgroundTransparency = .03
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0,20)
settingsCorner.Parent = settings

local settingsStroke = Instance.new("UIStroke")
settingsStroke.Thickness = 1.5
settingsStroke.Transparency = .1
settingsStroke.Color = Color3.fromRGB(170,0,255)
settingsStroke.Parent = settings

local settingsGradient = Instance.new("UIGradient")
settingsGradient.Rotation = 35
settingsGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(40,30,55)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(22,27,42)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(34,25,48))
})
settingsGradient.Parent = settings

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-28,0,44)
title.Position = UDim2.fromOffset(14,10)
title.Text = "VORAZURE • MOBILE CONTROL"
title.TextColor3 = Color3.fromRGB(245,240,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.ZIndex = 42
title.Parent = settings

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,-28,0,24)
subtitle.Position = UDim2.fromOffset(14,48)
subtitle.Text = "Independent control layout • saved locally"
subtitle.TextColor3 = Color3.fromRGB(170,165,180)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.BackgroundTransparency = 1
subtitle.ZIndex = 42
subtitle.Parent = settings

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1,-24,0,125)
cameraSection.Position = UDim2.fromOffset(12,78)
cameraSection.BackgroundColor3 = Color3.fromRGB(35,35,45)
cameraSection.BackgroundTransparency = .12
cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0,14)
cameraCorner.Parent = cameraSection

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1,-20,0,28)
cameraTitle.Position = UDim2.fromOffset(10,7)
cameraTitle.Text = "CAMERA SENSITIVITY"
cameraTitle.TextColor3 = Color3.fromRGB(245,240,255)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 13
cameraTitle.TextXAlignment = Enum.TextXAlignment.Left
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1,0,0,22)
sensLabel.Position = UDim2.fromOffset(0,34)
sensLabel.TextColor3 = Color3.fromRGB(175,170,185)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 12
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text = "Multiplier: "..string.format("%.1f",config.Sensitivity).."x"
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

local sensMinus = makeButton(cameraSection,"Minus",UDim2.new(.06,0,0,72),UDim2.fromOffset(70,36),"-",Color3.fromRGB(55,55,68),43)
local sensReset = makeButton(cameraSection,"Reset",UDim2.new(.5,-42,0,72),UDim2.fromOffset(84,36),"RESET",Color3.fromRGB(55,55,68),43)
local sensPlus = makeButton(cameraSection,"Plus",UDim2.new(.94,-70,0,72),UDim2.fromOffset(70,36),"+",Color3.fromRGB(55,55,68),43)

connect(sensMinus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity-.1,.1,10)
	applySensitivity()
end)

connect(sensPlus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity+.1,.1,10)
	applySensitivity()
end)

connect(sensReset.Activated,function()
	config.Sensitivity = 1
	applySensitivity()
end)

local controlSection = Instance.new("Frame")
controlSection.Size = UDim2.new(1,-24,0,280)
controlSection.Position = UDim2.fromOffset(12,211)
controlSection.BackgroundColor3 = Color3.fromRGB(35,35,45)
controlSection.BackgroundTransparency = .12
controlSection.BorderSizePixel = 0
controlSection.ZIndex = 41
controlSection.Parent = settings

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0,14)
controlCorner.Parent = controlSection

local modeSwitchBtn = makeButton(controlSection,"Target",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,36),"TARGET: JUMP BUTTON",Color3.fromRGB(70,120,230),43)
modeSwitchBtn.TextColor3 = Color3.new(1,1,1)

local targetHint = Instance.new("TextLabel")
targetHint.Size = UDim2.new(1,-24,0,22)
targetHint.Position = UDim2.fromOffset(12,50)
targetHint.Text = "POSITION / SIZE ONLY AFFECTS SELECTED CONTROL"
targetHint.TextColor3 = Color3.fromRGB(155,150,165)
targetHint.Font = Enum.Font.Gotham
targetHint.TextSize = 10
targetHint.BackgroundTransparency = 1
targetHint.ZIndex = 42
targetHint.Parent = controlSection

local moveUp = makeButton(controlSection,"MoveUp",UDim2.new(.5,-32,0,75),UDim2.fromOffset(64,38),"↑",Color3.fromRGB(50,50,64),43)
local moveLeft = makeButton(controlSection,"MoveLeft",UDim2.new(.08,0,0,117),UDim2.fromOffset(64,38),"←",Color3.fromRGB(50,50,64),43)
local moveRight = makeButton(controlSection,"MoveRight",UDim2.new(.92,-64,0,117),UDim2.fromOffset(64,38),"→",Color3.fromRGB(50,50,64),43)
local moveDown = makeButton(controlSection,"MoveDown",UDim2.new(.5,-32,0,159),UDim2.fromOffset(64,38),"↓",Color3.fromRGB(50,50,64),43)

local sizePlus = makeButton(controlSection,"SizePlus",UDim2.new(.06,0,0,211),UDim2.fromOffset(82,34),"SIZE +",Color3.fromRGB(50,50,64),43)
local center = makeButton(controlSection,"Center",UDim2.new(.5,-41,0,211),UDim2.fromOffset(82,34),"RESET",Color3.fromRGB(50,50,64),43)
local sizeMinus = makeButton(controlSection,"SizeMinus",UDim2.new(.94,-82,0,211),UDim2.fromOffset(82,34),"SIZE -",Color3.fromRGB(50,50,64),43)

local touchSection = Instance.new("Frame")
touchSection.Size = UDim2.new(1,-24,0,72)
touchSection.Position = UDim2.fromOffset(12,499)
touchSection.BackgroundColor3 = Color3.fromRGB(35,35,45)
touchSection.BackgroundTransparency = .12
touchSection.BorderSizePixel = 0
touchSection.ZIndex = 41
touchSection.Parent = settings

local touchCorner = Instance.new("UICorner")
touchCorner.CornerRadius = UDim.new(0,14)
touchCorner.Parent = touchSection

local touchLabel = Instance.new("TextLabel")
touchLabel.Size = UDim2.new(1,-120,1,0)
touchLabel.Position = UDim2.fromOffset(12,0)
touchLabel.TextColor3 = Color3.fromRGB(230,225,240)
touchLabel.Font = Enum.Font.GothamBold
touchLabel.TextSize = 12
touchLabel.TextXAlignment = Enum.TextXAlignment.Left
touchLabel.BackgroundTransparency = 1
touchLabel.ZIndex = 42
touchLabel.Parent = touchSection

local touchButton = makeButton(touchSection,"TouchSupport",UDim2.new(1,-105,.5,-19),UDim2.fromOffset(92,38),"4 FINGER",Color3.fromRGB(70,120,230),43)
touchButton.TextColor3 = Color3.new(1,1,1)

local function updateTouchLabel()
	touchLabel.Text = "TOUCH SUPPORT\n2 / 3 / 4 fingers"
	touchButton.Text = tostring(config.TouchSupport).." FINGER"
end

local function setTargetMode(mode)
	targetSettingMode = mode
	if mode == "JUMP" then
		modeSwitchBtn.Text = "TARGET: JUMP BUTTON"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(70,120,230)
	elseif mode == "SHIFT" then
		modeSwitchBtn.Text = "TARGET: SHIFT LOCK"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(150,70,220)
	else
		modeSwitchBtn.Text = "TARGET: ANALOG"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(60,165,125)
	end
end

connect(modeSwitchBtn.Activated,function()
	if targetSettingMode == "JUMP" then
		setTargetMode("SHIFT")
	elseif targetSettingMode == "SHIFT" then
		setTargetMode("ANALOG")
	else
		setTargetMode("JUMP")
	end
end)

connect(touchButton.Activated,function()
	config.TouchSupport += 1
	if config.TouchSupport > 4 then config.TouchSupport = 2 end
	updateTouchLabel()
end)

local jumpButton

local function getJump()
	if jumpButton and jumpButton.Parent and jumpButton:IsDescendantOf(playerGui) then
		return jumpButton
	end
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then
		jumpButton = touchGui:FindFirstChild("JumpButton",true)
	end
	return jumpButton
end

local function updateJump()
	if destroyed then return end
	local jump = getJump()
	local camera = workspace.CurrentCamera
	if not jump or not camera then return end
	local viewport = camera.ViewportSize
	if viewport.X <= 0 or viewport.Y <= 0 then return end

	config.JumpX = math.clamp(config.JumpX,.05,.95)
	config.JumpY = math.clamp(config.JumpY,.05,.95)
	config.JumpSize = math.clamp(config.JumpSize,.05,.50)

	local size = math.max(40,math.floor(viewport.Y*config.JumpSize))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5,.5)
		jump.Position = UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size = UDim2.fromOffset(size,size)
	end)
end

local function updateShift()
	config.ShiftX = math.clamp(config.ShiftX,.02,.98)
	config.ShiftY = math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize = math.clamp(config.ShiftSize,20,100)
	btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function updateAnalog()
	config.AnalogX = math.clamp(config.AnalogX,.10,.90)
	config.AnalogY = math.clamp(config.AnalogY,.10,.90)
	config.AnalogSize = math.clamp(config.AnalogSize,90,220)
	analogGui.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
	analogGui.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
	resetAnalog()
end

local function applyMoveStep(dx,dy)
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	elseif targetSettingMode == "SHIFT" then
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	else
		config.AnalogX = math.clamp(config.AnalogX+dx,.10,.90)
		config.AnalogY = math.clamp(config.AnalogY+dy,.10,.90)
		updateAnalog()
	end
end

local holding = {[moveUp]=false,[moveDown]=false,[moveLeft]=false,[moveRight]=false}

local function bindHold(button,dx,dy)
	connect(button.InputBegan,function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		holding[button] = true
		applyMoveStep(dx,dy)
	end)
	connect(button.InputEnded,function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
			holding[button] = false
		end
	end)
end

bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)

connect(UserInputService.InputEnded,function(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
		for button in pairs(holding) do holding[button] = false end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end
	if holding[moveUp] then applyMoveStep(0,-step) end
	if holding[moveDown] then applyMoveStep(0,step) end
	if holding[moveLeft] then applyMoveStep(-step,0) end
	if holding[moveRight] then applyMoveStep(step,0) end
end)

connect(sizePlus.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	elseif targetSettingMode == "SHIFT" then
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	else
		config.AnalogSize = math.clamp(config.AnalogSize+10,90,220)
		updateAnalog()
	end
end)

connect(sizeMinus.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	elseif targetSettingMode == "SHIFT" then
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	else
		config.AnalogSize = math.clamp(config.AnalogSize-10,90,220)
		updateAnalog()
	end
end)

connect(center.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
		config.JumpSize = defaultConfig.JumpSize
		updateJump()
	elseif targetSettingMode == "SHIFT" then
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
		config.ShiftSize = defaultConfig.ShiftSize
		updateShift()
	else
		config.AnalogX = defaultConfig.AnalogX
		config.AnalogY = defaultConfig.AnalogY
		config.AnalogSize = defaultConfig.AnalogSize
		updateAnalog()
	end
end)

local saveButton = makeButton(settings,"SaveConfig",UDim2.new(.05,0,1,-48),UDim2.fromOffset(125,38),"SAVE",Color3.fromRGB(60,165,125),43)
saveButton.TextColor3 = Color3.new(1,1,1)

local closeButton = makeButton(settings,"Close",UDim2.new(.95,-125,1,-48),UDim2.fromOffset(125,38),"CLOSE",Color3.fromRGB(180,70,80),43)
closeButton.TextColor3 = Color3.new(1,1,1)

connect(saveButton.Activated,function()
	local ok = saveConfig()
	if ok then
		loadConfig()
		config.JumpX = math.clamp(tonumber(config.JumpX) or defaultConfig.JumpX,.05,.95)
		config.JumpY = math.clamp(tonumber(config.JumpY) or defaultConfig.JumpY,.05,.95)
		config.JumpSize = math.clamp(tonumber(config.JumpSize) or defaultConfig.JumpSize,.05,.50)
		config.ShiftX = math.clamp(tonumber(config.ShiftX) or defaultConfig.ShiftX,.02,.98)
		config.ShiftY = math.clamp(tonumber(config.ShiftY) or defaultConfig.ShiftY,.02,.98)
		config.ShiftSize = math.clamp(tonumber(config.ShiftSize) or defaultConfig.ShiftSize,20,100)
		config.Sensitivity = math.clamp(tonumber(config.Sensitivity) or defaultConfig.Sensitivity,.1,10)
		config.AnalogX = math.clamp(tonumber(config.AnalogX) or defaultConfig.AnalogX,.10,.90)
		config.AnalogY = math.clamp(tonumber(config.AnalogY) or defaultConfig.AnalogY,.10,.90)
		config.AnalogSize = math.clamp(tonumber(config.AnalogSize) or defaultConfig.AnalogSize,90,220)
		config.TouchSupport = math.clamp(math.floor(tonumber(config.TouchSupport) or defaultConfig.TouchSupport),2,4)

		updateJump()
		updateShift()
		updateAnalog()
		applySensitivity()
		updateTouchLabel()
		saveButton.Text = "SAVED + LOADED"
	else
		saveButton.Text = "SAVE ERROR"
	end
	task.delay(1.2,function()
		if saveButton and saveButton.Parent then saveButton.Text = "SAVE" end
	end)
end)

connect(menu.Activated,function()
	settings.Visible = not settings.Visible
end)

connect(closeButton.Activated,function()
	settings.Visible = false
end)

local function refresh()
	task.defer(function()
		if not destroyed then
			updateJump()
			updateShift()
			updateAnalog()
		end
	end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	clearMovement()

	if humanoid then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end

	refresh()
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		jumpButton = nil
		task.defer(function()
			if not destroyed then updateJump() end
		end)
	end
end)

applySensitivity()
updateCameraVectors()
updateJump()
updateShift()
updateAnalog()
updateTouchLabel()
