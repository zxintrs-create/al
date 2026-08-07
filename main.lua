local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Matikan kontrol default Roblox Mobile
local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()
Controls:Disable()


local character
local humanoid

local moveState = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	WLock = false
}


local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)



-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileButtonControl"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")


local function createButton(name,text,pos)

	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.fromOffset(75,75)
	b.Position = pos
	b.BackgroundTransparency = 0.3
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = gui

	return b
end


local Forward = createButton(
	"Forward",
	"▲",
	UDim2.new(0,120,1,-200)
)

local Backward = createButton(
	"Backward",
	"▼",
	UDim2.new(0,120,1,-80)
)

local Left = createButton(
	"Left",
	"◀",
	UDim2.new(0,40,1,-140)
)

local Right = createButton(
	"Right",
	"▶",
	UDim2.new(0,200,1,-140)
)

local WLock = createButton(
	"W LOCK",
	"OFF",
	UDim2.new(0,310,1,-140)
)



-- HOLD TOUCH
local function bindHold(button,state)

	button.TouchStarted:Connect(function()
		moveState[state] = true
	end)

	button.TouchEnded:Connect(function()
		moveState[state] = false
	end)

end


bindHold(Forward,"Forward")
bindHold(Backward,"Backward")
bindHold(Left,"Left")
bindHold(Right,"Right")



-- W LOCK
WLock.TouchTap:Connect(function()

	moveState.WLock = not moveState.WLock

	if moveState.WLock then
		WLock.Text = "ON"
		WLock.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		WLock.Text = "OFF"
		WLock.BackgroundColor3 = Color3.fromRGB(40,40,40)
	end

end)



-- MOVEMENT
RunService.RenderStepped:Connect(function()

	if not humanoid then return end

	local x = 0
	local z = 0


	if moveState.Forward or moveState.WLock then
		z -= 1
	end

	if moveState.Backward then
		z += 1
	end

	if moveState.Left then
		x -= 1
	end

	if moveState.Right then
		x += 1
	end


	local move = Vector3.new(x,0,z)


	if move.Magnitude > 0 then

		local camera = workspace.CurrentCamera

		local direction =
			camera.CFrame.RightVector * move.X +
			camera.CFrame.LookVector * -move.Z

		direction = Vector3.new(
			direction.X,
			0,
			direction.Z
		)


		humanoid:Move(direction.Unit,true)

	else
		humanoid:Move(Vector3.zero,true)
	end

end)
