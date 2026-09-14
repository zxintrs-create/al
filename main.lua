local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_CHECKPOINTS = 30
local GUI_TITLE = "👑 AldoVS CLICKER"
local SAVE_FILE = "teleport_checkpoints.json"
local currentMode = "Set Lokasi"
local isMinimized = false
local guiElements = {}

local checkpoints = {}

local autoTeleport = false
local loopEnabled = false
local TELEPORT_DELAY = 1

local TEXT_COLOR = Color3.fromRGB(0, 0, 0)
local WHITE = Color3.fromRGB(255, 255, 255)

local function notify(text)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[Teleport Tool]: " .. text;
		Color = Color3.fromRGB(0, 255, 100);
	})
end

local function addCorner(parent)
	local corner = Instance.new("UICorner")
	corner.Name = "UICorner"
	corner.CornerRadius = UDim.new(0.8, 0)
	corner.Parent = parent
end

local function addGradient(parent)
	addCorner(parent)

	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Thickness = 2
	stroke.Color = WHITE
	stroke.Parent = parent

	local gradient = Instance.new("UIGradient")
	gradient.Name = "UIGradient"
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})
	gradient.Rotation = 0
	gradient.Parent = stroke

	task.spawn(function()
		while gradient.Parent do
			local tween = TweenService:Create(
				gradient,
				TweenInfo.new(
					2,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut
				),
				{
					Rotation = gradient.Rotation + 360
				}
			)

			tween:Play()
			tween.Completed:Wait()

			if gradient.Parent then
				gradient.Rotation = 0
			end
		end
	end)
end

-- Serialize checkpoints to a JSON-like string for writefile
local function serializeCheckpoints()
	local entries = {}
	for i = 1, MAX_CHECKPOINTS do
		local cpName = "CP" .. i
		local data = checkpoints[cpName]
		if data then
			local x, y, z = data:GetComponents()
			table.insert(entries, string.format(
				'%s={%s,%s,%s}',
				cpName,
				string.format("%.4f", x),
				string.format("%.4f", y),
				string.format("%.4f", z)
			))
		end
	end
	return table.concat(entries, "\n")
end

-- Deserialize checkpoints from file content
local function deserializeCheckpoints(content)
	local loaded = {}
	for line in content:gmatch("[^\r\n]+") do
		local cpName, xStr, yStr, zStr = line:match("^(%w+)=%{(%S+),(%S+),(%S+)%}$")
		if cpName and xStr and yStr and zStr then
			local x, y, z = tonumber(xStr), tonumber(yStr), tonumber(zStr)
			if x and y and z then
				loaded[cpName] = CFrame.new(x, y, z)
			end
		end
	end
	return loaded
end

-- Save checkpoints to file using writefile()
local function saveCheckpointsToFile()
	local success, err = pcall(function()
		local content = serializeCheckpoints()
		writefile(SAVE_FILE, content)
	end)
	if success then
		notify("Checkpoint disimpan ke " .. SAVE_FILE)
	else
		notify("Gagal menyimpan: " .. tostring(err))
	end
end

-- Load checkpoints from file using readfile()
local function loadCheckpointsFromFile()
	local success, content = pcall(function()
		return readfile(SAVE_FILE)
	end)
	if not success or not content then
		notify("Gagal memuat file: " .. tostring(content or "file tidak ditemukan"))
		return false
	end

	local loaded = deserializeCheckpoints(content)
	local count = 0
	for cpName, cframe in pairs(loaded) do
		checkpoints[cpName] = cframe
		count = count + 1
	end

	if count > 0 then
		notify("Loaded " .. count .. " checkpoint dari " .. SAVE_FILE)
		updateUI()
		return true
	else
		notify("Tidak ada checkpoint valid di file")
		return false
	end
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
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Position = UDim2.new(1, -330, 0.5, -270)
	mainFrame.Size = UDim2.new(0, 310, 0, 540)
	mainFrame.Active = true
	addGradient(mainFrame)

	local titleBar = Instance.new("TextLabel")
	titleBar.Name = "TitleBar"
	titleBar.Parent = mainFrame
	titleBar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	titleBar.BorderSizePixel = 0
	titleBar.Position = UDim2.new(0, 6, 0, 6)
	titleBar.Size = UDim2.new(1, -12, 0, 42)
	titleBar.Font = Enum.Font.GothamBold
	titleBar.Text = "  " .. GUI_TITLE
	titleBar.TextColor3 = TEXT_COLOR
	titleBar.TextSize = 17
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.Active = true
	addGradient(titleBar)

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Parent = titleBar
	minimizeButton.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Position = UDim2.new(1, -68, 0, 5)
	minimizeButton.Size = UDim2.new(0, 28, 0, 32)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.Text = "−"
	minimizeButton.TextColor3 = TEXT_COLOR
	minimizeButton.TextSize = 18
	addGradient(minimizeButton)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Parent = titleBar
	closeButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	closeButton.BorderSizePixel = 0
	closeButton.Position = UDim2.new(1, -34, 0, 5)
	closeButton.Size = UDim2.new(0, 28, 0, 32)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "×"
	closeButton.TextColor3 = TEXT_COLOR
	closeButton.TextSize = 19
	addGradient(closeButton)

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Parent = mainFrame
	contentFrame.BackgroundTransparency = 1
	contentFrame.Position = UDim2.new(0, 8, 0, 56)
	contentFrame.Size = UDim2.new(1, -16, 1, -64)

	local modeFrame = Instance.new("Frame")
	modeFrame.Name = "ModeFrame"
	modeFrame.Parent = contentFrame
	modeFrame.BackgroundTransparency = 1
	modeFrame.Size = UDim2.new(1, 0, 0, 42)

	local setLokasiButton = Instance.new("TextButton")
	setLokasiButton.Name = "SetLokasiButton"
	setLokasiButton.Parent = modeFrame
	setLokasiButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	setLokasiButton.BorderSizePixel = 0
	setLokasiButton.Position = UDim2.new(0, 0, 0, 0)
	setLokasiButton.Size = UDim2.new(0.49, 0, 1, 0)
	setLokasiButton.Font = Enum.Font.GothamBold
	setLokasiButton.Text = "SET LOKASI"
	setLokasiButton.TextColor3 = TEXT_COLOR
	setLokasiButton.TextSize = 13
	addGradient(setLokasiButton)

	local teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportButton"
	teleportButton.Parent = modeFrame
	teleportButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	teleportButton.BorderSizePixel = 0
	teleportButton.Position = UDim2.new(0.51, 0, 0, 0)
	teleportButton.Size = UDim2.new(0.49, 0, 1, 0)
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.Text = "TELEPORT"
	teleportButton.TextColor3 = TEXT_COLOR
	teleportButton.TextSize = 13
	addGradient(teleportButton)

	local actionFrame = Instance.new("Frame")
	actionFrame.Name = "ActionFrame"
	actionFrame.Parent = contentFrame
	actionFrame.BackgroundTransparency = 1
	actionFrame.Position = UDim2.new(0, 0, 0, 50)
	actionFrame.Size = UDim2.new(1, 0, 0, 90)

	local autoButton = Instance.new("TextButton")
	autoButton.Name = "AutoTeleportButton"
	autoButton.Parent = actionFrame
	autoButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	autoButton.BorderSizePixel = 0
	autoButton.Position = UDim2.new(0, 0, 0, 0)
	autoButton.Size = UDim2.new(0.48, 0, 0, 40)
	autoButton.Font = Enum.Font.GothamBold
	autoButton.Text = "AUTO TELEPORT"
	autoButton.TextColor3 = TEXT_COLOR
	autoButton.TextSize = 13
	addGradient(autoButton)

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Parent = actionFrame
	loopButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	loopButton.BorderSizePixel = 0
	loopButton.Position = UDim2.new(0.52, 0, 0, 0)
	loopButton.Size = UDim2.new(0.48, 0, 0, 40)
	loopButton.Font = Enum.Font.GothamBold
	loopButton.Text = "LOOP: OFF"
	loopButton.TextColor3 = TEXT_COLOR
	loopButton.TextSize = 13
	addGradient(loopButton)

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Parent = actionFrame
	stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	stopButton.BorderSizePixel = 0
	stopButton.Position = UDim2.new(0, 0, 0, 48)
	stopButton.Size = UDim2.new(1, 0, 0, 38)
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "STOP"
	stopButton.TextColor3 = TEXT_COLOR
	stopButton.TextSize = 13
	addGradient(stopButton)

	-- SAVE and LOAD buttons
	local fileFrame = Instance.new("Frame")
	fileFrame.Name = "FileFrame"
	fileFrame.Parent = contentFrame
	fileFrame.BackgroundTransparency = 1
	fileFrame.Position = UDim2.new(0, 0, 0, 148)
	fileFrame.Size = UDim2.new(1, 0, 0, 36)

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Parent = fileFrame
	saveButton.BackgroundColor3 = Color3.fromRGB(0, 130, 70)
	saveButton.BorderSizePixel = 0
	saveButton.Position = UDim2.new(0, 0, 0, 0)
	saveButton.Size = UDim2.new(0.48, 0, 1, 0)
	saveButton.Font = Enum.Font.GothamBold
	saveButton.Text = "💾 SAVE"
	saveButton.TextColor3 = TEXT_COLOR
	saveButton.TextSize = 13
	addGradient(saveButton)

	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Parent = fileFrame
	loadButton.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
	loadButton.BorderSizePixel = 0
	loadButton.Position = UDim2.new(0.52, 0, 0, 0)
	loadButton.Size = UDim2.new(0.48, 0, 1, 0)
	loadButton.Font = Enum.Font.GothamBold
	loadButton.Text = "📂 LOAD"
	loadButton.TextColor3 = TEXT_COLOR
	loadButton.TextSize = 13
	addGradient(loadButton)

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Parent = contentFrame
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.new(0, 0, 0, 192)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -192)
	scrollingFrame.ScrollBarThickness = 5
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	addGradient(scrollingFrame)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ListLayout"
	listLayout.Parent = scrollingFrame
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)

	local listPadding = Instance.new("UIPadding")
	listPadding.Name = "ListPadding"
	listPadding.Parent = scrollingFrame
	listPadding.PaddingTop = UDim.new(0, 6)
	listPadding.PaddingBottom = UDim.new(0, 6)
	listPadding.PaddingLeft = UDim.new(0, 6)
	listPadding.PaddingRight = UDim.new(0, 6)

	for i = 1, MAX_CHECKPOINTS do
		local cpButton = Instance.new("TextButton")
		cpButton.Name = "CP" .. i
		cpButton.Parent = scrollingFrame
		cpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		cpButton.BorderSizePixel = 0
		cpButton.Size = UDim2.new(1, 0, 0, 36)
		cpButton.Font = Enum.Font.Gotham
		cpButton.Text = "CP" .. i
		cpButton.TextColor3 = TEXT_COLOR
		cpButton.TextSize = 13
		cpButton.TextXAlignment = Enum.TextXAlignment.Center
		cpButton.LayoutOrder = i
		cpButton.AutoButtonColor = false
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
		SaveButton = saveButton,
		LoadButton = loadButton,
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
		guiElements.SetLokasiButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
		guiElements.TeleportButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	else
		guiElements.SetLokasiButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
		guiElements.TeleportButton.BackgroundColor3 = Color3.fromRGB(215, 90, 0)
	end

	if autoTeleport then
		guiElements.AutoTeleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		guiElements.AutoTeleportButton.Text = "AUTO: ON"
	else
		guiElements.AutoTeleportButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
		guiElements.AutoTeleportButton.Text = "AUTO TELEPORT"
	end

	if loopEnabled then
		guiElements.LoopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		guiElements.LoopButton.Text = "LOOP: ON"
	else
		guiElements.LoopButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
		guiElements.LoopButton.Text = "LOOP: OFF"
	end

	for i = 1, MAX_CHECKPOINTS do
		local cpButton = guiElements.ScrollingFrame:FindFirstChild("CP" .. i)
		if cpButton then
			local cpName = "CP" .. i
			local checkpointData = checkpoints[cpName]
			if checkpointData then
				local x, y, z = checkpointData:GetComponents()
				cpButton.Text = string.format(
					"%s\nX: %.1f   Y: %.1f   Z: %.1f",
					cpName, x, y, z
				)
				cpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
			else
				if currentMode == "Set Lokasi" then
					cpButton.Text = cpName
					cpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
				else
					cpButton.Text = cpName .. " (Kosong)"
					cpButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
		end
	end
	return last
end

local function teleportToCheckpoint(index)
	local character = player.Character
	if not character then return false end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	local target = checkpoints["CP" .. index]
	if not target then return false end

	root.CFrame = target
	return true
end

local function stopAutoTeleport()
	autoTeleport = false
	updateUI()
	notify("Auto Teleport dihentikan.")
end

local function startAutoTeleport()
	if autoTeleport then return end

	local lastCheckpoint = getLastCheckpoint()
	if lastCheckpoint < 1 then
		notify("Belum ada CP yang disimpan.")
		return
	end

	autoTeleport = true
	updateUI()
	notify("Auto Teleport: CP1 sampai CP" .. lastCheckpoint)

	task.spawn(function()
		while autoTeleport do
			local currentLast = getLastCheckpoint()
			if currentLast < 1 then break end

			for i = 1, currentLast do
				if not autoTeleport then break end
				if not checkpoints["CP" .. i] then break end

				teleportToCheckpoint(i)
				task.wait(TELEPORT_DELAY)
			end

			if not loopEnabled then break end
			task.wait(TELEPORT_DELAY)
		end
		autoTeleport = false
		updateUI()
	end)
end

guiElements = createTeleportGui()
makeDraggable(guiElements.MainFrame, guiElements.TitleBar)

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

guiElements.SaveButton.MouseButton1Click:Connect(function()
	saveCheckpointsToFile()
end)

guiElements.LoadButton.MouseButton1Click:Connect(function()
	loadCheckpointsFromFile()
end)

guiElements.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local tweenInfo = TweenInfo.new(
		0.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	if isMinimized then
		guiElements.MinimizeButton.Text = "+"
		guiElements.ContentFrame.Visible = false
		TweenService:Create(
			guiElements.MainFrame,
			tweenInfo,
			{ Size = UDim2.new(0, 310, 0, 54) }
		):Play()
	else
		guiElements.MinimizeButton.Text = "−"
		guiElements.ContentFrame.Visible = true
		TweenService:Create(
			guiElements.MainFrame,
			tweenInfo,
			{ Size = UDim2.new(0, 310, 0, 540) }
		):Play()
	end
end)

guiElements.CloseButton.MouseButton1Click:Connect(function()
	autoTeleport = false
	loopEnabled = false
	guiElements.ScreenGui:Destroy()
end)

for i = 1, MAX_CHECKPOINTS do
	local cpButton = guiElements.ScrollingFrame:FindFirstChild("CP" .. i)
	if cpButton then
		local cpIndex = i
		cpButton.MouseButton1Click:Connect(function()
			local character = player.Character
			if not character then
				notify("Karakter tidak ditemukan!")
				return
			end

			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				notify("HumanoidRootPart tidak ditemukan!")
				return
			end

			local cpName = "CP" .. cpIndex
			if currentMode == "Set Lokasi" then
				checkpoints[cpName] = root.CFrame
				notify("Lokasi " .. cpName .. " telah disimpan!")
				updateUI()
			elseif currentMode == "Teleport" then
				local targetCFrame = checkpoints[cpName]
				if targetCFrame then
					root.CFrame = targetCFrame
					notify("Berhasil teleport ke " .. cpName .. "!")
				else
					notify(cpName .. " belum disimpan!")
				end
			end
		end)
	end
end

updateUI()
