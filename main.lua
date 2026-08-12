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

local config = {}
for k, v in pairs(defaultConfig) do config[k] = v end

local function saveConfig()
	pcall(function()
		local data = HttpService:JSONEncode(config)
		if writefile then
			writefile(CONFIG_FILE, data)
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local raw = readfile(CONFIG_FILE)
			local decoded = HttpService:JSONDecode(raw)
			for k, v in pairs(decoded) do
				config[k] = v
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
local btnWLock = nil
local btnShiftLock = nil

local MAIN_BUTTON_COLOR = Color3.fromRGB(255, 255, 255)
local PRESSED_COLOR = Color3.fromRGB(70, 150, 255)
local WLOCK_OFF_COLOR = Color3.fromRGB(220, 70, 70)
local WLOCK_ON_COLOR = Color3.fromRGB(70, 200, 100)
local BUTTON_TRANSPARENCY = 0.15
local BUTTON_TEXT_COLOR = Color3.fromRGB(20, 20, 20)

local SHIFT_OFF_COLOR = Color3.fromRGB(255, 255, 255)
local SHIFT_ON_COLOR = Color3.fromRGB(170, 0, 255)

_G.ShiftLocked = false

local function connect(signal, callback)
	local c
	pcall(function()
		c = signal:Connect(callback)
	end)
	if c then table.insert(connections, c) end
	return c
end

local function disconnectAll()
	for i = 1, #connections do
		pcall(function() connections[i]:Disconnect() end)
	end
	table.clear(connections)
end

local function destroyGui(name)
	local obj = playerGui:FindFirstChild(name)
	if obj then
		pcall(function() obj:Destroy() end)
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

local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}

local buttonDefaults = {}

local function setButtonVisual(button, pressed)
	if not button or not button.Parent then return end
	local normalColor = buttonDefaults[button]
	if pressed then
		button.BackgroundColor3 = PRESSED_COLOR
	elseif normalColor then
		button.BackgroundColor3 = normalColor
	end
end

local function updateWLock()
	if destroyed or not btnWLock or not btnWLock.Parent then return end
	btnWLock.BackgroundColor3 = moveState.WLock and WLOCK_ON_COLOR or WLOCK_OFF_COLOR
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
crosshair.Position = UDim2.new(0.5, -3, 0.5, -3)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = screenGui

local crosshairCorner = Instance.new("UICorner")
crosshairCorner.CornerRadius = UDim.new(1, 0)
crosshairCorner.Parent = crosshair

local function toggleShiftLock()
	if destroyed then return end
	_G.ShiftLocked = not _G.ShiftLocked

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
	for button, color in pairs(buttonDefaults) do
		if button and button.Parent then
			button.BackgroundColor3 = color
		end
	end
	updateWLock()
end

local function clearMovement()
	moveState.Forward = false
	moveState.Backward = false
	moveState.Left = false
	moveState.Right = false
	moveState.WLock = false
	resetMovementVisuals()
end

btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(0.5, 0.5)
btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
btnShiftLock.Image = "rbxassetid://6031068426"
btnShiftLock.ImageColor3 = Color3.fromRGB(255, 255, 255)
btnShiftLock.BackgroundColor3 = SHIFT_OFF_COLOR
btnShiftLock.BackgroundTransparency = 0.2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = true
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = screenGui

local shiftCorner = Instance.new("UICorner")
shiftCorner.CornerRadius = UDim.new(1, 0)
shiftCorner.Parent = btnShiftLock

local shiftStroke = Instance.new("UIStroke")
shiftStroke.Thickness = 2
shiftStroke.Color = Color3.fromRGB(0, 0, 0)
shiftStroke.Transparency = 0.3
shiftStroke.Parent = btnShiftLock

connect(btnShiftLock.Activated, toggleShiftLock)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "ControlsFrame"
mainFrame.Size = UDim2.fromOffset(300, 300)
mainFrame.Position = UDim2.new(0, 18, 1, -330)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local function createButton(name, position, size, text, zIndex, bgColor)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.Text = text
	button.BackgroundColor3 = bgColor or MAIN_BUTTON_COLOR
	button.BackgroundTransparency = BUTTON_TRANSPARENCY
	button.TextColor3 = BUTTON_TEXT_COLOR
	button.Font = Enum.Font.GothamBold
	button.TextSize = 28
	button.AutoButtonColor = false
	button.Active = false
	button.Selectable = false
	button.BorderSizePixel = 0
	button.ZIndex = zIndex or 10
	button.Parent = mainFrame

	buttonDefaults[button] = button.BackgroundColor3

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button

	return button
end

local btnUp = createButton("Up", UDim2.new(.33,0,0,0), UDim2.new(.34,0,.34,0), "▲", 10, MAIN_BUTTON_COLOR)
local btnDown = createButton("Down", UDim2.new(.33,0,.66,0), UDim2.new(.34,0,.34,0), "▼", 10, MAIN_BUTTON_COLOR)
local btnLeft = createButton("Left", UDim2.new(0,0,.33,0), UDim2.new(.34,0,.34,0), "◀", 10, MAIN_BUTTON_COLOR)
local btnRight = createButton("Right", UDim2.new(.66,0,.33,0), UDim2.new(.34,0,.34,0), "▶", 10, MAIN_BUTTON_COLOR)

btnWLock = Instance.new("TextButton")
btnWLock.Name = "WLock"
btnWLock.Position = UDim2.new(.33,0,.33,0)
btnWLock.Size = UDim2.new(.34,0,.34,0)
btnWLock.Text = "W"
btnWLock.BackgroundColor3 = WLOCK_OFF_COLOR
btnWLock.BackgroundTransparency = BUTTON_TRANSPARENCY
btnWLock.TextColor3 = BUTTON_TEXT_COLOR
btnWLock.Font = Enum.Font.GothamBold
btnWLock.TextSize = 28
btnWLock.AutoButtonColor = false
btnWLock.Active = false
btnWLock.Selectable = false
btnWLock.BorderSizePixel = 0
btnWLock.ZIndex = 12
btnWLock.Parent = mainFrame

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1,0)
centerCorner.Parent = btnWLock

-- === FITUR SAKLAR MODE DELAY ===
local isDelayMode = false

local btnToggleDelay = Instance.new("TextButton")
btnToggleDelay.Name = "ToggleDelay"
btnToggleDelay.Position = UDim2.new(0, 0, -0.2, 0) 
btnToggleDelay.Size = UDim2.new(1, 0, 0.15, 0)
btnToggleDelay.Text = "MODE: KELINCAHAN"
btnToggleDelay.BackgroundColor3 = Color3.fromRGB(70, 200, 100)
btnToggleDelay.BackgroundTransparency = 0.15
btnToggleDelay.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggleDelay.Font = Enum.Font.GothamBold
btnToggleDelay.TextSize = 16
btnToggleDelay.AutoButtonColor = false
btnToggleDelay.BorderSizePixel = 0
btnToggleDelay.ZIndex = 12
btnToggleDelay.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = btnToggleDelay

connect(btnToggleDelay.Activated, function()
	if destroyed then return end
	isDelayMode = not isDelayMode
	if isDelayMode then
		btnToggleDelay.Text = "MODE: DELAY (JEJAK)"
		btnToggleDelay.BackgroundColor3 = Color3.fromRGB(220, 120, 40)
	else
		btnToggleDelay.Text = "MODE: KELINCAHAN"
		btnToggleDelay.BackgroundColor3 = Color3.fromRGB(70, 200, 100)
	end
end)
-- ===============================

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

local function updateMovementFromPosition(pos)
	local absPos = touchZone.AbsolutePosition
	local absSize = touchZone.AbsoluteSize
	
	local centerX = absPos.X + (absSize.X / 2)
	local centerY = absPos.Y + (absSize.Y / 2)
	
	local deltaX = (pos.X - centerX) / (absSize.X / 2)
	local deltaY = (pos.Y - centerY) / (absSize.Y / 2)

	moveState.Forward = false
	moveState.Backward = false
	moveState.Left = false
	moveState.Right = false

	local threshold = 0.15 

	if deltaY < -threshold then 
		moveState.Forward = true 
	elseif deltaY > threshold then 
		moveState.Backward = true 
	end
	
	if deltaX < -threshold then 
		moveState.Left = true 
	elseif deltaX > threshold then 
		moveState.Right = true 
	end

	setButtonVisual(btnUp, moveState.Forward)
	setButtonVisual(btnDown, moveState.Backward)
	setButtonVisual(btnLeft, moveState.Left)
	setButtonVisual(btnRight, moveState.Right)
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

		local function turnOffMovement()
			if activeTouchId == nil then
				moveState.Forward = false
				moveState.Backward = false
				moveState.Left = false
				moveState.Right = false

				setButtonVisual(btnUp, false)
				setButtonVisual(btnDown, false)
				setButtonVisual(btnLeft, false)
				setButtonVisual(btnRight, false)
			end
		end

		-- Langsung matikan delay jika lompat/di udara agar tidak ada jeda patah-patah/berhenti saat nge-combo jump
		local isJumpingOrInAir = false
		if humanoid and humanoid.Parent then
			pcall(function()
				local currentState = humanoid:GetState()
				if currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping or currentState == Enum.HumanoidStateType.Climbing or currentState == Enum.HumanoidStateType.Swimming then
					isJumpingOrInAir = true
				end
			end)
		end

		if isDelayMode and not isJumpingOrInAir then
			task.delay(0.25, turnOffMovement)
		else
			turnOffMovement()
		end
	end
end

connect(touchZone.InputEnded, stopTouch)
connect(UserInputService.InputEnded, function(input)
	if input == activeTouchId then
		stopTouch(input)
	end
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)

local function updateCameraVectors()
	if destroyed then return end
	local camera = workspace.CurrentCamera
	if not camera then return end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local forward = Vector3.new(look.X, 0, look.Z)
	local side = Vector3.new(right.X, 0, right.Z)

	if forward.Magnitude > .001 then cachedForward = forward.Unit end
	if side.Magnitude > .001 then cachedSide = side.Unit end
end

local function getMoveVector()
	local x, z = 0, 0

	if moveState.Forward then z += 1 end
	if moveState.Backward then z -= 1 end
	if moveState.Left then x -= 1 end
	if moveState.Right then x += 1 end

	if x == 0 and z == 0 then
		if moveState.WLock then return cachedForward end
		return Vector3.zero
	end

	local movement = cachedSide * x + cachedForward * z
	if movement.Magnitude < .001 then return Vector3.zero end

	return movement.Unit
end

connect(RunService.RenderStepped, function()
	if destroyed then return end

	local currentCharacter = character
	local currentHumanoid = humanoid

	if not currentCharacter or not currentCharacter.Parent or not currentHumanoid or currentHumanoid.Health <= 0 then
		return
	end

	updateCameraVectors()
	currentHumanoid:Move(getMoveVector(), false)

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

local step = 0.018
local targetSettingMode = "JUMP"

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaMobileErgo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = playerGui

local function makeButton(parent, name, position, sizeValue, text, bg, zIndex)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = sizeValue
	button.Text = text
	button.BackgroundColor3 = bg or Color3.fromRGB(245, 245, 245)
	button.BackgroundTransparency = 0.05
	button.TextColor3 = Color3.fromRGB(20, 20, 20)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 22
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = false
	button.BorderSizePixel = 0
	button.ZIndex = zIndex or 41
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	return button
end

local menu = makeButton(gui, "OpenMenu", UDim2.new(1, -72, 1, -72), UDim2.fromOffset(60, 60), "⚙", Color3.fromRGB(245, 245, 245), 100)

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1, 0)
menuCorner.Parent = menu

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(300, 560)
settings.Position = UDim2.new(.5, -150, .5, -280)
settings.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
settings.BackgroundTransparency = 0.05
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 16)
settingsCorner.Parent = settings

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1, -20, 0, 160)
cameraSection.Position = UDim2.fromOffset(10, 10)
cameraSection.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0, 12)
cameraCorner.Parent = cameraSection

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1, 0, 0, 40)
cameraTitle.Text = "CAMERA SENSI SETTING"
cameraTitle.TextColor3 = Color3.fromRGB(20, 20, 20)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 18
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1, 0, 0, 30)
sensLabel.Position = UDim2.fromOffset(0, 40)
sensLabel.Text = "Multiplier: 1.0x"
sensLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 14
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text = "Multiplier: " .. string.format("%.1f", config.Sensitivity) .. "x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

local function updateSensitivity(amount)
	config.Sensitivity = math.clamp(config.Sensitivity + amount, 0.1, 10)
	applySensitivity()
end

local sensMinus = makeButton(cameraSection, "Minus", UDim2.new(.06, 0, 0, 85), UDim2.fromOffset(76, 42), "-", nil, 43)
local sensReset = makeButton(cameraSection, "Reset", UDim2.new(.5, -42, 0, 85), UDim2.fromOffset(84, 42), "RESET", nil, 43)
local sensPlus = makeButton(cameraSection, "Plus", UDim2.new(.94, -76, 0, 85), UDim2.fromOffset(76, 42), "+", nil, 43)

connect(sensMinus.Activated, function()
	updateSensitivity(-0.1)
end)

connect(sensPlus.Activated, function()
	updateSensitivity(0.1)
end)

connect(sensReset.Activated, function()
	config.Sensitivity = 1.0
	applySensitivity()
end)

applySensitivity()

local jumpSection = Instance.new("Frame")
jumpSection.Size = UDim2.new(1, -20, 0, 320)
jumpSection.Position = UDim2.fromOffset(10, 180)
jumpSection.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
jumpSection.BorderSizePixel = 0
jumpSection.ZIndex = 41
jumpSection.Parent = settings

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 12)
jumpCorner.Parent = jumpSection

local modeSwitchBtn = makeButton(jumpSection, "ToggleTargetMode", UDim2.new(.05, 0, 0, 10), UDim2.new(.9, 0, 0, 36), "TARGET: JUMP BUTTON", Color3.fromRGB(70, 150, 255), 43)
modeSwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

connect(modeSwitchBtn.Activated, function()
	if targetSettingMode == "JUMP" then
		targetSettingMode = "SHIFT"
		modeSwitchBtn.Text = "TARGET: SHIFT LOCK"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	else
		targetSettingMode = "JUMP"
		modeSwitchBtn.Text = "TARGET: JUMP BUTTON"
		modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
	end
end)

local moveUp = makeButton(jumpSection, "MoveUp", UDim2.new(.5, -34, 0, 55), UDim2.fromOffset(68, 46), "↑", nil, 43)
local moveLeft = makeButton(jumpSection, "MoveLeft", UDim2.new(.10, 0, 0, 102), UDim2.fromOffset(68, 46), "←", nil, 43)
local moveRight = makeButton(jumpSection, "MoveRight", UDim2.new(.90, -68, 0, 102), UDim2.fromOffset(68, 46), "→", nil, 43)
local moveDown = makeButton(jumpSection, "MoveDown", UDim2.new(.5, -34, 0, 149), UDim2.fromOffset(68, 46), "↓", nil, 43)
local sizePlus = makeButton(jumpSection, "SizePlus", UDim2.new(.06, 0, 0, 207), UDim2.fromOffset(88, 34), "SIZE +", nil, 43)
local sizeMinus = makeButton(jumpSection, "SizeMinus", UDim2.new(.94, -88, 0, 207), UDim2.fromOffset(88, 34), "SIZE -", nil, 43)
local center = makeButton(jumpSection, "Center", UDim2.new(.5, -44, 0, 207), UDim2.fromOffset(88, 34), "RESET", nil, 43)

local jumpButton = nil

local function getJump()
	if jumpButton and jumpButton.Parent and jumpButton:IsDescendantOf(playerGui) then
		return jumpButton
	end

	local touchGui = playerGui:FindFirstChild("TouchGui")

	if touchGui then
		jumpButton = touchGui:FindFirstChild("JumpButton", true)
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

	config.JumpX = math.clamp(config.JumpX, .05, .95)
	config.JumpY = math.clamp(config.JumpY, .05, .95)
	config.JumpSize = math.clamp(config.JumpSize, .05, .50)

	local pixelSize = math.max(40, math.floor(viewport.Y * config.JumpSize))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5, .5)
		jump.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
		jump.Size = UDim2.fromOffset(pixelSize, pixelSize)
	end)
end

local function updateShiftLockPosition()
	if btnShiftLock and btnShiftLock.Parent then
		config.ShiftX = math.clamp(config.ShiftX, .02, .98)
		config.ShiftY = math.clamp(config.ShiftY, .02, .98)
		config.ShiftSize = math.clamp(config.ShiftSize, 20, 100)

		btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
		btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	end
end

local function applyMoveStep(dx, dy)
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX + dx, .05, .95)
		config.JumpY = math.clamp(config.JumpY + dy, .05, .95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX + dx, .02, .98)
		config.ShiftY = math.clamp(config.ShiftY + dy, .02, .98)
		updateShiftLockPosition()
	end
end

local holding = {
	[moveUp] = false,
	[moveDown] = false,
	[moveLeft] = false,
	[moveRight] = false
}

local function bindHoldButton(button, dx, dy)
	connect(button.InputBegan, function()
		holding[button] = true
		applyMoveStep(dx, dy)
	end)

	connect(button.InputEnded, function()
		holding[button] = false
	end)
end

bindHoldButton(moveUp, 0, -step)
bindHoldButton(moveDown, 0, step)
bindHoldButton(moveLeft, -step, 0)
bindHoldButton(moveRight, step, 0)

connect(RunService.RenderStepped, function()
	if holding[moveUp] then applyMoveStep(0, -step) end
	if holding[moveDown] then applyMoveStep(0, step) end
	if holding[moveLeft] then applyMoveStep(-step, 0) end
	if holding[moveRight] then applyMoveStep(step, 0) end
end)

connect(sizePlus.Activated, function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize + .05, .05, .50)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize + 5, 20, 100)
		updateShiftLockPosition()
	end
end)

connect(sizeMinus.Activated, function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize - .05, .05, .50)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize - 5, 20, 100)
		updateShiftLockPosition()
	end
end)

connect(center.Activated, function()
	if targetSettingMode == "JUMP" then
		config.JumpX, config.JumpY = defaultConfig.JumpX, defaultConfig.JumpY
		updateJump()
	else
		config.ShiftX, config.ShiftY = defaultConfig.ShiftX, defaultConfig.ShiftY
		updateShiftLockPosition()
	end
end)

local btnSaveConfig = makeButton(settings, "SaveConfig", UDim2.new(0.05, 0, 1, -45), UDim2.fromOffset(130, 38), "SAVE", Color3.fromRGB(70, 200, 100), 43)
local btnClose = makeButton(settings, "Close", UDim2.new(0.95, -130, 1, -45), UDim2.fromOffset(130, 38), "CLOSE", Color3.fromRGB(230, 90, 90), 43)

btnSaveConfig.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)

connect(btnSaveConfig.Activated, function()
	if not destroyed then
		saveConfig()

		local oldText = btnSaveConfig.Text
		btnSaveConfig.Text = "SAVED!"

		task.delay(1, function()
			if btnSaveConfig and btnSaveConfig.Parent then
				btnSaveConfig.Text = oldText
			end
		end)
	end
end)

connect(menu.Activated, function()
	if not destroyed then
		settings.Visible = not settings.Visible
	end
end)

connect(btnClose.Activated, function()
	if not destroyed then
		settings.Visible = false
	end
end)

local function refreshJump()
	if destroyed then return end

	task.defer(function()
		updateJump()
		updateShiftLockPosition()
	end)

	task.delay(0.2, function()
		updateJump()
		updateShiftLockPosition()
	end)
end

connect(player.CharacterAdded, function(newCharacter)
	if destroyed then return end

	clearMovement()
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid", 10)

	updateWLock()
	refreshJump()
end)

connect(playerGui.ChildAdded, function(child)
	if child.Name == "TouchGui" then
		refreshJump()
	end
end)

updateCameraVectors()
updateWLock()
updateJump()
updateShiftLockPosition()
