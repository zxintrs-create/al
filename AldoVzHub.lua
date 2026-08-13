local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "AldoVzPremiumConfig.json"

local defaultConfig = {
	WalkSpeed = 16,
	JumpPower = 50,
	AirControl = 20,
	ControllerEnabled = false,
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1
}

local config = {}

for k,v in pairs(defaultConfig) do
	config[k] = v
end

pcall(function()
	if isfile and readfile and isfile(CONFIG_FILE) then
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

pcall(function()
	if writefile then
		writefile(CONFIG_FILE,HttpService:JSONEncode(config))
	end
end)

if _G.AldoVzPremiumCleanup then
	pcall(_G.AldoVzPremiumCleanup)
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
	for i = #connections,1,-1 do
		pcall(function()
			connections[i]:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyOld()
	local names = {
		"AldoVzPremium",
		"DeltaMobileControls",
		"DeltaMobileErgo"
	}

	for _,name in ipairs(names) do
		local obj = playerGui:FindFirstChild(name)
		if obj then
			pcall(function()
				obj:Destroy()
			end)
		end
	end
end

destroyOld()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoVzPremium"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local animationObjects = {}

local gradientColors = ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(0,170,255)),
	ColorSequenceKeypoint.new(.25,Color3.fromRGB(140,60,255)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,0,200)),
	ColorSequenceKeypoint.new(.75,Color3.fromRGB(140,60,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(0,170,255))
})

local function addGradient(object,rotation)
	local gradient = Instance.new("UIGradient")
	gradient.Color = gradientColors
	gradient.Rotation = rotation or 0
	gradient.Offset = Vector2.new(-1,0)
	gradient.Parent = object
	table.insert(animationObjects,gradient)
	return gradient
end

local function addStroke(object,thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 1.5
	stroke.Color = Color3.new(1,1,1)
	stroke.Transparency = .05
	stroke.Parent = object

	local gradient = Instance.new("UIGradient")
	gradient.Color = gradientColors
	gradient.Rotation = 0
	gradient.Offset = Vector2.new(-1,0)
	gradient.Parent = stroke

	table.insert(animationObjects,gradient)

	return stroke
end

local function round(object,radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,radius)
	c.Parent = object
	return c
end

local function animateGradient(gradient,speed)
	task.spawn(function()
		while gradient and gradient.Parent and not destroyed do
			gradient.Offset = Vector2.new(-1,0)

			local tween = TweenService:Create(
				gradient,
				TweenInfo.new(speed or 2.5,Enum.EasingStyle.Linear),
				{Offset = Vector2.new(1,0)}
			)

			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

for _,gradient in ipairs(animationObjects) do
	animateGradient(gradient,2.8)
end

local function makeFrame(parent,name,size,position,background,transparency,z)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = background or Color3.fromRGB(18,18,27)
	frame.BackgroundTransparency = transparency or 0
	frame.BorderSizePixel = 0
	frame.ZIndex = z or 10
	frame.Parent = parent

	round(frame,14)
	addGradient(frame,0)
	addStroke(frame,1.5)

	return frame
end

local function makeLabel(parent,name,size,position,text,textSize,z)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize or 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = z or 20
	label.Parent = parent

	addGradient(label,0)

	return label
end

local function makeButton(parent,name,size,position,text,z)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(25,25,38)
	button.BackgroundTransparency = .05
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 15
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = false
	button.ZIndex = z or 30
	button.Parent = parent

	round(button,10)
	addStroke(button,1.2)

	connect(button.MouseEnter,function()
		if button.Parent then
			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{BackgroundTransparency = 0}
			):Play()
		end
	end)

	connect(button.MouseLeave,function()
		if button.Parent then
			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{BackgroundTransparency = .05}
			):Play()
		end
	end)

	return button
end

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.AnchorPoint = Vector2.new(0,0)
openButton.Position = UDim2.new(0,12,0,42)
openButton.Size = UDim2.fromOffset(48,48)
openButton.BackgroundColor3 = Color3.fromRGB(18,18,27)
openButton.BackgroundTransparency = .05
openButton.BorderSizePixel = 0
openButton.Text = "☰"
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 24
openButton.AutoButtonColor = false
openButton.ZIndex = 100
openButton.Parent = screenGui

round(openButton,12)
addStroke(openButton,1.5)

local menu = Instance.new("Frame")
menu.Name = "MenuFrame"
menu.Size = UDim2.new(0,650,0,440)
menu.Position = UDim2.new(0,12,0,98)
menu.BackgroundColor3 = Color3.fromRGB(12,12,20)
menu.BackgroundTransparency = .04
menu.BorderSizePixel = 0
menu.Visible = false
menu.ZIndex = 10
menu.Parent = screenGui

round(menu,18)
addGradient(menu,0)
addStroke(menu,2)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,-20,0,54)
header.Position = UDim2.fromOffset(10,10)
header.BackgroundColor3 = Color3.fromRGB(20,20,32)
header.BackgroundTransparency = .05
header.BorderSizePixel = 0
header.ZIndex = 20
header.Parent = menu

round(header,12)
addGradient(header,0)
addStroke(header,1.5)

local headerLabel = makeLabel(
	header,
	"HeaderLabel",
	UDim2.new(1,-20,1,0),
	UDim2.fromOffset(10,0),
	"👾 AldoVz | PING : 0 | FPS : 0 | CHECK : 0 | SPEED : 16",
	14,
	30
)

local menuList = Instance.new("ScrollingFrame")
menuList.Name = "MenuList"
menuList.Size = UDim2.new(0,155,1,-78)
menuList.Position = UDim2.fromOffset(10,70)
menuList.BackgroundColor3 = Color3.fromRGB(16,16,26)
menuList.BackgroundTransparency = .05
menuList.BorderSizePixel = 0
menuList.ScrollBarThickness = 3
menuList.CanvasSize = UDim2.new(0,0,0,0)
menuList.ZIndex = 20
menuList.Parent = menu

round(menuList,12)
addStroke(menuList,1.2)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = menuList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0,10)
listPadding.PaddingBottom = UDim.new(0,10)
listPadding.Parent = menuList

local mainArea = Instance.new("Frame")
mainArea.Name = "MainArea"
mainArea.Size = UDim2.new(1,-180,1,-78)
mainArea.Position = UDim2.fromOffset(170,70)
mainArea.BackgroundColor3 = Color3.fromRGB(16,16,26)
mainArea.BackgroundTransparency = .05
mainArea.BorderSizePixel = 0
mainArea.ZIndex = 20
mainArea.Parent = menu

round(mainArea,12)
addGradient(mainArea,0)
addStroke(mainArea,1.5)

local mainTitle = makeLabel(
	mainArea,
	"MainTitle",
	UDim2.new(1,-20,0,35),
	UDim2.fromOffset(10,8),
	"MAIN",
	20,
	30
)

local mainInfo = makeLabel(
	mainArea,
	"MainInfo",
	UDim2.new(1,-20,0,28),
	UDim2.fromOffset(10,45),
	"FITUR IN MAIN FRAME",
	13,
	30
)

local function makeSectionButton(text,order)
	local b = makeButton(
		menuList,
		"Menu_"..text,
		UDim2.new(1,-20,0,45),
		UDim2.new(),
		text,
		30
	)
	b.LayoutOrder = order
	return b
end

local mainButton = makeSectionButton("MAIN",1)
local noteButton = makeSectionButton("NOTE",2)
local controlButton = makeSectionButton("CONTROL",3)
local playerButton = makeSectionButton("PLAYER",4)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFeatureFrame"
mainFrame.Size = UDim2.new(1,-20,1,-85)
mainFrame.Position = UDim2.fromOffset(10,75)
mainFrame.BackgroundTransparency = 1
mainFrame.ZIndex = 25
mainFrame.Parent = mainArea

local walkSpeedLabel = makeLabel(
	mainFrame,
	"WalkSpeedLabel",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,5),
	"WALK SPEED : 16",
	16,
	30
)

local walkMinus = makeButton(
	mainFrame,
	"WalkMinus",
	UDim2.fromOffset(70,38),
	UDim2.fromOffset(10,45),
	"-",
	30
)

local walkPlus = makeButton(
	mainFrame,
	"WalkPlus",
	UDim2.fromOffset(70,38),
	UDim2.fromOffset(90,45),
	"+",
	30
)

local jumpSetting = makeButton(
	mainFrame,
	"JumpSetting",
	UDim2.new(1,-180,0,42),
	UDim2.fromOffset(10,100),
	"JUMP SETTING",
	30
)

local shiftSetting = makeButton(
	mainFrame,
	"ShiftSetting",
	UDim2.new(1,-180,0,42),
	UDim2.fromOffset(10,150),
	"SHIFT LOCK",
	30
)

local controllerButton = makeButton(
	mainFrame,
	"Controller",
	UDim2.new(1,-20,0,42),
	UDim2.fromOffset(10,205),
	"CONTROLLER : OFF",
	30
)

local settingFrame = Instance.new("Frame")
settingFrame.Name = "JumpShiftSetting"
settingFrame.Size = UDim2.new(1,-20,0,170)
settingFrame.Position = UDim2.fromOffset(10,255)
settingFrame.BackgroundColor3 = Color3.fromRGB(22,22,34)
settingFrame.BorderSizePixel = 0
settingFrame.ZIndex = 30
settingFrame.Parent = mainFrame

round(settingFrame,12)
addGradient(settingFrame,0)
addStroke(settingFrame,1.2)

local targetLabel = makeLabel(
	settingFrame,
	"TargetLabel",
	UDim2.new(1,-20,0,28),
	UDim2.fromOffset(10,5),
	"PILIH SET : JUMP",
	14,
	35
)

local targetButton = makeButton(
	settingFrame,
	"Target",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,35),
	"JUMP",
	35
)

local leftButton = makeButton(settingFrame,"Left",UDim2.fromOffset(42,35),UDim2.fromOffset(10,78),"←",35)
local upButton = makeButton(settingFrame,"Up",UDim2.fromOffset(42,35),UDim2.fromOffset(58,78),"↑",35)
local downButton = makeButton(settingFrame,"Down",UDim2.fromOffset(42,35),UDim2.fromOffset(106,78),"↓",35)
local rightButton = makeButton(settingFrame,"Right",UDim2.fromOffset(42,35),UDim2.fromOffset(154,78),"→",35)

local sizePlus = makeButton(settingFrame,"SizePlus",UDim2.fromOffset(70,35),UDim2.new(1,-235,0,78),"SIZE +",35)
local sizeMinus = makeButton(settingFrame,"SizeMinus",UDim2.fromOffset(70,35),UDim2.new(1,-160,0,78),"SIZE -",35)
local resetButton = makeButton(settingFrame,"Reset",UDim2.fromOffset(70,35),UDim2.new(1,-85,0,78),"RESET 🔁",35)

local noteFrame = Instance.new("Frame")
noteFrame.Name = "NoteFrame"
noteFrame.Size = UDim2.new(1,-20,1,-20)
noteFrame.Position = UDim2.fromOffset(10,10)
noteFrame.BackgroundTransparency = 1
noteFrame.Visible = false
noteFrame.ZIndex = 25
noteFrame.Parent = mainArea

local noteTitle = makeLabel(noteFrame,"NoteTitle",UDim2.new(1,-20,0,35),UDim2.fromOffset(10,5),"NOTE",20,30)

local noteList = Instance.new("ScrollingFrame")
noteList.Name = "NoteList"
noteList.Size = UDim2.new(0,130,1,-55)
noteList.Position = UDim2.fromOffset(10,45)
noteList.BackgroundColor3 = Color3.fromRGB(22,22,34)
noteList.BorderSizePixel = 0
noteList.ScrollBarThickness = 3
noteList.ZIndex = 30
noteList.Parent = noteFrame

round(noteList,10)
addStroke(noteList,1.2)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,6)
noteLayout.Parent = noteList

local noteEditor = Instance.new("TextBox")
noteEditor.Name = "NoteEditor"
noteEditor.Size = UDim2.new(1,-155,0,230)
noteEditor.Position = UDim2.fromOffset(145,45)
noteEditor.BackgroundColor3 = Color3.fromRGB(22,22,34)
noteEditor.BorderSizePixel = 0
noteEditor.TextColor3 = Color3.new(1,1,1)
noteEditor.PlaceholderText = "Tulis catatan..."
noteEditor.PlaceholderColor3 = Color3.fromRGB(150,150,160)
noteEditor.Text = ""
noteEditor.TextSize = 14
noteEditor.Font = Enum.Font.Gotham
noteEditor.TextXAlignment = Enum.TextXAlignment.Left
noteEditor.TextYAlignment = Enum.TextYAlignment.Top
noteEditor.MultiLine = true
noteEditor.ClearTextOnFocus = false
noteEditor.ZIndex = 30
noteEditor.Parent = noteFrame

round(noteEditor,10)
addStroke(noteEditor,1.2)
addGradient(noteEditor,0)

local noteSave = makeButton(noteFrame,"SaveNote",UDim2.fromOffset(100,38),UDim2.new(1,-255,1,-48),"SAVE",35)
local noteNew = makeButton(noteFrame,"NewNote",UDim2.fromOffset(100,38),UDim2.new(1,-145,1,-48),"NEW",35)
local noteCopy = makeButton(noteFrame,"CopyNote",UDim2.fromOffset(100,38),UDim2.new(1,-35,1,-48),"COPY",35)

local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(1,-20,1,-20)
controlFrame.Position = UDim2.fromOffset(10,10)
controlFrame.BackgroundTransparency = 1
controlFrame.Visible = false
controlFrame.ZIndex = 25
controlFrame.Parent = mainArea

local controlTitle = makeLabel(controlFrame,"ControlTitle",UDim2.new(1,-20,0,35),UDim2.fromOffset(10,5),"CONTROL",20,30)

local controllerStatus = makeLabel(
	controlFrame,
	"ControllerStatus",
	UDim2.new(1,-20,0,35),
	UDim2.fromOffset(10,50),
	"CONTROLLER : OFF",
	16,
	30
)

local controlToggle = makeButton(
	controlFrame,
	"ControlToggle",
	UDim2.new(1,-20,0,45),
	UDim2.fromOffset(10,90),
	"OFF CONTROLLER W A S D",
	30
)

local airLabel = makeLabel(
	controlFrame,
	"AirControl",
	UDim2.new(1,-20,0,35),
	UDim2.fromOffset(10,145),
	"AIR CONTROL : 20",
	16,
	30
)

local airMinus = makeButton(controlFrame,"AirMinus",UDim2.fromOffset(70,38),UDim2.fromOffset(10,185),"-",30)
local airPlus = makeButton(controlFrame,"AirPlus",UDim2.fromOffset(70,38),UDim2.fromOffset(90,185),"+",30)

local playerFrame = Instance.new("Frame")
playerFrame.Name = "PlayerFrame"
playerFrame.Size = UDim2.new(1,-20,1,-20)
playerFrame.Position = UDim2.fromOffset(10,10)
playerFrame.BackgroundTransparency = 1
playerFrame.Visible = false
playerFrame.ZIndex = 25
playerFrame.Parent = mainArea

local playerTitle = makeLabel(playerFrame,"PlayerTitle",UDim2.new(1,-20,0,35),UDim2.fromOffset(10,5),"PLAYER / SPECTATE",20,30)

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1,-20,1,-55)
playerList.Position = UDim2.fromOffset(10,45)
playerList.BackgroundColor3 = Color3.fromRGB(22,22,34)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.ZIndex = 30
playerList.Parent = playerFrame

round(playerList,10)
addStroke(playerList,1.2)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,6)
playerLayout.Parent = playerList

local function setMainPage(page)
	mainFrame.Visible = page == "MAIN"
	noteFrame.Visible = page == "NOTE"
	controlFrame.Visible = page == "CONTROL"
	playerFrame.Visible = page == "PLAYER"
end

connect(mainButton.Activated,function()
	setMainPage("MAIN")
end)

connect(noteButton.Activated,function()
	setMainPage("NOTE")
end)

connect(controlButton.Activated,function()
	setMainPage("CONTROL")
end)

connect(playerButton.Activated,function()
	setMainPage("PLAYER")
end)

connect(openButton.Activated,function()
	menu.Visible = not menu.Visible
end)

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function applyCharacterSettings()
	if not humanoid then return end
	humanoid.WalkSpeed = config.WalkSpeed
	pcall(function()
		humanoid.JumpPower = config.JumpPower
	end)
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE,HttpService:JSONEncode(config))
		end
	end)
end

connect(walkMinus.Activated,function()
	config.WalkSpeed = math.max(1,config.WalkSpeed-1)
	applyCharacterSettings()
	walkSpeedLabel.Text = "WALK SPEED : "..config.WalkSpeed
	headerLabel.Text = "👾 AldoVz | PING : 0 | FPS : 0 | CHECK : 0 | SPEED : "..config.WalkSpeed
	saveConfig()
end)

connect(walkPlus.Activated,function()
	config.WalkSpeed += 1
	applyCharacterSettings()
	walkSpeedLabel.Text = "WALK SPEED : "..config.WalkSpeed
	headerLabel.Text = "👾 AldoVz | PING : 0 | FPS : 0 | CHECK : 0 | SPEED : "..config.WalkSpeed
	saveConfig()
end)

local shiftLocked = false

local shiftButton = Instance.new("ImageButton")
shiftButton.Name = "ShiftLockButton"
shiftButton.AnchorPoint = Vector2.new(.5,.5)
shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
shiftButton.Image = "rbxassetid://6031068426"
shiftButton.ImageColor3 = Color3.new(1,1,1)
shiftButton.BackgroundColor3 = Color3.new(1,1,1)
shiftButton.BackgroundTransparency = .2
shiftButton.AutoButtonColor = false
shiftButton.Visible = true
shiftButton.ZIndex = 100
shiftButton.Parent = screenGui

round(shiftButton,999)
addStroke(shiftButton,1.5)

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = Color3.new(1,1,1)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 110
crosshair.Parent = screenGui

round(crosshair,999)

local function toggleShiftLock()
	shiftLocked = not shiftLocked

	crosshair.Visible = shiftLocked

	if humanoid then
		humanoid.AutoRotate = not shiftLocked
	end

	if shiftLocked then
		shiftButton.BackgroundColor3 = Color3.fromRGB(170,0,255)
	else
		shiftButton.BackgroundColor3 = Color3.new(1,1,1)
	end
end

connect(shiftButton.Activated,toggleShiftLock)

connect(shiftSetting.Activated,function()
	targetSettingMode = "SHIFT"
	targetLabel.Text = "PILIH SET : SHIFTLOCK"
	targetButton.Text = "SHIFTLOCK"
	setMainPage("MAIN")
end)

connect(jumpSetting.Activated,function()
	targetSettingMode = "JUMP"
	targetLabel.Text = "PILIH SET : JUMP"
	targetButton.Text = "JUMP"
	setMainPage("MAIN")
end)

local targetSettingMode = "JUMP"

connect(targetButton.Activated,function()
	if targetSettingMode == "JUMP" then
		targetSettingMode = "SHIFT"
		targetLabel.Text = "PILIH SET : SHIFTLOCK"
		targetButton.Text = "SHIFTLOCK"
	else
		targetSettingMode = "JUMP"
		targetLabel.Text = "PILIH SET : JUMP"
		targetButton.Text = "JUMP"
	end
end)

local step = .02

local function updateJumpButton()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if not touchGui then return end

	local jump = touchGui:FindFirstChild("JumpButton",true)
	local camera = workspace.CurrentCamera

	if not jump or not camera then return end

	local size = math.max(40,math.floor(camera.ViewportSize.Y * config.JumpSize))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5,.5)
		jump.Position = UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size = UDim2.fromOffset(size,size)
	end)
end

local function updateShiftButton()
	shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function settingMove(dx,dy)
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJumpButton()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShiftButton()
	end
	saveConfig()
end

connect(leftButton.Activated,function()
	settingMove(-step,0)
end)

connect(rightButton.Activated,function()
	settingMove(step,0)
end)

connect(upButton.Activated,function()
	settingMove(0,-step)
end)

connect(downButton.Activated,function()
	settingMove(0,step)
end)

connect(sizePlus.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.5)
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
	end
	updateJumpButton()
	updateShiftButton()
	saveConfig()
end)

connect(sizeMinus.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.5)
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
	end
	updateJumpButton()
	updateShiftButton()
	saveConfig()
end)

connect(resetButton.Activated,function()
	if targetSettingMode == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
		config.JumpSize = defaultConfig.JumpSize
	else
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
		config.ShiftSize = defaultConfig.ShiftSize
	end

	updateJumpButton()
	updateShiftButton()
	saveConfig()
end)

local controllerFrame = Instance.new("Frame")
controllerFrame.Name = "ControllerFrame"
controllerFrame.Size = UDim2.fromOffset(310,310)
controllerFrame.Position = UDim2.new(0,18,1,-330)
controllerFrame.BackgroundTransparency = 1
controllerFrame.Visible = false
controllerFrame.ZIndex = 70
controllerFrame.Parent = screenGui

round(controllerFrame,18)
addStroke(controllerFrame,1.5)

local movement = {
	W = false,
	A = false,
	S = false,
	D = false
}

local function controllerButton(name,text,pos)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.fromOffset(82,82)
	b.Position = pos
	b.BackgroundColor3 = Color3.new(1,1,1)
	b.BackgroundTransparency = .15
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(20,20,25)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 28
	b.AutoButtonColor = false
	b.ZIndex = 80
	b.Parent = controllerFrame

	round(b,16)
	addStroke(b,1.5)

	return b
end

local btnW = controllerButton("W","▲",UDim2.fromOffset(114,10))
local btnA = controllerButton("A","◀",UDim2.fromOffset(20,104))
local btnS = controllerButton("S","▼",UDim2.fromOffset(114,104))
local btnD = controllerButton("D","▶",UDim2.fromOffset(208,104))

local wLock = controllerButton("WLock","W",UDim2.fromOffset(114,198))
wLock.Size = UDim2.fromOffset(82,82)

local function bindController(button,key)
	connect(button.InputBegan,function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		movement[key] = true
		button.BackgroundColor3 = Color3.fromRGB(70,150,255)
	end)

	connect(button.InputEnded,function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		movement[key] = false
		button.BackgroundColor3 = Color3.new(1,1,1)
	end)
end

bindController(btnW,"W")
bindController(btnA,"A")
bindController(btnS,"S")
bindController(btnD,"D")

local wLockEnabled = false

connect(wLock.Activated,function()
	wLockEnabled = not wLockEnabled
end)

connect(controlToggle.Activated,function()
	config.ControllerEnabled = not config.ControllerEnabled
	controllerFrame.Visible = config.ControllerEnabled

	if config.ControllerEnabled then
		controlToggle.Text = "ON CONTROLLER W A S D"
		controllerStatus.Text = "CONTROLLER : ON"
	else
		controlToggle.Text = "OFF CONTROLLER W A S D"
		controllerStatus.Text = "CONTROLLER : OFF"

		for k in pairs(movement) do
			movement[k] = false
		end
	end

	saveConfig()
end)

connect(controllerButton.Activated,function()
	config.ControllerEnabled = not config.ControllerEnabled
	controllerFrame.Visible = config.ControllerEnabled

	if config.ControllerEnabled then
		controllerButton.Text = "CONTROLLER : ON"
	else
		controllerButton.Text = "CONTROLLER : OFF"
	end

	saveConfig()
end)

local airControl = 20

connect(airMinus.Activated,function()
	airControl = math.max(0,airControl-1)
	airLabel.Text = "AIR CONTROL : "..airControl
end)

connect(airPlus.Activated,function()
	airControl += 1
	airLabel.Text = "AIR CONTROL : "..airControl
end)

local notes = {}
local currentNote = 1

local function noteFile(index)
	return "AldoVz_Note_"..index..".txt"
end

local function loadNote(index)
	local file = noteFile(index)

	pcall(function()
		if isfile and readfile and isfile(file) then
			notes[index] = readfile(file)
		end
	end)

	noteEditor.Text = notes[index] or ""
	currentNote = index
end

local function saveNote(index)
	notes[index] = noteEditor.Text

	pcall(function()
		if writefile then
			writefile(noteFile(index),noteEditor.Text)
		end
	end)
end

local function refreshNotes()
	for _,child in ipairs(noteList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local count = math.max(1,#notes)

	for i = 1,count do
		local b = makeButton(
			noteList,
			"Note"..i,
			UDim2.new(1,-10,0,38),
			UDim2.new(),
			"NOTE "..i,
			40
		)

		b.LayoutOrder = i

		connect(b.Activated,function()
			loadNote(i)
		end)
	end

	noteList.CanvasSize = UDim2.new(0,0,0,count*44+20)
end

connect(noteNew.Activated,function()
	local index = #notes+1
	notes[index] = ""
	refreshNotes()
	loadNote(index)
end)

connect(noteSave.Activated,function()
	saveNote(currentNote)
end)

connect(noteCopy.Activated,function()
	pcall(function()
		if setclipboard then
			setclipboard(noteEditor.Text)
		end
	end)
end)

refreshNotes()
loadNote(1)

local function refreshPlayers()
	for _,child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _,target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local b = makeButton(
				playerList,
				target.Name,
				UDim2.new(1,-10,0,42),
				UDim2.new(),
				target.Name,
				40
			)

			b.LayoutOrder = #playerList:GetChildren()

			connect(b.Activated,function()
				local targetCharacter = target.Character
				local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

				if targetHumanoid then
					workspace.CurrentCamera.CameraSubject = targetHumanoid
				end
			end)
		end
	end

	playerList.CanvasSize = UDim2.new(0,0,0,#Players:GetPlayers()*48+20)
end

connect(Players.PlayerAdded,refreshPlayers)
connect(Players.PlayerRemoving,refreshPlayers)

refreshPlayers()

local function getPing()
	local ping = 0

	pcall(function()
		local network = Stats.Network
		local serverStats = network.ServerStatsItem
		local dataPing = serverStats["Data Ping"]
		if dataPing then
			ping = math.floor(dataPing:GetValue())
		end
	end)

	return ping
end

local fpsTime = os.clock()
local fpsFrames = 0
local fps = 0

connect(RunService.RenderStepped,function(dt)
	if destroyed then return end

	fpsFrames += 1

	if os.clock()-fpsTime >= 1 then
		fps = fpsFrames
		fpsFrames = 0
		fpsTime = os.clock()
	end

	local ping = getPing()

	headerLabel.Text =
		"👾 AldoVz | PING : "..ping..
		" | FPS : "..fps..
		" | CHECK : 0 | SPEED : "..config.WalkSpeed

	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = config.WalkSpeed

		local camera = workspace.CurrentCamera

		local x = 0
		local z = 0

		if config.ControllerEnabled then
			if movement.W then z += 1 end
			if movement.S then z -= 1 end
			if movement.A then x -= 1 end
			if movement.D then x += 1 end

			if x == 0 and z == 0 and wLockEnabled then
				z = 1
			end
		end

		if camera and (x ~= 0 or z ~= 0) then
			local forward = Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)
			local right = Vector3.new(camera.CFrame.RightVector.X,0,camera.CFrame.RightVector.Z)

			if forward.Magnitude > .001 then
				forward = forward.Unit
			end

			if right.Magnitude > .001 then
				right = right.Unit
			end

			local move = right*x + forward*z

			if move.Magnitude > .001 then
				local control = humanoid.FloorMaterial == Enum.Material.Air and math.clamp(airControl/20,0,1) or 1
				humanoid:Move(move.Unit*control,false)
			end
		elseif config.ControllerEnabled and humanoid.FloorMaterial == Enum.Material.Air and airControl > 0 then
			humanoid:Move(Vector3.zero,false)
		end

		if shiftLocked and camera then
			local root = character:FindFirstChild("HumanoidRootPart")

			if root then
				local _,y = camera.CFrame:ToOrientation()
				root.CFrame = CFrame.new(root.Position)*CFrame.Angles(0,y,0)
			end

			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
		end
	end
end)

connect(player.CharacterAdded,function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		applyCharacterSettings()
		humanoid.AutoRotate = not shiftLocked
	end

	task.wait(.5)
	updateJumpButton()
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		task.wait(.2)
		updateJumpButton()
	end
end)

applyCharacterSettings()
updateJumpButton()
updateShiftButton()

controllerFrame.Visible = config.ControllerEnabled
controllerButton.Text = config.ControllerEnabled and "CONTROLLER : ON" or "CONTROLLER : OFF"
controlToggle.Text = config.ControllerEnabled and "ON CONTROLLER W A S D" or "OFF CONTROLLER W A S D"
controllerStatus.Text = config.ControllerEnabled and "CONTROLLER : ON" or "CONTROLLER : OFF"

setMainPage("MAIN")

_G.AldoVzPremiumCleanup = function()
	if destroyed then return end
	destroyed = true
	disconnectAll()

	pcall(function()
		screenGui:Destroy()
	end)
end
