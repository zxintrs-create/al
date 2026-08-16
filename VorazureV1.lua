local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE="VZMenuConfig.json"
local defaultConfig={JumpX=0.85,JumpY=0.75,JumpSize=0.30,ShiftX=0.75,ShiftY=0.65,ShiftSize=35}
local config={}
for k,v in pairs(defaultConfig)do
config[k]=v
end
local function filesystemAvailable()
return type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
end
local function saveConfig()
if not filesystemAvailable()then
return false,"Filesystem API tidak tersedia"
end
local data
local ok,err=pcall(function()
data=HttpService:JSONEncode(config)
writefile(CONFIG_FILE,data)
end)
if not ok then
return false,tostring(err)
end
local verified=false
pcall(function()
verified=isfile(CONFIG_FILE) and type(readfile(CONFIG_FILE))=="string"
end)
if not verified then
return false,"File tidak berhasil diverifikasi"
end
return true
end
local function loadConfig()
if not filesystemAvailable()then
return false,"Filesystem API tidak tersedia"
end
if not isfile(CONFIG_FILE)then
return false,"Config belum ada"
end
local ok,data=pcall(function()
return HttpService:JSONDecode(readfile(CONFIG_FILE))
end)
if not ok or type(data)~="table"then
return false,"Config rusak"
end
for k,v in pairs(defaultConfig)do
if type(data[k])==type(v)then
config[k]=data[k]
end
end
config.JumpX=math.clamp(config.JumpX,0.05,0.95)
config.JumpY=math.clamp(config.JumpY,0.05,0.95)
config.JumpSize=math.clamp(config.JumpSize,0.05,0.50)
config.ShiftX=math.clamp(config.ShiftX,0.05,0.95)
config.ShiftY=math.clamp(config.ShiftY,0.05,0.95)
config.ShiftSize=math.clamp(config.ShiftSize,20,100)
return true
end
loadConfig()
pcall(function()
local old=CoreGui:FindFirstChild("VZMenu")
if old then
old:Destroy()
end
end)
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=CoreGui
local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.fromOffset(58,58)
OpenMenu.Position=UDim2.new(0.05,0,0.15,0)
OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2
OpenMenu.BorderSizePixel=0
OpenMenu.AutoButtonColor=false
OpenMenu.Active=true
OpenMenu.ZIndex=10
OpenMenu.Parent=ScreenGui
Instance.new("UICorner",OpenMenu).CornerRadius=UDim.new(8,0)
local OpenStroke=Instance.new("UIStroke",OpenMenu)
OpenStroke.Thickness=2
OpenStroke.Color=Color3.fromRGB(255,255,255)
local OpenGradient=Instance.new("UIGradient",OpenStroke)
OpenGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
local Image=Instance.new("ImageLabel",OpenMenu)
Image.Name="Image"
Image.AnchorPoint=Vector2.new(0.5,0.5)
Image.Size=UDim2.new(0.8,0,0.8,0)
Image.Position=UDim2.new(0.5,0,0.5,0)
Image.BackgroundTransparency=1
Image.Image="rbxassetid://139928547001912"
Image.ZIndex=11
Image.Parent=OpenMenu
Instance.new("UICorner",Image).CornerRadius=UDim.new(8,0)
local MenuFrame=Instance.new("Frame",ScreenGui)
MenuFrame.Name="MenuFrame"
MenuFrame.Size=UDim2.fromOffset(680,420)
MenuFrame.Position=UDim2.new(0.5,-340,0.5,-210)
MenuFrame.BackgroundColor3=Color3.fromRGB(12,12,18)
MenuFrame.BorderSizePixel=0
MenuFrame.Visible=false
MenuFrame.ZIndex=2
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
TopBar.ZIndex=3
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
TitleInfo.ZIndex=4
task.spawn(function()
local last=os.clock()
local frames=0
RunService.RenderStepped:Connect(function()
frames+=1
local now=os.clock()
if now-last>=1 then
local fps=math.floor(frames/(now-last))
local ping=0
pcall(function()
ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
end)
TitleInfo.Text=string.format("ALDO VORA ZURE      FPS : %d      PING : %d ms",fps,ping)
frames=0
last=now
end
end)
end)
local Sidebar=Instance.new("Frame",MenuFrame)
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0.28,0,1,-35)
Sidebar.Position=UDim2.new(0,0,0,35)
Sidebar.BackgroundColor3=Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency=0.5
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=3
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
MenuLabel.ZIndex=4
local ContentArea=Instance.new("Frame",MenuFrame)
ContentArea.Name="ContentArea"
ContentArea.Size=UDim2.new(0.72,0,1,-35)
ContentArea.Position=UDim2.new(0.28,0,0,35)
ContentArea.BackgroundTransparency=1
ContentArea.ZIndex=3
local function CreateMainFrame(name)
local frame=Instance.new("Frame",ContentArea)
frame.Name=name
frame.Size=UDim2.new(1,0,1,0)
frame.BackgroundTransparency=1
frame.Visible=false
frame.ZIndex=4
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
local btn=Instance.new("TextButton",Sidebar)
btn.Size=UDim2.new(0.9,0,0,38)
btn.BackgroundColor3=Color3.fromRGB(25,25,35)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Text=text
btn.ZIndex=4
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
btn.Activated:Connect(function()
SwitchMenu(target)
end)
return btn
end
CreateNavButton("Jump",MainFrameJump)
CreateNavButton("Shift lock",MainFrameShiftLock)
CreateNavButton("Emote",MainFrameDance)
local function CreateControlBtn(parent,text,callback)
local btn=Instance.new("TextButton",parent)
btn.Size=UDim2.new(0.85,0,0,32)
btn.BackgroundColor3=Color3.fromRGB(22,22,32)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Text=text
btn.ZIndex=5
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
btn.Activated:Connect(callback)
return btn
end
local function CreateControlLbl(parent,text)
local lbl=Instance.new("TextLabel",parent)
lbl.Size=UDim2.new(0.85,0,0,25)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(255,220,0)
lbl.Font=Enum.Font.GothamBlack
lbl.TextSize=14
lbl.Text=text
lbl.ZIndex=5
return lbl
end
CreateControlLbl(MainFrameJump,"Jump  setting")
local jumpButtonRef
local function getJumpButton()
if jumpButtonRef and jumpButtonRef.Parent then
return jumpButtonRef
end
jumpButtonRef=nil
local touchGui=PlayerGui:FindFirstChild("TouchGui")
if touchGui then
jumpButtonRef=touchGui:FindFirstChild("JumpButton",true)
end
return jumpButtonRef
end
local function updateJumpPos()
local button=getJumpButton()
if button then
button.AnchorPoint=Vector2.new(0.5,0.5)
button.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
end
end
local function updateJumpSize()
local button=getJumpButton()
local camera=workspace.CurrentCamera
if button and camera then
local size=math.max(40,math.floor(camera.ViewportSize.Y*config.JumpSize))
button.Size=UDim2.fromOffset(size,size)
end
end
local function updateJump()
updateJumpPos()
updateJumpSize()
end
CreateControlBtn(MainFrameJump,"↑",function()
config.JumpY=math.clamp(config.JumpY-0.05,0.05,0.95)
updateJumpPos()
end)
local rowJumpLR=Instance.new("Frame",MainFrameJump)
rowJumpLR.Size=UDim2.new(0.85,0,0,32)
rowJumpLR.BackgroundTransparency=1
rowJumpLR.ZIndex=5
local btnJumpL=CreateControlBtn(rowJumpLR,"←",function()
config.JumpX=math.clamp(config.JumpX-0.05,0.05,0.95)
updateJumpPos()
end)
btnJumpL.Size=UDim2.new(0.48,0,1,0)
local btnJumpR=CreateControlBtn(rowJumpLR,"→",function()
config.JumpX=math.clamp(config.JumpX+0.05,0.05,0.95)
updateJumpPos()
end)
btnJumpR.Size=UDim2.new(0.48,0,1,0)
btnJumpR.Position=UDim2.new(0.52,0,0,0)
CreateControlBtn(MainFrameJump,"↓",function()
config.JumpY=math.clamp(config.JumpY+0.05,0.05,0.95)
updateJumpPos()
end)
local rowJumpSize=Instance.new("Frame",MainFrameJump)
rowJumpSize.Size=UDim2.new(0.85,0,0,32)
rowJumpSize.BackgroundTransparency=1
rowJumpSize.ZIndex=5
local bSzPlusJump=CreateControlBtn(rowJumpSize,"size+",function()
config.JumpSize=math.clamp(config.JumpSize+0.05,0.05,0.50)
updateJumpSize()
end)
bSzPlusJump.Size=UDim2.new(0.48,0,1,0)
local bSzMinJump=CreateControlBtn(rowJumpSize,"size-",function()
config.JumpSize=math.clamp(config.JumpSize-0.05,0.05,0.50)
updateJumpSize()
end)
bSzMinJump.Size=UDim2.new(0.48,0,1,0)
bSzMinJump.Position=UDim2.new(0.52,0,0,0)
local rowJumpSR=Instance.new("Frame",MainFrameJump)
rowJumpSR.Size=UDim2.new(0.85,0,0,32)
rowJumpSR.BackgroundTransparency=1
rowJumpSR.ZIndex=5
local btnSave=CreateControlBtn(rowJumpSR,"Save",function()
local ok,err=saveConfig()
if ok then
btnSave.Text="Saved"
task.delay(1,function()
if btnSave.Parent then btnSave.Text="Save" end
end)
else
btnSave.Text="Failed"
task.delay(1,function()
if btnSave.Parent then btnSave.Text="Save" end
end)
end
end)
btnSave.Size=UDim2.new(0.48,0,1,0)
btnSave.TextColor3=Color3.fromRGB(0,255,100)
local btnReset=CreateControlBtn(rowJumpSR,"reset",function()
for k,v in pairs(defaultConfig)do
config[k]=v
end
updateJump()
saveConfig()
end)
btnReset.Size=UDim2.new(0.48,0,1,0)
btnReset.Position=UDim2.new(0.52,0,0,0)
btnReset.TextColor3=Color3.fromRGB(255,50,50)
CreateControlLbl(MainFrameShiftLock,"Shift lock setting")
local ShiftLocked=false
_G.ShiftLocked=false
local crosshair=Instance.new("Frame",ScreenGui)
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.Position=UDim2.new(0.5,0,0.5,0)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.Visible=false
crosshair.ZIndex=1000000
Instance.new("UICorner",crosshair).CornerRadius=UDim.new(1,0)
local btnShiftLock=Instance.new("ImageButton",ScreenGui)
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(0.5,0.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image="rbxassetid://136616143786672"
btnShiftLock.BackgroundColor3=Color3.fromRGB(255,255,255)
btnShiftLock.BackgroundTransparency=0.2
btnShiftLock.BorderSizePixel=0
btnShiftLock.Active=true
btnShiftLock.AutoButtonColor=false
btnShiftLock.ZIndex=100000
Instance.new("UICorner",btnShiftLock).CornerRadius=UDim.new(1,0)
local function applyShift()
local character=LocalPlayer.Character
if not character then return end
local humanoid=character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end
humanoid.AutoRotate=not ShiftLocked
end
local function setShift(state)
ShiftLocked=state
_G.ShiftLocked=state
crosshair.Visible=state
applyShift()
end
btnShiftLock.Activated:Connect(function()
setShift(not ShiftLocked)
end)
CreateControlBtn(MainFrameShiftLock,"↑",function()
config.ShiftY=math.clamp(config.ShiftY-0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local rowShiftLR=Instance.new("Frame",MainFrameShiftLock)
rowShiftLR.Size=UDim2.new(0.85,0,0,32)
rowShiftLR.BackgroundTransparency=1
rowShiftLR.ZIndex=5
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
local rowShiftSize=Instance.new("Frame",MainFrameShiftLock)
rowShiftSize.Size=UDim2.new(0.85,0,0,32)
rowShiftSize.BackgroundTransparency=1
rowShiftSize.ZIndex=5
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
local rowShiftSR=Instance.new("Frame",MainFrameShiftLock)
rowShiftSR.Size=UDim2.new(0.85,0,0,32)
rowShiftSR.BackgroundTransparency=1
rowShiftSR.ZIndex=5
local btnSaveShift=CreateControlBtn(rowShiftSR,"Save",function()
local ok=saveConfig()
btnSaveShift.Text=ok and "Saved" or "Failed"
task.delay(1,function()
if btnSaveShift.Parent then btnSaveShift.Text="Save" end
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
if not character then return end
local humanoid=character:FindFirstChildOfClass("Humanoid")
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
track.Priority=Enum.AnimationPriority.Action
track:Play(0.1)
task.delay(0.2,function()
if animation.Parent then animation:Destroy() end
end)
else
animation:Destroy()
end
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
RunService:BindToRenderStep("VZShiftLockRotation",Enum.RenderPriority.Character.Value+1,function()
if not ShiftLocked then return end
local character=LocalPlayer.Character
if not character then return end
local humanoid=character:FindFirstChildOfClass("Humanoid")
local root=character:FindFirstChild("HumanoidRootPart")
local camera=workspace.CurrentCamera
if not humanoid or not root or not camera or humanoid.Health<=0 then return end
local look=camera.CFrame.LookVector
local flat=Vector3.new(look.X,0,look.Z)
if flat.Magnitude<0.001 then return end
root.CFrame=CFrame.lookAt(root.Position,root.Position+flat.Unit)
end)
LocalPlayer.CharacterAdded:Connect(function(character)
ShiftLocked=false
_G.ShiftLocked=false
crosshair.Visible=false
local humanoid=character:WaitForChild("Humanoid",5)
if humanoid then
humanoid.AutoRotate=true
end
task.wait(0.3)
updateJump()
end)
PlayerGui.ChildAdded:Connect(function(child)
if child.Name=="TouchGui" then
task.wait(0.2)
updateJump()
end
end)
RunService.RenderStepped:Connect(function()
local rotation=(os.clock()*45)%360
OpenGradient.Rotation=rotation
MenuGradient.Rotation=rotation
end)
SwitchMenu(MainFrameJump)
task.spawn(function()
for i=1,20 do
task.wait(0.25)
if getJumpButton()then
updateJump()
break
end
end
end)
