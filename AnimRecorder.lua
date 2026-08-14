-- AUTO WALK SCRIPT NORTH WEST EAST SOUTH --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local walking = false
local walkDirection = Vector3.zero

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CheeseWalkGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.4, 0.4)
frame.Position = UDim2.fromScale(0.3, 0.3)
frame.BackgroundTransparency = 0.2
frame.Parent = gui

local function makeButton(text, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.Text = text
	b.TextScaled = true
	b.Parent = frame
	return b
end

local northBtn = makeButton("↑", UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.35, 0.05))
local southBtn = makeButton("↓", UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.35, 0.75))
local westBtn  = makeButton("←", UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.05, 0.4))
local eastBtn  = makeButton("→", UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.65, 0.4))

local stopBtn  = makeButton("STOP", UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.35, 0.4))
local killBtn  = makeButton("X", UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.82, 0.03))

-- Direction logic
northBtn.MouseButton1Click:Connect(function()
	walking = true
	walkDirection = Vector3.new(0, 0, -1)
end)

southBtn.MouseButton1Click:Connect(function()
	walking = true
	walkDirection = Vector3.new(0, 0, 1)
end)

westBtn.MouseButton1Click:Connect(function()
	walking = true
	walkDirection = Vector3.new(-1, 0, 0)
end)

eastBtn.MouseButton1Click:Connect(function()
	walking = true
	walkDirection = Vector3.new(1, 0, 0)
end)

stopBtn.MouseButton1Click:Connect(function()
	walking = false
	humanoid:Move(Vector3.zero, false)
end)

killBtn.MouseButton1Click:Connect(function()
	walking = false
	gui:Destroy()
end)

-- Force straight movement
RunService.RenderStepped:Connect(function()
	if walking then
		humanoid:Move(walkDirection, false)
	end
end)
