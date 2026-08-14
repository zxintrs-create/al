local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
	return
end

local NAME = "VZ_GameplayTouchGuard"
local EDGE = 36
local STROKE = 3

local function getParent()
	local ok, hui = pcall(function()
		return type(gethui) == "function" and gethui() or nil
	end)

	if ok and hui then
		return hui
	end

	return CoreGui
end

local Parent = getParent()

pcall(function()
	local old = Parent:FindFirstChild(NAME)
	if old then
		old:Destroy()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = NAME
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 2147483646
ScreenGui.Parent = Parent

local function Guard(name)
	local b = Instance.new("TextButton")
	b.Name = name
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.Text = ""
	b.TextTransparency = 1
	b.AutoButtonColor = false
	b.Active = true
	b.Selectable = false
	b.Modal = true
	b.ZIndex = 2147483647
	b.Parent = ScreenGui

	b.Activated:Connect(function()
	end)

	return b
end

local Top = Guard("Top")
local Bottom = Guard("Bottom")
local Left = Guard("Left")
local Right = Guard("Right")

local Border = Instance.new("Frame")
Border.Name = "TouchSafeBorder"
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 0
Border.ZIndex = 2147483645
Border.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 45)
Corner.Parent = Border

local Stroke = Instance.new("UIStroke")
Stroke.Name = "UIStroke"
Stroke.Thickness = STROKE
Stroke.Transparency = 0.08
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Border

local Gradient = Instance.new("UIGradient")
Gradient.Name = "UIGradient"
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.18, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.36, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.54, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
Gradient.Offset = Vector2.new(-1, 0)
Gradient.Parent = Stroke

local Glow = Instance.new("UIStroke")
Glow.Name = "NeonGlow"
Glow.Thickness = 8
Glow.Transparency = 0.78
Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Glow.Parent = Border

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Name = "NeonGradient"
GlowGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 130, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 70, 255)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 210)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 120))
})
GlowGradient.Offset = Vector2.new(-1, 0)
GlowGradient.Parent = Glow

TweenService:Create(
	Gradient,
	TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{Offset = Vector2.new(1, 0)}
):Play()

TweenService:Create(
	GlowGradient,
	TweenInfo.new(3.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
	{Offset = Vector2.new(1, 0)}
):Play()

local enabled = true
local gameplay = true

local function setVisible(state)
	enabled = state

	Top.Active = state
	Bottom.Active = state
	Left.Active = state
	Right.Active = state

	Border.Visible = state
end

local function update()
	local size = ScreenGui.AbsoluteSize
	local w = size.X
	local h = size.Y

	Top.Position = UDim2.fromOffset(0, 0)
	Top.Size = UDim2.fromOffset(w, EDGE)

	Bottom.Position = UDim2.fromOffset(0, math.max(0, h - EDGE))
	Bottom.Size = UDim2.fromOffset(w, EDGE)

	Left.Position = UDim2.fromOffset(0, EDGE)
	Left.Size = UDim2.fromOffset(
		EDGE,
		math.max(0, h - EDGE * 2)
	)

	Right.Position = UDim2.fromOffset(math.max(0, w - EDGE), EDGE)
	Right.Size = UDim2.fromOffset(
		EDGE,
		math.max(0, h - EDGE * 2)
	)

	Border.Position = UDim2.fromOffset(
		EDGE / 2,
		EDGE / 2
	)

	Border.Size = UDim2.fromOffset(
		math.max(0, w - EDGE),
		math.max(0, h - EDGE)
	)
end

ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
update()

local function textBoxFocused()
	local focused = UserInputService:GetFocusedTextBox()
	return focused ~= nil
end

local function refresh()
	if not UserInputService.TouchEnabled then
		setVisible(false)
		return
	end

	if not gameplay then
		setVisible(false)
		return
	end

	if textBoxFocused() then
		setVisible(false)
		return
	end

	setVisible(true)
end

UserInputService.TextBoxFocused:Connect(function()
	setVisible(false)
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	task.defer(refresh)
end)

pcall(function()
	GuiService.MenuOpened:Connect(function()
		gameplay = false
		setVisible(false)
	end)

	GuiService.MenuClosed:Connect(function()
		gameplay = true
		task.defer(refresh)
	end)
end)

Player.CharacterAdded:Connect(function()
	task.wait(0.5)
	gameplay = true
	refresh()
end)

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(0.5)

		if gameplay and not textBoxFocused() then
			if not enabled then
				setVisible(true)
			end
		elseif enabled then
			setVisible(false)
		end
	end
end)

_G.VZTouchGuard = {
	Enable = function()
		gameplay = true
		refresh()
	end,

	Disable = function()
		gameplay = false
		setVisible(false)
	end,

	SetEdge = function(value)
		value = tonumber(value)

		if not value then
			return
		end

		EDGE = math.clamp(math.floor(value), 20, 70)
		update()
	end,

	GetEdge = function()
		return EDGE
	end,

	Destroy = function()
		pcall(function()
			ScreenGui:Destroy()
		end)

		_G.VZTouchGuard = nil
	end
}

refresh()
