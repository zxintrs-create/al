local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "AldoVzConfig.json"
local NOTE_PREFIX = "AldoVzNote_"
local NOTE_COUNT_FILE = "AldoVzNotes.json"

local defaultConfig = {
	WalkSpeed = 16,
	JumpPower = 50,
	AirControl = 20,
	ControllerEnabled = true,
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	TargetSetting = "JUMP",
	ShiftLocked = false
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

local function saveNote(index,text)
	pcall(function()
		if writefile then
			writefile(NOTE_PREFIX..tostring(index)..".txt",text or "")
		end
	end)
end

local function loadNote(index)
	local result = ""
	pcall(function()
		if readfile and isfile and isfile(NOTE_PREFIX..tostring(index)..".txt") then
			result = readfile(NOTE_PREFIX..tostring(index)..".txt")
		end
	end)
	return result
end

local function saveNoteList(list)
	pcall(function()
		if writefile then
			writefile(NOTE_COUNT_FILE,HttpService:JSONEncode(list))
		end
	end)
end

local function loadNoteList()
	local list = {1}
	pcall(function()
		if readfile and isfile and isfile(NOTE_COUNT_FILE) then
			local data = HttpService:JSONDecode(readfile(NOTE_COUNT_FILE))
			if type(data) == "table" then
				list = data
			end
		end
	end)
	return list
end

if _G.AldoVzCleanup then
	pcall(_G.AldoVzCleanup)
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

local function destroy(name)
	local obj = playerGui:FindFirstChild(name)
	if obj then
		pcall(function()
			obj:Destroy()
		end)
	end
end

_G.AldoVzCleanup = function()
	if destroyed then return end
	destroyed = true
	disconnectAll()
	destroy("AldoVz")
end

destroy("AldoVz")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoVz"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

local mainColor = Color3.fromRGB(28,28,35)
local panelColor = Color3.fromRGB(35,35,45)
local buttonColor = Color3.fromRGB(48,48,60)
local selectedColor = Color3.fromRGB(100,60,180)
local greenColor = Color3.fromRGB(55,180,95)
local redColor = Color3.fromRGB(210,65,65)
local white = Color3.fromRGB(245,245,245)
local gray = Color3.fromRGB(170,170,180)

local function corner(obj,radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,radius or 8)
	c.Parent = obj
	return c
end

local function stroke(obj,color,transparency,thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1,1,1)
	s.Transparency = transparency or .7
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

local function button(parent,name,text,pos,size)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Position = pos
	b.Size = size
	b.BackgroundColor3 = buttonColor
	b.TextColor3 = white
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.BorderSizePixel = 0
	b.Active = true
	b.Selectable = false
	b.ZIndex = 20
	b.Parent = parent
	corner(b,8)
	return b
end

local function label(parent,name,text,pos,size,textSize)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Text = text
	l.Position = pos
	l.Size = size
	l.BackgroundTransparency = 1
	l.TextColor3 = white
	l.Font = Enum.Font.GothamBold
	l.TextSize = textSize or 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.ZIndex = 20
	l.Parent = parent
	return l
end

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(0,420,0,58)
header.Position = UDim2.new(0,8,0,8)
header.BackgroundColor3 = mainColor
header.BorderSizePixel = 0
header.Parent = screenGui
corner(header,10)
stroke(header,Color3.fromRGB(110,80,180),.5,1)

local title = label(header,"Title","👾 AldoVz",UDim2.fromOffset(12,2),UDim2.fromOffset(110,28),17)

local pingLabel = label(header,"Ping","PING : 0",UDim2.fromOffset(120,2),UDim2.fromOffset(80,25),12)
local fpsLabel = label(header,"FPS","FPS : 0",UDim2.fromOffset(200,2),UDim2.fromOffset(70,25),12)
local checkLabel = label(header,"Check","CHECK : 0",UDim2.fromOffset(270,2),UDim2.fromOffset(95,25),12)

local menuButton = button(header,"MenuButton","MENU",UDim2.fromOffset(10,31),UDim2.fromOffset(90,22))
menuButton.TextSize = 11

local speedLabel = label(header,"Speed","SPEED : "..tostring(config.WalkSpeed),UDim2.fromOffset(310,30),UDim2.fromOffset(100,22),11)

local body = Instance.new("Frame")
body.Name = "MenuBody"
body.Size = UDim2.new(0,760,0,530)
body.Position = UDim2.new(0,8,0,72)
body.BackgroundColor3 = mainColor
body.BorderSizePixel = 0
body.Visible = true
body.Parent = screenGui
corner(body,10)
stroke(body,Color3.fromRGB(110,80,180),.5,1)

local side = Instance.new("Frame")
side.Name = "MenuList"
side.Size = UDim2.new(0,145,1,0)
side.BackgroundColor3 = Color3.fromRGB(24,24,30)
side.BorderSizePixel = 0
side.Parent = body
corner(side,10)

local sideTitle = label(side,"MenuTitle","MENU LIST",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,30),14)

local mainButton = button(side,"MainButton","MAIN",UDim2.fromOffset(10,52),UDim2.new(1,-20,0,42))
local noteButton = button(side,"NoteButton","NOTE",UDim2.fromOffset(10,102),UDim2.new(1,-20,0,42))
local controlButton = button(side,"ControlButton","CONTROL",UDim2.fromOffset(10,152),UDim2.new(1,-20,0,42))
local playerButton = button(side,"PlayerButton","PLAYER",UDim2.fromOffset(10,202),UDim2.new(1,-20,0,42))

local content = Instance.new("Frame")
content.Name = "MainContent"
content.Size = UDim2.new(1,-155,1,-10)
content.Position = UDim2.fromOffset(150,5)
content.BackgroundTransparency = 1
content.Parent = body

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromScale(1,1)
mainFrame.BackgroundTransparency = 1
mainFrame.Visible = true
mainFrame.Parent = content

local mainTitle = label(mainFrame,"Title","MAIN",UDim2.fromOffset(10,5),UDim2.new(1,-20,0,35),20)

local walkFrame = Instance.new("Frame")
walkFrame.Size = UDim2.new(1,-20,0,85)
walkFrame.Position = UDim2.fromOffset(10,48)
walkFrame.BackgroundColor3 = panelColor
walkFrame.BorderSizePixel = 0
walkFrame.Parent = mainFrame
corner(walkFrame,10)

label(walkFrame,"WalkTitle","WALK SPEED",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,25),14)

local speedMinus = button(walkFrame,"Minus","-",UDim2.fromOffset(12,38),UDim2.fromOffset(55,35))
local speedValue = label(walkFrame,"Value",tostring(config.WalkSpeed),UDim2.fromOffset(80,38),UDim2.fromOffset(100,35),17)
speedValue.TextXAlignment = Enum.TextXAlignment.Center
local speedPlus = button(walkFrame,"Plus","+",UDim2.fromOffset(190,38),UDim2.fromOffset(55,35))

local jumpSetting = Instance.new("Frame")
jumpSetting.Size = UDim2.new(1,-20,0,255)
jumpSetting.Position = UDim2.fromOffset(10,145)
jumpSetting.BackgroundColor3 = panelColor
jumpSetting.BorderSizePixel = 0
jumpSetting.Parent = mainFrame
corner(jumpSetting,10)

label(jumpSetting,"Title","SETTING SHIFTLOCK / JUMP",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,28),15)

local targetButton = button(jumpSetting,"Target","PILIH SET : "..config.TargetSetting,UDim2.fromOffset(12,40),UDim2.new(1,-24,0,35))
targetButton.BackgroundColor3 = selectedColor

local arrowUp = button(jumpSetting,"Up","↑",UDim2.new(.5,-30,0,85),UDim2.fromOffset(60,38))
local arrowLeft = button(jumpSetting,"Left","←",UDim2.new(.5,-100,0,127),UDim2.fromOffset(60,38))
local arrowRight = button(jumpSetting,"Right","→",UDim2.new(.5,40,0,127),UDim2.fromOffset(60,38))
local arrowDown = button(jumpSetting,"Down","↓",UDim2.new(.5,-30,0,169),UDim2.fromOffset(60,38))

local sizePlus = button(jumpSetting,"SizePlus","SIZE +",UDim2.fromOffset(15,215),UDim2.fromOffset(90,32))
local sizeMinus = button(jumpSetting,"SizeMinus","SIZE -",UDim2.new(1,-105,0,215),UDim2.fromOffset(90,32))
local resetSetting = button(jumpSetting,"Reset","RESET 🔁",UDim2.new(.5,-45,0,215),UDim2.fromOffset(90,32))

local noteFrame = Instance.new("Frame")
noteFrame.Name = "NoteFrame"
noteFrame.Size = UDim2.fromScale(1,1)
noteFrame.BackgroundTransparency = 1
noteFrame.Visible = false
noteFrame.Parent = content

label(noteFrame,"Title","NOTE",UDim2.fromOffset(10,5),UDim2.new(1,-20,0,35),20)

local noteList = Instance.new("ScrollingFrame")
noteList.Name = "NoteList"
noteList.Size = UDim2.new(0,105,1,-55)
noteList.Position = UDim2.fromOffset(10,45)
noteList.BackgroundColor3 = panelColor
noteList.BorderSizePixel = 0
noteList.ScrollBarThickness = 4
noteList.CanvasSize = UDim2.new()
noteList.Parent = noteFrame
corner(noteList,8)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,5)
noteLayout.Parent = noteList

local noteEditor = Instance.new("TextBox")
noteEditor.Name = "NoteEditor"
noteEditor.Size = UDim2.new(1,-130,1,-105)
noteEditor.Position = UDim2.fromOffset(125,45)
noteEditor.BackgroundColor3 = Color3.fromRGB(20,20,25)
noteEditor.TextColor3 = white
noteEditor.PlaceholderText = "Tulis catatan..."
noteEditor.PlaceholderColor3 = gray
noteEditor.Text = ""
noteEditor.TextSize = 14
noteEditor.Font = Enum.Font.Code
noteEditor.TextXAlignment = Enum.TextXAlignment.Left
noteEditor.TextYAlignment = Enum.TextYAlignment.Top
noteEditor.MultiLine = true
noteEditor.ClearTextOnFocus = false
noteEditor.TextWrapped = true
noteEditor.BorderSizePixel = 0
noteEditor.Parent = noteFrame
corner(noteEditor,8)

local noteCurrent = 1

local noteSave = button(noteFrame,"Save","SAVE FILE",UDim2.fromOffset(125,445),UDim2.fromOffset(110,38))
local noteCopy = button(noteFrame,"Copy","COPY",UDim2.fromOffset(245,445),UDim2.fromOffset(90,38))
local notePaste = button(noteFrame,"Paste","PASTE",UDim2.fromOffset(345,445),UDim2.fromOffset(90,38))
local noteNew = button(noteFrame,"New","NEW FILE",UDim2.fromOffset(445,445),UDim2.fromOffset(110,38))

local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.fromScale(1,1)
controlFrame.BackgroundTransparency = 1
controlFrame.Visible = false
controlFrame.Parent = content

label(controlFrame,"Title","CONTROL",UDim2.fromOffset(10,5),UDim2.new(1,-20,0,35),20)

local controllerStatus = button(controlFrame,"Controller","CONTROLLER : "..(config.ControllerEnabled and "ON" or "OFF"),UDim2.fromOffset(10,50),UDim2.new(1,-20,0,45))
controllerStatus.BackgroundColor3 = config.ControllerEnabled and greenColor or redColor

local airFrame = Instance.new("Frame")
airFrame.Size = UDim2.new(1,-20,0,120)
airFrame.Position = UDim2.fromOffset(10,110)
airFrame.BackgroundColor3 = panelColor
airFrame.BorderSizePixel = 0
airFrame.Parent = controlFrame
corner(airFrame,10)

label(airFrame,"AirTitle","AIR CONTROL",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,28),15)

local airMinus = button(airFrame,"Minus","-",UDim2.fromOffset(15,52),UDim2.fromOffset(60,40))
local airValue = label(airFrame,"Value",tostring(config.AirControl),UDim2.fromOffset(90,52),UDim2.fromOffset(120,40),17)
airValue.TextXAlignment = Enum.TextXAlignment.Center
local airPlus = button(airFrame,"Plus","+",UDim2.fromOffset(220,52),UDim2.fromOffset(60,40))

local controlInfo = label(controlFrame,"Info","W A S D / TOUCH CONTROLLER\nAIR CONTROL : "..tostring(config.AirControl),UDim2.fromOffset(15,245),UDim2.new(1,-30,0,80),15)
controlInfo.TextYAlignment = Enum.TextYAlignment.Top

local playerFrame = Instance.new("Frame")
playerFrame.Name = "PlayerFrame"
playerFrame.Size = UDim2.fromScale(1,1)
playerFrame.BackgroundTransparency = 1
playerFrame.Visible = false
playerFrame.Parent = content

label(playerFrame,"Title","PLAYER",UDim2.fromOffset(10,5),UDim2.new(1,-20,0,35),20)

local spectateLabel = label(playerFrame,"Spectate","SPECTATE : NONE",UDim2.fromOffset(10,43),UDim2.new(1,-20,0,30),14)

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1,-20,1,-90)
playerList.Position = UDim2.fromOffset(10,80)
playerList.BackgroundColor3 = panelColor
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 5
playerList.CanvasSize = UDim2.new()
playerList.Parent = playerFrame
corner(playerList,10)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,5)
playerLayout.Parent = playerList

local pages = {
	MAIN = mainFrame,
	NOTE = noteFrame,
	CONTROL = controlFrame,
	PLAYER = playerFrame
}

local navs = {
	MAIN = mainButton,
	NOTE = noteButton,
	CONTROL = controlButton,
	PLAYER = playerButton
}

local function showPage(name)
	for key,frame in pairs(pages) do
		frame.Visible = key == name
	end

	for key,b in pairs(navs) do
		b.BackgroundColor3 = key == name and selectedColor or buttonColor
	end
end

connect(mainButton.Activated,function()
	showPage("MAIN")
end)

connect(noteButton.Activated,function()
	showPage("NOTE")
end)

connect(controlButton.Activated,function()
	showPage("CONTROL")
end)

connect(playerButton.Activated,function()
	showPage("PLAYER")
end)

connect(menuButton.Activated,function()
	body.Visible = not body.Visible
end)

local function applyHumanoid()
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = config.WalkSpeed
		pcall(function()
			humanoid.UseJumpPower = true
			humanoid.JumpPower = config.JumpPower
		end)
	end
end

connect(speedMinus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed-1,1,200)
	speedValue.Text = tostring(config.WalkSpeed)
	speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
	applyHumanoid()
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed+1,1,200)
	speedValue.Text = tostring(config.WalkSpeed)
	speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
	applyHumanoid()
end)

connect(targetButton.Activated,function()
	if config.TargetSetting == "JUMP" then
		config.TargetSetting = "SHIFTLOCK"
	else
		config.TargetSetting = "JUMP"
	end
	targetButton.Text = "PILIH SET : "..config.TargetSetting
end)

local function getJumpButton()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if not touchGui then return nil end
	return touchGui:FindFirstChild("JumpButton",true)
end

local function updateJump()
	local jump = getJumpButton()
	local camera = workspace.CurrentCamera
	if not jump or not camera then return end

	local viewport = camera.ViewportSize
	local size = math.max(40,math.floor(viewport.Y * config.JumpSize))

	pcall(function()
		jump.AnchorPoint = Vector2.new(.5,.5)
		jump.Position = UDim2.new(config.JumpX,0,config.JumpY,0)
		jump.Size = UDim2.fromOffset(size,size)
	end)
end

local shiftButton = Instance.new("TextButton")
shiftButton.Name = "ShiftLock"
shiftButton.Text = "⇄"
shiftButton.TextSize = 22
shiftButton.Font = Enum.Font.GothamBold
shiftButton.TextColor3 = white
shiftButton.BackgroundColor3 = config.ShiftLocked and selectedColor or redColor
shiftButton.BackgroundTransparency = .1
shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
shiftButton.AnchorPoint = Vector2.new(.5,.5)
shiftButton.BorderSizePixel = 0
shiftButton.Active = true
shiftButton.ZIndex = 50
shiftButton.Parent = screenGui
corner(shiftButton,999)

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = white
crosshair.BorderSizePixel = 0
crosshair.Visible = config.ShiftLocked
crosshair.ZIndex = 49
crosshair.Parent = screenGui
corner(crosshair,999)

local function updateShiftButton()
	shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
	shiftButton.BackgroundColor3 = config.ShiftLocked and selectedColor or redColor
end

local function toggleShift()
	config.ShiftLocked = not config.ShiftLocked
	crosshair.Visible = config.ShiftLocked

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate = not config.ShiftLocked
	end

	updateShiftButton()
end

connect(shiftButton.Activated,toggleShift)

local function settingMove(dx,dy)
	if config.TargetSetting == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShiftButton()
	end
end

local settingStep = .018

connect(arrowUp.Activated,function()
	settingMove(0,-settingStep)
end)

connect(arrowDown.Activated,function()
	settingMove(0,settingStep)
end)

connect(arrowLeft.Activated,function()
	settingMove(-settingStep,0)
end)

connect(arrowRight.Activated,function()
	settingMove(settingStep,0)
end)

connect(sizePlus.Activated,function()
	if config.TargetSetting == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShiftButton()
	end
end)

connect(sizeMinus.Activated,function()
	if config.TargetSetting == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShiftButton()
	end
end)

connect(resetSetting.Activated,function()
	if config.TargetSetting == "JUMP" then
		config.JumpX = defaultConfig.JumpX
		config.JumpY = defaultConfig.JumpY
		config.JumpSize = defaultConfig.JumpSize
		updateJump()
	else
		config.ShiftX = defaultConfig.ShiftX
		config.ShiftY = defaultConfig.ShiftY
		config.ShiftSize = defaultConfig.ShiftSize
		updateShiftButton()
	end
end)

local noteListData = loadNoteList()

local function refreshNotes()
	for _,obj in ipairs(noteList:GetChildren()) do
		if obj:IsA("TextButton") then
			obj:Destroy()
		end
	end

	for _,index in ipairs(noteListData) do
		local b = button(noteList,"Note"..tostring(index),"FILE "..tostring(index),UDim2.new(),UDim2.new(1,-8,0,35))
		b.LayoutOrder = tonumber(index) or 0

		connect(b.Activated,function()
			noteCurrent = index
			noteEditor.Text = loadNote(index)
		end)
	end

	task.defer(function()
		noteList.CanvasSize = UDim2.fromOffset(0,noteLayout.AbsoluteContentSize.Y+10)
	end)
end

refreshNotes()
noteEditor.Text = loadNote(noteCurrent)

connect(noteSave.Activated,function()
	saveNote(noteCurrent,noteEditor.Text)
end)

connect(noteNew.Activated,function()
	local max = 0

	for _,v in ipairs(noteListData) do
		local n = tonumber(v)
		if n and n > max then
			max = n
		end
	end

	local newIndex = max + 1
	table.insert(noteListData,newIndex)
	saveNoteList(noteListData)
	noteCurrent = newIndex
	noteEditor.Text = ""
	refreshNotes()
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
			noteEditor.Text = getclipboard()
		end
	end)
end)

connect(controllerStatus.Activated,function()
	config.ControllerEnabled = not config.ControllerEnabled

	controllerStatus.Text = "CONTROLLER : "..(config.ControllerEnabled and "ON" or "OFF")
	controllerStatus.BackgroundColor3 = config.ControllerEnabled and greenColor or redColor
end)

connect(airMinus.Activated,function()
	config.AirControl = math.clamp(config.AirControl-1,0,100)
	airValue.Text = tostring(config.AirControl)
	controlInfo.Text = "W A S D / TOUCH CONTROLLER\nAIR CONTROL : "..tostring(config.AirControl)
end)

connect(airPlus.Activated,function()
	config.AirControl = math.clamp(config.AirControl+1,0,100)
	airValue.Text = tostring(config.AirControl)
	controlInfo.Text = "W A S D / TOUCH CONTROLLER\nAIR CONTROL : "..tostring(config.AirControl)
end)

local moveState = {
	W = false,
	A = false,
	S = false,
	D = false
}

local cachedForward = Vector3.new(0,0,-1)
local cachedRight = Vector3.new(1,0,0)

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
		cachedRight = side.Unit
	end
end

local function getMovement()
	if not config.ControllerEnabled then
		return Vector3.zero
	end

	local x = 0
	local z = 0

	if moveState.A then x -= 1 end
	if moveState.D then x += 1 end
	if moveState.W then z += 1 end
	if moveState.S then z -= 1 end

	if x == 0 and z == 0 then
		return Vector3.zero
	end

	local move = cachedRight*x + cachedForward*z

	if move.Magnitude <= .001 then
		return Vector3.zero
	end

	return move.Unit
end

local keyboardMap = {
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.D] = "D"
}

connect(UserInputService.InputBegan,function(input,gp)
	if gp then return end

	local key = keyboardMap[input.KeyCode]
	if key then
		moveState[key] = true
	end
end)

connect(UserInputService.InputEnded,function(input)
	local key = keyboardMap[input.KeyCode]
	if key then
		moveState[key] = false
	end
end)

local touchButtons = {}

local controlPad = Instance.new("Frame")
controlPad.Name = "TouchController"
controlPad.Size = UDim2.fromOffset(170,170)
controlPad.Position = UDim2.new(0,10,1,-185)
controlPad.BackgroundTransparency = 1
controlPad.ZIndex = 60
controlPad.Parent = screenGui

local function touchControl(name,text,pos,key)
	local b = button(controlPad,name,text,pos,UDim2.fromOffset(52,52))
	b.BackgroundTransparency = .15
	b.ZIndex = 61

	connect(b.InputBegan,function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			moveState[key] = true
		end
	end)

	connect(b.InputEnded,function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			moveState[key] = false
		end
	end)

	touchButtons[key] = b
end

touchControl("W","W",UDim2.fromOffset(59,0),"W")
touchControl("A","A",UDim2.fromOffset(0,59),"A")
touchControl("S","S",UDim2.fromOffset(59,59),"S")
touchControl("D","D",UDim2.fromOffset(118,59),"D")

local spectating = nil

local function stopSpectate()
	spectating = nil
	spectateLabel.Text = "SPECTATE : NONE"

	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end

local function spectate(target)
	if not target or target == player then
		stopSpectate()
		return
	end

	local targetHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")

	if targetHumanoid then
		spectating = target
		spectateLabel.Text = "SPECTATE : "..target.Name
		workspace.CurrentCamera.CameraSubject = targetHumanoid
	end
end

local function refreshPlayers()
	for _,obj in ipairs(playerList:GetChildren()) do
		if obj:IsA("TextButton") then
			obj:Destroy()
		end
	end

	for _,target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local b = button(playerList,target.Name.."Button",target.Name.."  |  "..target.DisplayName,UDim2.new(),UDim2.new(1,-10,0,40))
			b.LayoutOrder = target.UserId

			connect(b.Activated,function()
				spectate(target)
			end)
		end
	end

	local stop = button(playerList,"StopSpectate","STOP SPECTATE",UDim2.new(),UDim2.new(1,-10,0,40))
	stop.LayoutOrder = 999999

	connect(stop.Activated,stopSpectate)

	task.defer(function()
		playerList.CanvasSize = UDim2.fromOffset(0,playerLayout.AbsoluteContentSize.Y+10)
	end)
end

refreshPlayers()

connect(Players.PlayerAdded,function()
	refreshPlayers()
end)

connect(Players.PlayerRemoving,function(target)
	if spectating == target then
		stopSpectate()
	end
	refreshPlayers()
end)

local fps = 0
local frameCounter = 0
local lastFps = os.clock()

connect(RunService.RenderStepped,function()
	if destroyed then return end

	frameCounter += 1

	local now = os.clock()

	if now-lastFps >= 1 then
		fps = frameCounter
		frameCounter = 0
		lastFps = now

		fpsLabel.Text = "FPS : "..tostring(fps)
	end

	local movement = getMovement()

	if humanoid and humanoid.Parent and humanoid.Health > 0 then
		local state = humanoid:GetState()
		local isAir = state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping

		if isAir then
			local factor = math.clamp(config.AirControl/20,0,1)
			movement *= factor
		end

		humanoid:Move(movement,false)

		if config.ShiftLocked then
			local camera = workspace.CurrentCamera
			local root = character and character:FindFirstChild("HumanoidRootPart")

			if camera and root then
				local _,y = camera.CFrame:ToOrientation()
				root.CFrame = CFrame.new(root.Position)*CFrame.Angles(0,y,0)
			end

			humanoid.AutoRotate = false
		else
			humanoid.AutoRotate = true
		end
	end

	updateCameraVectors()
end)

connect(RunService.Heartbeat,function()
	if destroyed then return end

	local ok,ping = pcall(function()
		return player:GetNetworkPing()*1000
	end)

	if ok and ping then
		pingLabel.Text = "PING : "..tostring(math.floor(ping))
	end

	checkLabel.Text = "CHECK : "..tostring(math.floor(config.WalkSpeed))
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		applyHumanoid()
		humanoid.AutoRotate = not config.ShiftLocked
	end

	task.delay(.5,function()
		if not destroyed then
			updateJump()
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

connect(workspace:GetPropertyChangedSignal("CurrentCamera"),function()
	task.delay(.1,function()
		if not destroyed then
			updateJump()
		end
	end)
end)

applyHumanoid()
updateJump()
updateShiftButton()
showPage("MAIN")
saveConfig()
