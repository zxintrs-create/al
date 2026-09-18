local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAX_CHECKPOINTS = 30
local GUI_TITLE = "👑 AldoVS TELEPORT"
local SAVE_FILE = "teleport_checkpoints.json"
local currentMode = "Set Lokasi"
local isMinimized = false
local guiElements = {}

local checkpoints = {}

local autoTeleport = false
local loopEnabled = false
local TELEPORT_DELAY = 0.5

local currentPlatform = nil

local function notify(text)
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[Teleport Tool]: " .. text,
		Color = Color3.fromRGB(0, 255, 100),
	})
end

-- Fungsi Membuat/Menghapus Pijakan Invisible
local function clearPlatform()
	if currentPlatform then
		currentPlatform:Destroy()
		currentPlatform = nil
	end
end

local function createPlatform(cframe)
	clearPlatform()

	local platform = Instance.new("Part")
	platform.Name = "TeleportPlatform_Invisible"
	platform.Size = Vector3.new(6, 1, 6)
	platform.CFrame = cframe * CFrame.new(0, -3.5, 0) -- Berada di bawah kaki karakter
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 1 -- Completely invisible
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = workspace

	currentPlatform = platform
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
end

local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(60, 60, 60)
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

-- Serialize checkpoints
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

-- Deserialize checkpoints
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
	mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	mainFrame.BorderSizePixel = 0
	mainFrame.Position = UDim2.new(1, -330, 0.5, -270)
	mainFrame.Size = UDim2.new(0, 310, 0, 540)
	mainFrame.Active = true
	addCorner(mainFrame, 12)
	addStroke(mainFrame, Color3.fromRGB(255, 170, 0), 2)

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
	titleLabel.TextSize = 15
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Parent = titleBar
	minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Position = UDim2.new(1, -65, 0, 8)
	minimizeButton.Size = UDim2.new(0, 28, 0, 28)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.Text = "−"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.TextSize = 16
	addCorner(minimizeButton, 6)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Parent = titleBar
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Position = UDim2.new(1, -32, 0, 8)
	closeButton.Size = UDim2.new(0, 28, 0, 28)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	addCorner(closeButton, 6)

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
	modeFrame.Size = UDim2.new(1, 0, 0, 36)

	local setLokasiButton = Instance.new("TextButton")
	setLokasiButton.Name = "SetLokasiButton"
	setLokasiButton.Parent = modeFrame
	setLokasiButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	setLokasiButton.BorderSizePixel = 0
	setLokasiButton.Position = UDim2.new(0, 0, 0, 0)
	setLokasiButton.Size = UDim2.new(0.48, 0, 1, 0)
	setLokasiButton.Font = Enum.Font.GothamBold
	setLokasiButton.Text = "SET LOKASI"
	setLokasiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	setLokasiButton.TextSize = 12
	addCorner(setLokasiButton, 6)

	local teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportButton"
	teleportButton.Parent = modeFrame
	teleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	teleportButton.BorderSizePixel = 0
	teleportButton.Position = UDim2.new(0.52, 0, 0, 0)
	teleportButton.Size = UDim2.new(0.48, 0, 1, 0)
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.Text = "TELEPORT"
	teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	teleportButton.TextSize = 12
	addCorner(teleportButton, 6)

	local actionFrame = Instance.new("Frame")
	actionFrame.Name = "ActionFrame"
	actionFrame.Parent = contentFrame
	actionFrame.BackgroundTransparency = 1
	actionFrame.Position = UDim2.new(0, 0, 0, 44)
	actionFrame.Size = UDim2.new(1, 0, 0, 80)

	local autoButton = Instance.new("TextButton")
	autoButton.Name = "AutoTeleportButton"
	autoButton.Parent = actionFrame
	autoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	autoButton.BorderSizePixel = 0
	autoButton.Position = UDim2.new(0, 0, 0, 0)
	autoButton.Size = UDim2.new(0.48, 0, 0, 34)
	autoButton.Font = Enum.Font.GothamBold
	autoButton.Text = "AUTO TELEPORT"
	autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	autoButton.TextSize = 11
	addCorner(autoButton, 6)

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Parent = actionFrame
	loopButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	loopButton.BorderSizePixel = 0
	loopButton.Position = UDim2.new(0.52, 0, 0, 0)
	loopButton.Size = UDim2.new(0.48, 0, 0, 34)
	loopButton.Font = Enum.Font.GothamBold
	loopButton.Text = "LOOP: OFF"
	loopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loopButton.TextSize = 11
	addCorner(loopButton, 6)

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Parent = actionFrame
	stopButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	stopButton.BorderSizePixel = 0
	stopButton.Position = UDim2.new(0, 0, 0, 40)
	stopButton.Size = UDim2.new(1, 0, 0, 34)
	stopButton.Font = Enum.Font.GothamBold
	stopButton.Text = "⛔ STOP AUTO"
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.TextSize = 12
	addCorner(stopButton, 6)

	local fileFrame = Instance.new("Frame")
	fileFrame.Name = "FileFrame"
	fileFrame.Parent = contentFrame
	fileFrame.BackgroundTransparency = 1
	fileFrame.Position = UDim2.new(0, 0, 0, 130)
	fileFrame.Size = UDim2.new(1, 0, 0, 32)

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Parent = fileFrame
	saveButton.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
	saveButton.BorderSizePixel = 0
	saveButton.Position = UDim2.new(0, 0, 0, 0)
	saveButton.Size = UDim2.new(0.48, 0, 1, 0)
	saveButton.Font = Enum.Font.GothamBold
	saveButton.Text = "💾 SAVE"
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.TextSize = 12
	addCorner(saveButton, 6)

	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Parent = fileFrame
	loadButton.BackgroundColor3 = Color3.fromRGB(30, 100, 180)
	loadButton.BorderSizePixel = 0
	loadButton.Position = UDim2.new(0.52, 0, 0, 0)
	loadButton.Size = UDim2.new(0.48, 0, 1, 0)
	loadButton.Font = Enum.Font.GothamBold
	loadButton.Text = "📂 LOAD"
	loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadButton.TextSize = 12
	addCorner(loadButton, 6)

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Parent = contentFrame
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.new(0, 0, 0, 170)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -170)
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	addCorner(scrollingFrame, 8)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ListLayout"
	listLayout.Parent = scrollingFrame
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)

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
		cpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		cpButton.BorderSizePixel = 0
		cpButton.Size = UDim2.new(1, 0, 0, 38)
		cpButton.Font = Enum.Font.GothamMedium
		cpButton.Text = "CP" .. i
		cpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		cpButton.TextSize = 12
		cpButton.TextXAlignment = Enum.TextXAlignment.Center
		cpButton.LayoutOrder = i
		addCorner(cpButton, 6)
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

	if currentMode == "Set Lokasi" then
		guiElements.SetLokasiButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
		guiElements.TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	else
		guiElements.SetLokasiButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		guiElements.TeleportButton.BackgroundColor3 = Color3.fromRGB(220, 100, 0)
	end

	if autoTeleport then
		guiElements.AutoTeleportButton.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
		guiElements.AutoTeleportButton.Text = "AUTO: ON"
	else
		guiElements.AutoTeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		guiElements.AutoTeleportButton.Text = "AUTO TELEPORT"
	end

	if loopEnabled then
		guiElements.LoopButton.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
		guiElements.LoopButton.Text = "LOOP: ON"
	else
		guiElements.LoopButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		guiElements.LoopButton.Text = "LOOP: OFF"
	end

	for i = 1, MAX_CHECKPOINTS do
		local cpButton = guiElements.ScrollingFrame:FindFirstChild("CP" .. i)
		if cpButton then
			local cpName = "CP" .. i
			local checkpointData = checkpoints[cpName]
			if checkpointData then
				local x, y, z = checkpointData:GetComponents()
				cpButton.Text = string.format("%s | X: %.1f  Y: %.1f  Z: %.1f", cpName, x, y, z)
				cpButton.BackgroundColor3 = Color3.fromRGB(35, 120, 65)
			else
				if currentMode == "Set Lokasi" then
					cpButton.Text = cpName
					cpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				else
					cpButton.Text = cpName .. " (Kosong)"
					cpButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
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

local function teleportToCheckpoint(index, isLastPoint)
	local character = player.Character
	if not character then return false end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	local target = checkpoints["CP" .. index]
	if not target then return false end

	root.CFrame = target

	-- Jika BUKAN titik terakhir, buat pijakan invisible
	if not isLastPoint then
		createPlatform(target)
	else
		clearPlatform() -- Hapus pijakan jika berada di titik terakhir
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
				if not autoTeleport then break end
				if not checkpoints["CP" .. i] then break end

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

-- Init Setup
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
	notify(loopEnabled and "Loop ON." or "Loop OFF.")
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
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	if isMinimized then
		guiElements.MinimizeButton.Text = "+"
		guiElements.ContentFrame.Visible = false
		TweenService:Create(guiElements.MainFrame, tweenInfo, { Size = UDim2.new(0, 310, 0, 45) }):Play()
	else
		guiElements.MinimizeButton.Text = "−"
		guiElements.ContentFrame.Visible = true
		TweenService:Create(guiElements.MainFrame, tweenInfo, { Size = UDim2.new(0, 310, 0, 540) }):Play()
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
				checkpoints[cpName] = root.CFrame
				notify("Lokasi " .. cpName .. " telah disimpan!")
				updateUI()
			elseif currentMode == "Teleport" then
				local lastCheckpoint = getLastCheckpoint()
				local isLastPoint = (cpIndex == lastCheckpoint)

				if checkpoints[cpName] then
					teleportToCheckpoint(cpIndex, isLastPoint)
					notify("Berhasil teleport ke " .. cpName .. "!")
				else
					notify(cpName .. " belum disimpan!")
				end
			end
		end)
	end
end

updateUI()
