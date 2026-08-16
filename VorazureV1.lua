local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE="VZMenuConfig.json"

local defaultConfig={
	JumpX=0.85,
	JumpY=0.75,
	JumpSize=0.30,
	ShiftX=0.75,
	ShiftY=0.65,
	ShiftSize=35
}

local config={}
for k,v in pairs(defaultConfig)do
	config[k]=v
end

local function loadConfig()
	if type(isfile)~="function"or type(readfile)~="function"then return end
	if not isfile(CONFIG_FILE)then return end
	pcall(function()
		local data=HttpService:JSONDecode(readfile(CONFIG_FILE))
		if type(data)=="table"then
			for k,v in pairs(defaultConfig)do
				if type(data[k])==type(v)then
					config[k]=data[k]
				end
			end
		end
	end)
	config.JumpX=math.clamp(tonumber(config.JumpX)or defaultConfig.JumpX,0.05,0.95)
	config.JumpY=math.clamp(tonumber(config.JumpY)or defaultConfig.JumpY,0.05,0.95)
	config.JumpSize=math.clamp(tonumber(config.JumpSize)or defaultConfig.JumpSize,0.05,0.50)
	config.ShiftX=math.clamp(tonumber(config.ShiftX)or defaultConfig.ShiftX,0.05,0.95)
	config.ShiftY=math.clamp(tonumber(config.ShiftY)or defaultConfig.ShiftY,0.05,0.95)
	config.ShiftSize=math.clamp(tonumber(config.ShiftSize)or defaultConfig.ShiftSize,20,100)
end

local function saveConfig()
	if type(writefile)~="function"then return false end
	return pcall(function()
		writefile(CONFIG_FILE,HttpService:JSONEncode(config))
	end)
end

loadConfig()

pcall(function()
	local old=CoreGui:FindFirstChild("VZMenu")
	if old then old:Destroy()end
end)

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder=999999
ScreenGui.Parent=CoreGui

local Loading=Instance.new("Frame")
Loading.Name="Loading"
Loading.Size=UDim2.fromScale(1,1)
Loading.BackgroundColor3=Color3.fromRGB(8,8,12)
Loading.BorderSizePixel=0
Loading.ZIndex=10000
Loading.Parent=ScreenGui

local LoadingTitle=Instance.new("TextLabel")
LoadingTitle.Size=UDim2.new(1,0,0,45)
LoadingTitle.Position=UDim2.new(0,0,0.43,0)
LoadingTitle.BackgroundTransparency=1
LoadingTitle.Text="VZ MENU"
LoadingTitle.TextColor3=Color3.new(1,1,1)
LoadingTitle.Font=Enum.Font.GothamBlack
LoadingTitle.TextSize=28
LoadingTitle.ZIndex=10001
LoadingTitle.Parent=Loading

local LoadingText=Instance.new("TextLabel")
LoadingText.Size=UDim2.new(1,0,0,30)
LoadingText.Position=UDim2.new(0,0,0.51,0)
LoadingText.BackgroundTransparency=1
LoadingText.Text="Loading..."
LoadingText.TextColor3=Color3.fromRGB(255,220,0)
LoadingText.Font=Enum.Font.GothamBold
LoadingText.TextSize=13
LoadingText.ZIndex=10001
LoadingText.Parent=Loading

local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.fromOffset(58,58)
OpenMenu.Position=UDim2.new(0.05,0,0.15,0)
OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2
OpenMenu.BorderSizePixel=0
OpenMenu.AutoButtonColor=false
OpenMenu.Active=true
OpenMenu.Image="rbxassetid://139928547001912"
OpenMenu.ImageColor3=Color3.new(1,1,1)
OpenMenu.ScaleType=Enum.ScaleType.Fit
OpenMenu.ZIndex=100
OpenMenu.Parent=ScreenGui

Instance.new("UICorner",OpenMenu).CornerRadius=UDim.new(8,0)

local OpenStroke=Instance.new("UIStroke")
OpenStroke.Thickness=2
OpenStroke.Color=Color3.new(1,1,1)
OpenStroke.Parent=OpenMenu

local OpenGradient=Instance.new("UIGradient")
OpenGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
OpenGradient.Parent=OpenStroke

local MenuFrame=Instance.new("Frame")
MenuFrame.Name="MenuFrame"
MenuFrame.Size=UDim2.fromOffset(680,420)
MenuFrame.Position=UDim2.new(0.5,-340,0.5,-210)
MenuFrame.BackgroundColor3=Color3.fromRGB(12,12,18)
MenuFrame.BorderSizePixel=0
MenuFrame.Visible=false
MenuFrame.ZIndex=20
MenuFrame.Parent=ScreenGui

Instance.new("UICorner",MenuFrame).CornerRadius=UDim.new(0,8)

local MenuStroke=Instance.new("UIStroke")
MenuStroke.Thickness=2
MenuStroke.Color=Color3.new(1,1,1)
MenuStroke.Parent=MenuFrame

local MenuGradient=Instance.new("UIGradient")
MenuGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
MenuGradient.Parent=MenuStroke

local TopBar=Instance.new("Frame")
TopBar.Size=UDim2.new(1,0,0,35)
TopBar.BackgroundColor3=Color3.fromRGB(18,18,26)
TopBar.BorderSizePixel=0
TopBar.ZIndex=21
TopBar.Parent=MenuFrame

Instance.new("UICorner",TopBar).CornerRadius=UDim.new(0,8)

local TitleInfo=Instance.new("TextLabel")
TitleInfo.Size=UDim2.new(1,-20,1,0)
TitleInfo.Position=UDim2.new(0,15,0,0)
TitleInfo.BackgroundTransparency=1
TitleInfo.Font=Enum.Font.GothamBold
TitleInfo.TextSize=13
TitleInfo.TextColor3=Color3.new(1,1,1)
TitleInfo.TextXAlignment=Enum.TextXAlignment.Left
TitleInfo.Text="ALDO VORA ZURE      FPS : 0      PING : 0 ms"
TitleInfo.ZIndex=22
TitleInfo.Parent=TopBar

local Sidebar=Instance.new("Frame")
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0.28,0,1,-35)
Sidebar.Position=UDim2.new(0,0,0,35)
Sidebar.BackgroundColor3=Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency=0.5
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=21
Sidebar.Parent=MenuFrame

local SidebarLayout=Instance.new("UIListLayout")
SidebarLayout.SortOrder=Enum.SortOrder.LayoutOrder
SidebarLayout.Padding=UDim.new(0,6)
SidebarLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
SidebarLayout.Parent=Sidebar

local MenuLabel=Instance.new("TextLabel")
MenuLabel.Size=UDim2.new(1,0,0,35)
MenuLabel.BackgroundTransparency=1
MenuLabel.Text="MENU   :"
MenuLabel.TextColor3=Color3.fromRGB(255,220,0)
MenuLabel.Font=Enum.Font.GothamBlack
MenuLabel.TextSize=14
MenuLabel.ZIndex=22
MenuLabel.Parent=Sidebar

local ContentArea=Instance.new("Frame")
ContentArea.Name="ContentArea"
ContentArea.Size=UDim2.new(0.72,0,1,-35)
ContentArea.Position=UDim2.new(0.28,0,0,35)
ContentArea.BackgroundTransparency=1
ContentArea.ZIndex=21
ContentArea.Parent=MenuFrame

local function CreateMainFrame(name)
	local frame=Instance.new("Frame")
	frame.Name=name
	frame.Size=UDim2.fromScale(1,1)
	frame.BackgroundTransparency=1
	frame.Visible=false
	frame.ZIndex=22
	frame.Parent=ContentArea
	local layout=Instance.new("UIListLayout")
	layout.SortOrder=Enum.SortOrder.LayoutOrder
	layout.Padding=UDim.new(0,8)
	layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
	layout.VerticalAlignment=Enum.VerticalAlignment.Center
	layout.Parent=frame
	return frame
end

local MainFrameJump=CreateMainFrame("MainFrameJump")
local MainFrameShiftLock=CreateMainFrame("MainFrameShiftLock")
local MainFrameDance=CreateMainFrame("MainFrameDance")

local function SwitchMenu(target)
	MainFrameJump.Visible=target==MainFrameJump
	MainFrameShiftLock.Visible=target==MainFrameShiftLock
	MainFrameDance.Visible=target==MainFrameDance
end

local function CreateNavButton(text,target)
	local button=Instance.new("TextButton")
	button.Size=UDim2.new(0.9,0,0,38)
	button.BackgroundColor3=Color3.fromRGB(25,25,35)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=13
	button.Text=text
	button.ZIndex=23
	button.Parent=Sidebar
	Instance.new("UICorner",button).CornerRadius=UDim.new(0,6)
	button.Activated:Connect(function()
		SwitchMenu(target)
	end)
	return button
end

CreateNavButton("Jump",MainFrameJump)
CreateNavButton("Shift lock",MainFrameShiftLock)
CreateNavButton("Emote",MainFrameDance)

local function CreateControlBtn(parent,text,callback)
	local button=Instance.new("TextButton")
	button.Size=UDim2.new(0.85,0,0,32)
	button.BackgroundColor3=Color3.fromRGB(22,22,32)
	button.TextColor3=Color3.new(1,1,1)
	button.Font=Enum.Font.GothamBold
	button.TextSize=13
	button.Text=text
	button.ZIndex=24
	button.Parent=parent
	Instance.new("UICorner",button).CornerRadius=UDim.new(0,6)
	button.Activated:Connect(callback)
	return button
end

local function CreateControlLbl(parent,text)
	local label=Instance.new("TextLabel")
	label.Size=UDim2.new(0.85,0,0,25)
	label.BackgroundTransparency=1
	label.TextColor3=Color3.fromRGB(255,220,0)
	label.Font=Enum.Font.GothamBlack
	label.TextSize=14
	label.Text=text
	label.ZIndex=24
	label.Parent=parent
	return label
end

CreateControlLbl(MainFrameJump,"Jump  setting")

local JumpButton

local function getJumpButton()
	if JumpButton and JumpButton.Parent then
		return JumpButton
	end
	JumpButton=nil
	local TouchGui=PlayerGui:FindFirstChild("TouchGui")
	if TouchGui then
		JumpButton=TouchGui:FindFirstChild("JumpButton",true)
	end
	return JumpButton
end

local function applyJumpPosition()
	local button=getJumpButton()
	if not button then return end
	button.AnchorPoint=Vector2.new(0.5,0.5)
	button.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
end

local function applyJumpSize()
	local button=getJumpButton()
	local camera=workspace.CurrentCamera
	if not button or not camera then return end
	local size=math.clamp(math.floor(camera.ViewportSize.Y*config.JumpSize),40,160)
	button.Size=UDim2.fromOffset(size,size)
end

local function applyJump()
	applyJumpPosition()
	applyJumpSize()
end

CreateControlBtn(MainFrameJump,"↑",function()
	config.JumpY=math.clamp(config.JumpY-0.05,0.05,0.95)
	applyJumpPosition()
end)

local rowJumpLR=Instance.new("Frame")
rowJumpLR.Size=UDim2.new(0.85,0,0,32)
rowJumpLR.BackgroundTransparency=1
rowJumpLR.ZIndex=24
rowJumpLR.Parent=MainFrameJump

local btnJumpL=CreateControlBtn(rowJumpLR,"←",function()
	config.JumpX=math.clamp(config.JumpX-0.05,0.05,0.95)
	applyJumpPosition()
end)
btnJumpL.Size=UDim2.new(0.48,0,1,0)

local btnJumpR=CreateControlBtn(rowJumpLR,"→",function()
	config.JumpX=math.clamp(config.JumpX+0.05,0.05,0.95)
	applyJumpPosition()
end)
btnJumpR.Size=UDim2.new(0.48,0,1,0)
btnJumpR.Position=UDim2.new(0.52,0,0,0)

CreateControlBtn(MainFrameJump,"↓",function()
	config.JumpY=math.clamp(config.JumpY+0.05,0.05,0.95)
	applyJumpPosition()
end)

local rowJumpSize=Instance.new("Frame")
rowJumpSize.Size=UDim2.new(0.85,0,0,32)
rowJumpSize.BackgroundTransparency=1
rowJumpSize.ZIndex=24
rowJumpSize.Parent=MainFrameJump

local bSzPlusJump=CreateControlBtn(rowJumpSize,"size+",function()
	config.JumpSize=math.clamp(config.JumpSize+0.05,0.05,0.50)
	applyJumpSize()
end)
bSzPlusJump.Size=UDim2.new(0.48,0,1,0)

local bSzMinJump=CreateControlBtn(rowJumpSize,"size-",function()
	config.JumpSize=math.clamp(config.JumpSize-0.05,0.05,0.50)
	applyJumpSize()
end)
bSzMinJump.Size=UDim2.new(0.48,0,1,0)
bSzMinJump.Position=UDim2.new(0.52,0,0,0)

local rowJumpSR=Instance.new("Frame")
rowJumpSR.Size=UDim2.new(0.85,0,0,32)
rowJumpSR.BackgroundTransparency=1
rowJumpSR.ZIndex=24
rowJumpSR.Parent=MainFrameJump

local btnSave=CreateControlBtn(rowJumpSR,"Save",function()
	local ok=saveConfig()
	btnSave.Text=ok and"Saved"or"Failed"
	task.delay(1,function()
		if btnSave.Parent then
			btnSave.Text="Save"
		end
	end)
end)
btnSave.Size=UDim2.new(0.48,0,1,0)
btnSave.TextColor3=Color3.fromRGB(0,255,100)

local btnReset=CreateControlBtn(rowJumpSR,"reset",function()
	config.JumpX=defaultConfig.JumpX
	config.JumpY=defaultConfig.JumpY
	config.JumpSize=defaultConfig.JumpSize
	applyJump()
	saveConfig()
end)
btnReset.Size=UDim2.new(0.48,0,1,0)
btnReset.Position=UDim2.new(0.52,0,0,0)
btnReset.TextColor3=Color3.fromRGB(255,50,50)

CreateControlLbl(MainFrameShiftLock,"Shift lock setting")

local ShiftLocked=false

local crosshair=Instance.new("Frame")
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.Position=UDim2.fromScale(0.5,0.5)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000
crosshair.Parent=ScreenGui
Instance.new("UICorner",crosshair).CornerRadius=UDim.new(1,0)

local btnShiftLock=Instance.new("ImageButton")
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(0.5,0.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.BackgroundColor3=Color3.fromRGB(255,255,255)
btnShiftLock.BackgroundTransparency=0.2
btnShiftLock.BorderSizePixel=0
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.Image="rbxassetid://136616143786672"
btnShiftLock.ImageColor3=Color3.new(1,1,1)
btnShiftLock.ScaleType=Enum.ScaleType.Fit
btnShiftLock.ZIndex=999
btnShiftLock.Parent=ScreenGui

Instance.new("UICorner",btnShiftLock).CornerRadius=UDim.new(1,0)

local ShiftStroke=Instance.new("UIStroke")
ShiftStroke.Thickness=2
ShiftStroke.Color=Color3.new(1,1,1)
ShiftStroke.Parent=btnShiftLock

local function updateShiftVisual()
	if ShiftLocked then
		btnShiftLock.ImageColor3=Color3.fromRGB(0,255,100)
		btnShiftLock.BackgroundColor3=Color3.fromRGB(10,60,25)
		ShiftStroke.Color=Color3.fromRGB(0,255,100)
		crosshair.Visible=true
	else
		btnShiftLock.ImageColor3=Color3.new(1,1,1)
		btnShiftLock.BackgroundColor3=Color3.fromRGB(255,255,255)
		ShiftStroke.Color=Color3.new(1,1,1)
		crosshair.Visible=false
	end
end

local function setShiftLock(state)
	ShiftLocked=state
	updateShiftVisual()
	local character=LocalPlayer.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.AutoRotate=not ShiftLocked
		humanoid.CameraOffset=Vector3.zero
	end
end

btnShiftLock.Activated:Connect(function()
	setShiftLock(not ShiftLocked)
end)

CreateControlBtn(MainFrameShiftLock,"↑",function()
	config.ShiftY=math.clamp(config.ShiftY-0.05,0.05,0.95)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)

local rowShiftLR=Instance.new("Frame")
rowShiftLR.Size=UDim2.new(0.85,0,0,32)
rowShiftLR.BackgroundTransparency=1
rowShiftLR.ZIndex=24
rowShiftLR.Parent=MainFrameShiftLock

local btnShiftL=CreateControlBtn(rowShiftLR,"←",function()
	config.ShiftX=math.clamp(config.ShiftX-0.05,0.05,0.95)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
btnShiftL.Size=UDim2.new(0.48,0,1,0)

local btnShiftR=CreateControlBtn(rowShiftLR,"→",function()
	config.ShiftX=math.clamp(config.ShiftX+0.05,0.05,0.95)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
btnShiftR.Size=UDim2.new(0.48,0,1,0)
btnShiftR.Position=UDim2.new(0.52,0,0,0)

CreateControlBtn(MainFrameShiftLock,"↓",function()
	config.ShiftY=math.clamp(config.ShiftY+0.05,0.05,0.95)
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)

local rowShiftSize=Instance.new("Frame")
rowShiftSize.Size=UDim2.new(0.85,0,0,32)
rowShiftSize.BackgroundTransparency=1
rowShiftSize.ZIndex=24
rowShiftSize.Parent=MainFrameShiftLock

local bSzPlusShift=CreateControlBtn(rowShiftSize,"size+",function()
	config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
bSzPlusShift.Size=UDim2.new(0.48,0,1,0)

local bSzMinShift=CreateControlBtn(rowShiftSize,"size-",function()
	config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
bSzMinShift.Size=UDim2.new(0.48,0,1,0)
bSzMinShift.Position=UDim2.new(0.52,0,0,0)

local rowShiftSR=Instance.new("Frame")
rowShiftSR.Size=UDim2.new(0.85,0,0,32)
rowShiftSR.BackgroundTransparency=1
rowShiftSR.ZIndex=24
rowShiftSR.Parent=MainFrameShiftLock

local btnSaveShift=CreateControlBtn(rowShiftSR,"Save",function()
	local ok=saveConfig()
	btnSaveShift.Text=ok and"Saved"or"Failed"
	task.delay(1,function()
		if btnSaveShift.Parent then
			btnSaveShift.Text="Save"
		end
	end)
end)
btnSaveShift.Size=UDim2.new(0.48,0,1,0)
btnSaveShift.TextColor3=Color3.fromRGB(0,255,100)

local btnResetShift=CreateControlBtn(rowShiftSR,"reset",function()
	config.ShiftX=defaultConfig.ShiftX
	config.ShiftY=defaultConfig.ShiftY
	config.ShiftSize=defaultConfig.ShiftSize
	btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
	btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
	saveConfig()
end)
btnResetShift.Size=UDim2.new(0.48,0,1,0)
btnResetShift.Position=UDim2.new(0.52,0,0,0)
btnResetShift.TextColor3=Color3.fromRGB(255,50,50)

CreateControlLbl(MainFrameDance,"Emotes & Dances")

local function PlayAnimation(assetId)
	local character=LocalPlayer.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator=humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator=Instance.new("Animator")
		animator.Parent=humanoid
	end
	local animation=Instance.new("Animation")
	animation.AnimationId="rbxassetid://"..tostring(assetId)
	local ok,track=pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if ok and track then
		track:Play(0.1)
	end
	task.delay(1,function()
		if animation.Parent then
			animation:Destroy()
		end
	end)
end

CreateControlBtn(MainFrameDance,"Dance 1",function()
	PlayAnimation(507710273)
end)

CreateControlBtn(MainFrameDance,"Dance 2",function()
	PlayAnimation(507719543)
end)

CreateControlBtn(MainFrameDance,"Emote 1",function()
	PlayAnimation(591577311)
end)

CreateControlBtn(MainFrameDance,"Emote 2",function()
	PlayAnimation(591578361)
end)

CreateControlBtn(MainFrameDance,"Jump Style",function()
	PlayAnimation(3338871789)
end)

OpenMenu.Activated:Connect(function()
	MenuFrame.Visible=not MenuFrame.Visible
end)

local fpsFrames=0
local fpsTime=os.clock()

RunService.RenderStepped:Connect(function()
	fpsFrames+=1
	local now=os.clock()
	if now-fpsTime>=1 then
		local fps=math.floor(fpsFrames/(now-fpsTime))
		local ping=0
		pcall(function()
			ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
		end)
		TitleInfo.Text=string.format("ALDO VORA ZURE      FPS : %d      PING : %d ms",fps,ping)
		fpsFrames=0
		fpsTime=now
	end
	local rotation=(now*45)%360
	OpenGradient.Rotation=rotation
	MenuGradient.Rotation=rotation
end)

local function setupCharacter(character)
	local humanoid=character:WaitForChild("Humanoid",8)
	if humanoid then
		humanoid.CameraOffset=Vector3.zero
		humanoid.AutoRotate=true
	end
	ShiftLocked=false
	updateShiftVisual()
	task.wait(0.35)
	applyJump()
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

PlayerGui.ChildAdded:Connect(function(child)
	if child.Name=="TouchGui" then
		task.wait(0.3)
		applyJump()
	end
end)

SwitchMenu(MainFrameJump)
updateShiftVisual()

task.spawn(function()
	for i=1,50 do
		if getJumpButton() then
			applyJump()
			break
		end
		task.wait(0.1)
	end
	LoadingText.Text="Ready"
	task.wait(0.25)
	if Loading and Loading.Parent then
		Loading:Destroy()
	end
end)
