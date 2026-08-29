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
local function saveConfig()pcall(function()if writefile then writefile(CONFIG_FILE,HttpService:JSONEncode(config))end end)end
local function loadConfig()pcall(function()
if readfile and isfile and isfile(CONFIG_FILE)then
local d=HttpService:JSONDecode(readfile(CONFIG_FILE))
if type(d)=="table"then
for k,v in pairs(d)do
if defaultConfig[k]~=nil and type(v)==type(defaultConfig[k])then config[k]=v end
end
end
end
end)end
loadConfig()

if _G.DeltaMobileControlsCleanup then pcall(_G.DeltaMobileControlsCleanup)end

local connections={}
local destroyed=false
local function connect(s,f)local c= s:Connect(f)table.insert(connections,c)return c end
local function disconnectAll()for i=#connections,1,-1 do pcall(function()connections[i]:Disconnect()end)end;table.clear(connections)end
local function destroyGui(n)local g=playerGui:FindFirstChild(n)if g then pcall(function()g:Destroy()end)end end
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
local function registerGradient(g)if g then gradientObjects[g]=true end end
local function premium(obj,thickness)
if not obj or not obj:IsA("GuiObject")then return end
local old=obj:FindFirstChild("PremiumStroke")
if old then old:Destroy()end
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
registerGradient(gradient)
end

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")
local moveState={Forward=false,Backward=false,Left=false,Right=false,WLock=false}
local AIR_ACCEL=1
local screenGui=Instance.new("ScreenGui")
screenGui.Name="DeltaMobileControls"
screenGui.ResetOnSpawn=false
screenGui.IgnoreGuiInset=true
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder=999999
screenGui.Parent=playerGui

local function makeMoveButton(name,pos,text)
local b=Instance.new("TextButton")
b.Name=name
b.Position=pos
b.Size=UDim2.fromOffset(72,72)
b.Text=text
b.BackgroundColor3=Color3.fromRGB(30,30,30)
b.BackgroundTransparency=.05
b.TextColor3=Color3.new(1,1,1)
b.Font=Enum.Font.GothamBold
b.TextSize=28
b.AutoButtonColor=false
b.Active=true
b.Selectable=false
b.BorderSizePixel=0
b.ZIndex=50
b.Parent=screenGui
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,14)
c.Parent=b
premium(b,1.8)
return b
end

local btnUp=makeMoveButton("Up",UDim2.new(0,40,1,-250),"▲")
local btnDown=makeMoveButton("Down",UDim2.new(0,40,1,-90),"▼")
local btnLeft=makeMoveButton("Left",UDim2.new(0,0,1,-170),"◀")
local btnRight=makeMoveButton("Right",UDim2.new(0,80,1,-170),"▶")
local btnWLock=Instance.new("TextButton")
btnWLock.Name="WLock"
btnWLock.Position=UDim2.new(0,120,1,-250)
btnWLock.Size=UDim2.fromOffset(90,42)
btnWLock.Text="W: OFF"
btnWLock.BackgroundColor3=Color3.fromRGB(150,0,0)
btnWLock.TextColor3=Color3.new(1,1,1)
btnWLock.Font=Enum.Font.GothamBold
btnWLock.TextSize=15
btnWLock.AutoButtonColor=false
btnWLock.BorderSizePixel=0
btnWLock.ZIndex=51
btnWLock.Parent=screenGui
local wc=Instance.new("UICorner")
wc.CornerRadius=UDim.new(0,10)
wc.Parent=btnWLock
premium(btnWLock,1.5)

local function setMove(dir,state)moveState[dir]=state end
local function bindMove(btn,name)
connect(btn.InputBegan,function(i)
if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then setMove(name,true)end
end)
connect(btn.InputEnded,function(i)
if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then setMove(name,false)end
end)
end

bindMove(btnUp,"Forward")
bindMove(btnDown,"Backward")
bindMove(btnLeft,"Left")
bindMove(btnRight,"Right")

connect(UserInputService.InputEnded,function(i)
if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
for k in pairs(moveState)do
if k~="WLock"then moveState[k]=false end
end
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

local function getMoveVector()
local cam=workspace.CurrentCamera
if not cam then return Vector3.zero end
local look=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
local right=Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
if look.Magnitude>0 then look=look.Unit end
if right.Magnitude>0 then right=right.Unit end
local v=Vector3.zero
if moveState.Forward or moveState.WLock then v+=look end
if moveState.Backward then v-=look end
if moveState.Left then v-=right end
if moveState.Right then v+=right end
if v.Magnitude>1 then v=v.Unit end
return v
end

connect(RunService.RenderStepped,function()
if destroyed or not character or not character.Parent or not humanoid or humanoid.Health<=0 then return end
humanoid:Move(getMoveVector(),false)
end)

connect(RunService.RenderStepped,function()
if destroyed or not character or not humanoid or humanoid.Health<=0 then return end
if humanoid.FloorMaterial~=Enum.Material.Air then return end
local root=character:FindFirstChild("HumanoidRootPart")
if not root then return end
local dir=getMoveVector()
if dir.Magnitude<=0 then return end
local vel=root.AssemblyLinearVelocity
local target=dir*humanoid.WalkSpeed
local a=math.clamp(AIR_ACCEL*.1,0,1)
root.AssemblyLinearVelocity=Vector3.new(
vel.X+(target.X-vel.X)*a,
vel.Y,
vel.Z+(target.Z-vel.Z)*a
)
end)

_G.ShiftLocked=false

local crosshair=Instance.new("Frame")
crosshair.Name="ShiftLockCrosshair"
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.Position=UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000
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
btnShiftLock.Visible=false
btnShiftLock.ZIndex=100
btnShiftLock.Parent=screenGui
local shiftCorner=Instance.new("UICorner")
shiftCorner.CornerRadius=UDim.new(1,0)
shiftCorner.Parent=btnShiftLock
premium(btnShiftLock,2.5)

local function toggleShiftLock()
_G.ShiftLocked=not _G.ShiftLocked
crosshair.Visible=_G.ShiftLocked
btnShiftLock.ImageColor3=_G.ShiftLocked and Color3.fromRGB(255,120,0)or Color3.new(1,1,1)
if humanoid and humanoid.Parent then
humanoid.AutoRotate=not _G.ShiftLocked
end
end

connect(btnShiftLock.Activated,toggleShiftLock)

local function updateShift()
config.ShiftX=math.clamp(config.ShiftX,.02,.98)
config.ShiftY=math.clamp(config.ShiftY,.02,.98)
config.ShiftSize=math.clamp(config.ShiftSize,20,100)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
end

local function applyJumpPremium(j)
if not j or not j:IsA("GuiObject")then return end
local o=j:FindFirstChild("PremiumJumpStroke")
if not o then
o=Instance.new("Frame")
o.Name="PremiumJumpStroke"
o.BackgroundTransparency=1
o.BorderSizePixel=0
o.Active=false
o.Selectable=false
o.ZIndex=j.ZIndex+2
o.Parent=j
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(1,0)
c.Parent=o
local s=Instance.new("UIStroke")
s.Name="PremiumStroke"
s.Thickness=2.5
s.Color=Color3.new(1,1,1)
s.Parent=o
local g=Instance.new("UIGradient")
g.Name="PremiumGradient"
g.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})
g.Parent=s
registerGradient(g)
end
o.Position=UDim2.fromScale(0,0)
o.Size=UDim2.fromScale(1,1)
o.Visible=j.Visible
o.ZIndex=j.ZIndex+2
end

local jumpButton
local function getJump()
local tg=playerGui:FindFirstChild("TouchGui")
if not tg then jumpButton=nil return nil end
jumpButton=tg:FindFirstChild("JumpButton",true)
if jumpButton and jumpButton:IsA("GuiObject")then
applyJumpPremium(jumpButton)
return jumpButton
end
jumpButton=nil
return nil
end

local function updateJump()
if destroyed then return end
local j=getJump()
if not j then return end
local cam=workspace.CurrentCamera
if not cam then return end
local vp=cam.ViewportSize
if vp.X<=0 or vp.Y<=0 then return end
config.JumpX=math.clamp(config.JumpX,.05,.95)
config.JumpY=math.clamp(config.JumpY,.05,.95)
config.JumpSize=math.clamp(config.JumpSize,.05,.50)
local size=math.max(40,math.floor(vp.Y*config.JumpSize))
pcall(function()
j.AnchorPoint=Vector2.new(.5,.5)
j.Position=UDim2.new(config.JumpX,0,config.JumpY,0)
j.Size=UDim2.fromOffset(size,size)
applyJumpPremium(j)
end)
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
b.BackgroundColor3=bg or Color3.fromRGB(245,245,245)
b.BackgroundTransparency=.05
b.TextColor3=Color3.fromRGB(20,20,20)
b.Font=Enum.Font.GothamBold
b.TextSize=22
b.AutoButtonColor=false
b.Active=true
b.BorderSizePixel=0
b.ZIndex=z or 41
b.Parent=p
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,12)
c.Parent=b
premium(b,1.8)
return b
end

local menu=Instance.new("ImageButton")
menu.Name="OpenMenu"
menu.Position=UDim2.new(1,-72,1,-72)
menu.Size=UDim2.fromOffset(60,60)
menu.Image=OPEN_MENU_IMAGE
menu.BackgroundColor3=Color3.fromRGB(25,25,25)
menu.BackgroundTransparency=.05
menu.AutoButtonColor=false
menu.Active=true
menu.BorderSizePixel=0
menu.ZIndex=100
menu.Parent=gui
local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu
premium(menu,2.5)

local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(300,610)
settings.Position=UDim2.new(.5,-150,.5,-305)
settings.BackgroundColor3=Color3.fromRGB(18,18,22)
settings.BackgroundTransparency=.03
settings.BorderSizePixel=0
settings.Visible=false
settings.ZIndex=40
settings.Parent=gui
local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings
premium(settings,2.5)

local shiftToggleSection=Instance.new("Frame")
shiftToggleSection.Size=UDim2.new(1,-20,0,50)
shiftToggleSection.Position=UDim2.fromOffset(10,10)
shiftToggleSection.BackgroundColor3=Color3.fromRGB(30,30,35)
shiftToggleSection.BorderSizePixel=0
shiftToggleSection.ZIndex=41
shiftToggleSection.Parent=settings
local stc=Instance.new("UICorner")
stc.CornerRadius=UDim.new(0,12)
stc.Parent=shiftToggleSection
premium(shiftToggleSection,1.5)

local shiftToggleBtn=makeButton(shiftToggleSection,"ShiftToggleBtn",UDim2.new(.05,0,0,7),UDim2.new(.9,0,0,36),"SHIFT LOCK: OFF",Color3.fromRGB(70,35,35),43)
shiftToggleBtn.TextColor3=Color3.new(1,1,1)
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
cameraSection.Size=UDim2.new(1,-20,0,160)
cameraSection.Position=UDim2.fromOffset(10,70)
cameraSection.BackgroundColor3=Color3.fromRGB(30,30,35)
cameraSection.BorderSizePixel=0
cameraSection.ZIndex=41
cameraSection.Parent=settings
local cameraCorner=Instance.new("UICorner")
cameraCorner.CornerRadius=UDim.new(0,12)
cameraCorner.Parent=cameraSection
premium(cameraSection,1.5)

local cameraTitle=Instance.new("TextLabel")
cameraTitle.Size=UDim2.new(1,0,0,40)
cameraTitle.Text="CAMERA SENSI SETTING"
cameraTitle.TextColor3=Color3.new(1,1,1)
cameraTitle.Font=Enum.Font.GothamBold
cameraTitle.TextSize=18
cameraTitle.BackgroundTransparency=1
cameraTitle.ZIndex=42
cameraTitle.Parent=cameraSection

local sensLabel=Instance.new("TextLabel")
sensLabel.Size=UDim2.new(1,0,0,30)
sensLabel.Position=UDim2.fromOffset(0,40)
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

local sensMinus=makeButton(cameraSection,"Minus",UDim2.new(.06,0,0,85),UDim2.fromOffset(76,42),"-",nil,43)
local sensReset=makeButton(cameraSection,"Reset",UDim2.new(.5,-42,0,85),UDim2.fromOffset(84,42),"RESET",nil,43)
local sensPlus=makeButton(cameraSection,"Plus",UDim2.new(.94,-76,0,85),UDim2.fromOffset(76,42),"+",nil,43)

connect(sensMinus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity-.1,.1,10)applySensitivity()end)
connect(sensPlus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity+.1,.1,10)applySensitivity()end)
connect(sensReset.Activated,function()config.Sensitivity=1 applySensitivity()end)
applySensitivity()

local jumpSection=Instance.new("Frame")
jumpSection.Size=UDim2.new(1,-20,0,320)
jumpSection.Position=UDim2.fromOffset(10,240)
jumpSection.BackgroundColor3=Color3.fromRGB(30,30,35)
jumpSection.BorderSizePixel=0
jumpSection.ZIndex=41
jumpSection.Parent=settings
local jumpCorner=Instance.new("UICorner")
jumpCorner.CornerRadius=UDim.new(0,12)
jumpCorner.Parent=jumpSection
premium(jumpSection,1.5)

local modeSwitchBtn=makeButton(jumpSection,"ToggleTargetMode",UDim2.new(.05,0,0,10),UDim2.new(.9,0,0,36),"TARGET: JUMP BUTTON",Color3.fromRGB(70,35,35),43)
modeSwitchBtn.TextColor3=Color3.new(1,1,1)
local targetSettingMode="JUMP"
connect(modeSwitchBtn.Activated,function()
if targetSettingMode=="JUMP"then
targetSettingMode="SHIFT"
modeSwitchBtn.Text="TARGET: SHIFT LOCK"
else
targetSettingMode="JUMP"
modeSwitchBtn.Text="TARGET: JUMP BUTTON"
end
end)

local moveUp=makeButton(jumpSection,"MoveUp",UDim2.new(.5,-34,0,55),UDim2.fromOffset(68,46),"↑",nil,43)
local moveLeft=makeButton(jumpSection,"MoveLeft",UDim2.new(.10,0,0,102),UDim2.fromOffset(68,46),"←",nil,43)
local moveRight=makeButton(jumpSection,"MoveRight",UDim2.new(.90,-68,0,102),UDim2.fromOffset(68,46),"→",nil,43)
local moveDown=makeButton(jumpSection,"MoveDown",UDim2.new(.5,-34,0,149),UDim2.fromOffset(68,46),"↓",nil,43)
local sizePlus=makeButton(jumpSection,"SizePlus",UDim2.new(.06,0,0,207),UDim2.fromOffset(88,34),"SIZE +",nil,43)
local sizeMinus=makeButton(jumpSection,"SizeMinus",UDim2.new(.94,-88,0,207),UDim2.fromOffset(88,34),"SIZE -",nil,43)
local center=makeButton(jumpSection,"Center",UDim2.new(.5,-44,0,207),UDim2.fromOffset(88,34),"RESET",nil,43)

local holding={[moveUp]=false,[moveDown]=false,[moveLeft]=false,[moveRight]=false}
local step=.018

local function applyMoveStep(dx,dy)
if targetSettingMode=="JUMP"then
config.JumpX=math.clamp(config.JumpX+dx,.05,.95)
config.JumpY=math.clamp(config.JumpY+dy,.05,.95)
updateJump()
else
config.ShiftX=math.clamp(config.ShiftX+dx,.02,.98)
config.ShiftY=math.clamp(config.ShiftY+dy,.02,.98)
updateShift()
end
end

local function bindHold(b,dx,dy)
connect(b.InputBegan,function(i)
if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
holding[b]=true
applyMoveStep(dx,dy)
end)
connect(b.InputEnded,function(i)
if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then holding[b]=false end
end)
end

bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)
connect(UserInputService.InputEnded,function(i)
if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
for b in pairs(holding)do holding[b]=false end
end
end)

connect(RunService.RenderStepped,function()
if destroyed then return end
if holding[moveUp]then applyMoveStep(0,-step)end
if holding[moveDown]then applyMoveStep(0,step)end
if holding[moveLeft]then applyMoveStep(-step,0)end
if holding[moveRight]then applyMoveStep(step,0)end
end)

connect(sizePlus.Activated,function()
if targetSettingMode=="JUMP"then
config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50)
updateJump()
else
config.ShiftSize=math.clamp(config.ShiftSize+5,20,100)
updateShift()
end
end)

connect(sizeMinus.Activated,function()
if targetSettingMode=="JUMP"then
config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50)
updateJump()
else
config.ShiftSize=math.clamp(config.ShiftSize-5,20,100)
updateShift()
end
end)

connect(center.Activated,function()
if targetSettingMode=="JUMP"then
config.JumpX=defaultConfig.JumpX
config.JumpY=defaultConfig.JumpY
config.JumpSize=defaultConfig.JumpSize
updateJump()
else
config.ShiftX=defaultConfig.ShiftX
config.ShiftY=defaultConfig.ShiftY
config.ShiftSize=defaultConfig.ShiftSize
updateShift()
end
end)

local saveButton=makeButton(settings,"SaveConfig",UDim2.new(.05,0,1,-45),UDim2.fromOffset(130,38),"SAVE",Color3.fromRGB(45,100,55),43)
saveButton.TextColor3=Color3.new(1,1,1)

local closeButton=makeButton(settings,"Close",UDim2.new(.95,-130,1,-45),UDim2.fromOffset(130,38),"CLOSE",Color3.fromRGB(100,40,40),43)
closeButton.TextColor3=Color3.new(1,1,1)
connect(saveButton.Activated,function()
saveConfig()
saveButton.Text="SAVED!"
task.delay(1,function()if saveButton.Parent then saveButton.Text="SAVE"end end)
end)

connect(menu.Activated,function()settings.Visible=not settings.Visible end)
connect(closeButton.Activated,function()settings.Visible=false end)

connect(player.CharacterAdded,function(n)
if destroyed then return end
for b in pairs(holding)do holding[b]=false end
character=n
humanoid=n:WaitForChild("Humanoid",10)
if humanoid then
humanoid.AutoRotate=not _G.ShiftLocked
humanoid.CameraOffset=Vector3.zero
end
task.defer(updateJump)
task.delay(.2,updateJump)
end)

connect(playerGui.ChildAdded,function(c)
if c.Name=="TouchGui"then
jumpButton=nil
task.defer(updateJump)
task.delay(.2,updateJump)
task.delay(.5,updateJump)
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
if look.Magnitude>.001 then root.CFrame=CFrame.lookAt(root.Position,root.Position+look.Unit)end
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
if j and j:IsA("GuiObject")then applyJumpPremium(j)end
end
end)

local function refresh()
task.defer(function()updateJump()updateShift()end)
task.delay(.2,function()if not destroyed then updateJump()updateShift()end end)
task.delay(.5,function()if not destroyed then updateJump()updateShift()end end)
end
updateJump()
updateShift()
refresh()
