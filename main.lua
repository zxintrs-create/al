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
if old then
	old:Destroy()
end

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
openButton.Text = "🌙 VOID MOON"
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
speedLabel.Text = "PART SPEED: 0\nSTATUS: IDLE\nDISTANCE: 0\nAURA: 0"
speedLabel.ZIndex = 20
speedLabel.Parent = gui

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,8)
speedCorner.Parent = speedLabel

local speedStroke = Instance.new("UIStroke")
speedStroke.Thickness = 1.5
speedStroke.Color = COLOR_CYAN
speedStroke.Parent = speedLabel

local function getCharacter()
	local character = player.Character
	if not character then
		return nil,nil
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil,nil
	end

	return character,hrp
end

local function getBallSpawns()
	local result = {}
	local activeMap = Workspace:FindFirstChild("ActiveMap")

	if not activeMap then
		return result
	end

	for _,obj in ipairs(activeMap:GetDescendants()) do
		if obj.Name == "BallSpawns" then
			if obj:IsA("BasePart") then
				result[#result+1] = obj
			else
				for _,p in ipairs(obj:GetDescendants()) do
					if p:IsA("BasePart") then
						result[#result+1] = p
					end
				end
			end
		end
	end

	return result
end

local function isNearSpawn(part)
	local spawns = getBallSpawns()

	if #spawns == 0 then
		return false
	end

	for _,spawn in ipairs(spawns) do
		if spawn:IsDescendantOf(Workspace) then
			if (part.Position-spawn.Position).Magnitude <= 30 then
				return true
			end
		end
	end

	return false
end

local function isValidBall(part)
	if not part then
		return false
	end

	if not part:IsDescendantOf(Workspace) then
		return false
	end

	if not part:IsA("BasePart") then
		return false
	end

	local character = player.Character

	if character and part:IsDescendantOf(character) then
		return false
	end

	return true
end

local function findInitialBall()
	local spawns = getBallSpawns()

	if #spawns == 0 then
		return nil
	end

	local best = nil
	local bestDistance = math.huge

	for _,obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") then
			if not (player.Character and obj:IsDescendantOf(player.Character)) then
				for _,spawn in ipairs(spawns) do
					local distance = (obj.Position-spawn.Position).Magnitude

					if distance < 30 and distance < bestDistance then
						best = obj
						bestDistance = distance
					end
				end
			end
		end
	end

	return best
end

local function getBall()
	if isValidBall(cachedBall) then
		return cachedBall
	end

	cachedBall = findInitialBall()

	return cachedBall
end

Workspace.ChildAdded:Connect(function(obj)
	if not obj:IsA("BasePart") then
		return
	end

	if player.Character and obj:IsDescendantOf(player.Character) then
		return
	end

	if isNearSpawn(obj) then
		cachedBall = obj
	end
end)

Workspace.ChildRemoved:Connect(function(obj)
	if obj == cachedBall then
		cachedBall = nil
	end
end)

local function getAura(speed)
	return math.clamp(
		BASE_AURA + speed * SPEED_AURA_FACTOR,
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

	local diameter = radius * 2
	visualAuraPart.Size = Vector3.new(diameter,diameter,diameter)
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
		"PART SPEED: %.2f\nSTATUS: %s\nDISTANCE: %.2f\nAURA: %.2f",
		speed,
		state,
		distance or 0,
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
		updateSpeed(0,"IDLE",0,0)
		return
	end

	local ball = getBall()

	if not isValidBall(ball) then
		updateSpeed(0,"IDLE",0,0)
		return
	end

	local velocity = ball.AssemblyLinearVelocity
	local speed = velocity.Magnitude

	if speed <= 0.05 then
		updateSpeed(0,"IDLE",(ball.Position-hrp.Position).Magnitude,BASE_AURA)
		updateAura(BASE_AURA)
		return
	end

	local distanceVector = hrp.Position-ball.Position
	local distance = distanceVector.Magnitude

	if distance <= 0.001 then
		clickDeflect()
		return
	end

	local directionToPlayer = distanceVector.Unit
	local approachSpeed = velocity:Dot(directionToPlayer)

	local aura = getAura(speed)

	updateAura(aura)

	speedLabel:SetAttribute("PartSpeed",speed)

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
	) * 0.5

	local detectionRadius =
		aura + ballRadius + 2

	local innerRadius =
		INNER_AURA + ballRadius + 2

	local clashRadius =
		CLASH_AURA + ballRadius + 2

	local timeToContact =
		distance / math.max(approachSpeed,0.001)

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

		-- Semakin cepat Part, semakin cepat masuk fase click.
		local reactionTime =
			math.clamp(
				0.06 - speed * 0.00008,
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
			visualAuraPart.Color = COLOR_CYAN:Lerp(
				COLOR_PURPLE,
				(math.sin(os.clock()*2)+1)/2
			)
		end
	end
end)
