local RunService=game:GetService("RunService") 
local TweenService=game:GetService("TweenService") 
local ContentProvider=game:GetService("ContentProvider") 
local CoreGui=game:GetService("CoreGui") 
local Players=game:GetService("Players") 
local LocalPlayer=Players.LocalPlayer 
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE = "VZMenuConfig.json"

local defaultConfig = {
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
	Sensitivity = 1.0
}

local config = {}
for k, v in pairs(defaultConfig) do
	config[k] = v
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode(config))
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(data) == "table" then
				for k, v in pairs(data) do
					if defaultConfig[k] ~= nil and type(v) == type(defaultConfig[k]) then
						config[k] = v
					end
				end
			end
		end
	end)
end

loadConfig()

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

-- Tab / Scrolling Frame untuk Fitur Tambahan
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(0.95, 0, 0.82, 0)
ContentContainer.Position = UDim2.new(0.025, 0, 0.12, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.CanvasSize = UDim2.new(0, 0, 2.5, 0)
ContentContainer.ScrollBarThickness = 6
ContentContainer.ZIndex = 5
ContentContainer.Parent = MenuFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ContentContainer

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

-- Shift Lock & Crosshair Setup
_G.ShiftLocked = false
local crosshair = Instance.new("Frame")
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6,6)
crosshair.Position = UDim2.new(0.5,-3,0.5,-3)
crosshair.BackgroundColor3 = Color3.new(1,1,1)
crosshair.BorderSizePixel = 0
crosshair.Visible = false
crosshair.ZIndex = 1000000
crosshair.Parent = ScreenGui

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1,0)
cc.Parent = crosshair

local btnShiftLock = Instance.new("ImageButton")
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(0.5,0.5)
btnShiftLock.Position = UDim2.new(config.ShiftX,0,config.ShiftY,0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize,config.ShiftSize)
btnShiftLock.Image = "rbxassetid://136616143786672"
btnShiftLock.BackgroundColor3 = Color3.fromRGB(255,255,255)
btnShiftLock.BackgroundTransparency = 0.2
btnShiftLock.AutoButtonColor = false
btnShiftLock.Active = true
btnShiftLock.BorderSizePixel = 0
btnShiftLock.ZIndex = 100000
btnShiftLock.Parent = ScreenGui

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(1,0)
sc.Parent = btnShiftLock

local function toggleShiftLock()
	_G.ShiftLocked = not _G.ShiftLocked
	crosshair.Visible = _G.ShiftLocked
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.AutoRotate = not _G.ShiftLocked
		character.Humanoid.CameraOffset = Vector3.zero
	end
end

btnShiftLock.Activated:Connect(toggleShiftLock)

CreateHeader("--- SHIFT LOCK MOBILE ---")
CreateButton("ShiftToggleBtn", "Toggle Shift Lock On/Off", function()
	toggleShiftLock()
end)

CreateHeader("--- JUMP SETTING ---")
local targetSettingMode = "JUMP"

CreateButton("ModeJumpToggle", "Target Setting: JUMP BUTTON", function(btn)
	if targetSettingMode == "JUMP" then
		targetSettingMode = "SHIFT"
		btn.Text = "Target Setting: SHIFT LOCK"
	else
		targetSettingMode = "JUMP"
		btn.Text = "Target Setting: JUMP BUTTON"
	end
end)

local jumpButtonRef
local function getJumpButton()
	if jumpButtonRef and jumpButtonRef.Parent then return jumpButtonRef end
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then
		jumpButtonRef = touchGui:FindFirstChild("JumpButton", true)
	end
	return jumpButtonRef
end

local function updateJumpPos()
	local jBtn = getJumpButton()
	if jBtn then
		jBtn.AnchorPoint = Vector2.new(0.5, 0.5)
		jBtn.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
	end
end

CreateButton("MoveUp", "Jump/Shift Pos [ ↑ ]", function()
	if targetSettingMode == "JUMP" then
		config.JumpY = math.clamp(config.JumpY - 0.05, 0.05, 0.95)
		updateJumpPos()
	else
		config.ShiftY = math.clamp(config.ShiftY - 0.05, 0.05, 0.95)
		btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	end
end)

CreateButton("MoveDown", "Jump/Shift Pos [ ↓ ]", function()
	if targetSettingMode == "JUMP" then
		config.JumpY = math.clamp(config.JumpY + 0.05, 0.05, 0.95)
		updateJumpPos()
	else
		config.ShiftY = math.clamp(config.ShiftY + 0.05, 0.05, 0.95)
		btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	end
end)

CreateButton("MoveLeft", "Jump/Shift Pos [ ← ]", function()
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX - 0.05, 0.05, 0.95)
		updateJumpPos()
	else
		config.ShiftX = math.clamp(config.ShiftX - 0.05, 0.05, 0.95)
		btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	end
end)

CreateButton("MoveRight", "Jump/Shift Pos [ → ]", function()
	if targetSettingMode == "JUMP" then
		config.JumpX = math.clamp(config.JumpX + 0.05, 0.05, 0.95)
		updateJumpPos()
	else
		config.ShiftX = math.clamp(config.ShiftX + 0.05, 0.05, 0.95)
		btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	end
end)

CreateButton("SizePlus", "SIZE +", function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize + 0.05, 0.05, 0.50)
		local jBtn = getJumpButton()
		if jBtn then
			local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
			jBtn.Size = UDim2.fromOffset(sz, sz)
		end
	else
		config.ShiftSize = math.clamp(config.ShiftSize + 5, 20, 100)
		btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	end
end)

CreateButton("SizeMinus", "SIZE -", function()
	if targetSettingMode == "JUMP" then
		config.JumpSize = math.clamp(config.JumpSize - 0.05, 0.05, 0.50)
		local jBtn = getJumpButton()
		if jBtn then
			local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
			jBtn.Size = UDim2.fromOffset(sz, sz)
		end
	else
		config.ShiftSize = math.clamp(config.ShiftSize - 5, 20, 100)
		btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	end
end)

CreateButton("ResetConfig", "RESET DEFAULT SETTING", function()
	config.JumpX = defaultConfig.JumpX
	config.JumpY = defaultConfig.JumpY
	config.JumpSize = defaultConfig.JumpSize
	config.ShiftX = defaultConfig.ShiftX
	config.ShiftY = defaultConfig.ShiftY
	config.ShiftSize = defaultConfig.ShiftSize
	updateJumpPos()
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
end)

-- EMOTE & DANCE SECTION
CreateHeader("--- EMOTES & DANCES ---")

local function PlayAnimation(assetId)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(assetId)
		local loadAnim = char.Humanoid:LoadAnimation(anim)
		loadAnim:Play()
	end
end

CreateButton("Dance1", "DANCE 1 ★", function() PlayAnimation(507710273) end)
CreateButton("Dance2", "DANCE 2 ★", function() PlayAnimation(507719543) end)
CreateButton("Emote1", "EMOTE 1 ★", function() PlayAnimation(591577311) end)
CreateButton("Emote2", "EMOTE 2 ★", function() PlayAnimation(591578361) end)
CreateButton("JumpStyle", "Jump Style ★", function() PlayAnimation(3338871789) end)

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
	
	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if camera and root then
			local _, y = camera.CFrame:ToOrientation()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
		end
	end
end)
