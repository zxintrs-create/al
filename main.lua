local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

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

Notify("Load script , 👑 VOID VAINLY STAR")
print("D-PAD VOID VAINLY STAR ✅")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local SETTINGS_FILE = "JumpSettings.json"
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
screenGui.DisplayOrder = 999999999 -- Memastikan render di paling atas semua GUI
screenGui.Parent = getTargetParent()

local uiScale = Instance.new("UIScale")
uiScale.Scale = SKALA_UKURAN
uiScale.Parent = screenGui

local moveInputs = {Forward = false, Backward = false, Left = false, Right = false}
local holdingJump = false
local shiftLockEnabled = false

---------------------------------------------------------
-- D-PAD KIRI (WASD)
---------------------------------------------------------
local dpadContainer = Instance.new("Frame")
dpadContainer.Name = "DPadContainer"
dpadContainer.AnchorPoint = Vector2.new(0, 1)
dpadContainer.Position = UDim2.new(0, 15, 1, -15)
dpadContainer.Size = UDim2.new(0, 180, 0, 180)
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

---------------------------------------------------------
-- SISTEM SAVE / LOAD (READFILE & WRITEFILE)
---------------------------------------------------------
local jumpSize = 120
local jumpPosX = -15
local jumpPosY = -15

local function loadSettingsFromFile()
	if readfile and isfile and isfile(SETTINGS_FILE) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(SETTINGS_FILE))
		end)
		if success and type(result) == "table" then
			jumpSize = result.Size or jumpSize
			jumpPosX = result.PosX or jumpPosX
			jumpPosY = result.PosY or jumpPosY
		end
	end
end

loadSettingsFromFile()

---------------------------------------------------------
-- TOMBOL JUMP
---------------------------------------------------------
local btnJump = Instance.new("ImageButton")
btnJump.Name = "BtnJump"
btnJump.AnchorPoint = Vector2.new(1, 1)
btnJump.Position = UDim2.new(1, jumpPosX, 1, jumpPosY)
btnJump.Size = UDim2.new(0, jumpSize, 0, jumpSize)
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

---------------------------------------------------------
-- TOMBOL SHIFT LOCK
---------------------------------------------------------
local btnShift = Instance.new("TextButton")
btnShift.Name = "BtnShift"
btnShift.AnchorPoint = Vector2.new(0.5, 0.5)
btnShift.Position = UDim2.new(1, -20, 1, -150)
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

---------------------------------------------------------
-- MENU SETTINGS & GUI
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

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 220, 0, 210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "JUMP SETTINGS"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local tempSize = jumpSize
local tempPosX = jumpPosX
local tempPosY = jumpPosY

local function createSettingRow(parent, yOffset, labelText, initialVal, onMinus, onPlus)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(0, 10, 0, yOffset)
	frame.Size = UDim2.new(1, -20, 0, 35)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.new(0, 0, 0, 0)
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
	btnMinus.TextSize = 16
	btnMinus.Parent = frame

	local valLbl = Instance.new("TextLabel")
	valLbl.Position = UDim2.new(0.56, 0, 0, 0)
	valLbl.Size = UDim2.new(0.28, 0, 1, 0)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(initialVal)
	valLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
	valLbl.TextSize = 14
	valLbl.Font = Enum.Font.SourceSansBold
	valLbl.Parent = frame

	local btnPlus = Instance.new("TextButton")
	btnPlus.Position = UDim2.new(0.85, 0, 0.1, 0)
	btnPlus.Size = UDim2.new(0, 28, 0.8, 0)
	btnPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btnPlus.Text = "+"
	btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnPlus.TextSize = 16
	btnPlus.Parent = frame

	btnMinus.Activated:Connect(function()
		onMinus(valLbl)
	end)

	btnPlus.Activated:Connect(function()
		onPlus(valLbl)
	end)

	return valLbl
end

local lblSize = createSettingRow(mainFrame, 35, "Ukuran:", tempSize,
	function(lbl)
		tempSize = math.max(40, tempSize - 10)
		lbl.Text = tostring(tempSize)
		btnJump.Size = UDim2.new(0, tempSize, 0, tempSize)
	end,
	function(lbl)
		tempSize = math.min(300, tempSize + 10)
		lbl.Text = tostring(tempSize)
		btnJump.Size = UDim2.new(0, tempSize, 0, tempSize)
	end
)

local lblPosX = createSettingRow(mainFrame, 75, "Posisi X:", tempPosX,
	function(lbl)
		tempPosX = tempPosX - 10
		lbl.Text = tostring(tempPosX)
		btnJump.Position = UDim2.new(1, tempPosX, 1, tempPosY)
	end,
	function(lbl)
		tempPosX = tempPosX + 10
		lbl.Text = tostring(tempPosX)
		btnJump.Position = UDim2.new(1, tempPosX, 1, tempPosY)
	end
)

local lblPosY = createSettingRow(mainFrame, 115, "Posisi Y:", tempPosY,
	function(lbl)
		tempPosY = tempPosY - 10
		lbl.Text = tostring(tempPosY)
		btnJump.Position = UDim2.new(1, tempPosX, 1, tempPosY)
	end,
	function(lbl)
		tempPosY = tempPosY + 10
		lbl.Text = tostring(tempPosY)
		btnJump.Position = UDim2.new(1, tempPosX, 1, tempPosY)
	end
)

local btnSave = Instance.new("TextButton")
btnSave.Name = "BtnSave"
btnSave.Position = UDim2.new(0, 10, 0, 160)
btnSave.Size = UDim2.new(1, -20, 0, 35)
btnSave.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
btnSave.Text = "SAVE SETTINGS"
btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSave.TextSize = 14
btnSave.Font = Enum.Font.SourceSansBold
btnSave.Parent = mainFrame

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = btnSave

btnOpenMenu.Activated:Connect(function()
	tempSize = jumpSize
	tempPosX = jumpPosX
	tempPosY = jumpPosY
	lblSize.Text = tostring(tempSize)
	lblPosX.Text = tostring(tempPosX)
	lblPosY.Text = tostring(tempPosY)
	mainFrame.Visible = not mainFrame.Visible
end)

btnSave.Activated:Connect(function()
	jumpSize = tempSize
	jumpPosX = tempPosX
	jumpPosY = tempPosY
	btnJump.Size = UDim2.new(0, jumpSize, 0, jumpSize)
	btnJump.Position = UDim2.new(1, jumpPosX, 1, jumpPosY)
	
	if writefile then
		local dataToSave = {
			Size = jumpSize,
			PosX = jumpPosX,
			PosY = jumpPosY
		}
		pcall(function()
			writefile(SETTINGS_FILE, HttpService:JSONEncode(dataToSave))
		end)
	end
	
	mainFrame.Visible = false
end)

---------------------------------------------------------
-- INPUT TOUCH CONTROLS
---------------------------------------------------------
local function bindTouch(btn, dir)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			moveInputs[dir] = true
		end
	end)
	
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			moveInputs[dir] = false
		end
	end)
end

bindTouch(btnW, "Forward")
bindTouch(btnS, "Backward")
bindTouch(btnA, "Left")
bindTouch(btnD, "Right")

btnJump.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingJump = true
	end
end)

btnJump.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdingJump = false
	end
end)

btnShift.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		shiftLockEnabled = not shiftLockEnabled
		btnShift.BackgroundColor3 = shiftLockEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(0, 220, 255)
	end
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
