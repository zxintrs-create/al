local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GinsengTeleportGui"
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

local function removePlatform()
    local character = player.Character
    if character then
        for _, obj in ipairs(character:GetChildren()) do
            if obj.Name == "SafetyPlatform" then
                obj:Destroy()
            end
        end
    end
end

local function createPlatform()
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    removePlatform()

    local platform = Instance.new("Part")
    platform.Name = "SafetyPlatform"
    platform.Size = Vector3.new(5, 1, 5)
    platform.Transparency = 0.5
    platform.CanCollide = false
    platform.BrickColor = BrickColor.new("Really red")
    platform.CFrame = rootPart.CFrame - Vector3.new(0, 4, 0)
    platform.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = platform
    weld.Parent = platform
end

local function getNearestGinseng(characterRoot)
    local nearestPart = nil
    local shortestDistance = math.huge

    local herbsFolder = workspace:FindFirstChild("Herbs")
    if herbsFolder then
        for _, obj in ipairs(herbsFolder:GetChildren()) do
            if obj.Name == "Ginseng" and obj:IsA("BasePart") then
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

local function triggerPromptReliably(prompt)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
        -- Metode alternatif paksa jika fungsi standar diabaikan game
        if prompt.HoldDuration > 0 then
            task.delay(prompt.HoldDuration, function()
                if prompt and prompt.Parent then
                    prompt:InputHoldEnd(player)
                end
            end)
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    isTeleportActive = not isTeleportActive
    if isTeleportActive then
        toggleButton.Text = "Teleport: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        createPlatform()
    else
        toggleButton.Text = "Teleport: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        removePlatform()
    end
end)

task.spawn(function()
    while true do
        if isTeleportActive then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                
                local nearestGinseng = getNearestGinseng(humanoidRootPart)

                if nearestGinseng then
                    if (humanoidRootPart.Position - nearestGinseng.Position).Magnitude > 5 then
                        humanoidRootPart.CFrame = nearestGinseng.CFrame + Vector3.new(0, 3, 0)

                        local prompt = nearestGinseng:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            triggerPromptReliably(prompt)
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)
