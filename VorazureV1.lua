local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    MaxDistance = 45,
    AntiFlingPower = 1.5,

    GrabAnimation = "rbxassetid://7691396275",
    ChokeAnimation = "rbxassetid://3752886447"
}

local selectedPlayer = nil
local selectedHighlight = nil

local flingProtectionActive = false
local antiFlingConnection = nil

local currentAnimTrack = nil

local dragging = false
local dragStart = nil
local dragStartPosition = nil

local function getPlayerGui()
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VZCombatSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getPlayerGui()

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(340, 210)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -20, 0, 32)
TitleLabel.Position = UDim2.fromOffset(10, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "VZ COMBAT | LOCAL"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Active = true
TitleLabel.Parent = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Name = "Target"
TargetLabel.Size = UDim2.new(1, -20, 0, 24)
TargetLabel.Position = UDim2.fromOffset(10, 44)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: NONE"
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 14
TargetLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
TargetLabel.TextXAlignment = Enum.TextXAlignment.Center
TargetLabel.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.fromOffset(10, 65)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: READY"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = MainFrame

local function createButton(name, text, position, width)
    local button = Instance.new("TextButton")

    button.Name = name
    button.Size = UDim2.new(width, 0, 0, 32)
    button.Position = position

    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.TextColor3 = Color3.fromRGB(240, 240, 240)

    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13

    button.AutoButtonColor = true
    button.Active = true

    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

local SelectBtn = createButton(
    "SelectButton",
    "SELECT",
    UDim2.new(0.03, 0, 0, 91),
    0.46
)

local AntiFlingBtn = createButton(
    "AntiFlingButton",
    "ANTI-FLING",
    UDim2.new(0.51, 0, 0, 91),
    0.46
)

local GrabBtn = createButton(
    "GrabButton",
    "GRAB",
    UDim2.new(0.03, 0, 0, 129),
    0.46
)

local ChokeBtn = createButton(
    "ChokeButton",
    "CHOKE",
    UDim2.new(0.51, 0, 0, 129),
    0.46
)

local ClearBtn = createButton(
    "ClearButton",
    "CLEAR",
    UDim2.new(0.03, 0, 0, 167),
    0.94
)

local function setStatus(text)
    StatusLabel.Text = "Status: " .. text
end

local function removeHighlight()
    if selectedHighlight then
        pcall(function()
            selectedHighlight:Destroy()
        end)

        selectedHighlight = nil
    end
end

local function addHighlight(player)
    removeHighlight()

    if not player then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "VZSelectedTarget"
    highlight.Adornee = character
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.1
    highlight.Parent = character

    selectedHighlight = highlight
end

local function clearTarget()
    selectedPlayer = nil

    removeHighlight()

    TargetLabel.Text = "Target: NONE"

    setStatus("READY")
end

local function findPlayerFromInstance(instance)
    local current = instance

    while current and current ~= workspace do
        if current:IsA("Model") then
            local player = Players:GetPlayerFromCharacter(current)

            if player and player ~= LocalPlayer then
                return player
            end
        end

        current = current.Parent
    end

    return nil
end

local function raycastPlayer(screenPosition)
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
        ray.Direction * 1000,
        params
    )

    if not result then
        return nil
    end

    return findPlayerFromInstance(result.Instance)
end

local function getDistanceToPlayer(player)
    if not player then
        return math.huge
    end

    local myCharacter = LocalPlayer.Character
    local targetCharacter = player.Character

    if not myCharacter or not targetCharacter then
        return math.huge
    end

    local myRoot =
        myCharacter:FindFirstChild("HumanoidRootPart")

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot or not targetRoot then
        return math.huge
    end

    return (
        targetRoot.Position -
        myRoot.Position
    ).Magnitude
end

local function selectPlayer(player)
    if not player then
        clearTarget()
        setStatus("NO PLAYER FOUND")
        return
    end

    if player == LocalPlayer then
        clearTarget()
        setStatus("CANNOT SELECT SELF")
        return
    end

    local distance = getDistanceToPlayer(player)

    if distance > CONFIG.MaxDistance then
        clearTarget()
        setStatus("TARGET TOO FAR")
        return
    end

    selectedPlayer = player

    TargetLabel.Text =
        "Target: " .. player.DisplayName

    addHighlight(player)

    setStatus(
        "SELECTED • "
        .. math.floor(distance)
        .. " STUDS"
    )
end

local function getMousePosition()
    local mouse = LocalPlayer:GetMouse()

    return Vector2.new(
        mouse.X,
        mouse.Y
    )
end

local function selectFromMouse()
    local position = getMousePosition()

    local player = raycastPlayer(position)

    selectPlayer(player)
end

local function stopLocalAnimation()
    if currentAnimTrack then
        pcall(function()
            currentAnimTrack:Stop(0.1)
            currentAnimTrack:Destroy()
        end)

        currentAnimTrack = nil
    end
end

local function playLocalAnimation(animationId)
    if not animationId or animationId == "" then
        setStatus("ANIMATION ID INVALID")
        return false
    end

    local character = LocalPlayer.Character

    if not character then
        setStatus("CHARACTER NOT READY")
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        setStatus("HUMANOID NOT FOUND")
        return false
    end

    local animator =
        humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopLocalAnimation()

    local animation = Instance.new("Animation")
    animation.AnimationId = animationId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    animation:Destroy()

    if not success then
        warn("[VZ] LoadAnimation failed:", track)

        setStatus("ANIMATION LOAD FAILED")

        return false
    end

    if not track then
        setStatus("ANIMATION TRACK INVALID")
        return false
    end

    currentAnimTrack = track

    track.Priority = Enum.AnimationPriority.Action
    track.Looped = false

    local playSuccess, playError =
        pcall(function()
            track:Play(0.1, 1, 1)
        end)

    if not playSuccess then
        warn("[VZ] Animation Play failed:", playError)

        setStatus("ANIMATION PLAY FAILED")

        pcall(function()
            track:Destroy()
        end)

        currentAnimTrack = nil

        return false
    end

    setStatus("ANIMATION PLAYING")

    return true
end

local function toggleAntiFling()
    flingProtectionActive =
        not flingProtectionActive

    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end

    if flingProtectionActive then

        AntiFlingBtn.Text = "ANTI-FLING [ON]"

        AntiFlingBtn.BackgroundColor3 =
            Color3.fromRGB(70, 150, 80)

        antiFlingConnection =
            RunService.Heartbeat:Connect(function()

                local character =
                    LocalPlayer.Character

                if not character then
                    return
                end

                local root =
                    character:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if not root then
                    return
                end

                if root.AssemblyLinearVelocity.Magnitude >
                    CONFIG.AntiFlingPower then

                    root.AssemblyLinearVelocity =
                        Vector3.zero
                end

                if root.AssemblyAngularVelocity.Magnitude >
                    CONFIG.AntiFlingPower then

                    root.AssemblyAngularVelocity =
                        Vector3.zero
                end
            end)

        setStatus("ANTI-FLING ON")

    else

        AntiFlingBtn.Text = "ANTI-FLING"

        AntiFlingBtn.BackgroundColor3 =
            Color3.fromRGB(50, 50, 70)

        setStatus("ANTI-FLING OFF")
    end
end

SelectBtn.Activated:Connect(function()
    selectFromMouse()
end)

AntiFlingBtn.Activated:Connect(function()
    toggleAntiFling()
end)

GrabBtn.Activated:Connect(function()
    if not selectedPlayer then
        setStatus("SELECT A PLAYER FIRST")
        return
    end

    if getDistanceToPlayer(selectedPlayer) >
        CONFIG.MaxDistance then

        clearTarget()
        setStatus("TARGET TOO FAR")
        return
    end

    playLocalAnimation(
        CONFIG.GrabAnimation
    )
end)

ChokeBtn.Activated:Connect(function()
    if not selectedPlayer then
        setStatus("SELECT A PLAYER FIRST")
        return
    end

    if getDistanceToPlayer(selectedPlayer) >
        CONFIG.MaxDistance then

        clearTarget()
        setStatus("TARGET TOO FAR")
        return
    end

    playLocalAnimation(
        CONFIG.ChokeAnimation
    )
end)

ClearBtn.Activated:Connect(function()
    clearTarget()
end)

UserInputService.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.X then

            clearTarget()

        elseif input.KeyCode == Enum.KeyCode.G then

            if selectedPlayer then
                playLocalAnimation(
                    CONFIG.GrabAnimation
                )
            end

        elseif input.KeyCode == Enum.KeyCode.C then

            if selectedPlayer then
                playLocalAnimation(
                    CONFIG.ChokeAnimation
                )
            end

        elseif input.KeyCode == Enum.KeyCode.F then

            toggleAntiFling()
        end
    end
)

UserInputService.TouchTap:Connect(
    function(touchPositions, processed)

        if processed then
            return
        end

        local position = touchPositions[1]

        if not position then
            return
        end

        local guiObjects =
            LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(
                position.X,
                position.Y
            )

        for _, object in ipairs(guiObjects) do

            if object:IsDescendantOf(MainFrame) then
                return
            end
        end

        local player =
            raycastPlayer(position)

        selectPlayer(player)
    end
)

TitleLabel.InputBegan:Connect(
    function(input)

        if input.UserInputType ~=
            Enum.UserInputType.MouseButton1
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end

        dragging = true

        dragStart = input.Position

        dragStartPosition =
            MainFrame.Position

        input.Changed:Connect(
            function()

                if input.UserInputState ==
                    Enum.UserInputState.End then

                    dragging = false
                end
            end
        )
    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return
        end

        local delta =
            input.Position - dragStart

        MainFrame.Position = UDim2.new(
            dragStartPosition.X.Scale,
            dragStartPosition.X.Offset + delta.X,

            dragStartPosition.Y.Scale,
            dragStartPosition.Y.Offset + delta.Y
        )
    end
)

LocalPlayer.CharacterAdded:Connect(
    function()

        stopLocalAnimation()

        if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
        end

        flingProtectionActive = false

        AntiFlingBtn.Text = "ANTI-FLING"

        AntiFlingBtn.BackgroundColor3 =
            Color3.fromRGB(50, 50, 70)

        clearTarget()

        task.wait(1)

        setStatus("READY")
    end
)

Players.PlayerRemoving:Connect(
    function(player)

        if player == selectedPlayer then
            clearTarget()
        end
    end
)

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(1)

        if selectedPlayer then

            if not selectedPlayer.Parent then
                clearTarget()
                continue
            end

            local distance =
                getDistanceToPlayer(
                    selectedPlayer
                )

            if distance > CONFIG.MaxDistance then

                TargetLabel.Text =
                    "Target: "
                    .. selectedPlayer.DisplayName
                    .. " [FAR]"

            end
        end
    end
end)

print("ALDO VOXA ZORU")
