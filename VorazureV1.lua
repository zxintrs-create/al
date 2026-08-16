local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local CONFIG_FILE = "VZMenuConfig.json"

local defaultConfig = {
	JumpX = 0.85,
	JumpY = 0.75,
	JumpSize = 0.30,
	ShiftX = 0.75,
	ShiftY = 0.65,
	ShiftSize = 35,
}

local config = {}
for k, v in pairs(defaultConfig) do
	config[k] = v
end

local function saveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode(config))
		end
	end)
end

local function loadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if type(data) == "table" then
				for k, v in pairs(data) do
					if defaultConfig[k] ~= nil then
						config[k] = v
					end
				end
			end
		end
	end)
end

loadConfig()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VZMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local OpenMenu = Instance.new("ImageButton")
OpenMenu.Name = "OpenMenu"
OpenMenu.Size = UDim2.fromOffset(58, 58)
OpenMenu.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenMenu.BackgroundTransparency = 0.2
OpenMenu.BorderSizePixel = 0
OpenMenu.AutoButtonColor = false
OpenMenu.Active = true
OpenMenu.ZIndex = 10
OpenMenu.Parent = ScreenGui

Instance.new("UICorner", OpenMenu).CornerRadius = UDim.new(8, 0)
local OpenStroke = Instance.new("UIStroke", OpenMenu)
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(255, 255, 255)

local OpenGradient = Instance.new("UIGradient", OpenStroke)
OpenGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

local Image = Instance.new("ImageLabel", OpenMenu)
Image.Name = "Image"
Image.AnchorPoint = Vector2.new(0.5, 0.5)
Image.Size = UDim2.new(0.8, 0, 0.8, 0)
Image.Position = UDim2.new(0.5, 0, 0.5, 0)
Image.BackgroundTransparency = 1
Image.Image = "rbxassetid://95844752147381"
Image.ZIndex = 11
Instance.new("UICorner", Image).CornerRadius = UDim.new(8, 0)

-- MENU FRAME UTAMA
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.fromOffset(680, 420)
MenuFrame.Position = UDim2.new(0.5, -340, 0.5, -210)
MenuFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.ZIndex = 2

Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)
local MenuStroke = Instance.new("UIStroke", MenuFrame)
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(255, 255, 255)

local MenuGradient = Instance.new("UIGradient", MenuStroke)
MenuGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

-- TOP BAR (STATUS FPS & PING)
local TopBar = Instance.new("Frame", MenuFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TitleInfo = Instance.new("TextLabel", TopBar)
TitleInfo.Size = UDim2.new(1, -20, 1, 0)
TitleInfo.Position = UDim2.new(0, 15, 0, 0)
TitleInfo.BackgroundTransparency = 1
TitleInfo.Font = Enum.Font.GothamBold
TitleInfo.TextSize = 13
TitleInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleInfo.TextXAlignment = Enum.TextXAlignment.Left
TitleInfo.Text = "ALDO VORA ZURE      FPS : 0      PING : 0 ms"
TitleInfo.ZIndex = 4

task.spawn(function()
	local lastUpdate = tick()
	local frames = 0
	RunService.RenderStepped:Connect(function()
		frames = frames + 1
		local now = tick()
		if now - lastUpdate >= 1 then
			local fps = math.floor(frames / (now - lastUpdate))
			local ping = 0
			pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
			TitleInfo.Text = string.format("ALDO VORA ZURE      FPS : %d      PING : %d ms", fps, ping)
			frames = 0
			lastUpdate = now
		end
	end)
end)

-- SIDEBAR MENU (KIRI)
local Sidebar = Instance.new("Frame", MenuFrame)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.28, 0, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MenuLabel = Instance.new("TextLabel", Sidebar)
MenuLabel.Size = UDim2.new(1, 0, 0, 35)
MenuLabel.BackgroundTransparency = 1
MenuLabel.Text = "MENU   :"
MenuLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
MenuLabel.Font = Enum.Font.GothamBlack
MenuLabel.TextSize = 14
MenuLabel.ZIndex = 4

-- CONTENT AREA (KANAN)
local ContentArea = Instance.new("Frame", MenuFrame)
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(0.72, 0, 1, -35)
ContentArea.Position = UDim2.new(0.28, 0, 0, 35)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 3

local function CreateMainFrame(name)
	local frame = Instance.new("Frame", ContentArea)
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.ZIndex = 4
	
	local layout = Instance.new("UIListLayout", frame)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	return frame
end

local MainFrameJump = CreateMainFrame("MainFrameJump")
local MainFrameShiftLock = CreateMainFrame("MainFrameShiftLock")
local MainFrameDance = CreateMainFrame("MainFrameDance")

local function SwitchMenu(targetFrame)
	MainFrameJump.Visible = (targetFrame == MainFrameJump)
	MainFrameShiftLock.Visible = (targetFrame == MainFrameShiftLock)
	MainFrameDance.Visible = (targetFrame == MainFrameDance)
end

local function CreateNavButton(text, targetFrame)
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(0.9, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Text = text
	btn.ZIndex = 4
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function() SwitchMenu(targetFrame) end)
	return btn
end

CreateNavButton("Jump", MainFrameJump)
CreateNavButton("Shift lock", MainFrameShiftLock)
CreateNavButton("Emote", MainFrameDance)

local function CreateControlBtn(parent, text, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.85, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Text = text
	btn.ZIndex = 5
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function CreateControlLbl(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(0.85, 0, 0, 25)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 14
	lbl.Text = text
	lbl.ZIndex = 5
	return lbl
end

-- ==========================================================
-- 1. MAINFRAME JUMP SETTING
-- ==========================================================
CreateControlLbl(MainFrameJump, "Jump  setting")

local jumpButtonRef
local function getJumpButton()
	if jumpButtonRef and jumpButtonRef.Parent then return jumpButtonRef end
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui then jumpButtonRef = touchGui:FindFirstChild("JumpButton", true) end
	return jumpButtonRef
end

local function updateJumpPos()
	local jBtn = getJumpButton()
	if jBtn then
		jBtn.AnchorPoint = Vector2.new(0.5, 0.5)
		jBtn.Position = UDim2.new(config.JumpX, 0, config.JumpY, 0)
	end
end

-- Tombol Atas (↑)
CreateControlBtn(MainFrameJump, "↑", function()
	config.JumpY = math.clamp(config.JumpY - 0.05, 0.05, 0.95)
	updateJumpPos()
end)

-- Baris Tengah (←   →)
local rowJumpLR = Instance.new("Frame", MainFrameJump)
rowJumpLR.Size = UDim2.new(0.85, 0, 0, 32)
rowJumpLR.BackgroundTransparency = 1
rowJumpLR.ZIndex = 5

local btnJumpL = Instance.new("TextButton", rowJumpLR)
btnJumpL.Size = UDim2.new(0.48, 0, 1, 0)
btnJumpL.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnJumpL.TextColor3 = Color3.new(1,1,1)
btnJumpL.Font = Enum.Font.GothamBold
btnJumpL.Text = "←"
btnJumpL.ZIndex = 5
Instance.new("UICorner", btnJumpL).CornerRadius = UDim.new(0, 6)
btnJumpL.MouseButton1Click:Connect(function()
	config.JumpX = math.clamp(config.JumpX - 0.05, 0.05, 0.95)
	updateJumpPos()
end)

local btnJumpR = Instance.new("TextButton", rowJumpLR)
btnJumpR.Size = UDim2.new(0.48, 0, 1, 0)
btnJumpR.Position = UDim2.new(0.52, 0, 0, 0)
btnJumpR.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnJumpR.TextColor3 = Color3.new(1,1,1)
btnJumpR.Font = Enum.Font.GothamBold
btnJumpR.Text = "→"
btnJumpR.ZIndex = 5
Instance.new("UICorner", btnJumpR).CornerRadius = UDim.new(0, 6)
btnJumpR.MouseButton1Click:Connect(function()
	config.JumpX = math.clamp(config.JumpX + 0.05, 0.05, 0.95)
	updateJumpPos()
end)

-- Tombol Bawah (↓)
CreateControlBtn(MainFrameJump, "↓", function()
	config.JumpY = math.clamp(config.JumpY + 0.05, 0.05, 0.95)
	updateJumpPos()
end)

local rowJumpSize = Instance.new("Frame", MainFrameJump)
rowJumpSize.Size = UDim2.new(0.85, 0, 0, 32)
rowJumpSize.BackgroundTransparency = 1
rowJumpSize.ZIndex = 5

local bSzPlusJump = Instance.new("TextButton", rowJumpSize)
bSzPlusJump.Size = UDim2.new(0.48, 0, 1, 0)
bSzPlusJump.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzPlusJump.TextColor3 = Color3.new(1,1,1)
bSzPlusJump.Font = Enum.Font.GothamBold
bSzPlusJump.Text = "size+"
bSzPlusJump.ZIndex = 5
Instance.new("UICorner", bSzPlusJump).CornerRadius = UDim.new(0, 6)
bSzPlusJump.MouseButton1Click:Connect(function()
	config.JumpSize = math.clamp(config.JumpSize + 0.05, 0.05, 0.50)
	local jBtn = getJumpButton()
	if jBtn then
		local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
		jBtn.Size = UDim2.fromOffset(sz, sz)
	end
end)

local bSzMinJump = Instance.new("TextButton", rowJumpSize)
bSzMinJump.Size = UDim2.new(0.48, 0, 1, 0)
bSzMinJump.Position = UDim2.new(0.52, 0, 0, 0)
bSzMinJump.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzMinJump.TextColor3 = Color3.new(1,1,1)
bSzMinJump.Font = Enum.Font.GothamBold
bSzMinJump.Text = "size-"
bSzMinJump.ZIndex = 5
Instance.new("UICorner", bSzMinJump).CornerRadius = UDim.new(0, 6)
bSzMinJump.MouseButton1Click:Connect(function()
	config.JumpSize = math.clamp(config.JumpSize - 0.05, 0.05, 0.50)
	local jBtn = getJumpButton()
	if jBtn then
		local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
		jBtn.Size = UDim2.fromOffset(sz, sz)
	end
end)
local rowJumpSR = Instance.new("Frame", MainFrameJump)
rowJumpSR.Size = UDim2.new(0.85, 0, 0, 32)
rowJumpSR.BackgroundTransparency = 1
rowJumpSR.ZIndex = 5

local btnSave = Instance.new("TextButton", rowJumpSR)
btnSave.Size = UDim2.new(0.48, 0, 1, 0)
btnSave.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnSave.TextColor3 = Color3.fromRGB(0, 255, 100)
btnSave.Font = Enum.Font.GothamBold
btnSave.Text = "Save"
btnSave.ZIndex = 5
Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 6)
btnSave.MouseButton1Click:Connect(function()
	saveConfig()
end)

local btnReset = Instance.new("TextButton", rowJumpSR)
btnReset.Size = UDim2.new(0.48, 0, 1, 0)
btnReset.Position = UDim2.new(0.52, 0, 0, 0)
btnReset.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnReset.TextColor3 = Color3.fromRGB(255, 50, 50)
btnReset.Font = Enum.Font.GothamBold
btnReset.Text = "reset"
btnReset.ZIndex = 5
Instance.new("UICorner", btnReset).CornerRadius = UDim.new(0, 6)
btnReset.MouseButton1Click:Connect(function()
	config.JumpX = defaultConfig.JumpX
	config.JumpY = defaultConfig.JumpY
	config.JumpSize = defaultConfig.JumpSize
	updateJumpPos()
	local jBtn = getJumpButton()
	if jBtn then
		local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
		jBtn.Size = UDim2.fromOffset(sz, sz)
	end
	saveConfig()
end)
_G.ShiftLocked = false
local crosshair = Instance.new("Frame", ScreenGui)
crosshair.Name = "ShiftLockCrosshair"
crosshair.Size = UDim2.fromOffset(6, 6)
crosshair.Position = UDim2.new(0.5, -3, 0.5, -3)
crosshair.BackgroundColor3 = Color3.new(1, 1, 1)
crosshair.Visible = false
crosshair.ZIndex = 1000000
Instance.new("UICorner", crosshair).CornerRadius = UDim.new(1, 0)

local btnShiftLock = Instance.new("ImageButton", ScreenGui)
btnShiftLock.Name = "ShiftLockButton"
btnShiftLock.AnchorPoint = Vector2.new(0.5, 0.5)
btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
btnShiftLock.Image = "rbxassetid://136616143786672"
btnShiftLock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btnShiftLock.BackgroundTransparency = 0.2
btnShiftLock.Active = true
btnShiftLock.ZIndex = 100000
Instance.new("UICorner", btnShiftLock).CornerRadius = UDim.new(1, 0)

local function toggleShiftLock()
	_G.ShiftLocked = not _G.ShiftLocked
	crosshair.Visible = _G.ShiftLocked
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.AutoRotate = not _G.ShiftLocked
		character.Humanoid.CameraOffset = Vector3.zero
	end
end
btnShiftLock.Activated:Connect(toggleShiftLock)

CreateControlLbl(MainFrameShiftLock, "Shift lock setting")

CreateControlBtn(MainFrameShiftLock, "↑", function()
	config.ShiftY = math.clamp(config.ShiftY - 0.05, 0.05, 0.95)
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
end)

local rowShiftLR = Instance.new("Frame", MainFrameShiftLock)
rowShiftLR.Size = UDim2.new(0.85, 0, 0, 32)
rowShiftLR.BackgroundTransparency = 1
rowShiftLR.ZIndex = 5

local btnShiftL = Instance.new("TextButton", rowShiftLR)
btnShiftL.Size = UDim2.new(0.48, 0, 1, 0)
btnShiftL.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnShiftL.TextColor3 = Color3.new(1,1,1)
btnShiftL.Font = Enum.Font.GothamBold
btnShiftL.Text = "←"
btnShiftL.ZIndex = 5
Instance.new("UICorner", btnShiftL).CornerRadius = UDim.new(0, 6)
btnShiftL.MouseButton1Click:Connect(function()
	config.ShiftX = math.clamp(config.ShiftX - 0.05, 0.05, 0.95)
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
end)

local btnShiftR = Instance.new("TextButton", rowShiftLR)
btnShiftR.Size = UDim2.new(0.48, 0, 1, 0)
btnShiftR.Position = UDim2.new(0.52, 0, 0, 0)
btnShiftR.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnShiftR.TextColor3 = Color3.new(1,1,1)
btnShiftR.Font = Enum.Font.GothamBold
btnShiftR.Text = "→"
btnShiftR.ZIndex = 5
Instance.new("UICorner", btnShiftR).CornerRadius = UDim.new(0, 6)
btnShiftR.MouseButton1Click:Connect(function()
	config.ShiftX = math.clamp(config.ShiftX + 0.05, 0.05, 0.95)
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
end)

CreateControlBtn(MainFrameShiftLock, "↓", function()
	config.ShiftY = math.clamp(config.ShiftY + 0.05, 0.05, 0.95)
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
end)

local rowShiftSize = Instance.new("Frame", MainFrameShiftLock)
rowShiftSize.Size = UDim2.new(0.85, 0, 0, 32)
rowShiftSize.BackgroundTransparency = 1
rowShiftSize.ZIndex = 5

local bSzPlusShift = Instance.new("TextButton", rowShiftSize)
bSzPlusShift.Size = UDim2.new(0.48, 0, 1, 0)
bSzPlusShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzPlusShift.TextColor3 = Color3.new(1,1,1)
bSzPlusShift.Font = Enum.Font.GothamBold
bSzPlusShift.Text = "size+"
bSzPlusShift.ZIndex = 5
Instance.new("UICorner", bSzPlusShift).CornerRadius = UDim.new(0, 6)
bSzPlusShift.MouseButton1Click:Connect(function()
	config.ShiftSize = math.clamp(config.ShiftSize + 5, 20, 100)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
end)

local bSzMinShift = Instance.new("TextButton", rowShiftSize)
bSzMinShift.Size = UDim2.new(0.48, 0, 1, 0)
bSzMinShift.Position = UDim2.new(0.52, 0, 0, 0)
bSzMinShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzMinShift.TextColor3 = Color3.new(1,1,1)
bSzMinShift.Font = Enum.Font.GothamBold
bSzMinShift.Text = "size-"
bSzMinShift.ZIndex = 5
Instance.new("UICorner", bSzMinShift).CornerRadius = UDim.new(0, 6)
bSzMinShift.MouseButton1Click:Connect(function()
	config.ShiftSize = math.clamp(config.ShiftSize - 5, 20, 100)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
end)

local rowShiftSR = Instance.new("Frame", MainFrameShiftLock)
rowShiftSR.Size = UDim2.new(0.85, 0, 0, 32)
rowShiftSR.BackgroundTransparency = 1
rowShiftSR.ZIndex = 5

local btnSaveShift = Instance.new("TextButton", rowShiftSR)
btnSaveShift.Size = UDim2.new(0.48, 0, 1, 0)
btnSaveShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnSaveShift.TextColor3 = Color3.fromRGB(0, 255, 100)
btnSaveShift.Font = Enum.Font.GothamBold
btnSaveShift.Text = "Save"
btnSaveShift.ZIndex = 5
Instance.new("UICorner", btnSaveShift).CornerRadius = UDim.new(0, 6)
btnSaveShift.MouseButton1Click:Connect(function()
	saveConfig()
end)

local btnResetShift = Instance.new("TextButton", rowShiftSR)
btnResetShift.Size = UDim2.new(0.48, 0, 1, 0)
btnResetShift.Position = UDim2.new(0.52, 0, 0, 0)
btnResetShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
btnResetShift.TextColor3 = Color3.fromRGB(255, 50, 50)
btnResetShift.Font = Enum.Font.GothamBold
btnResetShift.Text = "reset"
btnResetShift.ZIndex = 5
Instance.new("UICorner", btnResetShift).CornerRadius = UDim.new(0, 6)
btnResetShift.MouseButton1Click:Connect(function()
	config.ShiftX = defaultConfig.ShiftX
	config.ShiftY = defaultConfig.ShiftY
	config.ShiftSize = defaultConfig.ShiftSize
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	saveConfig()
end)
CreateControlLbl(MainFrameDance, "Emotes & Dances")
local function PlayAnimation(assetId)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(assetId)
		local loadAnim = char.Humanoid:LoadAnimation(anim)
		loadAnim:Play()
	end
end

CreateControlBtn(MainFrameDance, "Dance 1", function() PlayAnimation(507710273) end)
CreateControlBtn(MainFrameDance, "Dance 2", function() PlayAnimation(507719543) end)
CreateControlBtn(MainFrameDance, "Emote 1", function() PlayAnimation(591577311) end)
CreateControlBtn(MainFrameDance, "Emote 2", function() PlayAnimation(591578361) end)
CreateControlBtn(MainFrameDance, "Jump Style", function() PlayAnimation(3338871789) end)
RunService.Stepped:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end
end)

OpenMenu.Activated:Connect(function()
	MenuFrame.Visible = not MenuFrame.Visible
end)

RunService.RenderStepped:Connect(function(dt)
	local rot = (tick() * 45) % 360
	OpenGradient.Rotation = rot
	MenuGradient.Rotation = rot
	
	if _G.ShiftLocked then
		local camera = workspace.CurrentCamera
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if camera and root then
			local _, y = camera.CFrame:ToOrientation()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
		end
	end
end)
