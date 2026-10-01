local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Fungsi Notifikasi
local function Notify(pesanTeks)
	task.spawn(function()
		local success = false
		while not success do
			success = pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "System Log",
					Text = pesanTeks,
					Duration = 5,
					Button1 = "OK"
				})
			end)
			if not success then task.wait(0.5) end
		end
	end)
end

Notify("Load script , 👑 VOID VAINLY STAR (Full X & Y Layout)")
print("D-PAD ✅")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local SETTINGS_FILE = "MobileControlsFullLayout.json"
local SKALA_UKURAN = 2.0 

-- Sembunyikan TouchGui bawaan Roblox
task.spawn(function()
	local touchGui = playerGui:WaitForChild("TouchGui", 5)
	if touchGui then
		touchGui.Enabled = false
	end
end)

---------------------------------------------------------
-- PENENTUAN PARENT KE CORE GUI / GETHUI
---------------------------------------------------------
local function getTargetParent()
	if gethui then
		return gethui()
	end
	local success, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if success and coreGui then
		return coreGui
	end
	return playerGui
end

-- Buat ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMobileControls"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999999
screenGui.Parent = getTargetParent()

local uiScale = Instance.new("UIScale")
uiScale.Scale = SKALA_UKURAN
uiScale.Parent = screenGui

local moveInputs = {Forward = false, Backward = false, Left = false, Right = false}
local holdingJump = false
local shiftLockEnabled = false

---------------------------------------------------------
-- PENGATURAN DEFAULT & LOAD / SAVE FILE (LENGKAP X & Y)
---------------------------------------------------------
local layoutConfig = {
	-- D-Pad Kiri
	DpadPosX = 15, DpadPosY = -15, DpadSize = 180,
	-- Tombol Jump Kanan
	JumpPosX = -15, JumpPosY = -15, JumpSize = 120,
	-- Tombol Aksi (Q,E,R,F)
	ActionPosX = -160, ActionPosY = -15, ActionSize = 45,
	-- Tombol Shift Lock
	ShiftPosX = -20, ShiftPosY = -150
}

local function loadSettingsFromFile()
	if readfile and isfile and isfile(SETTINGS_FILE) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(SETTINGS_FILE))
		end)
		if success and type(result) == "table" then
			for k, v in pairs(result) do
				layoutConfig[k] = v
			end
		end
	end
end

loadSettingsFromFile()

---------------------------------------------------------
-- FUNGSI ANTI-SLIP (MENGECEK APAKAH JARI DI DALAM TOMBOL)
---------------------------------------------------------
local function isInputInsideGui(guiObject, inputPos)
	local absPos = guiObject.AbsolutePosition
	local absSize = guiObject.AbsoluteSize
	return inputPos.X >= absPos.X 
		and inputPos.X <= absPos.X + absSize.X 
		and inputPos.Y >= absPos.Y 
		and inputPos.Y <= absPos.Y + absSize.Y
end

---------------------------------------------------------
-- D-PAD KIRI (WASD) DENGAN ANTI-SLIP
---------------------------------------------------------
local dpadContainer = Instance.new("Frame")
dpadContainer.Name = "DPadContainer"
dpadContainer.AnchorPoint = Vector2.new(0, 1)
dpadContainer.Position = UDim2.new(0, layoutConfig.DpadPosX, 1, layoutConfig.DpadPosY)
dpadContainer.Size = UDim2.new(0, layoutConfig.DpadSize, 0, layoutConfig.DpadSize)
dpadContainer.BackgroundTransparency = 1
dpadContainer.Parent = screenGui

local function createDpadBtn(name, pos, size, text)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Position = pos
	btn.Size = size
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 24
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Parent = dpadContainer
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	return btn
end

local btnW = createDpadBtn("BtnW", UDim2.new(0.33, 0, 0, 0), UDim2.new(0.34, 0, 0.34, 0), "▲")
local btnS = createDpadBtn("BtnS", UDim2.new(0.33, 0, 0.66, 0), UDim2.new(0.34, 0, 0.34, 0), "▼")
local btnA = createDpadBtn("BtnA", UDim2.new(0, 0, 0.33, 0), UDim2.new(0.34, 0, 0.34, 0), "◄")
local btnD = createDpadBtn("BtnD", UDim2.new(0.66, 0, 0.33, 0), UDim2.new(0.34, 0, 0.34, 0), "►")

local function bindDpadAntiSlip(btn, dir)
	local activeInput = nil
	btn.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not activeInput then
			activeInput = input
			moveInputs[dir] = true
			btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == activeInput and not isInputInsideGui(btn, input.Position) then
			moveInputs[dir] = false
			activeInput = nil
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input == activeInput then
			moveInputs[dir] = false
			activeInput = nil
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		end
	end)
end

bindDpadAntiSlip(btnW, "Forward")
bindDpadAntiSlip(btnS, "Backward")
bindDpadAntiSlip(btnA, "Left")
bindDpadAntiSlip(btnD, "Right")

---------------------------------------------------------
-- TOMBOL JUMP DENGAN ANTI-SLIP
---------------------------------------------------------
local btnJump = Instance.new("ImageButton")
btnJump.Name = "BtnJump"
btnJump.AnchorPoint = Vector2.new(1, 1)
btnJump.Position = UDim2.new(1, layoutConfig.JumpPosX, 1, layoutConfig.JumpPosY)
btnJump.Size = UDim2.new(0, layoutConfig.JumpSize, 0, layoutConfig.JumpSize)
btnJump.Image = "rbxassetid://124372870787270"
btnJump.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
btnJump.BackgroundTransparency = 0.2
btnJump.BorderSizePixel = 0
btnJump.Parent = screenGui

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(1, 0)
jumpCorner.Parent = btnJump

local jumpText = Instance.new("TextLabel")
jumpText.Name = "JumpLabel"
jumpText.Size = UDim2.new(1, 0, 1, 0)
jumpText.BackgroundTransparency = 1
jumpText.Text = "JUMP"
jumpText.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpText.TextSize = 22
jumpText.Font = Enum.Font.SourceSansBold
jumpText.Parent = btnJump

local activeJumpInput = nil
btnJump.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not activeJumpInput then
		activeJumpInput = input
		holdingJump = true
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == activeJumpInput and not isInputInsideGui(btnJump, input.Position) then
		holdingJump = false
		activeJumpInput = nil
	end
end)
btnJump.InputEnded:Connect(function(input)
	if input == activeJumpInput then
		holdingJump = false
		activeJumpInput = nil
	end
end)

---------------------------------------------------------
-- TOMBOL AKSI (Q, E, R, F) DENGAN ANTI-SLIP
---------------------------------------------------------
local actionContainer = Instance.new("Frame")
actionContainer.Name = "ActionContainer"
actionContainer.AnchorPoint = Vector2.new(1, 1)
actionContainer.Position = UDim2.new(1, layoutConfig.ActionPosX, 1, layoutConfig.ActionPosY) 
actionContainer.Size = UDim2.new(0, 120, 0, 120)
actionContainer.BackgroundTransparency = 1
actionContainer.Parent = screenGui

local function createActionBtn(name, text, pos, keyCode, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Position = pos
	btn.Size = UDim2.new(0, layoutConfig.ActionSize, 0, layoutConfig.ActionSize)
	btn.BackgroundColor3 = color or Color3.fromRGB(50, 100, 200)
	btn.BackgroundTransparency = 0.2
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 18
	btn.Font = Enum.Font.SourceSansBold
	btn.Parent = actionContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn

	local activeActionInput = nil
	btn.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not activeActionInput then
			activeActionInput = input
			pcall(function() VirtualInputManager:SendKeyEvent(true, keyCode, false, game) end)
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == activeActionInput and not isInputInsideGui(btn, input.Position) then
			pcall(function() VirtualInputManager:SendKeyEvent(false, keyCode, false, game) end)
			activeActionInput = nil
			btn.BackgroundColor3 = color
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input == activeActionInput then
			pcall(function() VirtualInputManager:SendKeyEvent(false, keyCode, false, game) end)
			activeActionInput = nil
			btn.BackgroundColor3 = color
		end
	end)
	return btn
end

createActionBtn("BtnQ", "Q", UDim2.new(0, 0, 0.5, -22), Enum.KeyCode.Q, Color3.fromRGB(0, 150, 200))     
createActionBtn("BtnF", "F", UDim2.new(0.5, -22, 1, -45), Enum.KeyCode.F, Color3.fromRGB(200, 50, 50))   
createActionBtn("BtnE", "E", UDim2.new(0.5, -22, 0, 0), Enum.KeyCode.E, Color3.fromRGB(0, 200, 100))     
createActionBtn("BtnR", "R", UDim2.new(1, -45, 0.5, -22), Enum.KeyCode.R, Color3.fromRGB(150, 50, 200))  

---------------------------------------------------------
-- TOMBOL SHIFT LOCK
---------------------------------------------------------
local btnShift = Instance.new("TextButton")
btnShift.Name = "BtnShift"
btnShift.AnchorPoint = Vector2.new(0.5, 0.5)
btnShift.Position = UDim2.new(1, layoutConfig.ShiftPosX, 1, layoutConfig.ShiftPosY)
btnShift.Size = UDim2.new(0, 45, 0, 45)
btnShift.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
btnShift.BackgroundTransparency = 0.1
btnShift.Text = "LOCK"
btnShift.TextColor3 = Color3.fromRGB(255, 255, 255)
btnShift.TextSize = 12
btnShift.Font = Enum.Font.SourceSansBold
btnShift.Parent = screenGui

local shiftCorner = Instance.new("UICorner")
shiftCorner.CornerRadius = UDim.new(1, 0)
shiftCorner.Parent = btnShift

btnShift.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		shiftLockEnabled = not shiftLockEnabled
		btnShift.BackgroundColor3 = shiftLockEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(0, 220, 255)
	end
end)

---------------------------------------------------------
-- MENU PENGATURAN UI LENGKAP (X & Y TERSEDIA)
---------------------------------------------------------
local btnOpenMenu = Instance.new("TextButton")
btnOpenMenu.Name = "BtnOpenMenu"
btnOpenMenu.AnchorPoint = Vector2.new(1, 0)
btnOpenMenu.Position = UDim2.new(1, -10, 0, 10)
btnOpenMenu.Size = UDim2.new(0, 70, 0, 30)
btnOpenMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
btnOpenMenu.BackgroundTransparency = 0.2
btnOpenMenu.Text = "MENU"
btnOpenMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
btnOpenMenu.TextSize = 14
btnOpenMenu.Font = Enum.Font.SourceSansBold
btnOpenMenu.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 6)
menuCorner.Parent = btnOpenMenu

local mainFrame = Instance.new("ScrollingFrame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.CanvasSize = UDim2.new(0, 0, 0, 520)
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LAYOUT SETTINGS (X & Y)"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Variabel Sementara untuk Pengaturan
local tempConfig = {}
for k, v in pairs(layoutConfig) do tempConfig[k] = v end

local function createSettingRow(parent, yOffset, labelText, keyVal, minVal, maxVal, step, onChange)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(0, 10, 0, yOffset)
	frame.Size = UDim2.new(1, -20, 0, 35)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.4, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 12
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local btnMinus = Instance.new("TextButton")
	btnMinus.Position = UDim2.new(0.42, 0, 0.1, 0)
	btnMinus.Size = UDim2.new(0, 28, 0.8, 0)
	btnMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btnMinus.Text = "-"
	btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnMinus.Parent = frame

	local valLbl = Instance.new("TextLabel")
	valLbl.Position = UDim2.new(0.56, 0, 0, 0)
	valLbl.Size = UDim2.new(0.28, 0, 1, 0)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(tempConfig[keyVal])
	valLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
	valLbl.TextSize = 13
	valLbl.Font = Enum.Font.SourceSansBold
	valLbl.Parent = frame

	local btnPlus = Instance.new("TextButton")
	btnPlus.Position = UDim2.new(0.85, 0, 0.1, 0)
	btnPlus.Size = UDim2.new(0, 28, 0.8, 0)
	btnPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btnPlus.Text = "+"
	btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnPlus.Parent = frame

	btnMinus.Activated:Connect(function()
		tempConfig[keyVal] = math.max(minVal, tempConfig[keyVal] - step)
		valLbl.Text = tostring(tempConfig[keyVal])
		onChange(tempConfig[keyVal])
	end)

	btnPlus.Activated:Connect(function()
		tempConfig[keyVal] = math.min(maxVal, tempConfig[keyVal] + step)
		valLbl.Text = tostring(tempConfig[keyVal])
		onChange(tempConfig[keyVal])
	end)

	return valLbl
end

-- Baris Pengaturan Lengkap X, Y, dan Ukuran di Menu
local yPos = 40
local spacing = 40

createSettingRow(mainFrame, yPos, "Dpad Size:", "DpadSize", 120, 260, 10, function(val) dpadContainer.Size = UDim2.new(0, val, 0, val) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Dpad Pos X:", "DpadPosX", 0, 300, 10, function(val) dpadContainer.Position = UDim2.new(0, val, 1, tempConfig.DpadPosY) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Dpad Pos Y:", "DpadPosY", -400, 0, 10, function(val) dpadContainer.Position = UDim2.new(0, tempConfig.DpadPosX, 1, val) end) yPos = yPos + spacing

createSettingRow(mainFrame, yPos, "Jump Size:", "JumpSize", 60, 200, 10, function(val) btnJump.Size = UDim2.new(0, val, 0, val) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Jump Pos X:", "JumpPosX", -300, 0, 10, function(val) btnJump.Position = UDim2.new(1, val, 1, tempConfig.JumpPosY) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Jump Pos Y:", "JumpPosY", -400, 0, 10, function(val) btnJump.Position = UDim2.new(1, tempConfig.JumpPosX, 1, val) end) yPos = yPos + spacing

createSettingRow(mainFrame, yPos, "Action Size:", "ActionSize", 35, 75, 5, function(val)
	for _, child in ipairs(actionContainer:GetChildren()) do
		if child:IsA("TextButton") then child.Size = UDim2.new(0, val, 0, val) end
	end
end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Action Pos X:", "ActionPosX", -400, 0, 10, function(val) actionContainer.Position = UDim2.new(1, val, 1, tempConfig.ActionPosY) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Action Pos Y:", "ActionPosY", -400, 0, 10, function(val) actionContainer.Position = UDim2.new(1, tempConfig.ActionPosX, 1, val) end) yPos = yPos + spacing

createSettingRow(mainFrame, yPos, "Shift Pos X:", "ShiftPosX", -300, 0, 10, function(val) btnShift.Position = UDim2.new(1, val, 1, tempConfig.ShiftPosY) end) yPos = yPos + spacing
createSettingRow(mainFrame, yPos, "Shift Pos Y:", "ShiftPosY", -500, 0, 10, function(val) btnShift.Position = UDim2.new(1, tempConfig.ShiftPosX, 1, val) end) yPos = yPos + spacing

local btnSave = Instance.new("TextButton")
btnSave.Name = "BtnSave"
btnSave.Position = UDim2.new(0, 10, 0, yPos + 10)
btnSave.Size = UDim2.new(1, -20, 0, 35)
btnSave.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
btnSave.Text = "SAVE SETTINGS"
btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSave.TextSize = 14
btnSave.Font = Enum.Font.SourceSansBold
btnSave.Parent = mainFrame

mainFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 60)

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = btnSave

btnOpenMenu.Activated:Connect(function()
	for k, v in pairs(layoutConfig) do tempConfig[k] = v end
	mainFrame.Visible = not mainFrame.Visible
end)

btnSave.Activated:Connect(function()
	for k, v in pairs(tempConfig) do layoutConfig[k] = v end
	
	-- Terapkan Perubahan Permanen
	dpadContainer.Size = UDim2.new(0, layoutConfig.DpadSize, 0, layoutConfig.DpadSize)
	dpadContainer.Position = UDim2.new(0, layoutConfig.DpadPosX, 1, layoutConfig.DpadPosY)
	
	btnJump.Size = UDim2.new(0, layoutConfig.JumpSize, 0, layoutConfig.JumpSize)
	btnJump.Position = UDim2.new(1, layoutConfig.JumpPosX, 1, layoutConfig.JumpPosY)
	
	actionContainer.Position = UDim2.new(1, layoutConfig.ActionPosX, 1, layoutConfig.ActionPosY)
	for _, child in ipairs(actionContainer:GetChildren()) do
		if child:IsA("TextButton") then child.Size = UDim2.new(0, layoutConfig.ActionSize, 0, layoutConfig.ActionSize) end
	end
	
	btnShift.Position = UDim2.new(1, layoutConfig.ShiftPosX, 1, layoutConfig.ShiftPosY)
	
	if writefile then
		pcall(function()
			writefile(SETTINGS_FILE, HttpService:JSONEncode(layoutConfig))
		end)
	end
	
	mainFrame.Visible = false
end)

---------------------------------------------------------
-- LOOP UTAMA
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if holdingJump then
		hum.Jump = true
	end

	local z = (moveInputs.Forward and -1 or 0) + (moveInputs.Backward and 1 or 0)
	local x = (moveInputs.Left and -1 or 0) + (moveInputs.Right and 1 or 0)

	if x ~= 0 or z ~= 0 then
		hum:Move(Vector3.new(x, 0, z), true)
	end

	if shiftLockEnabled then
		hum.AutoRotate = false
		local _, y, _ = camera.CFrame:ToOrientation()
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, y, 0)
		hum.CameraOffset = Vector3.new(1.75, 0, 0)
	else
		hum.AutoRotate = true
		hum.CameraOffset = Vector3.new(0, 0, 0)
	end
end)
