local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_CHECKPOINTS = 30
local GUI_TITLE = "👑 AldoVYSR TELEPON V2"
local SAVE_FOLDER = "teleport_saves/"
local currentSaveFileName = "TELEPORT_1"

local currentMode = "Set Lokasi"
local tpMethod = "Instan" -- DEFAULT DIUBAH KE INSTAN
local isMinimized = false
local guiElements = {}
local checkpoints = {}

local historyStack = {}
local redoStack = {}
local MAX_HISTORY_STEPS = 20

local autoTeleport = false
local loopEnabled = false
local TELEPORT_DELAY = 0.5
local TWEEN_SPEED = 0.02
local currentPlatform = nil

-- Warna Tema
local CYAN = Color3.fromRGB(0, 255, 255)
local PURPLE = Color3.fromRGB(145, 0, 255)
local COLOR_ACTIVE_GREEN = Color3.fromRGB(0, 200, 100)
local COLOR_INACTIVE_GRAY = Color3.fromRGB(45, 45, 55)
local COLOR_CP_FILLED_SET = Color3.fromRGB(0, 140, 70)
local COLOR_CP_TELEPORT = Color3.fromRGB(140, 40, 200)
local COLOR_RED_OFF = Color3.fromRGB(180, 40, 40)

pcall(function()
	if isfolder and not isfolder(SAVE_FOLDER) then
		makefolder(SAVE_FOLDER)
	end
end)

local function notify(text)
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[Teleport Tool]: " .. text,
			Color = CYAN
		})
	end)
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, thickness)
	local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = thickness or 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent

	local oldGradient = stroke:FindFirstChild("CyanPurpleGradient")
	if oldGradient then oldGradient:Destroy() end

	local gradient = Instance.new("UIGradient")
	gradient.Name = "CyanPurpleGradient"
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CYAN),
		ColorSequenceKeypoint.new(0.5, PURPLE),
		ColorSequenceKeypoint.new(1, CYAN)
	})
	gradient.Rotation = 0
	gradient.Parent = stroke

	task.spawn(function()
		while gradient and gradient.Parent do
			local tween = TweenService:Create(
				gradient,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Rotation = gradient.Rotation + 360}
			)
			tween:Play()
			tween.Completed:Wait()
		end
	end)

	return stroke
end

local function clearPlatform()
	if currentPlatform then
		currentPlatform:Destroy()
		currentPlatform = nil
	end
end

local function cloneCheckpoints()
	local copy = {}
	for k, v in pairs(checkpoints) do copy[k] = v end
	return copy
end

local function pushHistory()
	table.insert(historyStack, cloneCheckpoints())
	if #historyStack > MAX_HISTORY_STEPS then table.remove(historyStack, 1) end
	table.clear(redoStack)
end

local function serializeCheckpoints()
	local entries = {}
	for i = 1, MAX_CHECKPOINTS do
		local cpName = "CP" .. i
		local data = checkpoints[cpName]
		if data then
			local x, y, z = data:GetComponents()
			table.insert(entries, string.format("%s={%.4f,%.4f,%.4f}", cpName, x, y, z))
		end
	end
	return table.concat(entries, "\n")
end

local function deserializeCheckpoints(content)
	local loaded = {}
	for line in content:gmatch("[^\r\n]+") do
		local cpName, xStr, yStr, zStr = line:match("^(%w+)=%{(%S+),(%S+),(%S+)%}$")
		if cpName and xStr and yStr and zStr then
			local x, y, z = tonumber(xStr), tonumber(yStr), tonumber(zStr)
			if x and y and z then loaded[cpName] = CFrame.new(x, y, z) end
		end
	end
	return loaded
end

local function getSaveFilePath(name)
	local safeName = name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
	return SAVE_FOLDER .. safeName .. ".json"
end

local function saveCheckpointsToFile(fileName)
	if not fileName or fileName == "" then fileName = currentSaveFileName end
	local filePath = getSaveFilePath(fileName)

	local success, err = pcall(function()
		if writefile then writefile(filePath, serializeCheckpoints()) end
	end)

	if success then
		currentSaveFileName = fileName
		notify("Berhasil disimpan ke: " .. fileName)
	else
		notify("Gagal menyimpan: " .. tostring(err))
	end
end

local function loadCheckpointsFromFile(fileName)
	local filePath = getSaveFilePath(fileName)
	local success, content = pcall(function()
		if readfile then return readfile(filePath) end
	end)

	if not success or not content then
		notify("File " .. fileName .. " tidak ditemukan!")
		return false
	end

	pushHistory()
	table.clear(checkpoints)

	local loaded = deserializeCheckpoints(content)
	local count = 0
	for cpName, cframe in pairs(loaded) do
		checkpoints[cpName] = cframe
		count += 1
	end

	currentSaveFileName = fileName
	notify("Memuat " .. count .. " checkpoint dari: " .. fileName)
	if updateUI then updateUI() end
	return true
end

local function createTeleportGui()
	local oldGui = playerGui:FindFirstChild("TeleportToolGui")
	if oldGui then oldGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportToolGui"
	screenGui.Parent = playerGui
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local openButton = Instance.new("TextButton")
	openButton.Name = "OpenButtonTp"
	openButton.Parent = screenGui
	openButton.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	openButton.Position = UDim2.new(1, -70, 0.5, -150)
	openButton.Size = UDim2.fromOffset(50, 50)
	openButton.Font = Enum.Font.GothamBold
	openButton.Text = "TP"
	openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	openButton.TextSize = 18
	openButton.Active = true
	openButton.Draggable = true
	addCorner(openButton, 25)
	addStroke(openButton, 2)

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Parent = screenGui
	mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	mainFrame.BorderSizePixel = 0
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
	mainFrame.Size = UDim2.new(0, 310, 0, 575)
	mainFrame.Active = true
	mainFrame.Visible = false
	addCorner(mainFrame, 12)
	addStroke(mainFrame, 2)

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Parent = mainFrame
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.new(1, 0, 0, 45)
	addCorner(titleBar, 12)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Parent = titleBar
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = GUI_TITLE
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Parent = titleBar
	minimizeButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Position = UDim2.new(1, -65, 0, 8)
	minimizeButton.Size = UDim2.new(0, 28, 0, 28)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.Text = "−"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 16
	addCorner(minimizeButton, 6)
	addStroke(minimizeButton, 1)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Parent = titleBar
	closeButton.BackgroundColor3 = COLOR_RED_OFF
	closeButton.BorderSizePixel = 0
	closeButton.Position = UDim2.new(1, -32, 0, 8)
	closeButton.Size = UDim2.new(0, 28, 0, 28)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	addCorner(closeButton, 6)
	addStroke(closeButton, 1)

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Parent = mainFrame
	contentFrame.BackgroundTransparency = 1
	contentFrame.Position = UDim2.new(0, 10, 0, 52)
	contentFrame.Size = UDim2.new(1, -20, 1, -60)

	local modeFrame = Instance.new("Frame")
	modeFrame.Name = "ModeFrame"
	modeFrame.Parent = contentFrame
	modeFrame.BackgroundTransparency = 1
	modeFrame.Size = UDim2.new(1, 0, 0, 32)

	local setLokasiButton = Instance.new("TextButton")
	setLokasiButton.Name = "SetLokasiButton"
	setLokasiButton.Parent = modeFrame
	setLokasiButton.BackgroundColor3 = COLOR_ACTIVE_GREEN
	setLokasiButton.BorderSizePixel = 0
	setLokasiButton.Size = UDim2.new(0.38, 0, 1, 0)
	setLokasiButton.Font = Enum.Font.GothamBold
	setLokasiButton.Text = "SET LOKASI"
	setLokasiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	setLokasiButton.TextSize = 10
	addCorner(setLokasiButton, 6)
	addStroke(setLokasiButton, 1)

	local teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportButton"
	teleportButton.Parent = modeFrame
	teleportButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	teleportButton.BorderSizePixel = 0
	teleportButton.Position = UDim2.new(0.40, 0, 0, 0)
	teleportButton.Size = UDim2.new(0.38, 0, 1, 0)
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.Text = "TELEPORT"
	teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	teleportButton.TextSize = 10
	addCorner(teleportButton, 6)
	addStroke(teleportButton, 1)

	local undoButton = Instance.new("TextButton")
	undoButton.Name = "UndoButton"
	undoButton.Parent = modeFrame
	undoButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	undoButton.BorderSizePixel = 0
	undoButton.Position = UDim2.new(0.80, 0, 0, 0)
	undoButton.Size = UDim2.new(0.09, 0, 1, 0)
	undoButton.Font = Enum.Font.GothamBold
	undoButton.Text = "↩️"
	undoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	undoButton.TextSize = 12
	addCorner(undoButton, 6)
	addStroke(undoButton, 1)

	local redoButton = Instance.new("TextButton")
	redoButton.Name = "RedoButton"
	redoButton.Parent = modeFrame
	redoButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	redoButton.BorderSizePixel = 0
	redoButton.Position = UDim2.new(0.91, 0, 0, 0)
	redoButton.Size = UDim2.new(0.09, 0, 1, 0)
	redoButton.Font = Enum.Font.GothamBold
	redoButton.Text = "↪️"
	redoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	redoButton.TextSize = 12
	addCorner(redoButton, 6)
	addStroke(redoButton, 1)

	local methodFrame = Instance.new("Frame")
	methodFrame.Name = "MethodFrame"
	methodFrame.Parent = contentFrame
	methodFrame.BackgroundTransparency = 1
	methodFrame.Position = UDim2.new(0, 0, 0, 38)
	methodFrame.Size = UDim2.new(1, 0, 0, 32)

	local methodToggleBtn = Instance.new("TextButton")
	methodToggleBtn.Name = "MethodToggleBtn"
	methodToggleBtn.Parent = methodFrame
	methodToggleBtn.BackgroundColor3 = COLOR_INACTIVE_GRAY
	methodToggleBtn.BorderSizePixel = 0
	methodToggleBtn.Size = UDim2.new(0.38, 0, 1, 0)
	methodToggleBtn.Font = Enum.Font.GothamBold
	methodToggleBtn.Text = "MODE: INSTAN"
	methodToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	methodToggleBtn.TextSize = 10
	addCorner(methodToggleBtn, 6)
	addStroke(methodToggleBtn, 1)

	local speedSubFrame = Instance.new("Frame")
	speedSubFrame.Name = "SpeedSubFrame"
	speedSubFrame.Parent = methodFrame
	speedSubFrame.BackgroundTransparency = 1
	speedSubFrame.Position = UDim2.new(0.40, 0, 0, 0)
	speedSubFrame.Size = UDim2.new(0.60, 0, 1, 0)

	local speedDownBtn = Instance.new("TextButton")
	speedDownBtn.Name = "SpeedDownBtn"
	speedDownBtn.Parent = speedSubFrame
	speedDownBtn.BackgroundColor3 = COLOR_INACTIVE_GRAY
	speedDownBtn.BorderSizePixel = 0
	speedDownBtn.Size = UDim2.new(0, 24, 1, 0)
	speedDownBtn.Font = Enum.Font.GothamBold
	speedDownBtn.Text = "-"
	speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedDownBtn.TextSize = 12
	addCorner(speedDownBtn, 5)
	addStroke(speedDownBtn, 1)

	local speedDisplay = Instance.new("TextButton")
	speedDisplay.Name = "SpeedDisplay"
	speedDisplay.Parent = speedSubFrame
	speedDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	speedDisplay.BorderSizePixel = 0
	speedDisplay.Position = UDim2.new(0, 28, 0, 0)
	speedDisplay.Size = UDim2.new(1, -56, 1, 0)
	speedDisplay.Font = Enum.Font.GothamBold
	speedDisplay.Text = string.format("Spd: %.3fs", TWEEN_SPEED)
	speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedDisplay.TextSize = 10
	addCorner(speedDisplay, 5)
	addStroke(speedDisplay, 1)

	local speedUpBtn = Instance.new("TextButton")
	speedUpBtn.Name = "SpeedUpBtn"
	speedUpBtn.Parent = speedSubFrame
	speedUpBtn.BackgroundColor3 = COLOR_INACTIVE_GRAY
	speedUpBtn.BorderSizePixel = 0
	speedUpBtn.Position = UDim2.new(1, -24, 0, 0)
	speedUpBtn.Size = UDim2.new(0, 24, 1, 0)
	speedUpBtn.Font = Enum.Font.GothamBold
	speedUpBtn.Text = "+"
	speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedUpBtn.TextSize = 12
	addCorner(speedUpBtn, 5)
	addStroke(speedUpBtn, 1)

	local actionFrame = Instance.new("Frame")
	actionFrame.Name = "ActionFrame"
	actionFrame.Parent = contentFrame
	actionFrame.BackgroundTransparency = 1
	actionFrame.Position = UDim2.new(0, 0, 0, 75)
	actionFrame.Size = UDim2.new(1, 0, 0, 72)

	local autoButton = Instance.new("TextButton")
	autoButton.Name = "AutoTeleportButton"
	autoButton.Parent = actionFrame
	autoButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	autoButton.BorderSizePixel = 0
	autoButton.Size = UDim2.new(0.48, 0, 0, 32)
	autoButton.Font = Enum.Font.GothamBold
	autoButton.Text = "AUTO TELEPORT"
	autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoButton.TextSize = 10
	addCorner(autoButton, 6)
	addStroke(autoButton, 1)

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Parent = actionFrame
	loopButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	loopButton.BorderSizePixel = 0
	loopButton.Position = UDim2.new(0.52, 0, 0, 0)
	loopButton.Size = UDim2.new(0.48, 0, 0, 32)
	loopButton.Font = Enum.Font.GothamBold
	loopButton.Text = "LOOP: OFF"
	loopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loopButton.TextSize = 10
	addCorner(loopButton, 6)
	addStroke(loopButton, 1)

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Parent = actionFrame
	stopButton.BackgroundColor3 = COLOR_RED_OFF
	stopButton.BorderSizePixel = 0
	stopButton.Position = UDim2.new(0, 0, 0, 36)
	stopButton.Size = UDim2.new(1, 0, 0, 32)
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "⛔ STOP AUTO"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 11
	addCorner(stopButton, 6)
	addStroke(stopButton, 1)

	local fileFrame = Instance.new("Frame")
	fileFrame.Name = "FileFrame"
	fileFrame.Parent = contentFrame
	fileFrame.BackgroundTransparency = 1
	fileFrame.Position = UDim2.new(0, 0, 0, 152)
	fileFrame.Size = UDim2.new(1, 0, 0, 30)

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Parent = fileFrame
	saveButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	saveButton.BorderSizePixel = 0
	saveButton.Size = UDim2.new(0.32, 0, 1, 0)
	saveButton.Font = Enum.Font.GothamBold
	saveButton.Text = "💾 SAVE"
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.TextSize = 10
	addCorner(saveButton, 6)
	addStroke(saveButton, 1)

	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Parent = fileFrame
	loadButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	loadButton.BorderSizePixel = 0
	loadButton.Position = UDim2.new(0.34, 0, 0, 0)
	loadButton.Size = UDim2.new(0.32, 0, 1, 0)
	loadButton.Font = Enum.Font.GothamBold
	loadButton.Text = "📂 LOAD"
	loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadButton.TextSize = 10
	addCorner(loadButton, 6)
	addStroke(loadButton, 1)

	local fileSlotButton = Instance.new("TextButton")
	fileSlotButton.Name = "FileSlotButton"
	fileSlotButton.Parent = fileFrame
	fileSlotButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
	fileSlotButton.BorderSizePixel = 0
	fileSlotButton.Position = UDim2.new(0.68, 0, 0, 0)
	fileSlotButton.Size = UDim2.new(0.32, 0, 1, 0)
	fileSlotButton.Font = Enum.Font.GothamBold
	fileSlotButton.Text = currentSaveFileName
	fileSlotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	fileSlotButton.TextSize = 9
	addCorner(fileSlotButton, 6)
	addStroke(fileSlotButton, 1)

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Parent = contentFrame
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.new(0, 0, 0, 188)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -188)
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollBarImageColor3 = CYAN
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	addCorner(scrollingFrame, 8)
	addStroke(scrollingFrame, 1)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ListLayout"
	listLayout.Parent = scrollingFrame
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)

	local listPadding = Instance.new("UIPadding")
	listPadding.Name = "ListPadding"
	listPadding.Parent = scrollingFrame
	listPadding.PaddingTop = UDim.new(0, 5)
	listPadding.PaddingBottom = UDim.new(0, 5)
	listPadding.PaddingLeft = UDim.new(0, 5)
	listPadding.PaddingRight = UDim.new(0, 5)

	for i = 1, MAX_CHECKPOINTS do
		local cpButton = Instance.new("TextButton")
		cpButton.Name = "CP" .. i
		cpButton.Parent = scrollingFrame
		cpButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
		cpButton.BorderSizePixel = 0
		cpButton.Size = UDim2.new(1, 0, 0, 35)
		cpButton.Font = Enum.Font.GothamMedium
		cpButton.Text = "CP" .. i
		cpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		cpButton.TextSize = 11
		cpButton.TextXAlignment = Enum.TextXAlignment.Center
		cpButton.LayoutOrder = i
		addCorner(cpButton, 6)
		addStroke(cpButton, 1)
	end

	return {
		ScreenGui = screenGui,
		OpenButton = openButton,
		MainFrame = mainFrame,
		TitleBar = titleBar,
		MinimizeButton = minimizeButton,
		CloseButton = closeButton,
		ContentFrame = contentFrame,
		SetLokasiButton = setLokasiButton,
		TeleportButton = teleportButton,
		UndoButton = undoButton,
		RedoButton = redoButton,
		MethodToggleBtn = methodToggleBtn,
		SpeedDisplay = speedDisplay,
		SpeedUpBtn = speedUpBtn,
		SpeedDownBtn = speedDownBtn,
		AutoTeleportButton = autoButton,
		LoopButton = loopButton,
		StopButton = stopButton,
		SaveButton = saveButton,
		LoadButton = loadButton,
		FileSlotButton = fileSlotButton,
		ScrollingFrame = scrollingFrame
	}
end

local function makeDraggable(objectToMove, dragHandle)
	local dragging = false
	local dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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

function updateUI()
	if not guiElements.SetLokasiButton then return end

	-- Warna Mode
	if currentMode == "Set Lokasi" then
		guiElements.SetLokasiButton.BackgroundColor3 = COLOR_ACTIVE_GREEN
		guiElements.TeleportButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	else
		guiElements.SetLokasiButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
		guiElements.TeleportButton.BackgroundColor3 = COLOR_CP_TELEPORT
	end

	-- Status Mode TP (Default: Instan)
	if tpMethod == "Tween" then
		guiElements.MethodToggleBtn.Text = "MODE: TWEEN"
		guiElements.MethodToggleBtn.BackgroundColor3 = COLOR_ACTIVE_GREEN
		guiElements.SpeedDisplay.Visible = true
		guiElements.SpeedUpBtn.Visible = true
		guiElements.SpeedDownBtn.Visible = true
	else
		guiElements.MethodToggleBtn.Text = "MODE: INSTAN"
		guiElements.MethodToggleBtn.BackgroundColor3 = COLOR_INACTIVE_GRAY
		guiElements.SpeedDisplay.Visible = false
		guiElements.SpeedUpBtn.Visible = false
		guiElements.SpeedDownBtn.Visible = false
	end

	-- Auto TP & Loop
	if autoTeleport then
		guiElements.AutoTeleportButton.Text = "AUTO: ON"
		guiElements.AutoTeleportButton.BackgroundColor3 = COLOR_ACTIVE_GREEN
	else
		guiElements.AutoTeleportButton.Text = "AUTO TELEPORT"
		guiElements.AutoTeleportButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	end

	if loopEnabled then
		guiElements.LoopButton.Text = "LOOP: ON"
		guiElements.LoopButton.BackgroundColor3 = COLOR_ACTIVE_GREEN
	else
		guiElements.LoopButton.Text = "LOOP: OFF"
		guiElements.LoopButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
	end

	guiElements.SpeedDisplay.Text = string.format("Spd: %.3fs", TWEEN_SPEED)
	guiElements.FileSlotButton.Text = currentSaveFileName

	-- CP Buttons
	for i = 1, MAX_CHECKPOINTS do
		local cpName = "CP" .. i
		local cpButton = guiElements.ScrollingFrame:FindFirstChild(cpName)

		if cpButton then
			local hasData = checkpoints[cpName] ~= nil

			if currentMode == "Set Lokasi" then
				cpButton.Visible = true
				if hasData then
					cpButton.Text = cpName .. " [Tersimpan]"
					cpButton.BackgroundColor3 = COLOR_CP_FILLED_SET
				else
					cpButton.Text = cpName .. " [Kosong]"
					cpButton.BackgroundColor3 = COLOR_INACTIVE_GRAY
				end
			elseif currentMode == "Teleport" then
				if hasData then
					cpButton.Visible = true
					cpButton.Text = "🚀 " .. cpName
					cpButton.BackgroundColor3 = COLOR_CP_TELEPORT
				else
					cpButton.Visible = false
				end
			end
		end
	end
end

local function getLastCheckpoint()
	local last = 0
	for i = 1, MAX_CHECKPOINTS do
		if checkpoints["CP" .. i] then last = i end
	end
	return last
end

local function createPlatform(cframe)
	clearPlatform()
	local platform = Instance.new("Part")
	platform.Name = "TeleportPlatform_Invisible"
	platform.Size = Vector3.new(6, 1, 6)
	platform.CFrame = cframe * CFrame.new(0, -3.5, 0)
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 1
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = workspace

	currentPlatform = platform
end

local function teleportToCheckpoint(index, isLastPoint)
	local character = player.Character
	if not character then return false end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	local target = checkpoints["CP" .. index]
	if not target then return false end

	if tpMethod == "Instan" then
		root.CFrame = target
	else
		local tweenInfo = TweenInfo.new(
			TWEEN_SPEED,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(root, tweenInfo, {CFrame = target})
		tween:Play()
		tween.Completed:Wait()
	end

	if not isLastPoint then
		createPlatform(target)
	else
		clearPlatform()
	end

	return true
end

local function stopAutoTeleport()
	autoTeleport = false
	clearPlatform()
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
				if not autoTeleport or not checkpoints["CP" .. i] then break end
				local isLastPoint = (i == currentLast)
				teleportToCheckpoint(i, isLastPoint)
				task.wait(TELEPORT_DELAY)
			end

			if not loopEnabled then break end
			task.wait(TELEPORT_DELAY)
		end

		autoTeleport = false
		updateUI()
	end)
end

local function openFileListWindow(modeType)
	local existingPopup = playerGui:FindFirstChild("FilePopupGui")
	if existingPopup then existingPopup:Destroy() end

	local popupGui = Instance.new("ScreenGui")
	popupGui.Name = "FilePopupGui"
	popupGui.Parent = playerGui
	popupGui.ResetOnSpawn = false
	popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local popFrame = Instance.new("Frame")
	popFrame.Parent = popupGui
	popFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
	popFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	popFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	popFrame.Size = UDim2.new(0, 280, 0, 350)
	addCorner(popFrame, 12)
	addStroke(popFrame, 2)

	local popTitle = Instance.new("TextLabel")
	popTitle.Parent = popFrame
	popTitle.BackgroundTransparency = 1
	popTitle.Size = UDim2.new(1, 0, 0, 40)
	popTitle.Font = Enum.Font.GothamBold
	popTitle.Text = (modeType == "LOAD") and "📂 PILIH SAVE UNTUK DIMUAT" or "💾 PILIH SLOT SAVE"
	popTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	popTitle.TextSize = 12

	local closePop = Instance.new("TextButton")
	closePop.Parent = popFrame
	closePop.BackgroundColor3 = COLOR_RED_OFF
	closePop.Position = UDim2.new(1, -32, 0, 6)
	closePop.Size = UDim2.new(0, 26, 0, 26)
	closePop.Font = Enum.Font.GothamBold
	closePop.Text = "×"
	closePop.TextColor3 = Color3.fromRGB(255, 255, 255)
	closePop.TextSize = 16
	addCorner(closePop, 6)
	addStroke(closePop, 1)

	closePop.MouseButton1Click:Connect(function()
		popupGui:Destroy()
	end)

	local popScroll = Instance.new("ScrollingFrame")
	popScroll.Parent = popFrame
	popScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	popScroll.BorderSizePixel = 0
	popScroll.Position = UDim2.new(0, 10, 0, 45)
	popScroll.Size = UDim2.new(1, -20, 1, -55)
	popScroll.ScrollBarThickness = 4
	popScroll.ScrollBarImageColor3 = CYAN
	popScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	addCorner(popScroll, 8)

	local layout = Instance.new("UIListLayout")
	layout.Parent = popScroll
	layout.Padding = UDim.new(0, 5)

	local files = {}
	pcall(function()
		if listfiles then files = listfiles(SAVE_FOLDER) end
	end)

	local fileNamesFound = {}
	for _, filePath in ipairs(files) do
		local baseName = filePath:match("([^/\\]+)$")
		if baseName then
			local fileName = baseName:match("^(.*)%.json$")
			if fileName then table.insert(fileNamesFound, fileName) end
		end
	end

	if #fileNamesFound == 0 then
		for i = 1, 5 do table.insert(fileNamesFound, "TELEPORT_" .. i) end
	end

	table.sort(fileNamesFound)

	for _, name in ipairs(fileNamesFound) do
		local btn = Instance.new("TextButton")
		btn.Parent = popScroll
		btn.BackgroundColor3 = COLOR_INACTIVE_GRAY
		btn.Size = UDim2.new(1, 0, 0, 35)
		btn.Font = Enum.Font.GothamMedium
		btn.Text = "📁 " .. name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 12
		addCorner(btn, 6)
		addStroke(btn, 1)

		btn.MouseButton1Click:Connect(function()
			if modeType == "LOAD" then
				loadCheckpointsFromFile(name)
			else
				saveCheckpointsToFile(name)
			end
			popupGui:Destroy()
			updateUI()
		end)
	end
end

guiElements = createTeleportGui()
makeDraggable(guiElements.MainFrame, guiElements.TitleBar)

guiElements.OpenButton.MouseButton1Click:Connect(function()
	guiElements.MainFrame.Visible = not guiElements.MainFrame.Visible
end)

guiElements.SetLokasiButton.MouseButton1Click:Connect(function()
	currentMode = "Set Lokasi"
	updateUI()
end)

guiElements.TeleportButton.MouseButton1Click:Connect(function()
	currentMode = "Teleport"
	updateUI()
end)

guiElements.UndoButton.MouseButton1Click:Connect(function()
	if #historyStack > 0 then
		table.insert(redoStack, cloneCheckpoints())
		checkpoints = table.remove(historyStack)
		updateUI()
		notify("Undo berhasil.")
	else
		notify("Tidak ada riwayat untuk di-undo.")
	end
end)

guiElements.RedoButton.MouseButton1Click:Connect(function()
	if #redoStack > 0 then
		table.insert(historyStack, cloneCheckpoints())
		checkpoints = table.remove(redoStack)
		updateUI()
		notify("Redo berhasil.")
	else
		notify("Tidak ada riwayat untuk di-redo.")
	end
end)

guiElements.MethodToggleBtn.MouseButton1Click:Connect(function()
	tpMethod = (tpMethod == "Tween") and "Instan" or "Tween"
	updateUI()
	notify("Mode TP diubah ke: " .. tpMethod)
end)

guiElements.SpeedUpBtn.MouseButton1Click:Connect(function()
	TWEEN_SPEED = math.clamp(TWEEN_SPEED + 0.005, 0.001, 1.0)
	updateUI()
end)

guiElements.SpeedDownBtn.MouseButton1Click:Connect(function()
	TWEEN_SPEED = math.clamp(TWEEN_SPEED - 0.005, 0.001, 1.0)
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
	notify(loopEnabled and "Loop ON." or "Loop OFF.")
end)

guiElements.StopButton.MouseButton1Click:Connect(function()
	stopAutoTeleport()
end)

guiElements.SaveButton.MouseButton1Click:Connect(function()
	openFileListWindow("SAVE")
end)

guiElements.LoadButton.MouseButton1Click:Connect(function()
	openFileListWindow("LOAD")
end)

guiElements.FileSlotButton.MouseButton1Click:Connect(function()
	openFileListWindow("LOAD")
end)

guiElements.MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if isMinimized then
		guiElements.MinimizeButton.Text = "+"
		guiElements.ContentFrame.Visible = false
		TweenService:Create(guiElements.MainFrame, tweenInfo, {Size = UDim2.new(0, 310, 0, 45)}):Play()
	else
		guiElements.MinimizeButton.Text = "−"
		guiElements.ContentFrame.Visible = true
		TweenService:Create(guiElements.MainFrame, tweenInfo, {Size = UDim2.new(0, 310, 0, 575)}):Play()
	end
end)

guiElements.CloseButton.MouseButton1Click:Connect(function()
	autoTeleport = false
	loopEnabled = false
	clearPlatform()
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
				pushHistory()
				checkpoints[cpName] = root.CFrame
				notify("Lokasi " .. cpName .. " telah disimpan!")
				updateUI()
			elseif currentMode == "Teleport" then
				local lastCheckpoint = getLastCheckpoint()
				local isLastPoint = (cpIndex == lastCheckpoint)

				if checkpoints[cpName] then
					teleportToCheckpoint(cpIndex, isLastPoint)
					notify("Berhasil teleport ke " .. cpName .. "!")
				end
			end
		end)
	end
end

updateUI()
