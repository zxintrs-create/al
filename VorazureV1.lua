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
	Sensitivity = 1.0,
    AnalogX = 0.17,
    AnalogY = 0.78,
    AnalogSize = 150
}

-- costum id foto
local SHIFT_LOCK_IMAGE = "rbxassetid://6031068426"
local OPEN_MENU_IMAGE = "rbxassetid://1234567890"

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

config.JumpX = math.clamp(tonumber(config.JumpX) or defaultConfig.JumpX,.05,.95)
config.JumpY = math.clamp(tonumber(config.JumpY) or defaultConfig.JumpY,.05,.95)
config.JumpSize = math.clamp(tonumber(config.JumpSize) or defaultConfig.JumpSize,.05,.50)
config.ShiftX = math.clamp(tonumber(config.ShiftX) or defaultConfig.ShiftX,.02,.98)
config.ShiftY = math.clamp(tonumber(config.ShiftY) or defaultConfig.ShiftY,.02,.98)
config.ShiftSize = math.clamp(tonumber(config.ShiftSize) or defaultConfig.ShiftSize,20,100)
config.AnalogX = math.clamp(tonumber(config.AnalogX) or defaultConfig.AnalogX,.10,.90)
config.AnalogY = math.clamp(tonumber(config.AnalogY) or defaultConfig.AnalogY,.10,.90)
config.AnalogSize = math.clamp(tonumber(config.AnalogSize) or defaultConfig.AnalogSize,90,220)
config.Sensitivity = math.clamp(tonumber(config.Sensitivity) or defaultConfig.Sensitivity,.1,10)

if _G.DeltaMobileControlsCleanup then
	pcall(_G.DeltaMobileControlsCleanup)
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

local function destroyGui(name)
	local gui = playerGui:FindFirstChild(name)
	if gui then
		pcall(function()
			gui:Destroy()
		end)
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

_G.ShiftLocked = false


local buttonDefaults = {}
local activeInputs = {}

local function visual(button, pressed)
	if not button or not button.Parent then return end
	if pressed then
		button.BackgroundColor3 = PRESSED_COLOR
	else
		button.BackgroundColor3 = buttonDefaults[button] or MAIN_COLOR
	end
end

local btnShiftLock

local function clearMovement()
    clearAnalog()
    resetAnalogVisual()
end

-- SHIFT LOCK BUTTON
btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(.5,.5)
btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image = SHIFT_LOCK_IMAGE
btnShiftLock.ImageColor3 = Color3.new(1,1,1)
btnShiftLock.BackgroundColor3 = SHIFT_OFF
btnShiftLock.BackgroundTransparency = .2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.Selectable = false
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = screenGui

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(1,0)
sc.Parent = btnShiftLock

local ss = Instance.new("UIStroke")
ss.Thickness = 2
ss.Color = Color3.new(0,0,0)
ss.Transparency = .3
ss.Parent = btnShiftLock

connect(btnShiftLock.Activated, toggleShiftLock)

-- CLASSIC ROBLOX MOBILE ANALOG
local analogState = {
    touch = nil,
    x = 0,
    y = 0
}

local MAX_CONTROL_TOUCHES = 4
local EDGE_IGNORE = 8

local trackedTouches = {}

local function countTrackedTouches()
    local n = 0
    for input in pairs(trackedTouches) do
        if input.UserInputState ~= Enum.UserInputState.End then
            n += 1
        end
    end
    return n
end

local function isEdgeTouch(position)
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local viewport = camera.ViewportSize
    return position.X <= EDGE_IGNORE
        or position.Y <= EDGE_IGNORE
        or position.X >= viewport.X - EDGE_IGNORE
        or position.Y >= viewport.Y - EDGE_IGNORE
end

local function clearAnalog()
    analogState.touch = nil
    analogState.x = 0
    analogState.y = 0
end

local analogGui = Instance.new("Frame")
analogGui.Name = "ClassicAnalog"
analogGui.AnchorPoint = Vector2.new(.5,.5)
analogGui.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
analogGui.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
analogGui.BackgroundColor3 = Color3.fromRGB(245,245,245)
analogGui.BackgroundTransparency = .35
analogGui.BorderSizePixel = 0
analogGui.Active = true
analogGui.Selectable = false
analogGui.ZIndex = 20
analogGui.Parent = screenGui

local analogCorner = Instance.new("UICorner")
analogCorner.CornerRadius = UDim.new(1,0)
analogCorner.Parent = analogGui

local analogStroke = Instance.new("UIStroke")
analogStroke.Thickness = 2
analogStroke.Transparency = .45
analogStroke.Color = Color3.fromRGB(0,0,0)
analogStroke.Parent = analogGui

local analogKnob = Instance.new("Frame")
analogKnob.Name = "Thumb"
analogKnob.AnchorPoint = Vector2.new(.5,.5)
analogKnob.Position = UDim2.fromScale(.5,.5)
analogKnob.Size = UDim2.fromScale(.42,.42)
analogKnob.BackgroundColor3 = Color3.fromRGB(90,90,90)
analogKnob.BackgroundTransparency = .15
analogKnob.BorderSizePixel = 0
analogKnob.Active = false
analogKnob.ZIndex = 21
analogKnob.Parent = analogGui

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1,0)
knobCorner.Parent = analogKnob

local function resetAnalogVisual()
    analogState.x = 0
    analogState.y = 0
    analogKnob.Position = UDim2.fromScale(.5,.5)
end

local function updateAnalogFromPosition(position)
    if destroyed or not analogState.touch then return end

    local center = analogGui.AbsolutePosition + analogGui.AbsoluteSize * .5
    local radius = math.max(1, math.min(analogGui.AbsoluteSize.X,analogGui.AbsoluteSize.Y) * .5)

    local delta = Vector2.new(position.X - center.X, position.Y - center.Y)
    local magnitude = delta.Magnitude

    if magnitude > radius then
        delta = delta.Unit * radius
        magnitude = radius
    end

    local nx = math.clamp(delta.X / radius,-1,1)
    local ny = math.clamp(delta.Y / radius,-1,1)

    analogState.x = nx
    analogState.y = ny

    analogKnob.Position = UDim2.new(.5,nx * radius,.5,ny * radius)
end

local function beginAnalog(input)
    if destroyed then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    if analogState.touch then return end
    if isEdgeTouch(input.Position) then return end

    if countTrackedTouches() >= MAX_CONTROL_TOUCHES then
        return
    end

    trackedTouches[input] = true
    analogState.touch = input
    updateAnalogFromPosition(input.Position)
end

connect(analogGui.InputBegan,function(input)
    beginAnalog(input)
end)

connect(UserInputService.InputChanged,function(input)
    if destroyed then return end
    if input.UserInputType == Enum.UserInputType.Touch and input == analogState.touch then
        updateAnalogFromPosition(input.Position)
    end
end)

connect(UserInputService.TouchMoved,function(input)
    if destroyed then return end
    if input == analogState.touch then
        updateAnalogFromPosition(input.Position)
    end
end)

local function endTouch(input)
    trackedTouches[input] = nil
    if input == analogState.touch then
        clearAnalog()
        resetAnalogVisual()
    end
end

connect(UserInputService.InputEnded,function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        endTouch(input)
    end
end)

connect(UserInputService.TouchEnded,function(input)
    endTouch(input)
end)

connect(RunService.RenderStepped,function()
    if destroyed then return end

    if analogState.touch then
        if analogState.touch.UserInputState == Enum.UserInputState.End then
            endTouch(analogState.touch)
        end
    end

    for input in pairs(trackedTouches) do
        if input.UserInputState == Enum.UserInputState.End then
            trackedTouches[input] = nil
        end
    end
end)

local cachedForward = Vector3.new(0,0,-1)
local cachedSide = Vector3.new(1,0,0)

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
    local x = analogState.x
    local z = -analogState.y

    if math.abs(x) < .06 then x = 0 end
    if math.abs(z) < .06 then z = 0 end

    if x == 0 and z == 0 then
        return Vector3.zero
    end

    local magnitude = math.sqrt(x*x + z*z)
    if magnitude > 1 then
        x /= magnitude
        z /= magnitude
    end

    local movement = cachedSide * x + cachedForward * z

    if movement.Magnitude < .001 then
        return Vector3.zero
    end

    return movement.Unit * math.clamp(magnitude,0,1)
end

connect(RunService.RenderStepped,function()
    if destroyed then return end
    if not character or not character.Parent then return end
    if not humanoid or humanoid.Health <= 0 then return end

    updateCameraVectors()

    local movement = getMoveVector()

    -- Only feeds the normal Humanoid movement pipeline.
    -- No WalkSpeed, JumpPower, gravity, or physics values are changed.
    humanoid:Move(movement,false)

    if _G.ShiftLocked then
        local camera = workspace.CurrentCamera
        local root = character:FindFirstChild("HumanoidRootPart")

        if camera and root then
            local look = camera.CFrame.LookVector
            local flatLook = Vector3.new(look.X,0,look.Z)

            if flatLook.Magnitude > .001 then
                root.CFrame = CFrame.lookAt(
                    root.Position,
                    root.Position + flatLook.Unit,
                    Vector3.yAxis
                )
            end
        end

        humanoid.AutoRotate = false
    else
        humanoid.AutoRotate = true
    end

    humanoid.CameraOffset = Vector3.zero
end)

-- SETTINGS
local step = .018
local targetSettingMode = "JUMP"

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaMobileErgo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = playerGui

local function makeButton(parent,name,pos,size,text,bg,z)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.Text = text
	b.BackgroundColor3 = bg or Color3.fromRGB(245,245,245)
	b.BackgroundTransparency = .05
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 22
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.BorderSizePixel = 0
	b.ZIndex = z or 41
	b.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,12)
	c.Parent = b

	return b
end

local menu = Instance.new("ImageButton")
menu.Name = "OpenMenu"
menu.Position = UDim2.new(1,-72,1,-72)
menu.Size = UDim2.fromOffset(60,60)
menu.Image = OPEN_MENU_IMAGE
menu.BackgroundColor3 = Color3.fromRGB(245,245,245)
menu.BackgroundTransparency = 0.05
menu.AutoButtonColor = false
menu.ZIndex = 100
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(1,0)
menuCorner.Parent = menu

local settings = Instance.new("Frame")
settings.Name = "SettingsFrame"
settings.Size = UDim2.fromOffset(300,620)
settings.Position = UDim2.new(.5,-150,.5,-310)
settings.BackgroundColor3 = Color3.fromRGB(245,245,245)
settings.BackgroundTransparency = .05
settings.BorderSizePixel = 0
settings.Visible = false
settings.ZIndex = 40
settings.Parent = gui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0,18)
settingsCorner.Parent = settings

local settingsStroke = Instance.new("UIStroke")
settingsStroke.Thickness = 1.5
settingsStroke.Transparency = .18
settingsStroke.Color = Color3.fromRGB(255,255,255)
settingsStroke.Parent = settings

local settingsGradient = Instance.new("UIGradient")
settingsGradient.Rotation = 35
settingsGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(250,250,255)),
    ColorSequenceKeypoint.new(.5,Color3.fromRGB(232,235,245)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(248,248,252))
})
settingsGradient.Parent = settings

local cameraSection = Instance.new("Frame")
cameraSection.Size = UDim2.new(1,-20,0,160)
cameraSection.Position = UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3 = Color3.fromRGB(225,225,225)
cameraSection.BorderSizePixel = 0
cameraSection.ZIndex = 41
cameraSection.Parent = settings

local cameraCorner = Instance.new("UICorner")
cameraCorner.CornerRadius = UDim.new(0,14)
cameraCorner.Parent = cameraSection

local cameraStroke = Instance.new("UIStroke")
cameraStroke.Thickness = 1
cameraStroke.Transparency = .35
cameraStroke.Color = Color3.fromRGB(255,255,255)
cameraStroke.Parent = cameraSection

local cameraTitle = Instance.new("TextLabel")
cameraTitle.Size = UDim2.new(1,0,0,40)
cameraTitle.Text = "CAMERA SENSI SETTING"
cameraTitle.TextColor3 = Color3.fromRGB(20,20,20)
cameraTitle.Font = Enum.Font.GothamBold
cameraTitle.TextSize = 18
cameraTitle.BackgroundTransparency = 1
cameraTitle.ZIndex = 42
cameraTitle.Parent = cameraSection

local sensLabel = Instance.new("TextLabel")
sensLabel.Size = UDim2.new(1,0,0,30)
sensLabel.Position = UDim2.fromOffset(0,40)
sensLabel.TextColor3 = Color3.fromRGB(60,60,60)
sensLabel.Font = Enum.Font.Gotham
sensLabel.TextSize = 14
sensLabel.BackgroundTransparency = 1
sensLabel.ZIndex = 42
sensLabel.Parent = cameraSection

local function applySensitivity()
	sensLabel.Text = "Multiplier: "..string.format("%.1f",config.Sensitivity).."x"
	pcall(function()
		UserSettings().GameSettings.MouseSensitivity = config.Sensitivity
	end)
end

local sensMinus = makeButton(cameraSection,"Minus",UDim2.new(.06,0,0,85),UDim2.fromOffset(76,42),"-",nil,43)
local sensReset = makeButton(cameraSection,"Reset",UDim2.new(.5,-42,0,85),UDim2.fromOffset(84,42),"RESET",nil,43)
local sensPlus = makeButton(cameraSection,"Plus",UDim2.new(.94,-76,0,85),UDim2.fromOffset(76,42),"+",nil,43)

connect(sensMinus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity-.1,.1,10)
	applySensitivity()
end)

connect(sensPlus.Activated,function()
	config.Sensitivity = math.clamp(config.Sensitivity+.1,.1,10)
	applySensitivity()
end)

connect(sensReset.Activated,function()
	config.Sensitivity = 1
	applySensitivity()
end)

applySensitivity()

local jumpSection = Instance.new("Frame")
jumpSection.Size = UDim2.new(1,-20,0,380)
jumpSection.Position = UDim2.fromOffset(10,180)
jumpSection.BackgroundColor3 = Color3.fromRGB(225,225,225)
jumpSection.BorderSizePixel = 0
jumpSection.ZIndex = 41
jumpSection.Parent = settings

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0,14)
jumpCorner.Parent = jumpSection

local jumpStroke = Instance.new("UIStroke")
jumpStroke.Thickness = 1
jumpStroke.Transparency = .35
jumpStroke.Color = Color3.fromRGB(255,255,255)
jumpStroke.Parent = jumpSection

local modeSwitchBtn = makeButton(
	jumpSection,"ToggleTargetMode",
	UDim2.new(.05,0,0,10),
	UDim2.new(.9,0,0,36),
	"TARGET: JUMP BUTTON",
	Color3.fromRGB(70,150,255),43
)
modeSwitchBtn.TextColor3 = Color3.new(1,1,1)

local function setTargetMode(mode)
    targetSettingMode = mode
    if mode == "JUMP" then
        modeSwitchBtn.Text = "TARGET: JUMP BUTTON"
        modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(70,150,255)
    elseif mode == "SHIFT" then
        modeSwitchBtn.Text = "TARGET: SHIFT LOCK"
        modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(170,0,255)
    else
        modeSwitchBtn.Text = "TARGET: ANALOG"
        modeSwitchBtn.BackgroundColor3 = Color3.fromRGB(70,180,140)
    end
end

connect(modeSwitchBtn.Activated,function()
    if targetSettingMode == "JUMP" then
        setTargetMode("SHIFT")
    elseif targetSettingMode == "SHIFT" then
        setTargetMode("ANALOG")
    else
        setTargetMode("JUMP")
    end
end)

local targetHint = Instance.new("TextLabel")
targetHint.Size = UDim2.new(1,-20,0,22)
targetHint.Position = UDim2.fromOffset(10,50)
targetHint.Text = "POSITION / SIZE — ONLY SELECTED TARGET"
targetHint.TextColor3 = Color3.fromRGB(90,90,100)
targetHint.Font = Enum.Font.Gotham
targetHint.TextSize = 11
targetHint.BackgroundTransparency = 1
targetHint.ZIndex = 42
targetHint.Parent = jumpSection

local moveUp = makeButton(jumpSection,"MoveUp",UDim2.new(.5,-34,0,75),UDim2.fromOffset(68,46),"↑",nil,43)
local moveLeft = makeButton(jumpSection,"MoveLeft",UDim2.new(.10,0,0,122),UDim2.fromOffset(68,46),"←",nil,43)
local moveRight = makeButton(jumpSection,"MoveRight",UDim2.new(.90,-68,0,122),UDim2.fromOffset(68,46),"→",nil,43)
local moveDown = makeButton(jumpSection,"MoveDown",UDim2.new(.5,-34,0,169),UDim2.fromOffset(68,46),"↓",nil,43)

local sizePlus = makeButton(jumpSection,"SizePlus",UDim2.new(.06,0,0,227),UDim2.fromOffset(88,34),"SIZE +",nil,43)
local sizeMinus = makeButton(jumpSection,"SizeMinus",UDim2.new(.94,-88,0,227),UDim2.fromOffset(88,34),"SIZE -",nil,43)
local center = makeButton(jumpSection,"Center",UDim2.new(.5,-44,0,227),UDim2.fromOffset(88,34),"RESET",nil,43)

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
	if viewport.X <= 0 or viewport.Y <= 0 then return end

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

local function updateShift()
	config.ShiftX = math.clamp(config.ShiftX,.02,.98)
	config.ShiftY = math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize = math.clamp(config.ShiftSize,20,100)

	btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function updateAnalog()
    config.AnalogX = math.clamp(config.AnalogX,.10,.90)
    config.AnalogY = math.clamp(config.AnalogY,.10,.90)
    config.AnalogSize = math.clamp(config.AnalogSize,90,220)

    if analogGui and analogGui.Parent then
        analogGui.Position = UDim2.new(config.AnalogX,0,config.AnalogY,0)
        analogGui.Size = UDim2.fromOffset(config.AnalogSize,config.AnalogSize)
        resetAnalogVisual()
    end
end

local function applyMoveStep(dx,dy)
    if targetSettingMode == "JUMP" then
        config.JumpX = math.clamp(config.JumpX+dx,.05,.95)
        config.JumpY = math.clamp(config.JumpY+dy,.05,.95)
        updateJump()
    elseif targetSettingMode == "SHIFT" then
        config.ShiftX = math.clamp(config.ShiftX+dx,.02,.98)
        config.ShiftY = math.clamp(config.ShiftY+dy,.02,.98)
        updateShift()
    else
        config.AnalogX = math.clamp(config.AnalogX+dx,.10,.90)
        config.AnalogY = math.clamp(config.AnalogY+dy,.10,.90)
        updateAnalog()
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
		local t = input.UserInputType
		if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
		holding[button] = true
		applyMoveStep(dx,dy)
	end)

	connect(button.InputEnded,function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
			holding[button] = false
		end
	end)
end

bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)

connect(UserInputService.InputEnded,function(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
		for button in pairs(holding) do
			holding[button] = false
		end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end

	if holding[moveUp] then applyMoveStep(0,-step) end
	if holding[moveDown] then applyMoveStep(0,step) end
	if holding[moveLeft] then applyMoveStep(-step,0) end
	if holding[moveRight] then applyMoveStep(step,0) end
end)

connect(sizePlus.Activated,function()
    if targetSettingMode == "JUMP" then
        config.JumpSize = math.clamp(config.JumpSize+.05,.05,.50)
        updateJump()
    elseif targetSettingMode == "SHIFT" then
        config.ShiftSize = math.clamp(config.ShiftSize+5,20,100)
        updateShift()
    else
        config.AnalogSize = math.clamp(config.AnalogSize+10,90,220)
        updateAnalog()
    end
end)

connect(sizeMinus.Activated,function()
    if targetSettingMode == "JUMP" then
        config.JumpSize = math.clamp(config.JumpSize-.05,.05,.50)
        updateJump()
    elseif targetSettingMode == "SHIFT" then
        config.ShiftSize = math.clamp(config.ShiftSize-5,20,100)
        updateShift()
    else
        config.AnalogSize = math.clamp(config.AnalogSize-10,90,220)
        updateAnalog()
    end
end)

connect(center.Activated,function()
    if targetSettingMode == "JUMP" then
        config.JumpX = defaultConfig.JumpX
        config.JumpY = defaultConfig.JumpY
        config.JumpSize = defaultConfig.JumpSize
        updateJump()
    elseif targetSettingMode == "SHIFT" then
        config.ShiftX = defaultConfig.ShiftX
        config.ShiftY = defaultConfig.ShiftY
        config.ShiftSize = defaultConfig.ShiftSize
        updateShift()
    else
        config.AnalogX = defaultConfig.AnalogX
        config.AnalogY = defaultConfig.AnalogY
        config.AnalogSize = defaultConfig.AnalogSize
        updateAnalog()
    end
end)

local saveButton = makeButton(
	settings,"SaveConfig",
	UDim2.new(.05,0,1,-45),
	UDim2.fromOffset(130,38),
	"SAVE",
	Color3.fromRGB(70,200,100),43
)
saveButton.TextColor3 = Color3.new(1,1,1)

local closeButton = makeButton(
	settings,"Close",
	UDim2.new(.95,-130,1,-45),
	UDim2.fromOffset(130,38),
	"CLOSE",
	Color3.fromRGB(230,90,90),43
)
closeButton.TextColor3 = Color3.new(1,1,1)

connect(saveButton.Activated,function()
    local ok = saveConfig()
    if ok then
        loadConfig()
        config.JumpX = math.clamp(tonumber(config.JumpX) or defaultConfig.JumpX,.05,.95)
        config.JumpY = math.clamp(tonumber(config.JumpY) or defaultConfig.JumpY,.05,.95)
        config.JumpSize = math.clamp(tonumber(config.JumpSize) or defaultConfig.JumpSize,.05,.50)
        config.ShiftX = math.clamp(tonumber(config.ShiftX) or defaultConfig.ShiftX,.02,.98)
        config.ShiftY = math.clamp(tonumber(config.ShiftY) or defaultConfig.ShiftY,.02,.98)
        config.ShiftSize = math.clamp(tonumber(config.ShiftSize) or defaultConfig.ShiftSize,20,100)
        config.AnalogX = math.clamp(tonumber(config.AnalogX) or defaultConfig.AnalogX,.10,.90)
        config.AnalogY = math.clamp(tonumber(config.AnalogY) or defaultConfig.AnalogY,.10,.90)
        config.AnalogSize = math.clamp(tonumber(config.AnalogSize) or defaultConfig.AnalogSize,90,220)
        config.Sensitivity = math.clamp(tonumber(config.Sensitivity) or defaultConfig.Sensitivity,.1,10)
        updateJump()
        updateShift()
        updateAnalog()
        applySensitivity()
        saveButton.Text = "SAVED + LOADED"
    else
        saveButton.Text = "SAVE ERROR"
    end
    task.delay(1.2,function()
        if saveButton and saveButton.Parent then saveButton.Text = "SAVE" end
    end)
end)

connect(menu.Activated,function()
	settings.Visible = not settings.Visible
end)

connect(closeButton.Activated,function()
	settings.Visible = false
end)

local function refresh()
	task.defer(function()
		updateJump()
		updateShift()
        updateAnalog()
	end)

	task.delay(.2,function()
		if not destroyed then
			updateJump()
			updateShift()
            updateAnalog()
		end
	end)
end

connect(player.CharacterAdded,function(newCharacter)
	if destroyed then return end

    clearMovement()

	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid",10)

	if humanoid then
		humanoid.AutoRotate = not _G.ShiftLocked
		humanoid.CameraOffset = Vector3.zero
	end

	refresh()
end)

connect(playerGui.ChildAdded,function(child)
	if child.Name == "TouchGui" then
		jumpButton = nil
		refresh()
	end
end)

updateCameraVectors()
updateJump()
updateShift()
updateAnalog()
applySensitivity()
