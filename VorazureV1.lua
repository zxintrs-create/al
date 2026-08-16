local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- CONFIG
local CONFIG = {
    MaxDistance = 45,
    AntiFlingPower = 1.5
}

-- STATE
local selectedPlayer = nil
local flingProtectionActive = false
local antiFlingConnection = nil
local currentAnimTrack = nil

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VZCombatSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(340, 200)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 32)
TitleLabel.Position = UDim2.fromOffset(10, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "VZ COMBAT | LOCAL"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.Parent = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -20, 0, 24)
TargetLabel.Position = UDim2.fromOffset(10, 45)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: NONE"
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 14
TargetLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
TargetLabel.Parent = MainFrame

-- Buttons
local function createButton(text, position, sizeX, sizeY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(sizeX, 0, 0, sizeY)
    btn.Position = position
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.AutoButtonColor = true
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    return btn
end

local SelectBtn = createButton(
    "SELECT",
    UDim2.new(0.03, 0, 0, 78),
    0.46,
    32
)

local AntiFlingBtn = createButton(
    "ANTI-FLING",
    UDim2.new(0.51, 0, 0, 78),
    0.46,
    32
)

local GrabBtn = createButton(
    "GRAB",
    UDim2.new(0.03, 0, 0, 118),
    0.46,
    32
)

local ChokeBtn = createButton(
    "CHOKE",
    UDim2.new(0.51, 0, 0, 118),
    0.46,
    32
)

local ClearBtn = createButton(
    "CLEAR",
    UDim2.new(0.03, 0, 0, 158),
    0.94,
    32
)

-- Selection Highlight
local selectedHighlight = nil

local function removeSelectionHighlight()
    if selectedHighlight then
        selectedHighlight:Destroy()
        selectedHighlight = nil
    end
end

local function addSelectionHighlight(player)
    removeSelectionHighlight()

    if not player or not player.Character then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "VZSelectedTarget"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0.1
    highlight.Parent = player.Character

    selectedHighlight = highlight
end

-- Get Player From Screen Position
local function getPlayerFromScreenPosition(screenPosition)
    local camera = workspace.CurrentCamera

    if not camera then
        return nil
    end

    local ray = camera:ViewportPointToRay(
        screenPosition.X,
        screenPosition.Y
    )

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {
            LocalPlayer.Character
        }
    end

    local result = workspace:Raycast(
        ray.Origin,
        ray.Direction * 500,
        params
    )

    if not result then
        return nil
    end

    local instance = result.Instance

    while instance and instance ~= workspace do
        local player = Players:GetPlayerFromCharacter(instance)

        if player and player ~= LocalPlayer then
            return player
        end

        instance = instance.Parent
    end

    return nil
end

-- Desktop Selection
local function getPlayerFromRay()
    local camera = workspace.CurrentCamera

    if not camera then
        return nil
    end

    local mouse = LocalPlayer:GetMouse()

    return getPlayerFromScreenPosition(
        Vector2.new(mouse.X, mouse.Y)
    )
end

-- Set Target
local function setTarget(player)
    removeSelectionHighlight()

    if not player then
        selectedPlayer = nil
        TargetLabel.Text = "Target: NONE"
        return
    end

    local myChar = LocalPlayer.Character
    local targetChar = player.Character

    if myChar and targetChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

        if myRoot and targetRoot then
            local dist = (
                targetRoot.Position
                - myRoot.Position
            ).Magnitude

            if dist <= CONFIG.MaxDistance then
                selectedPlayer = player

                TargetLabel.Text =
                    "Target: " .. player.DisplayName

                addSelectionHighlight(player)

                return
            end
        end
    end

    selectedPlayer = nil
    TargetLabel.Text = "Target: TOO FAR / INVALID"
end

-- Clear Target
local function clearTarget()
    selectedPlayer = nil
    TargetLabel.Text = "Target: NONE"
    removeSelectionHighlight()
end

-- Anti-Fling System
local function toggleAntiFling()
    flingProtectionActive = not flingProtectionActive

    if flingProtectionActive then
        AntiFlingBtn.Text = "ANTI-FLING [ON]"
        AntiFlingBtn.BackgroundColor3 =
            Color3.fromRGB(80, 180, 80)

        if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
        end

        antiFlingConnection = RunService.Heartbeat:Connect(
            function()
                local char = LocalPlayer.Character

                if not char then
                    return
                end

                local root =
                    char:FindFirstChild("HumanoidRootPart")

                if not root then
                    return
                end

                root.AssemblyLinearVelocity =
                    Vector3.new(0, 0, 0)

                root.AssemblyAngularVelocity =
                    Vector3.new(0, 0, 0)
            end
        )
    else
        AntiFlingBtn.Text = "ANTI-FLING"
        AntiFlingBtn.BackgroundColor3 =
            Color3.fromRGB(50, 50, 70)

        if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
        end
    end
end

-- Local Animation Functions
local function playLocalAnimation(animationId)
    if not animationId then
        return
    end

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local humanoid =
        char:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    local animator =
        humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    if currentAnimTrack then
        pcall(function()
            currentAnimTrack:Stop(0.1)
            currentAnimTrack:Destroy()
        end)

        currentAnimTrack = nil
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animationId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    animation:Destroy()

    if success and track then
        currentAnimTrack = track
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = false
        track:Play(0.1)
    end
end

-- Button Connections

SelectBtn.MouseButton1Click:Connect(function()
    local player = getPlayerFromRay()
    setTarget(player)
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    toggleAntiFling()
end)

GrabBtn.MouseButton1Click:Connect(function()
    playLocalAnimation(
        "rbxassetid://7691396275"
    )
end)

ChokeBtn.MouseButton1Click:Connect(function()
    playLocalAnimation(
        "rbxassetid://3752886447"
    )
end)

ClearBtn.MouseButton1Click:Connect(function()
    clearTarget()
end)

-- Mobile Touch Selection
UserInputService.TouchTap:Connect(
    function(touchPositions, processed)
        if processed then
            return
        end

        if not touchPositions then
            return
        end

        local position = touchPositions[1]

        if not position then
            return
        end

        -- Jangan memilih player ketika menyentuh
        -- tombol GUI.
        local guiObjects =
            LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(
                position.X,
                position.Y
            )

        for _, guiObject in ipairs(guiObjects) do
            if guiObject:IsDescendantOf(MainFrame) then
                return
            end
        end

        local player =
            getPlayerFromScreenPosition(position)

        setTarget(player)
    end
)

-- Hotkey System
UserInputService.InputBegan:Connect(
    function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.X then
            clearTarget()

        elseif input.KeyCode == Enum.KeyCode.G then
            playLocalAnimation(
                "rbxassetid://7691396275"
            )

        elseif input.KeyCode == Enum.KeyCode.C then
            playLocalAnimation(
                "rbxassetid://3752886447"
            )

        elseif input.KeyCode == Enum.KeyCode.F then
            toggleAntiFling()
        end
    end
)

-- UI Dragging
local dragging = false
local dragStart
local startPos

TitleLabel.InputBegan:Connect(
    function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(
                function()
                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        dragging = false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)
        if not dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local delta =
                input.Position - dragStart

            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
)

-- Cleanup
LocalPlayer.CharacterAdded:Connect(
    function()
        if currentAnimTrack then
            pcall(function()
                currentAnimTrack:Stop()
                currentAnimTrack:Destroy()
            end)

            currentAnimTrack = nil
        end

        clearTarget()
    end
)

Players.PlayerRemoving:Connect(
    function(player)
        if player == selectedPlayer then
            clearTarget()
        end
    end
)

print("ALDO VOXA ZORU")
