local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")
local CoreGui=game:GetService("CoreGui")

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=CoreGui

local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.fromOffset(58,58)
OpenMenu.Position=UDim2.new(0.05,0,0.12,0)
OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2
OpenMenu.BorderSizePixel=0
OpenMenu.AutoButtonColor=false
OpenMenu.Active=true
OpenMenu.Visible=true
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
Image.Size=UDim2.new(0.8,0,0.8,0)
Image.Position=UDim2.new(0.1,0,0.1,0)
Image.BackgroundTransparency=1
Image.BorderSizePixel=0
Image.Image="rbxassetid://95844752147381"
Image.ImageColor3=Color3.fromRGB(255,255,255)
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
LoadingScreen.Size=UDim2.fromScale(1,1)
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
LogoStroke.Thickness=3.5
LogoStroke.Color=Color3.fromRGB(255,255,255)
LogoStroke.Parent=LogoImage

local LogoGradient=Instance.new("UIGradient")
LogoGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})
LogoGradient.Parent=LogoStroke

local LoadingTitle=Instance.new("TextLabel")
LoadingTitle.Size=UDim2.new(1,0,0,60)
LoadingTitle.Position=UDim2.new(0,0,0.52,0)
LoadingTitle.BackgroundTransparency=1
LoadingTitle.Text="ALDO ZORA XORE"
LoadingTitle.TextColor3=Color3.fromRGB(255,255,255)
LoadingTitle.Font=Enum.Font.GothamBlack
LoadingTitle.TextSize=45
LoadingTitle.ZIndex=21
LoadingTitle.Parent=LoadingScreen

local TitleStroke=Instance.new("UIStroke")
TitleStroke.Thickness=6
TitleStroke.Color=Color3.fromRGB(255,255,255)
TitleStroke.Parent=LoadingTitle

local TitleInner=Instance.new("TextLabel")
TitleInner.Size=UDim2.fromScale(1,1)
TitleInner.BackgroundTransparency=1
TitleInner.Text="ALDO ZORA XORE"
TitleInner.TextColor3=Color3.fromRGB(255,255,255)
TitleInner.Font=Enum.Font.GothamBlack
TitleInner.TextSize=45
TitleInner.ZIndex=22
TitleInner.Parent=LoadingTitle

local InnerStroke=Instance.new("UIStroke")
InnerStroke.Thickness=2.5
InnerStroke.Color=Color3.fromRGB(255,255,255)
InnerStroke.Parent=TitleInner

local TitleGradient=Instance.new("UIGradient")
TitleGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
})
TitleGradient.Parent=InnerStroke

local BarBackground=Instance.new("Frame")
BarBackground.Size=UDim2.new(0.3,0,0.01,0)
BarBackground.AnchorPoint=Vector2.new(0.5,0)
BarBackground.Position=UDim2.new(0.5,0,0.68,0)
BarBackground.BackgroundColor3=Color3.fromRGB(30,30,30)
BarBackground.BorderSizePixel=0
BarBackground.ZIndex=21
BarBackground.Parent=LoadingScreen

local BarCorner=Instance.new("UICorner")
BarCorner.CornerRadius=UDim.new(1,0)
BarCorner.Parent=BarBackground

local BarFill=Instance.new("Frame")
BarFill.Size=UDim2.new(0,0,1,0)
BarFill.BackgroundColor3=Color3.fromRGB(255,255,255)
BarFill.BorderSizePixel=0
BarFill.ZIndex=22
BarFill.Parent=BarBackground

local BarFillCorner=Instance.new("UICorner")
BarFillCorner.CornerRadius=UDim.new(1,0)
BarFillCorner.Parent=BarFill

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
local TitleAnim=TweenService:Create(TitleGradient,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Offset=Vector2.new(1,0)})
local PulseAnim=TweenService:Create(LoadingText,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.6})

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
	TitleAnim:Play()
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
		TweenService:Create(LoadingTitle,FadeInfo,{TextTransparency=1}),
		TweenService:Create(TitleInner,FadeInfo,{TextTransparency=1}),
		TweenService:Create(TitleStroke,FadeInfo,{Transparency=1}),
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
	TitleAnim:Cancel()
	PulseAnim:Cancel()

	LoadingScreen.Visible=false
	LoadingScreen.BackgroundTransparency=0
	LogoImage.ImageTransparency=0
	LogoStroke.Transparency=0
	LoadingTitle.TextTransparency=0
	TitleInner.TextTransparency=0
	TitleStroke.Transparency=0
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
