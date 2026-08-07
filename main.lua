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
	setupCharacter(char)
end)



--// GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileControl"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")



--// BUTTON
local function createButton(name,text,pos)

	local button = Instance.new("TextButton")

	button.Name = name
	button.Size = UDim2.new(0,75,0,75)
	button.Position = pos
	button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	button.BackgroundTransparency = 0.25
	button.TextColor3 = Color3.new(1,1,1)
	button.Text = text
	button.TextScaled = true
	button.BorderSizePixel = 0

	button.Parent = screenGui

	return button
end



local forward = createButton(
	"Forward",
	"▲",
	UDim2.new(0,120,1,-210)
)

local backward = createButton(
	"Backward",
	"▼",
	UDim2.new(0,120,1,-70)
)

local left = createButton(
	"Left",
	"◀",
	UDim2.new(0,35,1,-140)
)

local right = createButton(
	"Right",
	"▶",
	UDim2.new(0,205,1,-140)
)

local wLock = createButton(
	"W LOCK",
	"OFF",
	UDim2.new(0,320,1,-140)
)



--// HOLD BUTTON FIX MOBILE
local function connectHold(button,state)

	button.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch then

			moveState[state] = true

		end

	end)


	button.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch then

			moveState[state] = false

		end

	end)

end


connectHold(forward,"Forward")
connectHold(backward,"Backward")
connectHold(left,"Left")
connectHold(right,"Right")



--// W LOCK BUTTON
wLock.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch then

		moveState.WLock = not moveState.WLock


		if moveState.WLock then

			wLock.Text = "ON"
			wLock.BackgroundColor3 = Color3.fromRGB(0,255,0)

		else

			wLock.Text = "OFF"
			wLock.BackgroundColor3 = Color3.fromRGB(35,35,35)

		end

	end

end)



--// MOVEMENT ENGINE
RunService.RenderStepped:Connect(function()

	if not humanoid then
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


		local direction =
			(camera.CFrame.RightVector * input.X)
			+
			(camera.CFrame.LookVector * -input.Z)



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
