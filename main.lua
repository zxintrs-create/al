local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local CONFIG_FILE="DeltaMobileConfig.json"

local defaultConfig={
	JumpX=.85,
	JumpY=.75,
	JumpSize=.30,
	Sensitivity=1
}

local config={}
for k,v in pairs(defaultConfig)do
	config[k]=v
end

pcall(function()
	if readfile and isfile and isfile(CONFIG_FILE)then
		local data=HttpService:JSONDecode(readfile(CONFIG_FILE))
		if type(data)=="table"then
			for k,v in pairs(data)do
				if defaultConfig[k]~=nil and type(v)==type(defaultConfig[k])then
					config[k]=v
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

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
end

local connections={}
local gradientObjects={}
local destroyed=false

local function connect(signal,callback)
	local c
	pcall(function()
		c=signal:Connect(callback)
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
	local gui=playerGui:FindFirstChild(name)
	if gui then
		pcall(function()
			gui:Destroy()
		end)
	end
end

_G.DeltaMobileControlsCleanup=function()
	if destroyed then return end
	destroyed=true
	disconnectAll()
	destroyGui("DeltaMobileControls")
	destroyGui("DeltaMobileErgo")
end

destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")

local PREMIUM_COLORS=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(.25,Color3.fromRGB(255,80,0)),
	ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),
	ColorSequenceKeypoint.new(.75,Color3.fromRGB(255,80,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})

local function addPremiumStroke(obj,thickness)
	if not obj or not obj:IsA("GuiObject")then
		return
	end

	local oldStroke=obj:FindFirstChild("PremiumStroke")
	if oldStroke then
		oldStroke:Destroy()
	end

	local stroke=Instance.new("UIStroke")
	stroke.Name="PremiumStroke"
	stroke.Thickness=thickness or 2
	stroke.Color=Color3.new(1,1,1)
	stroke.Parent=obj

	local gradient=Instance.new("UIGradient")
	gradient.Name="PremiumGradient"
	gradient.Color=PREMIUM_COLORS
	gradient.Rotation=0
	gradient.Parent=stroke

	gradientObjects[gradient]=true

	return stroke
end

local function makeButton(parent,name,pos,size,text,bg,z)
	local button=Instance.new("TextButton")
	button.Name=name
	button.Position=pos
	button.Size=size
	button.Text=text
	button.BackgroundColor3=bg or Color3.fromRGB(35,35,40)
	button.BackgroundTransparency=.02
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=28
	button.AutoButtonColor=false
	button.Active=true
	button.Selectable=false
	button.BorderSizePixel=0
	button.ZIndex=z or 43
	button.Parent=parent

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(0,16)
	corner.Parent=button

	addPremiumStroke(button,2)

	return button
end

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=1000000
gui.Parent=playerGui

local menu=Instance.new("ImageButton")
menu.Name="OpenMenu"
menu.AnchorPoint=Vector2.new(1,1)
menu.Position=UDim2.new(1,-22,1,-22)
menu.Size=UDim2.fromOffset(68,68)
menu.Image="rbxassetid://114480118578175"
menu.BackgroundColor3=Color3.fromRGB(25,25,30)
menu.BackgroundTransparency=.03
menu.AutoButtonColor=false
menu.Active=true
menu.Selectable=false
menu.ZIndex=100
menu.Parent=gui

local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu

addPremiumStroke(menu,2.5)

local settings=Instance.new("ScrollingFrame")
settings.Name="SettingsFrame"
settings.AnchorPoint=Vector2.new(.5,.5)
settings.Position=UDim2.new(.5,0,.5,0)
settings.Size=UDim2.new(
	0,
	320,
	0,
	math.min(
		650,
		(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 650)-30
	)
)
settings.BackgroundColor3=Color3.fromRGB(18,18,22)
settings.BackgroundTransparency=.02
settings.BorderSizePixel=0
settings.ScrollBarThickness=4
settings.Visible=false
settings.ZIndex=40
settings.CanvasSize=UDim2.fromOffset(0,720)
settings.Parent=gui

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings

addPremiumStroke(settings,2.5)

local cameraSection=Instance.new("Frame")
cameraSection.Name="CameraSensitivity"
cameraSection.Size=UDim2.new(1,-20,0,150)
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3=Color3.fromRGB(30,30,35)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings

local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection

addPremiumStroke(cameraSection,1.5)

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,36)
cameraTitle.Text="CAMERA SENSITIVITY"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=17
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local sensitivityLabel=Instance.new("TextLabel")
sensitivityLabel.Size=UDim2.new(1,0,0,30)
sensitivityLabel.Position=UDim2.fromOffset(0,36)
sensitivityLabel.TextColor3=Color3.fromRGB(220,220,220)
sensitivityLabel.Font=Enum.Font.Gotham
sensitivityLabel.TextSize=14
sensitivityLabel.BackgroundTransparency=1
sensitivityLabel.ZIndex=42
sensitivityLabel.Parent=cameraSection

local sensitivityMinus=makeButton(
	cameraSection,
	"SensitivityMinus",
	UDim2.fromOffset(12,82),
	UDim2.fromOffset(80,46),
	"-",
	nil,
	43
)

local sensitivityReset=makeButton(
	cameraSection,
	"SensitivityReset",
	UDim2.new(.5,-43,0,82),
	UDim2.fromOffset(86,46),
	"RESET",
	nil,
	43
)

local sensitivityPlus=makeButton(
	cameraSection,
	"SensitivityPlus",
	UDim2.new(1,-92,0,82),
	UDim2.fromOffset(80,46),
	"+",
	nil,
	43
)

local function applySensitivity()
	config.Sensitivity=math.clamp(config.Sensitivity,.1,10)

	sensitivityLabel.Text=
		"Multiplier: "..string.format("%.1f",config.Sensitivity).."x"

	pcall(function()
		UserSettings().GameSettings.MouseSensitivity=config.Sensitivity
	end)
end

connect(sensitivityMinus.Activated,function()
	config.Sensitivity=math.clamp(
		config.Sensitivity-.1,
		.1,
		10
	)

	applySensitivity()
end)

connect(sensitivityPlus.Activated,function()
	config.Sensitivity=math.clamp(
		config.Sensitivity+.1,
		.1,
		10
	)

	applySensitivity()
end)

connect(sensitivityReset.Activated,function()
	config.Sensitivity=defaultConfig.Sensitivity
	applySensitivity()
end)

applySensitivity()

local jumpSection=Instance.new("Frame")
jumpSection.Name="JumpSetting"
jumpSection.Size=UDim2.new(1,-20,0,430)
jumpSection.Position=UDim2.fromOffset(10,170)
jumpSection.BackgroundColor3=Color3.fromRGB(30,30,35)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings

local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection

addPremiumStroke(jumpSection,1.5)

local jumpTitle=Instance.new("TextLabel")
jumpTitle.Size=UDim2.new(1,0,0,36)
jumpTitle.Text="JUMP BUTTON POSITION"
jumpTitle.TextColor3=Color3.new(1,1,1)
jumpTitle.Font=Enum.Font.GothamBold
jumpTitle.TextSize=17
jumpTitle.BackgroundTransparency=1
jumpTitle.ZIndex=42
jumpTitle.Parent=jumpSection

local targetLabel=Instance.new("TextLabel")
targetLabel.Position=UDim2.fromOffset(10,36)
targetLabel.Size=UDim2.new(1,-20,0,30)
targetLabel.Text="TARGET: JUMP BUTTON BAWAAN ROBLOX"
targetLabel.TextColor3=Color3.fromRGB(190,190,210)
targetLabel.Font=Enum.Font.Gotham
targetLabel.TextSize=12
targetLabel.BackgroundTransparency=1
targetLabel.ZIndex=42
targetLabel.Parent=jumpSection

local moveUp=makeButton(
	jumpSection,
	"MoveUp",
	UDim2.new(.5,-38,0,75),
	UDim2.fromOffset(76,50),
	"↑",
	nil,
	43
)

local moveLeft=makeButton(
	jumpSection,
	"MoveLeft",
	UDim2.fromOffset(28,128),
	UDim2.fromOffset(76,50),
	"←",
	nil,
	43
)

local moveRight=makeButton(
	jumpSection,
	"MoveRight",
	UDim2.new(1,-104,0,128),
	UDim2.fromOffset(76,50),
	"→",
	nil,
	43
)

local moveDown=makeButton(
	jumpSection,
	"MoveDown",
	UDim2.new(.5,-38,0,181),
	UDim2.fromOffset(76,50),
	"↓",
	nil,
	43
)

local sizePlus=makeButton(
	jumpSection,
	"SizePlus",
	UDim2.fromOffset(20,250),
	UDim2.fromOffset(85,42),
	"SIZE +",
	nil,
	43
)

local resetJump=makeButton(
	jumpSection,
	"ResetJump",
	UDim2.new(.5,-43,0,250),
	UDim2.fromOffset(86,42),
	"RESET",
	nil,
	43
)

local sizeMinus=makeButton(
	jumpSection,
	"SizeMinus",
	UDim2.new(1,-105,0,250),
	UDim2.fromOffset(85,42),
	"SIZE -",
	nil,
	43
)

local positionLabel=Instance.new("TextLabel")
positionLabel.Position=UDim2.fromOffset(10,315)
positionLabel.Size=UDim2.new(1,-20,0,28)
positionLabel.TextColor3=Color3.fromRGB(210,210,220)
positionLabel.Font=Enum.Font.Gotham
positionLabel.TextSize=13
positionLabel.BackgroundTransparency=1
positionLabel.ZIndex=42
positionLabel.Parent=jumpSection

local sizeLabel=Instance.new("TextLabel")
sizeLabel.Position=UDim2.fromOffset(10,343)
sizeLabel.Size=UDim2.new(1,-20,0,28)
sizeLabel.TextColor3=Color3.fromRGB(210,210,220)
sizeLabel.Font=Enum.Font.Gotham
sizeLabel.TextSize=13
sizeLabel.BackgroundTransparency=1
sizeLabel.ZIndex=42
sizeLabel.Parent=jumpSection

local touchGui
local jumpButton

local function getJumpButton()
	touchGui=playerGui:FindFirstChild("TouchGui")

	if not touchGui then
		jumpButton=nil
		return nil
	end

	local button=touchGui:FindFirstChild("JumpButton",true)

	if button and button:IsA("GuiObject")then
		jumpButton=button
		return button
	end

	jumpButton=nil
	return nil
end

local function updateLabels()
	positionLabel.Text=
		"X: "..string.format("%.3f",config.JumpX)..
		"    Y: "..string.format("%.3f",config.JumpY)

	sizeLabel.Text=
		"SIZE: "..string.format("%.2f",config.JumpSize)
end

local function applyJumpStroke(button)
	local old=button:FindFirstChild("PremiumJumpStroke")

	if old then
		old:Destroy()
	end

	local overlay=Instance.new("Frame")
	overlay.Name="PremiumJumpStroke"
	overlay.Size=UDim2.fromScale(1,1)
	overlay.BackgroundTransparency=1
	overlay.BorderSizePixel=0
	overlay.ZIndex=button.ZIndex+2
	overlay.Parent=button

	local corner=Instance.new("UICorner")
	corner.CornerRadius=UDim.new(1,0)
	corner.Parent=overlay

	local stroke=Instance.new("UIStroke")
	stroke.Name="PremiumStroke"
	stroke.Thickness=2.5
	stroke.Color=Color3.new(1,1,1)
	stroke.Parent=overlay

	local gradient=Instance.new("UIGradient")
	gradient.Name="PremiumGradient"
	gradient.Color=PREMIUM_COLORS
	gradient.Rotation=0
	gradient.Parent=stroke

	gradientObjects[gradient]=true
end

local function updateJump()
	if destroyed then return end

	local button=getJumpButton()
	local camera=workspace.CurrentCamera

	if not button or not camera then
		return
	end

	local viewport=camera.ViewportSize

	if viewport.X<=0 or viewport.Y<=0 then
		return
	end

	config.JumpX=math.clamp(config.JumpX,.04,.96)
	config.JumpY=math.clamp(config.JumpY,.04,.96)
	config.JumpSize=math.clamp(config.JumpSize,.08,.50)

	local size=math.max(
		52,
		math.floor(viewport.Y*config.JumpSize)
	)

	pcall(function()
		button.AnchorPoint=Vector2.new(.5,.5)

		button.Position=UDim2.new(
			config.JumpX,
			0,
			config.JumpY,
			0
		)

		button.Size=UDim2.fromOffset(size,size)

		applyJumpStroke(button)
	end)

	updateLabels()
end

local step=.015
local holding={}

local function bindPositionButton(button,dx,dy)
	connect(button.InputBegan,function(input)
		local t=input.UserInputType

		if t==Enum.UserInputType.Touch
			or t==Enum.UserInputType.MouseButton1 then

			holding[button]=true
			button.BackgroundColor3=Color3.fromRGB(65,65,75)
		end
	end)

	connect(button.InputEnded,function(input)
		local t=input.UserInputType

		if t==Enum.UserInputType.Touch
			or t==Enum.UserInputType.MouseButton1 then

			holding[button]=false
			button.BackgroundColor3=Color3.fromRGB(35,35,40)
		end
	end)

	connect(button.Activated,function()
		if holding[button] then
			return
		end

		config.JumpX=math.clamp(
			config.JumpX+dx,
			.04,
			.96
		)

		config.JumpY=math.clamp(
			config.JumpY+dy,
			.04,
			.96
		)

		updateJump()
	end)

	button:SetAttribute("DX",dx)
	button:SetAttribute("DY",dy)
end

bindPositionButton(moveUp,0,-step)
bindPositionButton(moveLeft,-step,0)
bindPositionButton(moveRight,step,0)
bindPositionButton(moveDown,0,step)

connect(UserInputService.InputEnded,function(input)
	local t=input.UserInputType

	if t==Enum.UserInputType.Touch
		or t==Enum.UserInputType.MouseButton1 then

		for button in pairs(holding)do
			holding[button]=false
			button.BackgroundColor3=Color3.fromRGB(35,35,40)
		end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	for button,state in pairs(holding)do
		if state then
			local dx=button:GetAttribute("DX") or 0
			local dy=button:GetAttribute("DY") or 0

			config.JumpX=math.clamp(
				config.JumpX+dx,
				.04,
				.96
			)

			config.JumpY=math.clamp(
				config.JumpY+dy,
				.04,
				.96
			)

			updateJump()
		end
	end
end)

connect(sizePlus.Activated,function()
	config.JumpSize=math.clamp(
		config.JumpSize+.03,
		.08,
		.50
	)

	updateJump()
end)

connect(sizeMinus.Activated,function()
	config.JumpSize=math.clamp(
		config.JumpSize-.03,
		.08,
		.50
	)

	updateJump()
end)

connect(resetJump.Activated,function()
	config.JumpX=defaultConfig.JumpX
	config.JumpY=defaultConfig.JumpY
	config.JumpSize=defaultConfig.JumpSize

	updateJump()
end)

local saveButton=makeButton(
	settings,
	"SaveConfig",
	UDim2.fromOffset(20,620),
	UDim2.fromOffset(130,42),
	"SAVE",
	Color3.fromRGB(45,100,55),
	43
)

local closeButton=makeButton(
	settings,
	"Close",
	UDim2.new(1,-150,0,620),
	UDim2.fromOffset(130,42),
	"CLOSE",
	Color3.fromRGB(100,40,40),
	43
)

connect(saveButton.Activated,function()
	saveConfig()

	saveButton.Text="SAVED!"

	task.delay(1,function()
		if saveButton and saveButton.Parent then
			saveButton.Text="SAVE"
		end
	end)
end)

connect(closeButton.Activated,function()
	settings.Visible=false
end)

connect(menu.Activated,function()
	settings.Visible=not settings.Visible
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name=="TouchGui" then
		jumpButton=nil

		task.defer(updateJump)
		task.delay(.25,updateJump)
		task.delay(.7,updateJump)
		task.delay(1,updateJump)
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then
		return
	end

	for gradient in pairs(gradientObjects)do
		if gradient and gradient.Parent then
			gradient.Rotation=(gradient.Rotation+1.5)%360
		else
			gradientObjects[gradient]=nil
		end
	end
end)

updateLabels()
updateJump()

task.delay(.2,function()
	updateJump()
end)

task.delay(.6,function()
	updateJump()
end)

task.delay(1,function()
	updateJump()
end)
