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
	AnalogX = 0.16,
	AnalogY = 0.76,
	AnalogSize = 120,
	Sensitivity = 1.0,
	TouchSupport = 3
}

local SHIFT_LOCK_IMAGE = "rbxassetid://6031068426"
local OPEN_MENU_IMAGE = "rbxassetid://1234567890"

local config = {}
for k, v in pairs(defaultConfig) do
	config[k] = v
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode(config))
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(data) == "table" then
				for k, v in pairs(data) do
					if defaultConfig[k] ~= nil and type(v) == type(defaultConfig[k]) then
						config[k] = v
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

local MAIN_COLOR = Color3.fromRGB(255,255,255)
local PRESSED_COLOR = Color3.fromRGB(70,150,255)
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

local btnShiftLock

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

local analogFrame = Instance.new("Frame")
analogFrame.Name = "ClassicAnalog"
analogFrame.AnchorPoint = Vector2.new(.5,.5)
analogFrame.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
analogFrame.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
analogFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
analogFrame.BackgroundTransparency = .42
analogFrame.BorderSizePixel = 0
analogFrame.Active = true
analogFrame.ZIndex = 20
analogFrame.Parent = screenGui

local analogCorner = Instance.new("UICorner")
analogCorner.CornerRadius = UDim.new(1,0)
analogCorner.Parent = analogFrame

local analogStroke = Instance.new("UIStroke")
analogStroke.Thickness = 2
analogStroke.Color = Color3.new(1,1,1)
analogStroke.Transparency = .45
analogStroke.Parent = analogFrame

local analogKnob = Instance.new("Frame")
analogKnob.Name = "Knob"
analogKnob.AnchorPoint = Vector2.new(.5,.5)
analogKnob.Position = UDim2.fromScale(.5,.5)
analogKnob.Size = UDim2.fromScale(.42,.42)
analogKnob.BackgroundColor3 = Color3.fromRGB(235,235,235)
analogKnob.BackgroundTransparency = .08
analogKnob.BorderSizePixel = 0
analogKnob.Active = false
analogKnob.ZIndex = 21
analogKnob.Parent = analogFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1,0)
knobCorner.Parent = analogKnob

local knobStroke = Instance.new("UIStroke")
knobStroke.Thickness = 2
knobStroke.Color = Color3.new(1,1,1)
knobStroke.Transparency = .35
knobStroke.Parent = analogKnob

local analogTouch = nil
local analogVector = Vector2.zero
local analogCenter = Vector2.zero
local analogRadius = 1

local function updateAnalogGeometry()
	analogCenter = analogFrame.AbsolutePosition + analogFrame.AbsoluteSize / 2
	analogRadius = math.max(1,math.min(analogFrame.AbsoluteSize.X,analogFrame.AbsoluteSize.Y) / 2)
end

local function resetAnalog()
	analogTouch = nil
	analogVector = Vector2.zero
	analogKnob.Position = UDim2.fromScale(.5,.5)
end

local function updateAnalog(position)
	local delta = position - analogCenter
	local radius = analogRadius * .68

	if radius <= 0 then
		resetAnalog()
		return
	end

	if delta.Magnitude > radius then
		delta = delta.Unit * radius
	end

	analogVector = delta / radius

	if analogVector.Magnitude < .08 then
		analogVector = Vector2.zero
	end

	local visual = analogVector * .34

	analogKnob.Position = UDim2.new(
		.5 + visual.X,
		0,
		.5 + visual.Y,
		0
	)
end

local function isEdgeTouch(position)
	local camera = workspace.CurrentCamera
	if not camera then return false end

	local viewport = camera.ViewportSize
	local edgeX = math.max(28,viewport.X * .025)
	local edgeY = math.max(28,viewport.Y * .025)

	return position.X <= edgeX
		or position.X >= viewport.X - edgeX
		or position.Y <= edgeY
		or position.Y >= viewport.Y - edgeY
end

local function getTouchCount()
	local count = 0

	for _, input in ipairs(UserInputService:GetTouches()) do
		if input.UserInputState ~= Enum.UserInputState.End then
			count += 1
		end
	end

	return count
end

connect(analogFrame.InputBegan,function(input)
	if destroyed then return end

	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if analogTouch then
		return
	end

	if isEdgeTouch(input.Position) then
		return
	end

	if getTouchCount() > math.clamp(config.TouchSupport,2,4) then
		return
	end

	updateAnalogGeometry()

	analogTouch = input
	updateAnalog(input.Position)
end)

connect(UserInputService.InputChanged,function(input)
	if destroyed then return end

	if input ~= analogTouch then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	updateAnalog(input.Position)
end)

connect(UserInputService.InputEnded,function(input)
	if input == analogTouch then
		resetAnalog()
	end
end)

connect(UserInputService.TouchEnded,function(input)
	if input == analogTouch then
		resetAnalog()
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

	if forward.Magnitude > .001 then
		cachedForward = forward.Unit
	end

	if side.Magnitude > .001 then
		cachedSide = side.Unit
	end
end

local function getMoveVector()
	local x = analogVector.X
	local z = -analogVector.Y

	if math.abs(x) < .03 then
		x = 0
	end

	if math.abs(z) < .03 then
		z = 0
	end

	if x == 0 and z == 0 then
		return Vector3.zero
	end

	local movement = cachedSide * x + cachedForward * z

	if movement.Magnitude < .001 then
		return Vector3.zero
	end

	return movement.Unit * math.clamp(math.sqrt(x*x + z*z),0,1)
end

connect(RunService.RenderStepped,function()
	if destroyed then return end

	if not character or not character.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end

	updateCameraVectors()

	local movement = getMoveVector()

	humanoid:Move(movement,false)

	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local root = character:FindFirstChild("HumanoidRootPart")

		if camera and root then
			local look = Vector3.new(
				camera.CFrame.LookVector.X,
				0,
				camera.CFrame.LookVector.Z
			)

			if look.Magnitude > .001 then
				root.CFrame = CFrame.lookAt(
					root.Position,
					root.Position + look.Unit
				)
			end
		end

		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = true
	end

	humanoid.CameraOffset = Vector3.zero
end)

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
	b.BackgroundTransparency = .05
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 22
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 41
	b.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,12)
	c.Parent = b

	return b
end

local menu = Instance.new("ImageButton")
menu.Name = "OpenMenu"
menu.Position = UDim2.new(1,-72,1,-72)
menu.Size = UDim2.fromOffset(60,60)
menu.Image = OPEN_MENU_IMAGE
menu.BackgroundColor3 = Color3.fromRGB(245,245,245)
menu.BackgroundTransparency = .05
menu.AutoButtonColor = false
menu.ZIndex = 100
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1,0)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Thickness = 2
menuStroke.Color = Color3.fromRGB(170,0,255)
menuStroke.Transparency = .2
menuStroke.Parent = menu

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(320,590)
settings.Position = UDim2.new(.5,-160,.5,-295)
settings.BackgroundColor3 = Color3.fromRGB(20,20,30)
settings.BackgroundTransparency = .03
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0,18)
settingsCorner.Parent = settings

local settingsStroke = Instance.new("UIStroke")
settingsStroke.Thickness = 2
settingsStroke.Color = Color3.fromRGB(170,0,255)
settingsStroke.Transparency = .15
settingsStroke.Parent = settings

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,42)
title.Position = UDim2.fromOffset(10,8)
title.Text = "DELTA MOBILE CONTROLS"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.ZIndex = 41
title.Parent = settings

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1,-20,0,115)
cameraSection.Position = UDim2.fromOffset(10,55)
cameraSection.BackgroundColor3 = Color3.fromRGB(30,30,42)
cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0,12)
cameraCorner.Parent = cameraSection

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1,0,0,30)
cameraTitle.Text = "CAMERA SENSI SETTING"
cameraTitle.TextColor3 = Color3.new(1,1,1)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 15
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1,0,0,25)
sensLabel.Position = UDim2.fromOffset(0,28)
sensLabel.TextColor3 = Color3.fromRGB(190,190,205)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 13
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text = "Multiplier: "..string.format("%.1f",config.Sensitivity).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

local sensMinus = makeButton(
	cameraSection,
	"Minus",
	UDim2.new(.06,0,0,65),
	UDim2.fromOffset(76,38),
	"-",
	nil,
	43
)

local sensReset = makeButton(
	cameraSection,
	"Reset",
	UDim2.new(.5,-42,0,65),
	UDim2.fromOffset(84,38),
	"RESET",
	nil,
	43
)

local sensPlus = makeButton(
	cameraSection,
	"Plus",
	UDim2.new(.94,-76,0,65),
	UDim2.fromOffset(76,38),
	"+",
	nil,
	43
)

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

applySensitivity()

local controlSection = Instance.new("Frame")
controlSection.Size = UDim2.new(1,-20,0,330)
controlSection.Position = UDim2.fromOffset(10,180)
controlSection.BackgroundColor3 = Color3.fromRGB(30,30,42)
controlSection.BorderSizePixel = 0
controlSection.ZIndex = 41
controlSection.Parent = settings

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0,12)
controlCorner.Parent = controlSection

local modeSwitchBtn = makeButton(
	controlSection,
	"ToggleTargetMode",
	UDim2.new(.05,0,0,10),
	UDim2.new(.9,0,0,36),
	"TARGET: JUMP BUTTON",
	Color3.fromRGB(70,150,255),
	43
)

modeSwitchBtn.TextColor3 = Color3.new(1,1,1)

connect(modeSwitchBtn.Activated,function()
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

local moveUp = makeButton(
	controlSection,
	"MoveUp",
	UDim2.new(.5,-34,0,55),
	UDim2.fromOffset(68,42),
	"↑",
	nil,
	43
)

local moveLeft = makeButton(
	controlSection,
	"MoveLeft",
	UDim2.new(.10,0,0,98),
	UDim2.fromOffset(68,42),
	"←",
	nil,
	43
)

local moveRight = makeButton(
	controlSection,
	"MoveRight",
	UDim2.new(.90,-68,0,98),
	UDim2.fromOffset(68,42),
	"→",
	nil,
	43
)

local moveDown = makeButton(
	controlSection,
	"MoveDown",
	UDim2.new(.5,-34,0,141),
	UDim2.fromOffset(68,42),
	"↓",
	nil,
	43
)

local sizePlus = makeButton(
	controlSection,
	"SizePlus",
	UDim2.new(.06,0,0,195),
	UDim2.fromOffset(88,34),
	"SIZE +",
	nil,
	43
)

local sizeMinus = makeButton(
	controlSection,
	"SizeMinus",
	UDim2.new(.94,-88,0,195),
	UDim2.fromOffset(88,34),
	"SIZE -",
	nil,
	43
)

local center = makeButton(
	controlSection,
	"Center",
	UDim2.new(.5,-44,0,195),
	UDim2.fromOffset(88,34),
	"RESET",
	nil,
	43
)

local analogMode = false

local analogTargetButton = makeButton(
	controlSection,
	"AnalogTarget",
	UDim2.new(.05,0,0,242),
	UDim2.new(.9,0,0,34),
	"ANALOG SETTING",
	Color3.fromRGB(70,150,255),
	43
)

analogTargetButton.TextColor3 = Color3.new(1,1,1)

local touchButton = makeButton(
	controlSection,
	"TouchSupport",
	UDim2.new(.05,0,0,280),
	UDim2.new(.42,0,0,34),
	"TOUCH: "..tostring(config.TouchSupport),
	Color3.fromRGB(70,150,255),
	43
)

touchButton.TextColor3 = Color3.new(1,1,1)

local analogSizeButton = makeButton(
	controlSection,
	"AnalogSize",
	UDim2.new(.53,0,0,280),
	UDim2.new(.42,0,0,34),
	"ANALOG SIZE",
	Color3.fromRGB(170,0,255),
	43
)

analogSizeButton.TextColor3 = Color3.new(1,1,1)

connect(analogTargetButton.Activated,function()
	analogMode = not analogMode

	if analogMode then
		analogTargetButton.Text = "ANALOG: POSITION"
		analogTargetButton.BackgroundColor3 = Color3.fromRGB(170,0,255)
	else
		analogTargetButton.Text = "ANALOG SETTING"
		analogTargetButton.BackgroundColor3 = Color3.fromRGB(70,150,255)
	end
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

	local size = math.max(40,math.floor(viewport.Y * config.JumpSize))

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
	config.AnalogX = math.clamp(config.AnalogX,.05,.50)
	config.AnalogY = math.clamp(config.AnalogY,.45,.95)
	config.AnalogSize = math.clamp(config.AnalogSize,80,220)

	analogFrame.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
	analogFrame.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)

	updateAnalogGeometry()
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
	end
end

connect(moveUp.Activated,function()
	if analogMode then
		config.AnalogY = math.clamp(config.AnalogY-step,.45,.95)
		updateAnalog()
	else
		applyMoveStep(0,-step)
	end
end)

connect(moveDown.Activated,function()
	if analogMode then
		config.AnalogY = math.clamp(config.AnalogY+step,.45,.95)
		updateAnalog()
	else
		applyMoveStep(0,step)
	end
end)

connect(moveLeft.Activated,function()
	if analogMode then
		config.AnalogX = math.clamp(config.AnalogX-step,.05,.50)
		updateAnalog()
	else
		applyMoveStep(-step,0)
	end
end)

connect(moveRight.Activated,function()
	if analogMode then
		config.AnalogX = math.clamp(config.AnalogX+step,.05,.50)
		updateAnalog()
	else
		applyMoveStep(step,0)
	end
end)

connect(sizePlus.Activated,function()
	if analogMode then
		config.AnalogSize = math.clamp(config.AnalogSize+10,80,220)
		updateAnalog()
	elseif targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if analogMode then
		config.AnalogSize = math.clamp(config.AnalogSize-10,80,220)
		updateAnalog()
	elseif targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(center.Activated,function()
	if analogMode then
		config.AnalogX = defaultConfig.AnalogX
		config.AnalogY = defaultConfig.AnalogY
		config.AnalogSize = defaultConfig.AnalogSize
		updateAnalog()
	elseif targetSettingMode == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
		updateJump()
	else
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
		updateShift()
	end
end)

connect(touchButton.Activated,function()
	config.TouchSupport += 1

	if config.TouchSupport > 4 then
		config.TouchSupport = 2
	end

	touchButton.Text = "TOUCH: "..tostring(config.TouchSupport)
	resetAnalog()
end)

connect(analogSizeButton.Activated,function()
	config.AnalogSize += 10

	if config.AnalogSize > 220 then
		config.AnalogSize = 80
	end

	updateAnalog()
end)

local saveButton = makeButton(
	settings,
	"SaveConfig",
	UDim2.new(.05,0,1,-45),
	UDim2.fromOffset(130,38),
	"SAVE",
	Color3.fromRGB(70,200,100),
	43
)

saveButton.TextColor3 = Color3.new(1,1,1)

local closeButton = makeButton(
	settings,
	"Close",
	UDim2.new(.95,-130,1,-45),
	UDim2.fromOffset(130,38),
	"CLOSE",
	Color3.fromRGB(230,90,90),
	43
)

closeButton.TextColor3 = Color3.new(1,1,1)

connect(saveButton.Activated,function()
	saveConfig()
	loadConfig()
	applySensitivity()
	updateJump()
	updateShift()
	updateAnalog()

	local old = saveButton.Text
	saveButton.Text = "SAVED!"

	task.delay(1,function()
		if saveButton and saveButton.Parent then
			saveButton.Text = old
		end
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
		updateJump()
		updateShift()
		updateAnalog()
	end)

	task.delay(.2,function()
		if not destroyed then
			updateJump()
			updateShift()
			updateAnalog()
		end
	end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	resetAnalog()

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end

	refresh()
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		jumpButton = nil
		refresh()
	end
end)

updateCameraVectors()
updateJump()
updateShift()
updateAnalog()
