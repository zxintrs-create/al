local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local isPC = UIS.KeyboardEnabled and not UIS.TouchEnabled
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Settings
local Theme = Color3.fromRGB(180, 30, 30)
local FOVColor = Color3.fromRGB(160, 0, 255)
local FOVTransparency = 0.4

-- States
local States = {
	Shield = false,
	Jump = false,
	Noclip = false,
	Fly = false,
	Aimbot = false,
	Hitbox = false,
	ESP = false,
	ShowFOV = true,
	ShowNames = true,
	ShowDistance = true,
	ShowSkeleton = true,
	Fullbright = false,
	AntiRagdoll = false,
	Zoom = false
}

local Speed = 16
local FOV = 50
local BodyVelocity, BodyGyro
local OriginalSizes = {}
local SavedCFrame = nil
local HoldingRightClick = false
local MenuOpen = true
local ESPDrawings = {}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.4
FOVCircle.Color = FOVColor
FOVCircle.Filled = false
FOVCircle.Radius = FOV
FOVCircle.Transparency = FOVTransparency

-- ==================== UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlVysr"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Open / Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 75, 0, 32)
ToggleBtn.Position = UDim2.new(1, -90, 0, 16)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "CLOSE"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- UIStroke & UIGradient untuk Open Button (Cyan - Ungu)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local ToggleGradient = Instance.new("UIGradient", ToggleStroke)
ToggleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),   -- Cyan
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 32, 240))  -- Ungu
})

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 480)
MainFrame.Position = UDim2.new(0.014, 0, 0.045, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

-- UIStroke & UIGradient untuk Main Frame (Cyan - Ungu)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local MainGradient = Instance.new("UIGradient", Stroke)
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),   -- Cyan
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 32, 240))  -- Ungu
})

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundTransparency = 1
Title.Text = "👑VOID VAINLY STAR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient", Title)
TitleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 32, 240))
})

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 30)
TabContainer.Position = UDim2.new(0, 10, 0, 44)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local function CreateTab(name, index)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.25, -3, 1, 0)
	btn.Position = UDim2.new(index * 0.25, 0, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = TabContainer
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local TabMain = CreateTab("MAIN", 0)
local TabCombat = CreateTab("COMBAT", 1)
local TabESP = CreateTab("ESP", 2)
local TabUtils = CreateTab("UTILS", 3)
TabMain.BackgroundColor3 = Theme

local function CreatePage()
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -84)
	page.Position = UDim2.new(0, 0, 0, 82)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = MainFrame
	return page
end

local PageMain = CreatePage()
PageMain.Visible = true
local PageCombat = CreatePage()
local PageESP = CreatePage()
local PageUtils = CreatePage()

local function SwitchTab(tab)
	PageMain.Visible = tab == "main"
	PageCombat.Visible = tab == "combat"
	PageESP.Visible = tab == "esp"
	PageUtils.Visible = tab == "utils"

	TabMain.BackgroundColor3 = tab == "main" and Theme or Color3.fromRGB(32, 32, 32)
	TabCombat.BackgroundColor3 = tab == "combat" and Theme or Color3.fromRGB(32, 32, 32)
	TabESP.BackgroundColor3 = tab == "esp" and Theme or Color3.fromRGB(32, 32, 32)
	TabUtils.BackgroundColor3 = tab == "utils" and Theme or Color3.fromRGB(32, 32, 32)
end

TabMain.MouseButton1Click:Connect(function() SwitchTab("main") end)
TabCombat.MouseButton1Click:Connect(function() SwitchTab("combat") end)
TabESP.MouseButton1Click:Connect(function() SwitchTab("esp") end)
TabUtils.MouseButton1Click:Connect(function() SwitchTab("utils") end)

-- Button creator
local function CreateButton(parent, text, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -24, 0, 36)
	btn.Position = UDim2.new(0, 12, 0, y)
	btn.BackgroundColor3 = color or Color3.fromRGB(55, 10, 10)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = true
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	return btn
end

-- MAIN
local BtnShield = CreateButton(PageMain, "Shield", 8)
local BtnJump = CreateButton(PageMain, "Jump", 52)
local BtnNoclip = CreateButton(PageMain, "Noclip", 96)
local BtnFly = CreateButton(PageMain, "Fly", 140)

local SpeedFrame = Instance.new("Frame", PageMain)
SpeedFrame.Size = UDim2.new(1, -24, 0, 36)
SpeedFrame.Position = UDim2.new(0, 12, 0, 195)
SpeedFrame.BackgroundTransparency = 1

local BtnSpeedPlus = Instance.new("TextButton", SpeedFrame)
BtnSpeedPlus.Size = UDim2.new(0.2, 0, 1, 0)
BtnSpeedPlus.BackgroundColor3 = Color3.fromRGB(20, 110, 20)
BtnSpeedPlus.Text = "+"
BtnSpeedPlus.TextColor3 = Color3.new(1, 1, 1)
BtnSpeedPlus.Font = Enum.Font.GothamBold
BtnSpeedPlus.TextSize = 18
Instance.new("UICorner", BtnSpeedPlus).CornerRadius = UDim.new(0, 10)

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0.52, 0, 1, 0)
SpeedLabel.Position = UDim2.new(0.24, 0, 0, 0)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 14
Instance.new("UICorner", SpeedLabel).CornerRadius = UDim.new(0, 10)

local BtnSpeedMinus = Instance.new("TextButton", SpeedFrame)
BtnSpeedMinus.Size = UDim2.new(0.2, 0, 1, 0)
BtnSpeedMinus.Position = UDim2.new(0.8, 0, 0, 0)
BtnSpeedMinus.BackgroundColor3 = Color3.fromRGB(110, 20, 20)
BtnSpeedMinus.Text = "-"
BtnSpeedMinus.TextColor3 = Color3.new(1, 1, 1)
BtnSpeedMinus.Font = Enum.Font.GothamBold
BtnSpeedMinus.TextSize = 18
Instance.new("UICorner", BtnSpeedMinus).CornerRadius = UDim.new(0, 10)

-- COMBAT
local BtnAimbot = CreateButton(PageCombat, "Aimbot", 8)
local BtnHitbox = CreateButton(PageCombat, "Hitbox", 52)
local BtnFOVToggle = CreateButton(PageCombat, "FOV Circle: ON", 96, Color3.fromRGB(20, 90, 20))

local FOVFrame = Instance.new("Frame", PageCombat)
FOVFrame.Size = UDim2.new(1, -24, 0, 36)
FOVFrame.Position = UDim2.new(0, 12, 0, 150)
FOVFrame.BackgroundTransparency = 1

local BtnFOVPlus = Instance.new("TextButton", FOVFrame)
BtnFOVPlus.Size = UDim2.new(0.2, 0, 1, 0)
BtnFOVPlus.BackgroundColor3 = Color3.fromRGB(20, 110, 20)
BtnFOVPlus.Text = "+"
BtnFOVPlus.TextColor3 = Color3.new(1, 1, 1)
BtnFOVPlus.Font = Enum.Font.GothamBold
BtnFOVPlus.TextSize = 18
Instance.new("UICorner", BtnFOVPlus).CornerRadius = UDim.new(0, 10)

local FOVLabel = Instance.new("TextLabel", FOVFrame)
FOVLabel.Size = UDim2.new(0.52, 0, 1, 0)
FOVLabel.Position = UDim2.new(0.24, 0, 0, 0)
FOVLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
FOVLabel.Text = "FOV: 50"
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.Font = Enum.Font.GothamBold
FOVLabel.TextSize = 14
Instance.new("UICorner", FOVLabel).CornerRadius = UDim.new(0, 10)

local BtnFOVMinus = Instance.new("TextButton", FOVFrame)
BtnFOVMinus.Size = UDim2.new(0.2, 0, 1, 0)
BtnFOVMinus.Position = UDim2.new(0.8, 0, 0, 0)
BtnFOVMinus.BackgroundColor3 = Color3.fromRGB(110, 20, 20)
BtnFOVMinus.Text = "-"
BtnFOVMinus.TextColor3 = Color3.new(1, 1, 1)
BtnFOVMinus.Font = Enum.Font.GothamBold
BtnFOVMinus.TextSize = 18
Instance.new("UICorner", BtnFOVMinus).CornerRadius = UDim.new(0, 10)

-- ESP
local BtnESP = CreateButton(PageESP, "ESP", 8)
local BtnSkeleton = CreateButton(PageESP, "Skeleton: ON", 52, Color3.fromRGB(20, 90, 20))
local BtnNames = CreateButton(PageESP, "Names: ON", 96, Color3.fromRGB(20, 90, 20))
local BtnDistance = CreateButton(PageESP, "Distance: ON", 140, Color3.fromRGB(20, 90, 20))

-- UTILS
local BtnSave = CreateButton(PageUtils, "Save Position", 8, Color3.fromRGB(25, 80, 140))
local BtnTP = CreateButton(PageUtils, "Teleport", 52, Color3.fromRGB(25, 110, 45))
local BtnFullbright = CreateButton(PageUtils, "Fullbright", 104)
local BtnAntiRagdoll = CreateButton(PageUtils, "Anti Ragdoll", 148)
local BtnZoom = CreateButton(PageUtils, "Inf Zoom", 192)
local BtnDelete = CreateButton(PageUtils, "Delete Hub", 250, Color3.fromRGB(130, 15, 15))

local StatusLabel = Instance.new("TextLabel", PageUtils)
StatusLabel.Size = UDim2.new(1, -24, 0, 18)
StatusLabel.Position = UDim2.new(0, 12, 0, 300)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "No position saved"
StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12

-- ==================== LOGIC ====================
local function SetButton(btn, state, onText, offText)
	btn.Text = state and onText or offText
	btn.BackgroundColor3 = state and Color3.fromRGB(20, 100, 20) or Color3.fromRGB(55, 10, 10)
end

local function ToggleMenu()
	MenuOpen = not MenuOpen
	if MenuOpen then
		MainFrame.Visible = true
		TweenService:Create(MainFrame, TweenInfo.new(0.18), {Position = UDim2.new(0.014, 0, 0.045, 0)}):Play()
		ToggleBtn.Text = "CLOSE"
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.18), {Position = UDim2.new(-0.5, 0, 0.045, 0)}):Play()
		task.wait(0.18)
		MainFrame.Visible = false
		ToggleBtn.Text = "OPEN"
	end
end

-- FITUR SHIELD (ASLI)
local function ToggleShield()
	States.Shield = not States.Shield
	SetButton(BtnShield, States.Shield, "Shield ON", "Shield")
end

local function ToggleJump()
	States.Jump = not States.Jump
	SetButton(BtnJump, States.Jump, "Jump ON", "Jump")
end

local function ToggleNoclip()
	States.Noclip = not States.Noclip
	SetButton(BtnNoclip, States.Noclip, "Noclip ON", "Noclip")
end

-- TOGGLE FLY
local function ToggleFly()
	States.Fly = not States.Fly
	SetButton(BtnFly, States.Fly, "Fly ON", "Fly")
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if States.Fly then
		if hum then hum.PlatformStand = true end
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = root
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BodyGyro.CFrame = root.CFrame
		BodyGyro.Parent = root
	else
		if hum then hum.PlatformStand = false end
		if BodyVelocity then BodyVelocity:Destroy() end
		if BodyGyro then BodyGyro:Destroy() end
	end
end

local function ToggleAimbot()
	States.Aimbot = not States.Aimbot
	SetButton(BtnAimbot, States.Aimbot, "Aimbot ON", "Aimbot")
	FOVCircle.Visible = States.Aimbot and States.ShowFOV
end

local function ToggleHitbox()
	States.Hitbox = not States.Hitbox
	SetButton(BtnHitbox, States.Hitbox, "Hitbox ON", "Hitbox")
	if not States.Hitbox then
		for plr, size in pairs(OriginalSizes) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				plr.Character.HumanoidRootPart.Size = size
				plr.Character.HumanoidRootPart.Transparency = 0
			end
		end
		OriginalSizes = {}
	end
end

-- Connections
BtnShield.MouseButton1Click:Connect(ToggleShield)
BtnJump.MouseButton1Click:Connect(ToggleJump)
BtnNoclip.MouseButton1Click:Connect(ToggleNoclip)
BtnFly.MouseButton1Click:Connect(ToggleFly)
BtnAimbot.MouseButton1Click:Connect(ToggleAimbot)
BtnHitbox.MouseButton1Click:Connect(ToggleHitbox)
ToggleBtn.MouseButton1Click:Connect(ToggleMenu)

BtnSpeedPlus.MouseButton1Click:Connect(function()
	Speed = math.min(Speed + 10, 400)
	SpeedLabel.Text = "Speed: " .. Speed
end)
BtnSpeedMinus.MouseButton1Click:Connect(function()
	Speed = math.max(Speed - 10, 0)
	SpeedLabel.Text = "Speed: " .. Speed
end)

BtnFOVPlus.MouseButton1Click:Connect(function()
	FOV = math.min(FOV + 5, 400)
	FOVLabel.Text = "FOV: " .. FOV
	FOVCircle.Radius = FOV
end)
BtnFOVMinus.MouseButton1Click:Connect(function()
	FOV = math.max(FOV - 5, 10)
	FOVLabel.Text = "FOV: " .. FOV
	FOVCircle.Radius = FOV
end)
BtnFOVToggle.MouseButton1Click:Connect(function()
	States.ShowFOV = not States.ShowFOV
	BtnFOVToggle.Text = "FOV Circle: " .. (States.ShowFOV and "ON" or "OFF")
	BtnFOVToggle.BackgroundColor3 = States.ShowFOV and Color3.fromRGB(20, 90, 20) or Color3.fromRGB(55, 10, 10)
	FOVCircle.Visible = States.Aimbot and States.ShowFOV
end)

BtnESP.MouseButton1Click:Connect(function()
	States.ESP = not States.ESP
	SetButton(BtnESP, States.ESP, "ESP ON", "ESP")
end)
BtnSkeleton.MouseButton1Click:Connect(function()
	States.ShowSkeleton = not States.ShowSkeleton
	BtnSkeleton.Text = "Skeleton: " .. (States.ShowSkeleton and "ON" or "OFF")
	BtnSkeleton.BackgroundColor3 = States.ShowSkeleton and Color3.fromRGB(20, 90, 20) or Color3.fromRGB(55, 10, 10)
end)
BtnNames.MouseButton1Click:Connect(function()
	States.ShowNames = not States.ShowNames
	BtnNames.Text = "Names: " .. (States.ShowNames and "ON" or "OFF")
	BtnNames.BackgroundColor3 = States.ShowNames and Color3.fromRGB(20, 90, 20) or Color3.fromRGB(55, 10, 10)
end)
BtnDistance.MouseButton1Click:Connect(function()
	States.ShowDistance = not States.ShowDistance
	BtnDistance.Text = "Distance: " .. (States.ShowDistance and "ON" or "OFF")
	BtnDistance.BackgroundColor3 = States.ShowDistance and Color3.fromRGB(20, 90, 20) or Color3.fromRGB(55, 10, 10)
end)

BtnSave.MouseButton1Click:Connect(function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		SavedCFrame = root.CFrame
		StatusLabel.Text = string.format("Saved: %.0f, %.0f, %.0f", root.Position.X, root.Position.Y, root.Position.Z)
		StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
	end
end)
BtnTP.MouseButton1Click:Connect(function()
	if SavedCFrame then
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = SavedCFrame end
	else
		StatusLabel.Text = "Save a position first"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 160, 40)
	end
end)

BtnFullbright.MouseButton1Click:Connect(function()
	States.Fullbright = not States.Fullbright
	SetButton(BtnFullbright, States.Fullbright, "Fullbright ON", "Fullbright")
	if States.Fullbright then
		Lighting.FogEnd = 1e9
		Lighting.Brightness = 2.2
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 14
	else
		Lighting.FogEnd = 1000
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end)

BtnAntiRagdoll.MouseButton1Click:Connect(function()
	States.AntiRagdoll = not States.AntiRagdoll
	SetButton(BtnAntiRagdoll, States.AntiRagdoll, "Anti Ragdoll ON", "Anti Ragdoll")
end)

BtnZoom.MouseButton1Click:Connect(function()
	States.Zoom = not States.Zoom
	SetButton(BtnZoom, States.Zoom, "Inf Zoom ON", "Inf Zoom")
	LocalPlayer.CameraMaxZoomDistance = States.Zoom and 99999 or 128
end)

BtnDelete.MouseButton1Click:Connect(function()
	pcall(function() RunService:UnbindFromRenderStep("AimbotSystem") end)
	if BodyVelocity then BodyVelocity:Destroy() end
	if BodyGyro then BodyGyro:Destroy() end
	FOVCircle:Remove()
	for _, data in pairs(ESPDrawings) do
		for _, line in pairs(data.Lines) do pcall(function() line:Remove() end) end
		pcall(function() data.Name:Remove() end)
		pcall(function() data.Dist:Remove() end)
	end
	ScreenGui:Destroy()
end)

-- Keybinds
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.G then ToggleShield()
	elseif key == Enum.KeyCode.J then ToggleJump()
	elseif key == Enum.KeyCode.N then ToggleNoclip()
	elseif key == Enum.KeyCode.F then ToggleFly()
	elseif key == Enum.KeyCode.K then ToggleAimbot()
	elseif key == Enum.KeyCode.H then ToggleMenu()
	end
end)

-- Loops (Shield Asli)
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Speed
		if States.Shield then
			if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
			if not char:FindFirstChildOfClass("ForceField") then
				Instance.new("ForceField", char)
			end
		end
	end

	if States.Hitbox then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				if not OriginalSizes[plr] then
					OriginalSizes[plr] = hrp.Size
				end
				hrp.Size = Vector3.new(11, 14, 5)
				hrp.Transparency = 0.55
				hrp.CanCollide = false
			end
		end
	end
end)

UIS.JumpRequest:Connect(function()
	if States.Jump then
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then root.Velocity = Vector3.new(root.Velocity.X, 70, root.Velocity.Z) end
	end
end)

RunService.Stepped:Connect(function()
	if States.Noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- ==================== PERBAIKAN FLY UNIVERSAL (PC & MOBILE) ====================
RunService.RenderStepped:Connect(function(dt)
	if not States.Fly then return end
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not BodyVelocity or not hum then return end

	local moveDir = hum.MoveDirection
	local cameraCF = Camera.CFrame
	local velocity = Vector3.zero

	if moveDir.Magnitude > 0 then
		-- Proyeksi input pergerakan (Mendukung WASD PC & Touch Joystick Mobile secara bersamaan)
		local lookH = Vector3.new(cameraCF.LookVector.X, 0, cameraCF.LookVector.Z)
		local rightH = Vector3.new(cameraCF.RightVector.X, 0, cameraCF.RightVector.Z)
		
		if lookH.Magnitude > 0 then lookH = lookH.Unit end
		if rightH.Magnitude > 0 then rightH = rightH.Unit end

		local forwardInput = moveDir:Dot(lookH)
		local rightInput = moveDir:Dot(rightH)

		-- Menghasilkan arah pergerakan 3D mengikuti sudut pandang Kamera
		local flyDirection = (cameraCF.LookVector * forwardInput) + (cameraCF.RightVector * rightInput)
		if flyDirection.Magnitude > 0 then
			velocity = flyDirection.Unit * (Speed * 3)
		end
	end

	-- Kontrol vertikal khusus PC (Space = Naik, Shift/Ctrl = Turun)
	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		velocity = velocity + Vector3.new(0, Speed * 2, 0)
	elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
		velocity = velocity - Vector3.new(0, Speed * 2, 0)
	end

	-- Kontrol vertikal saat tombol Jump ditekan pada layar Mobile
	if isMobile and hum.Jump then
		velocity = velocity + Vector3.new(0, Speed * 2, 0)
	end

	BodyVelocity.Velocity = velocity
	if BodyGyro then
		BodyGyro.CFrame = cameraCF
	end
end)

if isPC then
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRightClick = true end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRightClick = false end
	end)
end

-- AIMBOT
local function UpdateAimbot()
	FOVCircle.Position = Camera.ViewportSize / 2
	FOVCircle.Radius = FOV
	FOVCircle.Color = FOVColor
	FOVCircle.Transparency = FOVTransparency
	FOVCircle.Visible = States.Aimbot and States.ShowFOV

	local canAim = (isPC and States.Aimbot and HoldingRightClick) or (isMobile and States.Aimbot) or (not isPC and not isMobile and States.Aimbot)
	if not canAim then return end

	local closest, shortest = nil, math.huge
	local center = Camera.ViewportSize / 2
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local pos, visible = Camera:WorldToViewportPoint(plr.Character.Head.Position)
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if visible and dist < shortest and dist < FOV then
					shortest = dist
					closest = plr
				end
			end
		end
	end
	if closest and closest.Character and closest.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
	end
end

RunService:BindToRenderStep("AimbotSystem", Enum.RenderPriority.Camera.Value + 1, UpdateAimbot)

-- ESP
local function CreateESP(player)
	if player == LocalPlayer then return end
	local lines = {}
	for i = 1, 5 do
		local line = Drawing.new("Line")
		line.Thickness = 1.6
		line.Color = Color3.fromRGB(255, 50, 50)
		line.Visible = false
		table.insert(lines, line)
	end
	local name = Drawing.new("Text")
	name.Size = 13
	name.Center = true
	name.Outline = true
	name.Color = Color3.new(1, 1, 1)
	name.Visible = false
	local dist = Drawing.new("Text")
	dist.Size = 12
	dist.Center = true
	dist.Outline = true
	dist.Color = Color3.fromRGB(160, 190, 255)
	dist.Visible = false
	ESPDrawings[player] = {Lines = lines, Name = name, Dist = dist}
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
	local data = ESPDrawings[player]
	if data then
		for _, line in pairs(data.Lines) do pcall(function() line:Remove() end) end
		pcall(function() data.Name:Remove() end)
		pcall(function() data.Dist:Remove() end)
		ESPDrawings[player] = nil
	end
end)

local function WorldToScreen(part)
	if not part then return nil, false end
	local pos, visible = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(pos.X, pos.Y), visible
end

RunService.RenderStepped:Connect(function()
	if not States.ESP then
		for _, data in pairs(ESPDrawings) do
			for _, line in pairs(data.Lines) do line.Visible = false end
			data.Name.Visible = false
			data.Dist.Visible = false
		end
		return
	end

	for player, data in pairs(ESPDrawings) do
		local char = player.Character
		if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
			local head = char:FindFirstChild("Head")
			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
			local lower = char:FindFirstChild("LowerTorso") or torso
			local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
			local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
			local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
			local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
			local root = char:FindFirstChild("HumanoidRootPart")

			local headPos, headVis = WorldToScreen(head)
			local torsoPos, torsoVis = WorldToScreen(torso)
			local lowerPos = WorldToScreen(lower)
			local lArmPos = WorldToScreen(leftArm)
			local rArmPos = WorldToScreen(rightArm)
			local lLegPos = WorldToScreen(leftLeg)
			local rLegPos = WorldToScreen(rightLeg)

			if headVis and torsoVis and States.ShowSkeleton then
				data.Lines[1].From = headPos
				data.Lines[1].To = torsoPos
				data.Lines[1].Visible = true

				if lArmPos then
					data.Lines[2].From = torsoPos
					data.Lines[2].To = lArmPos
					data.Lines[2].Visible = true
				else data.Lines[2].Visible = false end

				if rArmPos then
					data.Lines[3].From = torsoPos
					data.Lines[3].To = rArmPos
					data.Lines[3].Visible = true
				else data.Lines[3].Visible = false end

				if lLegPos then
					data.Lines[4].From = lowerPos or torsoPos
					data.Lines[4].To = lLegPos
					data.Lines[4].Visible = true
				else data.Lines[4].Visible = false end

				if rLegPos then
					data.Lines[5].From = lowerPos or torsoPos
					data.Lines[5].To = rLegPos
					data.Lines[5].Visible = true
				else data.Lines[5].Visible = false end
			else
				for i = 1, 5 do data.Lines[i].Visible = false end
			end

			if States.ShowNames and headVis then
				data.Name.Text = player.Name
				data.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
				data.Name.Visible = true
			else
				data.Name.Visible = false
			end

			if States.ShowDistance and root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and headVis then
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
				data.Dist.Text = math.floor(distance) .. "m"
				data.Dist.Position = Vector2.new(headPos.X, headPos.Y + 16)
				data.Dist.Visible = true
			else
				data.Dist.Visible = false
			end
		else
			for _, line in pairs(data.Lines) do line.Visible = false end
			data.Name.Visible = false
			data.Dist.Visible = false
		end
	end
end)

-- Anti Ragdoll
RunService.Heartbeat:Connect(function()
	if not States.AntiRagdoll then return end
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		local state = hum:GetState()
		if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			hum.Sit = false
		end
	end
end)

-- Ctrl + Click TP
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end
	end
end)

print("👑VOID VAINLY STAR")
