local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.fromOffset(58,58)
OpenMenu.Position=UDim2.new(0.05,0,0.5,0)
OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2
OpenMenu.ZIndex=10
OpenMenu.Parent=ScreenGui

local OpenCorner=Instance.new("UICorner")
OpenCorner.CornerRadius=UDim.new(8,0)
OpenCorner.Parent=OpenMenu

local OpenStroke=Instance.new("UIStroke")
OpenStroke.Thickness=2
OpenStroke.Parent=OpenMenu

local OpenGradient=Instance.new("UIGradient")
OpenGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
OpenGradient.Parent=OpenStroke

TweenService:Create(
	OpenGradient,
	TweenInfo.new(4,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),
	{Offset=Vector2.new(1,0)}
):Play()

local IconImage=Instance.new("ImageLabel")
IconImage.Name="Icon"
IconImage.Size=UDim2.new(0.8,0,0.8,0)
IconImage.Position=UDim2.new(0.1,0,0.1,0)
IconImage.BackgroundTransparency=1
IconImage.Image="rbxassetid://101640388423900"
IconImage.ZIndex=11
IconImage.Parent=OpenMenu

local MenuFrame=Instance.new("Frame")
MenuFrame.Name="MenuFrame"
MenuFrame.Size=UDim2.fromOffset(650,450)
MenuFrame.Position=UDim2.new(0.5,-325,0.5,-225)
MenuFrame.BackgroundColor3=Color3.fromRGB(12,12,18)
MenuFrame.BorderSizePixel=0
MenuFrame.Active=true
MenuFrame.Visible=false
MenuFrame.ZIndex=2
MenuFrame.Parent=ScreenGui

local MenuCorner=Instance.new("UICorner")
MenuCorner.CornerRadius=UDim.new(0,8)
MenuCorner.Parent=MenuFrame

local MenuStroke=Instance.new("UIStroke")
MenuStroke.Thickness=2
MenuStroke.Parent=MenuFrame

local MenuGradient=Instance.new("UIGradient")
MenuGradient.Color=ColorSequence.new({
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))
})
MenuGradient.Parent=MenuStroke

TweenService:Create(
	MenuGradient,
	TweenInfo.new(4,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),
	{Offset=Vector2.new(1,0)}
):Play()

local OpenDragging=false
local OpenDragStart
local OpenStartPosition

OpenMenu.InputBegan:Connect(function(Input)
	if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
		OpenDragging=true
		OpenDragStart=Input.Position
		OpenStartPosition=OpenMenu.Position
	end
end)

OpenMenu.InputEnded:Connect(function(Input)
	if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
		OpenDragging=false
	end
end)

local MenuDragging=false
local MenuDragStart
local MenuStartPosition

MenuFrame.InputBegan:Connect(function(Input)
	if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
		MenuDragging=true
		MenuDragStart=Input.Position
		MenuStartPosition=MenuFrame.Position
	end
end)

MenuFrame.InputEnded:Connect(function(Input)
	if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then
		MenuDragging=false
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if Input.UserInputType~=Enum.UserInputType.MouseMovement and Input.UserInputType~=Enum.UserInputType.Touch then
		return
	end

	if OpenDragging then
		local Delta=Input.Position-OpenDragStart
		OpenMenu.Position=UDim2.new(
			OpenStartPosition.X.Scale,
			OpenStartPosition.X.Offset+Delta.X,
			OpenStartPosition.Y.Scale,
			OpenStartPosition.Y.Offset+Delta.Y
		)
	end

	if MenuDragging then
		local Delta=Input.Position-MenuDragStart
		MenuFrame.Position=UDim2.new(
			MenuStartPosition.X.Scale,
			MenuStartPosition.X.Offset+Delta.X,
			MenuStartPosition.Y.Scale,
			MenuStartPosition.Y.Offset+Delta.Y
		)
	end
end)

OpenMenu.Activated:Connect(function()
	MenuFrame.Visible=not MenuFrame.Visible
end)

local StrokeGradients={}

for _,Object in ipairs(ScreenGui:GetDescendants()) do
	if Object:IsA("UIStroke") then
		local Gradient=Object:FindFirstChildOfClass("UIGradient")

		if Gradient then
			table.insert(StrokeGradients,Gradient)
		end
	end
end

local StrokeRotation=0
local StrokeSpeed=45

RunService.RenderStepped:Connect(function(DeltaTime)
	StrokeRotation=(StrokeRotation+(StrokeSpeed*DeltaTime))%360

	for _,Gradient in ipairs(StrokeGradients) do
		if Gradient and Gradient.Parent then
			Gradient.Rotation=StrokeRotation
		end
	end
end)
