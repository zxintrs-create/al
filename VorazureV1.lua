local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
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

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(8, 0)
OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(255, 255, 255)
OpenStroke.Parent = OpenMenu

local OpenGradient = Instance.new("UIGradient")
OpenGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})
OpenGradient.Parent = OpenStroke

local Image = Instance.new("ImageLabel")
Image.Name = "Image"
Image.AnchorPoint = Vector2.new(0.5, 0.5)
Image.Size = UDim2.new(0.8, 0, 0.8, 0)
Image.Position = UDim2.new(0.5, 0, 0.5, 0)
Image.BackgroundTransparency = 1
Image.Image = "rbxassetid://95844752147381"
Image.Visible = true
Image.ZIndex = 11
Image.Parent = OpenMenu

Instance.new("UICorner", Image).CornerRadius = UDim.new(8, 0)

-- MENU FRAME UTAMA
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.fromOffset(680, 420)
MenuFrame.Position = UDim2.new(0.5, -340, 0.5, -210)
MenuFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.ZIndex = 2
MenuFrame.Parent = ScreenGui

Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 2
MenuStroke.Color = Color3.fromRGB(255, 255, 255)
MenuStroke.Parent = MenuFrame

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})
MenuGradient.Parent = MenuStroke

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

-- Update FPS & Ping
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
Sidebar.Name = "UIScrollingMenu"
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
MenuLabel.Text = "MENU :"
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
	local frame = Instance.new("ScrollingFrame", ContentArea)
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.CanvasSize = UDim2.new(0, 0, 1.4, 0)
	frame.ScrollBarThickness = 4
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

-- Helper Tombol Konten Grid Kustom (Desain Tata Letak Panah & Size)
local function CreateControlBtn(parent, text, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.85, 0, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.ZIndex = 5
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function CreateControlLbl(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(0.85, 0, 0, 30)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 15
	lbl.Text = text
	lbl.ZIndex = 5
	return lbl
end

-- ==========================================================
-- 1. MAINFRAME JUMP
-- ==========================================================
CreateControlLbl(MainFrameJump, "JUMP SETTING")

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

CreateControlBtn(MainFrameJump, "↑", function()
	config.JumpY = math.clamp(config.JumpY - 0.05, 0.05, 0.95)
	updateJumpPos()
	saveConfig()
end)

CreateControlBtn(MainFrameJump, "←     →", function()
	-- Tombol Gabung Kiri Kanan atau terpisah, dibuat opsi interaktif
end)
-- Agar sesuai layout panah Anda (Atas di atas, Kiri Kanan di tengah, Bawah di bawah)
-- Kita buat struktur tombol khusus arah:
local function makeDirectionalLayout(parent, onMove)
	CreateControlBtn(parent, "↑", function() onMove(0, -0.05) end)
	
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(0.85, 0, 0, 35)
	row.BackgroundTransparency = 1
	row.ZIndex = 5
	
	local btnL = Instance.new("TextButton", row)
	btnL.Size = UDim2.new(0.48, 0, 1, 0)
	btnL.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	btnL.TextColor3 = Color3.new(1,1,1)
	btnL.Font = Enum.Font.GothamBold
	btnL.Text = "←"
	btnL.ZIndex = 5
	Instance.new("UICorner", btnL).CornerRadius = UDim.new(0, 6)
	btnL.MouseButton1Click:Connect(function() onMove(-0.05, 0) end)
	
	local btnR = Instance.new("TextButton", row)
	btnR.Size = UDim2.new(0.48, 0, 1, 0)
	btnR.Position = UDim2.new(0.52, 0, 0, 0)
	btnR.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	btnR.TextColor3 = Color3.new(1,1,1)
	btnR.Font = Enum.Font.GothamBold
	btnR.Text = "→"
	btnR.ZIndex = 5
	Instance.new("UICorner", btnR).CornerRadius = UDim.new(0, 6)
	btnR.MouseButton1Click:Connect(function() onMove(0.05, 0) end)
	
	CreateControlBtn(parent, "↓", function() onMove(0, 0.05) end)
end

-- Refresh isi MainFrameJump dengan struktur panah persis permintaan
MainFrameJump:ClearAllChildren()
local jl = Instance.new("UIListLayout", MainFrameJump)
jl.SortOrder = Enum.SortOrder.LayoutOrder
jl.Padding = UDim.new(0, 6)
jl.HorizontalAlignment = Enum.HorizontalAlignment.Center
jl.VerticalAlignment = Enum.VerticalAlignment.Center

CreateControlLbl(MainFrameJump, "JUMP SETTING")

makeDirectionalLayout(MainFrameJump, function(dx, dy)
	config.JumpX = math.clamp(config.JumpX + dx, 0.05, 0.95)
	config.JumpY = math.clamp(config.JumpY + dy, 0.05, 0.95)
	updateJumpPos()
	saveConfig()
end)

local sizeRowJump = Instance.new("Frame", MainFrameJump)
sizeRowJump.Size = UDim2.new(0.85, 0, 0, 35)
sizeRowJump.BackgroundTransparency = 1
sizeRowJump.ZIndex = 5

local bSzPlusJump = Instance.new("TextButton", sizeRowJump)
bSzPlusJump.Size = UDim2.new(0.48, 0, 1, 0)
bSzPlusJump.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzPlusJump.TextColor3 = Color3.new(1,1,1)
bSzPlusJump.Font = Enum.Font.GothamBold
bSzPlusJump.Text = "Size +"
bSzPlusJump.ZIndex = 5
Instance.new("UICorner", bSzPlusJump).CornerRadius = UDim.new(0, 6)
bSzPlusJump.MouseButton1Click:Connect(function()
	config.JumpSize = math.clamp(config.JumpSize + 0.05, 0.05, 0.50)
	local jBtn = getJumpButton()
	if jBtn then
		local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
		jBtn.Size = UDim2.fromOffset(sz, sz)
	end
	saveConfig()
end)

local bSzMinJump = Instance.new("TextButton", sizeRowJump)
bSzMinJump.Size = UDim2.new(0.48, 0, 1, 0)
bSzMinJump.Position = UDim2.new(0.52, 0, 0, 0)
bSzMinJump.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzMinJump.TextColor3 = Color3.new(1,1,1)
bSzMinJump.Font = Enum.Font.GothamBold
bSzMinJump.Text = "Size -"
bSzMinJump.ZIndex = 5
Instance.new("UICorner", bSzMinJump).CornerRadius = UDim.new(0, 6)
bSzMinJump.MouseButton1Click:Connect(function()
	config.JumpSize = math.clamp(config.JumpSize - 0.05, 0.05, 0.50)
	local jBtn = getJumpButton()
	if jBtn then
		local sz = math.max(40, math.floor(workspace.CurrentCamera.ViewportSize.Y * config.JumpSize))
		jBtn.Size = UDim2.fromOffset(sz, sz)
	end
	saveConfig()
end)

-- ==========================================================
-- 2. MAINFRAME SHIFT LOCK
-- ==========================================================
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

local sl = Instance.new("UIListLayout", MainFrameShiftLock)
sl.SortOrder = Enum.SortOrder.LayoutOrder
sl.Padding = UDim.new(0, 6)
sl.HorizontalAlignment = Enum.HorizontalAlignment.Center
sl.VerticalAlignment = Enum.VerticalAlignment.Center

CreateControlLbl(MainFrameShiftLock, "SHIFT LOCK SETTING")

makeDirectionalLayout(MainFrameShiftLock, function(dx, dy)
	config.ShiftX = math.clamp(config.ShiftX + dx, 0.05, 0.95)
	config.ShiftY = math.clamp(config.ShiftY + dy, 0.05, 0.95)
	btnShiftLock.Position = UDim2.new(config.ShiftX, 0, config.ShiftY, 0)
	saveConfig()
end)

local sizeRowShift = Instance.new("Frame", MainFrameShiftLock)
sizeRowShift.Size = UDim2.new(0.85, 0, 0, 35)
sizeRowShift.BackgroundTransparency = 1
sizeRowShift.ZIndex = 5

local bSzPlusShift = Instance.new("TextButton", sizeRowShift)
bSzPlusShift.Size = UDim2.new(0.48, 0, 1, 0)
bSzPlusShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzPlusShift.TextColor3 = Color3.new(1,1,1)
bSzPlusShift.Font = Enum.Font.GothamBold
bSzPlusShift.Text = "Size +"
bSzPlusShift.ZIndex = 5
Instance.new("UICorner", bSzPlusShift).CornerRadius = UDim.new(0, 6)
bSzPlusShift.MouseButton1Click:Connect(function()
	config.ShiftSize = math.clamp(config.ShiftSize + 5, 20, 100)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	saveConfig()
end)

local bSzMinShift = Instance.new("TextButton", sizeRowShift)
bSzMinShift.Size = UDim2.new(0.48, 0, 1, 0)
bSzMinShift.Position = UDim2.new(0.52, 0, 0, 0)
bSzMinShift.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
bSzMinShift.TextColor3 = Color3.new(1,1,1)
bSzMinShift.Font = Enum.Font.GothamBold
bSzMinShift.Text = "Size -"
bSzMinShift.ZIndex = 5
Instance.new("UICorner", bSzMinShift).CornerRadius = UDim.new(0, 6)
bSzMinShift.MouseButton1Click:Connect(function()
	config.ShiftSize = math.clamp(config.ShiftSize - 5, 20, 100)
	btnShiftLock.Size = UDim2.fromOffset(config.ShiftSize, config.ShiftSize)
	saveConfig()
end)

-- ==========================================================
-- 3. MAINFRAME DANCE / EMOTE
-- ==========================================================
local dl = Instance.new("UIListLayout", MainFrameDance)
dl.SortOrder = Enum.SortOrder.LayoutOrder
dl.Padding = UDim.new(0, 6)
dl.HorizontalAlignment = Enum.HorizontalAlignment.Center
dl.VerticalAlignment = Enum.VerticalAlignment.Center

CreateControlLbl(MainFrameDance, "EMOTES & DANCES")

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

-- NOCLIP SERVICE
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

-- BUKA/TUTUP MENU
local Loaded = false
local Loading = false

OpenMenu.Activated:Connect(function()
	if Loading then return end
	if Loaded then
		MenuFrame.Visible = not MenuFrame.Visible
		return
	end
	Loaded = true
	MenuFrame.Visible = true
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
