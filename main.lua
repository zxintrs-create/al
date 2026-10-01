local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local PlayerGui=player:WaitForChild("PlayerGui")

local input=PlayerGui:WaitForChild("INPUT_BUTTONS",10)
local touch=input and input:WaitForChild("TouchFrame",10)
local deflectFolder=touch and touch:WaitForChild("Deflect_Button",10)
local button=deflectFolder and deflectFolder:WaitForChild("Button",10)

if not button or not button:IsA("GuiButton") then
	warn("Deflect Button tidak ditemukan")
	return
end

local old=PlayerGui:FindFirstChild("VainlyStarSpeedDetector")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="VainlyStarSpeedDetector"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.Parent=PlayerGui

local label=Instance.new("TextLabel")
label.Size=UDim2.fromOffset(190,105)
label.Position=UDim2.fromOffset(8,70)
label.BackgroundColor3=Color3.fromRGB(12,12,18)
label.BackgroundTransparency=.1
label.TextColor3=Color3.fromRGB(255,255,255)
label.Font=Enum.Font.GothamBold
label.TextSize=13
label.TextXAlignment=Enum.TextXAlignment.Left
label.TextYAlignment=Enum.TextYAlignment.Center
label.Text="PART SPEED: 0\nSTATUS: IDLE\nDISTANCE: --\nAURA: --"
label.Parent=gui

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,8)
corner.Parent=label

local stroke=Instance.new("UIStroke")
stroke.Thickness=1.5
stroke.Color=Color3.fromRGB(0,220,255)
stroke.Parent=label

local OUTER_BASE=10
local SPEED_AURA_FACTOR=.055
local MIN_AURA=12
local MAX_AURA=65

local INNER_RADIUS=8
local CLASH_RADIUS=4

local PREDICTION_TIME=.045

local ball=nil
local ballLastPosition=nil
local ballLastTime=0

local spawns={}
local mapConnection=nil

local labelTimer=0
local lastStatus=""
local lastSpeed=-1
local lastDistance=-1
local lastAura=-1

local function getCharacter()
	local c=player.Character
	if not c then return nil,nil end

	local hrp=c:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil,nil end

	return c,hrp
end

local function refreshSpawns()
	table.clear(spawns)

	local active=Workspace:FindFirstChild("ActiveMap")
	if not active then return end

	for _,v in ipairs(active:GetDescendants()) do
		if v.Name=="BallSpawns" then
			if v:IsA("BasePart") then
				spawns[#spawns+1]=v
			else
				for _,p in ipairs(v:GetDescendants()) do
					if p:IsA("BasePart") then
						spawns[#spawns+1]=p
					end
				end
			end
		end
	end
end

local function nearSpawn(part)
	if #spawns==0 then
		return false
	end

	local pos=part.Position

	for _,spawn in ipairs(spawns) do
		if spawn and spawn:IsDescendantOf(Workspace) then
			if (pos-spawn.Position).Magnitude<=80 then
				return true
			end
		end
	end

	return false
end

local function validCandidate(obj)
	if not obj or not obj:IsA("BasePart") then
		return false
	end

	if not obj:IsDescendantOf(Workspace) then
		return false
	end

	if obj.Anchored then
		return false
	end

	if obj:IsDescendantOf(player.Character or nil) then
		return false
	end

	return nearSpawn(obj)
end

local function setBall(obj)
	if validCandidate(obj) then
		ball=obj
		ballLastPosition=obj.Position
		ballLastTime=os.clock()
	end
end

refreshSpawns()

for _,obj in ipairs(Workspace:GetChildren()) do
	if validCandidate(obj) then
		setBall(obj)
	end
end

Workspace.ChildAdded:Connect(function(obj)
	task.defer(function()
		if not obj:IsDescendantOf(Workspace) then return end

		if #spawns==0 then
			refreshSpawns()
		end

		if validCandidate(obj) then
			setBall(obj)
		end
	end)
end)

Workspace.ChildRemoved:Connect(function(obj)
	if obj==ball then
		ball=nil
		ballLastPosition=nil
		ballLastTime=0
	end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if #spawns==0 then
		refreshSpawns()
	end
end)

task.spawn(function()
	while gui.Parent do
		if #spawns==0 then
			refreshSpawns()
		end
		task.wait(.5)
	end
end)

local function getSpeed(part)
	if not part then return 0 end

	local v=part.AssemblyLinearVelocity
	local speed=v.Magnitude

	if speed<.05 then
		return 0
	end

	return speed
end

local function getAura(speed)
	return math.clamp(
		MIN_AURA+(speed*SPEED_AURA_FACTOR),
		MIN_AURA,
		MAX_AURA
	)
end

local function updateLabel(speed,status,distance,aura,force)
	if not force
		and math.abs(speed-lastSpeed)<.5
		and status==lastStatus
		and math.abs((distance or 0)-lastDistance)<.25
		and math.abs((aura or 0)-lastAura)<.25
	then
		return
	end

	lastSpeed=speed
	lastStatus=status
	lastDistance=distance or 0
	lastAura=aura or 0

	label.Text=string.format(
		"PART SPEED: %.2f\nSTATUS: %s\nDISTANCE: %.2f\nAURA: %.2f",
		speed,
		status,
		distance or 0,
		aura or 0
	)
end

local function click()
	pcall(function()
		button:Activate()
	end)
end

local function getApproach(ball,hrp)
	local offset=hrp.Position-ball.Position
	local distance=offset.Magnitude

	if distance<=.001 then
		return distance,0
	end

	local direction=offset.Unit
	local velocity=ball.AssemblyLinearVelocity
	local approach=velocity:Dot(direction)

	return distance,approach
end

RunService.RenderStepped:Connect(function(dt)
	local _,hrp=getCharacter()

	if not hrp then
		updateLabel(0,"IDLE",0,0,true)
		return
	end

	if not ball or not ball:IsDescendantOf(Workspace) then
		ball=nil
		updateLabel(0,"IDLE",0,0,true)
		return
	end

	local velocity=ball.AssemblyLinearVelocity
	local speed=velocity.Magnitude

	if speed<=.05 then
		updateLabel(0,"IDLE",0,0)
		return
	end

	local distance,approach=getApproach(ball,hrp)

	if approach<=0 then
		updateLabel(speed,"NO THREAT",distance,getAura(speed))
		return
	end

	local aura=getAura(speed)

	local ballRadius=math.max(
		ball.Size.X,
		ball.Size.Y,
		ball.Size.Z
	)*.5

	local characterRadius=2

	local outerRadius=aura+ballRadius+characterRadius
	local innerRadius=INNER_RADIUS+ballRadius+characterRadius
	local clashRadius=CLASH_RADIUS+ballRadius+characterRadius

	local tti=distance/math.max(approach,.01)

	local predictedDistance=distance-(approach*PREDICTION_TIME)

	if distance<=clashRadius then
		updateLabel(speed,"CLASH",distance,aura)

		click()

	elseif distance<=innerRadius or predictedDistance<=innerRadius then
		updateLabel(speed,"INNER AURA",distance,aura)

		click()

	elseif distance<=outerRadius then
		updateLabel(speed,"OUTER AURA",distance,aura)

		local clickWindow=math.clamp(
			.025+(speed*.00015),
			.025,
			.075
		)

		if tti<=clickWindow then
			click()
		end

	else
		updateLabel(speed,"TRACKING",distance,aura)
	end

	ballLastPosition=ball.Position
	ballLastTime=os.clock()
end)
