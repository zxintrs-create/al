-- TOUCH EDGE GUARD • DELTA EXECUTOR

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
	return
end

local EDGE_SIZE = 35
local STROKE_SIZE = 3

local GUI_NAME = "VZ_TouchEdgeGuard"

local function getParent()
	local ok, hui = pcall(function()
		if type(gethui) == "function" then
			return gethui()
		end
	end)

	if ok and hui then
		return hui
	end

	return CoreGui
end

local Parent = getParent()

pcall(function()
	local old = Parent:FindFirstChild(GUI_NAME)
	if old then
		old:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = Parent

local function createGuard(name, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = ""
	button.TextTransparency = 1
	button.AutoButtonColor = false
	button.Active = true
	button.Selectable = false
	button.Modal = true
	button.ZIndex = 2147483647
	button.Parent = ScreenGui

	button.Activated:Connect(function()
	end)

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			return
		end
	end)

	return button
end

local Top = createGuard(
	"TopTouchGuard",
	UDim2.fromOffset(0, 0),
	UDim2.new(1, 0, 0, EDGE_SIZE)
)

local Bottom = createGuard(
	"BottomTouchGuard",
	UDim2.new(0, 0, 1, -EDGE_SIZE),
	UDim2.new(1, 0, 0, EDGE_SIZE)
)

local Left = createGuard(
	"LeftTouchGuard",
	UDim2.fromOffset(0, EDGE_SIZE),
	UDim2.new(0, EDGE_SIZE, 1, -EDGE_SIZE * 2)
)

local Right = createGuard(
	"RightTouchGuard",
	UDim2.new(1, -EDGE_SIZE, 0, EDGE_SIZE),
	UDim2.new(0, EDGE_SIZE, 1, -EDGE_SIZE * 2)
)

local Border = Instance.new("Frame")
Border.Name = "EdgeBorder"
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 0
Border.Position = UDim2.fromOffset(
	EDGE_SIZE / 2,
	EDGE_SIZE / 2
)
Border.Size = UDim2.new(
	1,
	-EDGE_SIZE,
	1,
	-EDGE_SIZE
)
Border.ZIndex = 2147483646
Border.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 48)
Corner.Parent = Border

local Stroke = Instance.new("UIStroke")
Stroke.Name = "UIStroke"
Stroke.Thickness = STROKE_SIZE
Stroke.Transparency = 0.05
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Border

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Name = "UIGradient"

StrokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
})

StrokeGradient.Rotation = 0
StrokeGradient.Offset = Vector2.new(-1, 0)
StrokeGradient.Parent = Stroke

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Name = "NeonGlow"
GlowStroke.Thickness = 8
GlowStroke.Transparency = 0.78
GlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
GlowStroke.Parent = Border

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Name = "NeonGradient"

GlowGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 220, 255)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 120, 255)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 70, 255)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 210)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
})

GlowGradient.Rotation = 0
GlowGradient.Offset = Vector2.new(-1, 0)
GlowGradient.Parent = GlowStroke

local StrokeTween = TweenService:Create(
	StrokeGradient,
	TweenInfo.new(
		2.4,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1,
		false
	),
	{
		Offset = Vector2.new(1, 0)
	}
)

StrokeTween:Play()

local GlowTween = TweenService:Create(
	GlowGradient,
	TweenInfo.new(
		3.2,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1,
		false
	),
	{
		Offset = Vector2.new(1, 0)
	}
)

GlowTween:Play()

local function updateSize()
	local size = ScreenGui.AbsoluteSize

	Top.Position = UDim2.fromOffset(0, 0)
	Top.Size = UDim2.new(1, 0, 0, EDGE_SIZE)

	Bottom.Position = UDim2.new(0, 0, 1, -EDGE_SIZE)
	Bottom.Size = UDim2.new(1, 0, 0, EDGE_SIZE)

	Left.Position = UDim2.fromOffset(0, EDGE_SIZE)
	Left.Size = UDim2.fromOffset(
		EDGE_SIZE,
		math.max(0, size.Y - EDGE_SIZE * 2)
	)

	Right.Position = UDim2.new(1, -EDGE_SIZE, 0, EDGE_SIZE)
	Right.Size = UDim2.fromOffset(
		EDGE_SIZE,
		math.max(0, size.Y - EDGE_SIZE * 2)
	)

	Border.Position = UDim2.fromOffset(
		EDGE_SIZE / 2,
		EDGE_SIZE / 2
	)

	Border.Size = UDim2.new(
		1,
		-EDGE_SIZE,
		1,
		-EDGE_SIZE
	)
end

ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)

task.defer(function()
	updateSize()
end)

_G.VZTouchEdgeGuard = {
	Enabled = true,

	SetEdge = function(value)
		local n = tonumber(value)

		if not n then
			return
		end

		EDGE_SIZE = math.clamp(n, 10, 100)
		updateSize()
	end,

	Enable = function()
		Top.Active = true
		Bottom.Active = true
		Left.Active = true
		Right.Active = true

		Border.Visible = true

		_G.VZTouchEdgeGuard.Enabled = true
	end,

	Disable = function()
		Top.Active = false
		Bottom.Active = false
		Left.Active = false
		Right.Active = false

		Border.Visible = false

		_G.VZTouchEdgeGuard.Enabled = false
	end,

	Toggle = function()
		if _G.VZTouchEdgeGuard.Enabled then
			_G.VZTouchEdgeGuard.Disable()
		else
			_G.VZTouchEdgeGuard.Enable()
		end
	end,

	Destroy = function()
		pcall(function()
			StrokeTween:Cancel()
			GlowTween:Cancel()
		end)

		ScreenGui:Destroy()
		_G.VZTouchEdgeGuard = nil
	end
}
