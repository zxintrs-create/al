local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not Player or not Camera then
	return
end

local NAME = "VZ_DPI600_TouchGuard"

local X_INSET = 0.062
local Y_INSET = 0.028

local BORDER_THICKNESS = 3
local GLOW_THICKNESS = 8
local CORNER = 42

local function getParent()
	local ok, result = pcall(function()
		if type(gethui) == "function" then
			return gethui()
		end
	end)

	if ok and result then
		return result
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
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = Parent

local function createGuard(name)
	local button = Instance.new("TextButton")

	button.Name = name
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

	return button
end

local TopGuard = createGuard("TopEdgeGuard")
local BottomGuard = createGuard("BottomEdgeGuard")
local LeftGuard = createGuard("LeftEdgeGuard")
local RightGuard = createGuard("RightEdgeGuard")

local Border = Instance.new("Frame")
Border.Name = "DPI600Border"
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 0
Border.ZIndex = 2147483645
Border.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, CORNER)
Corner.Parent = Border

local Stroke = Instance.new("UIStroke")
Stroke.Name = "UIStroke"
Stroke.Thickness = BORDER_THICKNESS
Stroke.Transparency = 0.08
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Border

local Gradient = Instance.new("UIGradient")
Gradient.Name = "UIGradient"

Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.32, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.64, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
})

Gradient.Offset = Vector2.new(-1, 0)
Gradient.Parent = Stroke

local Glow = Instance.new("UIStroke")
Glow.Name = "NeonGlow"
Glow.Thickness = GLOW_THICKNESS
Glow.Transparency = 0.82
Glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Glow.Parent = Border

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Name = "NeonGradient"

GlowGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 220, 255)),
	ColorSequenceKeypoint.new(0.20, Color3.fromRGB(0, 150, 255)),
	ColorSequenceKeypoint.new(0.40, Color3.fromRGB(40, 80, 255)),
	ColorSequenceKeypoint.new(0.60, Color3.fromRGB(120, 40, 255)),
	ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 0, 220)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
})

GlowGradient.Offset = Vector2.new(-1, 0)
GlowGradient.Parent = Glow

local StrokeAnimation = TweenService:Create(
	Gradient,
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

local GlowAnimation = TweenService:Create(
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

StrokeAnimation:Play()
GlowAnimation:Play()

local Enabled = true
local GameplayMode = true

local function setGuardState(state)
	Enabled = state

	TopGuard.Active = state
	BottomGuard.Active = state
	LeftGuard.Active = state
	RightGuard.Active = state

	Border.Visible = state
end

local function getViewport()
	local viewport = Camera.ViewportSize

	if viewport.X <= 0 or viewport.Y <= 0 then
		return 0, 0
	end

	return viewport.X, viewport.Y
end

local function updateLayout()
	local width, height = getViewport()

	if width <= 0 or height <= 0 then
		return
	end

	local left = math.floor(width * X_INSET)
	local right = math.floor(width * X_INSET)
	local top = math.floor(height * Y_INSET)
	local bottom = math.floor(height * Y_INSET)

	local gameplayWidth = math.max(1, width - left - right)
	local gameplayHeight = math.max(1, height - top - bottom)

	TopGuard.Position = UDim2.fromOffset(0, 0)
	TopGuard.Size = UDim2.fromOffset(width, top)

	BottomGuard.Position = UDim2.fromOffset(0, height - bottom)
	BottomGuard.Size = UDim2.fromOffset(width, bottom)

	LeftGuard.Position = UDim2.fromOffset(0, top)
	LeftGuard.Size = UDim2.fromOffset(
		left,
		gameplayHeight
	)

	RightGuard.Position = UDim2.fromOffset(
		width - right,
		top
	)

	RightGuard.Size = UDim2.fromOffset(
		right,
		gameplayHeight
	)

	Border.Position = UDim2.fromOffset(
		left,
		top
	)

	Border.Size = UDim2.fromOffset(
		gameplayWidth,
		gameplayHeight
	)
end

local function isTyping()
	return UserInputService:GetFocusedTextBox() ~= nil
end

local function refresh()
	if not UserInputService.TouchEnabled then
		setGuardState(false)
		return
	end

	if not GameplayMode then
		setGuardState(false)
		return
	end

	if isTyping() then
		setGuardState(false)
		return
	end

	setGuardState(true)
end

updateLayout()

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	updateLayout()
end)

UserInputService.TextBoxFocused:Connect(function()
	setGuardState(false)
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	task.defer(refresh)
end)

pcall(function()
	GuiService.MenuOpened:Connect(function()
		GameplayMode = false
		setGuardState(false)
	end)

	GuiService.MenuClosed:Connect(function()
		GameplayMode = true
		task.defer(refresh)
	end)
end)

Player.CharacterAdded:Connect(function()
	task.wait(0.5)
	GameplayMode = true
	updateLayout()
	refresh()
end)

_G.VZTouchGuard = {
	Enabled = true,

	SetEnabled = function(state)
		if state then
			GameplayMode = true
			refresh()
		else
			GameplayMode = false
			setGuardState(false)
		end
	end,

	SetXInset = function(value)
		value = tonumber(value)

		if not value then
			return
		end

		X_INSET = math.clamp(value / 100, 0.01, 0.15)
		updateLayout()
	end,

	SetYInset = function(value)
		value = tonumber(value)

		if not value then
			return
		end

		Y_INSET = math.clamp(value / 100, 0.01, 0.10)
		updateLayout()
	end,

	Reset = function()
		X_INSET = 0.062
		Y_INSET = 0.028
		updateLayout()
	end,

	Destroy = function()
		pcall(function()
			StrokeAnimation:Cancel()
			GlowAnimation:Cancel()
		end)

		pcall(function()
			ScreenGui:Destroy()
		end)

		_G.VZTouchGuard = nil
	end
}

refresh()
