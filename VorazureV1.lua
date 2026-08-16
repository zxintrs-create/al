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
pcall(function()
if readfile and isfile and isfile(CONFIG_FILE)then
local data=HttpService:JSONDecode(readfile(CONFIG_FILE))
if type(data)=="table"then
for k,v in pairs(data)do
if defaultConfig[k]~=nil and type(v)=="number"then
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
pcall(function()
local old=CoreGui:FindFirstChild("VZMenu")
if old then
old:Destroy()
end
end)
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=CoreGui
local function corner(parent,radius)
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,radius)
c.Parent=parent
return c
end
local function stroke(parent,thickness)
local s=Instance.new("UIStroke")
s.Thickness=thickness
s.Color=Color3.fromRGB(255,255,255)
s.Parent=parent
return s
end
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
corner(OpenMenu,8)
local OpenStroke=stroke(OpenMenu,2)
local OpenGradient=Instance.new("UIGradient")
OpenGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
OpenGradient.Parent=OpenStroke
local Image=Instance.new("ImageLabel")
Image.Name="Image"
Image.AnchorPoint=Vector2.new(0.5,0.5)
Image.Size=UDim2.new(0.8,0,0.8,0)
Image.Position=UDim2.new(0.5,0,0.5,0)
Image.BackgroundTransparency=1
Image.Image="rbxassetid://95844752147381"
Image.ZIndex=11
Image.Parent=OpenMenu
corner(Image,8)
local MenuFrame=Instance.new("Frame")
MenuFrame.Name="MenuFrame"
MenuFrame.Size=UDim2.fromOffset(680,420)
MenuFrame.Position=UDim2.new(0.5,-340,0.5,-210)
MenuFrame.BackgroundColor3=Color3.fromRGB(12,12,18)
MenuFrame.BorderSizePixel=0
MenuFrame.Visible=false
MenuFrame.ZIndex=2
MenuFrame.Parent=ScreenGui
corner(MenuFrame,8)
local MenuStroke=stroke(MenuFrame,2)
local MenuGradient=Instance.new("UIGradient")
MenuGradient.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
MenuGradient.Parent=MenuStroke
local TopBar=Instance.new("Frame")
TopBar.Name="TopBar"
TopBar.Size=UDim2.new(1,0,0,35)
TopBar.BackgroundColor3=Color3.fromRGB(18,18,26)
TopBar.BorderSizePixel=0
TopBar.ZIndex=3
TopBar.Parent=MenuFrame
corner(TopBar,8)
local TitleInfo=Instance.new("TextLabel")
TitleInfo.Size=UDim2.new(1,-20,1,0)
TitleInfo.Position=UDim2.new(0,15,0,0)
TitleInfo.BackgroundTransparency=1
TitleInfo.Font=Enum.Font.GothamBold
TitleInfo.TextSize=13
TitleInfo.TextColor3=Color3.fromRGB(255,255,255)
TitleInfo.TextXAlignment=Enum.TextXAlignment.Left
TitleInfo.Text="ALDO VORA ZURE      FPS : 0      PING : 0 ms"
TitleInfo.ZIndex=4
TitleInfo.Parent=TopBar
task.spawn(function()
local lastUpdate=os.clock()
local frames=0
RunService.RenderStepped:Connect(function()
frames+=1
local now=os.clock()
if now-lastUpdate>=1 then
local fps=math.floor(frames/(now-lastUpdate))
local ping=0
pcall(function()
ping=math.floor(LocalPlayer:GetNetworkPing()*1000)
end)
TitleInfo.Text=string.format("ALDO VORA ZURE      FPS : %d      PING : %d ms",fps,ping)
frames=0
lastUpdate=now
end
end)
end)
local Sidebar=Instance.new("Frame")
Sidebar.Name="Sidebar"
Sidebar.Size=UDim2.new(0.28,0,1,-35)
Sidebar.Position=UDim2.new(0,0,0,35)
Sidebar.BackgroundColor3=Color3.fromRGB(15,15,22)
Sidebar.BackgroundTransparency=0.5
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=3
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
MenuLabel.ZIndex=4
MenuLabel.Parent=Sidebar
local ContentArea=Instance.new("Frame")
ContentArea.Name="ContentArea"
ContentArea.Size=UDim2.new(0.72,0,1,-35)
ContentArea.Position=UDim2.new(0.28,0,0,35)
ContentArea.BackgroundTransparency=1
ContentArea.ZIndex=3
ContentArea.Parent=MenuFrame
local function CreateMainFrame(name)
local frame=Instance.new("Frame")
frame.Name=name
frame.Size=UDim2.new(1,0,1,0)
frame.BackgroundTransparency=1
frame.Visible=false
frame.ZIndex=4
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
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,38)
btn.BackgroundColor3=Color3.fromRGB(25,25,35)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Text=text
btn.ZIndex=4
btn.Parent=Sidebar
corner(btn,6)
btn.Activated:Connect(function()
SwitchMenu(target)
end)
return btn
end
CreateNavButton("Jump",MainFrameJump)
CreateNavButton("Shift lock",MainFrameShiftLock)
CreateNavButton("Emote",MainFrameDance)
local function CreateControlBtn(parent,text,callback)
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.85,0,0,32)
btn.BackgroundColor3=Color3.fromRGB(22,22,32)
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Text=text
btn.ZIndex=5
btn.Parent=parent
corner(btn,6)
btn.Activated:Connect(callback)
return btn
end
local function CreateControlLbl(parent,text)
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0.85,0,0,25)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(255,220,0)
lbl.Font=Enum.Font.GothamBlack
lbl.TextSize=14
lbl.Text=text
lbl.ZIndex=5
lbl.Parent=parent
return lbl
end
CreateControlLbl(MainFrameJump,"Jump setting")
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
local function updateJumpPosition()
local button=getJumpButton()
if not button then
return
end
button.AnchorPoint=Vector2.new(0.5,0.5)
button.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
end
local function updateJumpSize()
local button=getJumpButton()
if not button then
return
end
local camera=workspace.CurrentCamera
if not camera then
return
end
local size=math.max(40,math.floor(camera.ViewportSize.Y*config.JumpSize))
button.Size=UDim2.fromOffset(size,size)
end
local function updateJumpButton()
updateJumpPosition()
updateJumpSize()
end
CreateControlBtn(MainFrameJump,"↑",function()
config.JumpY=math.clamp(config.JumpY-0.05,0.05,0.95)
updateJumpPosition()
end)
local rowJumpLR=Instance.new("Frame")
rowJumpLR.Size=UDim2.new(0.85,0,0,32)
rowJumpLR.BackgroundTransparency=1
rowJumpLR.ZIndex=5
rowJumpLR.Parent=MainFrameJump
local btnJumpL=Instance.new("TextButton")
btnJumpL.Size=UDim2.new(0.48,0,1,0)
btnJumpL.BackgroundColor3=Color3.fromRGB(22,22,32)
btnJumpL.TextColor3=Color3.new(1,1,1)
btnJumpL.Font=Enum.Font.GothamBold
btnJumpL.TextSize=13
btnJumpL.Text="←"
btnJumpL.ZIndex=5
btnJumpL.Parent=rowJumpLR
corner(btnJumpL,6)
btnJumpL.Activated:Connect(function()
config.JumpX=math.clamp(config.JumpX-0.05,0.05,0.95)
updateJumpPosition()
end)
local btnJumpR=Instance.new("TextButton")
btnJumpR.Size=UDim2.new(0.48,0,1,0)
btnJumpR.Position=UDim2.new(0.52,0,0,0)
btnJumpR.BackgroundColor3=Color3.fromRGB(22,22,32)
btnJumpR.TextColor3=Color3.new(1,1,1)
btnJumpR.Font=Enum.Font.GothamBold
btnJumpR.TextSize=13
btnJumpR.Text="→"
btnJumpR.ZIndex=5
btnJumpR.Parent=rowJumpLR
corner(btnJumpR,6)
btnJumpR.Activated:Connect(function()
config.JumpX=math.clamp(config.JumpX+0.05,0.05,0.95)
updateJumpPosition()
end)
CreateControlBtn(MainFrameJump,"↓",function()
config.JumpY=math.clamp(config.JumpY+0.05,0.05,0.95)
updateJumpPosition()
end)
local rowJumpSize=Instance.new("Frame")
rowJumpSize.Size=UDim2.new(0.85,0,0,32)
rowJumpSize.BackgroundTransparency=1
rowJumpSize.ZIndex=5
rowJumpSize.Parent=MainFrameJump
local bSzPlusJump=Instance.new("TextButton")
bSzPlusJump.Size=UDim2.new(0.48,0,1,0)
bSzPlusJump.BackgroundColor3=Color3.fromRGB(22,22,32)
bSzPlusJump.TextColor3=Color3.new(1,1,1)
bSzPlusJump.Font=Enum.Font.GothamBold
bSzPlusJump.TextSize=13
bSzPlusJump.Text="size+"
bSzPlusJump.ZIndex=5
bSzPlusJump.Parent=rowJumpSize
corner(bSzPlusJump,6)
bSzPlusJump.Activated:Connect(function()
config.JumpSize=math.clamp(config.JumpSize+0.05,0.05,0.50)
updateJumpSize()
end)
local bSzMinJump=Instance.new("TextButton")
bSzMinJump.Size=UDim2.new(0.48,0,1,0)
bSzMinJump.Position=UDim2.new(0.52,0,0,0)
bSzMinJump.BackgroundColor3=Color3.fromRGB(22,22,32)
bSzMinJump.TextColor3=Color3.new(1,1,1)
bSzMinJump.Font=Enum.Font.GothamBold
bSzMinJump.TextSize=13
bSzMinJump.Text="size-"
bSzMinJump.ZIndex=5
bSzMinJump.Parent=rowJumpSize
corner(bSzMinJump,6)
bSzMinJump.Activated:Connect(function()
config.JumpSize=math.clamp(config.JumpSize-0.05,0.05,0.50)
updateJumpSize()
end)
local rowJumpSR=Instance.new("Frame")
rowJumpSR.Size=UDim2.new(0.85,0,0,32)
rowJumpSR.BackgroundTransparency=1
rowJumpSR.ZIndex=5
rowJumpSR.Parent=MainFrameJump
local btnSave=Instance.new("TextButton")
btnSave.Size=UDim2.new(0.48,0,1,0)
btnSave.BackgroundColor3=Color3.fromRGB(22,22,32)
btnSave.TextColor3=Color3.fromRGB(0,255,100)
btnSave.Font=Enum.Font.GothamBold
btnSave.TextSize=13
btnSave.Text="Save"
btnSave.ZIndex=5
btnSave.Parent=rowJumpSR
corner(btnSave,6)
btnSave.Activated:Connect(saveConfig)
local btnReset=Instance.new("TextButton")
btnReset.Size=UDim2.new(0.48,0,1,0)
btnReset.Position=UDim2.new(0.52,0,0,0)
btnReset.BackgroundColor3=Color3.fromRGB(22,22,32)
btnReset.TextColor3=Color3.fromRGB(255,50,50)
btnReset.Font=Enum.Font.GothamBold
btnReset.TextSize=13
btnReset.Text="reset"
btnReset.ZIndex=5
btnReset.Parent=rowJumpSR
corner(btnReset,6)
btnReset.Activated:Connect(function()
config.JumpX=defaultConfig.JumpX
config.JumpY=defaultConfig.JumpY
config.JumpSize=defaultConfig.JumpSize
updateJumpButton()
saveConfig()
end)
local ShiftLocked=false
_G.ShiftLocked=false
local crosshair=Instance.new("Frame")
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.Position=UDim2.new(0.5,0,0.5,0)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.Visible=false
crosshair.ZIndex=1000000
crosshair.Parent=ScreenGui
corner(crosshair,3)
local btnShiftLock=Instance.new("ImageButton")
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
btnShiftLock.Parent=ScreenGui
corner(btnShiftLock,100)
local shiftStroke=stroke(btnShiftLock,1)
local function getCharacter()
local character=LocalPlayer.Character
if not character then
return
end
local humanoid=character:FindFirstChildOfClass("Humanoid")
local root=character:FindFirstChild("HumanoidRootPart")
if not humanoid or not root then
return
end
return character,humanoid,root
end
local function applyShiftLockState()
local character,humanoid,root=getCharacter()
if not humanoid or not root then
return
end
humanoid.AutoRotate=not ShiftLocked
if not ShiftLocked then
humanoid.CameraOffset=Vector3.zero
end
end
local function setShiftLock(state)
ShiftLocked=state
_G.ShiftLocked=state
crosshair.Visible=state
applyShiftLockState()
if state then
shiftStroke.Thickness=2
else
shiftStroke.Thickness=1
end
end
btnShiftLock.Activated:Connect(function()
setShiftLock(not ShiftLocked)
end)
LocalPlayer.CharacterAdded:Connect(function(character)
ShiftLocked=false
_G.ShiftLocked=false
crosshair.Visible=false
local humanoid=character:WaitForChild("Humanoid",5)
if humanoid then
humanoid.AutoRotate=true
humanoid.CameraOffset=Vector3.zero
end
task.defer(updateJumpButton)
end)
CreateControlLbl(MainFrameShiftLock,"Shift lock setting")
CreateControlBtn(MainFrameShiftLock,"↑",function()
config.ShiftY=math.clamp(config.ShiftY-0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local rowShiftLR=Instance.new("Frame")
rowShiftLR.Size=UDim2.new(0.85,0,0,32)
rowShiftLR.BackgroundTransparency=1
rowShiftLR.ZIndex=5
rowShiftLR.Parent=MainFrameShiftLock
local btnShiftL=Instance.new("TextButton")
btnShiftL.Size=UDim2.new(0.48,0,1,0)
btnShiftL.BackgroundColor3=Color3.fromRGB(22,22,32)
btnShiftL.TextColor3=Color3.new(1,1,1)
btnShiftL.Font=Enum.Font.GothamBold
btnShiftL.TextSize=13
btnShiftL.Text="←"
btnShiftL.ZIndex=5
btnShiftL.Parent=rowShiftLR
corner(btnShiftL,6)
btnShiftL.Activated:Connect(function()
config.ShiftX=math.clamp(config.ShiftX-0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local btnShiftR=Instance.new("TextButton")
btnShiftR.Size=UDim2.new(0.48,0,1,0)
btnShiftR.Position=UDim2.new(0.52,0,0,0)
btnShiftR.BackgroundColor3=Color3.fromRGB(22,22,32)
btnShiftR.TextColor3=Color3.new(1,1,1)
btnShiftR.Font=Enum.Font.GothamBold
btnShiftR.TextSize=13
btnShiftR.Text="→"
btnShiftR.ZIndex=5
btnShiftR.Parent=rowShiftLR
corner(btnShiftR,6)
btnShiftR.Activated:Connect(function()
config.ShiftX=math.clamp(config.ShiftX+0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
CreateControlBtn(MainFrameShiftLock,"↓",function()
config.ShiftY=math.clamp(config.ShiftY+0.05,0.05,0.95)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
end)
local rowShiftSize=Instance.new("Frame")
rowShiftSize.Size=UDim2.new(0.85,0,0,32)
rowShiftSize.BackgroundTransparency=1
rowShiftSize.ZIndex=5
rowShiftSize.Parent=MainFrameShiftLock
local bSzPlusShift=Instance.new("TextButton")
bSzPlusShift.Size=UDim2.new(0.48,0,1,0)
bSzPlusShift.BackgroundColor3=Color3.fromRGB(22,22,32)
bSzPlusShift.TextColor3=Color3.new(1,1,1)
bSzPlusShift.Font=Enum.Font.GothamBold
bSzPlusShift.TextSize=13
bSzPlusShift.Text="size+"
bSzPlusShift.ZIndex=5
bSzPlusShift.Parent=rowShiftSize
corner(bSzPlusShift,6)
bSzPlusShift.Activated:Connect(function()
config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
local bSzMinShift=Instance.new("TextButton")
bSzMinShift.Size=UDim2.new(0.48,0,1,0)
bSzMinShift.Position=UDim2.new(0.52,0,0,0)
bSzMinShift.BackgroundColor3=Color3.fromRGB(22,22,32)
bSzMinShift.TextColor3=Color3.new(1,1,1)
bSzMinShift.Font=Enum.Font.GothamBold
bSzMinShift.TextSize=13
bSzMinShift.Text="size-"
bSzMinShift.ZIndex=5
bSzMinShift.Parent=rowShiftSize
corner(bSzMinShift,6)
bSzMinShift.Activated:Connect(function()
config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end)
local rowShiftSR=Instance.new("Frame")
rowShiftSR.Size=UDim2.new(0.85,0,0,32)
rowShiftSR.BackgroundTransparency=1
rowShiftSR.ZIndex=5
rowShiftSR.Parent=MainFrameShiftLock
local btnSaveShift=Instance.new("TextButton")
btnSaveShift.Size=UDim2.new(0.48,0,1,0)
btnSaveShift.BackgroundColor3=Color3.fromRGB(22,22,32)
btnSaveShift.TextColor3=Color3.fromRGB(0,255,100)
btnSaveShift.Font=Enum.Font.GothamBold
btnSaveShift.TextSize=13
btnSaveShift.Text="Save"
btnSaveShift.ZIndex=5
btnSaveShift.Parent=rowShiftSR
corner(btnSaveShift,6)
btnSaveShift.Activated:Connect(saveConfig)
local btnResetShift=Instance.new("TextButton")
btnResetShift.Size=UDim2.new(0.48,0,1,0)
btnResetShift.Position=UDim2.new(0.52,0,0,0)
btnResetShift.BackgroundColor3=Color3.fromRGB(22,22,32)
btnResetShift.TextColor3=Color3.fromRGB(255,50,50)
btnResetShift.Font=Enum.Font.GothamBold
btnResetShift.TextSize=13
btnResetShift.Text="reset"
btnResetShift.ZIndex=5
btnResetShift.Parent=rowShiftSR
corner(btnResetShift,6)
btnResetShift.Activated:Connect(function()
config.ShiftX=defaultConfig.ShiftX
config.ShiftY=defaultConfig.ShiftY
config.ShiftSize=defaultConfig.ShiftSize
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
saveConfig()
end)
CreateControlLbl(MainFrameDance,"Emotes & Dances")
local function PlayAnimation(assetId)
local character=LocalPlayer.Character
if not character then
return
end
local humanoid=character:FindFirstChildOfClass("Humanoid")
if not humanoid then
return
end
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
if not ok or not track then
animation:Destroy()
return
end
track.Priority=Enum.AnimationPriority.Action
track:Play(0.1)
task.delay(0.15,function()
animation:Destroy()
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
RunService:BindToRenderStep("VZShiftLockRotation",Enum.RenderPriority.Character.Value+1,function()
if not ShiftLocked then
return
end
local character,humanoid,root=getCharacter()
if not character or not humanoid or not root then
return
end
if humanoid.Health<=0 then
return
end
local camera=workspace.CurrentCamera
if not camera then
return
end
local look=camera.CFrame.LookVector
local flatLook=Vector3.new(look.X,0,look.Z)
if flatLook.Magnitude<0.001 then
return
end
flatLook=flatLook.Unit
local position=root.Position
root.CFrame=CFrame.lookAt(position,position+flatLook,Vector3.yAxis)
end)
RunService.RenderStepped:Connect(function()
local rot=(os.clock()*45)%360
OpenGradient.Rotation=rot
MenuGradient.Rotation=rot
end)
task.spawn(function()
for _=1,20 do
task.wait(0.25)
if getJumpButton()then
updateJumpButton()
break
end
end
end)
PlayerGui.ChildAdded:Connect(function(child)
if child.Name=="TouchGui" then
task.defer(function()
task.wait(0.2)
updateJumpButton()
end)
end
end)
SwitchMenu(MainFrameJump)
updateJumpButton()
