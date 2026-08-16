local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE="VZMenuConfig.json"
local defaultConfig={JumpX=0.85,JumpY=0.75,JumpSize=0.30,ShiftX=0.75,ShiftY=0.65,ShiftSize=35}
local config={}
for k,v in pairs(defaultConfig)do config[k]=v end
local function clampConfig()
config.JumpX=math.clamp(tonumber(config.JumpX)or defaultConfig.JumpX,0.05,0.95)
config.JumpY=math.clamp(tonumber(config.JumpY)or defaultConfig.JumpY,0.05,0.95)
config.JumpSize=math.clamp(tonumber(config.JumpSize)or defaultConfig.JumpSize,0.05,0.50)
config.ShiftX=math.clamp(tonumber(config.ShiftX)or defaultConfig.ShiftX,0.05,0.95)
config.ShiftY=math.clamp(tonumber(config.ShiftY)or defaultConfig.ShiftY,0.05,0.95)
config.ShiftSize=math.clamp(tonumber(config.ShiftSize)or defaultConfig.ShiftSize,20,100)
end
local function saveConfig()
if type(writefile)~="function"then return false end
local ok=pcall(function()
writefile(CONFIG_FILE,HttpService:JSONEncode(config))
end)
if not ok then return false end
local verified=false
pcall(function()
verified=type(isfile)=="function"and isfile(CONFIG_FILE)
end)
return verified
end
local function loadConfig()
if type(readfile)~="function"or type(isfile)~="function"then return false end
if not isfile(CONFIG_FILE)then return false end
local ok,data=pcall(function()
return HttpService:JSONDecode(readfile(CONFIG_FILE))
end)
if not ok or type(data)~="table"then return false end
for k,v in pairs(defaultConfig)do
if type(data[k])==type(v)then config[k]=data[k] end
end
clampConfig()
return true
end
loadConfig()
clampConfig()
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
Loading.Position=UDim2.fromScale(0,0)
Loading.BackgroundColor3=Color3.fromRGB(8,8,12)
Loading.BorderSizePixel=0
Loading.ZIndex=1000000
Loading.Parent=ScreenGui
local LoadingTitle=Instance.new("TextLabel")
LoadingTitle.Size=UDim2.new(1,0,0,50)
LoadingTitle.Position=UDim2.new(0,0,0.42,0)
LoadingTitle.BackgroundTransparency=1
LoadingTitle.Text="VZ MENU"
LoadingTitle.TextColor3=Color3.fromRGB(255,255,255)
LoadingTitle.Font=Enum.Font.GothamBlack
LoadingTitle.TextSize=28
LoadingTitle.ZIndex=1000001
LoadingTitle.Parent=Loading
local LoadingStatus=Instance.new("TextLabel")
LoadingStatus.Size=UDim2.new(1,0,0,30)
LoadingStatus.Position=UDim2.new(0,0,0.50,0)
LoadingStatus.BackgroundTransparency=1
LoadingStatus.Text="Loading..."
LoadingStatus.TextColor3=Color3.fromRGB(255,220,0)
LoadingStatus.Font=Enum.Font.GothamBold
LoadingStatus.TextSize=13
LoadingStatus.ZIndex=1000001
LoadingStatus.Parent=Loading
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
OpenMenu.ImageColor3=Color3.fromRGB(255,255,255)
OpenMenu.ScaleType=Enum.ScaleType.Fit
OpenMenu.ZIndex=100
OpenMenu.Parent=ScreenGui
Instance.new("UICorner",OpenMenu).CornerRadius=UDim.new(8,0)
local OpenStroke=Instance.new("UIStroke",OpenMenu)
OpenStroke.Thickness=2
OpenStroke.Color=Color3.fromRGB(255,255,255)
OpenStroke.ZIndex=101
local OpenGradient=Instance.new("UIGradient",OpenStroke)
OpenGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
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
local MenuStroke=Instance.new("UIStroke",MenuFrame)
MenuStroke.Thickness=2
MenuStroke.Color=Color3.fromRGB(255,255,255)
local MenuGradient=Instance.new("UIGradient",MenuStroke)
MenuGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
local TopBar=Instance.new("Frame",MenuFrame)
TopBar.Name="TopBar"
TopBar.Size=UDim2.new(1,0,0,35)
TopBar.BackgroundColor3=Color3.fromRGB(18,18,26)
TopBar.BorderSizePixel=0
TopBar.ZIndex=21
Instance.new("UICorner",TopBar).CornerRadius=UDim.new(0,8)
local TitleInfo=Instance.new("TextLabel",TopBar)
TitleInfo.Size=UDim2.new(1,-20,1,0)
TitleInfo.Position=UDim2.new(0,15,0,0)
TitleInfo.BackgroundTransparency=1
TitleInfo.Font=Enum.Font.GothamBold
TitleInfo.TextSize=13
TitleInfo.TextColor3=Color3.fromRGB(255,255,255)
TitleInfo.TextXAlignment=Enum.TextXAlignment.Left
TitleInfo.Text="ALDO VORA ZURE      FPS : 0      PING : 0 ms"
TitleInfo.ZIndex=22
local Sidebar=Instance.new("Frame",MenuFrame)
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0.28,0,1,-35)
Sidebar.Position=UDim2.new(0,0,0,35)
Sidebar.BackgroundColor3=Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency=0.5
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=21
local SidebarLayout=Instance.new("UIListLayout",Sidebar)
SidebarLayout.SortOrder=Enum.SortOrder.LayoutOrder
SidebarLayout.Padding=UDim.new(0,6)
SidebarLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local MenuLabel=Instance.new("TextLabel",Sidebar)
MenuLabel.Size=UDim2.new(1,0,0,35)
MenuLabel.BackgroundTransparency=1
MenuLabel.Text="MENU   :"
MenuLabel.TextColor3=Color3.fromRGB(255,220,0)
MenuLabel.Font=Enum.Font.GothamBlack
MenuLabel.TextSize=14
MenuLabel.ZIndex=22
local ContentArea=Instance.new("Frame",MenuFrame)
ContentArea.Name="ContentArea"
ContentArea.Size=UDim2.new(0.72,0,1,-35)
ContentArea.Position=UDim2.new(0.28,0,0,35)
ContentArea.BackgroundTransparency=1
ContentArea.ZIndex=21
local function CreateMainFrame(name)
local frame=Instance.new("Frame",ContentArea)
frame.Name=name
frame.Size=UDim2.fromScale(1,1)
frame.BackgroundTransparency=1
frame.Visible=false
frame.ZIndex=22
local layout=Instance.new("UIListLayout",frame)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Padding=UDim.new(0,8)
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
layout.VerticalAlignment=Enum.VerticalAlignment.Center
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
local b=Instance.new("TextButton",Sidebar)
b.Size=UDim2.new(0.9,0,0,38)
b.BackgroundColor3=Color3.fromRGB(25,25,35)
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=13
b.Text=text
b.ZIndex=23
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
b.Activated:Connect(function()SwitchMenu(target)end)
return b
end
CreateNavButton("Jump",MainFrameJump)
CreateNavButton("Shift lock",MainFrameShiftLock)
CreateNavButton("Emote",MainFrameDance)
local function CreateControlBtn(parent,text,callback)
local b=Instance.new("TextButton",parent)
b.Size=UDim2.new(0.85,0,0,32)
b.BackgroundColor3=Color3.fromRGB(22,22,32)
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=13
b.Text=text
b.ZIndex=24
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
b.Activated:Connect(callback)
return b
end
local function CreateControlLbl(parent,text)
local l=Instance.new("TextLabel",parent)
l.Size=UDim2.new(0.85,0,0,25)
l.BackgroundTransparency=1
l.TextColor3=Color3.fromRGB(255,220,0)
l.Font=Enum.Font.GothamBlack
l.TextSize=14
l.Text=text
l.ZIndex=24
return l
end
CreateControlLbl(MainFrameJump,"Jump  setting")
local jumpButtonRef
local function getJumpButton()
if jumpButtonRef and jumpButtonRef.Parent then return jumpButtonRef end
jumpButtonRef=nil
local tg=PlayerGui:FindFirstChild("TouchGui")
if tg then jumpButtonRef=tg:FindFirstChild("JumpButton",true)end
return jumpButtonRef
end
local function updateJump()
local b=getJumpButton()
local cam=workspace.CurrentCamera
if not b then return end
b.AnchorPoint=Vector2.new(0.5,0.5)
b.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
if cam then
local s=math.max(40,math.floor(cam.ViewportSize.Y*config.JumpSize))
b.Size=UDim2.fromOffset(s,s)
end
end
CreateControlBtn(MainFrameJump,"↑",function()
config.JumpY=math.clamp(config.JumpY-0.05,0.05,0.95)
updateJump()
end)
local rowJL=Instance.new("Frame",MainFrameJump)
rowJL.Size=UDim2.new(0.85,0,0,32)
rowJL.BackgroundTransparency=1
local jl=CreateControlBtn(rowJL,"←",function()
config.JumpX=math.clamp(config.JumpX-0.05,0.05,0.95)
updateJump()
end)
jl.Size=UDim2.new(0.48,0,1,0)
local jr=CreateControlBtn(rowJL,"→",function()
config.JumpX=math.clamp(config.JumpX+0.05,0.05,0.95)
updateJump()
end)
jr.Size=UDim2.new(0.48,0,1,0)
jr.Position=UDim2.new(0.52,0,0,0)
CreateControlBtn(MainFrameJump,"↓",function()
config.JumpY=math.clamp(config.JumpY+0.05,0.05,0.95)
updateJump()
end)
local rowJS=Instance.new("Frame",MainFrameJump)
rowJS.Size=UDim2.new(0.85,0,0,32)
rowJS.BackgroundTransparency=1
local jsp=CreateControlBtn(rowJS,"size+",function()
config.JumpSize=math.clamp(config.JumpSize+0.05,0.05,0.50)
updateJump()
end)
jsp.Size=UDim2.new(0.48,0,1,0)
local jsm=CreateControlBtn(rowJS,"size-",function()
config.JumpSize=math.clamp(config.JumpSize-0.05,0.05,0.50)
updateJump()
end)
jsm.Size=UDim2.new(0.48,0,1,0)
jsm.Position=UDim2.new(0.52,0,0,0)
local rowJSave=Instance.new("Frame",MainFrameJump)
rowJSave.Size=UDim2.new(0.85,0,0,32)
rowJSave.BackgroundTransparency=1
local jSave=CreateControlBtn(rowJSave,"Save",function()
local ok=saveConfig()
jSave.Text=ok and "Saved"or"Failed"
task.delay(1,function()if jSave.Parent then jSave.Text="Save"end end)
end)
jSave.Size=UDim2.new(0.48,0,1,0)
jSave.TextColor3=Color3.fromRGB(0,255,100)
local jReset=CreateControlBtn(rowJSave,"reset",function()
config.JumpX=defaultConfig.JumpX
config.JumpY=defaultConfig.JumpY
config.JumpSize=defaultConfig.JumpSize
updateJump()
saveConfig()
end)
jReset.Size=UDim2.new(0.48,0,1,0)
jReset.Position=UDim2.new(0.52,0,0,0)
jReset.TextColor3=Color3.fromRGB(255,50,50)
CreateControlLbl(MainFrameShiftLock,"Shift lock setting")
local ShiftLocked=false
local crosshair=Instance.new("Frame",ScreenGui)
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.Position=UDim2.fromScale(0.5,0.5)
crosshair.BackgroundColor3=Color3.fromRGB(255,255,255)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000
Instance.new("UICorner",crosshair).CornerRadius=UDim.new(1,0)
local btnShiftLock=Instance.new("ImageButton",ScreenGui)
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(0.5,0.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image="rbxassetid://136616143786672"
btnShiftLock.ImageColor3=Color3.fromRGB(255,255,255)
btnShiftLock.BackgroundColor3=Color3.fromRGB(25,25,30)
btnShiftLock.BackgroundTransparency=0.15
btnShiftLock.BorderSizePixel=0
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.ZIndex=900
btnShiftLock.Parent=ScreenGui
Instance.new("UICorner",btnShiftLock).CornerRadius=UDim.new(1,0)
local shiftStroke=Instance.new("UIStroke",btnShiftLock)
shiftStroke.Thickness=2
shiftStroke.Color=Color3.fromRGB(255,255,255)
local function setShift(state)
ShiftLocked=state
crosshair.Visible=state
if state then
btnShiftLock.ImageColor3=Color3.fromRGB(0,255,100)
shiftStroke.Color=Color3.fromRGB(0,255,100)
else
btnShiftLock.ImageColor3=Color3.fromRGB(255,255,255)
shiftStroke.Color=Color3.fromRGB(255,255,255)
end
local c=LocalPlayer.Character
local h=c and c:FindFirstChildOfClass("Humanoid")
if h then h.AutoRotate=not state end
end
btnShiftLock.Activated:Connect(function()setShift(not ShiftLocked)end)
CreateControlBtn(MainFrameShiftLock,"↑",function()
config.ShiftY=math.clamp(config.ShiftY-0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local rowSL=Instance.new("Frame",MainFrameShiftLock)
rowSL.Size=UDim2.new(0.85,0,0,32)
rowSL.BackgroundTransparency=1
local sl=CreateControlBtn(rowSL,"←",function()
config.ShiftX=math.clamp(config.ShiftX-0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
sl.Size=UDim2.new(0.48,0,1,0)
local sr=CreateControlBtn(rowSL,"→",function()
config.ShiftX=math.clamp(config.ShiftX+0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
sr.Size=UDim2.new(0.48,0,1,0)
sr.Position=UDim2.new(0.52,0,0,0)
CreateControlBtn(MainFrameShiftLock,"↓",function()
config.ShiftY=math.clamp(config.ShiftY+0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local rowSS=Instance.new("Frame",MainFrameShiftLock)
rowSS.Size=UDim2.new(0.85,0,0,32)
rowSS.BackgroundTransparency=1
local ssp=CreateControlBtn(rowSS,"size+",function()
config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
ssp.Size=UDim2.new(0.48,0,1,0)
local ssm=CreateControlBtn(rowSS,"size-",function()
config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
ssm.Size=UDim2.new(0.48,0,1,0)
ssm.Position=UDim2.new(0.52,0,0,0)
local rowSSave=Instance.new("Frame",MainFrameShiftLock)
rowSSave.Size=UDim2.new(0.85,0,0,32)
rowSSave.BackgroundTransparency=1
local sSave=CreateControlBtn(rowSSave,"Save",function()
local ok=saveConfig()
sSave.Text=ok and"Saved"or"Failed"
task.delay(1,function()if sSave.Parent then sSave.Text="Save"end end)
end)
sSave.Size=UDim2.new(0.48,0,1,0)
sSave.TextColor3=Color3.fromRGB(0,255,100)
local sReset=CreateControlBtn(rowSSave,"reset",function()
config.ShiftX=defaultConfig.ShiftX
config.ShiftY=defaultConfig.ShiftY
config.ShiftSize=defaultConfig.ShiftSize
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
saveConfig()
end)
sReset.Size=UDim2.new(0.48,0,1,0)
sReset.Position=UDim2.new(0.52,0,0,0)
sReset.TextColor3=Color3.fromRGB(255,50,50)
CreateControlLbl(MainFrameDance,"Emotes & Dances")
local function PlayAnimation(id)
local c=LocalPlayer.Character
local h=c and c:FindFirstChildOfClass("Humanoid")
if not h then return end
local a=h:FindFirstChildOfClass("Animator")or Instance.new("Animator")
a.Parent=h
local anim=Instance.new("Animation")
anim.AnimationId="rbxassetid://"..tostring(id)
local ok,track=pcall(function()return a:LoadAnimation(anim)end)
if ok and track then track:Play(0.1)end
task.delay(1,function()anim:Destroy()end)
end
CreateControlBtn(MainFrameDance,"Dance 1",function()PlayAnimation(507710273)end)
CreateControlBtn(MainFrameDance,"Dance 2",function()PlayAnimation(507719543)end)
CreateControlBtn(MainFrameDance,"Emote 1",function()PlayAnimation(591577311)end)
CreateControlBtn(MainFrameDance,"Emote 2",function()PlayAnimation(591578361)end)
CreateControlBtn(MainFrameDance,"Jump Style",function()PlayAnimation(3338871789)end)
OpenMenu.Activated:Connect(function()
MenuFrame.Visible=not MenuFrame.Visible
end)
RunService.RenderStepped:Connect(function()
local r=(os.clock()*45)%360
OpenGradient.Rotation=r
MenuGradient.Rotation=r
end)
RunService:BindToRenderStep("VZShiftRotation",Enum.RenderPriority.Character.Value+1,function()
if not ShiftLocked then return end
local c=LocalPlayer.Character
local h=c and c:FindFirstChildOfClass("Humanoid")
local root=c and c:FindFirstChild("HumanoidRootPart")
local cam=workspace.CurrentCamera
if not h or not root or not cam or h.Health<=0 then return end
local look=cam.CFrame.LookVector
local flat=Vector3.new(look.X,0,look.Z)
if flat.Magnitude>0.001 then
root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit)
end
end)
LocalPlayer.CharacterAdded:Connect(function(character)
ShiftLocked=false
crosshair.Visible=false
btnShiftLock.ImageColor3=Color3.fromRGB(255,255,255)
shiftStroke.Color=Color3.fromRGB(255,255,255)
local h=character:WaitForChild("Humanoid",5)
if h then h.AutoRotate=true end
task.wait(0.4)
updateJump()
end)
PlayerGui.ChildAdded:Connect(function(child)
if child.Name=="TouchGui"then
task.wait(0.3)
updateJump()
end
end)
SwitchMenu(MainFrameJump)
LoadingStatus.Text="Ready"
task.wait(0.15)
Loading:Destroy()
task.spawn(function()
for i=1,20 do
task.wait(0.2)
if getJumpButton()then
updateJump()
break
end
end
end)
