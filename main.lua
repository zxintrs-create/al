local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- System Drag UI
local drag
pcall(function()
	drag = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Drag-UI-SUPPORTS-MOBILE-22790"))()
end)
if not drag then
	drag = function(f)
		f.Active = true
		f.Draggable = true
	end
end

-- UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AntiFlingGui"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Frame Utama (Tema Dark Purple/Navy agar warna Neon Cyan-Ungu terlihat menonjol)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 95)
frame.Position = UDim2.new(0.5, -115, 0.5, -47)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 28)
frame.BorderSizePixel = 0
frame.Parent = gui
drag(frame)

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

-- UIStroke Frame
local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2.5
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = frame

-- UIGradient Cyan - Ungu pada Stroke Frame
local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),   -- Cyan Neon
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 40, 255)), -- Ungu Neon
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 240, 255))    -- Kembali ke Cyan (Looping mulus)
})
frameGradient.Parent = frameStroke

-- Title Text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.35, 0)
title.Position = UDim2.new(0, 0, 0.05, 0)
title.BackgroundTransparency = 1
title.Text = "Anti Slap / Anti Fling"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Parent = frame

-- Toggle Button
local toggle = Instance.new("TextButton")
toggle.Position = UDim2.new(0, 12, 0.45, 0)
toggle.Size = UDim2.new(1, -24, 0.45, 0)
toggle.BackgroundColor3 = Color3.fromRGB(28, 24, 42)
toggle.BorderSizePixel = 0
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggle

-- UIStroke & Gradient untuk Tombol
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Thickness = 1.5
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
buttonStroke.Parent = toggle

local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 40, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 240, 255))
})
buttonGradient.Parent = buttonStroke

-- ROTATE LOOP (Animasi Rotasi UIGradient)
local rotationSpeed = 90 -- Kecepatan putaran (derajat per detik)
RunService.RenderStepped:Connect(function(deltaTime)
	local currentRotation = (frameGradient.Rotation + (rotationSpeed * deltaTime)) % 360
	frameGradient.Rotation = currentRotation
	buttonGradient.Rotation = currentRotation
end)

----------------------------------------------------
-- SYSTEM ANTI FLING / ANTI SLAP
----------------------------------------------------
local AntiFling = false
local heartbeatConnection
local steppedConnection

local function cleanPhysicsObjects(char)
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") 
		or v:IsA("BodyThrust") or v:IsA("BodyPosition") or v:IsA("LinearVelocity") 
		or v:IsA("AngularVelocity") or v:IsA("VectorForce") or v:IsA("Torque") then
			v:Destroy()
		end
	end
end

local function disablePlayerCollisions()
	local myChar = LocalPlayer.Character
	if not myChar then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			for _, myPart in ipairs(myChar:GetChildren()) do
				if myPart:IsA("BasePart") then
					for _, otherPart in ipairs(player.Character:GetChildren()) do
						if otherPart:IsA("BasePart") then
							myPart.CanCollide = false
						end
					end
				end
			end
		end
	end
end

local function startProtection()
	if heartbeatConnection then heartbeatConnection:Disconnect() end
	if steppedConnection then steppedConnection:Disconnect() end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not AntiFling then return end
		local char = LocalPlayer.Character
		if not char then return end

		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")

		cleanPhysicsObjects(char)

		if root then
			if root.AssemblyLinearVelocity.Magnitude > 80 then
				root.AssemblyLinearVelocity = Vector3.zero
			end
			if root.AssemblyAngularVelocity.Magnitude > 80 then
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end

		if hum then
			if hum.Sit then hum.Sit = false end
			if hum.PlatformStand then hum.PlatformStand = false end
		end
	end)

	steppedConnection = RunService.Stepped:Connect(function()
		if AntiFling then
			disablePlayerCollisions()
		end
	end)
end

local function stopProtection()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
	if steppedConnection then
		steppedConnection:Disconnect()
		steppedConnection = nil
	end
end

local function refresh()
	if AntiFling then
		toggle.Text = "STATUS: ON"
		toggle.TextColor3 = Color3.fromRGB(0, 255, 170) -- Hijau Neon terang saat ON
		startProtection()
	else
		toggle.Text = "STATUS: OFF"
		toggle.TextColor3 = Color3.fromRGB(255, 90, 90)  -- Merah soft saat OFF
		stopProtection()
	end
end

toggle.MouseButton1Click:Connect(function()
	AntiFling = not AntiFling
	refresh()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	if AntiFling then
		task.wait(0.1)
		refresh()
	end
end)

refresh()
