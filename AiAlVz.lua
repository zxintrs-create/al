local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local CONFIG_FILE="DeltaMobileConfig.json"

local defaultConfig={JumpX=.85,JumpY=.75,JumpSize=.30,ShiftX=.75,ShiftY=.65,ShiftSize=35,Sensitivity=1}
local config={}
for k,v in pairs(defaultConfig)do config[k]=v end

local SHIFT_LOCK_IMAGE="rbxassetid://103531792987903"
local OPEN_MENU_IMAGE="rbxassetid://114480118578175"

pcall(function()
	if readfile and isfile and isfile(CONFIG_FILE)then
		local d=HttpService:JSONDecode(readfile(CONFIG_FILE))
		if type(d)=="table"then
			for k,v in pairs(d)do
				if defaultConfig[k]~=nil and type(v)==type(defaultConfig[k])then config[k]=v end
			end
		end
	end
end)

local function saveConfig()
	pcall(function()
		if writefile then writefile(CONFIG_FILE,HttpService:JSONEncode(config))end
	end)
end

if _G.DeltaMobileControlsCleanup then pcall(_G.DeltaMobileControlsCleanup)end

local connections={}
local destroyed=false

local function connect(s,f)
	local c
	pcall(function()c=s:Connect(f)end)
	if c then table.insert(connections,c)end
	return c
end

local function disconnectAll()
	for i=#connections,1,-1 do pcall(function()connections[i]:Disconnect()end)end
	table.clear(connections)
end

local function destroyGui(n)
	local g=playerGui:FindFirstChild(n)
	if g then pcall(function()g:Destroy()end)end
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

local gradientObjects={}

local function premium(obj,thickness)
	if not obj or not obj:IsA("GuiObject")then return end
	local stroke=Instance.new("UIStroke")
	stroke.Name="PremiumStroke"
	stroke.Thickness=thickness or 2
	stroke.Color=Color3.new(1,1,1)
	stroke.Parent=obj
	local gradient=Instance.new("UIGradient")
	gradient.Name="PremiumGradient"
	gradient.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
	})
	gradient.Parent=stroke
	gradientObjects[gradient]=true
	return stroke
end

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")

_G.ShiftLocked=false

local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=999999
screenGui.Parent=playerGui

local crosshair=Instance.new("Frame")
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(7,7)
crosshair.Position=UDim2.new(.5,-3.5,.5,-3.5)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000000
crosshair.Parent=screenGui

local crossCorner=Instance.new("UICorner")
crossCorner.CornerRadius=UDim.new(1,0)
crossCorner.Parent=crosshair

local btnShiftLock=Instance.new("ImageButton")
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(.5,.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image=SHIFT_LOCK_IMAGE
btnShiftLock.BackgroundTransparency=1
btnShiftLock.ImageColor3=Color3.new(1,1,1)
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.Selectable=false
btnShiftLock.Visible=false
btnShiftLock.ZIndex=100000
btnShiftLock.Parent=screenGui
premium(btnShiftLock,2.5)

local function toggleShiftLock()
	if destroyed then return end
	_G.ShiftLocked=not _G.ShiftLocked
	btnShiftLock.ImageColor3=_G.ShiftLocked and Color3.fromRGB(255,120,0)or Color3.new(1,1,1)
	crosshair.Visible=_G.ShiftLocked
	if humanoid and humanoid.Parent then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end
end

connect(btnShiftLock.Activated,toggleShiftLock)

local touchGui
local jumpButton

local function getJump()
	touchGui=playerGui:FindFirstChild("TouchGui")
	if not touchGui then jumpButton=nil return end
	jumpButton=touchGui:FindFirstChild("JumpButton",true)
	if jumpButton and jumpButton:IsA("GuiObject")then return jumpButton end
	jumpButton=nil
end

local function updateJump()
	if destroyed then return end
	local j=getJump()
	local cam=workspace.CurrentCamera
	if not j or not cam then return end
	local vp=cam.ViewportSize
	if vp.X<=0 or vp.Y<=0 then return end

	config.JumpX=math.clamp(config.JumpX,.04,.96)
	config.JumpY=math.clamp(config.JumpY,.04,.96)
	config.JumpSize=math.clamp(config.JumpSize,.08,.50)

	local size=math.max(52,math.floor(vp.Y*config.JumpSize))

	pcall(function()
		j.AnchorPoint=Vector2.new(.5,.5)
		j.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
		j.Size=UDim2.fromOffset(size,size)

		local old=j:FindFirstChild("PremiumJumpStroke")
		if old then old:Destroy()end

		local overlay=Instance.new("Frame")
		overlay.Name="PremiumJumpStroke"
		overlay.Size=UDim2.fromScale(1,1)
		overlay.BackgroundTransparency=1
		overlay.BorderSizePixel=0
		overlay.ZIndex=j.ZIndex+2
		overlay.Parent=j

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
		gradient.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
		})
		gradient.Parent=stroke
		gradientObjects[gradient]=true
	end)
end

local function updateShift()
	if destroyed then return end
	config.ShiftX=math.clamp(config.ShiftX,.02,.98)
	config.ShiftY=math.clamp(config.ShiftY,.02,.98)
	config.ShiftSize=math.clamp(config.ShiftSize,25,110)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local gui=Instance.new("ScreenGui")
gui.Name="DeltaMobileErgo"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=1000000
gui.Parent=playerGui

local function makeButton(p,n,pos,size,text,bg,z)
	local b=Instance.new("TextButton")
	b.Name=n
	b.Position=pos
	b.Size=size
	b.Text=text
	b.BackgroundColor3=bg or Color3.fromRGB(35,35,40)
	b.BackgroundTransparency=.02
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=28
	b.AutoButtonColor=false
	b.Active=true
	b.Selectable=false
	b.BorderSizePixel=0
	b.ZIndex=z or 41
	b.Parent=p

	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,16)
	c.Parent=b

	premium(b,2)
	return b
end

local mainFrame=Instance.new("Frame")
mainFrame.Name="WASDFrame"
mainFrame.AnchorPoint=Vector2.new(0,1)
mainFrame.Position=UDim2.new(0,22,1,-24)
mainFrame.Size=UDim2.fromOffset(330,315)
mainFrame.BackgroundTransparency=1
mainFrame.ZIndex=50
mainFrame.Parent=gui

local btnUp=makeButton(mainFrame,"Up",UDim2.fromOffset(108,0),UDim2.fromOffset(88,88),"▲",Color3.fromRGB(35,35,40),51)
local btnLeft=makeButton(mainFrame,"Left",UDim2.fromOffset(12,98),UDim2.fromOffset(88,88),"◀",Color3.fromRGB(35,35,40),51)
local btnRight=makeButton(mainFrame,"Right",UDim2.fromOffset(204,98),UDim2.fromOffset(88,88),"▶",Color3.fromRGB(35,35,40),51)
local btnDown=makeButton(mainFrame,"Down",UDim2.fromOffset(108,196),UDim2.fromOffset(88,88),"▼",Color3.fromRGB(35,35,40),51)

local btnWLock=makeButton(mainFrame,"WLock",UDim2.fromOffset(204,0),UDim2.fromOffset(108,62),"W: OFF",Color3.fromRGB(150,0,0),52)
btnWLock.TextSize=18

local moveState={Forward=false,Backward=false,Left=false,Right=false,WLock=false}

local activeInputs={}

local function bindMove(btn,name)
	connect(btn.InputBegan,function(input)
		local t=input.UserInputType
		if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
			moveState[name]=true
			activeInputs[input]=name
			btn.BackgroundColor3=Color3.fromRGB(65,65,75)
		end
	end)

	connect(btn.InputEnded,function(input)
		local t=input.UserInputType
		if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
			moveState[name]=false
			activeInputs[input]=nil
			btn.BackgroundColor3=Color3.fromRGB(35,35,40)
		end
	end)
end

bindMove(btnUp,"Forward")
bindMove(btnDown,"Backward")
bindMove(btnLeft,"Left")
bindMove(btnRight,"Right")

connect(UserInputService.InputEnded,function(input)
	local name=activeInputs[input]
	if name then
		moveState[name]=false
		activeInputs[input]=nil
	end
end)

connect(btnWLock.Activated,function()
	moveState.WLock=not moveState.WLock
	if moveState.WLock then
		btnWLock.Text="W: ON"
		btnWLock.BackgroundColor3=Color3.fromRGB(0,150,0)
	else
		btnWLock.Text="W: OFF"
		btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
	end
end)

local function getMoveDirection()
	local cam=workspace.CurrentCamera
	if not cam then return Vector3.zero end

	local look=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
	local right=Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)

	if look.Magnitude>.001 then look=look.Unit end
	if right.Magnitude>.001 then right=right.Unit end

	local dir=Vector3.zero

	if moveState.Forward or moveState.WLock then dir+=look end
	if moveState.Backward then dir-=look end
	if moveState.Left then dir-=right end
	if moveState.Right then dir+=right end

	if dir.Magnitude>1 then dir=dir.Unit end
	return dir
end

local AIR_ACCEL=12
local AIR_MAX_SPEED=65

connect(RunService.RenderStepped,function(dt)
	if destroyed or not character or not character.Parent or not humanoid or humanoid.Health<=0 then return end

	local dir=getMoveDirection()
	humanoid:Move(dir,false)

	if humanoid.FloorMaterial==Enum.Material.Air and dir.Magnitude>0 then
		local root=character:FindFirstChild("HumanoidRootPart")
		if root then
			local vel=root.AssemblyLinearVelocity
			local horizontal=Vector3.new(vel.X,0,vel.Z)
			local target=dir*math.min(AIR_MAX_SPEED,humanoid.WalkSpeed)
			local alpha=math.clamp(AIR_ACCEL*dt,0,1)
			local newHorizontal=horizontal:Lerp(target,alpha)
			root.AssemblyLinearVelocity=Vector3.new(newHorizontal.X,vel.Y,newHorizontal.Z)
		end
	end
end)

local menu=Instance.new("ImageButton")
menu.Name="OpenMenu"
menu.AnchorPoint=Vector2.new(1,1)
menu.Position=UDim2.new(1,-22,1,-22)
menu.Size=UDim2.fromOffset(68,68)
menu.Image=OPEN_MENU_IMAGE
menu.BackgroundColor3=Color3.fromRGB(25,25,30)
menu.BackgroundTransparency=.03
menu.AutoButtonColor=false
menu.Active=true
menu.ZIndex=100
menu.Parent=gui
local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu
premium(menu,2.5)

local settings=Instance.new("ScrollingFrame")
settings.Name="SettingsFrame"
settings.AnchorPoint=Vector2.new(.5,.5)
settings.Position=UDim2.new(.5,0,.5,0)
settings.Size=UDim2.new(0,320,0,math.min(650,workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y-30 or 650))
settings.BackgroundColor3=Color3.fromRGB(18,18,22)
settings.BackgroundTransparency=.02
settings.BorderSizePixel=0
settings.ScrollBarThickness=4
settings.Visible=false
settings.ZIndex=40
settings.CanvasSize=UDim2.fromOffset(0,760)
settings.Parent=gui
local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings
premium(settings,2.5)

local shiftToggleSection=Instance.new("Frame")
shiftToggleSection.Size=UDim2.new(1,-20,0,58)
shiftToggleSection.Position=UDim2.fromOffset(10,10)
shiftToggleSection.BackgroundColor3=Color3.fromRGB(30,30,35)
shiftToggleSection.BorderSizePixel=0
shiftToggleSection.ZIndex=41
shiftToggleSection.Parent=settings
local stc=Instance.new("UICorner")
stc.CornerRadius=UDim.new(0,12)
stc.Parent=shiftToggleSection
premium(shiftToggleSection,1.5)

local shiftToggleBtn=makeButton(shiftToggleSection,"ShiftToggleBtn",UDim2.fromOffset(8,7),UDim2.new(1,-16,0,44),"SHIFT LOCK: OFF",Color3.fromRGB(70,35,35),43)
shiftToggleBtn.TextSize=14

local shiftLockVisible=false

connect(shiftToggleBtn.Activated,function()
	shiftLockVisible=not shiftLockVisible
	btnShiftLock.Visible=shiftLockVisible
	if shiftLockVisible then
		shiftToggleBtn.Text="SHIFT LOCK: ON"
		shiftToggleBtn.BackgroundColor3=Color3.fromRGB(35,70,35)
	else
		shiftToggleBtn.Text="SHIFT LOCK: OFF"
		shiftToggleBtn.BackgroundColor3=Color3.fromRGB(70,35,35)
		if _G.ShiftLocked then toggleShiftLock()end
	end
end)

local cameraSection=Instance.new("Frame")
cameraSection.Size=UDim2.new(1,-20,0,150)
cameraSection.Position=UDim2.fromOffset(10,78)
cameraSection.BackgroundColor3=Color3.fromRGB(30,30,35)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings
local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection
premium(cameraSection,1.5)

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,36)
cameraTitle.Text="CAMERA SENSITIVITY"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=17
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,30)
sensLabel.Position=UDim2.fromOffset(0,36)
sensLabel.TextColor3=Color3.fromRGB(220,220,220)
sensLabel.Font=Enum.Font.Gotham
sensLabel.TextSize=14
sensLabel.BackgroundTransparency=1
sensLabel.ZIndex=42
sensLabel.Parent=cameraSection

local function applySensitivity()
	sensLabel.Text="Multiplier: "..string.format("%.1f",config.Sensitivity).."x"
	pcall(function()UserSettings().GameSettings.MouseSensitivity=config.Sensitivity end)
end

local sensMinus=makeButton(cameraSection,"Minus",UDim2.fromOffset(12,82),UDim2.fromOffset(80,46),"-",nil,43)
local sensReset=makeButton(cameraSection,"Reset",UDim2.new(.5,-43,0,82),UDim2.fromOffset(86,46),"RESET",nil,43)
local sensPlus=makeButton(cameraSection,"Plus",UDim2.new(1,-92,0,82),UDim2.fromOffset(80,46),"+",nil,43)

connect(sensMinus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity-.1,.1,10);applySensitivity()end)
connect(sensPlus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity+.1,.1,10);applySensitivity()end)
connect(sensReset.Activated,function()config.Sensitivity=1;applySensitivity()end)

applySensitivity()

local jumpSection=Instance.new("Frame")
jumpSection.Size=UDim2.new(1,-20,0,355)
jumpSection.Position=UDim2.fromOffset(10,238)
jumpSection.BackgroundColor3=Color3.fromRGB(30,30,35)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings
local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection
premium(jumpSection,1.5)

local jumpTitle=Instance.new("TextLabel")
jumpTitle.Size=UDim2.new(1,0,0,35)
jumpTitle.Text="JUMP BUTTON POSITION"
jumpTitle.TextColor3=Color3.new(1,1,1)
jumpTitle.Font=Enum.Font.GothamBold
jumpTitle.TextSize=17
jumpTitle.BackgroundTransparency=1
jumpTitle.ZIndex=42
jumpTitle.Parent=jumpSection

local targetLabel=Instance.new("TextLabel")
targetLabel.Position=UDim2.fromOffset(10,35)
targetLabel.Size=UDim2.new(1,-20,0,28)
targetLabel.Text="TARGET: JUMP BUTTON BAWAAN ROBLOX"
targetLabel.TextColor3=Color3.fromRGB(190,190,210)
targetLabel.Font=Enum.Font.Gotham
targetLabel.TextSize=12
targetLabel.BackgroundTransparency=1
targetLabel.ZIndex=42
targetLabel.Parent=jumpSection

local moveUp=makeButton(jumpSection,"MoveUp",UDim2.new(.5,-38,0,70),UDim2.fromOffset(76,50),"↑",nil,43)
local moveLeft=makeButton(jumpSection,"MoveLeft",UDim2.fromOffset(28,122),UDim2.fromOffset(76,50),"←",nil,43)
local moveRight=makeButton(jumpSection,"MoveRight",UDim2.new(1,-104,0,122),UDim2.fromOffset(76,50),"→",nil,43)
local moveDown=makeButton(jumpSection,"MoveDown",UDim2.new(.5,-38,0,174),UDim2.fromOffset(76,50),"↓",nil,43)

local sizePlus=makeButton(jumpSection,"SizePlus",UDim2.fromOffset(20,245),UDim2.fromOffset(85,40),"SIZE +",nil,43)
local center=makeButton(jumpSection,"Center",UDim2.new(.5,-43,0,245),UDim2.fromOffset(86,40),"RESET",nil,43)
local sizeMinus=makeButton(jumpSection,"SizeMinus",UDim2.new(1,-105,0,245),UDim2.fromOffset(85,40),"SIZE -",nil,43)

local step=.015
local holding={}

local function bindHold(b,dx,dy)
	connect(b.InputBegan,function(input)
		local t=input.UserInputType
		if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
			holding[b]=true
		end
	end)

	connect(b.InputEnded,function(input)
		local t=input.UserInputType
		if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
			holding[b]=false
		end
	end)

	connect(b.Activated,function()
		if not holding[b] then
			if targetLabel.Text=="TARGET: JUMP BUTTON BAWAAN ROBLOX" then
				config.JumpX=math.clamp(config.JumpX+dx,.04,.96)
				config.JumpY=math.clamp(config.JumpY+dy,.04,.96)
				updateJump()
			end
		end
	end)

	b:SetAttribute("DX",dx)
	b:SetAttribute("DY",dy)
end

bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)

connect(UserInputService.InputEnded,function(input)
	local t=input.UserInputType
	if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
		for b in pairs(holding)do holding[b]=false end
	end
end)

connect(RunService.RenderStepped,function()
	for b,state in pairs(holding)do
		if state then
			local dx=b:GetAttribute("DX") or 0
			local dy=b:GetAttribute("DY") or 0
			config.JumpX=math.clamp(config.JumpX+dx,.04,.96)
			config.JumpY=math.clamp(config.JumpY+dy,.04,.96)
			updateJump()
		end
	end
end)

connect(sizePlus.Activated,function()
	config.JumpSize=math.clamp(config.JumpSize+.03,.08,.50)
	updateJump()
end)

connect(sizeMinus.Activated,function()
	config.JumpSize=math.clamp(config.JumpSize-.03,.08,.50)
	updateJump()
end)

connect(center.Activated,function()
	config.JumpX=defaultConfig.JumpX
	config.JumpY=defaultConfig.JumpY
	config.JumpSize=defaultConfig.JumpSize
	updateJump()
end)

local saveButton=makeButton(settings,"SaveConfig",UDim2.fromOffset(20,700),UDim2.fromOffset(130,42),"SAVE",Color3.fromRGB(45,100,55),43)
local closeButton=makeButton(settings,"Close",UDim2.new(1,-150,0,700),UDim2.fromOffset(130,42),"CLOSE",Color3.fromRGB(100,40,40),43)

connect(saveButton.Activated,function()
	saveConfig()
	saveButton.Text="SAVED!"
	task.delay(1,function()
		if saveButton and saveButton.Parent then saveButton.Text="SAVE"end
	end)
end)

connect(closeButton.Activated,function()settings.Visible=false end)
connect(menu.Activated,function()settings.Visible=not settings.Visible end)

connect(player.CharacterAdded,function(newChar)
	if destroyed then return end
	for b in pairs(holding)do holding[b]=false end
	moveState.Forward=false
	moveState.Backward=false
	moveState.Left=false
	moveState.Right=false
	character=newChar
	humanoid=newChar:WaitForChild("Humanoid",10)
	if humanoid then
		humanoid.AutoRotate=not _G.ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end
	task.defer(updateJump)
	task.delay(.25,updateJump)
	task.delay(.7,updateJump)
end)

connect(playerGui.ChildAdded,function(c)
	if c.Name=="TouchGui"then
		jumpButton=nil
		task.defer(updateJump)
		task.delay(.25,updateJump)
		task.delay(.7,updateJump)
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed or not character or not character.Parent or not humanoid or humanoid.Health<=0 then return end

	humanoid.CameraOffset=Vector3.zero

	if _G.ShiftLocked then
		local cam=workspace.CurrentCamera
		local root=character:FindFirstChild("HumanoidRootPart")
		if cam and root then
			local look=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
			if look.Magnitude>.001 then
				root.CFrame=CFrame.lookAt(root.Position,root.Position+look.Unit)
			end
		end
		humanoid.AutoRotate=false
	else
		humanoid.AutoRotate=true
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end
	for g in pairs(gradientObjects)do
		if g and g.Parent then
			g.Rotation=(g.Rotation+1)%360
		else
			gradientObjects[g]=nil
		end
	end
end)

connect(RunService.RenderStepped,function()
	if destroyed then return end
	local tg=playerGui:FindFirstChild("TouchGui")
	if tg then
		local j=tg:FindFirstChild("JumpButton",true)
		if j and j:IsA("GuiObject")then
			if j.Size.X.Offset<52 or j.Size.Y.Offset<52 then updateJump()end
		end
	end
end)

updateJump()
updateShift()

task.delay(.2,function()
	updateJump()
	updateShift()
end)

task.delay(.6,function()
	updateJump()
	updateShift()
end)
