-- Minimal LocalScript UI
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local SKY_ID = 11675661848
local MUSIC_ID = 134324160901088

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LocalAdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 120, 0, 32)
ToggleBtn.Position = UDim2.new(0, 12, 0.5, -16)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "AL KNIGHT"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "Local Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 2)
CloseBtn.Text = "X"
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12

local function makeButton(text, y, callback)
	local b = Instance.new("TextButton", MainFrame)
	b.Size = UDim2.new(1, -20, 0, 28)
	b.Position = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 11
	b.MouseButton1Click:Connect(function()
		pcall(callback)
	end)
	return b
end

local bgSound

makeButton("Apply Skybox", 45, function()
	local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
	sky.SkyboxBk = "rbxassetid://" .. SKY_ID
	sky.SkyboxDn = "rbxassetid://" .. SKY_ID
	sky.SkyboxFt = "rbxassetid://" .. SKY_ID
	sky.SkyboxLf = "rbxassetid://" .. SKY_ID
	sky.SkyboxRt = "rbxassetid://" .. SKY_ID
	sky.SkyboxUp = "rbxassetid://" .. SKY_ID
end)

makeButton("Play Music", 80, function()
	if bgSound then bgSound:Destroy() end
	bgSound = Instance.new("Sound", SoundService)
	bgSound.SoundId = "rbxassetid://" .. MUSIC_ID
	bgSound.Looped = true
	bgSound.Volume = 1
	bgSound:Play()
end)

makeButton("Stop Music", 115, function()
	if bgSound then bgSound:Destroy() end
end)

makeButton("Close Panel", 150, function()
	MainFrame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
