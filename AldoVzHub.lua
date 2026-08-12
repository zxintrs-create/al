local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "DeltaMobileConfig.json"
local NOTE_FILE_PREFIX = "AldoVz_Note_"

local defaultConfig = {
	WalkSpeed = 16,
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1,
	ControllerEnabled = false,
	AirControl = 20
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

if _G.AldoVzMenuCleanup then
	pcall(_G.AldoVzMenuCleanup)
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
	local gui = playerGui:FindFirstChild(name)
	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
end

_G.AldoVzMenuCleanup = function()
	if destroyed then
		return
	end
	destroyed = true
	disconnectAll()
	destroyGui("AldoVzPremiumUI")
	destroyGui("DeltaMobileControls")
end

destroyGui("AldoVzPremiumUI")
destroyGui("DeltaMobileControls")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

_G.ShiftLocked = false

local BG = Color3.fromRGB(10,10,16)
local PANEL = Color3.fromRGB(18,18,28)
local PANEL2 = Color3.fromRGB(25,25,38)
local TEXT = Color3.fromRGB(245,245,255)
local MUTED = Color3.fromRGB(155,155,175)
local WHITE = Color3.fromRGB(255,255,255)
local BLUE = Color3.fromRGB(80,150,255)
local PURPLE = Color3.fromRGB(180,60,255)
local GREEN = Color3.fromRGB(60,200,120)
local RED = Color3.fromRGB(220,70,80)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AldoVzPremiumUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000000
screenGui.Parent = playerGui

local function corner(obj,radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,radius)
	c.Parent = obj
	return c
end

local function stroke(obj)
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Color = WHITE
	s.Transparency = .15
	s.Parent = obj

	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,BLUE),
		ColorSequenceKeypoint.new(.5,PURPLE),
		ColorSequenceKeypoint.new(1,BLUE)
	})
	g.Rotation = 0
	g.Parent = s

	task.spawn(function()
		while s.Parent and not destroyed do
			for r=0,360,2 do
				if not s.Parent or destroyed then
					return
				end
				g.Rotation = r
				RunService.RenderStepped:Wait()
			end
		end
	end)

	return s
end

local function gradient(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,BLUE),
		ColorSequenceKeypoint.new(.45,PURPLE),
		ColorSequenceKeypoint.new(.7,BLUE),
		ColorSequenceKeypoint.new(1,PURPLE)
	})
	g.Rotation = 25
	g.Parent = obj

	task.spawn(function()
		while g.Parent and not destroyed do
			local tween = TweenService:Create(
				g,
				TweenInfo.new(2.5,Enum.EasingStyle.Linear),
				{Rotation = 205}
			)
			tween:Play()
			tween.Completed:Wait()
			if not g.Parent then
				return
			end
			g.Rotation = 25
		end
	end)

	return g
end

local function makeFrame(parent,name,pos,size,bg,z)
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = pos
	f.Size = size
	f.BackgroundColor3 = bg or PANEL
	f.BorderSizePixel = 0
	f.ZIndex = z or 100
	f.Parent = parent
	corner(f,12)
	stroke(f)
	return f
end

local function makeButton(parent,name,pos,size,text,bg,z)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = bg or PANEL2
	b.BackgroundTransparency = .05
	b.TextColor3 = TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 110
	b.Parent = parent
	corner(b,9)
	stroke(b)
	return b
end

local function makeLabel(parent,name,pos,size,text,textSize,z)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Position = pos
	l.Size = size
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = TEXT
	l.Font = Enum.Font.GothamBold
	l.TextSize = textSize or 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = z or 110
	l.Parent = parent
	return l
end

local openButton = makeButton(
	screenGui,
	"OpenMenu",
	UDim2.new(0,12,0,72),
	UDim2.fromOffset(52,52),
	"☰",
	PANEL,
	1000
)

openButton.TextSize = 25

local menuFrame = makeFrame(
	screenGui,
	"MenuFrame",
	UDim2.new(0,12,0,132),
	UDim2.new(0,720,0,540),
	PANEL,
	900
)

menuFrame.Visible = false
gradient(menuFrame)

local menuTop = makeFrame(
	menuFrame,
	"MenuHeader",
	UDim2.fromOffset(8,8),
	UDim2.new(1,-16,0,54),
	PANEL2,
	910
)

local menuLabel = makeLabel(
	menuTop,
	"MenuLabel",
	UDim2.fromOffset(12,0),
	UDim2.new(1,-24,1,0),
	"👾 AldoVz    PING : 0    FPS : 0    CHECK : 0    SPEED : 16",
	13,
	920
)

local menuList = makeFrame(
	menuFrame,
	"MenuList",
	UDim2.fromOffset(8,70),
	UDim2.fromOffset(150,458),
	PANEL2,
	910
)

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,8)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = menuList

local function menuButton(text,order)
	local b = makeButton(
		menuList,
		text,
		UDim2.new(),
		UDim2.new(1,-16,0,48),
		text,
		PANEL,
		920
	)
	b.LayoutOrder = order
	return b
end

local mainButton = menuButton("MAIN",1)
local noteButton = menuButton("NOTE",2)
local controlButton = menuButton("CONTROL",3)
local playerButton = menuButton("PLAYER",4)

local area = makeFrame(
	menuFrame,
	"AreaMainFrame",
	UDim2.fromOffset(166,70),
	UDim2.new(1,-174,1,-78),
	PANEL2,
	910
)

local pages = {}

local function createPage(name)
	local p = Instance.new("ScrollingFrame")
	p.Name = name
	p.Position = UDim2.fromOffset(0,0)
	p.Size = UDim2.new(1,0,1,0)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 4
	p.CanvasSize = UDim2.new()
	p.Visible = false
	p.ZIndex = 930
	p.Parent = area
	pages[name] = p
	return p
end

local mainPage = createPage("Main")
local notePage = createPage("Note")
local controlPage = createPage("Control")
local playerPage = createPage("Player")

local function selectPage(name)
	for n,p in pairs(pages) do
		p.Visible = n == name
	end
end

connect(mainButton.Activated,function()
	selectPage("Main")
end)

connect(noteButton.Activated,function()
	selectPage("Note")
end)

connect(controlButton.Activated,function()
	selectPage("Control")
end)

connect(playerButton.Activated,function()
	selectPage("Player")
end)

local mainTitle = makeLabel(
	mainPage,
	"Title",
	UDim2.fromOffset(14,10),
	UDim2.new(1,-28,0,34),
	"MAIN",
	18,
	940
)

local speedLabel = makeLabel(
	mainPage,
	"SpeedLabel",
	UDim2.fromOffset(14,54),
	UDim2.new(1,-28,0,30),
	"WALK SPEED : 16",
	14,
	940
)

local speedMinus = makeButton(
	mainPage,
	"SpeedMinus",
	UDim2.fromOffset(14,90),
	UDim2.fromOffset(70,40),
	"-",
	PANEL,
	940
)

local speedValue = makeLabel(
	mainPage,
	"SpeedValue",
	UDim2.new(.5,-60,0,90),
	UDim2.fromOffset(120,40),
	"16",
	16,
	940
)

speedValue.TextXAlignment = Enum.TextXAlignment.Center

local speedPlus = makeButton(
	mainPage,
	"SpeedPlus",
	UDim2.new(1,-84,0,90),
	UDim2.fromOffset(70,40),
	"+",
	PANEL,
	940
)

local jumpShiftTitle = makeLabel(
	mainPage,
	"JumpShiftTitle",
	UDim2.fromOffset(14,145),
	UDim2.new(1,-28,0,30),
	"SETTING SHIFTLOCK / JUMP",
	14,
	940
)

local targetMode = "JUMP"

local targetButton = makeButton(
	mainPage,
	"TargetMode",
	UDim2.fromOffset(14,180),
	UDim2.new(1,-28,0,40),
	"← ↑ ↓ →    PILIH SET : JUMP",
	BLUE,
	940
)

local moveUp = makeButton(mainPage,"MoveUp",UDim2.new(.5,-28,0,230),UDim2.fromOffset(56,38),"↑",PANEL,940)
local moveLeft = makeButton(mainPage,"MoveLeft",UDim2.new(.08,0,0,270),UDim2.fromOffset(56,38),"←",PANEL,940)
local moveRight = makeButton(mainPage,"MoveRight",UDim2.new(.92,-56,0,270),UDim2.fromOffset(56,38),"→",PANEL,940)
local moveDown = makeButton(mainPage,"MoveDown",UDim2.new(.5,-28,0,310),UDim2.fromOffset(56,38),"↓",PANEL,940)

local sizePlus = makeButton(mainPage,"SizePlus",UDim2.fromOffset(14,365),UDim2.fromOffset(90,38),"SIZE +",PANEL,940)
local sizeMinus = makeButton(mainPage,"SizeMinus",UDim2.new(1,-104,0,365),UDim2.fromOffset(90,38),"SIZE -",PANEL,940)
local resetSize = makeButton(mainPage,"Reset",UDim2.new(.5,-45,0,365),UDim2.fromOffset(90,38),"RESET 🔁",PANEL,940)

local shiftButton = makeButton(
	mainPage,
	"ShiftLock",
	UDim2.fromOffset(14,415),
	UDim2.new(1,-28,0,40),
	"SHIFT LOCK : OFF",
	PURPLE,
	940
)

local jumpButton

local function getJump()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then
		local b = touchGui:FindFirstChild("JumpButton",true)
		if b then
			jumpButton = b
		end
	end
	return jumpButton
end

local function updateJump()
	local jump = getJump()
	local camera = workspace.CurrentCamera
	if not jump or not camera then
		return
	end

	local viewport = camera.ViewportSize

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

local shiftLockGui = Instance.new("ScreenGui")
shiftLockGui.Name = "DeltaMobileControls"
shiftLockGui.ResetOnSpawn = false
shiftLockGui.IgnoreGuiInset = true
shiftLockGui.DisplayOrder = 800000
shiftLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shiftLockGui.Enabled = false
shiftLockGui.Parent = playerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3 = WHITE
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000
crosshair.Parent = shiftLockGui
corner(crosshair,6)

local shiftVisual = makeButton(
	shiftLockGui,
	"ShiftLockButton",
	UDim2.new(config.ShiftX,0,config.ShiftY,0),
	UDim2.fromOffset(config.ShiftSize,config.ShiftSize),
	"⇧",
	WHITE,
	1000
)

shiftVisual.TextColor3 = Color3.fromRGB(30,30,40)
shiftVisual.TextSize = 22

local mainControls = Instance.new("Frame")
mainControls.Name = "ControlsFrame"
mainControls.Size = UDim2.fromOffset(250,250)
mainControls.Position = UDim2.new(0,18,1,-270)
mainControls.BackgroundTransparency = 1
mainControls.Visible = false
mainControls.ZIndex = 900
mainControls.Parent = shiftLockGui

local movement = {}

local function movementButton(name,pos,text)
	local b = makeButton(
		mainControls,
		name,
		pos,
		UDim2.fromOffset(75,75),
		text,
		WHITE,
		910
	)
	b.TextColor3 = Color3.fromRGB(20,20,30)
	return b
end

movement.Up = movementButton("Up",UDim2.fromOffset(87,0),"▲")
movement.Down = movementButton("Down",UDim2.fromOffset(87,150),"▼")
movement.Left = movementButton("Left",UDim2.fromOffset(0,75),"◀")
movement.Right = movementButton("Right",UDim2.fromOffset(174,75),"▶")

local wLock = makeButton(
	mainControls,
	"WLock",
	UDim2.fromOffset(200,180),
	UDim2.fromOffset(55,55),
	"W",
	RED,
	920
)

local moveState = {
	Forward=false,
	Backward=false,
	Left=false,
	Right=false,
	WLock=false
}

local activeInputs = {}

local function clearMovement()
	for k in pairs(moveState) do
		moveState[k] = false
	end

	for k in pairs(activeInputs) do
		activeInputs[k] = nil
	end
end

local function visual(button,on)
	if button and button.Parent then
		button.BackgroundColor3 = on and BLUE or WHITE
	end
end

local function setDirection(direction,state)
	moveState[direction] = state

	if direction=="Forward" then
		visual(movement.Up,state)
	elseif direction=="Backward" then
		visual(movement.Down,state)
	elseif direction=="Left" then
		visual(movement.Left,state)
	elseif direction=="Right" then
		visual(movement.Right,state)
	end
end

local function releaseInput(input)
	local data = activeInputs[input]
	if not data then
		return
	end

	activeInputs[input] = nil
	setDirection(data.direction,false)
end

local function bindDirection(button,direction)
	connect(button.InputBegan,function(input)
		if not config.ControllerEnabled then
			return
		end

		local t = input.UserInputType
		if t~=Enum.UserInputType.Touch and t~=Enum.UserInputType.MouseButton1 then
			return
		end

		activeInputs[input] = {
			direction=direction
		}

		setDirection(direction,true)
	end)

	connect(button.InputEnded,function(input)
		releaseInput(input)
	end)
end

bindDirection(movement.Up,"Forward")
bindDirection(movement.Down,"Backward")
bindDirection(movement.Left,"Left")
bindDirection(movement.Right,"Right")

connect(wLock.Activated,function()
	if not config.ControllerEnabled then
		return
	end

	moveState.WLock = not moveState.WLock
	wLock.BackgroundColor3 = moveState.WLock and GREEN or RED
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)

local smoothX = 0
local smoothZ = 0

local function updateCameraVectors()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local forward = Vector3.new(look.X,0,look.Z)
	local side = Vector3.new(right.X,0,right.Z)

	if forward.Magnitude>.001 then
		cachedForward=forward.Unit
	end

	if side.Magnitude>.001 then
		cachedSide=side.Unit
	end
end

local function getMoveVector()
	local x=0
	local z=0

	if moveState.Forward then z+=1 end
	if moveState.Backward then z-=1 end
	if moveState.Left then x-=1 end
	if moveState.Right then x+=1 end

	if x==0 and z==0 then
		if moveState.WLock then
			return cachedForward
		end

		smoothX=0
		smoothZ=0
		return Vector3.zero
	end

	smoothX+=(x-smoothX)*.95
	smoothZ+=(z-smoothZ)*.95

	local movementVector=cachedSide*smoothX+cachedForward*smoothZ

	if movementVector.Magnitude<.001 then
		return Vector3.zero
	end

	return movementVector.Unit
end

local function applyWalkSpeed()
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed=config.WalkSpeed
	end
end

local function updateShift()
	config.ShiftX=math.clamp(config.ShiftX,.02,.98)
	config.ShiftY=math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize=math.clamp(config.ShiftSize,20,100)

	shiftVisual.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
	shiftVisual.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function toggleShift()
	if not config.ControllerEnabled then
		return
	end

	_G.ShiftLocked=not _G.ShiftLocked
	crosshair.Visible=_G.ShiftLocked
	shiftVisual.BackgroundColor3=_G.ShiftLocked and PURPLE or WHITE
	shiftButton.Text=_G.ShiftLocked and "SHIFT LOCK : ON" or "SHIFT LOCK : OFF"

	if humanoid and humanoid.Parent then
		humanoid.AutoRotate=not _G.ShiftLocked
	end
end

connect(shiftVisual.Activated,toggleShift)
connect(shiftButton.Activated,toggleShift)

local function updateController()
	shiftLockGui.Enabled=config.ControllerEnabled
	mainControls.Visible=config.ControllerEnabled

	if not config.ControllerEnabled then
		_G.ShiftLocked=false
		crosshair.Visible=false
		clearMovement()
		shiftVisual.BackgroundColor3=WHITE
		shiftButton.Text="SHIFT LOCK : OFF"
	end
end

local function applyMoveStep(dx,dy)
	if targetMode=="JUMP" then
		config.JumpX=math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY=math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX=math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY=math.clamp(config.ShiftY+dy,.02,.98)
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

bindHold(moveUp,0,-.018)
bindHold(moveDown,0,.018)
bindHold(moveLeft,-.018,0)
bindHold(moveRight,.018,0)

connect(speedMinus.Activated,function()
	config.WalkSpeed=math.clamp(config.WalkSpeed-1,1,100)
	applyWalkSpeed()
	speedValue.Text=tostring(config.WalkSpeed)
	speedLabel.Text="WALK SPEED : "..tostring(config.WalkSpeed)
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed=math.clamp(config.WalkSpeed+1,1,100)
	applyWalkSpeed()
	speedValue.Text=tostring(config.WalkSpeed)
	speedLabel.Text="WALK SPEED : "..tostring(config.WalkSpeed)
end)

connect(targetButton.Activated,function()
	if targetMode=="JUMP" then
		targetMode="SHIFT"
		targetButton.Text="← ↑ ↓ →    PILIH SET : SHIFTLOCK"
		targetButton.BackgroundColor3=PURPLE
	else
		targetMode="JUMP"
		targetButton.Text="← ↑ ↓ →    PILIH SET : JUMP"
		targetButton.BackgroundColor3=BLUE
	end
end)

connect(sizePlus.Activated,function()
	if targetMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50)
		updateJump()
	else
		config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if targetMode=="JUMP" then
		config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50)
		updateJump()
	else
		config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(resetSize.Activated,function()
	if targetMode=="JUMP" then
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
end)

local noteTitle = makeLabel(
	notePage,
	"Title",
	UDim2.fromOffset(14,10),
	UDim2.new(1,-28,0,34),
	"NOTE",
	18,
	940
)

local noteList = Instance.new("ScrollingFrame")
noteList.Name="NoteList"
noteList.Position=UDim2.fromOffset(14,50)
noteList.Size=UDim2.new(1,-28,0,100)
noteList.BackgroundColor3=PANEL
noteList.BorderSizePixel=0
noteList.ScrollBarThickness=4
noteList.CanvasSize=UDim2.new()
noteList.ZIndex=940
noteList.Parent=notePage
corner(noteList,10)
stroke(noteList)

local noteLayout=Instance.new("UIListLayout")
noteLayout.Padding=UDim.new(0,5)
noteLayout.Parent=noteList

local noteBox=Instance.new("TextBox")
noteBox.Name="NoteText"
noteBox.Position=UDim2.fromOffset(14,162)
noteBox.Size=UDim2.new(1,-28,0,190)
noteBox.BackgroundColor3=PANEL
noteBox.TextColor3=TEXT
noteBox.PlaceholderText="Tulis catatan..."
noteBox.PlaceholderColor3=MUTED
noteBox.Text=""
noteBox.TextSize=14
noteBox.Font=Enum.Font.Gotham
noteBox.TextWrapped=true
noteBox.TextXAlignment=Enum.TextXAlignment.Left
noteBox.TextYAlignment=Enum.TextYAlignment.Top
noteBox.ClearTextOnFocus=false
noteBox.MultiLine=true
noteBox.ZIndex=940
noteBox.Parent=notePage
corner(noteBox,10)
stroke(noteBox)

local noteSave=makeButton(notePage,"SaveNote",UDim2.fromOffset(14,365),UDim2.fromOffset(90,40),"SAVE",GREEN,940)
local noteNew=makeButton(notePage,"NewNote",UDim2.fromOffset(112,365),UDim2.fromOffset(90,40),"NEW",BLUE,940)
local noteDelete=makeButton(notePage,"DeleteNote",UDim2.fromOffset(210,365),UDim2.fromOffset(90,40),"DELETE",RED,940)

local selectedNote=1

local function noteFile(index)
	return NOTE_FILE_PREFIX..tostring(index)..".txt"
end

local function loadNote(index)
	selectedNote=index
	local text=""

	pcall(function()
		if readfile and isfile and isfile(noteFile(index)) then
			text=readfile(noteFile(index))
		end
	end)

	noteBox.Text=text
end

local function rebuildNotes()
	for _,child in ipairs(noteList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for i=1,10 do
		local b=makeButton(
			noteList,
			"Note"..i,
			UDim2.new(),
			UDim2.new(1,-8,0,34),
			"NOTE "..i,
			i==selectedNote and BLUE or PANEL2,
			950
		)

		connect(b.Activated,function()
			loadNote(i)
			rebuildNotes()
		end)
	end

	task.defer(function()
		noteList.CanvasSize=UDim2.fromOffset(0,noteLayout.AbsoluteContentSize.Y+5)
	end)
end

connect(noteSave.Activated,function()
	pcall(function()
		if writefile then
			writefile(noteFile(selectedNote),noteBox.Text)
		end
	end)
	rebuildNotes()
end)

connect(noteNew.Activated,function()
	for i=1,100 do
		local exists=false
		pcall(function()
			if isfile and isfile(noteFile(i)) then
				exists=true
			end
		end)

		if not exists then
			selectedNote=i
			noteBox.Text=""
			rebuildNotes()
			break
		end
	end
end)

connect(noteDelete.Activated,function()
	pcall(function()
		if delfile and isfile and isfile(noteFile(selectedNote)) then
			delfile(noteFile(selectedNote))
		elseif writefile then
			writefile(noteFile(selectedNote),"")
		end
	end)

	noteBox.Text=""
	rebuildNotes()
end)

local controlTitle=makeLabel(
	controlPage,
	"Title",
	UDim2.fromOffset(14,10),
	UDim2.new(1,-28,0,34),
	"CONTROL",
	18,
	940
)

local controllerToggle=makeButton(
	controlPage,
	"ControllerToggle",
	UDim2.fromOffset(14,52),
	UDim2.new(1,-28,0,44),
	"CONTROLLER : OFF",
	RED,
	940
)

local airTitle=makeLabel(
	controlPage,
	"AirTitle",
	UDim2.fromOffset(14,112),
	UDim2.new(1,-28,0,30),
	"SETTING AIR CONTROL",
	13,
	940
)

local airMinus=makeButton(controlPage,"AirMinus",UDim2.fromOffset(14,150),UDim2.fromOffset(70,42),"-",PANEL,940)

local airValue=makeLabel(
	controlPage,
	"AirValue",
	UDim2.new(.5,-70,0,150),
	UDim2.fromOffset(140,42),
	"20",
	16,
	940
)

airValue.TextXAlignment=Enum.TextXAlignment.Center

local airPlus=makeButton(controlPage,"AirPlus",UDim2.new(1,-84,0,150),UDim2.fromOffset(70,42),"+",PANEL,940)

connect(controllerToggle.Activated,function()
	config.ControllerEnabled=not config.ControllerEnabled
	updateController()

	if config.ControllerEnabled then
		controllerToggle.Text="CONTROLLER : ON"
		controllerToggle.BackgroundColor3=GREEN
	else
		controllerToggle.Text="CONTROLLER : OFF"
		controllerToggle.BackgroundColor3=RED
	end
end)

connect(airMinus.Activated,function()
	config.AirControl=math.clamp(config.AirControl-5,0,100)
	airValue.Text=tostring(config.AirControl)
end)

connect(airPlus.Activated,function()
	config.AirControl=math.clamp(config.AirControl+5,0,100)
	airValue.Text=tostring(config.AirControl)
end)

local playerTitle=makeLabel(
	playerPage,
	"Title",
	UDim2.fromOffset(14,10),
	UDim2.new(1,-28,0,34),
	"PLAYER",
	18,
	940
)

local spectateStatus=makeLabel(
	playerPage,
	"SpectateStatus",
	UDim2.fromOffset(14,48),
	UDim2.new(1,-28,0,30),
	"SPECTATE : OFF",
	12,
	940
)

local playerList=Instance.new("ScrollingFrame")
playerList.Name="PlayerList"
playerList.Position=UDim2.fromOffset(14,84)
playerList.Size=UDim2.new(1,-28,1,-98)
playerList.BackgroundColor3=PANEL
playerList.BorderSizePixel=0
playerList.ScrollBarThickness=4
playerList.CanvasSize=UDim2.new()
playerList.ZIndex=940
playerList.Parent=playerPage
corner(playerList,10)
stroke(playerList)

local playerLayout=Instance.new("UIListLayout")
playerLayout.Padding=UDim.new(0,6)
playerLayout.Parent=playerList

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
	if not camera then
		return
	end

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

	local allPlayers=Players:GetPlayers()

	table.sort(allPlayers,function(a,b)
		return a.Name:lower()<b.Name:lower()
	end)

	for _,p in ipairs(allPlayers) do
		if p~=player then
			local b=makeButton(
				playerList,
				p.Name,
				UDim2.new(),
				UDim2.new(1,-8,0,42),
				p.Name,
				PANEL2,
				950
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

connect(openButton.Activated,function()
	menuFrame.Visible=not menuFrame.Visible
end)

connect(UserInputService.InputEnded,function(input)
	releaseInput(input)

	local t=input.UserInputType

	if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
		for button in pairs(holding) do
			holding[button]=false
		end
	end
end)

local fpsFrames=0
local fpsTime=os.clock()
local fpsValue=0

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	fpsFrames+=1

	local now=os.clock()

	if now-fpsTime>=1 then
		fpsValue=fpsFrames
		fpsFrames=0
		fpsTime=now
	end

	if holding[moveUp] then
		applyMoveStep(0,-.018)
	end

	if holding[moveDown] then
		applyMoveStep(0,.018)
	end

	if holding[moveLeft] then
		applyMoveStep(-.018,0)
	end

	if holding[moveRight] then
		applyMoveStep(.018,0)
	end

	if config.ControllerEnabled and character and character.Parent and humanoid and humanoid.Health>0 then
		updateCameraVectors()

		local movementVector=getMoveVector()
		local state=humanoid:GetState()

		if state==Enum.HumanoidStateType.Freefall or state==Enum.HumanoidStateType.Jumping then
			movementVector*=math.clamp(config.AirControl,0,100)/100
		end

		humanoid:Move(movementVector,false)

		if _G.ShiftLocked then
			local camera=workspace.CurrentCamera
			local root=character:FindFirstChild("HumanoidRootPart")

			if camera and root then
				local _,y=camera.CFrame:ToOrientation()
				root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,y,0)
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
			"👾 AldoVz    PING : "
			..tostring(ping)
			.."    FPS : "
			..tostring(fpsValue)
			.."    CHECK : 0    SPEED : "
			..tostring(math.floor(config.WalkSpeed))
	end
end)

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then
		return
	end

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

speedValue.Text=tostring(config.WalkSpeed)
speedLabel.Text="WALK SPEED : "..tostring(config.WalkSpeed)
airValue.Text=tostring(config.AirControl)

updateController()
updateJump()
updateShift()
applyWalkSpeed()
loadNote(1)
rebuildNotes()
rebuildPlayers()
selectPage("Main")

menuFrame.Visible=false
