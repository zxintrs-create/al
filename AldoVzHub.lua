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

-- Fungsi mencari tanaman terdekat (Ginseng atau Spirit Grass) di dalam Workspace > Herbs
local function getNearestHerb(characterRoot)
    local nearestPart = nil
    local shortestDistance = math.huge

    local herbsFolder = workspace:FindFirstChild("Herbs")
    if herbsFolder then
        for _, obj in ipairs(herbsFolder:GetChildren()) do
            if (obj.Name == "Ginseng" or obj.Name == "Spirit Grass") and obj:IsA("BasePart") then
                local distance = (obj.Position - characterRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPart = obj
                end
            end
        end
    end

    return nearestPart
end

-- Loop utama dengan penerapan rotasi sumbu Y 40 lalu ke 90 derajat
task.spawn(function()
    while true do
        if isTeleportActive then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                
                local nearestHerb = getNearestHerb(humanoidRootPart)

                if nearestHerb then
                    if (humanoidRootPart.Position - nearestHerb.Position).Magnitude > 5 then
                        local targetPos = nearestHerb.Position + Vector3.new(0, 3, 0)
                        
                        -- 1. Teleport awal dengan rotasi sumbu Y 40 derajat
                        humanoidRootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(40), 0)
                        
                        local prompt = nearestHerb:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        
                        -- Jeda sangat singkat untuk transisi rotasi
                        task.wait(0.05)
                        
                        -- 2. Langsung ubah rotasi ke sumbu Y 90 derajat di posisi yang sama
                        humanoidRootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(90), 0)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)
