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

local SHIFT_LOCK_IMAGE_ID = "136616143786672"
local OPEN_MENU_IMAGE_ID = "112921115907036"

local config = {}

for k, v in pairs(defaultConfig) do
	config[k] = v
end

local destroyed = false
local connections = {}
local animatedGradients = {}

local function connect(signal, callback)
	local connection

	pcall(function()
		connection = signal:Connect(callback)
	end)

	if connection then
		table.insert(connections, connection)
	end

	return connection
end

local function disconnectAll()
	for i = #connections, 1, -1 do
		pcall(function()
			connections[i]:Disconnect()
		end)
	end

	table.clear(connections)
end

local function destroyGuiFrom(parent, name)
	if not parent then
		return
	end

	local gui = parent:FindFirstChild(name)

	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
end

local function destroyOldGui()
	destroyGuiFrom(playerGui, "DeltaMobileControls")
	destroyGuiFrom(playerGui, "DeltaMobileErgo")

	pcall(function()
		local coreGui = game:GetService("CoreGui")
		destroyGuiFrom(coreGui, "DeltaMobileControls")
		destroyGuiFrom(coreGui, "DeltaMobileErgo")
	end)
end

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

destroyOldGui()

_G.DeltaMobileControlsCleanup = function()
	if destroyed then
		return
	end

	destroyed = true

	disconnectAll()
	table.clear(animatedGradients)

	destroyGuiFrom(playerGui, "DeltaMobileControls")
	destroyGuiFrom(playerGui, "DeltaMobileErgo")

	pcall(function()
		local coreGui = game:GetService("CoreGui")
		destroyGuiFrom(coreGui, "DeltaMobileControls")
		destroyGuiFrom(coreGui, "DeltaMobileErgo")
	end)
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(
				CONFIG_FILE,
				HttpService:JSONEncode(config)
			)
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local raw = readfile(CONFIG_FILE)
			local data = HttpService:JSONDecode(raw)

			if type(data) == "table" then
				for k, v in pairs(data) do
					if defaultConfig[k] ~= nil
						and type(v) == type(defaultConfig[k]) then
						config[k] = v
					end
				end
			end
		end
	end)
end

loadConfig()

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.ShiftLocked = false

local BLACK = Color3.fromRGB(8, 8, 8)
local DARK = Color3.fromRGB(22, 22, 22)
local DARKER = Color3.fromRGB(14, 14, 14)

local WHITE = Color3.fromRGB(245, 245, 245)
local PURE_WHITE = Color3.fromRGB(255, 255, 255)

local ACTIVE_COLOR = Color3.fromRGB(45, 145, 255)
local ACTIVE_COLOR_2 = Color3.fromRGB(35, 115, 210)

local PRESSED_COLOR = Color3.fromRGB(65, 65, 65)
local PRESSED_TRANSPARENCY = 0.02
local NORMAL_TRANSPARENCY = 0.08

local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}

local activeInputs = {}
local buttonDefaults = {}

local function addCorner(object, radius)
	if not object then
		return
	end

	local old = object:FindFirstChildOfClass("UICorner")

	if old then
		old:Destroy()
	end

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = object

	return corner
end

local function addAnimatedStroke(object, thickness)
	if not object then
		return nil
	end

	local oldStroke = object:FindFirstChild("AnimatedGradientStroke")

	if oldStroke then
		oldStroke:Destroy()
	end

	local stroke = Instance.new("UIStroke")
	stroke.Name = "AnimatedGradientStroke"
	stroke.Thickness = thickness or 2
	stroke.Transparency = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Color = PURE_WHITE
	stroke.Parent = object

	local gradient = Instance.new("UIGradient")
	gradient.Name = "BlackWhiteGradient"

	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(0.20, Color3.fromRGB(70, 70, 70)),
		ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(80, 80, 80)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
	})

	gradient.Rotation = 0
	gradient.Offset = Vector2.new(-1, 0)
	gradient.Parent = stroke

	table.insert(animatedGradients, gradient)

	return stroke
end

local function getImageAsset(id)
	return "rbxassetid://" .. tostring(id)
end

local function applyImage(button, assetId)
	if not button then
		return
	end

	pcall(function()
		button.Image = getImageAsset(assetId)
		button.ImageTransparency = 0
		button.ImageColor3 = PURE_WHITE
		button.ScaleType = Enum.ScaleType.Fit
		button.ResampleMode = Enum.ResamplerMode.Default
	end)
end

local function setImageVisible(button)
	if not button or not button.Parent then
		return
	end

	pcall(function()
		button.ImageTransparency = 0
		button.ImageColor3 = PURE_WHITE
		button.ScaleType = Enum.ScaleType.Fit
	end)
end

local function setImageState(button, enabled)
	if not button or not button.Parent then
		return
	end

	pcall(function()
		button.ImageTransparency = 0

		if enabled then
			button.ImageColor3 = PURE_WHITE
			button.BackgroundColor3 = ACTIVE_COLOR
			button.BackgroundTransparency = 0.02
		else
			button.ImageColor3 = PURE_WHITE
			button.BackgroundColor3 = BLACK
			button.BackgroundTransparency = 0.05
		end
	end)
end

local function visual(button, pressed)
	if not button or not button.Parent then
		return
	end

	pcall(function()
		if pressed then
			button.BackgroundColor3 = PRESSED_COLOR
			button.BackgroundTransparency = PRESSED_TRANSPARENCY
			button.TextColor3 = PURE_WHITE
		else
			button.BackgroundColor3 =
				buttonDefaults[button] or DARK

			button.BackgroundTransparency =
				NORMAL_TRANSPARENCY

			button.TextColor3 = PURE_WHITE
		end
	end)
end

local function clearMovement()
	for direction in pairs(moveState) do
		moveState[direction] = false
	end

	for input in pairs(activeInputs) do
		activeInputs[input] = nil
	end
end

local btnWLock
local btnShiftLock

local function updateWLock()
	if not btnWLock or not btnWLock.Parent then
		return
	end

	if moveState.WLock then
		btnWLock.BackgroundColor3 = ACTIVE_COLOR
		btnWLock.BackgroundTransparency = 0.02
		btnWLock.TextColor3 = PURE_WHITE
	else
		btnWLock.BackgroundColor3 = BLACK
		btnWLock.BackgroundTransparency = 0.05
		btnWLock.TextColor3 = PURE_WHITE
	end

	btnWLock.Text = "W"
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
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.Position = UDim2.new(.5, -3, .5, -3)
crosshair.BackgroundColor3 = PURE_WHITE
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = screenGui

addCorner(crosshair, 6)
addAnimatedStroke(crosshair, 1.5)

local function toggleShiftLock()
	if destroyed then
		return
	end

	_G.ShiftLocked = not _G.ShiftLocked

	if btnShiftLock and btnShiftLock.Parent then
		setImageState(
			btnShiftLock,
			_G.ShiftLocked
		)
	end

	crosshair.Visible = _G.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end
end

btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(.5, .5)

btnShiftLock.Position = UDim2.new(
	config.ShiftX,
	0,
	config.ShiftY,
	0
)

btnShiftLock.Size = UDim2.fromOffset(
	config.ShiftSize,
	config.ShiftSize
)

btnShiftLock.BackgroundColor3 = BLACK
btnShiftLock.BackgroundTransparency = 0.05

btnShiftLock.ImageTransparency = 0
btnShiftLock.ImageColor3 = PURE_WHITE
btnShiftLock.ScaleType = Enum.ScaleType.Fit

btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = false
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = screenGui

applyImage(
	btnShiftLock,
	SHIFT_LOCK_IMAGE_ID
)

setImageVisible(btnShiftLock)

addCorner(btnShiftLock, 999)
addAnimatedStroke(btnShiftLock, 2.5)

connect(
	btnShiftLock.Activated,
	toggleShiftLock
)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "ControlsFrame"
mainFrame.Size = UDim2.fromOffset(300, 300)
mainFrame.Position = UDim2.new(0, 18, 1, -330)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local function createMoveButton(name, pos, size, text)
	local b = Instance.new("TextButton")

	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text

	b.BackgroundColor3 = BLACK
	b.BackgroundTransparency = NORMAL_TRANSPARENCY

	b.TextColor3 = PURE_WHITE
	b.Font = Enum.Font.GothamBold
	b.TextSize = 28

	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = 20
	b.Parent = mainFrame

	buttonDefaults[b] = b.BackgroundColor3

	addCorner(b, 14)
	addAnimatedStroke(b, 2)

	return b
end

local btnUp = createMoveButton(
	"Up",
	UDim2.new(.33, 0, 0, 0),
	UDim2.new(.34, 0, .34, 0),
	"▲"
)

local btnDown = createMoveButton(
	"Down",
	UDim2.new(.33, 0, .66, 0),
	UDim2.new(.34, 0, .34, 0),
	"▼"
)

local btnLeft = createMoveButton(
	"Left",
	UDim2.new(0, 0, .33, 0),
	UDim2.new(.34, 0, .34, 0),
	"◀"
)

local btnRight = createMoveButton(
	"Right",
	UDim2.new(.66, 0, .33, 0),
	UDim2.new(.34, 0, .34, 0),
	"▶"
)

btnWLock = Instance.new("TextButton")
btnWLock.Name = "WLock"
btnWLock.AnchorPoint = Vector2.new(.5, .5)
btnWLock.Position = UDim2.new(1, 42, .5, 0)
btnWLock.Size = UDim2.fromOffset(62, 62)

btnWLock.Text = "W"

btnWLock.BackgroundColor3 = BLACK
btnWLock.BackgroundTransparency = 0.05

btnWLock.TextColor3 = PURE_WHITE
btnWLock.Font = Enum.Font.GothamBold
btnWLock.TextSize = 25

btnWLock.AutoButtonColor = false
btnWLock.Active = true
btnWLock.Selectable = false
btnWLock.BorderSizePixel = 0
btnWLock.ZIndex = 30
btnWLock.Parent = mainFrame

addCorner(btnWLock, 999)
addAnimatedStroke(btnWLock, 2.5)

connect(
	btnWLock.Activated,
	function()
		if destroyed then
			return
		end

		moveState.WLock = not moveState.WLock
		updateWLock()
	end
)

local isDelayMode = false

local modeButton = Instance.new("TextButton")
modeButton.Name = "ToggleDelay"
modeButton.Position = UDim2.new(0, 0, -.20, 0)
modeButton.Size = UDim2.new(1, 0, .15, 0)

modeButton.Text = "MODE: KELINCAHAN"

modeButton.BackgroundColor3 = BLACK
modeButton.BackgroundTransparency = NORMAL_TRANSPARENCY

modeButton.TextColor3 = PURE_WHITE
modeButton.Font = Enum.Font.GothamBold
modeButton.TextSize = 16

modeButton.AutoButtonColor = false
modeButton.Active = true
modeButton.Selectable = false
modeButton.BorderSizePixel = 0
modeButton.ZIndex = 30
modeButton.Parent = mainFrame

addCorner(modeButton, 8)
addAnimatedStroke(modeButton, 2)

connect(
	modeButton.Activated,
	function()
		if destroyed then
			return
		end

		isDelayMode = not isDelayMode

		if isDelayMode then
			modeButton.Text = "MODE: DELAY (JEJAK)"
			modeButton.BackgroundColor3 = ACTIVE_COLOR
			modeButton.BackgroundTransparency = 0.02
			modeButton.TextColor3 = PURE_WHITE
		else
			modeButton.Text = "MODE: KELINCAHAN"
			modeButton.BackgroundColor3 = BLACK
			modeButton.BackgroundTransparency = NORMAL_TRANSPARENCY
			modeButton.TextColor3 = PURE_WHITE
		end
	end
)

local function setDirection(direction, state)
	moveState[direction] = state

	if direction == "Forward" then
		visual(btnUp, state)
	elseif direction == "Backward" then
		visual(btnDown, state)
	elseif direction == "Left" then
		visual(btnLeft, state)
	elseif direction == "Right" then
		visual(btnRight, state)
	end
end

local function releaseInput(input)
	local data = activeInputs[input]

	if not data then
		return
	end

	activeInputs[input] = nil

	setDirection(
		data.direction,
		false
	)
end

local function bindDirection(button, direction)
	connect(
		button.InputBegan,
		function(input)
			if destroyed then
				return
			end

			local t = input.UserInputType

			if t ~= Enum.UserInputType.Touch
				and t ~= Enum.UserInputType.MouseButton1 then
				return
			end

			if activeInputs[input] then
				return
			end

			activeInputs[input] = {
				direction = direction,
				button = button
			}

			setDirection(
				direction,
				true
			)
		end
	)

	connect(
		button.InputEnded,
		function(input)
			releaseInput(input)
		end
	)
end

bindDirection(btnUp, "Forward")
bindDirection(btnDown, "Backward")
bindDirection(btnLeft, "Left")
bindDirection(btnRight, "Right")

connect(
	UserInputService.InputEnded,
	function(input)
		releaseInput(input)
	end
)

local cachedForward = Vector3.new(0, 0, -1)
local cachedSide = Vector3.new(1, 0, 0)

local function updateCameraVectors()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local forward = Vector3.new(
		look.X,
		0,
		look.Z
	)

	local side = Vector3.new(
		right.X,
		0,
		right.Z
	)

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

	if moveState.Forward then
		z += 1
	end

	if moveState.Backward then
		z -= 1
	end

	if moveState.Left then
		x -= 1
	end

	if moveState.Right then
		x += 1
	end

	if x == 0 and z == 0 then
		if moveState.WLock then
			smoothX = 0
			smoothZ = 1

			return cachedForward
		end

		if not isDelayMode then
			smoothX = 0
			smoothZ = 0

			return Vector3.zero
		end
	end

	local lerpSpeed =
		isDelayMode and 0.15 or 0.95

	smoothX +=
		(x - smoothX) * lerpSpeed

	smoothZ +=
		(z - smoothZ) * lerpSpeed

	if math.abs(smoothX) < .005 then
		smoothX = 0
	end

	if math.abs(smoothZ) < .005 then
		smoothZ = 0
	end

	if smoothX == 0 and smoothZ == 0 then
		return Vector3.zero
	end

	local movement =
		cachedSide * smoothX +
		cachedForward * smoothZ

	if movement.Magnitude < .001 then
		return Vector3.zero
	end

	return movement.Unit
end

connect(
	RunService.RenderStepped,
	function()
		if destroyed then
			return
		end

		for i = #animatedGradients, 1, -1 do
			local gradient = animatedGradients[i]

			if gradient and gradient.Parent then
				local current = gradient.Offset.X
				local nextOffset = current + 0.012

				if nextOffset > 1.2 then
					nextOffset = -1.2
				end

				gradient.Offset = Vector2.new(
					nextOffset,
					0
				)
			else
				table.remove(
					animatedGradients,
					i
				)
			end
		end
	end
)

connect(
	RunService.RenderStepped,
	function()
		if destroyed then
			return
		end

		if not character or not character.Parent then
			return
		end

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		updateCameraVectors()

		local movement = getMoveVector()

		humanoid:Move(
			movement,
			false
		)

		if _G.ShiftLocked then
			local camera = workspace.CurrentCamera
			local root =
				character:FindFirstChild("HumanoidRootPart")

			if camera and root then
				local _, y =
					camera.CFrame:ToOrientation()

				root.CFrame =
					CFrame.new(root.Position) *
					CFrame.Angles(0, y, 0)
			end

			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
		end

		humanoid.CameraOffset = Vector3.zero
	end
)

local step = .018
local targetSettingMode = "JUMP"

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaMobileErgo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = playerGui

local function makeButton(parent, name, pos, size, text, bg, z)
	local b = Instance.new("TextButton")

	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text

	b.BackgroundColor3 = bg or BLACK
	b.BackgroundTransparency = NORMAL_TRANSPARENCY

	b.TextColor3 = PURE_WHITE
	b.Font = Enum.Font.GothamBold
	b.TextSize = 22

	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 41
	b.Parent = parent

	buttonDefaults[b] = b.BackgroundColor3

	addCorner(b, 12)
	addAnimatedStroke(b, 2)

	return b
end

local menu = Instance.new("ImageButton")
menu.Name = "OpenMenu"

menu.Position =
	UDim2.new(1, -72, 1, -72)

menu.Size =
	UDim2.fromOffset(60, 60)

menu.BackgroundColor3 = BLACK
menu.BackgroundTransparency = 0.05

menu.ImageTransparency = 0
menu.ImageColor3 = PURE_WHITE
menu.ScaleType = Enum.ScaleType.Fit

menu.AutoButtonColor = false
menu.Active = true
menu.Selectable = false
menu.BorderSizePixel = 0
menu.ZIndex = 100
menu.Parent = gui

applyImage(
	menu,
	OPEN_MENU_IMAGE_ID
)

setImageVisible(menu)

addCorner(menu, 999)
addAnimatedStroke(menu, 2.5)

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"

settings.Size =
	UDim2.fromOffset(300, 560)

settings.Position =
	UDim2.new(.5, -150, .5, -280)

settings.BackgroundColor3 = BLACK
settings.BackgroundTransparency = .04

settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

addCorner(settings, 16)
addAnimatedStroke(settings, 2.5)

local cameraSection = Instance.new("Frame")
cameraSection.Size =
	UDim2.new(1, -20, 0, 160)

cameraSection.Position =
	UDim2.fromOffset(10, 10)

cameraSection.BackgroundColor3 =
	Color3.fromRGB(28, 28, 28)

cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

addCorner(cameraSection, 12)
addAnimatedStroke(cameraSection, 1.5)

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size =
	UDim2.new(1, 0, 0, 40)

cameraTitle.Text =
	"CAMERA SENSI SETTING"

cameraTitle.TextColor3 =
	PURE_WHITE

cameraTitle.Font =
	Enum.Font.GothamBold

cameraTitle.TextSize = 18
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size =
	UDim2.new(1, 0, 0, 30)

sensLabel.Position =
	UDim2.fromOffset(0, 40)

sensLabel.TextColor3 =
	Color3.fromRGB(210, 210, 210)

sensLabel.Font =
	Enum.Font.Gotham

sensLabel.TextSize = 14
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text =
		"Multiplier: " ..
		string.format("%.1f", config.Sensitivity) ..
		"x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity =
			config.Sensitivity
	end)
end

local sensMinus = makeButton(
	cameraSection,
	"Minus",
	UDim2.new(.06, 0, 0, 85),
	UDim2.fromOffset(76, 42),
	"-",
	nil,
	43
)

local sensReset = makeButton(
	cameraSection,
	"Reset",
	UDim2.new(.5, -42, 0, 85),
	UDim2.fromOffset(84, 42),
	"RESET",
	nil,
	43
)

local sensPlus = makeButton(
	cameraSection,
	"Plus",
	UDim2.new(.94, -76, 0, 85),
	UDim2.fromOffset(76, 42),
	"+",
	nil,
	43
)

connect(
	sensMinus.Activated,
	function()
		config.Sensitivity =
			math.clamp(
				config.Sensitivity - .1,
				.1,
				10
			)

		applySensitivity()
	end
)

connect(
	sensPlus.Activated,
	function()
		config.Sensitivity =
			math.clamp(
				config.Sensitivity + .1,
				.1,
				10
			)

		applySensitivity()
	end
)

connect(
	sensReset.Activated,
	function()
		config.Sensitivity = 1
		applySensitivity()
	end
)

applySensitivity()

local jumpSection = Instance.new("Frame")
jumpSection.Size =
	UDim2.new(1, -20, 0, 320)

jumpSection.Position =
	UDim2.fromOffset(10, 180)

jumpSection.BackgroundColor3 =
	Color3.fromRGB(28, 28, 28)

jumpSection.BorderSizePixel = 0
jumpSection.ZIndex = 41
jumpSection.Parent = settings

addCorner(jumpSection, 12)
addAnimatedStroke(jumpSection, 1.5)

local modeSwitchBtn = makeButton(
	jumpSection,
	"ToggleTargetMode",
	UDim2.new(.05, 0, 0, 10),
	UDim2.new(.9, 0, 0, 36),
	"TARGET: JUMP BUTTON",
	BLACK,
	43
)

connect(
	modeSwitchBtn.Activated,
	function()
		if targetSettingMode == "JUMP" then
			targetSettingMode = "SHIFT"

			modeSwitchBtn.Text =
				"TARGET: SHIFT LOCK"

			modeSwitchBtn.BackgroundColor3 =
				ACTIVE_COLOR

			modeSwitchBtn.BackgroundTransparency = 0.02
			modeSwitchBtn.TextColor3 = PURE_WHITE
		else
			targetSettingMode = "JUMP"

			modeSwitchBtn.Text =
				"TARGET: JUMP BUTTON"

			modeSwitchBtn.BackgroundColor3 =
				BLACK

			modeSwitchBtn.BackgroundTransparency =
				NORMAL_TRANSPARENCY

			modeSwitchBtn.TextColor3 =
				PURE_WHITE
		end
	end
)

local moveUp = makeButton(
	jumpSection,
	"MoveUp",
	UDim2.new(.5, -34, 0, 55),
	UDim2.fromOffset(68, 46),
	"↑",
	nil,
	43
)

local moveLeft = makeButton(
	jumpSection,
	"MoveLeft",
	UDim2.new(.10, 0, 0, 102),
	UDim2.fromOffset(68, 46),
	"←",
	nil,
	43
)

local moveRight = makeButton(
	jumpSection,
	"MoveRight",
	UDim2.new(.90, -68, 0, 102),
	UDim2.fromOffset(68, 46),
	"→",
	nil,
	43
)

local moveDown = makeButton(
	jumpSection,
	"MoveDown",
	UDim2.new(.5, -34, 0, 149),
	UDim2.fromOffset(68, 46),
	"↓",
	nil,
	43
)

local sizePlus = makeButton(
	jumpSection,
	"SizePlus",
	UDim2.new(.06, 0, 0, 207),
	UDim2.fromOffset(88, 34),
	"SIZE +",
	nil,
	43
)

local sizeMinus = makeButton(
	jumpSection,
	"SizeMinus",
	UDim2.new(.94, -88, 0, 207),
	UDim2.fromOffset(88, 34),
	"SIZE -",
	nil,
	43
)

local center = makeButton(
	jumpSection,
	"Center",
	UDim2.new(.5, -44, 0, 207),
	UDim2.fromOffset(88, 34),
	"RESET",
	nil,
	43
)

local jumpButton

local function getJump()
	if jumpButton
		and jumpButton.Parent
		and jumpButton:IsDescendantOf(playerGui) then

		return jumpButton
	end

	local touchGui =
		playerGui:FindFirstChild("TouchGui")

	if touchGui then
		jumpButton =
			touchGui:FindFirstChild(
				"JumpButton",
				true
			)
	end

	return jumpButton
end

local function updateJump()
	if destroyed then
		return
	end

	local jump = getJump()
	local camera = workspace.CurrentCamera

	if not jump or not camera then
		return
	end

	local viewport = camera.ViewportSize

	if viewport.X <= 0 or viewport.Y <= 0 then
		return
	end

	config.JumpX =
		math.clamp(
			config.JumpX,
			.05,
			.95
		)

	config.JumpY =
		math.clamp(
			config.JumpY,
			.05,
			.95
		)

	config.JumpSize =
		math.clamp(
			config.JumpSize,
			.05,
			.50
		)

	local size =
		math.max(
			40,
			math.floor(
				viewport.Y *
				config.JumpSize
			)
		)

	pcall(function()
		jump.AnchorPoint =
			Vector2.new(.5, .5)

		jump.Position =
			UDim2.new(
				config.JumpX,
				0,
				config.JumpY,
				0
			)

		jump.Size =
			UDim2.fromOffset(
				size,
				size
			)
	end)
end

local function updateShift()
	config.ShiftX =
		math.clamp(
			config.ShiftX,
			.02,
			.98
		)

	config.ShiftY =
		math.clamp(
			config.ShiftY,
			.02,
			.98
		)

	config.ShiftSize =
		math.clamp(
			config.ShiftSize,
			20,
			100
		)

	if btnShiftLock and btnShiftLock.Parent then
		btnShiftLock.Position =
			UDim2.new(
				config.ShiftX,
				0,
				config.ShiftY,
				0
			)

		btnShiftLock.Size =
			UDim2.fromOffset(
				config.ShiftSize,
				config.ShiftSize
			)

		setImageVisible(btnShiftLock)
	end
end

local function applyMoveStep(dx, dy)
	if targetSettingMode == "JUMP" then
		config.JumpX =
			math.clamp(
				config.JumpX + dx,
				.05,
				.95
			)

		config.JumpY =
			math.clamp(
				config.JumpY + dy,
				.05,
				.95
			)

		updateJump()
	else
		config.ShiftX =
			math.clamp(
				config.ShiftX + dx,
				.02,
				.98
			)

		config.ShiftY =
			math.clamp(
				config.ShiftY + dy,
				.02,
				.98
			)

		updateShift()
	end
end

local holding = {
	[moveUp] = false,
	[moveDown] = false,
	[moveLeft] = false,
	[moveRight] = false
}

local function bindHold(button, dx, dy)
	connect(
		button.InputBegan,
		function(input)
			if destroyed then
				return
			end

			local t = input.UserInputType

			if t ~= Enum.UserInputType.Touch
				and t ~= Enum.UserInputType.MouseButton1 then
				return
			end

			holding[button] = true

			applyMoveStep(
				dx,
				dy
			)
		end
	)

	connect(
		button.InputEnded,
		function(input)
			local t = input.UserInputType

			if t == Enum.UserInputType.Touch
				or t == Enum.UserInputType.MouseButton1 then

				holding[button] = false
			end
		end
	)
end

bindHold(moveUp, 0, -step)
bindHold(moveDown, 0, step)
bindHold(moveLeft, -step, 0)
bindHold(moveRight, step, 0)

connect(
	UserInputService.InputEnded,
	function(input)
		local t = input.UserInputType

		if t == Enum.UserInputType.Touch
			or t == Enum.UserInputType.MouseButton1 then

			for button in pairs(holding) do
				holding[button] = false
			end
		end
	end
)

connect(
	RunService.RenderStepped,
	function()
		if destroyed then
			return
		end

		if holding[moveUp] then
			applyMoveStep(0, -step)
		end

		if holding[moveDown] then
			applyMoveStep(0, step)
		end

		if holding[moveLeft] then
			applyMoveStep(-step, 0)
		end

		if holding[moveRight] then
			applyMoveStep(step, 0)
		end
	end
)

connect(
	sizePlus.Activated,
	function()
		if targetSettingMode == "JUMP" then
			config.JumpSize =
				math.clamp(
					config.JumpSize + .05,
					.05,
					.50
				)

			updateJump()
		else
			config.ShiftSize =
				math.clamp(
					config.ShiftSize + 5,
					20,
					100
				)

			updateShift()
		end
	end
)

connect(
	sizeMinus.Activated,
	function()
		if targetSettingMode == "JUMP" then
			config.JumpSize =
				math.clamp(
					config.JumpSize - .05,
					.05,
					.50
				)

			updateJump()
		else
			config.ShiftSize =
				math.clamp(
					config.ShiftSize - 5,
					20,
					100
				)

			updateShift()
		end
	end
)

connect(
	center.Activated,
	function()
		if targetSettingMode == "JUMP" then
			config.JumpX = defaultConfig.JumpX
			config.JumpY = defaultConfig.JumpY
			config.JumpSize = defaultConfig.JumpSize

			updateJump()
		else
			config.ShiftX = defaultConfig.ShiftX
			config.ShiftY = defaultConfig.ShiftY
			config.ShiftSize = defaultConfig.ShiftSize

			updateShift()
		end
	end
)

local saveButton = makeButton(
	settings,
	"SaveConfig",
	UDim2.new(.05, 0, 1, -45),
	UDim2.fromOffset(130, 38),
	"SAVE",
	BLACK,
	43
)

local closeButton = makeButton(
	settings,
	"Close",
	UDim2.new(.95, -130, 1, -45),
	UDim2.fromOffset(130, 38),
	"CLOSE",
	BLACK,
	43
)

connect(
	saveButton.Activated,
	function()
		saveConfig()

		local old = saveButton.Text

		saveButton.Text = "SAVED!"
		saveButton.BackgroundColor3 = ACTIVE_COLOR
		saveButton.BackgroundTransparency = 0.02
		saveButton.TextColor3 = PURE_WHITE

		task.delay(
			1,
			function()
				if saveButton
					and saveButton.Parent then

					saveButton.Text = old
					saveButton.BackgroundColor3 = BLACK
					saveButton.BackgroundTransparency =
						NORMAL_TRANSPARENCY
					saveButton.TextColor3 =
						PURE_WHITE
				end
			end
		)
	end
)

local function updateMenuVisual()
	if settings.Visible then
		menu.BackgroundColor3 = ACTIVE_COLOR
		menu.BackgroundTransparency = 0.02
	else
		menu.BackgroundColor3 = BLACK
		menu.BackgroundTransparency = 0.05
	end

	setImageVisible(menu)
end

connect(
	menu.Activated,
	function()
		if destroyed then
			return
		end

		settings.Visible =
			not settings.Visible

		updateMenuVisual()
	end
)

connect(
	closeButton.Activated,
	function()
		settings.Visible = false
		updateMenuVisual()
	end
)

local function refresh()
	task.defer(function()
		if destroyed then
			return
		end

		updateJump()
		updateShift()
	end)

	task.delay(
		0.25,
		function()
			if not destroyed then
				updateJump()
				updateShift()
			end
		end
	)
end

connect(
	player.CharacterAdded,
	function(newCharacter)
		if destroyed then
			return
		end

		clearMovement()

		smoothX = 0
		smoothZ = 0

		character = newCharacter

		humanoid =
			newCharacter:WaitForChild(
				"Humanoid",
				10
			)

		if humanoid then
			humanoid.AutoRotate =
				not _G.ShiftLocked

			humanoid.CameraOffset =
				Vector3.zero
		end

		refresh()
	end
)

connect(
	playerGui.ChildAdded,
	function(child)
		if child.Name == "TouchGui" then
			jumpButton = nil

			task.defer(function()
				if not destroyed then
					refresh()
				end
			end)
		end
	end
)

connect(
	workspace:GetPropertyChangedSignal("CurrentCamera"),
	function()
		task.defer(function()
			if not destroyed then
				updateJump()
				updateShift()
			end
		end)
	end
)

updateCameraVectors()
updateWLock()
updateMenuVisual()
updateJump()
updateShift()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
	return
end

local NAME = "VZ_GameplayTouchGuard"
local EDGE = 36
local STROKE = 3

local function getParent()
	local ok, hui = pcall(function()
		return type(gethui) == "function" and gethui() or nil
	end)

	if ok and hui then
		return hui
	end

	return CoreGui
end

local Parent = getParent()

pcall(function()
	local old = Parent:FindFirstChild(NAME)
	if old then
		old:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = NAME
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 2147483646
ScreenGui.Parent = Parent

local function Guard(name)
	local b = Instance.new("TextButton")
	b.Name = name
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.Text = ""
	b.TextTransparency = 1
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.Modal = true
	b.ZIndex = 2147483647
	b.Parent = ScreenGui

	b.Activated:Connect(function()
	end)

	return b
end

local Top = Guard("Top")
local Bottom = Guard("Bottom")
local Left = Guard("Left")
local Right = Guard("Right")

local Border = Instance.new("Frame")
Border.Name = "TouchSafeBorder"
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 0
Border.ZIndex = 2147483645
Border.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 45)
Corner.Parent = Border

local Stroke = Instance.new("UIStroke")
Stroke.Name = "UIStroke"
Stroke.Thickness = STROKE
Stroke.Transparency = 0.08
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Border

local Gradient = Instance.new("UIGradient")
Gradient.Name = "UIGradient"
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.18, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.36, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.54, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
Gradient.Offset = Vector2.new(-1, 0)
Gradient.Parent = Stroke

local Glow = Instance.new("UIStroke")
Glow.Name = "NeonGlow"
Glow.Thickness = 8
Glow.Transparency = 0.78
Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Glow.Parent = Border

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Name = "NeonGradient"
GlowGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 130, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 70, 255)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 210)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 120))
})
GlowGradient.Offset = Vector2.new(-1, 0)
GlowGradient.Parent = Glow

TweenService:Create(
	Gradient,
	TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{Offset = Vector2.new(1, 0)}
):Play()

TweenService:Create(
	GlowGradient,
	TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{Offset = Vector2.new(1, 0)}
):Play()

local enabled = true
local gameplay = true

local function setVisible(state)
	enabled = state

	Top.Active = state
	Bottom.Active = state
	Left.Active = state
	Right.Active = state

	Border.Visible = state
end

local function update()
	local size = ScreenGui.AbsoluteSize
	local w = size.X
	local h = size.Y

	Top.Position = UDim2.fromOffset(0, 0)
	Top.Size = UDim2.fromOffset(w, EDGE)

	Bottom.Position = UDim2.fromOffset(0, math.max(0, h - EDGE))
	Bottom.Size = UDim2.fromOffset(w, EDGE)

	Left.Position = UDim2.fromOffset(0, EDGE)
	Left.Size = UDim2.fromOffset(
		EDGE,
		math.max(0, h - EDGE * 2)
	)

	Right.Position = UDim2.fromOffset(math.max(0, w - EDGE), EDGE)
	Right.Size = UDim2.fromOffset(
		EDGE,
		math.max(0, h - EDGE * 2)
	)

	Border.Position = UDim2.fromOffset(
		EDGE / 2,
		EDGE / 2
	)

	Border.Size = UDim2.fromOffset(
		math.max(0, w - EDGE),
		math.max(0, h - EDGE)
	)
end

ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
update()

local function textBoxFocused()
	local focused = UserInputService:GetFocusedTextBox()
	return focused ~= nil
end

local function refresh()
	if not UserInputService.TouchEnabled then
		setVisible(false)
		return
	end

	if not gameplay then
		setVisible(false)
		return
	end

	if textBoxFocused() then
		setVisible(false)
		return
	end

	setVisible(true)
end

UserInputService.TextBoxFocused:Connect(function()
	setVisible(false)
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	task.defer(refresh)
end)

pcall(function()
	GuiService.MenuOpened:Connect(function()
		gameplay = false
		setVisible(false)
	end)

	GuiService.MenuClosed:Connect(function()
		gameplay = true
		task.defer(refresh)
	end)
end)

Player.CharacterAdded:Connect(function()
	task.wait(0.5)
	gameplay = true
	refresh()
end)

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.5)

		if gameplay and not textBoxFocused() then
			if not enabled then
				setVisible(true)
			end
		elseif enabled then
			setVisible(false)
		end
	end
end)

_G.VZTouchGuard = {
	Enable = function()
		gameplay = true
		refresh()
	end,

	Disable = function()
		gameplay = false
		setVisible(false)
	end,

	SetEdge = function(value)
		value = tonumber(value)

		if not value then
			return
		end

		EDGE = math.clamp(math.floor(value), 20, 70)
		update()
	end,

	GetEdge = function()
		return EDGE
	end,

	Destroy = function()
		pcall(function()
			ScreenGui:Destroy()
		end)

		_G.VZTouchGuard = nil
	end
}

refresh()
