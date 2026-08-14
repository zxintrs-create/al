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
	Sensitivity = 1.0
}

-- image id
local SHIFT_LOCK_IMAGE = "rbxassetid://112921115907036"
local OPEN_MENU_IMAGE = "rbxassetid://117917793889046"

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
local WLOCK_OFF = Color3.fromRGB(220,70,70)
local WLOCK_ON = Color3.fromRGB(70,200,100)
local SHIFT_OFF = Color3.fromRGB(255,255,255)
local SHIFT_ON = Color3.fromRGB(170,0,255)

local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}

local buttonDefaults = {}
local activeInputs = {}

local function visual(button, pressed)
	if not button or not button.Parent then return end
	if pressed then
		button.BackgroundColor3 = PRESSED_COLOR
	else
		button.BackgroundColor3 = buttonDefaults[button] or MAIN_COLOR
	end
end

local btnWLock
local btnShiftLock

local function updateWLock()
	if btnWLock and btnWLock.Parent then
		btnWLock.BackgroundColor3 = moveState.WLock and WLOCK_ON or WLOCK_OFF
	end
end

local function clearMovement()
	moveState.Forward = false
	moveState.Backward = false
	moveState.Left = false
	moveState.Right = false

	for input in pairs(activeInputs) do
		activeInputs[input] = nil
	end

	for button, color in pairs(buttonDefaults) do
		if button and button.Parent then
			button.BackgroundColor3 = color
		end
	end

	updateWLock()
end

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

-- MOVEMENT FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "ControlsFrame"
mainFrame.Size = UDim2.fromOffset(300,300)
mainFrame.Position = UDim2.new(0,18,1,-330)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local function createMoveButton(name,pos,size,text)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = MAIN_COLOR
	b.BackgroundTransparency = .15
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 28
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = 20
	b.Parent = mainFrame

	buttonDefaults[b] = b.BackgroundColor3

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,14)
	corner.Parent = b

	return b
end

local btnUp = createMoveButton("Up",UDim2.new(.33,0,0,0),UDim2.new(.34,0,.34,0),"▲")
local btnDown = createMoveButton("Down",UDim2.new(.33,0,.66,0),UDim2.new(.34,0,.34,0),"▼")
local btnLeft = createMoveButton("Left",UDim2.new(0,0,.33,0),UDim2.new(.34,0,.34,0),"◀")
local btnRight = createMoveButton("Right",UDim2.new(.66,0,.33,0),UDim2.new(.34,0,.34,0),"▶")

-- W LOCK IS NOW OUTSIDE THE WASD CROSS.
-- It no longer occupies the center of the movement pad.
btnWLock = Instance.new("TextButton")
btnWLock.Name = "WLock"
btnWLock.AnchorPoint = Vector2.new(.5,.5)
btnWLock.Position = UDim2.new(1,42,.5,0)
btnWLock.Size = UDim2.fromOffset(62,62)
btnWLock.Text = "W"
btnWLock.BackgroundColor3 = WLOCK_OFF
btnWLock.BackgroundTransparency = .10
btnWLock.TextColor3 = Color3.new(1,1,1)
btnWLock.Font = Enum.Font.GothamBold
btnWLock.TextSize = 25
btnWLock.AutoButtonColor = false
btnWLock.Active = true
btnWLock.Selectable = false
btnWLock.BorderSizePixel = 0
btnWLock.ZIndex = 30
btnWLock.Parent = mainFrame

local wc = Instance.new("UICorner")
wc.CornerRadius = UDim.new(1,0)
wc.Parent = btnWLock

connect(btnWLock.Activated,function()
	if destroyed then return end
	moveState.WLock = not moveState.WLock
	updateWLock()
end)

-- MODE BUTTON
local isDelayMode = false

local modeButton = Instance.new("TextButton")
modeButton.Name = "ToggleDelay"
modeButton.Position = UDim2.new(0,0,-.20,0)
modeButton.Size = UDim2.new(1,0,.15,0)
modeButton.Text = "MODE: KELINCAHAN"
modeButton.BackgroundColor3 = Color3.fromRGB(70,200,100)
modeButton.BackgroundTransparency = .15
modeButton.TextColor3 = Color3.new(1,1,1)
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 16
modeButton.AutoButtonColor = false
modeButton.Active = true
modeButton.Selectable = false
modeButton.BorderSizePixel = 0
modeButton.ZIndex = 30
modeButton.Parent = mainFrame

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0,8)
mc.Parent = modeButton

connect(modeButton.Activated,function()
	isDelayMode = not isDelayMode

	if isDelayMode then
		modeButton.Text = "MODE: DELAY (JEJAK)"
		modeButton.BackgroundColor3 = Color3.fromRGB(220,120,40)
	else
		modeButton.Text = "MODE: KELINCAHAN"
		modeButton.BackgroundColor3 = Color3.fromRGB(70,200,100)
	end
end)

-- Each movement button owns its own touch.
-- There is deliberately NO transparent TouchZone over the whole WASD pad.
local function setDirection(direction,state)
	moveState[direction] = state

	if direction == "Forward" then visual(btnUp,state)
	elseif direction == "Backward" then visual(btnDown,state)
	elseif direction == "Left" then visual(btnLeft,state)
	elseif direction == "Right" then visual(btnRight,state)
	end
end

local function releaseInput(input)
	local data = activeInputs[input]
	if not data then return end

	activeInputs[input] = nil
	setDirection(data.direction,false)
end

local function bindDirection(button,direction)
	connect(button.InputBegan,function(input)
		if destroyed then return end

		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then
			return
		end

		-- One physical touch belongs to one button only.
		if activeInputs[input] then return end

		activeInputs[input] = {
			direction = direction,
			button = button
		}

		setDirection(direction,true)
	end)

	connect(button.InputEnded,function(input)
		releaseInput(input)
	end)
end

bindDirection(btnUp,"Forward")
bindDirection(btnDown,"Backward")
bindDirection(btnLeft,"Left")
bindDirection(btnRight,"Right")

connect(UserInputService.InputEnded,function(input)
	releaseInput(input)
end)

connect(UserInputService.TouchEnded,function(input)
	releaseInput(input)
end)

-- CAMERA / MOVEMENT
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

local smoothX = 0
local smoothZ = 0

local function getMoveVector()
	local x = 0
	local z = 0

	if moveState.Forward then z += 1 end
	if moveState.Backward then z -= 1 end
	if moveState.Left then x -= 1 end
	if moveState.Right then x += 1 end

	-- W Lock means forward camera movement when no WASD direction is held.
	if x == 0 and z == 0 then
		if moveState.WLock then
			-- W lock is immediate in both modes.
			smoothX = 0
			smoothZ = 1
			return cachedForward
		end

		-- KELINCAHAN stops immediately.
		if not isDelayMode then
			smoothX = 0
			smoothZ = 0
			return Vector3.zero
		end
	end

	-- Preserve the original distinction:
	-- KELINCAHAN = fast response
	-- DELAY = slow response / trail
	local lerpSpeed = isDelayMode and 0.15 or 0.95

	smoothX += (x - smoothX) * lerpSpeed
	smoothZ += (z - smoothZ) * lerpSpeed

	if math.abs(smoothX) < .005 then smoothX = 0 end
	if math.abs(smoothZ) < .005 then smoothZ = 0 end

	if smoothX == 0 and smoothZ == 0 then
		return Vector3.zero
	end

	local movement = cachedSide * smoothX + cachedForward * smoothZ

	if movement.Magnitude < .001 then
		return Vector3.zero
	end

	return movement.Unit
end

-- Air control:
-- Humanoid:Move is intentionally applied every RenderStepped,
-- including when Humanoid.FloorMaterial == Air.
connect(RunService.RenderStepped,function()
	if destroyed then return end

	if not character or not character.Parent then return end
	if not humanoid or humanoid.Health <= 0 then return end

	updateCameraVectors()

	local movement = getMoveVector()

	-- Keep air control active.
	humanoid:Move(movement,false)

	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local root = character:FindFirstChild("HumanoidRootPart")

		if camera and root then
			local _,y = camera.CFrame:ToOrientation()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,y,0)
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
menu.BackgroundTransparency = 0.05
menu.AutoButtonColor = false
menu.ZIndex = 100
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1,0)
menuCorner.Parent = menu

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(300,560)
settings.Position = UDim2.new(.5,-150,.5,-280)
settings.BackgroundColor3 = Color3.fromRGB(245,245,245)
settings.BackgroundTransparency = .05
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0,16)
settingsCorner.Parent = settings

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1,-20,0,160)
cameraSection.Position = UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3 = Color3.fromRGB(225,225,225)
cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0,12)
cameraCorner.Parent = cameraSection

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1,0,0,40)
cameraTitle.Text = "CAMERA SENSI SETTING"
cameraTitle.TextColor3 = Color3.fromRGB(20,20,20)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 18
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1,0,0,30)
sensLabel.Position = UDim2.fromOffset(0,40)
sensLabel.TextColor3 = Color3.fromRGB(60,60,60)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 14
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text = "Multiplier: "..string.format("%.1f",config.Sensitivity).."x"
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

local sensMinus = makeButton(cameraSection,"Minus",UDim2.new(.06,0,0,85),UDim2.fromOffset(76,42),"-",nil,43)
local sensReset = makeButton(cameraSection,"Reset",UDim2.new(.5,-42,0,85),UDim2.fromOffset(84,42),"RESET",nil,43)
local sensPlus = makeButton(cameraSection,"Plus",UDim2.new(.94,-76,0,85),UDim2.fromOffset(76,42),"+",nil,43)

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

local jumpSection = Instance.new("Frame")
jumpSection.Size = UDim2.new(1,-20,0,320)
jumpSection.Position = UDim2.fromOffset(10,180)
jumpSection.BackgroundColor3 = Color3.fromRGB(225,225,225)
jumpSection.BorderSizePixel = 0
jumpSection.ZIndex = 41
jumpSection.Parent = settings

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0,12)
jumpCorner.Parent = jumpSection

local modeSwitchBtn = makeButton(
	jumpSection,"ToggleTargetMode",
	UDim2.new(.05,0,0,10),
	UDim2.new(.9,0,0,36),
	"TARGET: JUMP BUTTON",
	Color3.fromRGB(70,150,255),43
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

local moveUp = makeButton(jumpSection,"MoveUp",UDim2.new(.5,-34,0,55),UDim2.fromOffset(68,46),"↑",nil,43)
local moveLeft = makeButton(jumpSection,"MoveLeft",UDim2.new(.10,0,0,102),UDim2.fromOffset(68,46),"←",nil,43)
local moveRight = makeButton(jumpSection,"MoveRight",UDim2.new(.90,-68,0,102),UDim2.fromOffset(68,46),"→",nil,43)
local moveDown = makeButton(jumpSection,"MoveDown",UDim2.new(.5,-34,0,149),UDim2.fromOffset(68,46),"↓",nil,43)

local sizePlus = makeButton(jumpSection,"SizePlus",UDim2.new(.06,0,0,207),UDim2.fromOffset(88,34),"SIZE +",nil,43)
local sizeMinus = makeButton(jumpSection,"SizeMinus",UDim2.new(.94,-88,0,207),UDim2.fromOffset(88,34),"SIZE -",nil,43)
local center = makeButton(jumpSection,"Center",UDim2.new(.5,-44,0,207),UDim2.fromOffset(88,34),"RESET",nil,43)

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

local function applyMoveStep(dx,dy)
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	end
end

local holding = {
	[moveUp]=false,
	[moveDown]=false,
	[moveLeft]=false,
	[moveRight]=false
}

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
		for button in pairs(holding) do
			holding[button] = false
		end
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
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(center.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
		updateJump()
	else
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
		updateShift()
	end
end)

local saveButton = makeButton(
	settings,"SaveConfig",
	UDim2.new(.05,0,1,-45),
	UDim2.fromOffset(130,38),
	"SAVE",
	Color3.fromRGB(70,200,100),43
)
saveButton.TextColor3 = Color3.new(1,1,1)

local closeButton = makeButton(
	settings,"Close",
	UDim2.new(.95,-130,1,-45),
	UDim2.fromOffset(130,38),
	"CLOSE",
	Color3.fromRGB(230,90,90),43
)
closeButton.TextColor3 = Color3.new(1,1,1)

connect(saveButton.Activated,function()
	saveConfig()
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
	end)

	task.delay(.2,function()
		if not destroyed then
			updateJump()
			updateShift()
		end
	end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	clearMovement()
	smoothX = 0
	smoothZ = 0

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
updateWLock()
updateJump()
updateShift()
