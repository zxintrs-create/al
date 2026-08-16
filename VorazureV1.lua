local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
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
Image.Image="rbxassetid://101640388423900"
Image.ImageTransparency=0
Image.Visible=true
Image.Rotation=0
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
OpenMenu.Activated:Connect(function()
MenuFrame.Visible=not MenuFrame.Visible
end)
local StrokeRotation=0
local ImageRotation=0
local StrokeSpeed=45
local ImageSpeed=45
RunService.RenderStepped:Connect(function(dt)
StrokeRotation=(StrokeRotation+StrokeSpeed*dt)%360
ImageRotation=(ImageRotation+ImageSpeed*dt)%360
OpenGradient.Rotation=StrokeRotation
MenuGradient.Rotation=StrokeRotation
Image.Rotation=ImageRotation
end)
