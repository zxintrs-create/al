local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CLICK_INTERVAL = 0.04

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaAutoClicker"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenuClick"
openButton.Size = UDim2.fromOffset(52, 52)
openButton.Position = UDim2.new(0, 15, 0.5, -26)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openButton.Text = "CLICK"
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.TextSize = 13
openButton.Font = Enum.Font.GothamBold
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2
openStroke.Color = Color3.new(1, 1, 1)
openStroke.Parent = openButton

local menu = Instance.new("Frame")
menu.Name = "MainFrameMenuClick"
menu.Size = UDim2.fromOffset(220, 210)
menu.Position = UDim2.new(0, 75, 0.5, -105)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.Visible = false
menu.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Thickness = 2
menuStroke.Color = Color3.new(1, 1, 1)
menuStroke.Parent = menu

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 38)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "DELTA AUTO CLICK"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.Parent = menu

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.fromOffset(10, 47)
status.BackgroundTransparency = 1
status.Text = "OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.Parent = menu

local toggle = Instance.new("TextButton")
toggle.Name = "AutoClickToggle"
toggle.Size = UDim2.new(1, -30, 0, 42)
toggle.Position = UDim2.fromOffset(15, 78)
toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggle.Text = "AUTO CLICK : OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 14
toggle.Font = Enum.Font.GothamBold
toggle.Parent = menu

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

local markerToggle = Instance.new("TextButton")
markerToggle.Name = "MarkerVisibility"
markerToggle.Size = UDim2.new(1, -30, 0, 42)
markerToggle.Position = UDim2.fromOffset(15, 128)
markerToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
markerToggle.Text = "MARKER : AKTIF"
markerToggle.TextColor3 = Color3.new(1, 1, 1)
markerToggle.TextSize = 14
markerToggle.Font = Enum.Font.GothamBold
markerToggle.Parent = menu

local markerCorner = Instance.new("UICorner")
markerCorner.CornerRadius = UDim.new(0, 8)
markerCorner.Parent = markerToggle

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.fromOffset(10, 177)
info.BackgroundTransparency = 1
info.Text = "40 MS"
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.TextSize = 13
info.Font = Enum.Font.GothamBold
info.Parent = menu

local marker = Instance.new("TextButton")
marker.Name = "ClickMarker"
marker.Size = UDim2.fromOffset(58, 58)
marker.Position = UDim2.new(0.5, -29, 0.5, -29)
marker.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
marker.BackgroundTransparency = 0.15
marker.Text = "●"
marker.TextColor3 = Color3.new(1, 1, 1)
marker.TextSize = 25
marker.Font = Enum.Font.GothamBold
marker.ZIndex = 100
marker.Parent = gui

local markerCorner = Instance.new("UICorner")
markerCorner.CornerRadius = UDim.new(1, 0)
markerCorner.Parent = marker

local markerStroke = Instance.new("UIStroke")
markerStroke.Thickness = 2
markerStroke.Color = Color3.new(1, 1, 1)
markerStroke.Parent = marker

local clicking = false
local markerVisible = true
local dragging = false
local dragStart
local startPosition

openButton.Activated:Connect(function()
	menu.Visible = not menu.Visible
end)

toggle.Activated:Connect(function()
	clicking = not clicking

	if clicking then
		toggle.Text = "AUTO CLICK : ON"
		toggle.BackgroundColor3 = Color3.fromRGB(35, 130, 65)
		status.Text = "ON • 40 MS"
		status.TextColor3 = Color3.fromRGB(80, 255, 120)
	else
		toggle.Text = "AUTO CLICK : OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		status.Text = "OFF"
		status.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

markerToggle.Activated:Connect(function()
	markerVisible = not markerVisible
	marker.Visible = markerVisible

	if markerVisible then
		markerToggle.Text = "MARKER : AKTIF"
	else
		markerToggle.Text = "MARKER : MATIKAN"
	end
end)

marker.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = marker.Position

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

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		marker.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

local function getButtonAtMarker()
	local center = marker.AbsolutePosition + marker.AbsoluteSize / 2
	local objects = gui:GetGuiObjectsAtPosition(center.X, center.Y)

	for _, object in ipairs(objects) do
		if object ~= marker and object:IsA("GuiButton") then
			return object
		end
	end

	for _, screenGui in ipairs(playerGui:GetChildren()) do
		if screenGui:IsA("ScreenGui") and screenGui ~= gui then
			local objects2 = screenGui:GetGuiObjectsAtPosition(center.X, center.Y)

			for _, object in ipairs(objects2) do
				if object:IsA("GuiButton") and object.Visible then
					return object
				end
			end
		end
	end

	return nil
end

task.spawn(function()
	while gui.Parent do
		if clicking then
			local button = getButtonAtMarker()

			if button then
				pcall(function()
					button:Activate()
				end)
			end
		end

		task.wait(CLICK_INTERVAL)
	end
end)
