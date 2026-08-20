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
local Rayfield=loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local window=Rayfield:CreateWindow({
name="Delta Mobile Controls",
subtitle="Mobile Ergonomics",
})
local mainTab=window:CreateTab({name="Controls",icon=93364949241311})
local cameraTab=window:CreateTab({name="Camera",icon="camera"})
local musicTab=window:CreateTab({name="Music",icon="music"})
local configTab=window:CreateTab({name="Config",icon="settings"})
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
premiumStroke(btnShiftLock,2.5)
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
if not touchGui then jumpButton=nil return nil end
jumpButton=touchGui:FindFirstChild("JumpButton",true)
if jumpButton and jumpButton:IsA("GuiObject")then return jumpButton end
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
local targetSettingMode="JUMP"
mainTab:CreateSection({name="SHIFT LOCK"})
mainTab:CreateToggle({
name="Shift Lock",
CurrentValue=false,
Flag="ShiftLock",
callback=function(v)
if v~=_G.ShiftLocked then toggleShiftLock()end
end,
})
mainTab:CreateSection({name="TARGET"})
mainTab:CreateDropdown({
name="Position Target",
Options={"JUMP","SHIFT"},
CurrentOption={"JUMP"},
MultipleOptions=false,
Flag="PositionTarget",
callback=function(v)
targetSettingMode=v[1]or"JUMP"
end,
})
mainTab:CreateSection({name="POSITION"})
mainTab:CreateButton({
name="Move Up",
callback=function()
if targetSettingMode=="JUMP"then config.JumpY=math.clamp(config.JumpY-.018,.05,.95);updateJump()else config.ShiftY=math.clamp(config.ShiftY-.018,.02,.98);updateShift()end
end,
})
mainTab:CreateButton({
name="Move Down",
callback=function()
if targetSettingMode=="JUMP"then config.JumpY=math.clamp(config.JumpY+.018,.05,.95);updateJump()else config.ShiftY=math.clamp(config.ShiftY+.018,.02,.98);updateShift()end
end,
})
mainTab:CreateButton({
name="Move Left",
callback=function()
if targetSettingMode=="JUMP"then config.JumpX=math.clamp(config.JumpX-.018,.05,.95);updateJump()else config.ShiftX=math.clamp(config.ShiftX-.018,.02,.98);updateShift()end
end,
})
mainTab:CreateButton({
name="Move Right",
callback=function()
if targetSettingMode=="JUMP"then config.JumpX=math.clamp(config.JumpX+.018,.05,.95);updateJump()else config.ShiftX=math.clamp(config.ShiftX+.018,.02,.98);updateShift()end
end,
})
mainTab:CreateSection({name="SIZE"})
mainTab:CreateButton({
name="Size +",
callback=function()
if targetSettingMode=="JUMP"then config.JumpSize=math.clamp(config.JumpSize+.05,.05,.50);updateJump()else config.ShiftSize=math.clamp(config.ShiftSize+5,20,100);updateShift()end
end,
})
mainTab:CreateButton({
name="Size -",
callback=function()
if targetSettingMode=="JUMP"then config.JumpSize=math.clamp(config.JumpSize-.05,.05,.50);updateJump()else config.ShiftSize=math.clamp(config.ShiftSize-5,20,100);updateShift()end
end,
})
mainTab:CreateButton({
name="Reset Target",
callback=function()
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
end,
})
cameraTab:CreateSection({name="CAMERA SENSITIVITY"})
cameraTab:CreateSlider({
name="Sensitivity",
Range={.1,10},
Increment=.1,
Suffix="x",
CurrentValue=config.Sensitivity,
Flag="Sensitivity",
callback=function(v)
config.Sensitivity=v
pcall(function()UserSettings().GameSettings.MouseSensitivity=v end)
end,
})
cameraTab:CreateButton({
name="Reset Sensitivity",
callback=function()
config.Sensitivity=1
pcall(function()UserSettings().GameSettings.MouseSensitivity=1 end)
end,
})
local MUSIC_LIST={{"DJ BE AS ONE","83435514857435"},{"DJ MISSING YOU","119116468910055"},{"DJ LET YOU GO WITH A SMILE","87543116048841"},{"DJ DRAMA MALAM MINGGU","139226256901949"},{"YOU HOLD MY HEART","106106801939821"},{"DJ STAY THE SAME BREAKBEAT","74088514222709"},{"DJ ALL OF ME IS YOURS BREAKBEAT","104593616947405"}}
musicTab:CreateSection({name="MUSIC NODE LIST"})
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
for _,d in ipairs(MUSIC_LIST)do
local name,id=d[1],d[2]
musicTab:CreateButton({
name=name.." • "..id,
callback=function()
if copyMusicID(id)then
pcall(function()
Rayfield:Notify({Title="Music ID",Content="Copied: "..id,Duration=2})
end)
else
pcall(function()
Rayfield:Notify({Title="Music ID",Content="Clipboard tidak tersedia",Duration=2})
end)
end
end,
})
end
configTab:CreateSection({name="CONFIGURATION"})
configTab:CreateButton({
name="Save Configuration",
callback=function()
saveConfig()
pcall(function()
Rayfield:Notify({Title="Configuration",Content="Configuration saved",Duration=2})
end)
end,
})
configTab:CreateButton({
name="Reset Configuration",
callback=function()
for k,v in pairs(defaultConfig)do config[k]=v end
pcall(function()UserSettings().GameSettings.MouseSensitivity=1 end)
updateJump()
updateShift()
end,
})
configTab:CreateButton({
name="Destroy Interface",
callback=function()
_G.DeltaMobileControlsCleanup()
pcall(function()Rayfield:Destroy()end)
end,
})
connect(player.CharacterAdded,function(n)
if destroyed then return end
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
local tg=playerGui:FindFirstChild("TouchGui")
if tg then
local j=tg:FindFirstChild("JumpButton",true)
if j and j:IsA("GuiObject")then
jumpButton=j
updateJump()
end
end
end)
updateJump()
updateShift()
pcall(function()Rayfield:LoadConfiguration()end)
