local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "DeltaMobileConfig.json"
local NOTE_PREFIX = "AldoVz_Note_"

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
}

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

if _G.AldoVzPremiumCleanup then
	pcall(_G.AldoVzPremiumCleanup)
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

local function cleanupGui(name)
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

	cleanupGui("AldoVzPremiumUI")
	cleanupGui("DeltaMobileControls")
	cleanupGui("DeltaMobileErgo")
end

cleanupGui("AldoVzPremiumUI")
cleanupGui("DeltaMobileControls")
cleanupGui("DeltaMobileErgo")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.ShiftLocked = false

local COLORS = {
	Background = Color3.fromRGB(10, 12, 20),
	Panel = Color3.fromRGB(18, 21, 34),
	Panel2 = Color3.fromRGB(24, 28, 45),
	White = Color3.fromRGB(245, 248, 255),
	Muted = Color3.fromRGB(155, 165, 190),
	Blue = Color3.fromRGB(70, 150, 255),
	Purple = Color3.fromRGB(170, 0, 255),
	Green = Color3.fromRGB(65, 205, 120),
	Red = Color3.fromRGB(225, 75, 85),
	Orange = Color3.fromRGB(235, 140, 55),
	Black = Color3.fromRGB(0, 0, 0)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoVzPremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.Blue
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = obj
	return s
end

local function gradient(obj, colors, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(colors)
	g.Rotation = rotation or 0
	g.Parent = obj
	return g
end

local function shiny(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(.35, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(.5, Color3.fromRGB(110,190,255)),
		ColorSequenceKeypoint.new(.65, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, .8),
		NumberSequenceKeypoint.new(.42, .8),
		NumberSequenceKeypoint.new(.5, .1),
		NumberSequenceKeypoint.new(.58, .8),
		NumberSequenceKeypoint.new(1, .8)
	})
	g.Offset = Vector2.new(-1,0)
	g.Rotation = 0
	g.Parent = obj

	local function play()
		g.Offset = Vector2.new(-1,0)
		local tween = TweenService:Create(
			g,
			TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Offset = Vector2.new(1,0)}
		)
		tween:Play()
		task.delay(2.2, function()
			if obj.Parent then
				play()
			end
		end)
	end

	task.spawn(play)
	return g
end

local function makeFrame(parent, name, size, position, bg)
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = position
	f.BackgroundColor3 = bg or COLORS.Panel
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function makeText(parent, name, text, size, position, textSize, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Text = text
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.TextColor3 = color or COLORS.White
	l.Font = Enum.Font.GothamBold
	l.TextSize = textSize or 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeButton(parent, name, text, size, position, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Size = size
	b.Position = position
	b.BackgroundColor3 = color or COLORS.Panel2
	b.BackgroundTransparency = .04
	b.TextColor3 = COLORS.White
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.Parent = parent
	corner(b, 9)
	stroke(b, Color3.fromRGB(80,100,145), 1, .35)

	connect(b.MouseEnter, function()
		if b.Parent then
			b.BackgroundColor3 = Color3.fromRGB(35,42,65)
		end
	end)

	connect(b.MouseLeave, function()
		if b.Parent then
			b.BackgroundColor3 = color or COLORS.Panel2
		end
	end)

	return b
end

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.Size = UDim2.fromOffset(52,52)
openButton.Position = UDim2.new(0,14,0,90)
openButton.Text = "☰"
openButton.TextSize = 25
openButton.Font = Enum.Font.GothamBold
openButton.TextColor3 = COLORS.White
openButton.BackgroundColor3 = COLORS.Panel
openButton.BackgroundTransparency = .05
openButton.AutoButtonColor = false
openButton.BorderSizePixel = 0
openButton.ZIndex = 100
openButton.Parent = screenGui
corner(openButton, 14)
stroke(openButton, COLORS.Blue, 1.5, .25)
gradient(openButton,{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(25,35,65)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(20,25,45)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(35,20,60))
},45)
shiny(openButton)

local menu = makeFrame(
	screenGui,
	"Menu",
	UDim2.fromOffset(720,500),
	UDim2.new(.5,-360,.5,-250),
	COLORS.Background
)
menu.Visible = false
menu.ZIndex = 50
corner(menu, 16)
stroke(menu, Color3.fromRGB(70,90,145), 1.5, .2)

local menuScale = Instance.new("UIScale")
menuScale.Scale = .9
menuScale.Parent = menu

local header = makeFrame(
	menu,
	"Header",
	UDim2.new(1,0,0,62),
	UDim2.fromOffset(0,0),
	COLORS.Panel
)
header.ZIndex = 51
corner(header, 16)

gradient(header,{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(25,30,55)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(30,20,55)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(15,30,55))
},0)
shiny(header)

local headerLabel = makeText(
	header,
	"HeaderLabel",
	"👾 AldoVz   |   PING : 0   |   FPS : 0   |   CHECK : 0   |   SPEED : "..tostring(config.WalkSpeed),
	UDim2.new(1,-25,1,0),
	UDim2.fromOffset(14,0),
	14,
	COLORS.White
)
headerLabel.ZIndex = 52

local closeButton = makeButton(
	header,
	"Close",
	"×",
	UDim2.fromOffset(38,38),
	UDim2.new(1,-48,.5,-19),
	COLORS.Red
)
closeButton.TextSize = 25
closeButton.ZIndex = 53

local commandLabel = makeText(
	menu,
	"Command",
	"COMMAND INFINITE YIEL : __________________________",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,68),
	13,
	COLORS.Muted
)
commandLabel.ZIndex = 51

local side = makeFrame(
	menu,
	"MenuList",
	UDim2.fromOffset(175,400),
	UDim2.fromOffset(10,105),
	COLORS.Panel
)
side.ZIndex = 51
corner(side, 12)

local sideTitle = makeText(
	side,
	"MenuTitle",
	"MENU",
	UDim2.new(1,-20,0,38),
	UDim2.fromOffset(10,5),
	17,
	COLORS.White
)
sideTitle.ZIndex = 52

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "UIScrollingBUTTON"
scroll.Size = UDim2.new(1,-10,1,-48)
scroll.Position = UDim2.fromOffset(5,43)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ZIndex = 52
scroll.Parent = side

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function updateCanvas()
	scroll.CanvasSize = UDim2.fromOffset(0,list.AbsoluteContentSize.Y + 12)
end

connect(list:GetPropertyChangedSignal("AbsoluteContentSize"),updateCanvas)

local mainArea = makeFrame(
	menu,
	"MainFrame",
	UDim2.new(1,-205,1,-115),
	UDim2.fromOffset(195,105),
	Color3.fromRGB(13,16,27)
)
mainArea.ZIndex = 51
corner(mainArea, 12)

local pageTitle = makeText(
	mainArea,
	"PageTitle",
	"MAIN",
	UDim2.new(1,-25,0,35),
	UDim2.fromOffset(15,10),
	18,
	COLORS.White
)
pageTitle.ZIndex = 52

local pages = {}

local function newPage(name)
	local p = makeFrame(
		mainArea,
		name,
		UDim2.new(1,-20,1,-55),
		UDim2.fromOffset(10,48),
		Color3.fromRGB(16,19,31)
	)
	p.ZIndex = 52
	p.Visible = false
	corner(p, 10)
	pages[name] = p
	return p
end

local function showPage(name,title)
	for n,p in pairs(pages) do
		p.Visible = n == name
	end
	pageTitle.Text = title
end

local mainPage = newPage("MainPage")
local notePage = newPage("NotePage")
local controlPage = newPage("ControlPage")
local playerPage = newPage("PlayerPage")

showPage("MainPage","MAIN")

local mainInfo = makeText(
	mainPage,
	"Info",
	"FITUR IN MAIN FRAME",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,8),
	15,
	COLORS.Muted
)

local speedLabel = makeText(
	mainPage,
	"Speed",
	"WALK SPEED : "..tostring(config.WalkSpeed),
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,48),
	14,
	COLORS.White
)

local speedMinus = makeButton(
	mainPage,"SpeedMinus","−",
	UDim2.fromOffset(55,38),
	UDim2.new(1,-180,0,43),
	COLORS.Panel2
)

local speedPlus = makeButton(
	mainPage,"SpeedPlus","+",
	UDim2.fromOffset(55,38),
	UDim2.new(1,-115,0,43),
	COLORS.Panel2
)

local speedReset = makeButton(
	mainPage,"SpeedReset","RESET",
	UDim2.fromOffset(90,38),
	UDim2.new(1,-100,0,90),
	COLORS.Blue
)

local settingJumpButton = makeButton(
	mainPage,
	"JumpSetting",
	"JUMP SETTING",
	UDim2.new(1,-20,0,42),
	UDim2.fromOffset(10,140),
	COLORS.Panel2
)

local shiftButton = makeButton(
	mainPage,
	"ShiftLock",
	"SHIFT LOCK : OFF",
	UDim2.new(1,-20,0,42),
	UDim2.fromOffset(10,192),
	COLORS.Panel2
)

local settingPage = newPage("SettingPage")

local settingInfo = makeText(
	settingPage,
	"SettingInfo",
	"SETTING SHIFTLOCK / JUMP",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,8),
	15,
	COLORS.White
)

local targetMode = "JUMP"

local targetButton = makeButton(
	settingPage,
	"Target",
	"PILIH SET : JUMP",
	UDim2.new(1,-20,0,40),
	UDim2.fromOffset(10,45),
	COLORS.Blue
)

local up = makeButton(settingPage,"Up","↑",UDim2.fromOffset(55,40),UDim2.new(.5,-27,0,98))
local left = makeButton(settingPage,"Left","←",UDim2.fromOffset(55,40),UDim2.new(.5,-90,0,145))
local right = makeButton(settingPage,"Right","→",UDim2.fromOffset(55,40),UDim2.new(.5,35,0,145))
local down = makeButton(settingPage,"Down","↓",UDim2.fromOffset(55,40),UDim2.new(.5,-27,0,192))

local sizePlus = makeButton(settingPage,"SizePlus","SIZE +",UDim2.fromOffset(85,38),UDim2.fromOffset(15,250),COLORS.Green)
local sizeMinus = makeButton(settingPage,"SizeMinus","SIZE -",UDim2.fromOffset(85,38),UDim2.fromOffset(110,250),COLORS.Orange)
local resetPos = makeButton(settingPage,"Reset","RESET 🔁",UDim2.fromOffset(100,38),UDim2.new(1,-115,0,250),COLORS.Blue)

local function getJump()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then
		return touchGui:FindFirstChild("JumpButton",true)
	end
end

local shiftLockButton = Instance.new("TextButton")
shiftLockButton.Name = "ShiftLockButton"
shiftLockButton.AnchorPoint = Vector2.new(.5,.5)
shiftLockButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
shiftLockButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
shiftLockButton.Text = "⇄"
shiftLockButton.TextSize = 22
shiftLockButton.Font = Enum.Font.GothamBold
shiftLockButton.TextColor3 = COLORS.White
shiftLockButton.BackgroundColor3 = Color3.fromRGB(70,70,90)
shiftLockButton.BackgroundTransparency = .1
shiftLockButton.AutoButtonColor = false
shiftLockButton.BorderSizePixel = 0
shiftLockButton.Visible = false
shiftLockButton.ZIndex = 90
shiftLockButton.Parent = screenGui
corner(shiftLockButton,99)
stroke(shiftLockButton,COLORS.Purple,2,.1)

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = COLORS.White
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 100
crosshair.Parent = screenGui
corner(crosshair,99)

local function updateShiftVisual()
	shiftLockButton.Text = _G.ShiftLocked and "⇄ ON" or "⇄ OFF"
	shiftLockButton.BackgroundColor3 = _G.ShiftLocked and COLORS.Purple or Color3.fromRGB(70,70,90)
	shiftButton.Text = _G.ShiftLocked and "SHIFT LOCK : ON" or "SHIFT LOCK : OFF"
	shiftButton.BackgroundColor3 = _G.ShiftLocked and COLORS.Purple or COLORS.Panel2
	crosshair.Visible = _G.ShiftLocked
end

local function toggleShift()
	_G.ShiftLocked = not _G.ShiftLocked
	updateShiftVisual()

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not _G.ShiftLocked
	end
end

connect(shiftLockButton.Activated,toggleShift)
connect(shiftButton.Activated,toggleShift)

local function updateJump()
	local jump = getJump()
	local camera = workspace.CurrentCamera

	if not jump or not camera then
		return
	end

	local viewport = camera.ViewportSize
	local size = math.max(40,math.floor(viewport.Y * config.JumpSize))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5,.5)
		jump.Position = UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size = UDim2.fromOffset(size,size)
	end)
end

local function updateShift()
	shiftLockButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	shiftLockButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local step = .018

local function moveTarget(dx,dy)
	if targetMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX + dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY + dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX + dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY + dy,.02,.98)
		updateShift()
	end
end

connect(targetButton.Activated,function()
	if targetMode == "JUMP" then
		targetMode = "SHIFT"
		targetButton.Text = "PILIH SET : SHIFTLOCK"
		targetButton.BackgroundColor3 = COLORS.Purple
	else
		targetMode = "JUMP"
		targetButton.Text = "PILIH SET : JUMP"
		targetButton.BackgroundColor3 = COLORS.Blue
	end
end)

connect(up.Activated,function() moveTarget(0,-step) end)
connect(down.Activated,function() moveTarget(0,step) end)
connect(left.Activated,function() moveTarget(-step,0) end)
connect(right.Activated,function() moveTarget(step,0) end)

connect(sizePlus.Activated,function()
	if targetMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.5)
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
	end
	updateJump()
	updateShift()
end)

connect(sizeMinus.Activated,function()
	if targetMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.5)
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
	end
	updateJump()
	updateShift()
end)

connect(resetPos.Activated,function()
	if targetMode == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
	else
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
	end
	updateJump()
	updateShift()
end)

connect(settingJumpButton.Activated,function()
	showPage("SettingPage","SETTING SHIFTLOCK / JUMP")
end)

connect(speedMinus.Activated,function()
	config.WalkSpeed = math.max(1,config.WalkSpeed-1)
	speedLabel.Text = "WALK SPEED : "..config.WalkSpeed
	headerLabel.Text = "👾 AldoVz   |   PING : 0   |   FPS : 0   |   CHECK : 0   |   SPEED : "..config.WalkSpeed
	if humanoid then humanoid.WalkSpeed = config.WalkSpeed end
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed = math.min(200,config.WalkSpeed+1)
	speedLabel.Text = "WALK SPEED : "..config.WalkSpeed
	headerLabel.Text = "👾 AldoVz   |   PING : 0   |   FPS : 0   |   CHECK : 0   |   SPEED : "..config.WalkSpeed
	if humanoid then humanoid.WalkSpeed = config.WalkSpeed end
end)

connect(speedReset.Activated,function()
	config.WalkSpeed = defaultConfig.WalkSpeed
	speedLabel.Text = "WALK SPEED : "..config.WalkSpeed
	headerLabel.Text = "👾 AldoVz   |   PING : 0   |   FPS : 0   |   CHECK : 0   |   SPEED : "..config.WalkSpeed
	if humanoid then humanoid.WalkSpeed = config.WalkSpeed end
end)

local noteList = {}
local selectedNote = nil

local noteListFrame = Instance.new("ScrollingFrame")
noteListFrame.Name = "NoteList"
noteListFrame.Size = UDim2.fromOffset(155,260)
noteListFrame.Position = UDim2.fromOffset(8,45)
noteListFrame.BackgroundColor3 = COLORS.Panel2
noteListFrame.BorderSizePixel = 0
noteListFrame.ScrollBarThickness = 3
noteListFrame.Parent = notePage
corner(noteListFrame,8)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,5)
noteLayout.Parent = noteListFrame

local noteBox = Instance.new("TextBox")
noteBox.Name = "NoteText"
noteBox.Size = UDim2.new(1,-175,0,220)
noteBox.Position = UDim2.fromOffset(165,45)
noteBox.BackgroundColor3 = COLORS.Panel2
noteBox.TextColor3 = COLORS.White
noteBox.PlaceholderText = "Tulis catatan..."
noteBox.PlaceholderColor3 = COLORS.Muted
noteBox.Text = ""
noteBox.TextSize = 14
noteBox.Font = Enum.Font.Gotham
noteBox.TextWrapped = true
noteBox.TextXAlignment = Enum.TextXAlignment.Left
noteBox.TextYAlignment = Enum.TextYAlignment.Top
noteBox.ClearTextOnFocus = false
noteBox.MultiLine = true
noteBox.Parent = notePage
corner(noteBox,8)

local noteName = Instance.new("TextBox")
noteName.Size = UDim2.new(1,-175,0,35)
noteName.Position = UDim2.fromOffset(165,5)
noteName.BackgroundColor3 = COLORS.Panel2
noteName.TextColor3 = COLORS.White
noteName.PlaceholderText = "Nama Note"
noteName.Text = ""
noteName.TextSize = 13
noteName.Font = Enum.Font.Gotham
noteName.ClearTextOnFocus = false
noteName.Parent = notePage
corner(noteName,8)

local noteNew = makeButton(notePage,"NewNote","NEW",UDim2.fromOffset(70,35),UDim2.fromOffset(5,315),COLORS.Blue)
local noteSave = makeButton(notePage,"SaveNote","SAVE",UDim2.fromOffset(70,35),UDim2.fromOffset(82,315),COLORS.Green)
local noteDelete = makeButton(notePage,"DeleteNote","DELETE",UDim2.fromOffset(70,35),UDim2.fromOffset(159,315),COLORS.Red)
local noteCopy = makeButton(notePage,"CopyNote","COPY",UDim2.fromOffset(70,35),UDim2.fromOffset(236,315),COLORS.Purple)

local function loadNotes()
	table.clear(noteList)

	pcall(function()
		if listfiles then
			local files = listfiles("")
			for _,path in ipairs(files) do
				if tostring(path):find(NOTE_PREFIX,1,true) then
					table.insert(noteList,path)
				end
			end
		end
	end)
end

local function refreshNotes()
	for _,child in ipairs(noteListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	loadNotes()

	for _,path in ipairs(noteList) do
		local fileName = tostring(path):match("([^/\\]+)$") or tostring(path)
		local button = makeButton(
			noteListFrame,
			fileName,
			fileName:gsub("%.txt$",""),
			UDim2.new(1,-8,0,34),
			UDim2.fromOffset(0,0),
			COLORS.Panel
		)

		connect(button.Activated,function()
			selectedNote = path
			noteName.Text = fileName:gsub("%.txt$",""):gsub("^"..NOTE_PREFIX,"")

			pcall(function()
				if readfile then
					noteBox.Text = readfile(path)
				end
			end)
		end)
	end

	noteListFrame.CanvasSize = UDim2.fromOffset(0,noteLayout.AbsoluteContentSize.Y + 5)
end

connect(noteNew.Activated,function()
	selectedNote = nil
	noteName.Text = ""
	noteBox.Text = ""
end)

connect(noteSave.Activated,function()
	local name = noteName.Text:gsub("[^%w_%-%s]",""):gsub("^%s+",""):gsub("%s+$","")

	if name == "" then
		name = "Note_1"
	end

	local path = NOTE_PREFIX..name..".txt"

	pcall(function()
		if writefile then
			writefile(path,noteBox.Text)
			selectedNote = path
		end
	end)

	refreshNotes()
end)

connect(noteDelete.Activated,function()
	if selectedNote then
		pcall(function()
			if delfile then
				delfile(selectedNote)
			end
		end)
	end

	selectedNote = nil
	noteName.Text = ""
	noteBox.Text = ""
	refreshNotes()
end)

connect(noteCopy.Activated,function()
	pcall(function()
		if setclipboard then
			setclipboard(noteBox.Text)
		end
	end)
end)

refreshNotes()

local controlInfo = makeText(
	controlPage,
	"ControlInfo",
	"CONTROL",
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,8),
	16,
	COLORS.White
)

local controllerState = false

local controllerButton = makeButton(
	controlPage,
	"Controller",
	"CONTROLLER : OFF",
	UDim2.new(1,-20,0,42),
	UDim2.fromOffset(10,48),
	COLORS.Red
)

local airLabel = makeText(
	controlPage,
	"AirLabel",
	"AIR CONTROL : "..config.AirControl,
	UDim2.new(1,-20,0,32),
	UDim2.fromOffset(10,105),
	14,
	COLORS.White
)

local airMinus = makeButton(controlPage,"AirMinus","−",UDim2.fromOffset(65,38),UDim2.fromOffset(10,145))
local airPlus = makeButton(controlPage,"AirPlus","+",UDim2.fromOffset(65,38),UDim2.fromOffset(82,145))
local airReset = makeButton(controlPage,"AirReset","RESET",UDim2.fromOffset(90,38),UDim2.fromOffset(154,145),COLORS.Blue)

connect(controllerButton.Activated,function()
	controllerState = not controllerState

	if controllerState then
		controllerButton.Text = "CONTROLLER : ON"
		controllerButton.BackgroundColor3 = COLORS.Green
	else
		controllerButton.Text = "CONTROLLER : OFF"
		controllerButton.BackgroundColor3 = COLORS.Red
	end
end)

connect(airMinus.Activated,function()
	config.AirControl = math.max(0,config.AirControl-1)
	airLabel.Text = "AIR CONTROL : "..config.AirControl
end)

connect(airPlus.Activated,function()
	config.AirControl = math.min(100,config.AirControl+1)
	airLabel.Text = "AIR CONTROL : "..config.AirControl
end)

connect(airReset.Activated,function()
	config.AirControl = defaultConfig.AirControl
	airLabel.Text = "AIR CONTROL : "..config.AirControl
end)

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1,-20,1,-65)
playerList.Position = UDim2.fromOffset(10,45)
playerList.BackgroundColor3 = COLORS.Panel2
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.Parent = playerPage
corner(playerList,9)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,6)
playerLayout.Parent = playerList

local spectating = nil

local function stopSpectate()
	spectating = nil
	local camera = workspace.CurrentCamera
	if camera and humanoid then
		camera.CameraSubject = humanoid
	end
end

local function spectate(target)
	if not target or not target.Character then
		return
	end

	local h = target.Character:FindFirstChildOfClass("Humanoid")
	if h then
		spectating = target
		workspace.CurrentCamera.CameraSubject = h
	end
end

local stopButton = makeButton(
	playerPage,
	"StopSpectate",
	"STOP SPECTATE",
	UDim2.fromOffset(130,38),
	UDim2.new(1,-140,1,-45),
	COLORS.Red
)

connect(stopButton.Activated,stopSpectate)

local function refreshPlayers()
	for _,child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _,target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local button = makeButton(
				playerList,
				target.Name,
				target.Name,
				UDim2.new(1,-8,0,40),
				UDim2.fromOffset(0,0),
				COLORS.Panel
			)

			connect(button.Activated,function()
				spectate(target)
			end)
		end
	end

	playerList.CanvasSize = UDim2.fromOffset(0,playerLayout.AbsoluteContentSize.Y + 8)
end

refreshPlayers()

connect(Players.PlayerAdded,refreshPlayers)
connect(Players.PlayerRemoving,function(target)
	if spectating == target then
		stopSpectate()
	end
	refreshPlayers()
end)

local mainMenuButton = makeButton(
	scroll,
	"MainButton",
	"MAIN",
	UDim2.new(1,-10,0,42),
	UDim2.fromOffset(0,0),
	COLORS.Blue
)
mainMenuButton.LayoutOrder = 1

local noteMenuButton = makeButton(
	scroll,
	"NoteButton",
	"NOTE",
	UDim2.new(1,-10,0,42),
	UDim2.fromOffset(0,0),
	COLORS.Panel2
)
noteMenuButton.LayoutOrder = 2

local controlMenuButton = makeButton(
	scroll,
	"ControlButton",
	"CONTROL",
	UDim2.new(1,-10,0,42),
	UDim2.fromOffset(0,0),
	COLORS.Panel2
)
controlMenuButton.LayoutOrder = 3

local playerMenuButton = makeButton(
	scroll,
	"PlayerButton",
	"PLAYER",
	UDim2.new(1,-10,0,42),
	UDim2.fromOffset(0,0),
	COLORS.Panel2
)
playerMenuButton.LayoutOrder = 4

local settingMenuButton = makeButton(
	scroll,
	"SettingButton",
	"SETTING",
	UDim2.new(1,-10,0,42),
	UDim2.fromOffset(0,0),
	COLORS.Panel2
)
settingMenuButton.LayoutOrder = 5

local function selectMenu(button,page,title)
	mainMenuButton.BackgroundColor3 = COLORS.Panel2
	noteMenuButton.BackgroundColor3 = COLORS.Panel2
	controlMenuButton.BackgroundColor3 = COLORS.Panel2
	playerMenuButton.BackgroundColor3 = COLORS.Panel2
	settingMenuButton.BackgroundColor3 = COLORS.Panel2

	button.BackgroundColor3 = COLORS.Blue
	showPage(page,title)
end

connect(mainMenuButton.Activated,function()
	selectMenu(mainMenuButton,"MainPage","MAIN")
end)

connect(noteMenuButton.Activated,function()
	selectMenu(noteMenuButton,"NotePage","NOTE")
	refreshNotes()
end)

connect(controlMenuButton.Activated,function()
	selectMenu(controlMenuButton,"ControlPage","CONTROL")
end)

connect(playerMenuButton.Activated,function()
	selectMenu(playerMenuButton,"PlayerPage","PLAYER")
	refreshPlayers()
end)

connect(settingMenuButton.Activated,function()
	selectMenu(settingMenuButton,"SettingPage","SETTING SHIFTLOCK / JUMP")
end)

connect(openButton.Activated,function()
	menu.Visible = not menu.Visible

	if menu.Visible then
		menuScale.Scale = .9

		local tween = TweenService:Create(
			menuScale,
			TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
			{Scale = 1}
		)
		tween:Play()
	end
end)

connect(closeButton.Activated,function()
	menu.Visible = false
end)

local movementState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false
}

local activeInputs = {}

local function createMovementButton(name,text,pos)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Size = UDim2.fromOffset(58,58)
	b.Position = pos
	b.BackgroundColor3 = COLORS.White
	b.BackgroundTransparency = .1
	b.TextColor3 = COLORS.Black
	b.Font = Enum.Font.GothamBold
	b.TextSize = 25
	b.AutoButtonColor = false
	b.BorderSizePixel = 0
	b.ZIndex = 10
	b.Parent = screenGui
	corner(b,14)
	return b
end

local moveUp = createMovementButton("Up","▲",UDim2.new(0,18,1,-180))
local moveDown = createMovementButton("Down","▼",UDim2.new(0,18,1,-58))
local moveLeft = createMovementButton("Left","◀",UDim2.new(0,78,1,-119))
local moveRight = createMovementButton("Right","▶",UDim2.new(0,138,1,-119))

local wLock = makeButton(
	screenGui,
	"WLock",
	"W : OFF",
	UDim2.fromOffset(72,58),
	UDim2.new(0,202,1,-119),
	COLORS.Red
)
wLock.ZIndex = 10

local movementButtons = {
	[moveUp] = "Forward",
	[moveDown] = "Backward",
	[moveLeft] = "Left",
	[moveRight] = "Right"
}

local function updateMovementButton(button,state)
	if state then
		button.BackgroundColor3 = COLORS.Blue
		button.TextColor3 = COLORS.White
	else
		button.BackgroundColor3 = COLORS.White
		button.TextColor3 = COLORS.Black
	end
end

local function releaseMovement(input)
	local direction = activeInputs[input]
	if direction then
		activeInputs[input] = nil
		movementState[direction] = false

		for button,d in pairs(movementButtons) do
			if d == direction then
				updateMovementButton(button,false)
			end
		end
	end
end

for button,direction in pairs(movementButtons) do
	connect(button.InputBegan,function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then
			return
		end

		activeInputs[input] = direction
		movementState[direction] = true
		updateMovementButton(button,true)
	end)

	connect(button.InputEnded,function(input)
		releaseMovement(input)
	end)
end

connect(UserInputService.InputEnded,function(input)
	releaseMovement(input)
end)

local wLockState = false

connect(wLock.Activated,function()
	wLockState = not wLockState

	if wLockState then
		wLock.Text = "W : ON"
		wLock.BackgroundColor3 = COLORS.Green
	else
		wLock.Text = "W : OFF"
		wLock.BackgroundColor3 = COLORS.Red
	end
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
	local sideVector = Vector3.new(right.X,0,right.Z)

	if forward.Magnitude > .001 then
		cachedForward = forward.Unit
	end

	if sideVector.Magnitude > .001 then
		cachedSide = sideVector.Unit
	end
end

local function getMovement()
	local x = 0
	local z = 0

	if movementState.Forward then z += 1 end
	if movementState.Backward then z -= 1 end
	if movementState.Left then x -= 1 end
	if movementState.Right then x += 1 end

	if x == 0 and z == 0 and wLockState then
		return cachedForward
	end

	smoothX += (x-smoothX)*.95
	smoothZ += (z-smoothZ)*.95

	if math.abs(smoothX)<.005 then smoothX=0 end
	if math.abs(smoothZ)<.005 then smoothZ=0 end

	if smoothX == 0 and smoothZ == 0 then
		return Vector3.zero
	end

	local v = cachedSide*smoothX + cachedForward*smoothZ

	if v.Magnitude < .001 then
		return Vector3.zero
	end

	return v.Unit
end

local lastTime = os.clock()
local frames = 0
local fps = 0

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	local now = os.clock()
	frames += 1

	if now-lastTime >= 1 then
		fps = frames
		frames = 0
		lastTime = now
	end

	local ping = 0

	pcall(function()
		local network = Stats.Network
		local serverStats = network.ServerStatsItem
		local dataPing = serverStats:FindFirstChild("Data Ping")

		if dataPing then
			local value = tostring(dataPing:GetValueString())
			ping = tonumber(value:match("%d+")) or 0
		end
	end)

	headerLabel.Text =
		"👾 AldoVz   |   PING : "..ping..
		"   |   FPS : "..fps..
		"   |   CHECK : 0   |   SPEED : "..config.WalkSpeed

	updateCameraVectors()

	if humanoid and humanoid.Parent and humanoid.Health > 0 then
		humanoid.WalkSpeed = config.WalkSpeed

		local movement = getMovement()

		local state = humanoid:GetState()

		if state == Enum.HumanoidStateType.Freefall or
			state == Enum.HumanoidStateType.Jumping then

			local factor = math.clamp(config.AirControl/100,0,1)
			movement = movement * factor
		end

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
	end

	updateJump()
	updateShift()
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then
		return
	end

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.WalkSpeed = config.WalkSpeed
		humanoid.AutoRotate = not _G.ShiftLocked
	end

	task.delay(.4,function()
		if not destroyed then
			updateJump()
			updateShift()
		end
	end)
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		task.delay(.2,function()
			if not destroyed then
				updateJump()
			end
		end)
	end
end)

updateShiftVisual()
updateShift()
updateJump()

task.spawn(function()
	while not destroyed do
		task.wait(2)
		if not destroyed then
			saveConfig()
		end
	end
end)
