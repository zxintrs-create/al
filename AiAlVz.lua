local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local CONFIG_FILE="DeltaMobileConfig.json"
local defaultConfig={JumpX=.85,JumpY=.75,JumpSize=.30,ShiftX=.75,ShiftY=.65,ShiftSize=35,Sensitivity=1}
local SHIFT_LOCK_IMAGE="rbxassetid://103531792987903"
local OPEN_MENU_IMAGE="rbxassetid://114480118578175"
local config={}
for k,v in pairs(defaultConfig)do config[k]=v end
local function saveConfig()pcall(function()if writefile then writefile(CONFIG_FILE,HttpService:JSONEncode(config))end end)end
local function loadConfig()pcall(function()if readfile and isfile and isfile(CONFIG_FILE)then local d=HttpService:JSONDecode(readfile(CONFIG_FILE));if type(d)=="table"then for k,v in pairs(d)do if defaultConfig[k]~=nil and type(v)==type(defaultConfig[k])then config[k]=v end end end end end)end
loadConfig()
if _G.DeltaMobileControlsCleanup then pcall(_G.DeltaMobileControlsCleanup)end
local connections={}
local destroyed=false
local function connect(s,f)local c;pcall(function()c=s:Connect(f)end);if c then table.insert(connections,c)end;return c end
local function disconnectAll()for i=#connections,1,-1 do pcall(function()connections[i]:Disconnect()end)end;table.clear(connections)end
local function destroyGui(n)local g=playerGui:FindFirstChild(n);if g then pcall(function()g:Destroy()end)end end
_G.DeltaMobileControlsCleanup=function()if destroyed then return end;destroyed=true;disconnectAll();destroyGui("DeltaMobileControls");destroyGui("DeltaMobileErgo")end
destroyGui("DeltaMobileControls")
destroyGui("DeltaMobileErgo")
local gradientObjects={}
local function registerGradient(g)if g and g:IsA("UIGradient")then gradientObjects[g]=true end end
local function premiumStroke(obj,thickness)
if not obj or not obj:IsA("GuiObject")then return end
local old=obj:FindFirstChild("PremiumStroke")
if old then old:Destroy()end
local stroke=Instance.new("UIStroke")
stroke.Name="PremiumStroke"
stroke.Thickness=thickness or 2
stroke.Color=Color3.new(1,1,1)
stroke.Transparency=0
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Parent=obj
local gradient=Instance.new("UIGradient")
gradient.Name="PremiumGradient"
gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
gradient.Rotation=0
gradient.Parent=stroke
registerGradient(gradient)
return stroke,gradient
end
local function premium(obj,thickness)return premiumStroke(obj,thickness)end
local function applyJumpPremium(j)
if not j or not j:IsA("GuiObject")then return end
local overlay=j:FindFirstChild("PremiumJumpStroke")
if not overlay then
overlay=Instance.new("Frame")
overlay.Name="PremiumJumpStroke"
overlay.BackgroundTransparency=1
overlay.BorderSizePixel=0
overlay.Active=false
overlay.Selectable=false
overlay.ZIndex=j.ZIndex+2
overlay.Parent=j
local corner=Instance.new("UICorner")
corner.Name="Circle"
corner.CornerRadius=UDim.new(1,0)
corner.Parent=overlay
local stroke=Instance.new("UIStroke")
stroke.Name="PremiumStroke"
stroke.Thickness=2.5
stroke.Color=Color3.new(1,1,1)
stroke.Transparency=0
stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
stroke.Parent=overlay
local gradient=Instance.new("UIGradient")
gradient.Name="PremiumGradient"
gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,220,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
gradient.Rotation=0
gradient.Parent=stroke
registerGradient(gradient)
else
overlay.Position=UDim2.fromScale(0,0)
overlay.Size=UDim2.fromScale(1,1)
overlay.AnchorPoint=Vector2.zero
overlay.Visible=j.Visible
overlay.ZIndex=j.ZIndex+2
end
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
crosshair.Size=UDim2.fromOffset(6,6)
crosshair.Position=UDim2.new(.5,-3,.5,-3)
crosshair.BackgroundColor3=Color3.new(1,1,1)
crosshair.BorderSizePixel=0
crosshair.Visible=false
crosshair.ZIndex=1000000
crosshair.Parent=screenGui
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(1,0)
cc.Parent=crosshair
local btnShiftLock=Instance.new("ImageButton")
btnShiftLock.Name="ShiftLockButton"
btnShiftLock.AnchorPoint=Vector2.new(.5,.5)
btnShiftLock.Position=UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size=UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image=SHIFT_LOCK_IMAGE
btnShiftLock.ImageColor3=Color3.new(1,1,1)
btnShiftLock.BackgroundColor3=Color3.new(1,1,1)
btnShiftLock.BackgroundTransparency=1
btnShiftLock.AutoButtonColor=false
btnShiftLock.Active=true
btnShiftLock.Selectable=false
btnShiftLock.BorderSizePixel=0
btnShiftLock.ZIndex=100000
btnShiftLock.Parent=screenGui
local sc=Instance.new("UICorner")
sc.CornerRadius=UDim.new(1,0)
sc.Parent=btnShiftLock
premium(btnShiftLock,2.5)
local function toggleShiftLock()
if destroyed then return end
_G.ShiftLocked=not _G.ShiftLocked
btnShiftLock.BackgroundTransparency=1
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
if not touchGui then jumpButton=nil return nil end
jumpButton=touchGui:FindFirstChild("JumpButton",true)
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
local cam=workspace.CurrentCamera
if not j or not cam then return end
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
local function updateShift()
if destroyed or not btnShiftLock.Parent then return end
config.ShiftX=math.clamp(config.ShiftX,.02,.98)
config.ShiftY=math.clamp(config.ShiftY,.02,.98)
config.ShiftSize=math.clamp(config.ShiftSize,20,100)
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
b.BackgroundColor3=bg or Color3.fromRGB(245,245,245)
b.BackgroundTransparency=.05
b.TextColor3=Color3.fromRGB(20,20,20)
b.Font=Enum.Font.GothamBold
b.TextSize=22
b.AutoButtonColor=false
b.Active=true
b.Selectable=false
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
menu.Selectable=false
menu.BorderSizePixel=0
menu.ZIndex=100
menu.Parent=gui
local menuCorner=Instance.new("UICorner")
menuCorner.CornerRadius=UDim.new(1,0)
menuCorner.Parent=menu
premium(menu,2.5)
local settings=Instance.new("Frame")
settings.Name="SettingsFrame"
settings.Size=UDim2.fromOffset(300,560)
settings.Position=UDim2.new(.5,-150,.5,-280)
settings.BackgroundColor3=Color3.fromRGB(18,18,22)
settings.BackgroundTransparency=.03
settings.BorderSizePixel=0
settings.Visible=false
settings.Active=false
settings.ZIndex=40
settings.Parent=gui
local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,16)
settingsCorner.Parent=settings
premium(settings,2.5)
local cameraSection=Instance.new("Frame")
cameraSection.Size=UDim2.new(1,-20,0,160)
cameraSection.Position=UDim2.fromOffset(10,10)
cameraSection.BackgroundColor3=Color3.fromRGB(30,30,35)
cameraSection.BorderSizePixel=0
cameraSection.Active=false
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
connect(sensMinus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity-.1,.1,10);applySensitivity()end)
connect(sensPlus.Activated,function()config.Sensitivity=math.clamp(config.Sensitivity+.1,.1,10);applySensitivity()end)
connect(sensReset.Activated,function()config.Sensitivity=1;applySensitivity()end)
applySensitivity()
local jumpSection=Instance.new("Frame")
jumpSection.Size=UDim2.new(1,-20,0,320)
jumpSection.Position=UDim2.fromOffset(10,180)
jumpSection.BackgroundColor3=Color3.fromRGB(30,30,35)
jumpSection.BorderSizePixel=0
jumpSection.Active=false
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
modeSwitchBtn.BackgroundColor3=Color3.fromRGB(70,25,25)
else
targetSettingMode="JUMP"
modeSwitchBtn.Text="TARGET: JUMP BUTTON"
modeSwitchBtn.BackgroundColor3=Color3.fromRGB(70,35,35)
end
end)
local moveUp=makeButton(jumpSection,"MoveUp",UDim2.new(.5,-34,0,55),UDim2.fromOffset(68,46),"↑",nil,43)
local moveLeft=makeButton(jumpSection,"MoveLeft",UDim2.new(.10,0,0,102),UDim2.fromOffset(68,46),"←",nil,43)
local moveRight=makeButton(jumpSection,"MoveRight",UDim2.new(.90,-68,0,102),UDim2.fromOffset(68,46),"→",nil,43)
local moveDown=makeButton(jumpSection,"MoveDown",UDim2.new(.5,-34,0,149),UDim2.fromOffset(68,46),"↓",nil,43)
local sizePlus=makeButton(jumpSection,"SizePlus",UDim2.new(.06,0,0,207),UDim2.fromOffset(88,34),"SIZE +",nil,43)
local sizeMinus=makeButton(jumpSection,"SizeMinus",UDim2.new(.94,-88,0,207),UDim2.fromOffset(88,34),"SIZE -",nil,43)
local center=makeButton(jumpSection,"Center",UDim2.new(.5,-44,0,207),UDim2.fromOffset(88,34),"RESET",nil,43)
local step=.018
local holding={[moveUp]=false,[moveDown]=false,[moveLeft]=false,[moveRight]=false}
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
local t=i.UserInputType
if t~=Enum.UserInputType.Touch and t~=Enum.UserInputType.MouseButton1 then return end
holding[b]=true
applyMoveStep(dx,dy)
end)
connect(b.InputEnded,function(i)
local t=i.UserInputType
if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then holding[b]=false end
end)
end
bindHold(moveUp,0,-step)
bindHold(moveDown,0,step)
bindHold(moveLeft,-step,0)
bindHold(moveRight,step,0)
connect(UserInputService.InputEnded,function(i)
local t=i.UserInputType
if t==Enum.UserInputType.Touch or t==Enum.UserInputType.MouseButton1 then
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
local old=saveButton.Text
saveButton.Text="SAVED!"
task.delay(1,function()if saveButton and saveButton.Parent then saveButton.Text=old end end)
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
local MUSIC_LIST={{"DJ BE AS ONE","83435514857435"},{"DJ MISSING YOU","119116468910055"},{"DJ LET YOU GO WITH A SMILE","87543116048841"},{"DJ DRAMA MALAM MINGGU","139226256901949"},{"YOU HOLD MY HEART","106106801939821"},{"DJ STAY THE SAME BREAKBEAT","74088514222709"},{"DJ ALL OF ME IS YOURS BREAKBEAT","104593616947405"}}
local musicGui=Instance.new("Frame")
musicGui.Name="MusicNodeList"
musicGui.Position=UDim2.fromOffset(12,72)
musicGui.Size=UDim2.fromOffset(315,360)
musicGui.BackgroundColor3=Color3.fromRGB(15,15,24)
musicGui.BackgroundTransparency=.03
musicGui.BorderSizePixel=0
musicGui.Active=false
musicGui.Visible=false
musicGui.ZIndex=200
musicGui.Parent=gui
local musicCorner=Instance.new("UICorner")
musicCorner.CornerRadius=UDim.new(0,16)
musicCorner.Parent=musicGui
premium(musicGui,2.5)
local musicTitle=Instance.new("TextLabel")
musicTitle.Position=UDim2.fromOffset(14,8)
musicTitle.Size=UDim2.new(1,-28,0,30)
musicTitle.BackgroundTransparency=1
musicTitle.Text="MUSIC NODE LIST"
musicTitle.TextColor3=Color3.new(1,1,1)
musicTitle.Font=Enum.Font.GothamBold
musicTitle.TextSize=18
musicTitle.TextXAlignment=Enum.TextXAlignment.Left
musicTitle.ZIndex=201
musicTitle.Parent=musicGui
local musicSub=Instance.new("TextLabel")
musicSub.Position=UDim2.fromOffset(14,36)
musicSub.Size=UDim2.new(1,-28,0,22)
musicSub.BackgroundTransparency=1
musicSub.Text="ID MUSIC • COPY"
musicSub.TextColor3=Color3.fromRGB(165,165,185)
musicSub.Font=Enum.Font.Gotham
musicSub.TextSize=11
musicSub.TextXAlignment=Enum.TextXAlignment.Left
musicSub.ZIndex=201
musicSub.Parent=musicGui
local musicList=Instance.new("ScrollingFrame")
musicList.Name="MusicList"
musicList.Position=UDim2.fromOffset(8,64)
musicList.Size=UDim2.new(1,-16,1,-72)
musicList.BackgroundTransparency=1
musicList.BorderSizePixel=0
musicList.ScrollBarThickness=3
musicList.ScrollBarImageColor3=Color3.fromRGB(255,80,0)
musicList.CanvasSize=UDim2.new()
musicList.AutomaticCanvasSize=Enum.AutomaticSize.Y
musicList.ScrollingDirection=Enum.ScrollingDirection.Y
musicList.ZIndex=201
musicList.Parent=musicGui
local musicLayout=Instance.new("UIListLayout")
musicLayout.Padding=UDim.new(0,7)
musicLayout.SortOrder=Enum.SortOrder.LayoutOrder
musicLayout.Parent=musicList
local musicPadding=Instance.new("UIPadding")
musicPadding.PaddingTop=UDim.new(0,2)
musicPadding.PaddingBottom=UDim.new(0,8)
musicPadding.PaddingLeft=UDim.new(0,2)
musicPadding.PaddingRight=UDim.new(0,2)
musicPadding.Parent=musicList
local function copyMusicID(id)
local ok=false
pcall(function()
if setclipboard then setclipboard(id);ok=true
elseif toclipboard then toclipboard(id);ok=true
elseif set_clipboard then set_clipboard(id);ok=true
end
end)
return ok
end
local function createMusicItem(index,name,id)
if destroyed then return end
local old=musicList:FindFirstChild("Music_"..index)
if old then return old end
local item=Instance.new("Frame")
item.Name="Music_"..index
item.Size=UDim2.new(1,-4,0,70)
item.BackgroundColor3=Color3.fromRGB(27,27,40)
item.BorderSizePixel=0
item.LayoutOrder=index
item.Active=false
item.ZIndex=202
item.Parent=musicList
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,11)
c.Parent=item
premium(item,1.3)
local nl=Instance.new("TextLabel")
nl.Position=UDim2.fromOffset(10,7)
nl.Size=UDim2.new(1,-105,0,24)
nl.BackgroundTransparency=1
nl.Text=name
nl.TextColor3=Color3.new(1,1,1)
nl.Font=Enum.Font.GothamBold
nl.TextSize=11
nl.TextXAlignment=Enum.TextXAlignment.Left
nl.TextTruncate=Enum.TextTruncate.AtEnd
nl.ZIndex=203
nl.Parent=item
local il=Instance.new("TextLabel")
il.Position=UDim2.fromOffset(10,34)
il.Size=UDim2.new(1,-105,0,22)
il.BackgroundTransparency=1
il.Text=id
il.TextColor3=Color3.fromRGB(175,175,195)
il.Font=Enum.Font.Code
il.TextSize=11
il.TextXAlignment=Enum.TextXAlignment.Left
il.ZIndex=203
il.Parent=item
local copy=Instance.new("TextButton")
copy.Name="Copy"
copy.AnchorPoint=Vector2.new(1,.5)
copy.Position=UDim2.new(1,-8,.5,0)
copy.Size=UDim2.fromOffset(78,38)
copy.BackgroundColor3=Color3.fromRGB(100,40,170)
copy.BorderSizePixel=0
copy.AutoButtonColor=false
copy.Text="COPY"
copy.TextColor3=Color3.new(1,1,1)
copy.Font=Enum.Font.GothamBold
copy.TextSize=12
copy.Active=true
copy.Selectable=false
copy.ZIndex=204
copy.Parent=item
local cp=Instance.new("UICorner")
cp.CornerRadius=UDim.new(0,9)
cp.Parent=copy
premium(copy,1.5)
connect(copy.Activated,function()
if destroyed then return end
if copyMusicID(id)then
copy.Text="COPIED"
copy.BackgroundColor3=Color3.fromRGB(45,170,100)
else
copy.Text="COPY ID"
copy.BackgroundColor3=Color3.fromRGB(190,90,50)
end
task.delay(1,function()
if copy and copy.Parent then
copy.Text="COPY"
copy.BackgroundColor3=Color3.fromRGB(100,40,170)
end
end)
end)
return item
end
for i,d in ipairs(MUSIC_LIST)do createMusicItem(i,d[1],d[2])end
local openMusic=Instance.new("TextButton")
openMusic.Name="OpenMusic"
openMusic.AnchorPoint=Vector2.new(1,0)
openMusic.Position=UDim2.new(1,-80,0,82)
openMusic.Size=UDim2.fromOffset(58,58)
openMusic.BackgroundColor3=Color3.fromRGB(25,25,35)
openMusic.BackgroundTransparency=.05
openMusic.BorderSizePixel=0
openMusic.Text="♫"
openMusic.TextColor3=Color3.new(1,1,1)
openMusic.TextSize=28
openMusic.Font=Enum.Font.GothamBold
openMusic.AutoButtonColor=false
openMusic.Active=true
openMusic.Selectable=false
openMusic.ZIndex=300
openMusic.Parent=gui
local omc=Instance.new("UICorner")
omc.CornerRadius=UDim.new(1,0)
omc.Parent=openMusic
premium(openMusic,2.5)
connect(openMusic.Activated,function()
if destroyed then return end
musicGui.Visible=not musicGui.Visible
end)

-- BAGIAN YANG SAYA PERBAIKI:
connect(RunService.RenderStepped,function()
if destroyed or not character or not character.Parent or not humanoid or humanoid.Health<=0 then return end
humanoid.CameraOffset=Vector3.zero
if _G.ShiftLocked then
    local cam=workspace.CurrentCamera
    local root=character:FindFirstChild("HumanoidRootPart")
    if cam and root then
        -- Cek apakah karakter TIDAK melompat/jatuh (mematikan Air Control, tapi menjaga Shift Lock)
        if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            local look=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
            if look.Magnitude>.001 then root.CFrame=CFrame.lookAt(root.Position,root.Position+look.Unit)end
        end
    end
    humanoid.AutoRotate=false
else
    humanoid.AutoRotate=true
end
end)
-- AKHIR BAGIAN YANG DIPERBAIKI

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
applyJumpPremium(j)
end
end
end)
local function refresh()
task.defer(function()updateJump();updateShift()end)
task.delay(.2,function()
if not destroyed then updateJump();updateShift()end
end)
task.delay(.5,function()
if not destroyed then updateJump();updateShift()end
end)
end
updateJump()
updateShift()
refresh()
