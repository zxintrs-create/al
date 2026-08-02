--[[
    ===================================================
    ALDO KNIGHTXOz HUB - ULTIMATE ADMIN & UTILITY HUB
    Features: Anti-Log Lag, Open/Close Button, Player TP,
              ESP, Fly, Spectator, Server Effects & Tools
    ===================================================
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- CONFIGURATION
local OWNER_ID = 6025622599
local SKY_ID = 11675661848
local MUSIC_ID = 134324160901088
local SWORD_ID = 47433

-- ANTI-OUTPUT / LOG STABILIZER (Mencegah Lag akibat Spam Log/Output)
local LogService = game:GetService("LogService")
if setconsoleoutput then pcall(setconsoleoutput, false) end

----------------------------------------------------
-- GUI CREATION
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KnightXOz_AdminHub"
ScreenGui.ResetOnSpawn = false

-- Protect GUI Parent
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 1. TOGGLE / OPEN BUTTON
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 100, 0, 35)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
OpenBtn.Text = "OPEN MENU"
OpenBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 12
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 200, 255)
OpenStroke.Thickness = 1.5

-- 2. MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ALDO KNIGHTXOz HUB - ADMIN & UTILITY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BackgroundTransparency = 1

-- Sidebar Container (Tab Buttons)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Container
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -160, 1, -55)
ContentFrame.Position = UDim2.new(0, 150, 0, 45)
ContentFrame.BackgroundTransparency = 1

----------------------------------------------------
-- TAB SYSTEM
----------------------------------------------------
local Tabs = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentFrame)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[name] = {Btn = TabBtn, Page = Page}
    return Page
end

-- Create Pages
local PlayerPage = CreateTab("Self & Player")
local WorldPage = CreateTab("Server & World")
local EffectPage = CreateTab("Effects & Fun")
local AdminPage = CreateTab("Admin Tools")

-- Select First Tab Default
Tabs["Self & Player"].Page.Visible = true
Tabs["Self & Player"].Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

----------------------------------------------------
-- HELPER COMPONENT (BUTTON MAKER)
----------------------------------------------------
local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return Btn
end

local function AddTextBox(parent, placeholder, callback)
    local Box = Instance.new("TextBox", parent)
    Box.Size = UDim2.new(1, -10, 0, 32)
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 11
    Box.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            pcall(function() callback(Box.Text) end)
        end
    end)
    return Box
end

----------------------------------------------------
-- FEATURE IMPLEMENTATIONS
----------------------------------------------------

-- 1. FLY FEATURE
local flying = false
local flySpeed = 50
local flyBV, flyBG

AddButton(PlayerPage, "TOGGLE FLY", function()
    flying = not flying
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if flying then
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.P = 9e4
        flyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.cframe = hrp.CFrame

        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.velocity = Vector3.new(0, 0.1, 0)
        flyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            while flying and char and char:FindFirstChild("HumanoidRootPart") do
                RunService.RenderStepped:Wait()
                local camCF = workspace.CurrentCamera.CFrame
                flyBG.cframe = camCF
                
                local vel = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + camCF.RightVector end
                
                flyBV.velocity = vel * flySpeed
            end
        end)
    else
        if flyBG then flyBG:Destroy() end
        if flyBV then flyBV:Destroy() end
    end
end)

-- 2. ESP FEATURE
local espEnabled = false
AddButton(PlayerPage, "TOGGLE ESP PLAYER", function()
    espEnabled = not espEnabled
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("KnightXOz_ESP")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "KnightXOz_ESP"
                    highlight.FillColor = Color3.fromRGB(0, 200, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = p.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- 3. SPECTATOR FEATURE
local spectating = false
AddTextBox(PlayerPage, "Spectate Target Name...", function(txt)
    for _, target in pairs(Players:GetPlayers()) do
        if string.find(string.lower(target.Name), string.lower(txt)) or string.find(string.lower(target.DisplayName), string.lower(txt)) then
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
                spectating = true
            end
            break
        end
    end
end)

AddButton(PlayerPage, "UNSPECTATE (RESET CAMERA)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        spectating = false
    end
end)

-- 4. TELEPORT TO PLAYER
AddTextBox(PlayerPage, "TP Target Player Name...", function(txt)
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and (string.find(string.lower(target.Name), string.lower(txt)) or string.find(string.lower(target.DisplayName), string.lower(txt))) then
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
            break
        end
    end
end)

-- 5. LIST PLAYERS NOTIFICATION
AddButton(PlayerPage, "SHOW ONLINE PLAYER LIST", function()
    local str = "Players Online:\n"
    for _, p in pairs(Players:GetPlayers()) do
        str = str .. "- " .. p.Name .. " (" .. p.DisplayName .. ")\n"
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "PLAYER LIST",
        Text = str,
        Duration = 5
    })
end)

----------------------------------------------------
-- WORLD & SERVER PAGE
----------------------------------------------------

-- 6. SKYBOX
AddButton(WorldPage, "APPLY SKYBOX (ID: 11675661848)", function()
    local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
    sky.SkyboxBk = "rbxassetid://" .. tostring(SKY_ID)
    sky.SkyboxDn = "rbxassetid://" .. tostring(SKY_ID)
    sky.SkyboxFt = "rbxassetid://" .. tostring(SKY_ID)
    sky.SkyboxLf = "rbxassetid://" .. tostring(SKY_ID)
    sky.SkyboxRt = "rbxassetid://" .. tostring(SKY_ID)
    sky.SkyboxUp = "rbxassetid://" .. tostring(SKY_ID)
end)

-- 7. PLAY SERVER MUSIC
local bgMusic = nil
AddButton(WorldPage, "PLAY MUSIC (ID: 134324160901088)", function()
    if bgMusic then bgMusic:Destroy() end
    bgMusic = Instance.new("Sound", SoundService)
    bgMusic.SoundId = "rbxassetid://" .. tostring(MUSIC_ID)
    bgMusic.Volume = 1
    bgMusic.Looped = true
    bgMusic:Play()
end)

AddButton(WorldPage, "STOP MUSIC", function()
    if bgMusic then bgMusic:Destroy() end
end)

----------------------------------------------------
-- EFFECTS & FUN PAGE
----------------------------------------------------

-- 8. AURA EFFECT
AddButton(EffectPage, "TOGGLE AURA EFFECT", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local aura = hrp:FindFirstChild("CultivationAura")
        if not aura then
            aura = Instance.new("ParticleEmitter", hrp)
            aura.Name = "CultivationAura"
            aura.Texture = "rbxassetid://242200234"
            aura.Size = NumberSequence.new(2, 4)
            aura.Rate = 20
            aura.Speed = NumberRange.new(1, 3)
        else
            aura:Destroy()
        end
    end
end)

-- 9. TRAIL EFFECT
AddButton(EffectPage, "TOGGLE CULTIVATION TRAIL", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local trail = hrp:FindFirstChild("CultivationTrail")
        if not trail then
            local a0 = Instance.new("Attachment", hrp)
            a0.Position = Vector3.new(0, 1, 0)
            local a1 = Instance.new("Attachment", hrp)
            a1.Position = Vector3.new(0, -1, 0)

            trail = Instance.new("Trail", hrp)
            trail.Name = "CultivationTrail"
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 255, 255))
            trail.Lifetime = 0.8
        else
            trail:Destroy()
            if hrp:FindFirstChild("Attachment") then hrp.Attachment:Destroy() end
        end
    end
end)

----------------------------------------------------
-- ADMIN TOOLS PAGE
----------------------------------------------------

-- 10. EXPLORER CHECK (DEX / STUDIO LITE INTEGRATION)
AddButton(AdminPage, "OPEN EXPLORER (OWNER CHECK)", function()
    if LocalPlayer.UserId == OWNER_ID or game.CreatorId == OWNER_ID then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "OWNER VERIFIED",
            Text = "Welcome Owner! Access Granted.",
            Duration = 3
        })
        -- Load Dex Explorer if supported by Executor
        if loadstring then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
            end)
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ACCESS DENIED",
            Text = "Hanya ID Owner (" .. tostring(OWNER_ID) .. ") yang dapat membuka Explorer.",
            Duration = 3
        })
    end
end)

-- 11. SWORD TOOL (GIVE TOOL ID)
AddButton(AdminPage, "EQUIP SWORD TOOL (ID: 47433)", function()
    if LocalPlayer and LocalPlayer:FindFirstChild("Backpack") then
        local tool = game:GetObjects("rbxassetid://" .. tostring(SWORD_ID))[1]
        if tool then
            tool.Parent = LocalPlayer.Backpack
        end
    end
end)

----------------------------------------------------
-- OPEN / CLOSE TOGGLE LOGIC
----------------------------------------------------
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- DRAGGABLE GUI LOGIC
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
