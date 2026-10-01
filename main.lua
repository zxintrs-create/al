local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local INPUT_BUTTONS = PlayerGui:WaitForChild("INPUT_BUTTONS",10)
local TouchFrame = INPUT_BUTTONS and INPUT_BUTTONS:WaitForChild("TouchFrame",10)
local Deflect_Button = TouchFrame and TouchFrame:WaitForChild("Deflect_Button",10)
local Deflect = Deflect_Button and Deflect_Button:WaitForChild("Button",10)

if not Deflect or not Deflect:IsA("GuiButton") then
	warn("Deflect Button tidak ditemukan")
	return
end

local GUI_NAME = "VainlyStarAutoParry"

local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local COLOR_CYAN = Color3.fromRGB(0,240,255)
local COLOR_PURPLE = Color3.fromRGB(170,60,255)
local COLOR_DARK = Color3.fromRGB(18,12,35)
local COLOR_FLASH = Color3.fromRGB(255,80,180)

local autoParryEnabled = false
local cachedBall = nil
local visualAuraPart = nil
local flashUntil = 0

local BASE_AURA = 10
local SPEED_AURA_FACTOR = 0.055
local MAX_AURA = 70
local INNER_AURA = 7
local CLASH_AURA = 3.5

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.Size = UDim2.fromOffset(160,36)
openButton.Position = UDim2.new(0.5,-80,0,0)
openButton.BackgroundColor3 = COLOR_DARK
openButton.TextColor3 = COLOR_CYAN
openButton.Text = "👑VOID VAINLY STAR"
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 14
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0,8)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = COLOR_PURPLE
openStroke.Thickness = 1.5
openStroke.Parent = openButton

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(250,195)
main.Position = UDim2.new(0.5,-125,0.5,-97)
main.BackgroundColor3 = COLOR_DARK
main.Visible = false
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLOR_CYAN
mainStroke.Thickness = 1.5
mainStroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.fromOffset(0,6)
title.BackgroundTransparency = 1
title.Text = "🌙 VOID MOON STAR"
title.TextColor3 = COLOR_CYAN
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.fromOffset(0,42)
status.BackgroundTransparency = 1
status.Text = "Status: NONAKTIF"
status.TextColor3 = Color3.fromRGB(255,90,140)
status.Font = Enum.Font.GothamMedium
status.TextSize = 15
status.Parent = main

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,0,0,20)
info.Position = UDim2.fromOffset(0,70)
info.BackgroundTransparency = 1
info.Text = "BALL AURA | SPEED DETECTION"
info.TextColor3 = Color3.fromRGB(220,220,255)
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.Parent = main

local toggle = Instance.new("TextButton")
toggle.Name = "ToggleButton"
toggle.Size = UDim2.new(0.88,0,0,42)
toggle.Position = UDim2.new(0.06,0,0.66,0)
toggle.BackgroundColor3 = Color3.fromRGB(100,20,60)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Text = "AUTO PARRY: OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0,10)
toggleCorner.Parent = toggle

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = COLOR_PURPLE
toggleStroke.Thickness = 1
toggleStroke.Parent = toggle

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.fromOffset(190,100)
speedLabel.Position = UDim2.fromOffset(8,70)
speedLabel.BackgroundColor3 = COLOR_DARK
speedLabel.BackgroundTransparency = 0.08
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 13
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.Text = "PART SPEED: 0\nSTATUS: WAITING\nDISTANCE: --\nAURA: 0"
speedLabel.ZIndex = 20
speedLabel.Parent = gui

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,8)
speedCorner.Parent = speedLabel

local speedStroke = Instance.new("UIStroke")
speedStroke.Thickness = 1.5
speedStroke.Color = COLOR_CYAN
speedStroke.Parent = speedLabel

speedLabel:SetAttribute("PartSpeed",0)

local function getCharacter()
	local character = player.Character
	if not character then return nil,nil end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil,nil end

	return character,hrp
end

local function getActiveMap()
	local activeMap = Workspace:FindFirstChild("ActiveMap")
	if not activeMap then return nil end
	return activeMap
end

local function getBallSpawnObjects()
	local result = {}
	local activeMap = getActiveMap()

	if not activeMap then
		return result
	end

	for _,mapObject in ipairs(activeMap:GetChildren()) do
		for _,obj in ipairs(mapObject:GetDescendants()) do
			if obj.Name == "BallSpawns" then
				table.insert(result,obj)
			end
		end

		if mapObject.Name == "BallSpawns" then
			table.insert(result,mapObject)
		end
	end

	return result
end

local function getSpawnParts()
	local result = {}

	for _,spawnObject in ipairs(getBallSpawnObjects()) do
		if spawnObject:IsA("BasePart") then
			table.insert(result,spawnObject)
		else
			for _,obj in ipairs(spawnObject:GetDescendants()) do
				if obj:IsA("BasePart") then
					table.insert(result,obj)
				end
			end
		end
	end

	return result
end

local function isValidBall(part)
	if not part then return false end
	if not part:IsA("BasePart") then return false end
	if not part:IsDescendantOf(Workspace) then return false end

	local character = player.Character
	if character and part:IsDescendantOf(character) then
		return false
	end

	return true
end

local function distanceToSpawn(part)
	local nearest = math.huge
	local spawns = getSpawnParts()

	for _,spawn in ipairs(spawns) do
		if spawn:IsDescendantOf(Workspace) then
			local distance = (part.Position-spawn.Position).Magnitude

			if distance < nearest then
				nearest = distance
			end
		end
	end

	return nearest
end

local function findNewBall()
	local spawns = getSpawnParts()

	if #spawns == 0 then
		return nil
	end

	local best = nil
	local bestDistance = math.huge

	for _,obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") and isValidBall(obj) then
			local nearest = distanceToSpawn(obj)

			if nearest <= 35 and nearest < bestDistance then
				best = obj
				bestDistance = nearest
			end
		end
	end

	return best
end

local function updateBallFromSpawn(obj)
	if not obj:IsA("BasePart") then
		return
	end

	if not isValidBall(obj) then
		return
	end

	local nearest = distanceToSpawn(obj)

	if nearest <= 35 then
		cachedBall = obj
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	if not obj:IsA("BasePart") then
		return
	end

	task.defer(function()
		if not obj:IsDescendantOf(Workspace) then
			return
		end

		updateBallFromSpawn(obj)
	end)
end)

Workspace.DescendantRemoving:Connect(function(obj)
	if obj == cachedBall then
		cachedBall = nil
	end
end)

local function getBall()
	if isValidBall(cachedBall) then
		return cachedBall
	end

	cachedBall = nil

	return findNewBall()
end

local function getAura(speed)
	return math.clamp(
		BASE_AURA + speed*SPEED_AURA_FACTOR,
		BASE_AURA,
		MAX_AURA
	)
end

local function destroyAura()
	if visualAuraPart then
		visualAuraPart:Destroy()
		visualAuraPart = nil
	end
end

local function updateAura(radius)
	if not autoParryEnabled then
		destroyAura()
		return
	end

	local character,hrp = getCharacter()

	if not character or not hrp then
		destroyAura()
		return
	end

	if not visualAuraPart then
		visualAuraPart = Instance.new("Part")
		visualAuraPart.Name = "BallDetectionAura"
		visualAuraPart.Shape = Enum.PartType.Ball
		visualAuraPart.Material = Enum.Material.ForceField
		visualAuraPart.Color = COLOR_CYAN
		visualAuraPart.Transparency = 0.65
		visualAuraPart.CanCollide = false
		visualAuraPart.CanTouch = false
		visualAuraPart.CanQuery = false
		visualAuraPart.CastShadow = false
		visualAuraPart.Anchored = false

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = hrp
		weld.Part1 = visualAuraPart
		weld.Parent = visualAuraPart

		visualAuraPart.CFrame = hrp.CFrame
		visualAuraPart.Parent = character
	end

	local diameter = radius*2

	visualAuraPart.Size = Vector3.new(
		diameter,
		diameter,
		diameter
	)
end

local function clickDeflect()
	if not Deflect or not Deflect:IsDescendantOf(game) then
		return
	end

	pcall(function()
		Deflect:Activate()
	end)
end

local function updateSpeed(speed,state,distance,aura)
	speedLabel:SetAttribute("PartSpeed",speed)

	speedLabel.Text = string.format(
		"PART SPEED: %.2f\nSTATUS: %s\nDISTANCE: %s\nAURA: %.2f",
		speed,
		state,
		distance and string.format("%.2f",distance) or "--",
		aura or 0
	)
end

openButton.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

toggle.MouseButton1Click:Connect(function()
	autoParryEnabled = not autoParryEnabled

	if autoParryEnabled then
		toggle.Text = "AUTO PARRY: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,200)
		status.Text = "Status: AKTIF"
		status.TextColor3 = COLOR_CYAN
	else
		toggle.Text = "AUTO PARRY: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(100,20,60)
		status.Text = "Status: NONAKTIF"
		status.TextColor3 = Color3.fromRGB(255,90,140)
		destroyAura()
	end
end)

player.CharacterAdded:Connect(function()
	cachedBall = nil
	destroyAura()
end)

RunService.PreRender:Connect(function()
	if not autoParryEnabled then
		return
	end

	local character,hrp = getCharacter()

	if not character or not hrp then
		updateSpeed(0,"WAITING",nil,0)
		return
	end

	local ball = getBall()

	if not ball then
		updateSpeed(0,"WAITING FOR BALL",nil,BASE_AURA)
		updateAura(BASE_AURA)
		return
	end

	if not isValidBall(ball) then
		cachedBall = nil
		updateSpeed(0,"WAITING FOR BALL",nil,BASE_AURA)
		updateAura(BASE_AURA)
		return
	end

	local velocity = ball.AssemblyLinearVelocity
	local speed = velocity.Magnitude

	speedLabel:SetAttribute("PartSpeed",speed)

	local ballPos = ball.Position
	local playerPos = hrp.Position

	local offset = playerPos-ballPos
	local distance = offset.Magnitude

	if speed <= 0.05 then
		updateSpeed(
			0,
			"IDLE",
			distance,
			BASE_AURA
		)

		updateAura(BASE_AURA)
		return
	end

	local directionToPlayer = offset.Unit
	local approachSpeed = velocity:Dot(directionToPlayer)

	local aura = getAura(speed)

	updateAura(aura)

	if approachSpeed <= 0 then
		updateSpeed(
			speed,
			"NO THREAT",
			distance,
			aura
		)
		return
	end

	local ballRadius = math.max(
		ball.Size.X,
		ball.Size.Y,
		ball.Size.Z
	)*0.5

	local detectionRadius =
		aura+ballRadius+2

	local innerRadius =
		INNER_AURA+ballRadius+2

	local clashRadius =
		CLASH_AURA+ballRadius+2

	local timeToContact =
		distance/math.max(approachSpeed,0.001)

	if distance <= clashRadius then

		updateSpeed(
			speed,
			"CLASH SPAM",
			distance,
			aura
		)

		flashUntil = os.clock()+0.035

		clickDeflect()

	elseif distance <= innerRadius then

		updateSpeed(
			speed,
			"INNER AURA",
			distance,
			aura
		)

		flashUntil = os.clock()+0.035

		clickDeflect()

	elseif distance <= detectionRadius then

		updateSpeed(
			speed,
			"OUTER AURA",
			distance,
			aura
		)

		local reactionTime = math.clamp(
			0.06-speed*0.00008,
			0.008,
			0.06
		)

		if timeToContact <= reactionTime then
			flashUntil = os.clock()+0.035
			clickDeflect()
		end

	else

		updateSpeed(
			speed,
			"TRACKING",
			distance,
			aura
		)
	end

	if visualAuraPart then
		if os.clock() < flashUntil then
			visualAuraPart.Color = COLOR_FLASH
		else
			local t = (math.sin(os.clock()*2)+1)/2
			visualAuraPart.Color = COLOR_CYAN:Lerp(
				COLOR_PURPLE,
				t
			)
		end
	end
end)
