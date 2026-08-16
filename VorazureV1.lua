local RunService=game:GetService("RunService") 
local TweenService=game:GetService("TweenService") 
local ContentProvider=game:GetService("ContentProvider") 
local CoreGui=game:GetService("CoreGui") 
local Players=game:GetService("Players") 
local LocalPlayer=Players.LocalPlayer 
local UserInputService=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")

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

local OpenCorner=Instance.new("UICorner") 
OpenCorner.CornerRadius=UDim.new(8,0) 
OpenCorner.Parent=OpenMenu 

local OpenStroke=Instance.new("UIStroke") 
OpenStroke.Thickness=2 
OpenStroke.Color=Color3.fromRGB(255,255,255) 
OpenStroke.Parent=OpenMenu 

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
Image.ImageTransparency=0 
Image.Visible=true 
Image.ZIndex=11 
Image.Parent=OpenMenu 

local ImageCorner=Instance.new("UICorner") 
ImageCorner.CornerRadius=UDim.new(8,0) 
ImageCorner.Parent=Image 

local MenuFrame=Instance.new("Frame") 
MenuFrame.Name="MenuFrame" 
MenuFrame.Size=UDim2.fromOffset(650,450) 
MenuFrame.Position=UDim2.new(0.5,-325,0.5,-225) 
MenuFrame.BackgroundColor3=Color3.fromRGB(12,12,18) 
MenuFrame.BorderSizePixel=0 
MenuFrame.Active=false 
MenuFrame.Visible=false 
MenuFrame.ZIndex=2 
MenuFrame.Parent=ScreenGui 

local MenuCorner=Instance.new("UICorner") 
MenuCorner.CornerRadius=UDim.new(0,8) 
MenuCorner.Parent=MenuFrame 

local MenuStroke=Instance.new("UIStroke") 
MenuStroke.Thickness=2 
MenuStroke.Color=Color3.fromRGB(255,255,255) 
MenuStroke.Parent=MenuFrame 

local MenuGradient=Instance.new("UIGradient") 
MenuGradient.Color=ColorSequence.new({ 	
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)), 	
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0)) 
}) 
MenuGradient.Parent=MenuStroke 

-- Container Fitur Tambahan di dalam MenuFrame agar teratur
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDime2 and UDim2.new(0.95, 0, 0.85, 0) or UDim2.new(0.95, 0, 0.85, 0)
ContentContainer.Size = UDim2.new(0.95, 0, 0.82, 0)
ContentContainer.Position = UDim2.new(0.025, 0, 0.12, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
ContentContainer.ScrollBarThickness = 6
ContentContainer.ZIndex = 5
ContentContainer.Parent = MenuFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ContentContainer

-- Helper membuat tombol fitur
local function CreateButton(name, text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.ZIndex = 6
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = ContentContainer
    return btn
end

-- Helper membuat Label Kategori Header
local function CreateHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 16
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = ContentContainer
end

-- 1. SHIFT LOCK MOBILE
CreateHeader("--- SHIFT LOCK ---")
local isShiftLock = false
CreateButton("ShiftLockBtn", "Toggle Shift Lock Mobile: OFF", function(btn)
    isShiftLock = not isShiftLock
    if isShiftLock then
        btn.Text = "Toggle Shift Lock Mobile: ON"
        task.spawn(function()
            while isShiftLock do
                RunService.RenderStepped:Wait()
                local player = Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.Humanoid.AutoRotate = false
                    local camera = workspace.CurrentCamera
                    local root = player.Character.HumanoidRootPart
                    local camCFrame = camera.CFrame
                    local targetAngle = CFrame.new(root.Position, Vector3.new(camCFrame.LookVector.X * 9999, root.Position.Y, camCFrame.LookVector.Z * 9999))
                    root.CFrame = root.CFrame:Lerp(targetAngle, 0.2)
                end
            end
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                Players.LocalPlayer.Character.Humanoid.AutoRotate = true
            end
        end)
    else
        btn.Text = "Toggle Shift Lock Mobile: OFF"
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            Players.LocalPlayer.Character.Humanoid.AutoRotate = true
        end
    end
end)

-- 2. JUMP SETTING (SIZE + , SIZE -, RESET)
CreateHeader("--- JUMP SETTING ---")
CreateButton("JumpPowerPlus", "Jump Power / Size (+)", function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = char.Humanoid.JumpPower + 10
    end
end)

CreateButton("JumpPowerMin", "Jump Power / Size (-)", function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if char.Humanoid.JumpPower > 10 then
            char.Humanoid.JumpPower = char.Humanoid.JumpPower - 10
        end
    end
end)

CreateButton("JumpPowerReset", "Reset Jump Power", function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 50
    end
end)

-- 3. EMOTE & DANCE SECTION
CreateHeader("--- EMOTES & DANCES ---")

local function PlayEmoteOrAnimation(assetId)
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(assetId)
        local loadAnim = char.Humanoid:LoadAnimation(anim)
        loadAnim:Play()
    end
end

CreateButton("Dance1", "DANCE 1 ★", function()
    PlayEmoteOrAnimation(507710273) -- Contoh Animasi Dance
end)

CreateButton("Dance2", "DANCE 2 ★", function()
    PlayEmoteOrAnimation(507719543) -- Contoh Animasi Dance
end)

CreateButton("Emote1", "EMOTE 1 ★", function()
    PlayEmoteOrAnimation(591577311) -- Contoh Animasi Emote
end)

CreateButton("Emote2", "EMOTE 2 ★", function()
    PlayEmoteOrAnimation(591578361) -- Contoh Animasi Emote
end)

CreateButton("JumpStyle", "Jump Style (Emote/Dance) ★", function()
    PlayEmoteOrAnimation(3338871789) -- ID Jump Style
end)


local LoadingScreen=Instance.new("Frame") 
LoadingScreen.Name="LoadingScreen" 
LoadingScreen.Size=UDim2.new(1,0,1,0) 
LoadingScreen.BackgroundColor3=Color3.fromRGB(12,12,12) 
LoadingScreen.BorderSizePixel=0 
LoadingScreen.Visible=false 
LoadingScreen.ZIndex=20 
LoadingScreen.Parent=MenuFrame 

local LoadingCorner=Instance.new("UICorner") 
LoadingCorner.CornerRadius=UDim.new(0,8) 
LoadingCorner.Parent=LoadingScreen 

local LogoImage=Instance.new("ImageLabel") 
LogoImage.Size=UDim2.fromOffset(160,160) 
LogoImage.AnchorPoint=Vector2.new(0.5,0.5) 
LogoImage.Position=UDim2.new(0.5,0,0.35,0) 
LogoImage.BackgroundTransparency=1 
LogoImage.Image="rbxassetid://112921115907036" 
LogoImage.ZIndex=21 
LogoImage.Parent=LoadingScreen 

local LogoCorner=Instance.new("UICorner") 
LogoCorner.CornerRadius=UDim.new(0,20) 
LogoCorner.Parent=LogoImage 

local LogoStroke=Instance.new("UIStroke") 
LogoStroke.Color=Color3.fromRGB(255,255,255) 
LogoStroke.Thickness=3.5 
LogoStroke.Parent=LogoImage 

local LogoGradient=Instance.new("UIGradient") 
LogoGradient.Color=ColorSequence.new({ 	
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)), 	
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,0)), 	
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0)) 
}) 
LogoGradient.Parent=LogoStroke 

local OuterText=Instance.new("TextLabel") 
OuterText.Size=UDim2.new(1,0,0,60) 
OuterText.AnchorPoint=Vector2.new(0.5,0) 
OuterText.Position=UDim2.new(0.5,0,0.52,0) 
OuterText.BackgroundTransparency=1 
OuterText.Text="ALDO ZORA XORE" 
OuterText.TextColor3=Color3.fromRGB(255,255,255) 
OuterText.Font=Enum.Font.GothamBlack 
OuterText.TextSize=45 
OuterText.ZIndex=21 
OuterText.Parent=LoadingScreen 

local OuterStroke=Instance.new("UIStroke") 
OuterStroke.Color=Color3.fromRGB(255,255,255) 
OuterStroke.Thickness=6 
OuterStroke.Parent=OuterText 

local InnerText=Instance.new("TextLabel") 
InnerText.Size=UDim2.new(1,0,1,0) 
InnerText.BackgroundTransparency=1 
InnerText.Text="ALDO ZORA XORE" 
InnerText.TextColor3=Color3.fromRGB(255,255,255) 
InnerText.Font=Enum.Font.GothamBlack 
InnerText.TextSize=45 
InnerText.ZIndex=22 
InnerText.Parent=OuterText 

local InnerStroke=Instance.new("UIStroke") 
InnerStroke.Color=Color3.fromRGB(255,255,255) 
InnerStroke.Thickness=2.5 
InnerStroke.Parent=InnerText 

local TextGradient=Instance.new("UIGradient") 
TextGradient.Color=ColorSequence.new({ 	
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)), 	
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,0)), 	
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0)) 
}) 
TextGradient.Parent=InnerStroke 

local BarBackground=Instance.new("Frame") 
BarBackground.Size=UDim2.new(0.3,0,0.01,0) 
BarBackground.AnchorPoint=Vector2.new(0.5,0) 
BarBackground.Position=UDim2.new(0.5,0,0.68,0) 
BarBackground.BackgroundColor3=Color3.fromRGB(30,30,30) 
BarBackground.BorderSizePixel=0 
BarBackground.ZIndex=21 
BarBackground.Parent=LoadingScreen 

local CornerBg=Instance.new("UICorner") 
CornerBg.CornerRadius=UDim.new(1,0) 
CornerBg.Parent=BarBackground 

local BarFill=Instance.new("Frame") 
BarFill.Size=UDim2.new(0,0,1,0) 
BarFill.BackgroundColor3=Color3.fromRGB(255,255,255) 
BarFill.BorderSizePixel=0 
BarFill.ZIndex=22 
BarFill.Parent=BarBackground 

local CornerFill=Instance.new("UICorner") 
CornerFill.CornerRadius=UDim.new(1,0) 
CornerFill.Parent=BarFill 

local BarGradient=Instance.new("UIGradient") 
BarGradient.Color=ColorSequence.new({ 	
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,50,50)), 	
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,0)) 
}) 
BarGradient.Parent=BarFill 

local LoadingText=Instance.new("TextLabel") 
LoadingText.Size=UDim2.new(1,0,4,0) 
LoadingText.AnchorPoint=Vector2.new(0.5,1) 
LoadingText.Position=UDim2.new(0.5,0,-0.5,0) 
LoadingText.BackgroundTransparency=1 
LoadingText.Text="LOADING EXPERIENCE..." 
LoadingText.TextColor3=Color3.fromRGB(200,200,200) 
LoadingText.Font=Enum.Font.GothamMedium 
LoadingText.TextSize=13 
LoadingText.ZIndex=21 
LoadingText.Parent=BarBackground 

local LogoAnim=TweenService:Create(LogoGradient,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(1,0)}) 
local TextAnim=TweenService:Create(TextGradient,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(1,0)}) 
local PulseAnim=TweenService:Create(LoadingText,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.6}) 

local function ApplyPlayerNoclip(Character) 	
    for _,Part in ipairs(Character:GetDescendants()) do 		
        if Part:IsA("BasePart") then 			
            Part.CanCollide=false 		
        end 	
    end 
end 

local function SetupPlayerNoclip(Player) 	
    local function SetupCharacter(Character) 		
        ApplyPlayerNoclip(Character) 		
        Character.DescendantAdded:Connect(function(Part) 			
            if Part:IsA("BasePart") then 				
                Part.CanCollide=false 			
            end 		
        end) 	
    end 	
    if Player.Character then 		
        SetupCharacter(Player.Character) 	
    end 	
    Player.CharacterAdded:Connect(SetupCharacter) 
end 

for _,Player in ipairs(Players:GetPlayers()) do 	
    SetupPlayerNoclip(Player) 
end 

Players.PlayerAdded:Connect(SetupPlayerNoclip) 

RunService.Stepped:Connect(function() 	
    for _,Player in ipairs(Players:GetPlayers()) do 		
        local Character=Player.Character 		
        if Character then 			
            for _,Part in ipairs(Character:GetDescendants()) do 				
                if Part:IsA("BasePart") then 					
                    Part.CanCollide=false 				
                end 			
            end 		
        end 	
    end 
end) 

local Loaded=false 
local Loading=false 

task.spawn(function() 	
    pcall(function() 		
        ContentProvider:PreloadAsync({Image,LogoImage}) 	
    end) 	
    Image.Visible=true 	
    Image.ImageTransparency=0 
end) 

OpenMenu.Activated:Connect(function() 	
    if Loading then return end 	
    if Loaded then 		
        MenuFrame.Visible=not MenuFrame.Visible 		
        return 	
    end 	
    Loading=true 	
    MenuFrame.Visible=true 	
    LoadingScreen.Visible=true 	
    LogoAnim:Play() 	
    TextAnim:Play() 	
    PulseAnim:Play() 	
    local FillAnim=TweenService:Create( 
        BarFill, 
        TweenInfo.new(3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), 
        {Size=UDim2.new(1,0,1,0)} 
    ) 	
    FillAnim:Play() 	
    FillAnim.Completed:Wait() 	
    task.wait(0.3) 	
    local FadeInfo=TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) 	
    local FadeList={ 
        TweenService:Create(LoadingScreen,FadeInfo,{BackgroundTransparency=1}), 
        TweenService:Create(LogoImage,FadeInfo,{ImageTransparency=1}), 
        TweenService:Create(LogoStroke,FadeInfo,{Transparency=1}), 
        TweenService:Create(OuterText,FadeInfo,{TextTransparency=1}), 
        TweenService:Create(InnerText,FadeInfo,{TextTransparency=1}), 
        TweenService:Create(OuterStroke,FadeInfo,{Transparency=1}), 
        TweenService:Create(InnerStroke,FadeInfo,{Transparency=1}), 
        TweenService:Create(BarBackground,FadeInfo,{BackgroundTransparency=1}), 
        TweenService:Create(BarFill,FadeInfo,{BackgroundTransparency=1}), 
        TweenService:Create(LoadingText,FadeInfo,{TextTransparency=1}) 	
    } 	
    for _,Tween in ipairs(FadeList) do 		
        Tween:Play() 	
    end 	
    FadeList[1].Completed:Wait() 	
    LogoAnim:Cancel() 	
    TextAnim:Cancel() 	
    PulseAnim:Cancel() 	
    LoadingScreen.Visible=false 	
    LoadingScreen.BackgroundTransparency=0 	
    LogoImage.ImageTransparency=0 	
    LogoStroke.Transparency=0 	
    OuterText.TextTransparency=0 	
    InnerText.TextTransparency=0 	
    OuterStroke.Transparency=0 	
    InnerStroke.Transparency=0 	
    BarBackground.BackgroundTransparency=0 	
    BarFill.BackgroundTransparency=0 	
    LoadingText.TextTransparency=0 	
    BarFill.Size=UDim2.new(0,0,1,0) 	
    Loaded=true 	
    Loading=false 	
    MenuFrame.Visible=false 
end) 

local StrokeRotation=0 
local StrokeSpeed=45 

RunService.RenderStepped:Connect(function(dt) 	
    StrokeRotation=(StrokeRotation+StrokeSpeed*dt)%360 	
    OpenGradient.Rotation=StrokeRotation 	
    MenuGradient.Rotation=StrokeRotation 
end)
