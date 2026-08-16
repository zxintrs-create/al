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
Image.Image="rbxassetid://95844752147381"
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
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local menuFrame = script.Parent
local baseFrame = Instance.new("Frame")
baseFrame.Size = UDim2.new(1, 0, 1, 0) 
baseFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12) 
baseFrame.BorderSizePixel = 0
baseFrame.Parent = menuFrame
local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0, 160, 0, 160)
logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
logoImage.Position = UDim2.new(0.5, 0, 0.35, 0)
logoImage.BackgroundTransparency = 1
logoImage.Image = "rbxassetid://112921115907036"
logoImage.Parent = baseFrame
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 20)
logoCorner.Parent = logoImage
local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(255, 255, 255)
logoStroke.Thickness = 3.5
logoStroke.Parent = logoImage
local logoStrokeGradient = Instance.new("UIGradient")
logoStrokeGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
logoStrokeGradient.Parent = logoStroke
local logoStrokeAnim = TweenService:Create(logoStrokeGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(1, 0)})
logoStrokeAnim:Play()
local outerText = Instance.new("TextLabel")
outerText.Size = UDim2.new(1, 0, 0, 60)
outerText.AnchorPoint = Vector2.new(0.5, 0)
outerText.Position = UDim2.new(0.5, 0, 0.52, 0)
outerText.BackgroundTransparency = 1
outerText.Text = "ALDO ZORA XORE" 
outerText.TextColor3 = Color3.fromRGB(255, 255, 255)
outerText.Font = Enum.Font.GothamBlack 
outerText.TextSize = 45 
outerText.Parent = baseFrame
local outerStroke = Instance.new("UIStroke")
outerStroke.Color = Color3.fromRGB(255, 255, 255) 
outerStroke.Thickness = 6 
outerStroke.Parent = outerText
local innerText = Instance.new("TextLabel")
innerText.Size = UDim2.new(1, 0, 1, 0)
innerText.BackgroundTransparency = 1
innerText.Text = "ALDO ZORA XORE"
innerText.TextColor3 = Color3.fromRGB(255, 255, 255) 
innerText.Font = Enum.Font.GothamBlack
innerText.TextSize = 45
innerText.ZIndex = 2 
innerText.Parent = outerText
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(255, 255, 255) 
innerStroke.Thickness = 2.5 
innerStroke.Parent = innerText
local textGradient = Instance.new("UIGradient")
textGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
textGradient.Parent = innerStroke
local textGradientAnim = TweenService:Create(textGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(1, 0)})
textGradientAnim:Play()
local barBackground = Instance.new("Frame")
barBackground.Size = UDim2.new(0.3, 0, 0.01, 0) 
barBackground.AnchorPoint = Vector2.new(0.5, 0)
barBackground.Position = UDim2.new(0.5, 0, 0.68, 0) 
barBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBackground.BorderSizePixel = 0
barBackground.Parent = baseFrame
local cornerBg = Instance.new("UICorner")
cornerBg.CornerRadius = UDim.new(1, 0)
cornerBg.Parent = barBackground
local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0) 
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBackground
local cornerFill = Instance.new("UICorner")
cornerFill.CornerRadius = UDim.new(1, 0)
cornerFill.Parent = barFill
local barGradient = Instance.new("UIGradient")
barGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 0))
})
barGradient.Parent = barFill
local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 4, 0)
loadingText.AnchorPoint = Vector2.new(0.5, 1)
loadingText.Position = UDim2.new(0.5, 0, -0.5, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "LOADING EXPERIENCE..."
loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingText.Font = Enum.Font.GothamMedium
loadingText.TextSize = 13
loadingText.Parent = barBackground
local pulseAnim = TweenService:Create(loadingText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.6})
pulseAnim:Play()
if not game:IsLoaded() then
game.Loaded:Wait()
end
local fillAnim = TweenService:Create(barFill, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
fillAnim:Play()
fillAnim.Completed:Wait() 
task.wait(0.3)
local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweensToPlay = {
TweenService:Create(baseFrame, fadeInfo, {BackgroundTransparency = 1}),
TweenService:Create(logoImage, fadeInfo, {ImageTransparency = 1}),
TweenService:Create(logoStroke, fadeInfo, {Transparency = 1}),
TweenService:Create(outerText, fadeInfo, {TextTransparency = 1}),
TweenService:Create(innerText, fadeInfo, {TextTransparency = 1}),
TweenService:Create(outerStroke, fadeInfo, {Transparency = 1}),
TweenService:Create(innerStroke, fadeInfo, {Transparency = 1}),
TweenService:Create(barBackground, fadeInfo, {BackgroundTransparency = 1}),
TweenService:Create(barFill, fadeInfo, {BackgroundTransparency = 1}),
TweenService:Create(loadingText, fadeInfo, {TextTransparency = 1})
}
for _, tween in ipairs(tweensToPlay) do
tween:Play()
end
tweensToPlay[1].Completed:Wait()
textGradientAnim:Cancel() 
logoStrokeAnim:Cancel()
pulseAnim:Cancel() 
baseFrame:Destroy()
