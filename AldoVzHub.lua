local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local VirtualUser=game:GetService("VirtualUser")
local Stats=game:GetService("Stats")
local Workspace=game:GetService("Workspace")
local StarterGui=game:GetService("StarterGui")
local CoreGui=game:GetService("CoreGui")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")

local function protect(fn,...)
    local ok,a,b,c=pcall(fn,...)
    return ok,a,b,c
end

local function notify(title,text,duration)
    protect(function()
        StarterGui:SetCore("SendNotification",{
            Title=title,
            Text=text,
            Duration=duration or 1.5
        })
    end)
end

local CONFIG_FILE="AldoVzConfig.json"
local ROUTE_FILE="AldoVzRoute.json"

local Config={
    walkSpeed=50,
    jumpPower=100,
    safeY=-40,
    antiAfk=true,
    smartJump=true,
    colors={
        main={
            Color3.fromRGB(90,10,190),
            Color3.fromRGB(200,0,160),
            Color3.fromRGB(0,160,220)
        },
        float={
            Color3.fromRGB(150,0,255),
            Color3.fromRGB(255,0,200),
            Color3.fromRGB(0,200,255)
        },
        stroke={
            Color3.fromRGB(180,0,255),
            Color3.fromRGB(255,0,200),
            Color3.fromRGB(0,220,255)
        },
        on=Color3.fromRGB(0,210,100),
        off=Color3.fromRGB(20,16,38)
    }
}

local function colorToTable(c)
    return {
        r=math.floor(c.R*255+0.5),
        g=math.floor(c.G*255+0.5),
        b=math.floor(c.B*255+0.5)
    }
end

local function tableToColor(t,fallback)
    fallback=fallback or Color3.fromRGB(150,0,255)
    if type(t)~="table" then
        return fallback
    end

    return Color3.fromRGB(
        math.clamp(math.floor(tonumber(t.r) or 0),0,255),
        math.clamp(math.floor(tonumber(t.g) or 0),0,255),
        math.clamp(math.floor(tonumber(t.b) or 0),0,255)
    )
end

local function loadConfig()
    if type(readfile)~="function" then
        return
    end

    protect(function()
        if type(isfile)=="function" and not isfile(CONFIG_FILE) then
            return
        end

        local raw=readfile(CONFIG_FILE)
        local data=HttpService:JSONDecode(raw)

        if type(data)~="table" then
            return
        end

        if type(data.walkSpeed)=="number" then
            Config.walkSpeed=data.walkSpeed
        end

        if type(data.jumpPower)=="number" then
            Config.jumpPower=data.jumpPower
        end

        if type(data.safeY)=="number" then
            Config.safeY=data.safeY
        end

        if data.antiAfk~=nil then
            Config.antiAfk=data.antiAfk==true
        end

        if data.smartJump~=nil then
            Config.smartJump=data.smartJump==true
        end
    end)
end

local function saveConfig()
    if type(writefile)~="function" then
        return
    end

    protect(function()
        writefile(
            CONFIG_FILE,
            HttpService:JSONEncode({
                walkSpeed=Config.walkSpeed,
                jumpPower=Config.jumpPower,
                safeY=Config.safeY,
                antiAfk=Config.antiAfk,
                smartJump=Config.smartJump,
                colors={
                    main={
                        colorToTable(Config.colors.main[1]),
                        colorToTable(Config.colors.main[2]),
                        colorToTable(Config.colors.main[3])
                    },
                    float={
                        colorToTable(Config.colors.float[1]),
                        colorToTable(Config.colors.float[2]),
                        colorToTable(Config.colors.float[3])
                    },
                    stroke={
                        colorToTable(Config.colors.stroke[1]),
                        colorToTable(Config.colors.stroke[2]),
                        colorToTable(Config.colors.stroke[3])
                    },
                    on=colorToTable(Config.colors.on),
                    off=colorToTable(Config.colors.off)
                }
            })
        )
    end)
end

loadConfig()

local State={
    autoWalk=false,
    autoClick=false,
    antiAfk=Config.antiAfk,
    smartJump=Config.smartJump,
    speedBypass=false,
    playerEsp=false,
    itemEsp=false,
    magnet=false,
    routePlay=false,
    recording=false
}

local Connections={}
local Threads={}

local function connect(c)
    if c then
        Connections[#Connections+1]=c
    end
    return c
end

local function disconnect(c)
    if c then
        protect(function()
            c:Disconnect()
        end)
    end
end

local function cancelThread(t)
    if t then
        protect(function()
            task.cancel(t)
        end)
    end
end

local function clearConnections()
    for i=#Connections,1,-1 do
        disconnect(Connections[i])
        Connections[i]=nil
    end
end

local function clearThreads()
    for i=#Threads,1,-1 do
        cancelThread(Threads[i])
        Threads[i]=nil
    end
end

local function getGuiParent()
    local ok,result=protect(function()
        if type(gethui)=="function" then
            return gethui()
        end
    end)

    if ok and result then
        return result
    end

    local ok2,result2=protect(function()
        local test=Instance.new("ScreenGui")
        test.Parent=CoreGui
        test:Destroy()
        return CoreGui
    end)

    if ok2 and result2 then
        return result2
    end

    return playerGui
end

local guiParent=getGuiParent()

local oldGui=guiParent:FindFirstChild("AldoVzHubV3")

if oldGui then
    oldGui:Destroy()
end

local sg=Instance.new("ScreenGui")
sg.Name="AldoVzHubV3"
sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.DisplayOrder=999999
sg.IgnoreGuiInset=true

local guiAttached=protect(function()
    sg.Parent=guiParent
end)

if not guiAttached then
    protect(function()
        sg.Parent=playerGui
    end)
end

local floatButton=Instance.new("TextButton")
floatButton.Name="FloatButton"
floatButton.Size=UDim2.fromOffset(50,50)
floatButton.Position=UDim2.new(0,16,0.4,0)
floatButton.Text="🚀"
floatButton.TextSize=24
floatButton.BackgroundColor3=Color3.fromRGB(25,12,60)
floatButton.BackgroundTransparency=0.05
floatButton.BorderSizePixel=0
floatButton.ZIndex=999
floatButton.AutoButtonColor=false
floatButton.Active=true
floatButton.Parent=sg

local floatCorner=Instance.new("UICorner")
floatCorner.CornerRadius=UDim.new(1,0)
floatCorner.Parent=floatButton

local floatGrad=Instance.new("UIGradient")
floatGrad.Rotation=45
floatGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Config.colors.float[1]),
    ColorSequenceKeypoint.new(0.5,Config.colors.float[2]),
    ColorSequenceKeypoint.new(1,Config.colors.float[3])
})
floatGrad.Parent=floatButton

local floatStroke=Instance.new("UIStroke")
floatStroke.Color=Config.colors.float[2]
floatStroke.Thickness=1.5
floatStroke.Transparency=0.2
floatStroke.Parent=floatButton

local mainFrame=Instance.new("Frame")
mainFrame.Name="MainFrame"
mainFrame.Size=UDim2.fromOffset(330,520)
mainFrame.Position=UDim2.new(0.5,-165,0.5,-260)
mainFrame.BackgroundColor3=Color3.fromRGB(14,10,28)
mainFrame.BorderSizePixel=0
mainFrame.ClipsDescendants=true
mainFrame.Visible=false
mainFrame.Active=false
mainFrame.ZIndex=998
mainFrame.Parent=sg

local mainCorner=Instance.new("UICorner")
mainCorner.CornerRadius=UDim.new(0,12)
mainCorner.Parent=mainFrame

local mainGrad=Instance.new("UIGradient")
mainGrad.Rotation=45
mainGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Config.colors.main[1]),
    ColorSequenceKeypoint.new(0.5,Config.colors.main[2]),
    ColorSequenceKeypoint.new(1,Config.colors.main[3])
})
mainGrad.Parent=mainFrame

local mainStroke=Instance.new("UIStroke")
mainStroke.Thickness=1.5
mainStroke.Transparency=0.15
mainStroke.Parent=mainFrame

local mainStrokeGrad=Instance.new("UIGradient")
mainStrokeGrad.Rotation=45
mainStrokeGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Config.colors.stroke[1]),
    ColorSequenceKeypoint.new(0.5,Config.colors.stroke[2]),
    ColorSequenceKeypoint.new(1,Config.colors.stroke[3])
})
mainStrokeGrad.Parent=mainStroke

connect(RunService.Heartbeat:Connect(function()
    local t=os.clock()

    mainGrad.Offset=Vector2.new(
        math.sin(t*0.4)*0.6,
        math.cos(t*0.35)*0.6
    )

    mainStrokeGrad.Offset=Vector2.new(
        math.cos(t*0.3)*0.5,
        math.sin(t*0.45)*0.5
    )

    floatGrad.Offset=Vector2.new(
        math.sin(t*0.5)*0.4,
        0
    )
end))

local titleBar=Instance.new("Frame")
titleBar.Size=UDim2.new(1,0,0,40)
titleBar.BackgroundColor3=Color3.fromRGB(20,14,42)
titleBar.BackgroundTransparency=0.25
titleBar.BorderSizePixel=0
titleBar.Parent=mainFrame

local titleLabel=Instance.new("TextLabel")
titleLabel.Size=UDim2.new(0,150,1,0)
titleLabel.Position=UDim2.fromOffset(12,0)
titleLabel.Text="👾 AldoVz"
titleLabel.TextColor3=Color3.fromRGB(230,210,255)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.TextSize=16
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency=1
titleLabel.Parent=titleBar

local titleStroke=Instance.new("UIStroke")
titleStroke.Color=Color3.fromRGB(180,80,255)
titleStroke.Thickness=1
titleStroke.Transparency=0.3
titleStroke.Parent=titleLabel

local perfLabel=Instance.new("TextLabel")
perfLabel.Size=UDim2.new(0,170,1,0)
perfLabel.Position=UDim2.new(1,-178,0,0)
perfLabel.Text="FPS: 0 | PING: 0 ms"
perfLabel.TextColor3=Color3.fromRGB(120,255,180)
perfLabel.Font=Enum.Font.GothamBold
perfLabel.TextSize=11
perfLabel.TextXAlignment=Enum.TextXAlignment.Right
perfLabel.BackgroundTransparency=1
perfLabel.Parent=titleBar

local content=Instance.new("ScrollingFrame")
content.Name="Content"
content.Size=UDim2.new(1,0,1,-52)
content.Position=UDim2.fromOffset(0,44)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.ScrollBarImageColor3=Color3.fromRGB(160,60,255)
content.AutomaticCanvasSize=Enum.AutomaticSize.Y
content.CanvasSize=UDim2.new()
content.Parent=mainFrame

local listLayout=Instance.new("UIListLayout")
listLayout.Padding=UDim.new(0,8)
listLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
listLayout.SortOrder=Enum.SortOrder.LayoutOrder
listLayout.Parent=content

local padding=Instance.new("UIPadding")
padding.PaddingTop=UDim.new(0,10)
padding.PaddingBottom=UDim.new(0,10)
padding.Parent=content

local menuBusy=false

local function openMenu()
    if menuBusy or mainFrame.Visible then
        return
    end

    menuBusy=true
    mainFrame.Visible=true
    mainFrame.Size=UDim2.fromOffset(300,470)
    mainFrame.Position=UDim2.new(0.5,-150,0.5,-235)

    local tween=TweenService:Create(
        mainFrame,
        TweenInfo.new(
            0.22,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Size=UDim2.fromOffset(330,520),
            Position=UDim2.new(0.5,-165,0.5,-260)
        }
    )

    tween:Play()

    tween.Completed:Once(function()
        menuBusy=false
    end)
end

local function closeMenu()
    if menuBusy or not mainFrame.Visible then
        return
    end

    menuBusy=true

    local tween=TweenService:Create(
        mainFrame,
        TweenInfo.new(
            0.16,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            Size=UDim2.fromOffset(300,470),
            Position=UDim2.new(0.5,-150,0.5,-235)
        }
    )

    tween:Play()

    tween.Completed:Once(function()
        mainFrame.Visible=false
        mainFrame.Size=UDim2.fromOffset(330,520)
        mainFrame.Position=UDim2.new(0.5,-165,0.5,-260)
        menuBusy=false
    end)
end

connect(floatButton.Activated:Connect(function()
    if mainFrame.Visible then
        closeMenu()
    else
        openMenu()
    end
end))

local dragActive=false
local dragMoved=false
local dragStart=nil
local startPos=nil

connect(floatButton.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch
        or input.UserInputType==Enum.UserInputType.MouseButton1 then

        dragActive=true
        dragMoved=false
        dragStart=input.Position
        startPos=floatButton.Position
    end
end))

connect(UserInputService.InputChanged:Connect(function(input)
    if not dragActive then
        return
    end

    if input.UserInputType~=Enum.UserInputType.Touch
        and input.UserInputType~=Enum.UserInputType.MouseMovement then
        return
    end

    local delta=input.Position-(dragStart or input.Position)

    if delta.Magnitude>6 then
        dragMoved=true
    end

    local camera=Workspace.CurrentCamera

    if camera then
        local viewport=camera.ViewportSize

        local x=(startPos and startPos.X.Offset or 16)+delta.X
        local y=(startPos and startPos.Y.Offset or 16)+delta.Y

        floatButton.Position=UDim2.fromOffset(
            math.clamp(
                x,
                0,
                math.max(0,viewport.X-50)
            ),
            math.clamp(
                y,
                0,
                math.max(0,viewport.Y-50)
            )
        )
    end
end))

connect(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch
        or input.UserInputType==Enum.UserInputType.MouseButton1 then

        dragActive=false
        dragMoved=false
        dragStart=nil
        startPos=nil
    end
end))

local fpsCount=0
local fpsElapsed=0

connect(RunService.RenderStepped:Connect(function(dt)
    fpsCount+=1
    fpsElapsed+=dt

    if fpsElapsed>=0.5 then
        local fps=math.floor(
            fpsCount/fpsElapsed+0.5
        )

        local ping=0

        protect(function()
            local raw=Stats.Network.ServerToClientPing

            if typeof(raw)=="Instance" then
                raw=raw:GetValue()
            end

            if type(raw)=="number" then
                ping=raw
            elseif type(raw)=="string" then
                ping=tonumber(
                    string.match(raw,"[%d%.]+")
                ) or 0
            end
        end)

        perfLabel.Text=string.format(
            "FPS: %d | PING: %d ms",
            fps,
            math.floor(ping+0.5)
        )

        fpsCount=0
        fpsElapsed=0
    end
end))

local function getRoot()
    local character=player.Character

    return character
        and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character=player.Character

    return character
        and character:FindFirstChildOfClass("Humanoid")
end

local function safeRay(origin,direction)
    local params=RaycastParams.new()

    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={
        player.Character
    }

    return Workspace:Raycast(
        origin,
        direction,
        params
    )
end

local autoWalkConnection

local function startAutoWalk()
    if autoWalkConnection then
        return
    end

    State.autoWalk=true

    autoWalkConnection=connect(
        RunService.RenderStepped:Connect(function()
            if not State.autoWalk then
                return
            end

            protect(function()
                local h=getHumanoid()
                local r=getRoot()

                if not h or not r then
                    return
                end

                h:Move(
                    Vector3.new(0,0,-1),
                    true
                )

                if State.smartJump then
                    local hit=safeRay(
                        r.Position+Vector3.new(0,1,0),
                        r.CFrame.LookVector*5
                    )

                    if hit
                        and hit.Instance
                        and hit.Instance.CanCollide then

                        h.Jump=true
                    end
                end
            end)
        end)
    )
end

local function stopAutoWalk()
    State.autoWalk=false

    if autoWalkConnection then
        disconnect(autoWalkConnection)
        autoWalkConnection=nil
    end
end

local autoClickThread

local function startAutoClick()
    if autoClickThread then
        return
    end

    State.autoClick=true

    autoClickThread=task.spawn(function()
        while State.autoClick do
            protect(function()
                local character=player.Character
                local tool=character
                    and character:FindFirstChildOfClass("Tool")

                if tool then
                    tool:Activate()
                end
            end)

            task.wait(0.1)
        end

        autoClickThread=nil
    end)

    Threads[#Threads+1]=autoClickThread
end

local function stopAutoClick()
    State.autoClick=false
    cancelThread(autoClickThread)
    autoClickThread=nil
end

local antiAfkConnection

local function startAntiAfk()
    State.antiAfk=true

    if antiAfkConnection then
        return
    end

    antiAfkConnection=connect(
        player.Idled:Connect(function()
            protect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(
                    Vector2.new()
                )
            end)
        end)
    )
end

local function stopAntiAfk()
    State.antiAfk=false
    disconnect(antiAfkConnection)
    antiAfkConnection=nil
end

local speedThread

local function startSpeed()
    if speedThread then
        return
    end

    State.speedBypass=true

    speedThread=task.spawn(function()
        while State.speedBypass do
            protect(function()
                local h=getHumanoid()

                if h then
                    h.WalkSpeed=Config.walkSpeed
                    h.JumpPower=Config.jumpPower
                end
            end)

            task.wait(0.3)
        end

        speedThread=nil
    end)

    Threads[#Threads+1]=speedThread
end

local function stopSpeed()
    State.speedBypass=false
    cancelThread(speedThread)
    speedThread=nil
end

local espMap={}
local espCharacterConnections={}

local function removePlayerESP(p)
    if espMap[p] then
        protect(function()
            espMap[p]:Destroy()
        end)
    end

    espMap[p]=nil
end

local function addPlayerESP(p)
    if p==player then
        return
    end

    protect(function()
        local character=p.Character

        if not character then
            return
        end

        removePlayerESP(p)

        local highlight=Instance.new("Highlight")

        highlight.Name="AldoVzESP"
        highlight.FillColor=Color3.fromRGB(255,0,180)
        highlight.FillTransparency=0.45
        highlight.OutlineColor=Color3.fromRGB(0,255,200)
        highlight.OutlineTransparency=0.2
        highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent=character

        espMap[p]=highlight
    end)
end

local function bindPlayerESP(p)
    if p==player then
        return
    end

    if espCharacterConnections[p] then
        disconnect(espCharacterConnections[p])
    end

    espCharacterConnections[p]=connect(
        p.CharacterAdded:Connect(function()
            task.wait(0.15)

            if State.playerEsp then
                addPlayerESP(p)
            end
        end)
    )

    if State.playerEsp then
        addPlayerESP(p)
    end
end

local function clearPlayerESP()
    for p in pairs(espMap) do
        removePlayerESP(p)
    end

    for p,c in pairs(espCharacterConnections) do
        disconnect(c)
        espCharacterConnections[p]=nil
    end
end

local function stopPlayerESP()
    State.playerEsp=false
    clearPlayerESP()
end

local function startPlayerESP()
    if State.playerEsp then
        return
    end

    State.playerEsp=true

    for _,p in ipairs(Players:GetPlayers()) do
        bindPlayerESP(p)
    end
end

local itemEntries={}
local itemIndex={}
local itemThread
local itemDescendantConnection

local keywords={
    "chest",
    "coin",
    "gold",
    "gem",
    "crate",
    "loot",
    "key",
    "orb",
    "zombie",
    "enemy",
    "mob",
    "npc",
    "boss",
    "monster",
    "skull",
    "diamond",
    "emerald",
    "ruby",
    "essence",
    "shard",
    "fragment",
    "plant",
    "ore",
    "crystal",
    "supply",
    "box",
    "token"
}

local function isInteresting(part)
    if not part:IsA("BasePart")
        or not part.CanCollide then
        return false
    end

    local name=part.Name:lower()

    for _,word in ipairs(keywords) do
        if string.find(name,word,1,true) then
            return true
        end
    end

    return false
end

local function destroyItemEntry(entry)
    protect(function()
        if entry.highlight then
            entry.highlight:Destroy()
        end

        if entry.billboard then
            entry.billboard:Destroy()
        end
    end)

    if entry.part then
        itemIndex[entry.part]=nil
    end
end

local function addItem(part)
    if #itemEntries>=60
        or itemIndex[part]
        or not isInteresting(part) then
        return
    end

    local ok=protect(function()
        local highlight=Instance.new("Highlight")

        highlight.FillColor=Color3.fromRGB(255,200,0)
        highlight.FillTransparency=0.55
        highlight.OutlineColor=Color3.fromRGB(255,120,0)
        highlight.OutlineTransparency=0.1
        highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent=part

        local billboard=Instance.new("BillboardGui")

        billboard.Name="AldoVzItemESP"
        billboard.Size=UDim2.fromOffset(130,24)
        billboard.AlwaysOnTop=true
        billboard.MaxDistance=500
        billboard.Adornee=part

        local label=Instance.new("TextLabel")

        label.Size=UDim2.fromScale(1,1)
        label.BackgroundTransparency=0.35
        label.BackgroundColor3=Color3.new(0,0,0)
        label.Text=part.Name
        label.TextColor3=Color3.fromRGB(255,220,100)
        label.Font=Enum.Font.GothamBold
        label.TextSize=11
        label.Parent=billboard

        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(0,6)
        corner.Parent=label

        billboard.Parent=sg

        local entry={
            part=part,
            highlight=highlight,
            billboard=billboard,
            label=label
        }

        itemEntries[#itemEntries+1]=entry
        itemIndex[part]=entry
    end)

    if not ok then
        itemIndex[part]=nil
    end
end

local function scanItems()
    for i=#itemEntries,1,-1 do
        local entry=itemEntries[i]

        if not entry.part
            or not entry.part.Parent then

            destroyItemEntry(entry)
            table.remove(itemEntries,i)
        end
    end

    if #itemEntries>=60 then
        return
    end

    protect(function()
        for _,part in ipairs(Workspace:GetDescendants()) do
            if #itemEntries>=60 then
                break
            end

            if isInteresting(part)
                and not itemIndex[part] then

                addItem(part)
            end
        end
    end)
end

local function updateItemDistances()
    local root=getRoot()

    if not root then
        return
    end

    for i=#itemEntries,1,-1 do
        local entry=itemEntries[i]

        if entry.part
            and entry.part.Parent
            and entry.label then

            entry.label.Text=string.format(
                "%s | %.0f",
                entry.part.Name,
                (
                    entry.part.Position-root.Position
                ).Magnitude
            )
        else
            destroyItemEntry(entry)
            table.remove(itemEntries,i)
        end
    end
end

local function startItemESP()
    if itemThread then
        return
    end

    State.itemEsp=true

    scanItems()

    itemDescendantConnection=connect(
        Workspace.DescendantAdded:Connect(function(instance)
            if State.itemEsp
                and instance:IsA("BasePart") then

                addItem(instance)
            end
        end)
    )

    itemThread=task.spawn(function()
        while State.itemEsp do
            protect(updateItemDistances)
            task.wait(0.75)
        end

        itemThread=nil
    end)

    Threads[#Threads+1]=itemThread
end

local function stopItemESP()
    State.itemEsp=false

    cancelThread(itemThread)

    itemThread=nil

    disconnect(itemDescendantConnection)
    itemDescendantConnection=nil

    for i=#itemEntries,1,-1 do
        destroyItemEntry(itemEntries[i])
        itemEntries[i]=nil
    end

    table.clear(itemIndex)
end

local function closestItem()
    local root=getRoot()

    if not root then
        return nil
    end

    local best=nil
    local bestDistance=math.huge

    for _,entry in ipairs(itemEntries) do
        if entry.part and entry.part.Parent then
            local distance=(
                entry.part.Position-root.Position
            ).Magnitude

            if distance<bestDistance then
                best=entry.part
                bestDistance=distance
            end
        end
    end

    return best,bestDistance
end

local magnetThread

local function startMagnet()
    if magnetThread then
        return
    end

    State.magnet=true

    magnetThread=task.spawn(function()
        while State.magnet do
            protect(function()
                if #itemEntries==0 then
                    scanItems()
                end

                local root=getRoot()
                local target,distance=closestItem()

                if root
                    and target
                    and distance
                    and distance>4 then

                    root.CFrame=
                        root.CFrame:Lerp(
                            CFrame.new(
                                target.Position+
                                Vector3.new(0,2,0)
                            ),
                            0.35
                        )
                end
            end)

            task.wait(0.2)
        end

        magnetThread=nil
    end)

    Threads[#Threads+1]=magnetThread
end

local function stopMagnet()
    State.magnet=false

    cancelThread(magnetThread)

    magnetThread=nil
end

local trackerFrame=Instance.new("Frame")
trackerFrame.Size=UDim2.new(1,-20,0,130)
trackerFrame.BackgroundColor3=Color3.fromRGB(18,14,36)
trackerFrame.BackgroundTransparency=0.15
trackerFrame.BorderSizePixel=0
trackerFrame.LayoutOrder=100
trackerFrame.Parent=content

local trackerCorner=Instance.new("UICorner")
trackerCorner.CornerRadius=UDim.new(0,8)
trackerCorner.Parent=trackerFrame

local trackerTitle=Instance.new("TextLabel")
trackerTitle.Size=UDim2.new(1,-8,0,22)
trackerTitle.Position=UDim2.fromOffset(8,2)
trackerTitle.Text="👥 PLAYER DISTANCE"
trackerTitle.TextColor3=Color3.fromRGB(160,140,255)
trackerTitle.Font=Enum.Font.GothamBold
trackerTitle.TextSize=11
trackerTitle.TextXAlignment=Enum.TextXAlignment.Left
trackerTitle.BackgroundTransparency=1
trackerTitle.Parent=trackerFrame

local trackerList=Instance.new("ScrollingFrame")
trackerList.Size=UDim2.new(1,-8,1,-26)
trackerList.Position=UDim2.fromOffset(4,24)
trackerList.BackgroundTransparency=1
trackerList.BorderSizePixel=0
trackerList.ScrollBarThickness=2
trackerList.AutomaticCanvasSize=Enum.AutomaticSize.Y
trackerList.Parent=trackerFrame

local trackerLayout=Instance.new("UIListLayout")
trackerLayout.Padding=UDim.new(0,2)
trackerLayout.Parent=trackerList

local trackerLabels={}

local function updateTracker()
    local root=getRoot()
    local used=0

    if root then
        local entries={}

        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player then
                local pr=p.Character
                    and p.Character:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if pr then
                    entries[#entries+1]={
                        player=p,
                        distance=(
                            pr.Position-root.Position
                        ).Magnitude
                    }
                end
            end
        end

        table.sort(
            entries,
            function(a,b)
                return a.distance<b.distance
            end
        )

        for index,entry in ipairs(entries) do
            local label=trackerLabels[index]

            if not label then
                label=Instance.new("TextLabel")
                label.Size=UDim2.new(1,0,0,16)
                label.TextColor3=Color3.fromRGB(220,210,255)
                label.Font=Enum.Font.Gotham
                label.TextSize=10
                label.TextXAlignment=Enum.TextXAlignment.Left
                label.BackgroundTransparency=1
                label.Parent=trackerList
                trackerLabels[index]=label
            end

            label.Text=string.format(
                "USN: %s | Jarak: %.1f Studs",
                entry.player.Name,
                entry.distance
            )

            label.Visible=true
            used=index
        end
    end

    for index=used+1,#trackerLabels do
        trackerLabels[index].Visible=false
    end
end

local trackerThread=task.spawn(function()
    while sg.Parent do
        protect(updateTracker)
        task.wait(0.5)
    end
end)

Threads[#Threads+1]=trackerThread

local routePoints={}
local checkpoint=nil
local recordingThread=nil
local routeThread=nil
local bodyVelocity=nil

local function startRecord()
    if State.recording then
        return
    end

    State.recording=true
    table.clear(routePoints)

    protect(function()
        local root=getRoot()

        if root then
            routePoints[#routePoints+1]=root.CFrame
            checkpoint=root.CFrame
        end
    end)

    recordingThread=task.spawn(function()
        while State.recording do
            task.wait(0.2)

            if not State.recording then
                break
            end

            protect(function()
                local root=getRoot()

                if root then
                    routePoints[#routePoints+1]=root.CFrame
                    checkpoint=root.CFrame
                end
            end)
        end

        recordingThread=nil
    end)

    Threads[#Threads+1]=recordingThread

    notify(
        "Record",
        "Route recording started",
        1.5
    )
end

local function stopRecord()
    State.recording=false

    cancelThread(recordingThread)
    recordingThread=nil

    notify(
        "Record",
        string.format(
            "%d points recorded",
            #routePoints
        ),
        1.5
    )
end

local function groundSafety(root)
    if not root then
        return false
    end

    local hit=safeRay(
        root.Position,
        Vector3.new(0,-7,0)
    )

    local valid=
        hit
        and hit.Instance
        and hit.Instance:IsA("BasePart")
        and hit.Instance.CanCollide

    if not valid then
        if not bodyVelocity
            or not bodyVelocity.Parent then

            bodyVelocity=Instance.new("BodyVelocity")
            bodyVelocity.MaxForce=Vector3.new(
                100000,
                0,
                100000
            )
            bodyVelocity.Velocity=Vector3.zero
            bodyVelocity.Parent=root
        end

        return false
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity=nil
    end

    return true
end

local function releaseRouteSafety()
    if bodyVelocity then
        protect(function()
            bodyVelocity:Destroy()
        end)

        bodyVelocity=nil
    end
end

local function stopRoute()
    State.routePlay=false

    local thread=routeThread
    routeThread=nil

    if thread then
        cancelThread(thread)
    end

    releaseRouteSafety()

    protect(function()
        local h=getHumanoid()
        local root=getRoot()

        if h then
            h.AutoRotate=true
        end

        if root then
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end

local function finishRoute()
    State.routePlay=false
    routeThread=nil
    releaseRouteSafety()

    protect(function()
        local h=getHumanoid()
        local root=getRoot()

        if h then
            h.AutoRotate=true
        end

        if root then
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end

local function playRoute()
    if #routePoints<2 then
        notify(
            "Route",
            "Record a route first",
            1.5
        )
        return
    end

    stopRoute()
    task.wait()

    local h=getHumanoid()
    local root=getRoot()

    if not h or not root then
        return
    end

    State.routePlay=true

    local thread

    thread=task.spawn(function()
        local oldAutoRotate=h.AutoRotate

        h.AutoRotate=false

        local ok=pcall(function()
            local frameInterval=0.2

            local totalDuration=
                (#routePoints-1)*
                frameInterval

            local startClock=os.clock()

            protect(function()
                root.CFrame=routePoints[1]
                root.AssemblyLinearVelocity=Vector3.zero
                root.AssemblyAngularVelocity=Vector3.zero
            end)

            checkpoint=routePoints[1]

            while State.routePlay do
                h=getHumanoid()
                root=getRoot()

                if not h or not root then
                    State.routePlay=false
                    break
                end

                local elapsed=
                    os.clock()-startClock

                if elapsed>=totalDuration then
                    local finalCFrame=
                        routePoints[#routePoints]

                    protect(function()
                        root.CFrame=finalCFrame
                        root.AssemblyLinearVelocity=
                            Vector3.zero
                        root.AssemblyAngularVelocity=
                            Vector3.zero
                    end)

                    checkpoint=finalCFrame
                    break
                end

                local positionIndex=
                    elapsed/frameInterval+1

                local i1=math.clamp(
                    math.floor(positionIndex),
                    1,
                    #routePoints-1
                )

                local alpha=math.clamp(
                    positionIndex-i1,
                    0,
                    1
                )

                local a=routePoints[i1]
                local b=routePoints[i1+1]

                local target=a:Lerp(b,alpha)

                local safe=groundSafety(root)

                if root.Position.Y<Config.safeY
                    or not safe then

                    if checkpoint then
                        protect(function()
                            root.CFrame=
                                checkpoint+
                                Vector3.new(0,3,0)

                            root.AssemblyLinearVelocity=
                                Vector3.zero

                            root.AssemblyAngularVelocity=
                                Vector3.zero
                        end)
                    end

                    State.routePlay=false
                    break
                end

                protect(function()
                    h.AutoRotate=false
                    h:ChangeState(
                        Enum.HumanoidStateType.Running
                    )

                    root.CFrame=target

                    root.AssemblyLinearVelocity=
                        Vector3.zero

                    root.AssemblyAngularVelocity=
                        Vector3.zero
                end)

                checkpoint=target

                RunService.RenderStepped:Wait()
            end
        end)

        protect(function()
            if h then
                h.AutoRotate=oldAutoRotate
            end
        end)

        if not ok then
            State.routePlay=false
        end

        if routeThread==thread then
            finishRoute()
        end
    end)

    routeThread=thread
    Threads[#Threads+1]=thread

    notify(
        "Route",
        string.format(
            "Playing %d recorded points",
            #routePoints
        ),
        1.5
    )
end

local function saveRoute()
    if #routePoints==0 then
        notify(
            "Route",
            "No route to save",
            1.5
        )
        return
    end

    if type(writefile)~="function" then
        notify(
            "Route",
            "writefile is unavailable",
            2
        )
        return
    end

    protect(function()
        local data={}

        for _,cf in ipairs(routePoints) do
            local x,y,z=
                cf:ToEulerAnglesXYZ()

            data[#data+1]={
                px=cf.Position.X,
                py=cf.Position.Y,
                pz=cf.Position.Z,
                rx=x,
                ry=y,
                rz=z
            }
        end

        writefile(
            ROUTE_FILE,
            HttpService:JSONEncode(data)
        )

        notify(
            "Route",
            string.format(
                "%d points saved",
                #data
            ),
            1.5
        )
    end)
end

local function loadRoute()
    if type(readfile)~="function" then
        notify(
            "Route",
            "readfile is unavailable",
            2
        )
        return
    end

    protect(function()
        if type(isfile)=="function"
            and not isfile(ROUTE_FILE) then

            notify(
                "Route",
                "Route file not found",
                1.5
            )

            return
        end

        local data=
            HttpService:JSONDecode(
                readfile(ROUTE_FILE)
            )

        if type(data)~="table" then
            return
        end

        table.clear(routePoints)

        for _,e in ipairs(data) do
            if type(e)=="table"
                and e.px
                and e.py
                and e.pz then

                local position=
                    Vector3.new(
                        e.px,
                        e.py,
                        e.pz
                    )

                routePoints[#routePoints+1]=
                    CFrame.new(position)*
                    CFrame.fromEulerAnglesXYZ(
                        e.rx or 0,
                        e.ry or 0,
                        e.rz or 0
                    )
            end
        end

        checkpoint=routePoints[1]

        notify(
            "Route",
            string.format(
                "%d points loaded",
                #routePoints
            ),
            1.5
        )
    end)
end

local buttons={}

local function makeToggle(
    text,
    getState,
    onEnable,
    onDisable
)
    local button=Instance.new("TextButton")

    button.Size=UDim2.new(1,-20,0,52)
    button.Text=text.."  [OFF]"
    button.TextColor3=
        Color3.fromRGB(200,190,235)

    button.Font=Enum.Font.GothamBold
    button.TextSize=13
    button.BackgroundColor3=Config.colors.off
    button.BackgroundTransparency=0.1
    button.BorderSizePixel=0
    button.AutoButtonColor=false
    button.LayoutOrder=#buttons+1
    button.Parent=content

    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,10)
    corner.Parent=button

    local stroke=Instance.new("UIStroke")
    stroke.Thickness=1.2
    stroke.Color=Color3.fromRGB(80,50,150)
    stroke.Transparency=0.4
    stroke.Parent=button

    local function update()
        local active=getState()

        button.Text=
            text..
            (active and "  [ON]" or "  [OFF]")

        TweenService:Create(
            button,
            TweenInfo.new(0.15),
            {
                BackgroundColor3=
                    active
                    and Config.colors.on
                    or Config.colors.off
            }
        ):Play()

        stroke.Color=
            active
            and Color3.fromRGB(0,255,140)
            or Color3.fromRGB(80,50,150)

        stroke.Transparency=
            active and 0 or 0.4

        button.TextColor3=
            active
            and Color3.new(1,1,1)
            or Color3.fromRGB(200,190,235)
    end

    connect(
        button.Activated:Connect(function()
            if getState() then
                onDisable()
            else
                onEnable()
            end

            update()
        end)
    )

    buttons[#buttons+1]=update

    return button
end

makeToggle(
    "🚶 Auto-Walk",
    function()
        return State.autoWalk
    end,
    startAutoWalk,
    stopAutoWalk
)

makeToggle(
    "👆 Auto-Click Tool",
    function()
        return State.autoClick
    end,
    startAutoClick,
    stopAutoClick
)

makeToggle(
    "⏰ Anti-AFK",
    function()
        return State.antiAfk
    end,
    startAntiAfk,
    stopAntiAfk
)

makeToggle(
    "🦘 Smart Auto-Jump",
    function()
        return State.smartJump
    end,
    function()
        State.smartJump=true
    end,
    function()
        State.smartJump=false
    end
)

makeToggle(
    "⚡ Speed/Jump",
    function()
        return State.speedBypass
    end,
    startSpeed,
    stopSpeed
)

makeToggle(
    "👤 Player ESP",
    function()
        return State.playerEsp
    end,
    startPlayerESP,
    stopPlayerESP
)

makeToggle(
    "🗺️ Item ESP",
    function()
        return State.itemEsp
    end,
    startItemESP,
    stopItemESP
)

makeToggle(
    "🧲 Teleport Magnet",
    function()
        return State.magnet
    end,
    startMagnet,
    stopMagnet
)

local settings=Instance.new("Frame")
settings.Size=UDim2.new(1,-20,0,120)
settings.BackgroundColor3=
    Color3.fromRGB(20,16,38)

settings.BackgroundTransparency=0.1
settings.BorderSizePixel=0
settings.LayoutOrder=200
settings.Parent=content

local settingsCorner=Instance.new("UICorner")
settingsCorner.CornerRadius=UDim.new(0,10)
settingsCorner.Parent=settings

local settingsTitle=Instance.new("TextLabel")
settingsTitle.Size=UDim2.new(1,-16,0,20)
settingsTitle.Position=UDim2.fromOffset(8,6)
settingsTitle.Text="⚙️ SETTINGS"
settingsTitle.TextColor3=
    Color3.fromRGB(160,140,255)

settingsTitle.Font=Enum.Font.GothamBold
settingsTitle.TextSize=11
settingsTitle.TextXAlignment=
    Enum.TextXAlignment.Left

settingsTitle.BackgroundTransparency=1
settingsTitle.Parent=settings

local function addAdjuster(
    y,
    label,
    getValue,
    minValue,
    maxValue,
    step,
    setValue
)
    local name=Instance.new("TextLabel")

    name.Size=UDim2.fromOffset(120,22)
    name.Position=UDim2.fromOffset(10,y)
    name.Text=label
    name.TextColor3=
        Color3.fromRGB(210,200,240)

    name.Font=Enum.Font.GothamBold
    name.TextSize=11
    name.TextXAlignment=
        Enum.TextXAlignment.Left

    name.BackgroundTransparency=1
    name.Parent=settings

    local value=Instance.new("TextLabel")

    value.Size=UDim2.fromOffset(60,22)
    value.Position=UDim2.fromOffset(120,y)
    value.Text=tostring(getValue())
    value.TextColor3=
        Color3.fromRGB(255,200,100)

    value.Font=Enum.Font.GothamBold
    value.TextSize=12
    value.BackgroundTransparency=1
    value.Parent=settings

    for symbol,x in pairs({
        ["-"]=250,
        ["+"]=290
    }) do
        local button=Instance.new("TextButton")

        button.Size=UDim2.fromOffset(36,26)
        button.Position=UDim2.fromOffset(x,y-2)
        button.Text=symbol
        button.TextColor3=Color3.new(1,1,1)
        button.TextSize=15
        button.Font=Enum.Font.GothamBold
        button.BackgroundColor3=
            Color3.fromRGB(60,40,100)

        button.BackgroundTransparency=0.15
        button.BorderSizePixel=0
        button.Parent=settings

        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(0,6)
        corner.Parent=button

        connect(
            button.Activated:Connect(function()
                local current=getValue()

                setValue(
                    math.clamp(
                        current+
                        (symbol=="+" and step or -step),
                        minValue,
                        maxValue
                    )
                )

                value.Text=tostring(getValue())

                saveConfig()
            end)
        )
    end
end

addAdjuster(
    30,
    "⚡ WalkSpeed",
    function()
        return Config.walkSpeed
    end,
    16,
    250,
    5,
    function(v)
        Config.walkSpeed=v

        if State.speedBypass then
            local h=getHumanoid()

            if h then
                h.WalkSpeed=v
            end
        end
    end
)

addAdjuster(
    62,
    "🦘 JumpPower",
    function()
        return Config.jumpPower
    end,
    50,
    500,
    10,
    function(v)
        Config.jumpPower=v

        if State.speedBypass then
            local h=getHumanoid()

            if h then
                h.JumpPower=v
            end
        end
    end
)

local function actionButton(
    text,
    callback,
    order
)
    local button=Instance.new("TextButton")

    button.Size=UDim2.new(1,-20,0,52)
    button.Text=text
    button.TextColor3=Color3.new(1,1,1)
    button.Font=Enum.Font.GothamBold
    button.TextSize=13
    button.BackgroundColor3=
        Color3.fromRGB(60,100,180)

    button.BackgroundTransparency=0.12
    button.BorderSizePixel=0
    button.LayoutOrder=order
    button.Parent=content

    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,10)
    corner.Parent=button

    connect(
        button.Activated:Connect(function()
            protect(callback)
        end)
    )

    return button
end

local recordButton

recordButton=actionButton(
    "● Record Route",
    function()
        if State.recording then
            stopRecord()
            recordButton.Text=
                "● Record Route"
        else
            startRecord()
            recordButton.Text=
                "⏹ Stop Record"
        end
    end,
    300
)

actionButton(
    "▶ Play Route",
    playRoute,
    301
)

actionButton(
    "⏹ Stop Route",
    stopRoute,
    302
)

actionButton(
    "💾 Save Route JSON",
    saveRoute,
    303
)

actionButton(
    "📂 Load Route JSON",
    loadRoute,
    304
)

actionButton(
    "💾 Save Config",
    function()
        saveConfig()
        notify(
            "Config",
            "Saved",
            1.5
        )
    end,
    305
)

connect(
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)

        protect(function()
            local h=
                character:WaitForChild(
                    "Humanoid",
                    5
                )

            if not h then
                return
            end

            if State.speedBypass then
                h.WalkSpeed=
                    Config.walkSpeed

                h.JumpPower=
                    Config.jumpPower
            end

            if State.routePlay then
                stopRoute()
            end
        end)
    end)
)

connect(
    Players.PlayerAdded:Connect(function(p)
        if State.playerEsp then
            bindPlayerESP(p)
        end
    end)
)

connect(
    Players.PlayerRemoving:Connect(function(p)
        if espCharacterConnections[p] then
            disconnect(
                espCharacterConnections[p]
            )

            espCharacterConnections[p]=nil
        end

        removePlayerESP(p)
    end)
)

if State.antiAfk then
    startAntiAfk()
end

for _,update in ipairs(buttons) do
    update()
end

local function cleanup()
    stopAutoWalk()
    stopAutoClick()
    stopAntiAfk()
    stopSpeed()
    stopPlayerESP()
    stopItemESP()
    stopMagnet()
    stopRoute()
    stopRecord()

    State.autoWalk=false
    State.autoClick=false
    State.antiAfk=false
    State.smartJump=false
    State.speedBypass=false
    State.playerEsp=false
    State.itemEsp=false
    State.magnet=false
    State.routePlay=false
    State.recording=false

    for p,c in pairs(
        espCharacterConnections
    ) do
        disconnect(c)
        espCharacterConnections[p]=nil
    end

    clearThreads()
    clearConnections()

    if sg then
        protect(function()
            sg:Destroy()
        end)
    end
end

_G.AldoVzHubV3Cleanup=cleanup

notify(
    "👾 AldoVz",
    "Loaded",
    2
)

print("[AldoVz ART]")
