local RunService=game:GetService("RunService")
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VZMenu"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=game:GetService("CoreGui")
local OpenButton=Instance.new("ImageButton")
OpenButton.Name="OpenButton"
OpenButton.Size=UDim2.fromOffset(58,58)
OpenButton.Position=UDim2.new(0.05,0,0.15,0)
OpenButton.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenButton.BackgroundTransparency=0.2
OpenButton.BorderSizePixel=0
OpenButton.AutoButtonColor=false
OpenButton.Active=true
OpenButton.Image=""
OpenButton.ZIndex=10
OpenButton.Parent=ScreenGui
local OpenCorner=Instance.new("UICorner")
OpenCorner.CornerRadius=UDim.new(8,0)
OpenCorner.Parent=OpenButton
local OpenStroke=Instance.new("UIStroke")
OpenStroke.Thickness=2
OpenStroke.Color=Color3.fromRGB(255,255,255)
OpenStroke.Parent=OpenButton
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
Image.ImageTransparency=0
Image.ImageColor3=Color3.fromRGB(255,255,255)
Image.ScaleType=Enum.ScaleType.Fit
Image.Visible=true
Image.ZIndex=20
Image.Parent=OpenButton
local ImageCorner=Instance.new("UICorner")
ImageCorner.CornerRadius=UDim.new(8,0)
ImageCorner.Parent=Image
local ImageRotation=0
local ImageSpeed=45
RunService.RenderStepped:Connect(function(dt)
ImageRotation=(ImageRotation+ImageSpeed*dt)%360
Image.Rotation=ImageRotation
end)
OpenButton.Activated:Connect(function()
end)
