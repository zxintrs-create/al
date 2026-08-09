--// Auto Walk Script with Sleek Toggle GUI //--

-- Instances
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Toggle = Instance.new("TextButton")

-- Properties
ScreenGui.Parent = game:GetService("CoreGui")

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Size = UDim2.new(0, 150, 0, 80)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.Active = true
Frame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

Title.Parent = Frame
Title.Text = "Auto Walk"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.BackgroundTransparency = 1

Toggle.Parent = Frame
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Toggle.Size = UDim2.new(0.7, 0, 0.35, 0)
Toggle.Position = UDim2.new(0.15, 0, 0.55, 0)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextScaled = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Toggle state
local walkEnabled = false

-- Toggle function
local function toggleWalk()
    walkEnabled = not walkEnabled
    if walkEnabled then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    end
end

-- Connect Button
Toggle.MouseButton1Click:Connect(toggleWalk)

-- Auto Walk Loop (runs every frame)
RunService.RenderStepped:Connect(function()
    if walkEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        local hrp = player.Character.HumanoidRootPart
        local hum = player.Character.Humanoid

        -- Move forward relative to where the character is facing
        local forwardVector = hrp.CFrame.LookVector
        hum:Move(Vector3.new(forwardVector.X, 0, forwardVector.Z), false)
    end
end)
