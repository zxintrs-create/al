local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

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

local ShiftLocked=false
local Character
local Humanoid
local RootPart

local function setupCharacter(Char)
	Character=Char
	Humanoid=Char:WaitForChild("Humanoid")
	RootPart=Char:WaitForChild("HumanoidRootPart")
	Humanoid.AutoRotate=not ShiftLocked
end

setupCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

LocalPlayer.CharacterAdded:Connect(setupCharacter)

local ShiftLockButton=Instance.new("ImageButton")
ShiftLockButton.Name="ShiftLockButton"
ShiftLockButton.Size=UDim2.fromOffset(45,45)
ShiftLockButton.Position=UDim2.new(0,20,0,20)
ShiftLockButton.BackgroundColor3=Color3.fromRGB(8,8,8)
ShiftLockButton.BackgroundTransparency=0.05
ShiftLockButton.BorderSizePixel=0
ShiftLockButton.AutoButtonColor=false
ShiftLockButton.Image="rbxassetid://136616143786672"
ShiftLockButton.ImageColor3=Color3.fromRGB(255,255,255)
ShiftLockButton.ImageTransparency=0
ShiftLockButton.ScaleType=Enum.ScaleType.Fit
ShiftLockButton.ZIndex=30
ShiftLockButton.Parent=MenuFrame

local ShiftCorner=Instance.new("UICorner")
ShiftCorner.CornerRadius=UDim.new(1,0)
ShiftCorner.Parent=ShiftLockButton

local ShiftStroke=Instance.new("UIStroke")
ShiftStroke.Thickness=2
ShiftStroke.Color=Color3.fromRGB(255,255,255)
ShiftStroke.Parent=ShiftLockButton

local ShiftGradient=Instance.new("UIGradient")
ShiftGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
ShiftGradient.Parent=ShiftStroke

local Crosshair=Instance.new("Frame")
Crosshair.Name="Crosshair"
Crosshair.AnchorPoint=Vector2.new(0.5,0.5)
Crosshair.Position=UDim2.new(0.5,0,0.5,0)
Crosshair.Size=UDim2.fromOffset(6,6)
Crosshair.BackgroundColor3=Color3.fromRGB(255,255,255)
Crosshair.BorderSizePixel=0
Crosshair.Visible=false
Crosshair.ZIndex=31
Crosshair.Parent=MenuFrame

local CrossCorner=Instance.new("UICorner")
CrossCorner.CornerRadius=UDim.new(1,0)
CrossCorner.Parent=Crosshair

local function updateShiftLock()
	if ShiftLocked then
		ShiftLockButton.BackgroundColor3=Color3.fromRGB(45,145,255)
		Crosshair.Visible=true
	else
		ShiftLockButton.BackgroundColor3=Color3.fromRGB(8,8,8)
		Crosshair.Visible=false
	end
end

ShiftLockButton.Activated:Connect(function()
	ShiftLocked=not ShiftLocked
	if Humanoid and Humanoid.Parent then
		Humanoid.AutoRotate=not ShiftLocked
	end
	updateShiftLock()
end)

local LogoAnim=TweenService:Create(
	LogoGradient,
	TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),
	{Offset=Vector2.new(1,0)}
)

local TextAnim=TweenService:Create(
	TextGradient,
	TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),
	{Offset=Vector2.new(1,0)}
)

local PulseAnim=TweenService:Create(
	LoadingText,
	TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{TextTransparency=0.6}
)

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
	if Loading then
		return
	end
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
	ShiftGradient.Rotation=StrokeRotation
	if ShiftLocked and Character and Character.Parent and Humanoid and Humanoid.Health>0 and RootPart and RootPart.Parent then
		local Camera=workspace.CurrentCamera
		if Camera then
			local Look=Camera.CFrame.LookVector
			local FlatLook=Vector3.new(Look.X,0,Look.Z)
			if FlatLook.Magnitude>0.001 then
				FlatLook=FlatLook.Unit
				RootPart.CFrame=CFrame.lookAt(RootPart.Position,RootPart.Position+FlatLook)
			end
		end
		Humanoid.AutoRotate=false
	end
end)

updateShiftLock()
