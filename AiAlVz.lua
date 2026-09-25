local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isBringActive = false
local hitboxes = {}

--==================================================
-- CONFIG
--==================================================

local CYAN = Color3.fromRGB(0, 255, 255)
local PURPLE = Color3.fromRGB(170, 0, 255)
local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(0, 0, 0)

--==================================================
-- SCREEN GUI
--==================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxControllerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

--==================================================
-- OPEN BUTTON
--==================================================

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Size = UDim2.new(0, 120, 0, 40)
openBtn.Position = UDim2.new(0, 15, 0.5, -20)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextColor3 = BLACK
openBtn.Text = "OPEN MENU"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.AutoButtonColor = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0.8, 0)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2
openStroke.Color = WHITE
openStroke.Parent = openBtn

local openGradient = Instance.new("UIGradient")
openGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(1, PURPLE)
})
openGradient.Rotation = 0
openGradient.Parent = openBtn

--==================================================
-- MAIN FRAME
--==================================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 285, 0, 175)
mainFrame.Position = UDim2.new(0.5, -142, 0.5, -87)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0.8, 0)
frameCorner.Parent = mainFrame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(1, PURPLE)
})
frameGradient.Rotation = 45
frameGradient.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2.5
frameStroke.Color = WHITE
frameStroke.Parent = mainFrame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(0.5, WHITE),
	ColorSequenceKeypoint.new(1, PURPLE)
})
strokeGradient.Parent = frameStroke

--==================================================
-- TITLE
--==================================================

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -60, 0, 40)
titleLabel.Position = UDim2.new(0, 15, 0, 3)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HITBOX MANAGER"
titleLabel.TextColor3 = BLACK
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 17
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

--==================================================
-- CLOSE BUTTON
--==================================================

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextColor3 = BLACK
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.AutoButtonColor = false
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.8, 0)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 2
closeStroke.Color = WHITE
closeStroke.Parent = closeBtn

local closeGradient = Instance.new("UIGradient")
closeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(1, PURPLE)
})
closeGradient.Rotation = 0
closeGradient.Parent = closeBtn

--==================================================
-- TOGGLE BUTTON
--==================================================

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0.86, 0, 0, 52)
toggleBtn.Position = UDim2.new(0.07, 0, 0, 78)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextColor3 = BLACK
toggleBtn.Text = "Bring Hitbox: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.8, 0)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Color = WHITE
toggleStroke.Parent = toggleBtn

local toggleGradient = Instance.new("UIGradient")
toggleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(1, PURPLE)
})
toggleGradient.Rotation = 0
toggleGradient.Parent = toggleBtn

--==================================================
-- HITBOX MANAGEMENT
--==================================================

local function saveOriginalHitboxes()
	hitboxes = {}

	local stagesFolder = workspace:FindFirstChild("Stages")

	if stagesFolder then
		for _, stage in ipairs(stagesFolder:GetChildren()) do
			local hitbox = stage:FindFirstChild("Hitbox")

			if hitbox and hitbox:IsA("BasePart") then
				table.insert(hitboxes, {
					part = hitbox,
					originalCFrame = hitbox.CFrame,
					originalAnchored = hitbox.Anchored,
					originalCanCollide = hitbox.CanCollide
				})
			end
		end
	end
end

local function restoreHitboxes()
	for _, data in ipairs(hitboxes) do
		if data.part and data.part.Parent then
			data.part.CFrame = data.originalCFrame
			data.part.Anchored = data.originalAnchored
			data.part.CanCollide = data.originalCanCollide
		end
	end

	hitboxes = {}
end

--==================================================
-- BUTTON EVENTS
--==================================================

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
	isBringActive = not isBringActive

	if isBringActive then
		toggleBtn.Text = "Bring Hitbox: ON"

		saveOriginalHitboxes()

		for _, data in ipairs(hitboxes) do
			if data.part and data.part.Parent then
				data.part.CanCollide = false
				data.part.Anchored = true
			end
		end
	else
		toggleBtn.Text = "Bring Hitbox: OFF"

		restoreHitboxes()
	end
end)

--==================================================
-- BRING HITBOX
--==================================================

RunService.Heartbeat:Connect(function()
	if not isBringActive then
		return
	end

	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local targetCFrame = rootPart.CFrame

	for i = #hitboxes, 1, -1 do
		local data = hitboxes[i]

		if data.part and data.part.Parent then
			data.part.CFrame = targetCFrame
		else
			table.remove(hitboxes, i)
		end
	end
end)

--==================================================
-- ANIMATED CYAN → PURPLE STROKES
--==================================================

task.spawn(function()
	local rotation = 0

	while screenGui.Parent do
		rotation = (rotation + 1.5) % 360

		strokeGradient.Rotation = rotation
		openGradient.Rotation = rotation
		toggleGradient.Rotation = rotation
		closeGradient.Rotation = rotation

		task.wait(0.03)
	end
end)
