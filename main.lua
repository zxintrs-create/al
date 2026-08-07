local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local character
local humanoid

--// STATE
local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}


--// CHARACTER
local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
	task.wait()
	setupCharacter(char)
end)



--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileButtonControl"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")



--// CREATE BUTTON
local function createButton(name,text,position)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0,75,0,75)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(40,40,40)
	button.BackgroundTransparency = 0.25
	button.TextColor3 = Color3.new(1,1,1)
	button.Text = text
	button.TextScaled = true
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = screenGui

	return button
end



--// BUTTON
local forwardButton = createButton(
	"Forward",
	"▲",
	UDim2.new(0,120,1,-220)
)

local backwardButton = createButton(
	"Backward",
	"▼",
	UDim2.new(0,120,1,-70)
)

local leftButton = createButton(
	"Left",
	"◀",
	UDim2.new(0,35,1,-145)
)

local rightButton = createButton(
	"Right",
	"▶",
	UDim2.new(0,205,1,-145)
)

local lockButton = createButton(
	"W LOCK",
	"OFF",
	UDim2.new(0,320,1,-145)
)



--// HOLD SYSTEM
local function holdButton(button,state)

	button.MouseButton1Down:Connect(function()
		moveState[state] = true
	end)


	button.MouseButton1Up:Connect(function()
		moveState[state] = false
	end)


	button.TouchEnded:Connect(function()
		moveState[state] = false
	end)

end


holdButton(forwardButton,"Forward")
holdButton(backwardButton,"Backward")
holdButton(leftButton,"Left")
holdButton(rightButton,"Right")



--// W LOCK
lockButton.MouseButton1Click:Connect(function()

	moveState.WLock = not moveState.WLock

	if moveState.WLock then
		lockButton.Text = "ON"
		lockButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		lockButton.Text = "OFF"
		lockButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	end

end)



--// RESPONSIVE MOVEMENT
RunService.RenderStepped:Connect(function()

	if not humanoid or humanoid.Health <= 0 then
		return
	end


	local input = Vector3.zero


	if moveState.Forward or moveState.WLock then
		input += Vector3.new(0,0,-1)
	end

	if moveState.Backward then
		input += Vector3.new(0,0,1)
	end

	if moveState.Left then
		input += Vector3.new(-1,0,0)
	end

	if moveState.Right then
		input += Vector3.new(1,0,0)
	end



	if input.Magnitude > 0 then

		local camera = workspace.CurrentCamera

		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector


		local direction =
			(right * input.X)
			+
			(forward * -input.Z)


		direction = Vector3.new(
			direction.X,
			0,
			direction.Z
		)


		if direction.Magnitude > 0 then

			humanoid:Move(
				direction.Unit,
				false
			)

		end

	else

		humanoid:Move(
			Vector3.zero,
			false
		)

	end

end)
