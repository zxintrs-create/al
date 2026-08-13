local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "DeltaMobileConfig.json"
local NOTE_PREFIX = "AldoVzNote"
local NOTE_EXT = ".txt"

local defaultConfig = {
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1,
	WalkSpeed = 16,
	AirControl = 20,
	ControllerEnabled = false
}

local config = {}
for k,v in pairs(defaultConfig) do
	config[k] = v
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
			local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(data) == "table" then
				for k,v in pairs(data) do
					if defaultConfig[k] ~= nil and type(v) == type(defaultConfig[k]) then
						config[k] = v
					end
				end
			end
		end
	end)
end

loadConfig()
config.ControllerEnabled = false

if _G.AldoVzNewMenuCleanup then
	pcall(_G.AldoVzNewMenuCleanup)
end

local connections = {}
local destroyed = false

local function connect(signal,callback)
	local c
	pcall(function()
		c = signal:Connect(callback)
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
	local obj = playerGui:FindFirstChild(name)
	if obj then
		pcall(function()
			obj:Destroy()
		end)
	end
end

_G.AldoVzNewMenuCleanup = function()
	if destroyed then return end
	destroyed = true
	disconnectAll()
	destroyGui("AldoVzMenu")
	destroyGui("AldoVzControls")
	destroyGui("AldoVzShiftLock")
end

destroyGui("AldoVzMenu")
destroyGui("AldoVzControls")
destroyGui("AldoVzShiftLock")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.ShiftLocked = false

local MAIN_COLOR = Color3.fromRGB(255,255,255)
local PRESSED_COLOR = Color3.fromRGB(70,150,255)
local WLOCK_OFF = Color3.fromRGB(220,70,70)
local WLOCK_ON = Color3.fromRGB(70,200,100)
local SHIFT_OFF = Color3.fromRGB(255,255,255)
local SHIFT_ON = Color3.fromRGB(170,0,255)
local PURPLE = Color3.fromRGB(105,55,190)
local PANEL = Color3.fromRGB(28,28,38)
local PANEL2 = Color3.fromRGB(36,36,48)
local BUTTON = Color3.fromRGB(48,48,62)
local TEXT = Color3.fromRGB(240,240,245)
local WHITE = Color3.fromRGB(255,255,255)

local function addGradient(parent,a,b,c)
	local g=Instance.new("UIGradient")
	g.Name="PremiumGradient"
	g.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,a),
		ColorSequenceKeypoint.new(0.5,b),
		ColorSequenceKeypoint.new(1,c)
	})
	g.Rotation=0
	g.Offset=Vector2.new(-1,0)
	g.Parent=parent
	return g
end

local function addPremiumStroke(parent)
	local st=Instance.new("UIStroke")
	st.Name="PremiumStroke"
	st.Thickness=1.5
	st.Color=WHITE
	st.Transparency=0.08
	st.Parent=parent

	local g=Instance.new("UIGradient")
	g.Name="StrokeGradient"
	g.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5,Color3.fromRGB(170,90,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
	})
	g.Parent=st

	return g
end

local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}

local buttonDefaults = {}
local activeInputs = {}

local function visual(button,pressed)
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
		btnWLock.Text = moveState.WLock and "ON" or "OFF"
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

	for button,color in pairs(buttonDefaults) do
		if button and button.Parent then
			button.BackgroundColor3 = color
		end
	end

	updateWLock()
end

local controlsGui = Instance.new("ScreenGui")
controlsGui.Name = "AldoVzControls"
controlsGui.ResetOnSpawn = false
controlsGui.IgnoreGuiInset = true
controlsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
controlsGui.DisplayOrder = 999998
controlsGui.Enabled = config.ControllerEnabled
controlsGui.Parent = playerGui

local mainControlFrame = Instance.new("Frame")
mainControlFrame.Name = "ControlsFrame"
mainControlFrame.Size = UDim2.fromOffset(300,300)
mainControlFrame.Position = UDim2.new(0,18,1,-330)
mainControlFrame.BackgroundTransparency = 1
mainControlFrame.BorderSizePixel = 0
mainControlFrame.Parent = controlsGui

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
	b.Parent = mainControlFrame
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

btnWLock = Instance.new("TextButton")
btnWLock.Name = "WLock"
btnWLock.AnchorPoint = Vector2.new(.5,.5)
btnWLock.Position = UDim2.new(1,42,.5,0)
btnWLock.Size = UDim2.fromOffset(62,62)
btnWLock.Text = "OFF"
btnWLock.BackgroundColor3 = WLOCK_OFF
btnWLock.BackgroundTransparency = .10
btnWLock.TextColor3 = Color3.new(1,1,1)
btnWLock.Font = Enum.Font.GothamBold
btnWLock.TextSize = 18
btnWLock.AutoButtonColor = false
btnWLock.Active = true
btnWLock.Selectable = false
btnWLock.BorderSizePixel = 0
btnWLock.ZIndex = 30
btnWLock.Parent = mainControlFrame

local wc = Instance.new("UICorner")
wc.CornerRadius = UDim.new(1,0)
wc.Parent = btnWLock

local function toggleWLock()
	if destroyed then return end
	moveState.WLock = not moveState.WLock
	updateWLock()
end

connect(btnWLock.Activated,toggleWLock)

local shiftGui = Instance.new("ScreenGui")
shiftGui.Name = "AldoVzShiftLock"
shiftGui.ResetOnSpawn = false
shiftGui.IgnoreGuiInset = true
shiftGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shiftGui.DisplayOrder = 999999
shiftGui.Parent = playerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = Color3.new(1,1,1)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = shiftGui

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1,0)
cc.Parent = crosshair

btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(.5,.5)
btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image = "rbxassetid://6031068426"
btnShiftLock.ImageColor3 = Color3.new(1,1,1)
btnShiftLock.BackgroundColor3 = SHIFT_OFF
btnShiftLock.BackgroundTransparency = .2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = false
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = shiftGui

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(1,0)
sc.Parent = btnShiftLock

local ss = Instance.new("UIStroke")
ss.Name = "PremiumStroke"
ss.Thickness = 2
ss.Color = Color3.new(1,1,1)
ss.Transparency = .08
ss.Parent = btnShiftLock

local ssGradient = Instance.new("UIGradient")
ssGradient.Name = "StrokeGradient"
ssGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(170,90,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
})
ssGradient.Parent = ss

local function toggleShiftLock()
	if destroyed then return end

	_G.ShiftLocked = not _G.ShiftLocked
	btnShiftLock.BackgroundColor3 = _G.ShiftLocked and SHIFT_ON or SHIFT_OFF
	crosshair.Visible = _G.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end
end

connect(btnShiftLock.Activated,toggleShiftLock)

local function setDirection(direction,state)
	moveState[direction] = state

	if direction == "Forward" then
		visual(btnUp,state)
	elseif direction == "Backward" then
		visual(btnDown,state)
	elseif direction == "Left" then
		visual(btnLeft,state)
	elseif direction == "Right" then
		visual(btnRight,state)
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
		if destroyed or not controlsGui.Enabled then return end

		local t = input.UserInputType

		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then
			return
		end

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

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)
local smoothX = 0
local smoothZ = 0

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
	if not controlsGui.Enabled then
		smoothX = 0
		smoothZ = 0
		return Vector3.zero
	end

	local x = 0
	local z = 0

	if moveState.Forward then z += 1 end
	if moveState.Backward then z -= 1 end
	if moveState.Left then x -= 1 end
	if moveState.Right then x += 1 end

	if x == 0 and z == 0 and moveState.WLock then
		smoothX = 0
		smoothZ = 1
		return cachedForward
	end

	smoothX += (x-smoothX)*.95
	smoothZ += (z-smoothZ)*.95

	if math.abs(smoothX)<.005 then smoothX=0 end
	if math.abs(smoothZ)<.005 then smoothZ=0 end

	if smoothX==0 and smoothZ==0 then
		return Vector3.zero
	end

	local movement = cachedSide*smoothX + cachedForward*smoothZ

	if movement.Magnitude<.001 then
		return Vector3.zero
	end

	return movement.Unit
end

local function applyWalkSpeed()
	if humanoid and humanoid.Parent then
		pcall(function()
			humanoid.WalkSpeed = config.WalkSpeed
		end)
	end
end

local function updateShift()
	config.ShiftX = math.clamp(config.ShiftX,.02,.98)
	config.ShiftY = math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize = math.clamp(config.ShiftSize,20,100)

	btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local targetSettingMode = "JUMP"
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

	if viewport.X<=0 or viewport.Y<=0 then return end

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

local function applyMoveStep(dx,dy)
	if targetSettingMode=="JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	end
end

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "AldoVzMenu"
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.DisplayOrder = 1000001
mainGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.AnchorPoint = Vector2.new(0,0)
openButton.Position = UDim2.fromOffset(12,72)
openButton.Size = UDim2.fromOffset(54,36)
openButton.Text = "MENU"
openButton.BackgroundColor3 = PANEL
openButton.BackgroundTransparency = .05
openButton.TextColor3 = TEXT
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 13
openButton.AutoButtonColor = false
openButton.Active = true
openButton.Selectable = false
openButton.BorderSizePixel = 0
openButton.ZIndex = 2000
openButton.Parent = mainGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0,10)
openCorner.Parent = openButton

addGradient(
	openButton,
	Color3.fromRGB(25,25,36),
	Color3.fromRGB(100,50,150),
	Color3.fromRGB(25,25,36)
)

addPremiumStroke(openButton)

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.AnchorPoint = Vector2.new(0,0)
menuFrame.Position = UDim2.new(0.02,0,0.10,0)
menuFrame.Size = UDim2.new(0.96,0,0.80,0)
menuFrame.BackgroundColor3 = PANEL
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 1000
menuFrame.Parent = mainGui

local menuSizeConstraint = Instance.new("UISizeConstraint")
menuSizeConstraint.MinSize = Vector2.new(300,420)
menuSizeConstraint.MaxSize = Vector2.new(760,760)
menuSizeConstraint.Parent = menuFrame

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0,14)
menuCorner.Parent = menuFrame

local menuStrokeGradient = addPremiumStroke(menuFrame)
local menuBackgroundGradient = addGradient(
	menuFrame,
	Color3.fromRGB(18,18,28),
	Color3.fromRGB(40,25,58),
	Color3.fromRGB(18,18,28)
)

local menuLabel = Instance.new("TextLabel")
menuLabel.Name = "MenuLabel"
menuLabel.Position = UDim2.fromOffset(14,8)
menuLabel.Size = UDim2.new(1,-28,0,42)
menuLabel.BackgroundTransparency = 1
menuLabel.Text = "👾 AldoVz    PING : 0    FPS : 0    CHECK : 0    SPEED : 16"
menuLabel.TextColor3 = TEXT
menuLabel.Font = Enum.Font.GothamBold
menuLabel.TextSize = 15
menuLabel.TextXAlignment = Enum.TextXAlignment.Left
menuLabel.ZIndex = 1100
menuLabel.Parent = menuFrame

local menuLabelGradient = Instance.new("UIGradient")
menuLabelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(190,110,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
})
menuLabelGradient.Parent = menuLabel

local commandLabel = Instance.new("TextLabel")
commandLabel.Name = "CommandLabel"
commandLabel.Position = UDim2.new(0,14,0,47)
commandLabel.Size = UDim2.new(0.40,-14,0,30)
commandLabel.BackgroundTransparency = 1
commandLabel.Text = "COMMAND INFINITE YIELD :"
commandLabel.TextColor3 = TEXT
commandLabel.Font = Enum.Font.GothamBold
commandLabel.TextSize = 12
commandLabel.TextXAlignment = Enum.TextXAlignment.Left
commandLabel.ZIndex = 1100
commandLabel.Parent = menuFrame

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Position = UDim2.new(0.40,0,0,48)
commandBox.Size = UDim2.new(0.58,0,0,28)
commandBox.BackgroundColor3 = PANEL2
commandBox.BorderSizePixel = 0
commandBox.Text = ""
commandBox.PlaceholderText = "command..."
commandBox.TextColor3 = TEXT
commandBox.PlaceholderColor3 = Color3.fromRGB(150,150,160)
commandBox.Font = Enum.Font.Gotham
commandBox.TextSize = 12
commandBox.ClearTextOnFocus = false
commandBox.ZIndex = 1100
commandBox.Parent = menuFrame

local commandCorner = Instance.new("UICorner")
commandCorner.CornerRadius = UDim.new(0,7)
commandCorner.Parent = commandBox

local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "MenuList"
sidebar.Position = UDim2.fromOffset(10,84)
sidebar.Size = UDim2.new(0,150,1,-94)
sidebar.CanvasSize = UDim2.new(0,0,0,0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
sidebar.BackgroundColor3 = Color3.fromRGB(22,22,30)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 1050
sidebar.Parent = menuFrame

addGradient(
	sidebar,
	Color3.fromRGB(20,20,30),
	Color3.fromRGB(35,20,55),
	Color3.fromRGB(20,20,30)
)

addPremiumStroke(sidebar)

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0,10)
sidebarCorner.Parent = sidebar

local listTitle = Instance.new("TextLabel")
listTitle.Position = UDim2.fromOffset(10,8)
listTitle.Size = UDim2.new(1,-20,0,28)
listTitle.BackgroundTransparency = 1
listTitle.Text = "MENU LIST"
listTitle.TextColor3 = TEXT
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 13
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.ZIndex = 1060
listTitle.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0,6)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "AreaMainFrame"
content.Position = UDim2.fromOffset(170,84)
content.Size = UDim2.new(1,-180,1,-94)
content.BackgroundColor3 = Color3.fromRGB(24,24,32)
content.BorderSizePixel = 0
content.ZIndex = 1050
content.Parent = menuFrame

addGradient(
	content,
	Color3.fromRGB(22,22,32),
	Color3.fromRGB(42,25,58),
	Color3.fromRGB(22,22,32)
)

addPremiumStroke(content)

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0,10)
contentCorner.Parent = content

local pages = {}
local navButtons = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name.."Frame"
	page.Size = UDim2.fromScale(1,1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.CanvasSize = UDim2.new(0,0,0,520)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 1060
	page.Parent = content

	pages[name] = page

	return page
end

local mainPage = createPage("Main")
local notePage = createPage("Note")
local controlPage = createPage("Control")
local playerPage = createPage("Player")

local function makeButton(parent,name,pos,size,text,bg,z)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = bg or BUTTON
	b.BackgroundTransparency = .04
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 1070
	b.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,9)
	c.Parent = b

	addGradient(
		b,
		Color3.fromRGB(45,45,58),
		Color3.fromRGB(90,45,130),
		Color3.fromRGB(45,45,58)
	)

	addPremiumStroke(b)

	return b
end

local function createNav(name,text,y)
	local b = makeButton(
		sidebar,
		name,
		UDim2.new(),
		UDim2.new(1,-20,0,48),
		text,
		BUTTON,
		1070
	)

	b.LayoutOrder = math.floor(y/56)
	navButtons[name] = b

	return b
end

local navMain = createNav("MainButton","MAIN",48)
local navNote = createNav("NoteButton","NOTE",104)
local navControl = createNav("ControlButton","CONTROL",160)
local navPlayer = createNav("PlayerButton","PLAYER",216)

local function selectPage(name)
	for n,p in pairs(pages) do
		p.Visible = n==name
	end

	for n,b in pairs(navButtons) do
		b.BackgroundColor3 = BUTTON
	end

	local b = navButtons[name]

	if b then
		b.BackgroundColor3 = PURPLE
	end
end

connect(navMain.Activated,function()
	selectPage("Main")
end)

connect(navNote.Activated,function()
	selectPage("Note")
end)

connect(navControl.Activated,function()
	selectPage("Control")
end)

connect(navPlayer.Activated,function()
	selectPage("Player")
end)

local mainTitle = Instance.new("TextLabel")
mainTitle.Position = UDim2.fromOffset(14,10)
mainTitle.Size = UDim2.new(1,-28,0,34)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "MAIN"
mainTitle.TextColor3 = TEXT
mainTitle.Font = Enum.Font.GothamBold
mainTitle.TextSize = 18
mainTitle.TextXAlignment = Enum.TextXAlignment.Left
mainTitle.ZIndex = 1070
mainTitle.Parent = mainPage

local speedSection = Instance.new("Frame")
speedSection.Position = UDim2.fromOffset(14,52)
speedSection.Size = UDim2.new(1,-28,0,90)
speedSection.BackgroundColor3 = PANEL2
speedSection.BorderSizePixel = 0
speedSection.ZIndex = 1065
speedSection.Parent = mainPage

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,10)
speedCorner.Parent = speedSection

addGradient(
	speedSection,
	Color3.fromRGB(35,35,48),
	Color3.fromRGB(70,38,95),
	Color3.fromRGB(35,35,48)
)

addPremiumStroke(speedSection)

local speedTitle = Instance.new("TextLabel")
speedTitle.Position = UDim2.fromOffset(12,8)
speedTitle.Size = UDim2.new(1,-24,0,24)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "WALK SPEED"
speedTitle.TextColor3 = TEXT
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 13
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.ZIndex = 1070
speedTitle.Parent = speedSection

local speedMinus = makeButton(
	speedSection,
	"SpeedMinus",
	UDim2.fromOffset(14,38),
	UDim2.fromOffset(62,40),
	"-",
	BUTTON,
	1070
)

local speedValue = Instance.new("TextLabel")
speedValue.Position = UDim2.new(.5,-50,0,38)
speedValue.Size = UDim2.fromOffset(100,40)
speedValue.BackgroundTransparency = 1
speedValue.TextColor3 = TEXT
speedValue.Font = Enum.Font.GothamBold
speedValue.TextSize = 16
speedValue.ZIndex = 1070
speedValue.Parent = speedSection

local speedPlus = makeButton(
	speedSection,
	"SpeedPlus",
	UDim2.new(1,-76,0,38),
	UDim2.fromOffset(62,40),
	"+",
	BUTTON,
	1070
)

local function updateSpeedText()
	speedValue.Text = tostring(math.floor(config.WalkSpeed))
	menuLabel.Text = "👾 AldoVz    PING : 0    FPS : 0    CHECK : 0    SPEED : "..tostring(math.floor(config.WalkSpeed))
end

connect(speedMinus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed-1,1,500)
	applyWalkSpeed()
	updateSpeedText()
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed+1,1,500)
	applyWalkSpeed()
	updateSpeedText()
end)

local settingSection = Instance.new("Frame")
settingSection.Position = UDim2.fromOffset(14,152)
settingSection.Size = UDim2.new(1,-28,0,320)
settingSection.BackgroundColor3 = PANEL2
settingSection.BorderSizePixel = 0
settingSection.ZIndex = 1065
settingSection.Parent = mainPage

local settingCorner = Instance.new("UICorner")
settingCorner.CornerRadius = UDim.new(0,10)
settingCorner.Parent = settingSection

addGradient(
	settingSection,
	Color3.fromRGB(35,35,48),
	Color3.fromRGB(70,38,95),
	Color3.fromRGB(35,35,48)
)

addPremiumStroke(settingSection)

local settingTitle = Instance.new("TextLabel")
settingTitle.Position = UDim2.fromOffset(12,8)
settingTitle.Size = UDim2.new(1,-24,0,28)
settingTitle.BackgroundTransparency = 1
settingTitle.Text = "SETTING SHIFTLOCK / JUMP"
settingTitle.TextColor3 = TEXT
settingTitle.Font = Enum.Font.GothamBold
settingTitle.TextSize = 13
settingTitle.TextXAlignment = Enum.TextXAlignment.Left
settingTitle.ZIndex = 1070
settingTitle.Parent = settingSection

local targetButton = makeButton(
	settingSection,
	"TargetButton",
	UDim2.fromOffset(12,42),
	UDim2.new(1,-24,0,40),
	"PILIH SET : JUMP",
	PURPLE,
	1070
)

local moveUp = makeButton(
	settingSection,
	"MoveUp",
	UDim2.new(.5,-34,0,90),
	UDim2.fromOffset(68,42),
	"↑",
	BUTTON,
	1070
)

local moveLeft = makeButton(
	settingSection,
	"MoveLeft",
	UDim2.new(.22,0,0,136),
	UDim2.fromOffset(68,42),
	"←",
	BUTTON,
	1070
)

local moveRight = makeButton(
	settingSection,
	"MoveRight",
	UDim2.new(.78,-68,0,136),
	UDim2.fromOffset(68,42),
	"→",
	BUTTON,
	1070
)

local moveDown = makeButton(
	settingSection,
	"MoveDown",
	UDim2.new(.5,-34,0,182),
	UDim2.fromOffset(68,42),
	"↓",
	BUTTON,
	1070
)

local sizePlus = makeButton(
	settingSection,
	"SizePlus",
	UDim2.fromOffset(12,232),
	UDim2.fromOffset(105,38),
	"SIZE +",
	BUTTON,
	1070
)

local resetButton = makeButton(
	settingSection,
	"Reset",
	UDim2.new(.5,-55,0,232),
	UDim2.fromOffset(110,38),
	"RESET 🔁",
	BUTTON,
	1070
)

local sizeMinus = makeButton(
	settingSection,
	"SizeMinus",
	UDim2.new(1,-117,0,232),
	UDim2.fromOffset(105,38),
	"SIZE -",
	BUTTON,
	1070
)

connect(targetButton.Activated,function()
	if targetSettingMode=="JUMP" then
		targetSettingMode="SHIFT"
		targetButton.Text="PILIH SET : SHIFTLOCK"
	else
		targetSettingMode="JUMP"
		targetButton.Text="PILIH SET : JUMP"
	end
end)

local holding = {
	[moveUp]=false,
	[moveDown]=false,
	[moveLeft]=false,
	[moveRight]=false
}

local function bindHold(button,dx,dy)
	connect(button.InputBegan,function(input)
		local t=input.UserInputType

		if t~=Enum.UserInputType.Touch and t~=Enum.UserInputType.MouseButton1 then
			return
		end

		holding[button]=true
		applyMoveStep(dx,dy)
	end)

	connect(button.InputEnded,function(input)
		local t=input.UserInputType

		if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
			holding[button]=false
		end
	end)
end

local step = .018

bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)

local function resetTarget()
	if targetSettingMode=="JUMP" then
		config.JumpX=defaultConfig.JumpX
		config.JumpY=defaultConfig.JumpY
		config.JumpSize=defaultConfig.JumpSize
		updateJump()
	else
		config.ShiftX=defaultConfig.ShiftX
		config.ShiftY=defaultConfig.ShiftY
		config.ShiftSize=defaultConfig.ShiftSize
		updateShift()
	end
end

connect(sizePlus.Activated,function()
	if targetSettingMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	else
		config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if targetSettingMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	else
		config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(resetButton.Activated,resetTarget)

local noteTitle = Instance.new("TextLabel")
noteTitle.Position = UDim2.fromOffset(14,10)
noteTitle.Size = UDim2.new(1,-28,0,34)
noteTitle.BackgroundTransparency = 1
noteTitle.Text = "NOTE"
noteTitle.TextColor3 = TEXT
noteTitle.Font = Enum.Font.GothamBold
noteTitle.TextSize = 18
noteTitle.TextXAlignment = Enum.TextXAlignment.Left
noteTitle.ZIndex = 1070
noteTitle.Parent = notePage

local noteList = Instance.new("ScrollingFrame")
noteList.Name = "NoteList"
noteList.Position = UDim2.new(0.04,0,0,52)
noteList.Size = UDim2.new(0.38,0,0,390)
noteList.BackgroundColor3 = PANEL2
noteList.BorderSizePixel = 0
noteList.ScrollBarThickness = 4
noteList.CanvasSize = UDim2.new()
noteList.ZIndex = 1065
noteList.Parent = notePage

local noteListCorner = Instance.new("UICorner")
noteListCorner.CornerRadius = UDim.new(0,10)
noteListCorner.Parent = noteList

addGradient(
	noteList,
	Color3.fromRGB(35,35,48),
	Color3.fromRGB(70,38,95),
	Color3.fromRGB(35,35,48)
)

addPremiumStroke(noteList)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,6)
noteLayout.Parent = noteList

local noteEditor = Instance.new("TextBox")
noteEditor.Name = "NoteEditor"
noteEditor.Position = UDim2.new(0.44,0,0,52)
noteEditor.Size = UDim2.new(0.52,0,0,330)
noteEditor.BackgroundColor3 = PANEL2
noteEditor.BorderSizePixel = 0
noteEditor.Text = ""
noteEditor.PlaceholderText = "Isi note..."
noteEditor.TextColor3 = TEXT
noteEditor.PlaceholderColor3 = Color3.fromRGB(140,140,150)
noteEditor.Font = Enum.Font.Gotham
noteEditor.TextSize = 13
noteEditor.TextWrapped = false
noteEditor.TextXAlignment = Enum.TextXAlignment.Left
noteEditor.TextYAlignment = Enum.TextYAlignment.Top
noteEditor.MultiLine = true
noteEditor.ClearTextOnFocus = false
noteEditor.ZIndex = 1070
noteEditor.Parent = notePage

local noteEditorCorner = Instance.new("UICorner")
noteEditorCorner.CornerRadius = UDim.new(0,10)
noteEditorCorner.Parent = noteEditor

addGradient(
	noteEditor,
	Color3.fromRGB(35,35,48),
	Color3.fromRGB(70,38,95),
	Color3.fromRGB(35,35,48)
)

addPremiumStroke(noteEditor)

local noteStatus = Instance.new("TextLabel")
noteStatus.Position = UDim2.new(0.44,0,0,390)
noteStatus.Size = UDim2.new(0.52,0,0,28)
noteStatus.BackgroundTransparency = 1
noteStatus.Text = "NOTE 1"
noteStatus.TextColor3 = TEXT
noteStatus.Font = Enum.Font.GothamBold
noteStatus.TextSize = 12
noteStatus.TextXAlignment = Enum.TextXAlignment.Left
noteStatus.ZIndex = 1070
noteStatus.Parent = notePage

local noteSave = makeButton(
	notePage,
	"NoteSave",
	UDim2.new(0.04,0,0,424),
	UDim2.new(0.21,0,0,38),
	"SAVE",
	Color3.fromRGB(70,170,100),
	1070
)

local noteCopy = makeButton(
	notePage,
	"NoteCopy",
	UDim2.new(0.27,0,0,424),
	UDim2.new(0.21,0,0,38),
	"COPY",
	BUTTON,
	1070
)

local notePaste = makeButton(
	notePage,
	"NotePaste",
	UDim2.new(0.50,0,0,424),
	UDim2.new(0.21,0,0,38),
	"PASTE",
	BUTTON,
	1070
)

local noteNew = makeButton(
	notePage,
	"NoteNew",
	UDim2.new(0.73,0,0,424),
	UDim2.new(0.23,0,0,38),
	"NEW",
	PURPLE,
	1070
)

local currentNote = 1

local function noteFile(index)
	return NOTE_PREFIX..tostring(index)..NOTE_EXT
end

local function loadNote(index)
	currentNote=index
	noteStatus.Text="NOTE "..tostring(index)

	local text=""

	pcall(function()
		if readfile and isfile and isfile(noteFile(index)) then
			text=readfile(noteFile(index))
		end
	end)

	noteEditor.Text=text
end

local function saveNote(index)
	pcall(function()
		if writefile then
			writefile(noteFile(index),noteEditor.Text)
		end
	end)

	noteStatus.Text="NOTE "..tostring(index).." SAVED"

	task.delay(1,function()
		if noteStatus and noteStatus.Parent then
			noteStatus.Text="NOTE "..tostring(currentNote)
		end
	end)
end

local function rebuildNotes()
	for _,child in ipairs(noteList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for i=1,20 do
		local exists=false

		pcall(function()
			if isfile then
				exists=isfile(noteFile(i))
			end
		end)

		if exists or i==1 then
			local b=makeButton(
				noteList,
				"Note"..i,
				UDim2.new(),
				UDim2.new(1,-10,0,38),
				"NOTE "..tostring(i),
				BUTTON,
				1070
			)

			b.LayoutOrder=i

			connect(b.Activated,function()
				loadNote(i)
			end)
		end
	end

	task.defer(function()
		noteList.CanvasSize=UDim2.fromOffset(0,noteLayout.AbsoluteContentSize.Y+8)
	end)
end

connect(noteSave.Activated,function()
	saveNote(currentNote)
	rebuildNotes()
end)

connect(noteCopy.Activated,function()
	pcall(function()
		if setclipboard then
			setclipboard(noteEditor.Text)
		end
	end)
end)

connect(notePaste.Activated,function()
	pcall(function()
		if getclipboard then
			noteEditor.Text=getclipboard()
		end
	end)
end)

connect(noteNew.Activated,function()
	for i=1,100 do
		local exists=false

		pcall(function()
			if isfile then
				exists=isfile(noteFile(i))
			end
		end)

		if not exists then
			loadNote(i)
			rebuildNotes()
			break
		end
	end
end)

addGradient(
	controlPage,
	Color3.fromRGB(22,22,32),
	Color3.fromRGB(42,25,58),
	Color3.fromRGB(22,22,32)
)

local controlTitle = Instance.new("TextLabel")
controlTitle.Position = UDim2.fromOffset(14,10)
controlTitle.Size = UDim2.new(1,-28,0,34)
controlTitle.BackgroundTransparency = 1
controlTitle.Text = "CONTROL"
controlTitle.TextColor3 = TEXT
controlTitle.Font = Enum.Font.GothamBold
controlTitle.TextSize = 18
controlTitle.TextXAlignment = Enum.TextXAlignment.Left
controlTitle.ZIndex = 1070
controlTitle.Parent = controlPage

local controllerToggle = makeButton(
	controlPage,
	"ControllerToggle",
	UDim2.fromOffset(14,52),
	UDim2.new(1,-28,0,44),
	"CONTROLLER : OFF",
	Color3.fromRGB(200,70,70),
	1070
)

local airTitle = Instance.new("TextLabel")
airTitle.Position = UDim2.fromOffset(14,112)
airTitle.Size = UDim2.new(1,-28,0,30)
airTitle.BackgroundTransparency = 1
airTitle.Text = "SETTING AIR CONTROL"
airTitle.TextColor3 = TEXT
airTitle.Font = Enum.Font.GothamBold
airTitle.TextSize = 13
airTitle.TextXAlignment = Enum.TextXAlignment.Left
airTitle.ZIndex = 1070
airTitle.Parent = controlPage

local airMinus = makeButton(
	controlPage,
	"AirMinus",
	UDim2.fromOffset(14,150),
	UDim2.fromOffset(70,42),
	"-",
	BUTTON,
	1070
)

local airValue = Instance.new("TextLabel")
airValue.Position = UDim2.new(.5,-70,0,150)
airValue.Size = UDim2.fromOffset(140,42)
airValue.BackgroundTransparency = 1
airValue.TextColor3 = TEXT
airValue.Font = Enum.Font.GothamBold
airValue.TextSize = 16
airValue.ZIndex = 1070
airValue.Parent = controlPage

local airPlus = makeButton(
	controlPage,
	"AirPlus",
	UDim2.new(1,-84,0,150),
	UDim2.fromOffset(70,42),
	"+",
	BUTTON,
	1070
)

local controlInfo = Instance.new("TextLabel")
controlInfo.Position = UDim2.fromOffset(14,210)
controlInfo.Size = UDim2.new(1,-28,0,90)
controlInfo.BackgroundTransparency = 1
controlInfo.Text = "W A S D menggunakan tombol controller sebelumnya. WLock tetap berada di luar silang WASD."
controlInfo.TextColor3 = Color3.fromRGB(180,180,190)
controlInfo.Font = Enum.Font.Gotham
controlInfo.TextSize = 12
controlInfo.TextWrapped = true
controlInfo.TextXAlignment = Enum.TextXAlignment.Left
controlInfo.TextYAlignment = Enum.TextYAlignment.Top
controlInfo.ZIndex = 1070
controlInfo.Parent = controlPage

local function updateController()
	controlsGui.Enabled=config.ControllerEnabled

	controllerToggle.Text=config.ControllerEnabled and "CONTROLLER : ON" or "CONTROLLER : OFF"

	controllerToggle.BackgroundColor3=
		config.ControllerEnabled
		and Color3.fromRGB(70,170,100)
		or Color3.fromRGB(200,70,70)

	if not config.ControllerEnabled then
		clearMovement()
	end
end

local function updateAir()
	config.AirControl=math.clamp(config.AirControl,0,100)
	airValue.Text=tostring(math.floor(config.AirControl)).."%"
end

connect(controllerToggle.Activated,function()
	config.ControllerEnabled=not config.ControllerEnabled
	updateController()
end)

connect(airMinus.Activated,function()
	config.AirControl=math.clamp(config.AirControl-5,0,100)
	updateAir()
end)

connect(airPlus.Activated,function()
	config.AirControl=math.clamp(config.AirControl+5,0,100)
	updateAir()
end)

addGradient(
	playerPage,
	Color3.fromRGB(22,22,32),
	Color3.fromRGB(42,25,58),
	Color3.fromRGB(22,22,32)
)

local playerTitle = Instance.new("TextLabel")
playerTitle.Position = UDim2.fromOffset(14,10)
playerTitle.Size = UDim2.new(1,-28,0,34)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "PLAYER"
playerTitle.TextColor3 = TEXT
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextSize = 18
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.ZIndex = 1070
playerTitle.Parent = playerPage

local spectateStatus = Instance.new("TextLabel")
spectateStatus.Position = UDim2.fromOffset(14,48)
spectateStatus.Size = UDim2.new(1,-28,0,30)
spectateStatus.BackgroundTransparency = 1
spectateStatus.Text = "SPECTATE : OFF"
spectateStatus.TextColor3 = TEXT
spectateStatus.Font = Enum.Font.GothamBold
spectateStatus.TextSize = 12
spectateStatus.TextXAlignment = Enum.TextXAlignment.Left
spectateStatus.ZIndex = 1070
spectateStatus.Parent = playerPage

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Position = UDim2.fromOffset(14,84)
playerList.Size = UDim2.new(1,-28,1,-98)
playerList.BackgroundColor3 = PANEL2
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new()
playerList.ZIndex = 1065
playerList.Parent = playerPage

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0,10)
playerListCorner.Parent = playerList

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,6)
playerLayout.Parent = playerList

local spectatingPlayer

local function restoreCamera()
	local camera=workspace.CurrentCamera

	if camera and humanoid and humanoid.Parent then
		camera.CameraType=Enum.CameraType.Custom
		camera.CameraSubject=humanoid
	end

	spectatingPlayer=nil
	spectateStatus.Text="SPECTATE : OFF"
end

local function spectate(target)
	local camera=workspace.CurrentCamera

	if not camera or not target then return end

	local targetHumanoid=target.Character and target.Character:FindFirstChildOfClass("Humanoid")

	if targetHumanoid then
		camera.CameraType=Enum.CameraType.Custom
		camera.CameraSubject=targetHumanoid
		spectatingPlayer=target
		spectateStatus.Text="SPECTATE : "..target.Name
	end
end

local function rebuildPlayers()
	for _,child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local players=Players:GetPlayers()

	table.sort(players,function(a,b)
		return a.Name:lower()<b.Name:lower()
	end)

	for _,p in ipairs(players) do
		if p~=player then
			local b=makeButton(
				playerList,
				p.Name,
				UDim2.new(),
				UDim2.new(1,-10,0,42),
				p.Name,
				BUTTON,
				1070
			)

			connect(b.Activated,function()
				if spectatingPlayer==p then
					restoreCamera()
				else
					spectate(p)
				end
			end)
		end
	end

	task.defer(function()
		playerList.CanvasSize=UDim2.fromOffset(0,playerLayout.AbsoluteContentSize.Y+8)
	end)
end

connect(Players.PlayerAdded,rebuildPlayers)

connect(Players.PlayerRemoving,function(p)
	if spectatingPlayer==p then
		restoreCamera()
	end

	rebuildPlayers()
end)

connect(openButton.InputBegan,function(input)
	if destroyed then return end

	local inputType=input.UserInputType

	if inputType==Enum.UserInputType.Touch
		or inputType==Enum.UserInputType.MouseButton1 then

		menuFrame.Visible=not menuFrame.Visible
	end
end)

connect(UserInputService.InputEnded,function(input)
	local t=input.UserInputType

	if t==Enum.UserInputType.Touch
		or t==Enum.UserInputType.MouseButton1 then

		for button in pairs(holding) do
			holding[button]=false
		end
	end
end)

local fpsFrames=0
local fpsTime=os.clock()
local fpsValue=0
local gradientObjects={}

local function collectGradients(root)
	for _,obj in ipairs(root:GetDescendants()) do
		if obj:IsA("UIGradient") then
			table.insert(gradientObjects,obj)
		end
	end
end

collectGradients(mainGui)
collectGradients(controlsGui)
collectGradients(shiftGui)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	local t=os.clock()*0.55
	local x=((t%2)-1)

	for _,g in ipairs(gradientObjects) do
		if g and g.Parent then
			g.Offset=Vector2.new(x,0)
		end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	fpsFrames+=1

	local now=os.clock()

	if now-fpsTime>=1 then
		fpsValue=fpsFrames
		fpsFrames=0
		fpsTime=now
	end

	if holding[moveUp] then
		applyMoveStep(0,-step)
	end

	if holding[moveDown] then
		applyMoveStep(0,step)
	end

	if holding[moveLeft] then
		applyMoveStep(-step,0)
	end

	if holding[moveRight] then
		applyMoveStep(step,0)
	end

	if character and character.Parent and humanoid and humanoid.Health>0 then
		updateCameraVectors()

		if config.ControllerEnabled then
			local movement=getMoveVector()
			local state=humanoid:GetState()

			if state==Enum.HumanoidStateType.Freefall
				or state==Enum.HumanoidStateType.Jumping then

				movement=movement*(math.clamp(config.AirControl,0,100)/100)
			end

			humanoid:Move(movement,false)
		end

		if _G.ShiftLocked then
			local camera=workspace.CurrentCamera
			local root=character:FindFirstChild("HumanoidRootPart")

			if camera and root then
				local _,y=camera.CFrame:ToOrientation()

				root.CFrame=
					CFrame.new(root.Position)*
					CFrame.Angles(0,y,0)
			end

			humanoid.AutoRotate=false
		else
			humanoid.AutoRotate=true
		end

		humanoid.CameraOffset=Vector3.zero
	end

	if menuFrame.Visible then
		local ping=0

		pcall(function()
			local item=Stats.Network.ServerStatsItem["Data Ping"]

			if item then
				local value=item:GetValueString()
				ping=tonumber(string.match(value,"%d+")) or 0
			end
		end)

		menuLabel.Text=
			"👾 AldoVz    PING : "..tostring(ping)..
			"    FPS : "..tostring(fpsValue)..
			"    CHECK : 0    SPEED : "..tostring(math.floor(config.WalkSpeed))
	end
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	clearMovement()

	character=newCharacter
	humanoid=newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
		applyWalkSpeed()
	end

	if spectatingPlayer then
		restoreCamera()
	end

	task.delay(.2,function()
		if not destroyed then
			updateJump()
			updateShift()
		end
	end)
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		jumpButton=nil

		task.delay(.2,function()
			if not destroyed then
				updateJump()
			end
		end)
	end
end)

local function applySensitivity()
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=config.Sensitivity
	end)
end

updateSpeedText()
config.ControllerEnabled=false
controlsGui.Enabled=false
updateController()
updateAir()
updateWLock()
updateShift()
updateJump()
applyWalkSpeed()
applySensitivity()
loadNote(1)
rebuildNotes()
rebuildPlayers()
selectPage("Main")
menuFrame.Visible=false
