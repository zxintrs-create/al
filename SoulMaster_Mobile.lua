--// DELTA AUTO CLICKER
--// Fixed 40ms
--// Marker + Drag + ON/OFF + Marker Aktif/Matikan

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CLICK_INTERVAL = 0.04

--==================================================
-- GUI
--==================================================

local old = PlayerGui:FindFirstChild("DeltaAutoClicker")
if old then
	old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAutoClicker"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- HELPERS
--==================================================

local function Stroke(parent)
	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Color = Color3.fromRGB(255,255,255)
	s.Parent = parent

	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
	})
	g.Parent = s

	task.spawn(function()
		while s.Parent do
			g.Rotation = (g.Rotation + 2) % 360
			task.wait()
		end
	end)

	return s
end

local function Round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function Button(parent, text, position)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 150, 0, 42)
	b.Position = position
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextSize = 15
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.AutoButtonColor = false
	b.Parent = parent

	Round(b, 10)
	Stroke(b)

	return b
end

--==================================================
-- OPEN MENU
--==================================================

local OpenMenuClick = Instance.new("TextButton")
OpenMenuClick.Name = "OpenMenuClick"
OpenMenuClick.Size = UDim2.new(0, 48, 0, 48)
OpenMenuClick.Position = UDim2.new(0, 15, 0.5, -24)
OpenMenuClick.BackgroundColor3 = Color3.fromRGB(20,20,20)
OpenMenuClick.Text = "⌁"
OpenMenuClick.TextColor3 = Color3.fromRGB(255,255,255)
OpenMenuClick.TextSize = 28
OpenMenuClick.Font = Enum.Font.GothamBold
OpenMenuClick.Parent = ScreenGui

Round(OpenMenuClick, 12)
Stroke(OpenMenuClick)

--==================================================
-- MAIN MENU
--==================================================

local MainFrameMenuClick = Instance.new("Frame")
MainFrameMenuClick.Name = "MainFrameMenuClick"
MainFrameMenuClick.Size = UDim2.new(0, 180, 0, 145)
MainFrameMenuClick.Position = UDim2.new(0, 70, 0.5, -72)
MainFrameMenuClick.BackgroundColor3 = Color3.fromRGB(15,15,15)
MainFrameMenuClick.Visible = false
MainFrameMenuClick.Parent = ScreenGui

Round(MainFrameMenuClick, 12)
Stroke(MainFrameMenuClick)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "AUTO CLICKER"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrameMenuClick

--==================================================
-- AUTO CLICK TOGGLE
--==================================================

local ToggleClick = Button(
	MainFrameMenuClick,
	"OFF",
	UDim2.new(0, 15, 0, 42)
)

--==================================================
-- MARKER TOGGLE
--==================================================

local MarkerToggle = Button(
	MainFrameMenuClick,
	"MARKER: AKTIF",
	UDim2.new(0, 15, 0, 92)
)

--==================================================
-- MARKER
--==================================================

local ClickMarker = Instance.new("TextButton")
ClickMarker.Name = "ClickMarker"
ClickMarker.Size = UDim2.new(0, 55, 0, 55)
ClickMarker.Position = UDim2.new(0.5, -27, 0.5, -27)
ClickMarker.AnchorPoint = Vector2.new(0,0)
ClickMarker.BackgroundColor3 = Color3.fromRGB(255,255,255)
ClickMarker.BackgroundTransparency = 0.25
ClickMarker.Text = "●"
ClickMarker.TextColor3 = Color3.fromRGB(255,0,0)
ClickMarker.TextSize = 28
ClickMarker.Font = Enum.Font.GothamBold
ClickMarker.AutoButtonColor = false
ClickMarker.Parent = ScreenGui

Round(ClickMarker, 100)
Stroke(ClickMarker)

--==================================================
-- DRAG MARKER
--==================================================

local dragging = false
local dragStart
local startPosition

ClickMarker.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = ClickMarker.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		ClickMarker.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

--==================================================
-- MARKER POSITION
--==================================================

local function GetMarkerPosition()
	local camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	local pos = ClickMarker.AbsolutePosition
	local size = ClickMarker.AbsoluteSize

	local x = math.floor(pos.X + size.X / 2)
	local y = math.floor(pos.Y + size.Y / 2)

	return x, y
end

--==================================================
-- AUTO CLICK
--==================================================

local AutoClick = false

local function DoClick()
	local x, y = GetMarkerPosition()

	if not x or not y then
		return
	end

	if typeof(mousemoveabs) ~= "function" then
		warn("Delta: mousemoveabs tidak tersedia.")
		return
	end

	if typeof(mouse1click) ~= "function" then
		warn("Delta: mouse1click tidak tersedia.")
		return
	end

	mousemoveabs(x, y)
	mouse1click()
end

task.spawn(function()
	while ScreenGui.Parent do
		if AutoClick then
			DoClick()
			task.wait(CLICK_INTERVAL)
		else
			task.wait(0.1)
		end
	end
end)

--==================================================
-- AUTO CLICK BUTTON
--==================================================

ToggleClick.Activated:Connect(function()
	AutoClick = not AutoClick

	if AutoClick then
		ToggleClick.Text = "ON"
		ToggleClick.BackgroundColor3 = Color3.fromRGB(35,35,35)

		-- marker otomatis disembunyikan agar tidak menghalangi klik
		ClickMarker.Visible = false
	else
		ToggleClick.Text = "OFF"

		if MarkerToggle.Text == "MARKER: AKTIF" then
			ClickMarker.Visible = true
		end
	end
end)

--==================================================
-- MARKER VISIBILITY
--==================================================

local MarkerActive = true

MarkerToggle.Activated:Connect(function()
	MarkerActive = not MarkerActive

	if MarkerActive then
		MarkerToggle.Text = "MARKER: AKTIF"

		if not AutoClick then
			ClickMarker.Visible = true
		end
	else
		MarkerToggle.Text = "MARKER: MATIKAN"
		ClickMarker.Visible = false
	end
end)

--==================================================
-- OPEN / CLOSE MENU
--==================================================

OpenMenuClick.Activated:Connect(function()
	MainFrameMenuClick.Visible = not MainFrameMenuClick.Visible
end)
