local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HerbsTeleportGui"
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenu"
openButton.Size = UDim2.new(0, 100, 0, 40)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.Text = "Menu"
openButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Parent = screenGui

local mainMenu = Instance.new("Frame")
mainMenu.Name = "MainMenu"
mainMenu.Size = UDim2.new(0, 200, 0, 150)
mainMenu.Position = UDim2.new(0, 10, 0, 60)
mainMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainMenu.Visible = false
mainMenu.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleTeleport"
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Teleport: OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = mainMenu

openButton.MouseButton1Click:Connect(function()
    mainMenu.Visible = not mainMenu.Visible
end)

local isTeleportActive = false

toggleButton.MouseButton1Click:Connect(function()
    isTeleportActive = not isTeleportActive
    if isTeleportActive then
        toggleButton.Text = "Teleport: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleButton.Text = "Teleport: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Loop utama dengan posisi di samping tanaman dan penguncian rotasi natural
task.spawn(function()
    while true do
        if isTeleportActive then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
                local humanoidRootPart = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                local herbsFolder = workspace:FindFirstChild("Herbs")
                if herbsFolder then
                    for _, herb in ipairs(herbsFolder:GetChildren()) do
                        if not isTeleportActive then break end
                        
                        if (herb.Name == "Ginseng" or herb.Name == "Spirit Grass") and herb:IsA("BasePart") then
                            if herb.Parent then
                                -- Posisi di samping tanaman agar tidak melayang di atasnya
                                local sideOffset = Vector3.new(2, 0, 2)
                                local targetPos = herb.Position + sideOffset
                                
                                -- Matikan auto rotate sebentar agar kontrol game tidak melawan script
                                humanoid.AutoRotate = false
                                
                                -- Posisikan karakter dan langsung hadapkan ke arah tanaman secara akurat
                                humanoidRootPart.CFrame = CFrame.lookAt(targetPos, herb.Position)
                                
                                task.wait(0.05)
                                
                                -- Picu interaksi ProximityPrompt
                                local prompt = herb:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then
                                    for i = 1, 2 do
                                        if not herb.Parent then break end
                                        fireproximityprompt(prompt)
                                        task.wait(0.05)
                                    end
                                end
                                
                                humanoid.AutoRotate = true
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
