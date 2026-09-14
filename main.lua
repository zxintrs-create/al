local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_CHECKPOINTS = 30
local GUI_TITLE = "Teleport Tool"
local currentMode = "Set Lokasi"
local isMinimized = false
local guiElements = {}

local checkpoints = {}

local autoTeleport = false
local loopEnabled = false
local TELEPORT_DELAY = 1

local function notify(text)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[Teleport Tool]: " .. text;
		Color = Color3.fromRGB(0, 255, 100);
	})
end

local function addGradient(parent)
	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = parent

	local gradient = Instance.new("UIGradient")
	gradient.Name = "UIGradient"
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})
	gradient.Parent = stroke

	task.spawn(function()
		while gradient.Parent do
			local tween = TweenService:Create(
				gradient,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Rotation = gradient.Rotation + 360}
			)
			tween:Play()
			tween.Completed:Wait()

			if gradient.Parent then
				gradient.Rotation = 0
			end
		end
	end)
end

local function createTeleportGui()
	local oldGui = playerGui:FindFirstChild("TeleportToolGui")

	if oldGui then
		oldGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportToolGui"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Parent = screenGui
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Position = UDim2.new(1, -160, 0.5, -200)
	mainFrame.Size = UDim2.new(0, 150, 0, 400)
	mainFrame.Active = true

	addGradient(mainFrame)

	local titleBar = Instance.new("TextLabel")
	titleBar.Name = "TitleBar"
	titleBar.Parent = mainFrame
	titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.Font = Enum.Font.GothamBold
	titleBar.Text = GUI_TITLE
	titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleBar.TextSize = 16
	titleBar.Active = true

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Parent = titleBar
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.Position = UDim2.new(1, -50, 0, 0)
	minimizeButton.Size = UDim2.new(0, 25, 1, 0)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.Text = "▼"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 14

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Parent = titleBar
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	closeButton.BorderSizePixel = 0
	closeButton.Position = UDim2.new(1, -25, 0, 0)
	closeButton.Size = UDim2.new(0, 25, 1, 0)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Parent = mainFrame
	contentFrame.BackgroundTransparency = 1
	contentFrame.Position = UDim2.new(0, 0, 0, 30)
	contentFrame.Size = UDim2.new(1, 0, 1, -30)

	local setLokasiButton = Instance.new("TextButton")
	setLokasiButton.Name = "SetLokasiButton"
	setLokasiButton.Parent = contentFrame
	setLokasiButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	setLokasiButton.BorderSizePixel = 0
	setLokasiButton.Position = UDim2.new(0, 5, 0, 5)
	setLokasiButton.Size = UDim2.new(1, -10, 0, 30)
	setLokasiButton.Font = Enum.Font.GothamBold
	setLokasiButton.Text = "Set Lokasi"
	setLokasiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	setLokasiButton.TextSize = 14

	addGradient(setLokasiButton)

	local teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportButton"
	teleportButton.Parent = contentFrame
	teleportButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	teleportButton.BorderSizePixel = 0
	teleportButton.Position = UDim2.new(0, 5, 0, 40)
	teleportButton.Size = UDim2.new(1, -10, 0, 30)
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.Text = "Teleport"
	teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	teleportButton.TextSize = 14

	addGradient(teleportButton)

	local autoButton = Instance.new("TextButton")
	autoButton.Name = "AutoTeleportButton"
	autoButton.Parent = contentFrame
	autoButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	autoButton.BorderSizePixel = 0
	autoButton.Position = UDim2.new(0, 5, 0, 75)
	autoButton.Size = UDim2.new(1, -10, 0, 30)
	autoButton.Font = Enum.Font.GothamBold
	autoButton.Text = "AUTO TELEPORT"
	autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoButton.TextSize = 13

	addGradient(autoButton)

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Parent = contentFrame
	loopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	loopButton.BorderSizePixel = 0
	loopButton.Position = UDim2.new(0, 5, 0, 110)
	loopButton.Size = UDim2.new(1, -10, 0, 30)
	loopButton.Font = Enum.Font.GothamBold
	loopButton.Text = "LOOP: OFF"
	loopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loopButton.TextSize = 13

	addGradient(loopButton)

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Parent = contentFrame
	stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	stopButton.BorderSizePixel = 0
	stopButton.Position = UDim2.new(0, 5, 0, 145)
	stopButton.Size = UDim2.new(1, -10, 0, 30)
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "STOP"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 13

	addGradient(stopButton)

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Parent = contentFrame
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.new(0, 5, 0, 180)
	scrollingFrame.Size = UDim2.new(1, -10, 1, -185)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

	addGradient(scrollingFrame)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = scrollingFrame
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 3)

	for i = 1, MAX_CHECKPOINTS do
		local cpButton = Instance.new("TextButton")
		cpButton.Name = "CP" .. i
		cpButton.Parent = scrollingFrame
		cpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		cpButton.BorderSizePixel = 0
		cpButton.Size = UDim2.new(1, 0, 0, 30)
		cpButton.Font = Enum.Font.Gotham
		cpButton.Text = "CP" .. i
		cpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		cpButton.TextSize = 14
		cpButton.LayoutOrder = i

		addGradient(cpButton)
	end

	return {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		TitleBar = titleBar,
		MinimizeButton = minimizeButton,
		CloseButton = closeButton,
		ContentFrame = contentFrame,
		SetLokasiButton = setLokasiButton,
		TeleportButton = teleportButton,
		AutoTeleportButton = autoButton,
		LoopButton = loopButton,
		StopButton = stopButton,
		ScrollingFrame = scrollingFrame
	}
end

local function makeDraggable(objectToMove, dragHandle)
	local dragging = false
	local dragStart
	local startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = objectToMove.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging then
			local delta = input.Position - dragStart

			objectToMove.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function updateUI()
	if not guiElements.SetLokasiButton then
		return
	end

	if currentMode == "Set Lokasi" then
		guiElements.SetLokasiButton.BackgroundColor3 =
			Color3.fromRGB(0, 120, 215)

		guiElements.TeleportButton.BackgroundColor3 =
			Color3.fromRGB(80, 80, 80)
	else
		guiElements.SetLokasiButton.BackgroundColor3 =
			Color3.fromRGB(80, 80, 80)

		guiElements.TeleportButton.BackgroundColor3 =
			Color3.fromRGB(215, 90, 0)
	end

	if autoTeleport then
		guiElements.AutoTeleportButton.BackgroundColor3 =
			Color3.fromRGB(0, 150, 0)
		guiElements.AutoTeleportButton.Text = "AUTO: ON"
	else
		guiElements.AutoTeleportButton.BackgroundColor3 =
			Color3.fromRGB(80, 80, 80)
		guiElements.AutoTeleportButton.Text = "AUTO TELEPORT"
	end

	if loopEnabled then
		guiElements.LoopButton.BackgroundColor3 =
			Color3.fromRGB(0, 150, 0)
		guiElements.LoopButton.Text = "LOOP: ON"
	else
		guiElements.LoopButton.BackgroundColor3 =
			Color3.fromRGB(80, 80, 80)
		guiElements.LoopButton.Text = "LOOP: OFF"
	end

	for i = 1, MAX_CHECKPOINTS do
		local cpButton =
			guiElements.ScrollingFrame:FindFirstChild("CP" .. i)

		if cpButton then
			local cpName = "CP" .. i
			local checkpointData = checkpoints[cpName]

			if checkpointData then
				local x, y, z = checkpointData:GetComponents()

				cpButton.Text = string.format(
					"%s (%.1f, %.1f, %.1f)",
					cpName,
					x,
					y,
					z
				)

				cpButton.BackgroundColor3 =
					Color3.fromRGB(0, 150, 0)
			else
				if currentMode == "Set Lokasi" then
					cpButton.Text = cpName
					cpButton.BackgroundColor3 =
						Color3.fromRGB(70, 70, 70)
				else
					cpButton.Text = cpName .. " (Kosong)"
					cpButton.BackgroundColor3 =
						Color3.fromRGB(150, 0, 0)
				end
			end
		end
	end
end

local function getLastCheckpoint()
	local last = 0

	for i = 1, MAX_CHECKPOINTS do
		if checkpoints["CP" .. i] then
			last = i
		else
			break
		end
	end

	return last
end

local function teleportToCheckpoint(index)
	local character = player.Character

	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return false
	end

	local target = checkpoints["CP" .. index]

	if not target then
		return false
	end

	root.CFrame = target

	return true
end

local function stopAutoTeleport()
	autoTeleport = false
	updateUI()
	notify("Auto Teleport dihentikan.")
end

local function startAutoTeleport()
	if autoTeleport then
		return
	end

	local lastCheckpoint = getLastCheckpoint()

	if lastCheckpoint < 1 then
		notify("Belum ada CP yang disimpan.")
		return
	end

	autoTeleport = true
	updateUI()

	notify(
		"Auto Teleport: CP1 sampai CP"
			.. lastCheckpoint
	)

	task.spawn(function()
		while autoTeleport do
			local currentLast = getLastCheckpoint()

			if currentLast < 1 then
				break
			end

			for i = 1, currentLast do
				if not autoTeleport then
					break
				end

				if not checkpoints["CP" .. i] then
					break
				end

				teleportToCheckpoint(i)

				task.wait(TELEPORT_DELAY)
			end

			if not loopEnabled then
				break
			end

			task.wait(TELEPORT_DELAY)
		end

		autoTeleport = false
		updateUI()
	end)
end

guiElements = createTeleportGui()

makeDraggable(
	guiElements.MainFrame,
	guiElements.TitleBar
)

guiElements.SetLokasiButton.MouseButton1Click:Connect(function()
	currentMode = "Set Lokasi"
	updateUI()
end)

guiElements.TeleportButton.MouseButton1Click:Connect(function()
	currentMode = "Teleport"
	updateUI()
end)

guiElements.AutoTeleportButton.MouseButton1Click:Connect(function()
	if autoTeleport then
		stopAutoTeleport()
	else
		startAutoTeleport()
	end
end)

guiElements.LoopButton.MouseButton1Click:Connect(function()
	loopEnabled = not loopEnabled
	updateUI()

	if loopEnabled then
		notify("Loop ON.")
	else
		notify("Loop OFF.")
	end
end)

guiElements.StopButton.MouseButton1Click:Connect(function()
	stopAutoTeleport()
end)

guiElements.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	local tweenInfo = TweenInfo.new(
		0.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	if isMinimized then
		guiElements.MinimizeButton.Text = "▲"
		guiElements.ContentFrame.Visible = false

		TweenService:Create(
			guiElements.MainFrame,
			tweenInfo,
			{Size = UDim2.new(0, 150, 0, 30)}
		):Play()
	else
		guiElements.MinimizeButton.Text = "▼"
		guiElements.ContentFrame.Visible = true

		TweenService:Create(
			guiElements.MainFrame,
			tweenInfo,
			{Size = UDim2.new(0, 150, 0, 400)}
		):Play()
	end
end)

guiElements.CloseButton.MouseButton1Click:Connect(function()
	autoTeleport = false
	loopEnabled = false
	guiElements.ScreenGui:Destroy()
end)

for i = 1, MAX_CHECKPOINTS do
	local cpButton =
		guiElements.ScrollingFrame:FindFirstChild("CP" .. i)

	if cpButton then
		local cpIndex = i

		cpButton.MouseButton1Click:Connect(function()
			local character = player.Character

			if not character then
				notify("Karakter tidak ditemukan!")
				return
			end

			local root =
				character:FindFirstChild("HumanoidRootPart")

			if not root then
				notify("HumanoidRootPart tidak ditemukan!")
				return
			end

			local cpName = "CP" .. cpIndex

			if currentMode == "Set Lokasi" then
				checkpoints[cpName] = root.CFrame

				notify(
					"Lokasi "
						.. cpName
						.. " telah disimpan!"
				)

				updateUI()

			elseif currentMode == "Teleport" then
				local targetCFrame =
					checkpoints[cpName]

				if targetCFrame then
					root.CFrame = targetCFrame

					notify(
						"Berhasil teleport ke "
							.. cpName
							.. "!"
					)
				else
					notify(
						cpName
							.. " belum disimpan!"
					)
				end
			end
		end)
	end
end

updateUI()
