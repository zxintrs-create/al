local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "AldoVzPremiumConfig.json"
local NOTE_FILE_PREFIX = "AldoVzNote_"

local defaultConfig = {
	WalkSpeed = 16,
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1,
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

_G.AldoVzPremiumCleanup = function()
	if destroyed then
		return
	end

	destroyed = true
	disconnectAll()

	destroyGui("AldoVzPremium")
	destroyGui("AldoVzController")

	pcall(function()
		if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
			local h = player.Character:FindFirstChildOfClass("Humanoid")
			h.AutoRotate = true
			h.CameraOffset = Vector3.zero
		end
	end)
end

destroyGui("AldoVzPremium")
destroyGui("AldoVzController")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local MAIN = Color3.fromRGB(13,14,25)
local PANEL = Color3.fromRGB(19,20,34)
local PANEL2 = Color3.fromRGB(25,26,43)
local BUTTON = Color3.fromRGB(29,30,48)
local WHITE = Color3.fromRGB(245,245,255)
local PURPLE = Color3.fromRGB(170,45,255)
local BLUE = Color3.fromRGB(45,135,255)
local RED = Color3.fromRGB(220,65,75)
local GREEN = Color3.fromRGB(60,205,110)

local controllerState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false
}

local activeTouches = {}
local holdingSettings = {}

local shiftLocked = false
local targetSetting = "JUMP"
local currentPage = "MAIN"
local controllerEnabled = config.ControllerEnabled == true
local jumpButton
local spectating = nil

local function makeCorner(obj,radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,radius)
	c.Parent = obj
	return c
end

local function makeStroke(obj)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = WHITE
	stroke.Transparency = 0.05
	stroke.Parent = obj

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(.25,Color3.fromRGB(170,70,255)),
		ColorSequenceKeypoint.new(.5,Color3.fromRGB(50,180,255)),
		ColorSequenceKeypoint.new(.75,Color3.fromRGB(190,50,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
	})
	gradient.Rotation = 0
	gradient.Parent = stroke

	task.spawn(function()
		while gradient.Parent and not destroyed do
			gradient.Offset = Vector2.new(-1,0)
			local tw = TweenService:Create(
				gradient,
				TweenInfo.new(2.2,Enum.EasingStyle.Linear),
				{Offset = Vector2.new(1,0)}
			)
			tw:Play()
			tw.Completed:Wait()
		end
	end)

	return stroke
end

local function makeButton(parent,name,text,pos,size)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Position = pos
	b.Size = size
	b.BackgroundColor3 = BUTTON
	b.BackgroundTransparency = .04
	b.TextColor3 = WHITE
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.Parent = parent
	makeCorner(b,10)
	makeStroke(b)

	connect(b.MouseEnter,function()
		if b.Parent then
			TweenService:Create(b,TweenInfo.new(.15),{
				BackgroundColor3 = Color3.fromRGB(42,43,67)
			}):Play()
		end
	end)

	connect(b.MouseLeave,function()
		if b.Parent then
			TweenService:Create(b,TweenInfo.new(.15),{
				BackgroundColor3 = BUTTON
			}):Play()
		end
	end)

	return b
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoVzPremium"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.AnchorPoint = Vector2.new(0,0)
openButton.Position = UDim2.fromOffset(90,82)
openButton.Size = UDim2.fromOffset(58,58)
openButton.Text = "☰"
openButton.TextColor3 = WHITE
openButton.TextSize = 26
openButton.Font = Enum.Font.GothamBold
openButton.BackgroundColor3 = MAIN
openButton.BorderSizePixel = 0
openButton.AutoButtonColor = false
openButton.Parent = screenGui
makeCorner(openButton,14)
makeStroke(openButton)

local header = Instance.new("Frame")
header.Name = "MenuHeader"
header.Position = UDim2.fromOffset(84,150)
header.Size = UDim2.new(0,800,0,72)
header.BackgroundColor3 = MAIN
header.BorderSizePixel = 0
header.Visible = false
header.Parent = screenGui
makeCorner(header,15)
makeStroke(header)

local headerScale = Instance.new("UIScale")
headerScale.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18,7)
title.Size = UDim2.fromOffset(170,28)
title.Text = "👾 AldoVz"
title.TextColor3 = WHITE
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = header

local pingLabel = Instance.new("TextLabel")
pingLabel.BackgroundTransparency = 1
pingLabel.Position = UDim2.fromOffset(185,7)
pingLabel.Size = UDim2.fromOffset(120,28)
pingLabel.Text = "PING : 0"
pingLabel.TextColor3 = WHITE
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 13
pingLabel.Parent = header

local fpsLabel = Instance.new("TextLabel")
fpsLabel.BackgroundTransparency = 1
fpsLabel.Position = UDim2.fromOffset(310,7)
fpsLabel.Size = UDim2.fromOffset(120,28)
fpsLabel.Text = "FPS : 0"
fpsLabel.TextColor3 = WHITE
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = header

local checkLabel = Instance.new("TextLabel")
checkLabel.BackgroundTransparency = 1
checkLabel.Position = UDim2.fromOffset(430,7)
checkLabel.Size = UDim2.fromOffset(130,28)
checkLabel.Text = "CHECK : 0"
checkLabel.TextColor3 = WHITE
checkLabel.Font = Enum.Font.GothamBold
checkLabel.TextSize = 13
checkLabel.Parent = header

local speedLabel = Instance.new("TextLabel")
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.fromOffset(560,7)
speedLabel.Size = UDim2.fromOffset(120,28)
speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
speedLabel.TextColor3 = WHITE
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 13
speedLabel.Parent = header

local commandBox = Instance.new("TextBox")
commandBox.Name = "InfiniteYieldCommand"
commandBox.Position = UDim2.fromOffset(185,39)
commandBox.Size = UDim2.fromOffset(480,25)
commandBox.BackgroundColor3 = Color3.fromRGB(8,9,17)
commandBox.BorderSizePixel = 0
commandBox.Text = ""
commandBox.PlaceholderText = "COMMAND INFINITE YIEL :_____________:"
commandBox.PlaceholderColor3 = Color3.fromRGB(130,130,150)
commandBox.TextColor3 = WHITE
commandBox.Font = Enum.Font.Code
commandBox.TextSize = 12
commandBox.ClearTextOnFocus = false
commandBox.Parent = header
makeCorner(commandBox,7)

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Position = UDim2.fromOffset(84,228)
menuFrame.Size = UDim2.new(0,800,0,540)
menuFrame.BackgroundColor3 = MAIN
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui
makeCorner(menuFrame,16)
makeStroke(menuFrame)

local menuList = Instance.new("Frame")
menuList.Name = "MenuList"
menuList.Position = UDim2.fromOffset(12,12)
menuList.Size = UDim2.new(0,180,1,-24)
menuList.BackgroundColor3 = PANEL
menuList.BorderSizePixel = 0
menuList.Parent = menuFrame
makeCorner(menuList,13)
makeStroke(menuList)

local menuTitle = Instance.new("TextLabel")
menuTitle.BackgroundTransparency = 1
menuTitle.Position = UDim2.fromOffset(14,12)
menuTitle.Size = UDim2.new(1,-28,0,32)
menuTitle.Text = "MENU"
menuTitle.TextColor3 = WHITE
menuTitle.TextXAlignment = Enum.TextXAlignment.Left
menuTitle.Font = Enum.Font.GothamBold
menuTitle.TextSize = 17
menuTitle.Parent = menuList

local menuScroll = Instance.new("ScrollingFrame")
menuScroll.Name = "UIScrollingButton"
menuScroll.Position = UDim2.fromOffset(10,52)
menuScroll.Size = UDim2.new(1,-20,1,-62)
menuScroll.BackgroundTransparency = 1
menuScroll.BorderSizePixel = 0
menuScroll.ScrollBarThickness = 3
menuScroll.CanvasSize = UDim2.fromOffset(0,0)
menuScroll.Parent = menuList

local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0,9)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menuScroll

local mainArea = Instance.new("Frame")
mainArea.Name = "MainFrame"
mainArea.Position = UDim2.fromOffset(204,12)
mainArea.Size = UDim2.new(1,-216,1,-24)
mainArea.BackgroundColor3 = PANEL
mainArea.BorderSizePixel = 0
mainArea.Parent = menuFrame
makeCorner(mainArea,13)
makeStroke(mainArea)

local pageTitle = Instance.new("TextLabel")
pageTitle.Name = "PageTitle"
pageTitle.BackgroundTransparency = 1
pageTitle.Position = UDim2.fromOffset(18,12)
pageTitle.Size = UDim2.new(1,-36,0,34)
pageTitle.Text = "MAIN"
pageTitle.TextColor3 = WHITE
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 19
pageTitle.Parent = mainArea

local pageContainer = Instance.new("Frame")
pageContainer.Name = "PageContainer"
pageContainer.Position = UDim2.fromOffset(12,54)
pageContainer.Size = UDim2.new(1,-24,1,-66)
pageContainer.BackgroundTransparency = 1
pageContainer.Parent = mainArea

local pages = {}

local function newPage(name)
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name
	frame.Size = UDim2.fromScale(1,1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ScrollBarThickness = 4
	frame.Visible = false
	frame.CanvasSize = UDim2.fromOffset(0,0)
	frame.Parent = pageContainer

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"),function()
		frame.CanvasSize = UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+20)
	end)

	pages[name] = frame
	return frame
end

local mainPage = newPage("MAIN")
local notePage = newPage("NOTE")
local controlPage = newPage("CONTROL")
local playerPage = newPage("PLAYER")
local settingPage = newPage("SETTING")

local function section(parent,height)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,height)
	f.BackgroundColor3 = PANEL2
	f.BorderSizePixel = 0
	f.Parent = parent
	makeCorner(f,12)
	makeStroke(f)
	return f
end

local function label(parent,text,pos,size)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = pos
	l.Size = size
	l.Text = text
	l.TextColor3 = WHITE
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local speedSection = section(mainPage,100)
label(speedSection,"WALK SPEED",UDim2.fromOffset(16,12),UDim2.fromOffset(200,25))

local speedMinus = makeButton(speedSection,"Minus","-",UDim2.fromOffset(14,45),UDim2.fromOffset(55,40))
local speedValue = label(speedSection,tostring(config.WalkSpeed),UDim2.new(.5,-50,0,45),UDim2.fromOffset(100,40))
speedValue.TextXAlignment = Enum.TextXAlignment.Center
speedValue.TextSize = 17

local speedPlus = makeButton(speedSection,"Plus","+",UDim2.new(1,-69,0,45),UDim2.fromOffset(55,40))

local shiftSection = section(mainPage,300)
label(shiftSection,"SETTING SHIFTLOCK / JUMP",UDim2.fromOffset(16,12),UDim2.fromOffset(300,25))

local targetButton = makeButton(
	shiftSection,
	"Target",
	"← ↑ ↓ →    PILIH SET : JUMP",
	UDim2.fromOffset(14,42),
	UDim2.new(1,-28,0,40)
)
targetButton.BackgroundColor3 = BLUE

local upButton = makeButton(shiftSection,"Up","↑",UDim2.new(.5,-30,0,91),UDim2.fromOffset(60,42))
local leftButton = makeButton(shiftSection,"Left","←",UDim2.new(.28,-30,0,140),UDim2.fromOffset(60,42))
local rightButton = makeButton(shiftSection,"Right","→",UDim2.new(.72,-30,0,140),UDim2.fromOffset(60,42))
local downButton = makeButton(shiftSection,"Down","↓",UDim2.new(.5,-30,0,189),UDim2.fromOffset(60,42))

local sizePlus = makeButton(shiftSection,"SizePlus","SIZE +",UDim2.fromOffset(14,245),UDim2.fromOffset(90,40))
local resetButton = makeButton(shiftSection,"Reset","RESET 🔄",UDim2.new(.5,-45,0,245),UDim2.fromOffset(90,40))
local sizeMinus = makeButton(shiftSection,"SizeMinus","SIZE -",UDim2.new(1,-104,0,245),UDim2.fromOffset(90,40))

local jumpObject

local function getJumpButton()
	if jumpObject and jumpObject.Parent then
		return jumpObject
	end

	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then
		jumpObject = touchGui:FindFirstChild("JumpButton",true)
	end

	return jumpObject
end

local function updateJump()
	local jump = getJumpButton()
	local camera = workspace.CurrentCamera

	if not jump or not camera then
		return
	end

	local viewport = camera.ViewportSize
	local size = math.max(40,math.floor(viewport.Y * math.clamp(config.JumpSize,.05,.5)))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5,.5)
		jump.Position = UDim2.new(
			math.clamp(config.JumpX,.05,.95),
			0,
			math.clamp(config.JumpY,.05,.95),
			0
		)
		jump.Size = UDim2.fromOffset(size,size)
	end)
end

local shiftLockButton = Instance.new("ImageButton")
shiftLockButton.Name = "ShiftLockButton"
shiftLockButton.AnchorPoint = Vector2.new(.5,.5)
shiftLockButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
shiftLockButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
shiftLockButton.Image = "rbxassetid://6031068426"
shiftLockButton.ImageColor3 = WHITE
shiftLockButton.BackgroundColor3 = WHITE
shiftLockButton.BackgroundTransparency = .2
shiftLockButton.AutoButtonColor = false
shiftLockButton.Active = true
shiftLockButton.Selectable = false
shiftLockButton.BorderSizePixel = 0
shiftLockButton.Visible = true
shiftLockButton.Parent = screenGui
makeCorner(shiftLockButton,99)
makeStroke(shiftLockButton)

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = WHITE
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.Parent = screenGui
makeCorner(crosshair,99)

local function updateShiftButton()
	shiftLockButton.BackgroundColor3 = shiftLocked and Color3.fromRGB(170,0,255) or WHITE
	crosshair.Visible = shiftLocked
end

local function toggleShift()
	shiftLocked = not shiftLocked
	updateShiftButton()

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not shiftLocked
		humanoid.CameraOffset = Vector3.zero
	end
end

connect(shiftLockButton.Activated,toggleShift)

local function updateShift()
	shiftLockButton.Position = UDim2.new(
		math.clamp(config.ShiftX,.02,.98),
		0,
		math.clamp(config.ShiftY,.02,.98),
		0
	)

	shiftLockButton.Size = UDim2.fromOffset(
		math.clamp(config.ShiftSize,20,100),
		math.clamp(config.ShiftSize,20,100)
	)
end

local function moveSetting(dx,dy)
	if targetSetting == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	end
end

local function changeTarget()
	if targetSetting == "JUMP" then
		targetSetting = "SHIFT"
		targetButton.Text = "← ↑ ↓ →    PILIH SET : SHIFTLOCK"
		targetButton.BackgroundColor3 = PURPLE
	else
		targetSetting = "JUMP"
		targetButton.Text = "← ↑ ↓ →    PILIH SET : JUMP"
		targetButton.BackgroundColor3 = BLUE
	end
end

connect(targetButton.Activated,changeTarget)
connect(upButton.Activated,function() moveSetting(0,-.018) end)
connect(downButton.Activated,function() moveSetting(0,.018) end)
connect(leftButton.Activated,function() moveSetting(-.018,0) end)
connect(rightButton.Activated,function() moveSetting(.018,0) end)

connect(sizePlus.Activated,function()
	if targetSetting == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if targetSetting == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(resetButton.Activated,function()
	if targetSetting == "JUMP" then
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
end)

local function applySpeed()
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = config.WalkSpeed
	end
	speedValue.Text = tostring(config.WalkSpeed)
	speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
end

connect(speedMinus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed-1,1,200)
	applySpeed()
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed+1,1,200)
	applySpeed()
end)

local noteList = Instance.new("ScrollingFrame")
noteList.Name = "NoteList"
noteList.Size = UDim2.new(1,0,0,125)
noteList.BackgroundColor3 = PANEL2
noteList.BorderSizePixel = 0
noteList.ScrollBarThickness = 3
noteList.Parent = notePage
makeCorner(noteList,12)
makeStroke(noteList)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,6)
noteLayout.Parent = noteList

local noteEditor = Instance.new("TextBox")
noteEditor.Name = "NoteEditor"
noteEditor.Size = UDim2.new(1,0,0,180)
noteEditor.BackgroundColor3 = PANEL2
noteEditor.BorderSizePixel = 0
noteEditor.Text = ""
noteEditor.PlaceholderText = "Tulis catatan di sini..."
noteEditor.PlaceholderColor3 = Color3.fromRGB(120,120,140)
noteEditor.TextColor3 = WHITE
noteEditor.TextXAlignment = Enum.TextXAlignment.Left
noteEditor.TextYAlignment = Enum.TextYAlignment.Top
noteEditor.TextWrapped = true
noteEditor.MultiLine = true
noteEditor.ClearTextOnFocus = false
noteEditor.Font = Enum.Font.Gotham
noteEditor.TextSize = 14
noteEditor.Parent = notePage
makeCorner(noteEditor,12)
makeStroke(noteEditor)

local noteName = Instance.new("TextBox")
noteName.Size = UDim2.new(1,-170,0,42)
noteName.BackgroundColor3 = PANEL2
noteName.BorderSizePixel = 0
noteName.Text = "1"
noteName.TextColor3 = WHITE
noteName.PlaceholderText = "Nama file"
noteName.Font = Enum.Font.Gotham
noteName.TextSize = 14
noteName.Parent = notePage
makeCorner(noteName,10)
makeStroke(noteName)

local noteSave = makeButton(notePage,"SaveNote","SAVE FILE",UDim2.new(1,-155,0,0),UDim2.fromOffset(155,42))

local function notePath(id)
	return NOTE_FILE_PREFIX..tostring(id)..".txt"
end

local function loadNote(id)
	local text = ""
	pcall(function()
		if readfile and isfile and isfile(notePath(id)) then
			text = readfile(notePath(id))
		end
	end)
	noteEditor.Text = text
end

local function refreshNotes()
	for _,obj in ipairs(noteList:GetChildren()) do
		if obj:IsA("TextButton") then
			obj:Destroy()
		end
	end

	local found = {}

	pcall(function()
		if listfiles then
			for _,path in ipairs(listfiles("")) do
				if string.find(path,NOTE_FILE_PREFIX,1,true) then
					table.insert(found,path)
				end
			end
		end
	end)

	table.sort(found)

	for _,path in ipairs(found) do
		local id = string.match(path,NOTE_FILE_PREFIX.."(.+)%.txt")
		if id then
			local b = makeButton(noteList,"Note_"..id,"FILE "..id,UDim2.fromOffset(0,0),UDim2.new(1,-6,0,36))
			b.Parent = noteList
			connect(b.Activated,function()
				noteName.Text = id
				loadNote(id)
			end)
		end
	end

	noteList.CanvasSize = UDim2.fromOffset(0,#found*42+8)
end

connect(noteSave.Activated,function()
	local id = noteName.Text
	if id == "" then
		id = "1"
	end

	pcall(function()
		if writefile then
			writefile(notePath(id),noteEditor.Text)
		end
	end)

	refreshNotes()
end)

local controllerSection = section(controlPage,210)

label(controllerSection,"CONTROL",UDim2.fromOffset(16,12),UDim2.fromOffset(200,25))

local controllerToggle = makeButton(
	controllerSection,
	"ControllerToggle",
	"CONTROLLER : OFF",
	UDim2.fromOffset(16,50),
	UDim2.new(1,-32,0,50)
)

controllerToggle.BackgroundColor3 = RED

local airLabel = label(
	controllerSection,
	"SETTING AIR CONTROL : "..tostring(config.AirControl),
	UDim2.fromOffset(16,115),
	UDim2.new(1,-32,0,25)
)

local airMinus = makeButton(
	controllerSection,
	"AirMinus",
	"-",
	UDim2.fromOffset(16,150),
	UDim2.fromOffset(65,40)
)

local airPlus = makeButton(
	controllerSection,
	"AirPlus",
	"+",
	UDim2.fromOffset(91,150),
	UDim2.fromOffset(65,40)
)

local airReset = makeButton(
	controllerSection,
	"AirReset",
	"RESET",
	UDim2.fromOffset(166,150),
	UDim2.fromOffset(90,40)
)

local function updateControllerButton()
	if controllerEnabled then
		controllerToggle.Text = "CONTROLLER : ON"
		controllerToggle.BackgroundColor3 = GREEN
	else
		controllerToggle.Text = "CONTROLLER : OFF"
		controllerToggle.BackgroundColor3 = RED
	end
end

connect(controllerToggle.Activated,function()
	controllerEnabled = not controllerEnabled
	config.ControllerEnabled = controllerEnabled
	updateControllerButton()
end)

connect(airMinus.Activated,function()
	config.AirControl = math.clamp(config.AirControl-1,0,100)
	airLabel.Text = "SETTING AIR CONTROL : "..tostring(config.AirControl)
end)

connect(airPlus.Activated,function()
	config.AirControl = math.clamp(config.AirControl+1,0,100)
	airLabel.Text = "SETTING AIR CONTROL : "..tostring(config.AirControl)
end)

connect(airReset.Activated,function()
	config.AirControl = defaultConfig.AirControl
	airLabel.Text = "SETTING AIR CONTROL : "..tostring(config.AirControl)
end)

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1,0,1,0)
playerList.BackgroundTransparency = 1
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.Parent = playerPage

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,8)
playerLayout.Parent = playerList

local stopSpectate = makeButton(
	playerPage,
	"StopSpectate",
	"STOP SPECTATE",
	UDim2.new(1,-170,0,0),
	UDim2.fromOffset(170,40)
)

stopSpectate.Visible = false

local function stopSpectating()
	spectating = nil
	stopSpectate.Visible = false

	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

connect(stopSpectate.Activated,stopSpectating)

local function refreshPlayers()
	for _,obj in ipairs(playerList:GetChildren()) do
		if obj:IsA("TextButton") then
			obj:Destroy()
		end
	end

	for _,plr in ipairs(Players:GetPlayers()) do
		local b = makeButton(
			playerList,
			"Player_"..plr.UserId,
			plr.Name.."  |  "..plr.DisplayName,
			UDim2.fromOffset(0,0),
			UDim2.new(1,-6,0,44)
		)

		b.Parent = playerList

		connect(b.Activated,function()
			if plr.Character then
				local targetHumanoid = plr.Character:FindFirstChildOfClass("Humanoid")
				local camera = workspace.CurrentCamera

				if targetHumanoid and camera then
					spectating = plr
					camera.CameraType = Enum.CameraType.Custom
					camera.CameraSubject = targetHumanoid
					stopSpectate.Visible = true
				end
			end
		end)
	end

	playerList.CanvasSize = UDim2.fromOffset(0,#Players:GetPlayers()*52+20)
end

local settingInfo = section(settingPage,190)

label(settingInfo,"SETTING",UDim2.fromOffset(16,12),UDim2.fromOffset(200,25))

local sensitivityLabel = label(
	settingInfo,
	"SENSITIVITY : "..string.format("%.1f",config.Sensitivity).."x",
	UDim2.fromOffset(16,52),
	UDim2.new(1,-32,0,25)
)

local sensitivityMinus = makeButton(settingInfo,"SensitivityMinus","-",UDim2.fromOffset(16,90),UDim2.fromOffset(65,42))
local sensitivityReset = makeButton(settingInfo,"SensitivityReset","RESET",UDim2.fromOffset(91,90),UDim2.fromOffset(90,42))
local sensitivityPlus = makeButton(settingInfo,"SensitivityPlus","+",UDim2.fromOffset(187,90),UDim2.fromOffset(65,42))

local saveAll = makeButton(
	settingPage,
	"SaveAll",
	"SAVE CONFIG",
	UDim2.fromOffset(0,0),
	UDim2.new(1,0,0,45)
)

local function applySensitivity()
	sensitivityLabel.Text = "SENSITIVITY : "..string.format("%.1f",config.Sensitivity).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

connect(sensitivityMinus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity-.1,.1,10)
	applySensitivity()
end)

connect(sensitivityPlus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity+.1,.1,10)
	applySensitivity()
end)

connect(sensitivityReset.Activated,function()
	config.Sensitivity = 1
	applySensitivity()
end)

connect(saveAll.Activated,function()
	saveConfig()
	saveAll.Text = "SAVED!"
	task.delay(1,function()
		if saveAll.Parent then
			saveAll.Text = "SAVE CONFIG"
		end
	end)
end)

local menuButtons = {}

local function createMenuButton(name,text,page)
	local b = makeButton(
		menuScroll,
		name,
		text,
		UDim2.fromOffset(0,0),
		UDim2.new(1,-4,0,48)
	)

	b.LayoutOrder = #menuButtons+1
	b.Parent = menuScroll

	table.insert(menuButtons,{button=b,page=page,name=name})

	connect(b.Activated,function()
		currentPage = page

		for _,data in ipairs(menuButtons) do
			data.button.BackgroundColor3 = BUTTON
		end

		b.BackgroundColor3 = PURPLE

		for name2,frame in pairs(pages) do
			frame.Visible = name2 == page
		end

		pageTitle.Text = page
	end)

	return b
end

local mainMenuButton = createMenuButton("MainButton","MAIN","MAIN")
createMenuButton("NoteButton","NOTE","NOTE")
createMenuButton("ControlButton","CONTROL","CONTROL")
createMenuButton("PlayerButton","PLAYER","PLAYER")
createMenuButton("SettingButton","SETTING","SETTING")

mainMenuButton.BackgroundColor3 = PURPLE

local closeButton = makeButton(
	menuScroll,
	"CloseButton",
	"CLOSE",
	UDim2.fromOffset(0,0),
	UDim2.new(1,-4,0,48)
)

closeButton.LayoutOrder = 99

local function setMenuVisible(state)
	header.Visible = state
	menuFrame.Visible = state

	if state then
		openButton.Text = "×"
	else
		openButton.Text = "☰"
	end
end

connect(openButton.Activated,function()
	setMenuVisible(not menuFrame.Visible)
end)

connect(closeButton.Activated,function()
	setMenuVisible(false)
end)

local controllerGui = Instance.new("ScreenGui")
controllerGui.Name = "AldoVzController"
controllerGui.ResetOnSpawn = false
controllerGui.IgnoreGuiInset = true
controllerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
controllerGui.DisplayOrder = 999998
controllerGui.Enabled = false
controllerGui.Parent = playerGui

local controllerFrame = Instance.new("Frame")
controllerFrame.Name = "ControllerFrame"
controllerFrame.Position = UDim2.new(0,18,1,-330)
controllerFrame.Size = UDim2.fromOffset(300,300)
controllerFrame.BackgroundTransparency = 1
controllerFrame.Parent = controllerGui

local function controllerButton(name,text,pos)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Position = pos
	b.Size = UDim2.fromScale(.34,.34)
	b.BackgroundColor3 = WHITE
	b.BackgroundTransparency = .12
	b.TextColor3 = Color3.fromRGB(20,20,25)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 28
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.Parent = controllerFrame
	makeCorner(b,14)
	return b
end

local btnUp = controllerButton("Up","▲",UDim2.new(.33,0,0,0))
local btnDown = controllerButton("Down","▼",UDim2.new(.33,0,.66,0))
local btnLeft = controllerButton("Left","◀",UDim2.new(0,0,.33,0))
local btnRight = controllerButton("Right","▶",UDim2.new(.66,0,.33,0))

local wLock = Instance.new("TextButton")
wLock.Name = "WLock"
wLock.AnchorPoint = Vector2.new(.5,.5)
wLock.Position = UDim2.new(1,42,.5,0)
wLock.Size = UDim2.fromOffset(62,62)
wLock.Text = "W"
wLock.BackgroundColor3 = RED
wLock.BackgroundTransparency = .1
wLock.TextColor3 = WHITE
wLock.Font = Enum.Font.GothamBold
wLock.TextSize = 25
wLock.AutoButtonColor = false
wLock.Active = true
wLock.Selectable = false
wLock.BorderSizePixel = 0
wLock.Parent = controllerFrame
makeCorner(wLock,99)

local wLockEnabled = false

connect(wLock.Activated,function()
	wLockEnabled = not wLockEnabled

	if wLockEnabled then
		wLock.BackgroundColor3 = GREEN
	else
		wLock.BackgroundColor3 = RED
	end
end)

local function setControllerDirection(direction,state)
	controllerState[direction] = state

	local button =
		direction == "Forward" and btnUp or
		direction == "Backward" and btnDown or
		direction == "Left" and btnLeft or
		btnRight

	if state then
		button.BackgroundColor3 = Color3.fromRGB(70,150,255)
	else
		button.BackgroundColor3 = WHITE
	end
end

local function releaseInput(input)
	local data = activeTouches[input]
	if not data then
		return
	end

	activeTouches[input] = nil
	setControllerDirection(data.direction,false)
end

local function bindController(button,direction)
	connect(button.InputBegan,function(input)
		if not controllerEnabled then
			return
		end

		local t = input.UserInputType

		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if activeTouches[input] then
			return
		end

		activeTouches[input] = {
			direction = direction
		}

		setControllerDirection(direction,true)
	end)

	connect(button.InputEnded,function(input)
		releaseInput(input)
	end)
end

bindController(btnUp,"Forward")
bindController(btnDown,"Backward")
bindController(btnLeft,"Left")
bindController(btnRight,"Right")

connect(UserInputService.InputEnded,function(input)
	releaseInput(input)
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedRight = Vector3.new(1,0,0)

local function updateCameraVectors()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local forward = Vector3.new(look.X,0,look.Z)
	local side = Vector3.new(right.X,0,right.Z)

	if forward.Magnitude > .001 then
		cachedForward = forward.Unit
	end

	if side.Magnitude > .001 then
		cachedRight = side.Unit
	end
end

local smoothX = 0
local smoothZ = 0

local function getControllerMove()
	local x = 0
	local z = 0

	if controllerState.Forward then
		z += 1
	end

	if controllerState.Backward then
		z -= 1
	end

	if controllerState.Left then
		x -= 1
	end

	if controllerState.Right then
		x += 1
	end

	if x == 0 and z == 0 and wLockEnabled then
		z = 1
	end

	local targetX = x
	local targetZ = z

	local speed = .95

	smoothX += (targetX-smoothX)*speed
	smoothZ += (targetZ-smoothZ)*speed

	if not controllerEnabled then
		smoothX = 0
		smoothZ = 0
		return Vector3.zero
	end

	if math.abs(smoothX) < .005 then
		smoothX = 0
	end

	if math.abs(smoothZ) < .005 then
		smoothZ = 0
	end

	if smoothX == 0 and smoothZ == 0 then
		return Vector3.zero
	end

	local movement = cachedRight*smoothX + cachedForward*smoothZ

	if movement.Magnitude <= .001 then
		return Vector3.zero
	end

	return movement.Unit
end

local function updateControllerVisibility()
	controllerGui.Enabled = controllerEnabled

	if not controllerEnabled then
		controllerState.Forward = false
		controllerState.Backward = false
		controllerState.Left = false
		controllerState.Right = false
		activeTouches = {}
		smoothX = 0
		smoothZ = 0

		btnUp.BackgroundColor3 = WHITE
		btnDown.BackgroundColor3 = WHITE
		btnLeft.BackgroundColor3 = WHITE
		btnRight.BackgroundColor3 = WHITE
	end
end

updateControllerButton()
updateControllerVisibility()

local frameTime = 0
local frames = 0
local fps = 0

connect(RunService.RenderStepped,function(dt)
	if destroyed then
		return
	end

	frameTime += dt
	frames += 1

	if frameTime >= 1 then
		fps = math.floor(frames/frameTime)
		frames = 0
		frameTime = 0
		fpsLabel.Text = "FPS : "..tostring(fps)
	end

	local ping = 0

	pcall(function()
		if player.GetNetworkPing then
			ping = math.floor(player:GetNetworkPing()*1000)
		end
	end)

	pingLabel.Text = "PING : "..tostring(ping)

	if not character or not character.Parent then
		return
	end

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	updateCameraVectors()

	local movement = getControllerMove()

	local state = humanoid:GetState()
	local airborne =
		state == Enum.HumanoidStateType.Freefall or
		state == Enum.HumanoidStateType.Jumping or
		state == Enum.HumanoidStateType.FallingDown

	if movement.Magnitude > 0 then
		if airborne then
			local airMultiplier = math.clamp(config.AirControl/20,0,5)
			humanoid:Move(movement*airMultiplier,false)
		else
			humanoid:Move(movement,false)
		end
	elseif controllerEnabled then
		humanoid:Move(Vector3.zero,false)
	end

	humanoid.WalkSpeed = config.WalkSpeed

	if shiftLocked then
		local camera = workspace.CurrentCamera
		local root = character:FindFirstChild("HumanoidRootPart")

		if camera and root then
			local _,y = camera.CFrame:ToOrientation()
			root.CFrame = CFrame.new(root.Position)*CFrame.Angles(0,y,0)
		end

		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = true
	end

	humanoid.CameraOffset = Vector3.zero
end)

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	updateJump()
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then
		return
	end

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	smoothX = 0
	smoothZ = 0
	activeTouches = {}

	if humanoid then
		humanoid.WalkSpeed = config.WalkSpeed
		humanoid.AutoRotate = not shiftLocked
		humanoid.CameraOffset = Vector3.zero
	end

	task.delay(.5,function()
		if not destroyed then
			jumpObject = nil
			updateJump()
		end
	end)
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		jumpObject = nil
		task.delay(.2,function()
			if not destroyed then
				updateJump()
			end
		end)
	end
end)

connect(Players.PlayerAdded,function()
	if currentPage == "PLAYER" then
		task.delay(.1,refreshPlayers)
	end
end)

connect(Players.PlayerRemoving,function()
	if currentPage == "PLAYER" then
		task.delay(.1,refreshPlayers)
	end

	if spectating then
		if spectating == player then
			stopSpectating()
		end
	end
end)

applySpeed()
applySensitivity()
updateShift()
updateShiftButton()
updateJump()
refreshNotes()
refreshPlayers()

pages.MAIN.Visible = true
pages.NOTE.Visible = false
pages.CONTROL.Visible = false
pages.PLAYER.Visible = false
pages.SETTING.Visible = false

task.spawn(function()
	while not destroyed do
		task.wait(.15)

		if controllerEnabled ~= config.ControllerEnabled then
			controllerEnabled = config.ControllerEnabled
		end

		updateControllerVisibility()

		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = config.WalkSpeed
		end
	end
end)

setMenuVisible(false)
