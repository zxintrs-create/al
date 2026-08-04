local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

print("========================================")
print("CREATED BY: ALDO KNIGHTXOz")
print("========================================")

local OWNER_NAME = "ALDOGanz_45"
local isOwner = (player.Name == OWNER_NAME)

local isAutoWalking = false
local isAutoJumping = false
local isRecording = false
local isPlayingLine = false
local recordedNodes = {}

-- 1. AUTO WALK
local autoWalkConnection = nil
local function toggleAutoWalk()
	isAutoWalking = not isAutoWalking
	if isAutoWalking then
		autoWalkConnection = RunService.RenderStepped:Connect(function()
			if isAutoWalking and humanoid and rootPart then
				humanoid:Move(rootPart.CFrame.LookVector, false)
			end
		end)
	else
		if autoWalkConnection then
			autoWalkConnection:Disconnect()
			autoWalkConnection = nil
		end
		humanoid:Move(Vector3.new(0, 0, 0), false)
	end
end

-- 2. AUTO JUMP
local function toggleAutoJump()
	isAutoJumping = not isAutoJumping
	task.spawn(function()
		while isAutoJumping do
			if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
				humanoid.Jump = true
			end
			task.wait(0.2)
		end
	end)
end

-- 3. SPEED CONTROLLER
local speeds = {16, 24, 32}
local currentSpeedIndex = 1
local function cycleSpeed()
	currentSpeedIndex = (currentSpeedIndex % #speeds) + 1
	humanoid.WalkSpeed = speeds[currentSpeedIndex]
end

-- VISUAL NODES
local visualNodesFolder = workspace:FindFirstChild("RecordedNodesVisual") or Instance.new("Folder")
visualNodesFolder.Name = "RecordedNodesVisual"
visualNodesFolder.Parent = workspace

local function updateVisuals()
	visualNodesFolder:ClearAllChildren()
	for _, node in ipairs(recordedNodes) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(0.3, 0.3, 0.3)
		part.CFrame = node.cframe - Vector3.new(0, 2, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = node.isJumping and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 180)
		part.Parent = visualNodesFolder
	end
end

-- 4. RECORD LINE (Merekam posisi CFrame dan status lompat)
local function startRecording()
	if not isOwner then return end
	isRecording = not isRecording
	
	if isRecording then
		recordedNodes = {}
		visualNodesFolder:ClearAllChildren()
		print("[ALDO KNIGHTXOz] Status: MEREKAM JALUR...")
		
		task.spawn(function()
			while isRecording do
				if rootPart and humanoid then
					local isJumpingState = (humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall)
					
					table.insert(recordedNodes, {
						cframe = rootPart.CFrame,
						isJumping = isJumpingState
					})
					
					updateVisuals()
				end
				task.wait(0.1)
			end
		end)
	else
		print("[ALDO KNIGHTXOz] Status: SELESAI! Total node: " .. #recordedNodes)
	end
end

-- 5. PLAY LINE (Gunakan Humanoid:MoveTo agar Animasi Bawaan Avatar Berjalan Alami)
local function playLine()
	if not isOwner or #recordedNodes == 0 or isPlayingLine then return end
	isPlayingLine = true
	print("[ALDO KNIGHTXOz] Memutar Jalur dengan Animasi Bawaan...")

	for i = 1, #recordedNodes do
		if not isPlayingLine then break end
		local node = recordedNodes[i]
		local targetCFrame = node.cframe
		local wasJumping = node.isJumping
		
		-- Pemicu status lompat bawaan jika titik direkam saat melompat
		if wasJumping then
			humanoid.Jump = true
		end

		-- MoveTo memicu animasi bawaan avatar secara otomatis tanpa script kustom
		humanoid:MoveTo(targetCFrame.Position)
		
		-- Batas waktu perpindahan per titik
		local distance = (rootPart.Position - targetCFrame.Position).Magnitude
		local timeToWait = math.clamp(distance / humanoid.WalkSpeed, 0.05, 0.3)
		
		task.wait(timeToWait)
	end

	humanoid:Move(Vector3.new(0, 0, 0), false)
	isPlayingLine = false
	print("[ALDO KNIGHTXOz] Playback Selesai!")
end

-- 6. SAVE RECORDER DATA (JSON)
local function saveRecorderData()
	if not isOwner or #recordedNodes == 0 then return end
	
	local rawTable = {}
	for _, node in ipairs(recordedNodes) do
		local cf = node.cframe
		table.insert(rawTable, {cf.X, cf.Y, cf.Z, node.isJumping})
	end
	
	local jsonString = HttpService:JSONEncode(rawTable)
	
	if setclipboard then
		setclipboard(jsonString)
		print("[ALDO KNIGHTXOz] Data JSON berhasil di-copy ke Clipboard!")
	else
		print("[ALDO KNIGHTXOz Data JSON]: " .. jsonString)
	end
end

-- 7. LOAD DATA JSON
local function loadRecorderData(jsonString)
	if not isOwner or jsonString == "" then return end
	
	local success, decodedTable = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)
	
	if success and type(decodedTable) == "table" then
		recordedNodes = {}
		for _, data in ipairs(decodedTable) do
			table.insert(recordedNodes, {
				cframe = CFrame.new(data[1], data[2], data[3]),
				isJumping = data[4] or false
			})
		end
		updateVisuals()
		print("[ALDO KNIGHTXOz] Berhasil memuat " .. #recordedNodes .. " titik jalur!")
	else
		warn("[ALDO KNIGHTXOz] Format Data JSON Tidak Valid!")
	end
end

-- GUI UTAMA (LIGHT PREMIUM & ROTATING STROKE)
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoWalkRecorderGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenuButton"
openBtn.Size = UDim2.new(0, 90, 0, 38)
openBtn.Position = UDim2.new(0, 15, 0.85, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Text = "MENU"
openBtn.TextColor3 = Color3.fromRGB(30, 30, 35)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2.5
openStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
openStroke.Parent = openBtn

local openGradient = Instance.new("UIGradient")
openGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
})
openGradient.Parent = openStroke

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 195, 0, isOwner and 385 or 175)
frame.Position = UDim2.new(0, 15, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(245, 247, 250)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 3
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 230, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 215, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
})
frameGradient.Parent = frameStroke

RunService.RenderStepped:Connect(function(delta)
	frameGradient.Rotation = (frameGradient.Rotation + (120 * delta)) % 360
	openGradient.Rotation = (openGradient.Rotation + (120 * delta)) % 360
end)

local UIList = Instance.new("UIListLayout")
UIList.Parent = frame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "CreatorLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 22)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ALDO KNIGHTXOz"
titleLabel.TextColor3 = Color3.fromRGB(20, 20, 30)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.LayoutOrder = 0
titleLabel.Parent = frame

openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	openBtn.Text = frame.Visible and "CLOSE" or "MENU"
end)

local function createButton(text, bgGradientColors, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.LayoutOrder = order
	btn.Parent = frame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn
	
	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = bgGradientColors
	btnGradient.Rotation = 45
	btnGradient.Parent = btn
	
	return btn
end

local autoWalkGradient = ColorSequence.new(Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 200, 255))
local speedGradient    = ColorSequence.new(Color3.fromRGB(160, 30, 240), Color3.fromRGB(200, 80, 255))
local jumpGradient     = ColorSequence.new(Color3.fromRGB(255, 140, 0), Color3.fromRGB(255, 180, 50))
local recordGradient   = ColorSequence.new(Color3.fromRGB(255, 60, 90), Color3.fromRGB(255, 100, 120))
local playGradient     = ColorSequence.new(Color3.fromRGB(0, 200, 100), Color3.fromRGB(50, 230, 140))
local saveGradient     = ColorSequence.new(Color3.fromRGB(220, 160, 0), Color3.fromRGB(250, 200, 50))
local loadGradient     = ColorSequence.new(Color3.fromRGB(0, 180, 220), Color3.fromRGB(0, 220, 255))

local btnAutoWalk = createButton("Auto Walk (R)", autoWalkGradient, 1)
btnAutoWalk.MouseButton1Click:Connect(toggleAutoWalk)

local btnSpeed = createButton("Speed: 16", speedGradient, 2)
btnSpeed.MouseButton1Click:Connect(function()
	cycleSpeed()
	btnSpeed.Text = "Speed: " .. tostring(humanoid.WalkSpeed)
end)

local btnAutoJump = createButton("Auto Jump: OFF", jumpGradient, 3)
btnAutoJump.MouseButton1Click:Connect(function()
	toggleAutoJump()
	btnAutoJump.Text = isAutoJumping and "Auto Jump: ON" or "Auto Jump: OFF"
end)

if isOwner then
	local btnRecord = createButton("Record Line (Z)", recordGradient, 4)
	local btnPlay = createButton("Play Line (X)", playGradient, 5)
	local btnSave = createButton("Save Data (C)", saveGradient, 6)
	
	local inputTextBox = Instance.new("TextBox")
	inputTextBox.Size = UDim2.new(1, 0, 0, 30)
	inputTextBox.PlaceholderText = "Paste Teks JSON Di Sini..."
	inputTextBox.Text = ""
	inputTextBox.TextColor3 = Color3.fromRGB(30, 30, 30)
	inputTextBox.BackgroundColor3 = Color3.fromRGB(220, 225, 230)
	inputTextBox.Font = Enum.Font.GothamBold
	inputTextBox.TextSize = 11
	inputTextBox.LayoutOrder = 7
	inputTextBox.Parent = frame
	
	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 6)
	tbCorner.Parent = inputTextBox
	
	local btnLoad = createButton("Load Data JSON", loadGradient, 8)
	
	btnRecord.MouseButton1Click:Connect(function()
		startRecording()
		btnRecord.Text = isRecording and "Stop Record (Z)" or "Record Line (Z)"
	end)
	
	btnPlay.MouseButton1Click:Connect(playLine)
	btnSave.MouseButton1Click:Connect(saveRecorderData)
	btnLoad.MouseButton1Click:Connect(function()
		loadRecorderData(inputTextBox.Text)
	end)
end

-- KEYBIND CONTROLS
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.R then
		toggleAutoWalk()
	elseif input.KeyCode == Enum.KeyCode.Z and isOwner then
		startRecording()
	elseif input.KeyCode == Enum.KeyCode.X and isOwner then
		playLine()
	elseif input.KeyCode == Enum.KeyCode.C and isOwner then
		saveRecorderData()
	end
end)
