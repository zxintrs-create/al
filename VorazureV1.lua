local RunService=game:GetService("RunService")

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=game:GetService("CoreGui")

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
OpenCorner.CornerRadius=UDim.new(0,8)
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

local ImageHolder=Instance.new("Frame")
ImageHolder.Name="ImageHolder"
ImageHolder.Size=UDim2.new(0.8,0,0.8,0)
ImageHolder.Position=UDim2.new(0.1,0,0.1,0)
ImageHolder.BackgroundTransparency=1
ImageHolder.BorderSizePixel=0
ImageHolder.ZIndex=11
ImageHolder.Parent=OpenMenu

local Image=Instance.new("ImageLabel")
Image.Name="Image"
Image.Size=UDim2.fromScale(1,1)
Image.Position=UDim2.fromScale(0,0)
Image.BackgroundTransparency=1
Image.BorderSizePixel=0
Image.Image="rbxassetid://95844752147381"
Image.ImageTransparency=0
Image.ScaleType=Enum.ScaleType.Fit
Image.Visible=true
Image.ZIndex=12
Image.Parent=ImageHolder

local ImageCorner=Instance.new("UICorner")
ImageCorner.CornerRadius=UDim.new(0,8)
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

OpenMenu.Activated:Connect(function()
	MenuFrame.Visible=not MenuFrame.Visible
end)

local StrokeRotation=0
local ImageRotation=0

RunService.RenderStepped:Connect(function(dt)
	StrokeRotation=(StrokeRotation+45*dt)%360
	ImageRotation=(ImageRotation+45*dt)%360

	OpenGradient.Rotation=StrokeRotation
	MenuGradient.Rotation=StrokeRotation
	ImageHolder.Rotation=ImageRotation
end)
