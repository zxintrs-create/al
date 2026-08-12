local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG_FILE = "AldoVzPremiumConfig.json"
local NOTE_PREFIX = "AldoVzNote_"

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
	ControllerEnabled = true
}

local config = {}
for k,v in pairs(defaultConfig) do
	config[k] = v
end

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

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE,HttpService:JSONEncode(config))
		end
	end)
end

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

_G.AldoVzPremiumCleanup = function()
	if destroyed then return end
	destroyed = true
	disconnectAll()
	pcall(function()
		local a = playerGui:FindFirstChild("AldoVzPremium")
		if a then a:Destroy() end
	end)
end

local old = playerGui:FindFirstChild("AldoVzPremium")
if old then
	old:Destroy()
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui")
gui.Name = "AldoVzPremium"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = playerGui

local function corner(obj,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r)
	c.Parent = obj
	return c
end

local function gradient(obj,colors,duration)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(colors)
	g.Rotation = 0
	g.Offset = Vector2.new(-1,0)
	g.Parent = obj

	task.spawn(function()
		while obj.Parent and g.Parent do
			g.Offset = Vector2.new(-1,0)
			local t = TweenService:Create(
				g,
				TweenInfo.new(duration or 3,Enum.EasingStyle.Linear),
				{Offset=Vector2.new(1,0)}
			)
			t:Play()
			t.Completed:Wait()
		end
	end)

	return g
end

local function stroke(obj)
	local s = Instance.new("UIStroke")
	s.Name = "PremiumStroke"
	s.Thickness = 1.8
	s.Transparency = 0
	s.Color = Color3.new(1,1,1)
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj

	local g = Instance.new("UIGradient")
	g.Name = "StrokeGradient"
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(.22,Color3.fromRGB(120,70,255)),
		ColorSequenceKeypoint.new(.45,Color3.fromRGB(50,180,255)),
		ColorSequenceKeypoint.new(.65,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(.82,Color3.fromRGB(180,60,255)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
	})
	g.Offset = Vector2.new(-1,0)
	g.Parent = s

	task.spawn(function()
		while obj.Parent and s.Parent and g.Parent do
			g.Offset = Vector2.new(-1,0)
			local t = TweenService:Create(
				g,
				TweenInfo.new(2.2,Enum.EasingStyle.Linear),
				{Offset=Vector2.new(1,0)}
			)
			t:Play()
			t.Completed:Wait()
		end
	end)

	return s
end

local function premium(obj)
	if not obj:IsA("GuiObject") then return end
	corner(obj,10)
	stroke(obj)
end

local function label(parent,text,pos,size,textSize)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = pos
	l.Size = size
	l.Text = text
	l.TextColor3 = Color3.new(1,1,1)
	l.Font = Enum.Font.GothamBold
	l.TextSize = textSize or 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function button(parent,name,text,pos,size)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(18,18,30)
	b.BackgroundTransparency = .05
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.BorderSizePixel = 0
	b.Active = true
	b.Selectable = false
	b.Parent = parent
	premium(b)
	return b
end

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.AnchorPoint = Vector2.new(0,0)
openButton.Position = UDim2.new(0,8,0,48)
openButton.Size = UDim2.fromOffset(48,48)
openButton.Text = "👾"
openButton.TextSize = 25
openButton.Font = Enum.Font.GothamBold
openButton.TextColor3 = Color3.new(1,1,1)
openButton.BackgroundColor3 = Color3.fromRGB(15,15,28)
openButton.AutoButtonColor = false
openButton.BorderSizePixel = 0
openButton.Parent = gui
premium(openButton)
gradient(openButton,{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(15,15,30)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(80,30,130)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(15,15,30))
},2.5)

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.AnchorPoint = Vector2.new(0,0)
menu.Position = UDim2.new(0,8,0,102)
menu.Size = UDim2.new(0.96,0,0.78,0)
menu.BackgroundColor3 = Color3.fromRGB(9,10,20)
menu.BorderSizePixel = 0
menu.Visible = false
menu.ClipsDescendants = true
menu.Parent = gui
premium(menu)
gradient(menu,{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(8,10,20)),
	ColorSequenceKeypoint.new(.3,Color3.fromRGB(25,15,48)),
	ColorSequenceKeypoint.new(.55,Color3.fromRGB(12,30,48)),
	ColorSequenceKeypoint.new(.8,Color3.fromRGB(30,15,55)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(8,10,20))
},4)

local menuSize = Instance.new("UISizeConstraint")
menuSize.MinSize = Vector2.new(300,420)
menuSize.MaxSize = Vector2.new(700,650)
menuSize.Parent = menu

local header = Instance.new("Frame")
header.Name = "MenuHeader"
header.Position = UDim2.fromOffset(8,8)
header.Size = UDim2.new(1,-16,0,58)
header.BackgroundColor3 = Color3.fromRGB(15,15,28)
header.BorderSizePixel = 0
header.Parent = menu
premium(header)

local headerText = label(
	header,
	"👾 AldoVz",
	UDim2.fromOffset(12,5),
	UDim2.new(.28,0,0,24),
	17
)

local pingLabel = label(header,"PING : 0",UDim2.new(.29,0,0,8),UDim2.new(.16,0,0,20),12)
local fpsLabel = label(header,"FPS : 0",UDim2.new(.46,0,0,8),UDim2.new(.15,0,0,20),12)
local checkLabel = label(header,"CHECK : 0",UDim2.new(.62,0,0,8),UDim2.new(.18,0,0,20),12)
local speedLabel = label(header,"SPEED : "..tostring(config.WalkSpeed),UDim2.new(.80,0,0,8),UDim2.new(.18,0,0,20),12)

local command = Instance.new("TextBox")
command.Name = "InfiniteYieldCommand"
command.Position = UDim2.new(.28,0,0,30)
command.Size = UDim2.new(.69,0,0,22)
command.BackgroundColor3 = Color3.fromRGB(8,8,16)
command.BorderSizePixel = 0
command.Text = ""
command.PlaceholderText = "COMMAND INFINITE YIELD :_____________:"
command.PlaceholderColor3 = Color3.fromRGB(150,150,170)
command.TextColor3 = Color3.new(1,1,1)
command.TextSize = 11
command.Font = Enum.Font.Code
command.ClearTextOnFocus = false
command.Parent = header
corner(command,5)

local left = Instance.new("Frame")
left.Name = "MenuList"
left.Position = UDim2.fromOffset(8,74)
left.Size = UDim2.new(.27,-4,1,-82)
left.BackgroundColor3 = Color3.fromRGB(12,13,25)
left.BorderSizePixel = 0
left.ClipsDescendants = true
left.Parent = menu
premium(left)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "UIScrollingBUTTON"
scroll.Size = UDim2.new(1,-8,1,-8)
scroll.Position = UDim2.fromOffset(4,4)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = left

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,7)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = scroll

local right = Instance.new("Frame")
right.Name = "MainFrame"
right.Position = UDim2.new(.27,12,0,74)
right.Size = UDim2.new(.73,-20,1,-82)
right.BackgroundColor3 = Color3.fromRGB(11,12,23)
right.BorderSizePixel = 0
right.ClipsDescendants = true
right.Parent = menu
premium(right)

local function clearMain()
	for _,v in ipairs(right:GetChildren()) do
		if not v:IsA("UIStroke") and not v:IsA("UIGradient") and not v:IsA("UICorner") then
			v:Destroy()
		end
	end
end

local pages = {}

local function createPage(name)
	local p = Instance.new("ScrollingFrame")
	p.Name = name
	p.Size = UDim2.new(1,-14,1,-14)
	p.Position = UDim2.fromOffset(7,7)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ScrollBarThickness = 3
	p.AutomaticCanvasSize = Enum.AutomaticSize.Y
	p.CanvasSize = UDim2.new()
	p.Visible = false
	p.Parent = right
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0,8)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.Parent = p
	pages[name] = p
	return p
end

local function pageTitle(parent,text)
	local l = label(parent,text,UDim2.new(),UDim2.new(1,0,0,34),18)
	l.TextXAlignment = Enum.TextXAlignment.Center
	return l
end

local mainPage = createPage("MainPage")
local notePage = createPage("NotePage")
local controlPage = createPage("ControlPage")
local playerPage = createPage("PlayerPage")

local currentPage = mainPage

local function showPage(page)
	for _,p in pairs(pages) do
		p.Visible = false
	end
	page.Visible = true
	currentPage = page
end

local mainButton = button(scroll,"MainButton","MAIN",UDim2.new(),UDim2.new(1,-8,0,42))
local noteButton = button(scroll,"NoteButton","NOTE",UDim2.new(),UDim2.new(1,-8,0,42))
local controlButton = button(scroll,"ControlButton","CONTROL",UDim2.new(),UDim2.new(1,-8,0,42))
local playerButton = button(scroll,"PlayerButton","PLAYER",UDim2.new(),UDim2.new(1,-8,0,42))

connect(mainButton.Activated,function()
	showPage(mainPage)
end)

connect(noteButton.Activated,function()
	showPage(notePage)
end)

connect(controlButton.Activated,function()
	showPage(controlPage)
end)

connect(playerButton.Activated,function()
	showPage(playerPage)
end)

pageTitle(mainPage,"MAIN")

local speedBox = Instance.new("Frame")
speedBox.Size = UDim2.new(1,-10,0,90)
speedBox.BackgroundColor3 = Color3.fromRGB(19,20,34)
speedBox.BorderSizePixel = 0
speedBox.Parent = mainPage
premium(speedBox)

label(speedBox,"WALK SPEED",UDim2.fromOffset(12,8),UDim2.new(.5,0,0,25),15)

local speedValue = label(
	speedBox,
	tostring(config.WalkSpeed),
	UDim2.new(.5,0,0,8),
	UDim2.new(.45,-10,0,25),
	15
)
speedValue.TextXAlignment = Enum.TextXAlignment.Center

local speedMinus = button(speedBox,"SpeedMinus","−",UDim2.fromOffset(12,42),UDim2.fromOffset(55,38))
local speedPlus = button(speedBox,"SpeedPlus","+",UDim2.new(1,-67,0,42),UDim2.fromOffset(55,38))

connect(speedMinus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed-1,1,500)
	speedValue.Text = tostring(config.WalkSpeed)
	speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
	if humanoid then humanoid.WalkSpeed = config.WalkSpeed end
end)

connect(speedPlus.Activated,function()
	config.WalkSpeed = math.clamp(config.WalkSpeed+1,1,500)
	speedValue.Text = tostring(config.WalkSpeed)
	speedLabel.Text = "SPEED : "..tostring(config.WalkSpeed)
	if humanoid then humanoid.WalkSpeed = config.WalkSpeed end
end)

local jumpBox = Instance.new("Frame")
jumpBox.Size = UDim2.new(1,-10,0,220)
jumpBox.BackgroundColor3 = Color3.fromRGB(19,20,34)
jumpBox.BorderSizePixel = 0
jumpBox.Parent = mainPage
premium(jumpBox)

label(jumpBox,"SETTING SHIFTLOCK / JUMP",UDim2.new(),UDim2.new(1,0,0,30),15).TextXAlignment = Enum.TextXAlignment.Center

local targetMode = "JUMP"

local targetButton = button(
	jumpBox,
	"Target",
	"PILIH SET : JUMP",
	UDim2.new(.08,0,0,38),
	UDim2.new(.84,0,0,35)
)

local up = button(jumpBox,"Up","↑",UDim2.new(.5,-28,0,80),UDim2.fromOffset(56,35))
local leftMove = button(jumpBox,"Left","←",UDim2.new(.15,0,0,118),UDim2.fromOffset(56,35))
local rightMove = button(jumpBox,"Right","→",UDim2.new(.85,-56,0,118),UDim2.fromOffset(56,35))
local down = button(jumpBox,"Down","↓",UDim2.new(.5,-28,0,156),UDim2.fromOffset(56,35))

local sizePlus = button(jumpBox,"SizePlus","SIZE +",UDim2.new(.08,0,0,194),UDim2.new(.25,0,0,32))
local resetSize = button(jumpBox,"Reset","RESET 🔁",UDim2.new(.375,0,0,194),UDim2.new(.25,0,0,32))
local sizeMinus = button(jumpBox,"SizeMinus","SIZE -",UDim2.new(.67,0,0,194),UDim2.new(.25,0,0,32))

local jumpButton

local function getJumpButton()
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if not touchGui then return nil end
	return touchGui:FindFirstChild("JumpButton",true)
end

local function updateJump()
	jumpButton = getJumpButton()
	if not jumpButton then return end
	local camera = workspace.CurrentCamera
	if not camera then return end
	local v = camera.ViewportSize
	local size = math.max(40,math.floor(v.Y*config.JumpSize))
	pcall(function()
		jumpButton.AnchorPoint = Vector2.new(.5,.5)
		jumpButton.Position = UDim2.new(config.JumpX,0,config.JumpY,0)
		jumpButton.Size = UDim2.fromOffset(size,size)
	end)
end

local shiftLock = false
local shiftButton

local function updateShift()
	if not shiftButton then return end
	shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function moveSetting(dx,dy)
	if targetMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
		config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
		updateJump()
	else
		config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
		config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
		updateShift()
	end
end

connect(targetButton.Activated,function()
	if targetMode == "JUMP" then
		targetMode = "SHIFT"
		targetButton.Text = "PILIH SET : SHIFTLOCK"
	else
		targetMode = "JUMP"
		targetButton.Text = "PILIH SET : JUMP"
	end
end)

connect(up.Activated,function() moveSetting(0,-.018) end)
connect(down.Activated,function() moveSetting(0,.018) end)
connect(leftMove.Activated,function() moveSetting(-.018,0) end)
connect(rightMove.Activated,function() moveSetting(.018,0) end)

connect(sizePlus.Activated,function()
	if targetMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize+.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
		updateShift()
	end
end)

connect(sizeMinus.Activated,function()
	if targetMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize-.05,.05,.5)
		updateJump()
	else
		config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
		updateShift()
	end
end)

connect(resetSize.Activated,function()
	if targetMode == "JUMP" then
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

local wasdFrame = Instance.new("Frame")
wasdFrame.Name = "WASDFrame"
wasdFrame.AnchorPoint = Vector2.new(.5,.5)
wasdFrame.Position = UDim2.new(0,100,1,-135)
wasdFrame.Size = UDim2.fromOffset(230,190)
wasdFrame.BackgroundTransparency = 1
wasdFrame.Parent = gui

local moveState = {
	Forward=false,
	Backward=false,
	Left=false,
	Right=false,
	WLock=false
}

local activeInputs = {}

local function moveButton(name,text,x,y)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = UDim2.fromOffset(x,y)
	b.Size = UDim2.fromOffset(60,60)
	b.Text = text
	b.TextSize = 26
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.BackgroundColor3 = Color3.new(1,1,1)
	b.BackgroundTransparency = .15
	b.AutoButtonColor = false
	b.BorderSizePixel = 0
	b.Parent = wasdFrame
	corner(b,14)
	return b
end

local btnUp = moveButton("Up","▲",85,0)
local btnDown = moveButton("Down","▼",85,125)
local btnLeft = moveButton("Left","◀",20,63)
local btnRight = moveButton("Right","▶",150,63)

local wLock = Instance.new("TextButton")
wLock.Name = "WLock"
wLock.Position = UDim2.fromOffset(208,63)
wLock.Size = UDim2.fromOffset(58,58)
wLock.Text = "W"
wLock.TextSize = 24
wLock.Font = Enum.Font.GothamBold
wLock.TextColor3 = Color3.new(1,1,1)
wLock.BackgroundColor3 = Color3.fromRGB(220,70,70)
wLock.AutoButtonColor = false
wLock.BorderSizePixel = 0
wLock.Parent = wasdFrame
corner(wLock,58)

local controllerOff = false

local function controllerVisual()
	local visible = not controllerOff
	wasdFrame.Visible = visible
end

local function setDirection(name,value,button)
	moveState[name] = value
	button.BackgroundColor3 = value and Color3.fromRGB(70,150,255) or Color3.new(1,1,1)
end

local function bindMove(button,name)
	connect(button.InputBegan,function(input)
		if controllerOff then return end
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		activeInputs[input] = name
		setDirection(name,true,button)
	end)

	connect(button.InputEnded,function(input)
		local n = activeInputs[input]
		if n then
			activeInputs[input] = nil
			setDirection(n,false,button)
		end
	end)
end

bindMove(btnUp,"Forward")
bindMove(btnDown,"Backward")
bindMove(btnLeft,"Left")
bindMove(btnRight,"Right")

connect(wLock.Activated,function()
	moveState.WLock = not moveState.WLock
	wLock.BackgroundColor3 = moveState.WLock and Color3.fromRGB(70,200,100) or Color3.fromRGB(220,70,70)
end)

connect(UserInputService.InputEnded,function(input)
	activeInputs[input] = nil
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)
local smoothX = 0
local smoothZ = 0

local function updateCamera()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector
	local f = Vector3.new(look.X,0,look.Z)
	local s = Vector3.new(right.X,0,right.Z)
	if f.Magnitude > .001 then cachedForward = f.Unit end
	if s.Magnitude > .001 then cachedSide = s.Unit end
end

local function getMovement()
	if controllerOff then
		return Vector3.zero
	end

	local x = 0
	local z = 0

	if moveState.Forward then z += 1 end
	if moveState.Backward then z -= 1 end
	if moveState.Left then x -= 1 end
	if moveState.Right then x += 1 end

	if x == 0 and z == 0 and moveState.WLock then
		return cachedForward
	end

	local targetX = x
	local targetZ = z

	smoothX += (targetX-smoothX)*.9
	smoothZ += (targetZ-smoothZ)*.9

	if math.abs(smoothX)<.005 then smoothX=0 end
	if math.abs(smoothZ)<.005 then smoothZ=0 end

	if smoothX == 0 and smoothZ == 0 then
		return Vector3.zero
	end

	local v = cachedSide*smoothX + cachedForward*smoothZ
	if v.Magnitude < .001 then return Vector3.zero end
	return v.Unit
end

connect(RunService.RenderStepped,function()
	if destroyed or not humanoid or humanoid.Health <= 0 then return end

	updateCamera()

	if config.ControllerEnabled then
		humanoid:Move(getMovement(),false)
	end

	humanoid.WalkSpeed = config.WalkSpeed

	if shiftLock and character and character.Parent then
		local root = character:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		if root and camera then
			local _,y = camera.CFrame:ToOrientation()
			root.CFrame = CFrame.new(root.Position)*CFrame.Angles(0,y,0)
			humanoid.AutoRotate = false
		end
	else
		humanoid.AutoRotate = true
	end

	humanoid.CameraOffset = Vector3.zero
end)

local shiftCrosshair = Instance.new("Frame")
shiftCrosshair.Name = "ShiftCrosshair"
shiftCrosshair.AnchorPoint = Vector2.new(.5,.5)
shiftCrosshair.Position = UDim2.new(.5,0,.5,0)
shiftCrosshair.Size = UDim2.fromOffset(6,6)
shiftCrosshair.BackgroundColor3 = Color3.new(1,1,1)
shiftCrosshair.BorderSizePixel = 0
shiftCrosshair.Visible = false
shiftCrosshair.Parent = gui
corner(shiftCrosshair,6)

shiftButton = Instance.new("TextButton")
shiftButton.Name = "ShiftLockButton"
shiftButton.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
shiftButton.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
shiftButton.AnchorPoint = Vector2.new(.5,.5)
shiftButton.Text = "◉"
shiftButton.TextSize = 17
shiftButton.Font = Enum.Font.GothamBold
shiftButton.TextColor3 = Color3.new(1,1,1)
shiftButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
shiftButton.AutoButtonColor = false
shiftButton.BorderSizePixel = 0
shiftButton.Parent = gui
corner(shiftButton,100)
stroke(shiftButton)

connect(shiftButton.Activated,function()
	shiftLock = not shiftLock
	shiftButton.BackgroundColor3 = shiftLock and Color3.fromRGB(170,0,255) or Color3.fromRGB(255,255,255)
	shiftCrosshair.Visible = shiftLock
	humanoid.AutoRotate = not shiftLock
end)

pageTitle(notePage,"NOTE")

local noteList = Instance.new("ScrollingFrame")
noteList.Name = "NoteList"
noteList.Size = UDim2.new(1,-10,0,130)
noteList.BackgroundColor3 = Color3.fromRGB(18,19,32)
noteList.BorderSizePixel = 0
noteList.ScrollBarThickness = 3
noteList.AutomaticCanvasSize = Enum.AutomaticSize.Y
noteList.CanvasSize = UDim2.new()
noteList.Parent = notePage
premium(noteList)

local noteLayout = Instance.new("UIListLayout")
noteLayout.Padding = UDim.new(0,5)
noteLayout.Parent = noteList

local noteEditor = Instance.new("TextBox")
noteEditor.Name = "NoteEditor"
noteEditor.Size = UDim2.new(1,-10,0,130)
noteEditor.BackgroundColor3 = Color3.fromRGB(8,9,18)
noteEditor.TextColor3 = Color3.new(1,1,1)
noteEditor.PlaceholderText = "Tulis catatan..."
noteEditor.PlaceholderColor3 = Color3.fromRGB(130,130,150)
noteEditor.Text = ""
noteEditor.TextSize = 13
noteEditor.Font = Enum.Font.Code
noteEditor.TextWrapped = true
noteEditor.TextXAlignment = Enum.TextXAlignment.Left
noteEditor.TextYAlignment = Enum.TextYAlignment.Top
noteEditor.MultiLine = true
noteEditor.ClearTextOnFocus = false
noteEditor.Parent = notePage
corner(noteEditor,8)
stroke(noteEditor)

local noteName = Instance.new("TextBox")
noteName.Size = UDim2.new(1,-10,0,38)
noteName.BackgroundColor3 = Color3.fromRGB(18,19,32)
noteName.TextColor3 = Color3.new(1,1,1)
noteName.PlaceholderText = "Nama file note 1"
noteName.Text = ""
noteName.Font = Enum.Font.Gotham
noteName.TextSize = 13
noteName.ClearTextOnFocus = false
noteName.Parent = notePage
corner(noteName,8)
stroke(noteName)

local noteSave = button(notePage,"SaveNote","SAVE NOTE",UDim2.new(),UDim2.new(1,-10,0,40))
local noteCopy = button(notePage,"CopyNote","COPY",UDim2.new(),UDim2.new(1,-10,0,40))
local notePaste = button(notePage,"PasteNote","PASTE",UDim2.new(),UDim2.new(1,-10,0,40))

local function getNoteFiles()
	local result = {}
	pcall(function()
		if listfiles then
			for _,path in ipairs(listfiles("")) do
				local name = path:match("([^/\\]+)$")
				if name and name:sub(1,#NOTE_PREFIX) == NOTE_PREFIX then
					table.insert(result,name)
				end
			end
		end
	end)
	table.sort(result)
	return result
end

local function refreshNotes()
	for _,v in ipairs(noteList:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,file in ipairs(getNoteFiles()) do
		local b = button(noteList,file:sub(#NOTE_PREFIX+1),UDim2.new(),UDim2.new(1,-8,0,34))
		connect(b.Activated,function()
			pcall(function()
				noteEditor.Text = readfile(file)
				noteName.Text = file:sub(#NOTE_PREFIX+1):gsub("%.txt$","")
			end)
		end)
	end
end

connect(noteSave.Activated,function()
	local n = noteName.Text
	if n == "" then n = "1" end
	n = n:gsub("[^%w_%-%s]","_")
	pcall(function()
		if writefile then
			writefile(NOTE_PREFIX..n..".txt",noteEditor.Text)
		end
	end)
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

refreshNotes()

pageTitle(controlPage,"CONTROL")

local controllerToggle = button(
	controlPage,
	"ControllerToggle",
	config.ControllerEnabled and "CONTROLLER : ON" or "CONTROLLER : OFF",
	UDim2.new(),
	UDim2.new(1,-10,0,45)
)

local airBox = Instance.new("Frame")
airBox.Size = UDim2.new(1,-10,0,110)
airBox.BackgroundColor3 = Color3.fromRGB(18,19,32)
airBox.BorderSizePixel = 0
airBox.Parent = controlPage
premium(airBox)

label(airBox,"SETTING AIR CONTROL",UDim2.fromOffset(10,8),UDim2.new(.6,0,0,25),14)

local airValue = label(
	airBox,
	tostring(config.AirControl),
	UDim2.new(.65,0,0,8),
	UDim2.new(.3,0,0,25),
	15
)
airValue.TextXAlignment = Enum.TextXAlignment.Center

local airMinus = button(airBox,"AirMinus","−",UDim2.fromOffset(10,50),UDim2.fromOffset(55,38))
local airPlus = button(airBox,"AirPlus","+",UDim2.new(1,-65,0,50),UDim2.fromOffset(55,38))

connect(controllerToggle.Activated,function()
	config.ControllerEnabled = not config.ControllerEnabled
	controllerToggle.Text = config.ControllerEnabled and "CONTROLLER : ON" or "CONTROLLER : OFF"
	controllerToggle.BackgroundColor3 = config.ControllerEnabled and Color3.fromRGB(30,120,70) or Color3.fromRGB(130,35,45)
	if not config.ControllerEnabled then
		moveState.Forward=false
		moveState.Backward=false
		moveState.Left=false
		moveState.Right=false
	end
end)

connect(airMinus.Activated,function()
	config.AirControl = math.clamp(config.AirControl-1,0,100)
	airValue.Text = tostring(config.AirControl)
end)

connect(airPlus.Activated,function()
	config.AirControl = math.clamp(config.AirControl+1,0,100)
	airValue.Text = tostring(config.AirControl)
end)

pageTitle(playerPage,"PLAYER")

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1,-10,1,-45)
playerList.BackgroundColor3 = Color3.fromRGB(18,19,32)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.CanvasSize = UDim2.new()
playerList.Parent = playerPage
premium(playerList)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0,6)
playerLayout.Parent = playerList

local spectating = false
local oldCameraSubject

local function stopSpectate()
	local camera = workspace.CurrentCamera
	if camera and humanoid then
		camera.CameraSubject = humanoid
	end
	spectating = false
end

local function refreshPlayers()
	for _,v in ipairs(playerList:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local b = button(
				playerList,
				plr.Name,
				plr.Name,
				UDim2.new(),
				UDim2.new(1,-8,0,40)
			)

			connect(b.Activated,function()
				local camera = workspace.CurrentCamera
				local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if camera and hum then
					camera.CameraSubject = hum
					spectating = true
				end
			end)
		end
	end

	local stop = button(
		playerList,
		"StopSpectate",
		"STOP SPECTATE",
		UDim2.new(),
		UDim2.new(1,-8,0,40)
	)

	connect(stop.Activated,stopSpectate)
end

connect(Players.PlayerAdded,function()
	task.defer(refreshPlayers)
end)

connect(Players.PlayerRemoving,function()
	task.defer(refreshPlayers)
end)

refreshPlayers()

local saveAll = button(
	scroll,
	"SaveAll",
	"SAVE",
	UDim2.new(),
	UDim2.new(1,-8,0,42)
)

connect(saveAll.Activated,function()
	saveConfig()
end)

local close = button(
	scroll,
	"CloseMenu",
	"CLOSE",
	UDim2.new(),
	UDim2.new(1,-8,0,42)
)

connect(close.Activated,function()
	menu.Visible = false
end)

connect(openButton.Activated,function()
	menu.Visible = not menu.Visible
end)

local fpsFrames = 0
local fpsTime = os.clock()

connect(RunService.RenderStepped,function()
	fpsFrames += 1
	local now = os.clock()

	if now-fpsTime >= 1 then
		fpsLabel.Text = "FPS : "..tostring(fpsFrames)
		fpsFrames = 0
		fpsTime = now

		local ping = 0
		pcall(function()
			local network = Stats.Network
			local serverStats = network:FindFirstChild("ServerStatsItem")
			if serverStats then
				local item = serverStats:FindFirstChild("Data Ping")
				if item then
					ping = math.floor(item:GetValue())
				end
			end
		end)

		pingLabel.Text = "PING : "..tostring(ping)
		checkLabel.Text = "CHECK : "..tostring(math.floor(ping))
	end
end)

connect(player.CharacterAdded,function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.WalkSpeed = config.WalkSpeed
		humanoid.AutoRotate = not shiftLock
	end

	task.delay(.5,function()
		updateJump()
		updateShift()
	end)
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		task.delay(.3,updateJump)
	end
end)

humanoid.WalkSpeed = config.WalkSpeed
showPage(mainPage)
updateJump()
updateShift()
saveConfig()
