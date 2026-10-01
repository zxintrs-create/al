local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- TARGET PARENT AMAN (CoreGui / gethui / PlayerGui)
---------------------------------------------------------
local function getTargetParent()
	local successGetHui, hui = pcall(function()
		return gethui and gethui()
	end)
	if successGetHui and hui then
		return hui
	end

	local successCore, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if successCore and coreGui then
		return coreGui
	end

	return playerGui
end

-- Fungsi Notifikasi dengan ScreenGui khusus agar selalu di layer teratas (DisplayOrder max)
local function Notify(pesanTeks)
	task.spawn(function()
		-- Buat ScreenGui khusus notifikasi di atas segalanya
		local notifyGui = Instance.new("ScreenGui")
		notifyGui.Name = "ZydexTopNotify"
		notifyGui.ResetOnSpawn = false
		notifyGui.IgnoreGuiInset = true
		notifyGui.DisplayOrder = 2147483647 -- Nilai tertinggi agar selalu di atas UI lain
		
		local successParent = pcall(function()
			notifyGui.Parent = getTargetParent()
		end)
		if not successParent then
			notifyGui.Parent = playerGui
		end

		-- Buat Frame / Tampilan Notifikasi Custom yang Elegan
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 300, 0, 60)
		frame.Position = UDim2.new(0.5, -150, 0, -80) -- Mulai dari atas (off-screen)
		frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		frame.BackgroundTransparency = 0.1
		frame.BorderSizePixel = 0
		frame.Parent = notifyGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(0, 180, 255)
		stroke.Thickness = 2
		stroke.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Position = UDim2.new(0, 10, 0, 5)
		title.BackgroundTransparency = 1
		title.Text = "👑 Zydex notify 999"
		title.TextColor3 = Color3.fromRGB(255, 215, 0)
		title.TextSize = 13
		title.Font = Enum.Font.SourceSansBold
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, -20, 0, 25)
		text.Position = UDim2.new(0, 10, 0, 25)
		text.BackgroundTransparency = 1
		text.Text = pesanTeks
		text.TextColor3 = Color3.fromRGB(255, 255, 255)
		text.TextSize = 12
		text.Font = Enum.Font.SourceSans
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.TextWrapped = true
		text.Parent = frame

		-- Animasi Masuk (Tween turun ke bawah)
		local TweenService = game:GetService("TweenService")
		local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)})
		tweenIn:Play()

		-- Tunggu beberapa detik lalu animasi keluar
		task.wait(4.5)
		local tweenOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -80)})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		
		notifyGui:Destroy()
	end)
end

Notify("Load script , 👑 VOID VAINLY STAR (Top Notify Fixed)")
print("D-PAD VOID VAINLY STAR (Fixed) ✅")

local camera = Workspace.CurrentCamera
local SETTINGS_FILE = "MobileControlsNativeJump.json"
local SKALA_UKURAN = 2.0 

-- Sembunyikan TouchGui bawaan Roblox
task.spawn(function()
	local success, err = pcall(function()
		local touchGui = playerGui:WaitForChild("TouchGui", 3)
		if touchGui then touchGui.Enabled = false end
	end)
end)

-- Buat ScreenGui Utama Kontrol
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMobileControls"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999999

local successParent, errParent = pcall(function()
	screenGui.Parent = getTargetParent()
end)
if not successParent then
	screenGui.Parent = playerGui
end

local uiScale = Instance.new("UIScale")
uiScale.Scale = SKALA_UKURAN
uiScale.Parent = screenGui

local moveInputs = {Forward = false, Backward = false, Left = false, Right = false}
local holdingJump = false
local shiftLockEnabled = false

local function resetAllInputs()
	moveInputs.Forward = false
	moveInputs.Backward = false
	moveInputs.Left = false
	moveInputs.Right = false
	holdingJump = false
end

---------------------------------------------------------
-- PENGATURAN DEFAULT & LOAD / SAVE FILE JSON
---------------------------------------------------------
local layoutConfig = {
	DpadPosX = 15, DpadPosY = -15, DpadSize = 180,
	JumpPosX = -15, JumpPosY = -15, JumpSize = 120,
	ActionPosX = -160, ActionPosY = -15, ActionSize = 45,
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
-- D-PAD KIRI (WASD)
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

local function bindDpadSafe(btn, dir)
	local activeInput = nil
	
	btn.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not activeInput then
			activeInput = input
			moveInputs[dir] = true
			btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
		end
	end)
	
	local function releaseDpad(input)
		if input == activeInput then
			moveInputs[dir] = false
			activeInput = nil
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		end
	end
	
	btn.InputEnded:Connect(releaseDpad)
end

bindDpadSafe(btnW, "Forward")
bindDpadSafe(btnS, "Backward")
bindDpadSafe(btnA, "Left")
bindDpadSafe(btnD, "Right")

---------------------------------------------------------
-- TOMBOL JUMP AMAN
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
		btnJump.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
	end
end)

local function releaseJump(input)
	if input == activeJumpInput then
		holdingJump = false
		btnJump.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		activeJumpInput = nil
	end
end

btnJump.InputEnded:Connect(releaseJump)

---------------------------------------------------------
-- TOMBOL AKSI (Q, E, R, F)
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
	
	local function releaseAction(input)
		if input == activeActionInput then
			pcall(function() VirtualInputManager:SendKeyEvent(false, keyCode, false, game) end)
			activeActionInput = nil
			btn.BackgroundColor3 = color
		end
	end
	
	btn.InputEnded:Connect(releaseAction)
	
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
-- MENU PENGATURAN UI LENGKAP
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
titleLabel.Text = "LAYOUT SETTINGS"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

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
-- LOOP UTAMA (GERAKAN, LOMPAT, & SHIFT LOCK)
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then 
		resetAllInputs()
		return 
	end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	
	if not hum or not hrp or hum.Health <= 0 then
		resetAllInputs()
		return
	end

	if holdingJump then
		hum.Jump = true
	end

	local z = (moveInputs.Forward and -1 or 0) + (moveInputs.Backward and 1 or 0)
	local x = (moveInputs.Left and -1 or 0) + (moveInputs.Right and 1 or 0)

	if x ~= 0 or z ~= 0 then
		local camCF = camera.CFrame
		local lookVector = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
		local rightVector = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
		
		local moveDir = (lookVector * -z) + (rightVector * x)
		if moveDir.Magnitude > 0 then
			hum:Move(moveDir.Unit, false)
		end
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
