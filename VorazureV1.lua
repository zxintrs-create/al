local Players=game:GetService("Players")
local RunService=game:GetService("RunService")

local Player=Players.LocalPlayer
local PlayerGui=Player:WaitForChild("PlayerGui")

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="PremiumMenuGui"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=PlayerGui

local OpenMenu=Instance.new("ImageButton")
OpenMenu.Name="OpenMenu"
OpenMenu.Size=UDim2.fromOffset(58,58)
OpenMenu.Position=UDim2.new(0.05,0,0.25,0)
OpenMenu.BackgroundColor3=Color3.fromRGB(15,15,20)
OpenMenu.BackgroundTransparency=0.2
OpenMenu.BorderSizePixel=0
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

local StrokeGradients={
	OpenGradient,
	MenuGradient
}

local StrokeRotation=0
local StrokeSpeed=45

RunService.RenderStepped:Connect(function(DeltaTime)
	StrokeRotation=(StrokeRotation+StrokeSpeed*DeltaTime)%360

	for i=1,#StrokeGradients do
		local Gradient=StrokeGradients[i]

		if Gradient and Gradient.Parent then
			Gradient.Rotation=StrokeRotation
		end
	end
end)
