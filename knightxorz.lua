-- [[ DELTA MOBILE PRECISION CONTROL V2: EXPANDED EDITION ]] --  
-- Added: Jump Button, UI Scaling System (+/-)

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer  
local character = player.Character or player.CharacterAdded:Wait()  
local humanoid = character:WaitForChild("Humanoid")

-- // STATE MANAGEMENT // --  
local moveState = {  
    Forward = false,  
    Backward = false,  
    Left = false,  
    Right = false,  
    WLock = false,  
    UIScale = 1  
}

-- // UI CONSTRUCTION // --  
local screenGui = Instance.new("ScreenGui")  
screenGui.Name = "DeltaMobileControlsV2"  
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

-- [ D-PAD BUTTONS ]  
local btnUp = createButton("Up", UDim2.new(0.35, 0, 0, 0), UDim2.new(0.3, 0, 0.3, 0), "▲")  
local btnDown = createButton("Down", UDim2.new(0.35, 0, 0.7, 0), UDim2.new(0.3, 0, 0.3, 0), "▼")  
local btnLeft = createButton("Left", UDim2.new(0, 0, 0.35, 0), UDim2.new(0.3, 0, 0.3, 0), "◀")  
local btnRight = createButton("Right", UDim2.new(0.7, 0, 0.35, 0), UDim2.new(0.3, 0, 0.3, 0), "▶")

-- [ JUMP BUTTON ]  
local btnJump = createButton("Jump", UDim2.new(0.35, 0, 0.35, 0), UDim2.new(0.3, 0, 0.3, 0), "JUMP")  
btnJump.BackgroundColor3 = Color3.fromRGB(50, 50, 80)

-- [ W-LOCK BUTTON ]  
local btnWLock = createButton("WLock", UDim2.new(0.7, 0, 0, 0), UDim2.new(0.3, 0, 0.2, 0), "W: OFF")  
btnWLock.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- [ SIZE CONTROLS ]  
local btnSizePlus = createButton("SizePlus", UDim2.new(0, 0, 0, -40), UDim2.new(0.2, 0, 0.2, 0), "S +")  
local btnSizeMinus = createButton("SizeMinus", UDim2.new(0.1, 0, 0, -40), UDim2.new(0.2, 0, 0.2, 0), "S -")  
btnSizePlus.Position = UDim2.new(0, 0, 0, -40)  
btnSizeMinus.Position = UDim2.new(0.1, 0, 0, -40) -- Adjusted slightly

-- // LOGIC // --

local function setMove(dir, state)  
    moveState[dir] = state  
end

btnUp.MouseButton1Down:Connect(function() setMove("Forward", true) end)  
btnUp.MouseButton1Up:Connect(function() setMove("Forward", false) end)

btnDown.MouseButton1Down:Connect(function() setMove("Backward", true) end)  
btnDown.MouseButton1Up:Connect(function() setMove("Backward", false) end)

btnLeft.MouseButton1Down:Connect(function() setMove("Left", true) end)  
btnLeft.MouseButton1Up:Connect(function() setMove("Left", false) end)

btnRight.MouseButton1Down:Connect(function() setMove("Right", true) end)  
btnRight.MouseButton1Up:Connect(function() setMove("Right", false) end)

-- Jump Action  
btnJump.MouseButton1Click:Connect(function()  
    humanoid.Jump = true  
end)

-- W-Lock Toggle  
btnWLock.MouseButton1Click:Connect(function()  
    moveState.WLock = not moveState.WLock  
    btnWLock.Text = moveState.WLock and "W: ON" or "W: OFF"  
    btnWLock.BackgroundColor3 = moveState.WLock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)  
end)

-- UI Scaling System  
local function updateScale()  
    local baseSize = 200  
    mainFrame.Size = UDim2.new(0, baseSize * moveState.UIScale, 0, baseSize * moveState.UIScale)  
    -- Note: Since buttons use Scale (0.3, 0), they resize automatically with mainFrame  
end

btnSizePlus.MouseButton1Click:Connect(function()  
    moveState.UIScale = math.min(moveState.UIScale + 0.1, 2)  
    updateScale()  
end)

btnSizeMinus.MouseButton1Click:Connect(function()  
    moveState.UIScale = math.max(moveState.UIScale - 0.1, 0.5)  
    updateScale()  
end)

-- // MOVEMENT ENGINE // --  
RunService.RenderStepped:Connect(function()  
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end  
    local root = character.HumanoidRootPart  
    local camera = workspace.CurrentCamera  
    local moveVec = Vector3.new(0, 0, 0)

    if moveState.Forward or moveState.WLock then  
        moveVec = moveVec + (camera.CFrame.LookVector * Vector3.new(1, 0, 1))  
    end  
    if moveState.Backward then  
        moveVec = moveVec - (camera.CFrame.LookVector * Vector3.new(1, 0, 1))  
    end  
    if moveState.Left then  
        moveVec = moveVec - (camera.CFrame.RightVector * Vector3.new(1, 0, 1))  
    end  
    if moveState.Right then  
        moveVec = moveVec + (camera.CFrame.RightVector * Vector3.new(1, 0, 1))  
    end

    if moveVec.Magnitude > 0 then  
        moveVec = moveVec.Unit  
    end

    humanoid:Move(moveVec, false)  
end)

player.CharacterAdded:Connect(function(newChar)  
    character = newChar  
    humanoid = newChar:WaitForChild("Humanoid")  
end)  
