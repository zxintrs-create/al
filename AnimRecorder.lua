local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local TextChatService=game:GetService("TextChatService")
local HttpService=game:GetService("HttpService")
local VirtualUser=game:GetService("VirtualUser")

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")

local CONFIG_FILE="VoraZureConfig.json"
local ROUTE_FILE="VoraZureRoutes.json"
local PLAYBACK_BIND="VoraZure_AutoWalk_Playback"

local CONFIG={
    Language="Indonesia",
    Gradient=0,
    WalkSpeed=0,
    JumpPower=50,
    AntiAFK=false,
    NaturalAnimation=true,
    AntiJitter=true,
    AntiGlitch=true,
    AntiLag=true,
    AntiOutTrack=true
}

local COLORS={
    Background=Color3.fromRGB(8,9,15),
    Panel=Color3.fromRGB(14,15,24),
    Panel2=Color3.fromRGB(20,21,32),
    Card=Color3.fromRGB(24,25,38),
    Text=Color3.fromRGB(245,245,255),
    SubText=Color3.fromRGB(155,158,180),
    Accent=Color3.fromRGB(135,75,255),
    Accent2=Color3.fromRGB(65,180,255),
    Success=Color3.fromRGB(80,220,145),
    Danger=Color3.fromRGB(255,75,100),
    Warning=Color3.fromRGB(255,190,75)
}

local Character
local Humanoid
local Root

local route={}
local savedRoutes={}

local isRecording=false
local isPlaying=false
local playbackTime=0
local playbackIndex=1
local recordStart=0
local lastSampleTime=0
local lastRecordPosition=nil
local lastRecordMove=Vector3.zero
local lastRecordState=nil
local jumpEvents={}
local playbackJumpCursor=1
local selectedPlayer=nil
local spectating=false

local recordConnection
local playbackHeartbeat
local antiAFKConnection
local characterConnection

local ScreenGui
local Main
local Gradient
local OpenButton
local Floating
local AutoStatus
local FPSLabel
local PingLabel
local SpeedValue
local JumpValue
local LanguageButton

local menuOpen=true
local menuTween=nil
local dragMoved=false

local function refreshCharacter()
    Character=LocalPlayer.Character

    if not Character then
        Humanoid=nil
        Root=nil
        return false
    end

    Humanoid=Character:FindFirstChildOfClass("Humanoid")
    Root=Character:FindFirstChild("HumanoidRootPart")

    return Humanoid~=nil and Root~=nil
end

refreshCharacter()

local function safeWriteFile(path,data)
    if type(writefile)~="function" then
        return false
    end

    return pcall(function()
        writefile(path,data)
    end)
end

local function safeReadFile(path)
    if type(isfile)~="function" or type(readfile)~="function" then
        return nil
    end

    local ok,result=pcall(function()
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end)

    if ok then
        return result
    end

    return nil
end

local function safeDeleteFile(path)
    if type(isfile)~="function" or type(delfile)~="function" then
        return
    end

    pcall(function()
        if isfile(path) then
            delfile(path)
        end
    end)
end

local function saveConfig()
    local ok,data=pcall(function()
        return HttpService:JSONEncode(CONFIG)
    end)

    if ok then
        safeWriteFile(CONFIG_FILE,data)
    end
end

local function loadConfig()
    local data=safeReadFile(CONFIG_FILE)

    if not data then
        return
    end

    local ok,decoded=pcall(function()
        return HttpService:JSONDecode(data)
    end)

    if ok and type(decoded)=="table" then
        for key,value in pairs(decoded) do
            if CONFIG[key]~=nil and typeof(value)==typeof(CONFIG[key]) then
                CONFIG[key]=value
            end
        end
    end

    CONFIG.Gradient=math.clamp(
        tonumber(CONFIG.Gradient) or 0,
        0,
        4
    )
end

local function saveRoutes()
    local ok,data=pcall(function()
        return HttpService:JSONEncode(savedRoutes)
    end)

    if ok then
        safeWriteFile(ROUTE_FILE,data)
    end
end

local function loadRoutes()
    local data=safeReadFile(ROUTE_FILE)

    if not data then
        return
    end

    local ok,decoded=pcall(function()
        return HttpService:JSONDecode(data)
    end)

    if ok and type(decoded)=="table" then
        savedRoutes=decoded
    end
end

loadConfig()
loadRoutes()

local function stopPlayback()
    if not isPlaying then
        return
    end

    isPlaying=false

    pcall(function()
        RunService:UnbindFromRenderStep(PLAYBACK_BIND)
    end)

    if playbackHeartbeat then
        playbackHeartbeat:Disconnect()
        playbackHeartbeat=nil
    end

    playbackTime=0
    playbackIndex=1
    playbackJumpCursor=1

    if Humanoid and Humanoid.Parent then
        pcall(function()
            Humanoid:Move(Vector3.zero,false)
        end)
    end

    if AutoStatus then
        AutoStatus.Text="STATUS : IDLE • "..tostring(#route).." POINTS"
        AutoStatus.TextColor3=COLORS.Success
    end
end

local function stopRecording()
    if not isRecording then
        return
    end

    isRecording=false

    if recordConnection then
        recordConnection:Disconnect()
        recordConnection=nil
    end

    if Root and Root.Parent and Humanoid then
        local pos=Root.Position
        local velocity=Root.AssemblyLinearVelocity
        local state=Humanoid:GetState()
        local move=Humanoid.MoveDirection
        local look=Root.CFrame.LookVector

        route[#route+1]={
            Time=os.clock()-recordStart,
            Position={
                X=pos.X,
                Y=pos.Y,
                Z=pos.Z
            },
            MoveDirection={
                X=move.X,
                Y=move.Y,
                Z=move.Z
            },
            Look={
                X=look.X,
                Y=look.Y,
                Z=look.Z
            },
            Velocity={
                X=velocity.X,
                Y=velocity.Y,
                Z=velocity.Z
            },
            State=state.Name,
            Jump=false
        }
    end

    if AutoStatus then
        AutoStatus.Text="STATUS : RECORD COMPLETE • "..tostring(#route).." POINTS"
        AutoStatus.TextColor3=COLORS.Success
    end
end

characterConnection=LocalPlayer.CharacterAdded:Connect(function(character)
    if isRecording then
        stopRecording()
    end

    if isPlaying then
        stopPlayback()
    end

    Character=character
    Humanoid=character:WaitForChild("Humanoid",10)
    Root=character:WaitForChild("HumanoidRootPart",10)

    task.wait(0.15)

    if Humanoid then
        Humanoid.WalkSpeed=CONFIG.WalkSpeed>0 and CONFIG.WalkSpeed or 16

        if Humanoid.UseJumpPower then
            Humanoid.JumpPower=CONFIG.JumpPower
        end
    end
end)

local function tween(object,properties,duration)
    if not object or not object.Parent then
        return nil
    end

    local ok,result=pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.25,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            properties
        )
    end)

    if ok then
        return result
    end

    return nil
end

local function corner(object,radius)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,radius or 10)
    c.Parent=object
    return c
end

local function stroke(object,transparency)
    local s=Instance.new("UIStroke")
    s.Color=Color3.fromRGB(90,95,130)
    s.Transparency=transparency or 0.65
    s.Thickness=1
    s.Parent=object
    return s
end

local function padding(object,amount)
    local p=Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,amount)
    p.PaddingBottom=UDim.new(0,amount)
    p.PaddingLeft=UDim.new(0,amount)
    p.PaddingRight=UDim.new(0,amount)
    p.Parent=object
    return p
end

pcall(function()
    local old=PlayerGui:FindFirstChild("VoraZureMobileHub")

    if old then
        old:Destroy()
    end
end)

ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VoraZureMobileHub"
ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder=999999
ScreenGui.Parent=PlayerGui

Main=Instance.new("Frame")
Main.Name="Main"
Main.Size=UDim2.new(0,390,0,590)
Main.Position=UDim2.new(0.5,-195,0.5,-295)
Main.BackgroundColor3=COLORS.Background
Main.BorderSizePixel=0
Main.Parent=ScreenGui

corner(Main,18)
stroke(Main,0.35)

local MainScale=Instance.new("UIScale")
MainScale.Scale=1
MainScale.Parent=Main

Gradient=Instance.new("UIGradient")
Gradient.Rotation=25
Gradient.Parent=Main

local function applyGradient()
    local index=math.clamp(
        tonumber(CONFIG.Gradient) or 0,
        0,
        4
    )

    if index==0 then
        Gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(90,45,170)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(35,100,190)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(155,50,180))
        })
    elseif index==1 then
        Gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(125,40,220)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(40,180,255))
        })
    elseif index==2 then
        Gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,50,145)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(95,50,255))
        })
    elseif index==3 then
        Gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(40,220,170)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(40,100,255))
        })
    else
        Gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,145,50)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,55,105)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(120,50,255))
        })
    end
end

applyGradient()

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        Gradient.Offset=Vector2.new(-1,0)

        local t=tween(
            Gradient,
            {
                Offset=Vector2.new(1,0)
            },
            4
        )

        if t then
            t:Play()
            t.Completed:Wait()
        else
            task.wait(4)
        end
    end
end)

local TopBar=Instance.new("Frame")
TopBar.Size=UDim2.new(1,0,0,66)
TopBar.BackgroundTransparency=1
TopBar.Parent=Main

local Title=Instance.new("TextLabel")
Title.BackgroundTransparency=1
Title.Position=UDim2.new(0,20,0,8)
Title.Size=UDim2.new(0,220,0,28)
Title.Font=Enum.Font.GothamBold
Title.Text="👑 VORA ZURE"
Title.TextSize=20
Title.TextColor3=COLORS.Text
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=TopBar

local Status=Instance.new("TextLabel")
Status.BackgroundTransparency=1
Status.Position=UDim2.new(0,21,0,36)
Status.Size=UDim2.new(0,180,0,20)
Status.Font=Enum.Font.Gotham
Status.Text="ONLINE • MOBILE"
Status.TextSize=11
Status.TextColor3=COLORS.Success
Status.TextXAlignment=Enum.TextXAlignment.Left
Status.Parent=TopBar

FPSLabel=Instance.new("TextLabel")
FPSLabel.BackgroundTransparency=1
FPSLabel.Position=UDim2.new(1,-170,0,12)
FPSLabel.Size=UDim2.new(0,70,0,20)
FPSLabel.Font=Enum.Font.GothamBold
FPSLabel.Text="FPS --"
FPSLabel.TextSize=12
FPSLabel.TextColor3=COLORS.Text
FPSLabel.Parent=TopBar

PingLabel=Instance.new("TextLabel")
PingLabel.BackgroundTransparency=1
PingLabel.Position=UDim2.new(1,-90,0,12)
PingLabel.Size=UDim2.new(0,70,0,20)
PingLabel.Font=Enum.Font.GothamBold
PingLabel.Text="PING --"
PingLabel.TextSize=12
PingLabel.TextColor3=COLORS.Text
PingLabel.Parent=TopBar

local Avatar=Instance.new("ImageLabel")
Avatar.Size=UDim2.new(0,48,0,48)
Avatar.Position=UDim2.new(0,14,0,75)
Avatar.BackgroundColor3=COLORS.Card
Avatar.BorderSizePixel=0
Avatar.Parent=Main
corner(Avatar,14)

local avatarOK,avatarURL=pcall(function()
    return Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size100x100
    )
end)

if avatarOK then
    Avatar.Image=avatarURL
end

local DisplayName=Instance.new("TextLabel")
DisplayName.BackgroundTransparency=1
DisplayName.Position=UDim2.new(0,72,0,76)
DisplayName.Size=UDim2.new(0,250,0,24)
DisplayName.Font=Enum.Font.GothamBold
DisplayName.Text="DISPLAY : "..LocalPlayer.DisplayName
DisplayName.TextSize=13
DisplayName.TextColor3=COLORS.Text
DisplayName.TextXAlignment=Enum.TextXAlignment.Left
DisplayName.Parent=Main

local Username=Instance.new("TextLabel")
Username.BackgroundTransparency=1
Username.Position=UDim2.new(0,72,0,100)
Username.Size=UDim2.new(0,250,0,20)
Username.Font=Enum.Font.Gotham
Username.Text="USERNAME : "..LocalPlayer.Name
Username.TextSize=11
Username.TextColor3=COLORS.SubText
Username.TextXAlignment=Enum.TextXAlignment.Left
Username.Parent=Main

local Content=Instance.new("Frame")
Content.Name="Content"
Content.Position=UDim2.new(0,12,0,132)
Content.Size=UDim2.new(1,-24,1,-144)
Content.BackgroundTransparency=1
Content.Parent=Main

local Tabs=Instance.new("Frame")
Tabs.Size=UDim2.new(0,90,1,0)
Tabs.BackgroundColor3=COLORS.Panel
Tabs.BorderSizePixel=0
Tabs.Parent=Content
corner(Tabs,14)

local Pages=Instance.new("Frame")
Pages.Position=UDim2.new(0,100,0,0)
Pages.Size=UDim2.new(1,-100,1,0)
Pages.BackgroundTransparency=1
Pages.Parent=Content

local function createPage(name)
    local page=Instance.new("ScrollingFrame")
    page.Name=name
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageTransparency=0.4
    page.Visible=false
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.CanvasSize=UDim2.new()
    page.Parent=Pages

    local layout=Instance.new("UIListLayout")
    layout.Padding=UDim.new(0,8)
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    layout.Parent=page

    padding(page,4)

    return page
end

local HomePage=createPage("HOME")
local AutoPage=createPage("AUTO WALK")
local CharacterPage=createPage("CHARACTER")
local ChatPage=createPage("CHAT")
local ProfilePage=createPage("PROFILE")
local SettingsPage=createPage("SETTINGS")

local PagesMap={
    HOME=HomePage,
    ["AUTO WALK"]=AutoPage,
    CHARACTER=CharacterPage,
    CHAT=ChatPage,
    PROFILE=ProfilePage,
    SETTINGS=SettingsPage
}

local function createTab(text,icon,order)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(1,-10,0,42)
    button.Position=UDim2.new(
        0,
        5,
        0,
        (order-1)*47+5
    )
    button.BackgroundColor3=COLORS.Panel
    button.Text=icon.."  "..text
    button.TextSize=10
    button.Font=Enum.Font.GothamBold
    button.TextColor3=COLORS.SubText
    button.AutoButtonColor=false
    button.Parent=Tabs

    corner(button,10)

    return button
end

local TabHome=createTab("HOME","⌂",1)
local TabAuto=createTab("AUTO","◈",2)
local TabCharacter=createTab("CHAR","♙",3)
local TabChat=createTab("CHAT","◉",4)
local TabProfile=createTab("PROFILE","◎",5)
local TabSettings=createTab("SET","⚙",6)

local buttonMap={
    HOME=TabHome,
    ["AUTO WALK"]=TabAuto,
    CHARACTER=TabCharacter,
    CHAT=TabChat,
    PROFILE=TabProfile,
    SETTINGS=TabSettings
}

local function switchPage(name)
    local page=PagesMap[name]

    if not page then
        return
    end

    for pageName,currentPage in pairs(PagesMap) do
        currentPage.Visible=pageName==name
    end

    for _,child in ipairs(Tabs:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3=COLORS.Panel
            child.TextColor3=COLORS.SubText
        end
    end

    local selected=buttonMap[name]

    if selected then
        selected.BackgroundColor3=COLORS.Accent
        selected.TextColor3=COLORS.Text
    end
end

TabHome.Activated:Connect(function()
    switchPage("HOME")
end)

TabAuto.Activated:Connect(function()
    switchPage("AUTO WALK")
end)

TabCharacter.Activated:Connect(function()
    switchPage("CHARACTER")
end)

TabChat.Activated:Connect(function()
    switchPage("CHAT")
end)

TabProfile.Activated:Connect(function()
    switchPage("PROFILE")
end)

TabSettings.Activated:Connect(function()
    switchPage("SETTINGS")
end)

local function createSection(parent,title,description)
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,-8,0,64)
    frame.BackgroundColor3=COLORS.Panel
    frame.BorderSizePixel=0
    frame.Parent=parent
    corner(frame,12)

    local titleLabel=Instance.new("TextLabel")
    titleLabel.BackgroundTransparency=1
    titleLabel.Position=UDim2.new(0,13,0,8)
    titleLabel.Size=UDim2.new(1,-26,0,22)
    titleLabel.Font=Enum.Font.GothamBold
    titleLabel.Text=title
    titleLabel.TextSize=13
    titleLabel.TextColor3=COLORS.Text
    titleLabel.TextXAlignment=Enum.TextXAlignment.Left
    titleLabel.Parent=frame

    local desc=Instance.new("TextLabel")
    desc.BackgroundTransparency=1
    desc.Position=UDim2.new(0,13,0,31)
    desc.Size=UDim2.new(1,-26,0,20)
    desc.Font=Enum.Font.Gotham
    desc.Text=description or ""
    desc.TextSize=10
    desc.TextColor3=COLORS.SubText
    desc.TextXAlignment=Enum.TextXAlignment.Left
    desc.Parent=frame

    return frame
end

local function createButton(parent,text,callback)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(1,-8,0,42)
    button.BackgroundColor3=COLORS.Card
    button.Text=text
    button.TextSize=12
    button.Font=Enum.Font.GothamBold
    button.TextColor3=COLORS.Text
    button.AutoButtonColor=false
    button.Parent=parent

    corner(button,10)
    stroke(button,0.75)

    button.MouseEnter:Connect(function()
        local t=tween(
            button,
            {
                BackgroundColor3=COLORS.Accent
            },
            0.15
        )

        if t then
            t:Play()
        end
    end)

    button.MouseLeave:Connect(function()
        local t=tween(
            button,
            {
                BackgroundColor3=COLORS.Card
            },
            0.15
        )

        if t then
            t:Play()
        end
    end)

    button.Activated:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)

    return button
end

local function createToggle(parent,text,initial,callback)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(1,-8,0,42)
    button.BackgroundColor3=COLORS.Card
    button.Text=""
    button.AutoButtonColor=false
    button.Parent=parent

    corner(button,10)

    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Position=UDim2.new(0,13,0,0)
    label.Size=UDim2.new(1,-75,1,0)
    label.Font=Enum.Font.GothamBold
    label.Text=text
    label.TextSize=11
    label.TextColor3=COLORS.Text
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.Parent=button

    local state=initial==true

    local indicator=Instance.new("Frame")
    indicator.Size=UDim2.new(0,45,0,23)
    indicator.Position=UDim2.new(1,-57,0.5,-11)
    indicator.BackgroundColor3=
        state
        and COLORS.Success
        or Color3.fromRGB(55,57,70)
    indicator.Parent=button

    corner(indicator,20)

    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,17,0,17)
    dot.Position=
        state
        and UDim2.new(1,-20,0.5,-8)
        or UDim2.new(0,3,0.5,-8)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255)
    dot.Parent=indicator

    corner(dot,20)

    local function update()
        indicator.BackgroundColor3=
            state
            and COLORS.Success
            or Color3.fromRGB(55,57,70)

        local target=
            state
            and UDim2.new(1,-20,0.5,-8)
            or UDim2.new(0,3,0.5,-8)

        local t=tween(
            dot,
            {
                Position=target
            },
            0.15
        )

        if t then
            t:Play()
        else
            dot.Position=target
        end

        if callback then
            callback(state)
        end
    end

    button.Activated:Connect(function()
        state=not state
        update()
    end)

    return button
end

local function setAutoStatus(text,color)
    if not AutoStatus then
        return
    end

    AutoStatus.Text=text
    AutoStatus.TextColor3=color or COLORS.Success
end

local function vecToTable(v)
    return {
        X=v.X,
        Y=v.Y,
        Z=v.Z
    }
end

local function tableToVec(v)
    if type(v)~="table" then
        return Vector3.zero
    end

    return Vector3.new(
        tonumber(v.X) or 0,
        tonumber(v.Y) or 0,
        tonumber(v.Z) or 0
    )
end

local function getPointPosition(point)
    return tableToVec(point and point.Position)
end

local function getPointMove(point)
    local v=tableToVec(point and point.MoveDirection)

    local horizontal=Vector3.new(
        v.X,
        0,
        v.Z
    )

    if horizontal.Magnitude>1 then
        horizontal=horizontal.Unit
    end

    return horizontal
end

local function getPointLook(point)
    local v=tableToVec(point and point.Look)

    local horizontal=Vector3.new(
        v.X,
        0,
        v.Z
    )

    if horizontal.Magnitude<0.01 then
        return Vector3.zero
    end

    return horizontal.Unit
end

local function getPointTime(point)
    return tonumber(point and point.Time) or 0
end

local function isJumpState(point)
    local state=point and point.State

    return
        point and point.Jump==true
        or state=="Jumping"
        or state=="Freefall"
        or state=="FallingDown"
end

local function addRecordPoint(position,moveDirection,look,velocity,state,jump,timeValue)
    route[#route+1]={
        Time=timeValue,
        Position=vecToTable(position),
        MoveDirection=vecToTable(moveDirection),
        Look=vecToTable(look),
        Velocity=vecToTable(velocity),
        State=state.Name,
        Jump=jump==true
    }
end

local function recordCurrentSample(force)
    if not Root or not Root.Parent or not Humanoid then
        return
    end

    local now=os.clock()
    local elapsed=now-recordStart

    if not force and now-lastSampleTime<1/60 then
        return
    end

    lastSampleTime=now

    local position=Root.Position
    local moveDirection=Humanoid.MoveDirection
    local look=Root.CFrame.LookVector
    local velocity=Root.AssemblyLinearVelocity
    local state=Humanoid:GetState()

    local jump=
        state==Enum.HumanoidStateType.Jumping
        or (
            velocity.Y>6
            and Humanoid.FloorMaterial==Enum.Material.Air
        )

    local last=route[#route]

    if last and CONFIG.AntiJitter and not jump then
        local lastPosition=getPointPosition(last)
        local lastMove=getPointMove(last)
        local distance=(position-lastPosition).Magnitude
        local moveChange=(moveDirection-lastMove).Magnitude
        local stateChanged=last.State~=state.Name

        if distance<0.025
            and moveChange<0.025
            and not stateChanged
            and elapsed-getPointTime(last)<0.06
            and not force then
            return
        end
    end

    addRecordPoint(
        position,
        moveDirection,
        look,
        velocity,
        state,
        jump,
        elapsed
    )
end

local function startRecording()
    if isRecording or isPlaying then
        return
    end

    if not refreshCharacter() then
        setAutoStatus(
            "STATUS : CHARACTER NOT READY",
            COLORS.Warning
        )
        return
    end

    route={}
    jumpEvents={}
    playbackIndex=1
    playbackTime=0
    playbackJumpCursor=1

    isRecording=true
    recordStart=os.clock()
    lastSampleTime=0
    lastRecordState=Humanoid:GetState()

    recordCurrentSample(true)

    recordConnection=RunService.Heartbeat:Connect(function()
        if not isRecording then
            return
        end

        if not Root
            or not Root.Parent
            or not Humanoid
            or Humanoid.Health<=0 then
            stopRecording()
            return
        end

        local currentState=Humanoid:GetState()

        if currentState==Enum.HumanoidStateType.Jumping
            and lastRecordState~=Enum.HumanoidStateType.Jumping then
            jumpEvents[#jumpEvents+1]=os.clock()-recordStart
        end

        if Humanoid.Jump
            and Humanoid.FloorMaterial==Enum.Material.Air
            and lastRecordState~=Enum.HumanoidStateType.Jumping then
            jumpEvents[#jumpEvents+1]=os.clock()-recordStart
        end

        recordCurrentSample(false)

        lastRecordState=currentState
    end)

    setAutoStatus(
        "STATUS : RECORDING",
        COLORS.Warning
    )
end

local function findNearestForwardIndex(position,startIndex)
    if #route<2 then
        return 1
    end

    local bestIndex=math.clamp(
        startIndex or 1,
        1,
        #route
    )

    local bestDistance=math.huge

    local beginIndex=math.max(
        1,
        bestIndex-3
    )

    local endIndex=math.min(
        #route,
        bestIndex+24
    )

    for i=beginIndex,endIndex do
        local p=getPointPosition(route[i])

        local flatDistance=(
            Vector3.new(
                p.X,
                position.Y,
                p.Z
            )
            -
            Vector3.new(
                position.X,
                position.Y,
                position.Z
            )
        ).Magnitude

        if flatDistance<bestDistance then
            bestDistance=flatDistance
            bestIndex=i
        end
    end

    return bestIndex
end

local function advancePlaybackIndex(position)
    while playbackIndex<#route do
        local point=getPointPosition(route[playbackIndex])

        local distance=(
            Vector3.new(
                point.X,
                position.Y,
                point.Z
            )
            -
            Vector3.new(
                position.X,
                position.Y,
                position.Z
            )
        ).Magnitude

        if distance<=1.35 then
            playbackIndex+=1
        else
            break
        end
    end
end

local function getInterpolatedData(timeValue)
    if #route<2 then
        return nil
    end

    while playbackIndex<#route
        and getPointTime(route[playbackIndex+1])<=timeValue do
        playbackIndex+=1
    end

    local aIndex=math.clamp(
        playbackIndex,
        1,
        #route-1
    )

    local bIndex=aIndex+1

    local a=route[aIndex]
    local b=route[bIndex]

    local aTime=getPointTime(a)
    local bTime=getPointTime(b)

    local alpha=math.clamp(
        (timeValue-aTime)/
        math.max(bTime-aTime,0.001),
        0,
        1
    )

    local aPosition=getPointPosition(a)
    local bPosition=getPointPosition(b)

    local aMove=getPointMove(a)
    local bMove=getPointMove(b)

    local aLook=getPointLook(a)
    local bLook=getPointLook(b)

    local position=aPosition:Lerp(
        bPosition,
        alpha
    )

    local move=aMove:Lerp(
        bMove,
        alpha
    )

    local look=aLook:Lerp(
        bLook,
        alpha
    )

    local jump=
        isJumpState(a)
        or isJumpState(b)

    return {
        Position=position,
        MoveDirection=move,
        Look=look,
        Jump=jump,
        StateA=a.State,
        StateB=b.State,
        A=a,
        B=b
    }
end

local function triggerJump()
    if not Humanoid or Humanoid.Health<=0 then
        return
    end

    local state=Humanoid:GetState()

    if state==Enum.HumanoidStateType.Jumping
        or state==Enum.HumanoidStateType.Freefall then
        return
    end

    pcall(function()
        Humanoid.Jump=true
    end)
end

local function processJumpEvents(previousTime,currentTime)
    while playbackJumpCursor<=#jumpEvents do
        local eventTime=jumpEvents[playbackJumpCursor]

        if eventTime>currentTime then
            break
        end

        if eventTime>=previousTime-0.02 then
            triggerJump()
        end

        playbackJumpCursor+=1
    end
end

local function startPlayback()
    if isPlaying or isRecording then
        return
    end

    if #route<2 then
        setAutoStatus(
            "STATUS : ROUTE TERLALU PENDEK",
            COLORS.Warning
        )
        return
    end

    if not refreshCharacter() then
        setAutoStatus(
            "STATUS : CHARACTER NOT READY",
            COLORS.Warning
        )
        return
    end

    local firstTime=getPointTime(route[1])

    if firstTime>0 then
        for i=1,#route do
            route[i].Time=getPointTime(route[i])-firstTime
        end
    end

    playbackTime=0
    playbackIndex=1
    playbackJumpCursor=1
    isPlaying=true

    setAutoStatus(
        "STATUS : PLAYING",
        COLORS.Success
    )

    pcall(function()
        RunService:UnbindFromRenderStep(PLAYBACK_BIND)
    end)

    RunService:BindToRenderStep(
        PLAYBACK_BIND,
        Enum.RenderPriority.Character.Value+10,
        function(dt)
            if not isPlaying then
                return
            end

            if not Root
                or not Root.Parent
                or not Humanoid
                or not Humanoid.Parent
                or Humanoid.Health<=0 then
                stopPlayback()
                return
            end

            local safeDt=math.clamp(
                dt,
                0,
                0.12
            )

            local previousTime=playbackTime

            playbackTime+=safeDt

            local totalTime=getPointTime(
                route[#route]
            )

            if playbackTime>=totalTime then
                local finalPoint=route[#route]
                local finalMove=getPointMove(finalPoint)

                if finalMove.Magnitude<0.02 then
                    finalMove=getPointLook(finalPoint)
                end

                if finalMove.Magnitude>0.02 then
                    pcall(function()
                        Humanoid:Move(
                            finalMove.Unit,
                            false
                        )
                    end)
                else
                    pcall(function()
                        Humanoid:Move(
                            Vector3.zero,
                            false
                        )
                    end)
                end

                if isJumpState(finalPoint) then
                    triggerJump()
                end

                stopPlayback()
                return
            end

            processJumpEvents(
                previousTime,
                playbackTime
            )

            local sample=getInterpolatedData(
                playbackTime
            )

            if not sample then
                stopPlayback()
                return
            end

            advancePlaybackIndex(
                Root.Position
            )

            local currentPosition=Root.Position
            local targetPosition=sample.Position

            local toTarget=Vector3.new(
                targetPosition.X-currentPosition.X,
                0,
                targetPosition.Z-currentPosition.Z
            )

            local targetDirection=Vector3.zero

            if toTarget.Magnitude>0.05 then
                targetDirection=toTarget.Unit
            end

            local recordedDirection=Vector3.new(
                sample.MoveDirection.X,
                0,
                sample.MoveDirection.Z
            )

            if recordedDirection.Magnitude>1 then
                recordedDirection=recordedDirection.Unit
            end

            if targetDirection.Magnitude<0.05 then
                targetDirection=recordedDirection
            elseif recordedDirection.Magnitude>0.05 then
                local blend=CONFIG.NaturalAnimation
                    and 0.38
                    or 0.18

                targetDirection=(
                    targetDirection*(1-blend)
                    +
                    recordedDirection*blend
                )

                if targetDirection.Magnitude>0.01 then
                    targetDirection=targetDirection.Unit
                end
            end

            local nextIndex=math.min(
                playbackIndex+2,
                #route
            )

            local nextPoint=route[nextIndex]

            if nextPoint then
                local nextPosition=getPointPosition(
                    nextPoint
                )

                local lookAhead=Vector3.new(
                    nextPosition.X-currentPosition.X,
                    0,
                    nextPosition.Z-currentPosition.Z
                )

                if lookAhead.Magnitude>0.05 then
                    local lead=CONFIG.AntiJitter
                        and 0.24
                        or 0.12

                    targetDirection=(
                        targetDirection*(1-lead)
                        +
                        lookAhead.Unit*lead
                    )

                    if targetDirection.Magnitude>0.01 then
                        targetDirection=targetDirection.Unit
                    end
                end
            end

            if CONFIG.AntiOutTrack then
                local errorVector=Vector3.new(
                    targetPosition.X-currentPosition.X,
                    0,
                    targetPosition.Z-currentPosition.Z
                )

                local errorDistance=errorVector.Magnitude

                if errorDistance>3 then
                    local recoveryStrength=math.clamp(
                        (errorDistance-2)/16,
                        0,
                        0.55
                    )

                    if errorVector.Magnitude>0.01 then
                        targetDirection=(
                            targetDirection*
                            (1-recoveryStrength)
                            +
                            errorVector.Unit*
                            recoveryStrength
                        )

                        if targetDirection.Magnitude>0.01 then
                            targetDirection=targetDirection.Unit
                        end
                    end
                end

                if errorDistance>22 then
                    playbackIndex=findNearestForwardIndex(
                        currentPosition,
                        playbackIndex
                    )
                end
            end

            local segmentStart=getPointPosition(
                sample.A
            )

            local segmentEnd=getPointPosition(
                sample.B
            )

            local segmentDistance=(
                segmentEnd-segmentStart
            ).Magnitude

            local segmentTime=math.max(
                getPointTime(sample.B)-
                getPointTime(sample.A),
                0.03
            )

            local requiredSpeed=segmentDistance/segmentTime

            requiredSpeed=math.clamp(
                requiredSpeed,
                4,
                36
            )

            if CONFIG.WalkSpeed>0 then
                requiredSpeed=math.max(
                    requiredSpeed,
                    CONFIG.WalkSpeed
                )
            end

            Humanoid.WalkSpeed=requiredSpeed

            if targetDirection.Magnitude>0.02 then
                pcall(function()
                    Humanoid:Move(
                        targetDirection,
                        false
                    )
                end)
            else
                pcall(function()
                    Humanoid:Move(
                        Vector3.zero,
                        false
                    )
                end)
            end

            local currentState=Humanoid:GetState()

            if sample.Jump
                and currentState~=Enum.HumanoidStateType.Jumping
                and currentState~=Enum.HumanoidStateType.Freefall
                and currentState~=Enum.HumanoidStateType.FallingDown then

                local heightDifference=
                    targetPosition.Y-currentPosition.Y

                if heightDifference>1.7 then
                    triggerJump()
                end
            end

            local waypointDistance=(
                Vector3.new(
                    currentPosition.X,
                    0,
                    currentPosition.Z
                )
                -
                Vector3.new(
                    targetPosition.X,
                    0,
                    targetPosition.Z
                )
            ).Magnitude

            if waypointDistance<=1.25 then
                playbackIndex=math.min(
                    playbackIndex+1,
                    #route
                )
            end
        end
    )

    playbackHeartbeat=RunService.Heartbeat:Connect(function()
        if not isPlaying then
            return
        end

        if not Humanoid
            or not Humanoid.Parent
            or Humanoid.Health<=0 then
            stopPlayback()
            return
        end

        if Humanoid.PlatformStand then
            Humanoid.PlatformStand=false
        end

        if Humanoid.WalkSpeed<1 then
            Humanoid.WalkSpeed=16
        end
    end)
end

local function cutRoute()
    if #route<2 then
        setAutoStatus(
            "STATUS : ROUTE KOSONG",
            COLORS.Warning
        )
        return
    end

    if isRecording then
        stopRecording()
    end

    if isPlaying then
        stopPlayback()
    end

    local cutIndex=math.clamp(
        playbackIndex,
        1,
        #route
    )

    local newRoute={}

    for i=1,cutIndex do
        newRoute[#newRoute+1]=route[i]
    end

    route=newRoute
    playbackIndex=1
    playbackTime=0

    jumpEvents={}

    setAutoStatus(
        "STATUS : CUT • "..tostring(#route).." POINTS",
        COLORS.Warning
    )
end

local function connectRoute()
    if #route<2 then
        setAutoStatus(
            "STATUS : ROUTE TERLALU PENDEK",
            COLORS.Warning
        )
        return
    end

    local first=route[1]
    local last=route[#route]

    local firstPosition=getPointPosition(first)
    local lastPosition=getPointPosition(last)

    local distance=(
        lastPosition-firstPosition
    ).Magnitude

    if distance<0.05 then
        setAutoStatus(
            "STATUS : ROUTE SUDAH TERHUBUNG",
            COLORS.Warning
        )
        return
    end

    local lastTime=getPointTime(last)

    route[#route+1]={
        Time=lastTime+
            math.max(
                distance/
                math.max(CONFIG.WalkSpeed>0 and CONFIG.WalkSpeed or 16,1),
                0.03
            ),
        Position={
            X=firstPosition.X,
            Y=firstPosition.Y,
            Z=firstPosition.Z
        },
        MoveDirection=first.MoveDirection,
        Look=first.Look,
        Velocity={
            X=0,
            Y=0,
            Z=0
        },
        State="Running",
        Jump=false
    }

    setAutoStatus(
        "STATUS : ROUTE CONNECTED • "..tostring(#route).." POINTS",
        COLORS.Success
    )
end

createSection(
    HomePage,
    "BERANDA",
    "VORA ZURE • Mobile control center"
)

createButton(
    HomePage,
    "⚡ LOAD SCRIPT",
    function()
        setAutoStatus(
            "STATUS : AUTO WALK READY",
            COLORS.Success
        )
        switchPage("AUTO WALK")
    end
)

createSection(
    HomePage,
    "PLAYER",
    "Informasi pemain aktif"
)

createButton(
    HomePage,
    "👤 "..LocalPlayer.DisplayName,
    function()
        switchPage("PROFILE")
    end
)

createButton(
    HomePage,
    "⚙ CHARACTER SETTINGS",
    function()
        switchPage("CHARACTER")
    end
)

createSection(
    AutoPage,
    "MAIN AUTO WALK",
    "Record dan playback rute"
)

AutoStatus=Instance.new("TextLabel")
AutoStatus.Size=UDim2.new(1,-8,0,32)
AutoStatus.BackgroundColor3=COLORS.Panel
AutoStatus.Text="STATUS : IDLE"
AutoStatus.Font=Enum.Font.GothamBold
AutoStatus.TextSize=11
AutoStatus.TextColor3=COLORS.Success
AutoStatus.Parent=AutoPage
corner(AutoStatus,10)

createButton(
    AutoPage,
    "● RECORD",
    startRecording
)

createButton(
    AutoPage,
    "■ STOP",
    function()
        stopRecording()
        stopPlayback()
    end
)

createButton(
    AutoPage,
    "▶ PLAY",
    startPlayback
)

createButton(
    AutoPage,
    "✂ CUT ROUTE",
    cutRoute
)

createButton(
    AutoPage,
    "↔ CONNECT ROUTE",
    connectRoute
)

createButton(
    AutoPage,
    "↻ REFRESH PLAY ANIMATION",
    function()
        if isPlaying then
            local savedTime=playbackTime
            stopPlayback()
            playbackTime=savedTime
            task.wait()
            startPlayback()
        else
            playbackTime=0
            playbackIndex=1
            setAutoStatus(
                "STATUS : PLAYBACK REFRESHED",
                COLORS.Success
            )
        end
    end
)

createSection(
    AutoPage,
    "FILE",
    "Route persistence"
)

createButton(
    AutoPage,
    "💾 SAVE FILE",
    function()
        savedRoutes.Main=route
        saveRoutes()

        setAutoStatus(
            "STATUS : ROUTE SAVED",
            COLORS.Success
        )
    end
)

createButton(
    AutoPage,
    "📂 LOAD FILE",
    function()
        if type(savedRoutes.Main)~="table"
            or #savedRoutes.Main<2 then

            setAutoStatus(
                "STATUS : FILE TIDAK DITEMUKAN",
                COLORS.Warning
            )
            return
        end

        stopRecording()
        stopPlayback()

        route=savedRoutes.Main
        playbackIndex=1
        playbackTime=0

        setAutoStatus(
            "STATUS : ROUTE LOADED • "
            ..tostring(#route)
            .." POINTS",
            COLORS.Success
        )
    end
)

createButton(
    AutoPage,
    "🗑 REMOVE FILE",
    function()
        savedRoutes.Main=nil
        safeDeleteFile(ROUTE_FILE)

        route={}
        jumpEvents={}
        playbackIndex=1
        playbackTime=0

        setAutoStatus(
            "STATUS : FILE REMOVED",
            COLORS.Danger
        )
    end
)

createSection(
    AutoPage,
    "PLAYBACK PROTECTION",
    "Stability system"
)

createToggle(
    AutoPage,
    "NATURAL ANIMASI PLAY",
    CONFIG.NaturalAnimation,
    function(v)
        CONFIG.NaturalAnimation=v
        saveConfig()
    end
)

createToggle(
    AutoPage,
    "ANTI JITTER",
    CONFIG.AntiJitter,
    function(v)
        CONFIG.AntiJitter=v
        saveConfig()
    end
)

createToggle(
    AutoPage,
    "ANTI GLITCH",
    CONFIG.AntiGlitch,
    function(v)
        CONFIG.AntiGlitch=v
        saveConfig()
    end
)

createToggle(
    AutoPage,
    "ANTI LAG",
    CONFIG.AntiLag,
    function(v)
        CONFIG.AntiLag=v
        saveConfig()
    end
)

createToggle(
    AutoPage,
    "ANTI OUT TRACK",
    CONFIG.AntiOutTrack,
    function(v)
        CONFIG.AntiOutTrack=v
        saveConfig()
    end
)

Floating=Instance.new("Frame")
Floating.Size=UDim2.new(0,300,0,62)
Floating.Position=UDim2.new(
    0.5,
    -150,
    1,
    -82
)
Floating.BackgroundColor3=COLORS.Panel
Floating.BorderSizePixel=0
Floating.Parent=ScreenGui
Floating.ZIndex=25

corner(Floating,18)
stroke(Floating,0.35)

local floatingLayout=Instance.new("UIListLayout")
floatingLayout.FillDirection=Enum.FillDirection.Horizontal
floatingLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
floatingLayout.VerticalAlignment=Enum.VerticalAlignment.Center
floatingLayout.Padding=UDim.new(0,5)
floatingLayout.Parent=Floating

local function floatingButton(text,callback)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(0,38,0,44)
    button.BackgroundColor3=COLORS.Card
    button.Text=text
    button.TextSize=14
    button.Font=Enum.Font.GothamBold
    button.TextColor3=COLORS.Text
    button.AutoButtonColor=false
    button.Parent=Floating
    button.ZIndex=26

    corner(button,11)
    stroke(button,0.7)

    button.Activated:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)

    return button
end

floatingButton(
    "▶",
    startPlayback
)

floatingButton(
    "●",
    startRecording
)

floatingButton(
    "■",
    function()
        stopRecording()
        stopPlayback()
    end
)

floatingButton(
    "✂",
    cutRoute
)

floatingButton(
    "↔",
    connectRoute
)

floatingButton(
    "‹",
    function()
        if #route==0 then
            return
        end

        playbackIndex=math.max(
            1,
            playbackIndex-1
        )

        if route[playbackIndex] then
            playbackTime=getPointTime(
                route[playbackIndex]
            )
        end
    end
)

floatingButton(
    "›",
    function()
        if #route==0 then
            return
        end

        playbackIndex=math.min(
            #route,
            playbackIndex+1
        )

        if route[playbackIndex] then
            playbackTime=getPointTime(
                route[playbackIndex]
            )
        end
    end
)

createSection(
    CharacterPage,
    "CHARACTER",
    "Character control"
)

SpeedValue=Instance.new("TextLabel")
SpeedValue.Size=UDim2.new(1,-8,0,38)
SpeedValue.BackgroundColor3=COLORS.Panel
SpeedValue.Text=
    "WALK SPEED SET : "
    ..tostring(CONFIG.WalkSpeed)
SpeedValue.Font=Enum.Font.GothamBold
SpeedValue.TextSize=12
SpeedValue.TextColor3=COLORS.Text
SpeedValue.Parent=CharacterPage
corner(SpeedValue,10)

createButton(
    CharacterPage,
    "WALK SPEED +5",
    function()
        CONFIG.WalkSpeed+=5

        if Humanoid and not isPlaying then
            Humanoid.WalkSpeed=CONFIG.WalkSpeed
        end

        SpeedValue.Text=
            "WALK SPEED SET : "
            ..tostring(CONFIG.WalkSpeed)

        saveConfig()
    end
)

createButton(
    CharacterPage,
    "WALK SPEED -5",
    function()
        CONFIG.WalkSpeed=math.max(
            0,
            CONFIG.WalkSpeed-5
        )

        if Humanoid and not isPlaying then
            Humanoid.WalkSpeed=
                CONFIG.WalkSpeed>0
                and CONFIG.WalkSpeed
                or 16
        end

        SpeedValue.Text=
            "WALK SPEED SET : "
            ..tostring(CONFIG.WalkSpeed)

        saveConfig()
    end
)

JumpValue=Instance.new("TextLabel")
JumpValue.Size=UDim2.new(1,-8,0,38)
JumpValue.BackgroundColor3=COLORS.Panel
JumpValue.Text=
    "JUMP SET : "
    ..tostring(CONFIG.JumpPower)
JumpValue.Font=Enum.Font.GothamBold
JumpValue.TextSize=12
JumpValue.TextColor3=COLORS.Text
JumpValue.Parent=CharacterPage
corner(JumpValue,10)

createButton(
    CharacterPage,
    "JUMP +10",
    function()
        CONFIG.JumpPower+=10

        if Humanoid and Humanoid.UseJumpPower then
            Humanoid.JumpPower=CONFIG.JumpPower
        end

        JumpValue.Text=
            "JUMP SET : "
            ..tostring(CONFIG.JumpPower)

        saveConfig()
    end
)

createButton(
    CharacterPage,
    "JUMP -10",
    function()
        CONFIG.JumpPower=math.max(
            0,
            CONFIG.JumpPower-10
        )

        if Humanoid and Humanoid.UseJumpPower then
            Humanoid.JumpPower=CONFIG.JumpPower
        end

        JumpValue.Text=
            "JUMP SET : "
            ..tostring(CONFIG.JumpPower)

        saveConfig()
    end
)

createSection(
    CharacterPage,
    "TO PLAYER",
    "Select target player"
)

local PlayerList=Instance.new("Frame")
PlayerList.Size=UDim2.new(1,-8,0,180)
PlayerList.BackgroundColor3=COLORS.Panel
PlayerList.BorderSizePixel=0
PlayerList.Parent=CharacterPage
corner(PlayerList)

local PlayerScroll=Instance.new("ScrollingFrame")
PlayerScroll.Size=UDim2.new(1,-10,1,-10)
PlayerScroll.Position=UDim2.new(0,5,0,5)
PlayerScroll.BackgroundTransparency=1
PlayerScroll.BorderSizePixel=0
PlayerScroll.ScrollBarThickness=3
PlayerScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
PlayerScroll.CanvasSize=UDim2.new()
PlayerScroll.Parent=PlayerList

local playerLayout=Instance.new("UIListLayout")
playerLayout.Padding=UDim.new(0,5)
playerLayout.SortOrder=Enum.SortOrder.LayoutOrder
playerLayout.Parent=PlayerScroll

local function refreshPlayerList()
    for _,child in ipairs(
        PlayerScroll:GetChildren()
    ) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _,player in ipairs(
        Players:GetPlayers()
    ) do
        if player~=LocalPlayer then
            local button=Instance.new("TextButton")
            button.Size=UDim2.new(1,-5,0,34)
            button.BackgroundColor3=COLORS.Card
            button.Text=
                player.DisplayName
                .."  @"
                ..player.Name
            button.TextSize=10
            button.Font=Enum.Font.GothamBold
            button.TextColor3=COLORS.Text
            button.AutoButtonColor=false
            button.Parent=PlayerScroll
            corner(button,8)

            button.Activated:Connect(
                function()
                    selectedPlayer=player

                    local targetCharacter=
                        player.Character

                    local targetRoot=
                        targetCharacter
                        and targetCharacter:
                            FindFirstChild(
                                "HumanoidRootPart"
                            )

                    if targetRoot
                        and refreshCharacter() then

                        Root.CFrame=
                            targetRoot.CFrame*
                            CFrame.new(0,0,3)
                    end
                end
            )
        end
    end
end

refreshPlayerList()

Players.PlayerAdded:Connect(
    refreshPlayerList
)

Players.PlayerRemoving:Connect(
    function(player)
        if selectedPlayer==player then
            selectedPlayer=nil
        end

        refreshPlayerList()
    end
)

createButton(
    CharacterPage,
    "↻ REFRESH PLAYER LIST",
    refreshPlayerList
)

createSection(
    CharacterPage,
    "SPECTATE PLAYER",
    "Camera follows selected player"
)

createButton(
    CharacterPage,
    "SPECTATE SELECTED",
    function()
        if not selectedPlayer then
            return
        end

        local targetCharacter=
            selectedPlayer.Character

        local targetHumanoid=
            targetCharacter
            and targetCharacter:
                FindFirstChildOfClass(
                    "Humanoid"
                )

        local camera=
            workspace.CurrentCamera

        if targetHumanoid and camera then
            camera.CameraSubject=targetHumanoid
            spectating=true
        end
    end
)

createButton(
    CharacterPage,
    "STOP SPECTATE",
    function()
        spectating=false
        refreshCharacter()

        local camera=
            workspace.CurrentCamera

        if camera and Humanoid then
            camera.CameraSubject=Humanoid
        end
    end
)

local function setAntiAFK(enabled)
    CONFIG.AntiAFK=enabled

    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection=nil
    end

    if enabled then
        antiAFKConnection=
            LocalPlayer.Idled:Connect(
                function()
                    if not CONFIG.AntiAFK then
                        return
                    end

                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(
                            Vector2.new(0,0)
                        )
                    end)
                end
            )
    end

    saveConfig()
end

createToggle(
    CharacterPage,
    "ANTI AFK",
    CONFIG.AntiAFK,
    setAntiAFK
)

createSection(
    ChatPage,
    "GLOBAL CHAT",
    "Roblox online chat"
)

local ChatBox=Instance.new("ScrollingFrame")
ChatBox.Size=UDim2.new(1,-8,0,250)
ChatBox.BackgroundColor3=COLORS.Panel
ChatBox.BorderSizePixel=0
ChatBox.ScrollBarThickness=3
ChatBox.AutomaticCanvasSize=Enum.AutomaticSize.Y
ChatBox.CanvasSize=UDim2.new()
ChatBox.Parent=ChatPage
corner(ChatBox,12)

local ChatLayout=Instance.new("UIListLayout")
ChatLayout.Padding=UDim.new(0,5)
ChatLayout.Parent=ChatBox

local MessageInput=Instance.new("TextBox")
MessageInput.Size=UDim2.new(1,-8,0,42)
MessageInput.BackgroundColor3=COLORS.Card
MessageInput.PlaceholderText="Kirim pesan..."
MessageInput.Text=""
MessageInput.TextSize=11
MessageInput.Font=Enum.Font.Gotham
MessageInput.TextColor3=COLORS.Text
MessageInput.PlaceholderColor3=COLORS.SubText
MessageInput.ClearTextOnFocus=false
MessageInput.Parent=ChatPage
corner(MessageInput,10)

createButton(
    ChatPage,
    "SEND MESSAGE",
    function()
        local message=MessageInput.Text

        if message=="" then
            return
        end

        local sent=false

        pcall(function()
            local channels=
                TextChatService:
                FindFirstChild(
                    "TextChannels"
                )

            if not channels then
                return
            end

            local general=
                channels:
                FindFirstChild(
                    "RBXGeneral"
                )

            if general then
                general:SendAsync(message)
                sent=true
            end
        end)

        if sent then
            MessageInput.Text=""
        end
    end
)

createSection(
    ProfilePage,
    "PROFIL",
    "@VORA ZURE"
)

createButton(
    ProfilePage,
    "@VORA ZURE : APA YANG ANDA LAKUKAN?",
    function()
        print(
            "@VORA ZURE > @ALDO : SEDANG BERMAIN"
        )
    end
)

createButton(
    ProfilePage,
    "@ALDO > @VORA ZURE : SEDANG BERMAIN",
    function()
        print(
            "VORA ZURE > ALDO : BERMAIN APA?"
        )
    end
)

createButton(
    ProfilePage,
    "@AZURE > @ALDO : BERMAIN APA?",
    function()
        print(
            "AZURE > ALDO : BERMAIN APA?"
        )
    end
)

createSection(
    SettingsPage,
    "SETTING",
    "Preferensi VORA ZURE"
)

LanguageButton=createButton(
    SettingsPage,
    "BAHASA : "
        ..tostring(CONFIG.Language),
    function()
        CONFIG.Language=
            CONFIG.Language=="Indonesia"
            and "English"
            or "Indonesia"

        LanguageButton.Text=
            "BAHASA : "
            ..tostring(CONFIG.Language)

        saveConfig()
    end
)

createSection(
    SettingsPage,
    "THEMA UI",
    "Animated gradient"
)

local gradientNames={
    "ANIM GRADIENT : DEFAULT",
    "ANIM GRADIENT 1",
    "ANIM GRADIENT 2",
    "ANIM GRADIENT 3",
    "ANIM GRADIENT 4"
}

for index,name in ipairs(
    gradientNames
) do
    createButton(
        SettingsPage,
        name,
        function()
            CONFIG.Gradient=index-1
            selectedGradient=index-1
            applyGradient()
            saveConfig()
        end
    )
end

createSection(
    SettingsPage,
    "SYSTEM",
    "VORA ZURE diagnostics"
)

createButton(
    SettingsPage,
    "REFRESH CHARACTER",
    function()
        if refreshCharacter() and Humanoid then
            Humanoid.WalkSpeed=
                CONFIG.WalkSpeed>0
                and CONFIG.WalkSpeed
                or 16

            if Humanoid.UseJumpPower then
                Humanoid.JumpPower=
                    CONFIG.JumpPower
            end
        end
    end
)

createButton(
    SettingsPage,
    "RESET CONFIG",
    function()
        stopRecording()
        stopPlayback()

        CONFIG.Language="Indonesia"
        CONFIG.Gradient=0
        CONFIG.WalkSpeed=0
        CONFIG.JumpPower=50
        CONFIG.AntiAFK=false
        CONFIG.NaturalAnimation=true
        CONFIG.AntiJitter=true
        CONFIG.AntiGlitch=true
        CONFIG.AntiLag=true
        CONFIG.AntiOutTrack=true

        selectedGradient=0

        setAntiAFK(false)
        applyGradient()
        refreshCharacter()

        if Humanoid then
            Humanoid.WalkSpeed=16

            if Humanoid.UseJumpPower then
                Humanoid.JumpPower=50
            end
        end

        if SpeedValue then
            SpeedValue.Text=
                "WALK SPEED SET : 0"
        end

        if JumpValue then
            JumpValue.Text=
                "JUMP SET : 50"
        end

        if LanguageButton then
            LanguageButton.Text=
                "BAHASA : Indonesia"
        end

        saveConfig()

        setAutoStatus(
            "STATUS : CONFIG RESET",
            COLORS.Success
        )
    end
)

OpenButton=Instance.new("TextButton")
OpenButton.Name="OpenButton"
OpenButton.Size=UDim2.new(0,70,0,70)
OpenButton.Position=UDim2.new(0,18,0.5,-35)
OpenButton.BackgroundColor3=COLORS.Accent
OpenButton.Text="👑"
OpenButton.TextSize=29
OpenButton.Font=Enum.Font.GothamBold
OpenButton.TextColor3=COLORS.Text
OpenButton.AutoButtonColor=false
OpenButton.Parent=ScreenGui
corner(OpenButton,22)
stroke(OpenButton,0.25)

local dragging=false
local dragStart
local startPosition

local function setMenu(state)
    menuOpen=state

    if menuTween then
        pcall(function()
            menuTween:Cancel()
        end)
        menuTween=nil
    end

    if state then
        Main.Visible=true
        Main.Size=
            UDim2.new(
                0,
                390,
                0,
                0
            )

        menuTween=tween(
            Main,
            {
                Size=
                    UDim2.new(
                        0,
                        390,
                        0,
                        590
                    )
            },
            0.25
        )

        if menuTween then
            menuTween:Play()
        else
            Main.Size=
                UDim2.new(
                    0,
                    390,
                    0,
                    590
                )
        end
    else
        menuTween=tween(
            Main,
            {
                Size=
                    UDim2.new(
                        0,
                        390,
                        0,
                        0
                    )
            },
            0.2
        )

        if menuTween then
            local active=menuTween

            active.Completed:Connect(
                function()
                    if not menuOpen
                        and Main
                        and Main.Parent then
                        Main.Visible=false
                    end
                end
            )

            active:Play()
        else
            Main.Visible=false
        end
    end
end

OpenButton.InputBegan:Connect(
    function(input)
        if input.UserInputType==
            Enum.UserInputType.Touch
            or input.UserInputType==
                Enum.UserInputType.MouseButton1 then

            dragging=true
            dragMoved=false
            dragStart=input.Position
            startPosition=
                OpenButton.Position

            input.Changed:Connect(
                function()
                    if input.UserInputState==
                        Enum.UserInputState.End then
                        dragging=false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)
        if not dragging then
            return
        end

        if input.UserInputType~=
            Enum.UserInputType.Touch
            and input.UserInputType~=
                Enum.UserInputType.MouseMovement then
            return
        end

        local delta=
            input.Position-dragStart

        if delta.Magnitude>8 then
            dragMoved=true
        end

        local camera=
            workspace.CurrentCamera

        local viewport=
            camera
            and camera.ViewportSize
            or Vector2.new(800,600)

        local buttonSize=
            OpenButton.AbsoluteSize

        local newX=
            startPosition.X.Offset+
            delta.X

        local newY=
            startPosition.Y.Offset+
            delta.Y

        newX=math.clamp(
            newX,
            0,
            math.max(
                0,
                viewport.X-buttonSize.X
            )
        )

        newY=math.clamp(
            newY,
            0,
            math.max(
                0,
                viewport.Y-buttonSize.Y
            )
        )

        OpenButton.Position=
            UDim2.new(
                0,
                newX,
                0,
                newY
            )
    end
)

OpenButton.Activated:Connect(
    function()
        if dragMoved then
            dragMoved=false
            return
        end

        setMenu(not menuOpen)
    end
)

local lastFrame=os.clock()
local frameCounter=0

RunService.RenderStepped:Connect(
    function()
        frameCounter+=1

        local now=os.clock()

        if now-lastFrame>=1 then
            FPSLabel.Text=
                "FPS "
                ..tostring(frameCounter)

            frameCounter=0
            lastFrame=now

            local ping=0

            pcall(
                function()
                    ping=math.floor(
                        LocalPlayer:
                        GetNetworkPing()*
                        1000
                    )
                end
            )

            PingLabel.Text=
                "PING "
                ..tostring(ping)
        end
    end
)

RunService.Heartbeat:Connect(
    function()
        if not Character
            or not Character.Parent
            or not Humanoid
            or not Root
            or not Root.Parent then
            return
        end

        if not isPlaying
            and CONFIG.WalkSpeed>0 then

            if Humanoid.WalkSpeed~=
                CONFIG.WalkSpeed then
                Humanoid.WalkSpeed=
                    CONFIG.WalkSpeed
            end
        end

        if not isPlaying
            and Humanoid.UseJumpPower then

            if Humanoid.JumpPower~=
                CONFIG.JumpPower then
                Humanoid.JumpPower=
                    CONFIG.JumpPower
            end
        end

        if CONFIG.AntiGlitch
            and not isPlaying
            and Root.Position.Y<-500 then

            Root.AssemblyLinearVelocity=
                Vector3.zero

            Root.CFrame=
                CFrame.new(
                    Root.Position.X,
                    10,
                    Root.Position.Z
                )
        end
    end
)

if CONFIG.AntiAFK then
    setAntiAFK(true)
end

switchPage("HOME")
setMenu(true)
