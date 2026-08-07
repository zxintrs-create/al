-- [[ DELTA MOBILE PRECISION CONTROL SYSTEM ]] --  
-- Developed by Delta maker script for Aldo Tzy  
-- Features: Virtual D-Pad, Hold Movement, W-Lock System, R6/R15 Support

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer  
local character = player.Character or player.CharacterAdded:Wait()  
local humanoid = character:WaitForChild("Humanoid")

-- // STATE MANAGEMENT // --  
local moveState = {  
	Forward = false,  
	Backward = false,  
	Left = false,  
	Right = false,  
	WLock = false  
}

-- // UI CONSTRUCTION // --  
local screenGui = Instance.new("ScreenGui")  
screenGui.Name = "DeltaMobileControls"  
screenGui.ResetOnSpawn = false  
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")  
mainFrame.Name = "ControlsFrame"  
mainFrame.Size = UDim2.new(0, 200, 0, 200)  
mainFrame.Position = UDim2.new(0, 50, 1, -250)  
mainFrame.BackgroundTransparency = 1  
mainFrame.Parent = screenGui

local function createButton(name, pos, size, text)  
	local btn = Instance.new("TextButton")  
	btn.Name = name  
	btn.Position = pos  
	btn.Size = size  
	btn.Text = text  
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)  
	btn.Font = Enum.Font.GothamBold  
	btn.TextSize = 20  
	btn.AutoButtonColor = false  
	  
	local corner = Instance.new("UICorner")  
	corner.CornerRadius = UDim.new(0, 10)  
	corner.Parent = btn  
	  
	btn.Parent = mainFrame  
	return btn  
end

-- Creating D-Pad Buttons  
local btnUp = createButton("Up", UDim2.new(0.35, 0, 0, 0), UDim2.new(0.3, 0, 0.3, 0), "▲")  
local btnDown = createButton("Down", UDim2.new(0.35, 0, 0.7, 0), UDim2.new(0.3, 0, 0.3, 0), "▼")  
local btnLeft = createButton("Left", UDim2.new(0, 0, 0.35, 0), UDim2.new(0.3, 0, 0.3, 0), "◀")  
local btnRight = createButton("Right", UDim2.new(0.7, 0, 0.35, 0), UDim2.new(0.3, 0, 0.3, 0), "▶")

-- Creating W Lock Button  
local btnWLock = createButton("WLock", UDim2.new(0.7, 0, 0, 0), UDim2.new(0.3, 0, 0.2, 0), "W: OFF")  
btnWLock.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- // INPUT LOGIC // --

-- Function to handle hold start  
local function setMove(dir, state)  
	moveState[dir] = state  
end

-- Up Button Events  
btnUp.MouseButton1Down:Connect(function() setMove("Forward", true) end)  
btnUp.MouseButton1Up:Connect(function() setMove("Forward", false) end)

-- Down Button Events  
btnDown.MouseButton1Down:Connect(function() setMove("Backward", true) end)  
btnDown.MouseButton1Up:Connect(function() setMove("Backward", false) end)

-- Left Button Events  
btnLeft.MouseButton1Down:Connect(function() setMove("Left", true) end)  
btnLeft.MouseButton1Up:Connect(function() setMove("Left", false) end)

-- Right Button Events  
btnRight.MouseButton1Down:Connect(function() setMove("Right", true) end)  
btnRight.MouseButton1Up:Connect(function() setMove("Right", false) end)

-- W Lock Toggle Event  
btnWLock.MouseButton1Click:Connect(function()  
	moveState.WLock = not moveState.WLock  
	if moveState.WLock then  
		btnWLock.Text = "W: ON"  
		btnWLock.BackgroundColor3 = Color3.fromRGB(0, 150, 0)  
	else  
		btnWLock.Text = "W: OFF"  
		btnWLock.BackgroundColor3 = Color3.fromRGB(150, 0, 0)  
	end  
end)

-- // MOVEMENT ENGINE // --

RunService.RenderStepped:Connect(function()  
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end  
	  
	local root = character.HumanoidRootPart  
	local camera = workspace.CurrentCamera  
	  
	-- Calculate Directional Vector relative to Camera  
	local moveVec = Vector3.new(0, 0, 0)  
	  
	-- Forward Logic (including WLock)  
	if moveState.Forward or moveState.WLock then  
		moveVec = moveVec + (camera.CFrame.LookVector * Vector3.new(1, 0, 1))  
	end  
	  
	-- Backward Logic  
	if moveState.Backward then  
		moveVec = moveVec - (camera.CFrame.LookVector * Vector3.new(1, 0, 1))  
	end  
	  
	-- Left Logic  
	if moveState.Left then  
		moveVec = moveVec - (camera.CFrame.RightVector * Vector3.new(1, 0, 1))  
	end  
	  
	-- Right Logic  
	if moveState.Right then  
		moveVec = moveVec + (camera.CFrame.RightVector * Vector3.new(1, 0, 1))  
	end  
	  
	-- Normalize vector to prevent diagonal speed increase  
	if moveVec.Magnitude > 0 then  
		moveVec = moveVec.Unit  
	end  
	  
	-- Apply move to Humanoid  
	humanoid:Move(moveVec, false)  
end)

-- Handle character respawn  
player.CharacterAdded:Connect(function(newChar)  
	character = newChar  
	humanoid = newChar:WaitForChild("Humanoid")  
end)
