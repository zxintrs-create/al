local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local VirtualUser=game:GetService("VirtualUser")
local TweenService=game:GetService("TweenService")
local Stats=game:GetService("Stats")
local Workspace=game:GetService("Workspace")
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")
local CoreGui=game:GetService("CoreGui")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local spawn,wait=task.spawn,task.wait

local function protect(cb)local ok,r=pcall(cb)return ok,r end
local function notify(t,txt,d)protect(function()StarterGui:SetCore("SendNotification",{Title=t,Text=txt,Duration=d or 1.5})end)end

local C={}
local ST={}
local function addC(c)if c then table.insert(C,c)end return c end
local function killST()for i,t in ipairs(ST)do protect(function()task.cancel(t)end)ST[i]=nil end table.clear(ST)end
local function purgeC()for i,c in ipairs(C)do protect(function()c:Disconnect()end)C[i]=nil end table.clear(C)end

local CFG={noclip=false,invisible=false,antiKick=true,skyboxId="rbxassetid://168892378",mapSaved={}}
local S={noclipCon=nil,invisCon=nil,selectedInstance=nil}

local function getGP()
local o,r=protect(function()if gethui then return gethui()end end)
if o and r then return r end
local o2,r2=protect(function()local s=Instance.new("ScreenGui")s.Parent=CoreGui s:Destroy()return CoreGui end)
if o2 and r2 then return CoreGui end
return playerGui
end
local guiParent=getGP()

local sg=Instance.new("ScreenGui")
sg.Name="AldoVzHack"
sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.DisplayOrder=999999
sg.IgnoreGuiInset=true
local sgOk=protect(function()sg.Parent=guiParent end)
if not sgOk then protect(function()sg.Parent=playerGui end)end

local floatButton=Instance.new("TextButton")
floatButton.Name="FloatButton"
floatButton.Size=UDim2.fromOffset(50,50)
floatButton.Position=UDim2.new(0,16,0.4,0)
floatButton.Text="💀"
floatButton.TextSize=24
floatButton.BackgroundColor3=Color3.fromRGB(20,10,40)
floatButton.BackgroundTransparency=0.05
floatButton.BorderSizePixel=0
floatButton.ZIndex=999
floatButton.Parent=sg
local floatCorner=Instance.new("UICorner")
floatCorner.CornerRadius=UDim.new(1,0)
floatCorner.Parent=floatButton
local floatGrad=Instance.new("UIGradient")
floatGrad.Rotation=45
floatGrad.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(200,0,0)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,0,100)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(100,0,255))
})
floatGrad.Parent=floatButton
local floatStroke=Instance.new("UIStroke")
floatStroke.Color=Color3.fromRGB(255,50,50)
floatStroke.Thickness=1.5
floatStroke.Transparency=0.2
floatStroke.Parent=floatButton

local drag={dragging=false,offset=Vector2.new()}
addC(floatButton.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch then
drag.dragging=true
drag.offset=i.Position-Vector2.new(floatButton.AbsolutePosition.X,floatButton.AbsolutePosition.Y)
end
end))
addC(floatButton.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.Touch then drag.dragging=false end
end))
addC(UserInputService.InputChanged:Connect(function(i)
if not drag.dragging then return end
if i.UserInputType~=Enum.UserInputType.Touch then return end
protect(function()
local vp=Workspace.CurrentCamera.ViewportSize
local p=i.Position-drag.offset
floatButton.Position=UDim2.fromOffset(math.clamp(p.X,0,vp.X-50),math.clamp(p.Y,0,vp.Y-50))
end)
end))

local mainFrame=Instance.new("Frame")
mainFrame.Name="MainFrame"
mainFrame.Size=UDim2.fromOffset(360,560)
mainFrame.Position=UDim2.new(0.5,-180,0.5,-280)
mainFrame.BackgroundColor3=Color3.fromRGB(10,8,24)
mainFrame.BorderSizePixel=0
mainFrame.ClipsDescendants=true
mainFrame.Visible=false
mainFrame.ZIndex=998
mainFrame.Parent=sg
local mainCorner=Instance.new("UICorner")
mainCorner.CornerRadius=UDim.new(0,12)
mainCorner.Parent=mainFrame
local mainGrad=Instance.new("UIGradient")
mainGrad.Rotation=45
mainGrad.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(60,0,120)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(180,0,80)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(0,80,180))
})
mainGrad.Offset=Vector2.new(0,0)
mainGrad.Parent=mainFrame
local mainStroke=Instance.new("UIStroke")
mainStroke.Color=Color3.fromRGB(200,0,80)
mainStroke.Thickness=1.5
mainStroke.Transparency=0.15
mainStroke.Parent=mainFrame

addC(RunService.Heartbeat:Connect(function()
protect(function()
local t=tick()
mainGrad.Offset=Vector2.new(math.sin(t*0.4)*0.6,math.cos(t*0.35)*0.6)
end)
end))

local titleBar=Instance.new("Frame")
titleBar.Name="TitleBar"
titleBar.Size=UDim2.new(1,0,0,36)
titleBar.BackgroundColor3=Color3.fromRGB(16,10,36)
titleBar.BackgroundTransparency=0.3
titleBar.BorderSizePixel=0
titleBar.Parent=mainFrame
local titleLabel=Instance.new("TextLabel")
titleLabel.Size=UDim2.new(0,200,1,0)
titleLabel.Position=UDim2.fromOffset(10,0)
titleLabel.Text="💀 ALDOVZ HACK SERVER"
titleLabel.TextColor3=Color3.fromRGB(255,80,80)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.TextSize=13
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency=1
titleLabel.Parent=titleBar
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.fromOffset(30,30)
closeBtn.Position=UDim2.new(1,-32,0.5,-15)
closeBtn.Text="✕"
closeBtn.TextColor3=Color3.fromRGB(255,100,100)
closeBtn.TextSize=16
closeBtn.Font=Enum.Font.GothamBold
closeBtn.BackgroundTransparency=1
closeBtn.BorderSizePixel=0
closeBtn.Parent=titleBar
addC(closeBtn.Activated:Connect(function()animMenu(false)end))

local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,0,0,32)
tabBar.Position=UDim2.new(0,0,0,36)
tabBar.BackgroundTransparency=1
tabBar.BorderSizePixel=0
tabBar.Parent=mainFrame
local tabLayout=Instance.new("UIListLayout")
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.Padding=UDim.new(0,2)
tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLayout.SortOrder=Enum.SortOrder.LayoutOrder
tabLayout.Parent=tabBar

local content=Instance.new("ScrollingFrame")
content.Size=UDim2.new(1,0,1,-76)
content.Position=UDim2.new(0,0,0,68)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.ScrollBarImageColor3=Color3.fromRGB(200,0,80)
content.AutomaticCanvasSize=Enum.AutomaticSize.Y
content.Parent=mainFrame
local listLayout=Instance.new("UIListLayout")
listLayout.Padding=UDim.new(0,6)
listLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
listLayout.SortOrder=Enum.SortOrder.LayoutOrder
listLayout.Parent=content
local padding=Instance.new("UIPadding")
padding.PaddingTop=UDim.new(0,6)
padding.PaddingBottom=UDim.new(0,6)
padding.Parent=content

-- ─── ANIMATION ─────────────────────────────────
local function setFT(t)
protect(function()
for _,c in ipairs(mainFrame:GetDescendants())do
if c:IsA("GuiObject")then c.GroupTransparency=t end
end
end)
end
local animating=false
local function animMenu(o)
if animating then return end
animating=true
if o then
mainFrame.Visible=true
setFT(1)
mainFrame.Size=UDim2.fromOffset(340,510)
mainFrame.Position=UDim2.new(0.5,-170,0.5,-255)
TweenService:Create(mainFrame,TweenInfo.new(0.25,Enum.EasingStyle.OutBack),{
Size=UDim2.fromOffset(360,560),
Position=UDim2.new(0.5,-180,0.5,-280)
}):Play()
TweenService:Create(mainFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
GroupTransparency=0
}):Play()
setFT(0)
else
local t=TweenService:Create(mainFrame,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
Size=UDim2.fromOffset(340,510),
Position=UDim2.new(0.5,-170,0.5,-255),
GroupTransparency=1
})
t:Play()
t.Completed:Connect(function()mainFrame.Visible=false animating=false end)
setFT(1)
return
end
task.delay(0.3,function()animating=false end)
end
addC(floatButton.Activated:Connect(function()
if drag.dragging then return end
animMenu(not mainFrame.Visible)
end))

-- ─── TAB SYSTEM ────────────────────────────────
local tabs={}
local currentTab=nil
local tabContents={}

local function createTab(name,icon)
local btn=Instance.new("TextButton")
btn.Size=UDim2.fromOffset(70,26)
btn.Text=icon.." "..name
btn.TextColor3=Color3.fromRGB(200,180,220)
btn.Font=Enum.Font.GothamBold
btn.TextSize=10
btn.BackgroundColor3=Color3.fromRGB(30,20,50)
btn.BackgroundTransparency=0.2
btn.BorderSizePixel=0
btn.Parent=tabBar
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local bs=Instance.new("UIStroke")
bs.Thickness=1
bs.Color=Color3.fromRGB(150,0,100)
bs.Transparency=0.5
bs.Parent=btn
local frame=Instance.new("Frame")
frame.Size=UDim2.new(1,0,0,0)
frame.BackgroundTransparency=1
frame.Visible=false
frame.Parent=content
table.insert(tabs,{button=btn,frame=frame,name=name})
addC(btn.Activated:Connect(function()
for _,t in ipairs(tabs)do
t.button.BackgroundColor3=Color3.fromRGB(30,20,50)
t.button.TextColor3=Color3.fromRGB(200,180,220)
t.frame.Visible=false
end
btn.BackgroundColor3=Color3.fromRGB(100,0,60)
btn.TextColor3=Color3.fromRGB(255,255,255)
frame.Visible=true
currentTab=frame
end))
return frame
end

-- ─── UI HELPERS ────────────────────────────────
local function makeSection(parent,title)
local s=Instance.new("Frame")
s.Size=UDim2.new(1,-16,0,0)
s.BackgroundColor3=Color3.fromRGB(16,12,32)
s.BackgroundTransparency=0.15
s.BorderSizePixel=0
s.AutomaticSize=Enum.AutomaticSize.Y
s.Parent=parent
local sc=Instance.new("UICorner")
sc.CornerRadius=UDim.new(0,8)
sc.Parent=s
local st=Instance.new("TextLabel")
st.Size=UDim2.new(1,-12,0,22)
st.Position=UDim2.fromOffset(6,4)
st.Text=title
st.TextColor3=Color3.fromRGB(200,150,255)
st.Font=Enum.Font.GothamBold
st.TextSize=11
st.TextXAlignment=Enum.TextXAlignment.Left
st.BackgroundTransparency=1
st.Parent=s
local sl=Instance.new("UIListLayout")
sl.Padding=UDim.new(0,4)
sl.HorizontalAlignment=Enum.HorizontalAlignment.Center
sl.SortOrder=Enum.SortOrder.LayoutOrder
sl.Parent=s
local sp=Instance.new("UIPadding")
sp.PaddingTop=UDim.new(0,26)
sp.PaddingBottom=UDim.new(0,8)
sp.Parent=s
return s
end

local function makeToggle(parent,text,getter,setter)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-12,0,40)
b.Text=text.."  [OFF]"
b.TextColor3=Color3.fromRGB(200,190,230)
b.Font=Enum.Font.GothamBold
b.TextSize=12
b.BackgroundColor3=Color3.fromRGB(20,16,38)
b.BackgroundTransparency=0.1
b.BorderSizePixel=0
b.Parent=parent
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,8)
bc.Parent=b
local bs=Instance.new("UIStroke")
bs.Thickness=1
bs.Color=Color3.fromRGB(80,40,120)
bs.Transparency=0.4
bs.Parent=b
local function upd()
local a=getter()
b.Text=text..(a and"  [ON]"or"  [OFF]")
b.BackgroundColor3=a and Color3.fromRGB(0,180,80)or Color3.fromRGB(20,16,38)
b.TextColor3=a and Color3.fromRGB(255,255,255)or Color3.fromRGB(200,190,230)
end
addC(b.Activated:Connect(function()
if getter()then setter(false)else setter(true)end
upd()
end))
return b
end

local function makeButton(parent,text,color,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,-12,0,40)
b.Text=text
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=12
b.BackgroundColor3=color or Color3.fromRGB(60,40,100)
b.BackgroundTransparency=0.12
b.BorderSizePixel=0
b.Parent=parent
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,8)
bc.Parent=b
local bs=Instance.new("UIStroke")
bs.Thickness=1
bs.Color=Color3.fromRGB(255,255,255)
bs.Transparency=0.5
bs.Parent=b
addC(b.Activated:Connect(function()protect(cb)end))
return b
end

local function makeInput(parent,placeholder,confirmText,confirmColor,onConfirm)
local f=Instance.new("Frame")
f.Size=UDim2.new(1,-12,0,56)
f.BackgroundTransparency=1
f.Parent=parent
local i=Instance.new("TextBox")
i.Size=UDim2.new(1,-60,0,36)
i.Position=UDim2.fromOffset(4,18)
i.PlaceholderText=placeholder
i.Text=""
i.TextColor3=Color3.fromRGB(255,255,255)
i.Font=Enum.Font.Gotham
i.TextSize=12
i.BackgroundColor3=Color3.fromRGB(20,16,38)
i.BackgroundTransparency=0.1
i.BorderSizePixel=0
i.ClearTextOnFocus=false
i.Parent=f
local ic=Instance.new("UICorner")
ic.CornerRadius=UDim.new(0,6)
ic.Parent=i
local b=Instance.new("TextButton")
b.Size=UDim2.fromOffset(50,36)
b.Position=UDim2.new(1,-54,0,18)
b.Text=confirmText or "GO"
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=10
b.BackgroundColor3=confirmColor or Color3.fromRGB(80,40,140)
b.BackgroundTransparency=0.12
b.BorderSizePixel=0
b.Parent=f
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=b
addC(b.Activated:Connect(function()
protect(function()onConfirm(i.Text)end)
end))
return f
end

local function makeLabel(parent,text,color,size)
local l=Instance.new("TextLabel")
l.Size=UDim2.new(1,-12,0,18)
l.Text=text
l.TextColor3=color or Color3.fromRGB(180,170,210)
l.Font=Enum.Font.Gotham
l.TextSize=size or 10
l.TextXAlignment=Enum.TextXAlignment.Left
l.BackgroundTransparency=1
l.Parent=parent
return l
end

-- ─── TAB 1: EXPLORER ──────────────────────────
local tab1=createTab("EXP","🔍")
local sec1=makeSection(tab1,"Explorer Scanner")
makeLabel(sec1,"Klik object untuk select, lalu gunakan tool di bawah",Color3.fromRGB(150,150,180),9)
local explDisplay=Instance.new("TextLabel")
explDisplay.Size=UDim2.new(1,-12,0,36)
explDisplay.Text="Selected: none"
explDisplay.TextColor3=Color3.fromRGB(255,200,100)
explDisplay.Font=Enum.Font.Gotham
explDisplay.TextSize=10
explDisplay.TextWrapped=true
explDisplay.BackgroundColor3=Color3.fromRGB(10,8,20)
explDisplay.BackgroundTransparency=0.3
explDisplay.BorderSizePixel=0
explDisplay.Parent=sec1
local explDc=Instance.new("UICorner")
explDc.CornerRadius=UDim.new(0,6)
explDc.Parent=explDisplay

local function scanExplorer()
protect(function()
local sel=S.selectedInstance
if not sel then notify("🔍 Explorer","Pilih object dulu!",1.5)return end
local txt="[Name]: "..sel.Name.."\n[Class]: "..sel.ClassName.."\n[Parent]: "..(sel.Parent and sel.Parent.Name or "nil")
if sel:IsA("BasePart")then
txt=txt.."\n[Position]: "..tostring(sel.Position)
end
explDisplay.Text=txt
end)
end

local function scanChildren()
protect(function()
local sel=S.selectedInstance
if not sel then notify("🔍 Explorer","Pilih object dulu!",1.5)return end
local txt=""
local count=0
for _,c in ipairs(sel:GetChildren())do
count=count+1
txt=txt..c.ClassName.." :: "..c.Name.."\n"
if count>=20 then txt=txt.."...+"..(#sel:GetChildren()-20).." more" break end
end
if txt=="" then txt="(no children)" end
explDisplay.Text=txt
end)
end

local function getScriptSource(inst)
if not inst then return nil end
if inst:IsA("LocalScript")or inst:IsA("Script")or inst:IsA("ModuleScript")then
return inst.Source
end
return nil
end

local function viewScript()
protect(function()
local sel=S.selectedInstance
if not sel then notify("📜 Script","Pilih object dulu!",1.5)return end
local src=getScriptSource(sel)
if src then
explDisplay.Text=string.sub(src,1,500)
notify("📜 Script","Source loaded! (max 500 char ditampilkan)",1.5)
else
notify("📜 Script","Object bukan script!",1.5)
end
end)
end

local function copyScript()
protect(function()
local sel=S.selectedInstance
if not sel then notify("📋 Copy","Pilih object dulu!",1.5)return end
local src=getScriptSource(sel)
if src then
setclipboard and setclipboard(src)
notify("📋 Copied","Script source di-copy ke clipboard!",1.5)
else
notify("📋 Copy","Object bukan script!",1.5)
end
end)
end

local function modifyScript()
protect(function()
local sel=S.selectedInstance
if not sel then notify("✏️ Modify","Pilih object dulu!",1.5)return end
if not(sel:IsA("LocalScript")or sel:IsA("Script")or sel:IsA("ModuleScript"))then
notify("✏️ Modify","Object bukan script!",1.5)return
end
sel.Source="-- Modified by AldoVz\nprint('Hacked by AldoVz')"
notify("✏️ Modified","Script berhasil dimodifikasi!",1.5)
end)
end

local function injectScript()
protect(function()
local sel=S.selectedInstance
if not sel then notify("💉 Inject","Pilih object dulu!",1.5)return end
local scr=Instance.new("LocalScript")
scr.Name="AldoVzInjected"
scr.Source="-- Injected by AldoVz Hub\nprint('💉 Script injected into '..script.Parent.Name)"
scr.Parent=sel
notify("💉 Injected","LocalScript dibuat di "..sel.Name,1.5)
end)
end

local function injectFromClipboard()
protect(function()
local sel=S.selectedInstance
if not sel then notify("📋 Inject","Pilih object dulu!",1.5)return end
local clip=""
protect(function()
if getclipboard then clip=getclipboard()end
end)
if clip=="" then
notify("📋 Inject","Clipboard kosong! Copy script dulu",1.5)
return
end
local scr=Instance.new("LocalScript")
scr.Name="AldoVzInjected"
scr.Source=clip
scr.Parent=sel
notify("📋 Injected","Script dari clipboard di-inject!",1.5)
end)
end

local function injectAsModule()
protect(function()
local sel=S.selectedInstance
if not sel then notify("📦 Inject","Pilih object dulu!",1.5)return end
local mod=Instance.new("ModuleScript")
mod.Name="AldoVzModule"
mod.Source="return { injected = true, name = 'AldoVz' }"
mod.Parent=sel
notify("📦 Injected","ModuleScript dibuat di "..sel.Name,1.5)
end)
end

local function runOnSelected()
protect(function()
local sel=S.selectedInstance
if not sel then notify("▶️ Run","Pilih object dulu!",1.5)return end
if sel:IsA("LocalScript")or sel:IsA("Script")then
local clone=sel:Clone()
clone.Disabled=false
clone.Parent=sel.Parent
notify("▶️ Run","Script di-run!",1.5)
else
notify("▶️ Run","Bukan script object!",1.5)
end
end)
end

local function deleteScript()
protect(function()
local sel=S.selectedInstance
if not sel then notify("🗑️ Delete","Pilih object dulu!",1.5)return end
if sel:IsA("LocalScript")or sel:IsA("Script")or sel:IsA("ModuleScript")then
local pn=sel.Name
sel:Destroy()
notify("🗑️ Deleted",pn.." dihapus!",1.5)
else
notify("🗑️ Delete","Bukan script object!",1.5)
end
end)
end

makeButton(sec1,"🔍 Scan Selected",Color3.fromRGB(80,60,160),scanExplorer)
makeButton(sec1,"📂 List Children",Color3.fromRGB(60,80,160),scanChildren)
makeButton(sec1,"📜 View Script Source",Color3.fromRGB(160,80,60),viewScript)
makeButton(sec1,"📋 Copy Script",Color3.fromRGB(60,140,80),copyScript)
makeButton(sec1,"✏️ Modify Script",Color3.fromRGB(160,60,60),modifyScript)
makeButton(sec1,"💉 Inject LocalScript (New)",Color3.fromRGB(180,60,180),injectScript)
makeButton(sec1,"📋 Inject from Clipboard",Color3.fromRGB(60,160,120),injectFromClipboard)
makeButton(sec1,"📦 Inject ModuleScript",Color3.fromRGB(100,60,180),injectAsModule)
makeButton(sec1,"▶️ Run Selected Script",Color3.fromRGB(60,180,80),runOnSelected)
makeButton(sec1,"🗑️ Delete Selected Script",Color3.fromRGB(180,40,40),deleteScript)

-- ─── SELECTOR ─────────────────────────────────
local function makeClickDetector()
protect(function()
local function scanNearby()
protect(function()
local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not r then return end
local nearest,ndist=nil,math.huge
local function scan(ins,depth)
if depth>3 then return end
for _,c in ipairs(ins:GetChildren())do
if c:IsA("BasePart")and c~=r then
local d=(c.Position-r.Position).Magnitude
if d<ndist and d<30 then
ndist=d
nearest=c
end
end
if depth<3 then scan(c,depth+1)end
end
end
scan(Workspace,1)
if nearest then
S.selectedInstance=nearest
explDisplay.Text="Selected: "..nearest.ClassName.." :: "..nearest.Name
notify("🎯 Selected",nearest.Name,1)
end
end)
end

local function selectChar()
protect(function()
local c=player.Character
if c then
S.selectedInstance=c
explDisplay.Text="Selected: Character :: "..c.Name
notify("🎯 Selected","Character",1)
end
end)
end

local function selectWS()
S.selectedInstance=Workspace
explDisplay.Text="Selected: Workspace"
notify("🎯 Selected","Workspace",1)
end

makeButton(sec1,"🎯 Select Nearest Object",Color3.fromRGB(60,140,100),scanNearby)
makeButton(sec1,"🧑 Select Character",Color3.fromRGB(60,100,140),selectChar)
makeButton(sec1,"🌍 Select Workspace",Color3.fromRGB(100,60,140),selectWS)
end)
end
makeClickDetector()

-- ─── TAB 2: EXPLOIT ────────────────────────────
local tab2=createTab("HACK","⚡")
local sec2=makeSection(tab2,"Toggle Features")
local noclipToggle
local invisibleToggle
local antiKickToggle

-- NOCLIP
local noclipActive=false
local noclipTh=nil
local function noclipStart()
noclipActive=true
CFG.noclip=true
if noclipTh then return end
noclipTh=spawn(function()
while noclipActive do
protect(function()
local c=player.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.CanCollide=false end
end
end
end)
wait(0.1)
end
noclipTh=nil
end)
table.insert(ST,noclipTh)
end
local function noclipStop()
noclipActive=false
CFG.noclip=false
if noclipTh then protect(function()task.cancel(noclipTh)end)noclipTh=nil end
end
noclipToggle=makeToggle(sec2,"🚪 Noclip",function()return noclipActive end,noclipStart,noclipStop)

-- INVISIBLE
local invisibleActive=false
local function invisibleStart()
invisibleActive=true
CFG.invisible=true
protect(function()
local c=player.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Transparency=1 end
end
local h=c:FindFirstChildOfClass("Humanoid")
if h then h:SetStateEnabled(Enum.HumanoidStateType.Dead,false)end
end
end)
S.invisCon=addC(RunService.RenderStepped:Connect(function()
protect(function()
local c=player.Character
if not c then return end
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Transparency=1 end
end
end)
end))
end
local function invisibleStop()
invisibleActive=false
CFG.invisible=false
if S.invisCon then protect(function()S.invisCon:Disconnect()end)S.invisCon=nil end
protect(function()
local c=player.Character
if c then
for _,p in ipairs(c:GetDescendants())do
if p:IsA("BasePart")then p.Transparency=0 end
end
end
end)
end
invisibleToggle=makeToggle(sec2,"👻 Invisible",function()return invisibleActive end,invisibleStart,invisibleStop)

-- ANTI KICK
local antiKickActive=true
local akC=nil
local function akStart()
antiKickActive=true
CFG.antiKick=true
if akC then return end
akC=addC(player.Idled:Connect(function()
protect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
end))
end
local function akStop()
antiKickActive=false
CFG.antiKick=false
if akC then protect(function()akC:Disconnect()end)akC=nil end
end
antiKickToggle=makeToggle(sec2,"🛡️ Anti Kick",function()return antiKickActive end,akStart,akStop)

-- ─── TAB 3: BACKDOOR ─────────────────────────
local tab3=createTab("BACK","🔓")
local sec3=makeSection(tab3,"Backdoor Scanner & Remote Hijack")

local backdoorKeywords={"backdoor","admin","owner","auth","password","secret","hidden","kick","ban","teleport","loadstring","loadfile","dofile","http","webhook","execute","exploit","bypass","rank","mod","god","fly","noclip","invisible","cmds","commands","console","adminpanel","adpan","give","tool","gear","spawn","delete","remove","control","manage","remote","event","fire","invoke","server","client","replicate","bypass","antikick","antiban","scripts","load","run","execute","test","debug","log","token","key","api","callback","hook","exploit","hack","cheat","mod","admin","owner","sudo","cmd","command","panel","paneladmin","adminpanel","admingui","admincmd","cmdpanel","staff","moderator","rank","setrank","changerank","promote","demote","permission","perms","access","level","role","group","team","setteam","jointeam","spectate","follow","goto","bring","tpto","teleport","tween","move","slide","freeze","unfreeze","remove","delete","destroy","kill","slay","reset","respawn","revive","heal","godmode","noclip","fly","jump","speed","walkspeed","jumppower","gravity","size","scale","remotes","events","bind","function","call","invoke","fire","trigger","activate","loadstring","load","execute","run","compile","script","source","code","bytecode","decompile","dump","read","write","file","folder","directory","path","create","upload","download","save","load","config","settings","options","preferences","configfile","json","data","savefile","loadfile","readfile","writefile","appendfile","dofile","httpget","https","request","post","get","fetch","webhook","discord","url","link","ip","address","port","connect","socket","server","client","network","send","receive","message","chat","broadcast","notice","notification","alert","warn","error","log","debug","print","output","console","cmd","terminal","shell","system","os","process","thread","coroutine","spawn","delay","wait","tick","time","clock","timer","counter","loop","while","repeat","for","if","then","else","end","function","return","local","global","var","value","set","get","insert","remove","find","match","gsub","sub","char","byte","len","rep","reverse","upper","lower","tonumber","tostring","type","typeof","rawget","rawset","rawlen","newproxy","select","unpack","pack","pairs","ipairs","next","table","string","math","vector","cframe","udim","udim2","color","ray","region","path","waypoint","point","node","graph","tree","stack","queue","list","map","key","value","index","key","hash","id","uid","guid","name","title","desc","description","tag","label","icon","image","sound","part","mesh","union","solid","model","folder","group","collection","service","instance","class","object","proto","module","package","lib","library","api","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk","sdk"}

local backdoorResults=Instance.new("TextLabel")
backdoorResults.Size=UDim2.new(1,-12,0,60)
backdoorResults.Text="Click scan to start"
backdoorResults.TextColor3=Color3.fromRGB(180,170,210)
backdoorResults.Font=Enum.Font.Gotham
backdoorResults.TextSize=9
backdoorResults.TextWrapped=true
backdoorResults.TextXAlignment=Enum.TextXAlignment.Left
backdoorResults.BackgroundColor3=Color3.fromRGB(10,8,20)
backdoorResults.BackgroundTransparency=0.3
backdoorResults.BorderSizePixel=0
backdoorResults.Parent=sec3
local bdC=Instance.new("UICorner")
bdC.CornerRadius=UDim.new(0,6)
bdC.Parent=backdoorResults

local function scanBackdoor()
protect(function()
notify("🔍 Backdoor","Scanning scripts...",1.5)
local found={}
local total=0
local function scan(ins,depth)
if depth>4 then return end
for _,c in ipairs(ins:GetChildren())do
total=total+1
if c:IsA("LocalScript")or c:IsA("Script")or c:IsA("ModuleScript")then
local src=c.Source:lower()
for _,kw in ipairs(backdoorKeywords)do
if string.find(src,kw,1,true)then
table.insert(found,{name=c.Name,class=c.ClassName,keyword=kw,parent=c.Parent and c.Parent.Name or "?"})
break
end
end
end
if total<5000 then scan(c,depth+1)end
end
end
scan(game,1)
local txt=""
for i,f in ipairs(found)do
if i>10 then txt=txt.."...+"..(#found-10).." more" break end
txt=txt..f.class.." :: "..f.name.." (key:"..f.keyword..")\n"
end
if txt=="" then txt="No backdoor scripts found (scanned "..total.." instances)" end
backdoorResults.Text=txt
notify("🔍 Backdoor",string.format("Found %d potential scripts",#found),2)
end)
end

local function exploitRemote()
protect(function()
local sel=S.selectedInstance
if not sel then notify("📡 Remote","Pilih remote event di Explorer!",1.5)return end
if not(sel:IsA("RemoteEvent")or sel:IsA("RemoteFunction"))then
notify("📡 Remote","Bukan RemoteEvent/RemoteFunction!",1.5)return
end
protect(function()
sel:FireServer("AldoVzHack")
end)
notify("📡 Remote","Fired! Jika ada listener, trigger berhasil!",1.5)
end)
end

local function findRemotes()
protect(function()
local found={}
local function scan(ins,depth)
if depth>3 then return end
for _,c in ipairs(ins:GetChildren())do
if c:IsA("RemoteEvent")or c:IsA("RemoteFunction")then
table.insert(found,c)
end
if depth<3 then scan(c,depth+1)end
end
end
scan(game,1)
local txt=""
for i,r in ipairs(found)do
if i>10 then txt=txt.."...+"..(#found-10).." more" break end
txt=txt..r.ClassName.." :: "..r.Name.."\n"
end
if txt=="" then txt="No remotes found" end
backdoorResults.Text=txt
notify("📡 Remotes",string.format("Found %d remote events",#found),1.5)
end)
end

makeButton(sec3,"🔓 Scan Backdoor Scripts",Color3.fromRGB(180,40,40),scanBackdoor)
makeButton(sec3,"📡 Fire Remote (Selected)",Color3.fromRGB(60,100,200),exploitRemote)
makeButton(sec3,"🔍 Find All Remotes",Color3.fromRGB(40,120,160),findRemotes)

-- ─── TAB 4: TELEPORT ──────────────────────────
local tab4=createTab("TP","🌐")
local sec4=makeSection(tab4,"Teleport & Player List")

local playerList=Instance.new("ScrollingFrame")
playerList.Size=UDim2.new(1,-12,0,120)
playerList.BackgroundColor3=Color3.fromRGB(10,8,20)
playerList.BackgroundTransparency=0.3
playerList.BorderSizePixel=0
playerList.ScrollBarThickness=2
playerList.AutomaticCanvasSize=Enum.AutomaticSize.Y
playerList.Parent=sec4
local plCorn=Instance.new("UICorner")
plCorn.CornerRadius=UDim.new(0,6)
plCorn.Parent=playerList
local plLy=Instance.new("UIListLayout")
plLy.Padding=UDim.new(0,2)
plLy.Parent=playerList

local function refreshPlayerList()
protect(function()
for _,c in ipairs(playerList:GetChildren())do
if c:IsA("TextButton")then c:Destroy()end
end
for _,p in ipairs(Players:GetPlayers())do
if p~=player then
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,0,0,28)
b.Text="📍 "..p.Name
b.TextColor3=Color3.fromRGB(200,190,230)
b.Font=Enum.Font.Gotham
b.TextSize=10
b.TextXAlignment=Enum.TextXAlignment.Left
b.BackgroundColor3=Color3.fromRGB(30,20,50)
b.BackgroundTransparency=0.2
b.BorderSizePixel=0
b.Parent=playerList
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,4)
bc.Parent=b
addC(b.Activated:Connect(function()
protect(function()
local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local pr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if r and pr then
r.CFrame=pr.CFrame+Vector3.new(0,3,0)
notify("📍 TP","Teleport ke "..p.Name,1.5)
end
end)
end))
end
end
end)
end
refreshPlayerList()
spawn(function()
while sg and sg.Parent do
wait(3)
if tab4.Visible then refreshPlayerList()end
end
end)

makeLabel(sec4,"Coordinate Teleport",Color3.fromRGB(150,150,200),10)
makeInput(sec4,"x,y,z (contoh: 0,50,0)","TP",Color3.fromRGB(80,60,160),function(txt)
protect(function()
local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not r then return end
local x,y,z=string.match(txt,"([%d%-]+),([%d%-]+),([%d%-]+)")
if x and y and z then
r.CFrame=CFrame.new(tonumber(x),tonumber(y),tonumber(z))
notify("🌐 TP","Teleport ke "..txt,1.5)
else
notify("🌐 TP","Format salah! Pakai x,y,z",1.5)
end
end)
end)

makeButton(sec4,"🔄 Refresh Player List",Color3.fromRGB(60,100,160),refreshPlayerList)

-- ─── TAB 5: SKYBOX ────────────────────────────
local tab5=createTab("SKY","🌈")
local sec5=makeSection(tab5,"Skybox Changer & Map Save/Load")

makeInput(sec5,"Skybox ID (rbxassetid://...)","APPLY",Color3.fromRGB(60,120,200),function(id)
protect(function()
local skyId=id
if string.find(skyId,"rbxassetid://")==nil then
skyId="rbxassetid://"..skyId
end
local sky=Instance.new("Sky")
sky.SkyboxBk=skyId
sky.SkyboxDn=skyId
sky.SkyboxFt=skyId
sky.SkyboxLf=skyId
sky.SkyboxRt=skyId
sky.SkyboxUp=skyId
sky.Parent=Lighting
CFG.skyboxId=skyId
notify("🌈 Skybox","Applied!",1.5)
end)
end)

makeButton(sec5,"💾 Save Skybox ID",Color3.fromRGB(60,140,80),function()
protect(function()
writefile("AldoVzSkybox.json",HttpService:JSONEncode({id=CFG.skyboxId}))
notify("💾 Saved","Skybox ID disimpan!",1.5)
end)
end)

makeButton(sec5,"📂 Load Skybox ID",Color3.fromRGB(60,80,140),function()
protect(function()
local c=readfile("AldoVzSkybox.json")
if c and #c>0 then
local d=HttpService:JSONDecode(c)
if d.id then
local sky=Instance.new("Sky")
sky.SkyboxBk=d.id sky.SkyboxDn=d.id sky.SkyboxFt=d.id
sky.SkyboxLf=d.id sky.SkyboxRt=d.id sky.SkyboxUp=d.id
sky.Parent=Lighting
CFG.skyboxId=d.id
notify("📂 Loaded","Skybox dimuat!",1.5)
end
end
end)
end)

makeLabel(sec5,"━━━ Map Save/Load ━━━",Color3.fromRGB(200,150,100),10)

makeButton(sec5,"💾 Save Map (Workspace)",Color3.fromRGB(60,160,90),function()
protect(function()
local data={}
local count=0
local function scan(ins,depth)
if depth>3 or count>200 then return end
for _,c in ipairs(ins:GetChildren())do
if c:IsA("BasePart")and c.Anchored then
count=count+1
table.insert(data,{
n=c.Name,
c=c.ClassName,
x=c.Position.X,y=c.Position.Y,z=c.Position.Z,
r={c.CFrame:ToEulerAnglesXYZ()},
sx=c.Size.X,sy=c.Size.Y,sz=c.Size.Z,
b=c.BrickColor and c.BrickColor.Name or "Medium stone grey"
})
end
if count<200 then scan(c,depth+1)end
end
end
scan(Workspace,1)
writefile("AldoVzMap.json",HttpService:JSONEncode(data))
notify("💾 Map Saved",string.format("%d parts disimpan!",#data),2)
end)
end)

makeButton(sec5,"📂 Load Map (from Save)",Color3.fromRGB(60,90,160),function()
protect(function()
local c=readfile("AldoVzMap.json")
if not c or #c==0 then notify("📂 Load","File map tidak ditemukan!",1.5)return end
local d=HttpService:JSONDecode(c)
local folder=Instance.new("Folder")
folder.Name="AldoVzLoadedMap"
folder.Parent=Workspace
for _,e in ipairs(d)do
local p=Instance.new("Part")
p.Name=e.n
p.Size=Vector3.new(e.sx,e.sy,e.sz)
p.Position=Vector3.new(e.x,e.y,e.z)
p.Anchored=true
p.CanCollide=true
p.BrickColor=BrickColor.new(e.b or "Medium stone grey")
p.Material=Enum.Material.SmoothPlastic
p.Parent=folder
end
notify("📂 Map Loaded",string.format("%d parts dimuat!",#d),2)
end)
end)

-- ─── TAB 6: MISC ──────────────────────────────
local tab6=createTab("MISC","⚙️")
local sec6=makeSection(tab6,"Miscellaneous Tools")

makeButton(sec6,"🔄 Force Respawn",Color3.fromRGB(160,60,60),function()
protect(function()
local c=player.Character
if c then
local h=c:FindFirstChildOfClass("Humanoid")
if h then h.Health=0 end
end
end)
end)

makeButton(sec6,"🔍 Get All Tools",Color3.fromRGB(60,120,160),function()
protect(function()
local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not r then return end
local count=0
local function scan(ins,depth)
if depth>3 then return end
for _,c in ipairs(ins:GetChildren())do
if c:IsA("Tool")then
c.Handle.CFrame=r.CFrame+Vector3.new(math.random(-5,5),3,math.random(-5,5))
count=count+1
end
scan(c,depth+1)
end
end
scan(Workspace,1)
notify("🔍 Tools",string.format("%d tools di-bring!",count),1.5)
end)
end)

makeButton(sec6,"🧹 Clear Debris",Color3.fromRGB(100,80,60),function()
protect(function()
local count=0
for _,c in ipairs(Workspace:GetChildren())do
if c:IsA("Part")or c:IsA("MeshPart")or c:IsA("UnionOperation")then
if not c.Anchored and c.Transparency<1 then
c:Destroy()
count=count+1
end
end
end
notify("🧹 Clear",string.format("%d parts dihapus!",count),1.5)
end)
end)

local espActive=false
local espTh=nil
local espHighlights={}
makeButton(sec6,"👁️ ESP All Players",Color3.fromRGB(80,40,140),function()
if espActive then
espActive=false
if espTh then protect(function()task.cancel(espTh)end)espTh=nil end
for p,h in pairs(espHighlights)do protect(function()h:Destroy()end)end
table.clear(espHighlights)
notify("👁️ ESP","OFF",1)
return
end
espActive=true
espTh=spawn(function()
while espActive do
protect(function()
for _,p in ipairs(Players:GetPlayers())do
if p~=player and p.Character then
local c=p.Character
if not espHighlights[p]or not espHighlights[p].Parent then
if espHighlights[p]then protect(function()espHighlights[p]:Destroy()end)end
local h=Instance.new("Highlight")
h.FillColor=Color3.fromRGB(255,0,0)
h.FillTransparency=0.4
h.OutlineColor=Color3.fromRGB(0,255,255)
h.OutlineTransparency=0.1
h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
h.Parent=c
espHighlights[p]=h
end
end
end)
wait(0.5)
end
espTh=nil
end)
table.insert(ST,espTh)
notify("👁️ ESP","ON",1)
end)

-- ─── INIT ──────────────────────────────────────
akStart()
notify("💀 AldoVz Hack","Loaded! Tap 💀 buka menu",2.5)
print("[AldoVzHackServer] Loaded — All features ready!")

local function cleanup()
protect(function()
noclipStop()
invisibleStop()
akStop()
if espTh then protect(function()task.cancel(espTh)end)end
killST()
purgeC()
protect(function()sg:Destroy()end)
end)
end
_G.AldoVzHackCleanup=cleanup
