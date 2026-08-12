local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoVzArtPremiumUI"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = false
MainFrame.Active = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Parent = MainFrame
UIStrokeMain.Thickness = 2
UIStrokeMain.Color = Color3.fromRGB(180, 100, 255)

local UIGradientMain = Instance.new("UIGradient")
UIGradientMain.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 120, 255))
})
UIGradientMain.Parent = UIStrokeMain

task.spawn(function()
    while true do
        TweenService:Create(UIGradientMain, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = UIGradientMain.Rotation + 360}):Play()
        task.wait(3)
    end
end)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TopBar.BorderSizePixel = 0

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 12)
UICornerTop.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TopBarFix.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "👑AldoVz ART"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 110, 0, 40)
OpenButton.Position = UDim2.new(0, 20, 0, 20)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
OpenButton.Text = "OPEN MENU"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 14
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false

local UICornerOpen = Instance.new("UICorner")
UICornerOpen.CornerRadius = UDim.new(0, 8)
UICornerOpen.Parent = OpenButton

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TopBar
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400)
Sidebar.ScrollBarThickness = 4

local UICornerSide = Instance.new("UICorner")
UICornerSide.CornerRadius = UDim.new(0, 8)
UICornerSide.Parent = Sidebar

local UIListSide = Instance.new("UIListLayout")
UIListSide.Parent = Sidebar
UIListSide.SortOrder = Enum.SortOrder.LayoutOrder
UIListSide.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -155, 1, -50)
ContentArea.Position = UDim2.new(0, 145, 0, 45)
ContentArea.BackgroundTransparency = 1

local Pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Parent = ContentArea
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 800)
    page.ScrollBarThickness = 4
    
    local list = Instance.new("UIListLayout")
    list.Parent = page
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    
    Pages[name] = page
    return page
end

local function createTabButton(name, targetPage)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Visible = false
        end
        Pages[targetPage].Visible = true
    end)
end

createTabButton("AI Chat", "AI")
createTabButton("Spectate", "Spectate")
createTabButton("Staff Check", "Staff")
createTabButton("Player List", "Players")
createTabButton("Tools & Notes", "Tools")
createTabButton("Auto Jump", "AutoJump")

local pageAI = createPage("AI")
pageAI.Visible = true

local chatHistoryStore = {}

local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Parent = pageAI
chatScroll.Size = UDim2.new(1, 0, 0, 220)
chatScroll.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
chatScroll.BorderSizePixel = 0
chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScroll.ScrollBarThickness = 3

local chatList = Instance.new("UIListLayout")
chatList.Parent = chatScroll
chatList.SortOrder = Enum.SortOrder.LayoutOrder
chatList.Padding = UDim.new(0, 6)

local chatInput = Instance.new("TextBox")
chatInput.Parent = pageAI
chatInput.Size = UDim2.new(1, -75, 0, 30)
chatInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
chatInput.PlaceholderText = "Type message to Violet..."
chatInput.Text = ""
chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
chatInput.TextSize = 12
chatInput.Font = Enum.Font.Gotham

local chatSend = Instance.new("TextButton")
chatSend.Parent = pageAI
chatSend.Size = UDim2.new(0, 70, 0, 30)
chatSend.Position = UDim2.new(1, -70, 0, 225)
chatSend.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
chatSend.Text = "SEND"
chatSend.TextColor3 = Color3.fromRGB(255, 255, 255)
chatSend.TextSize = 12
chatSend.Font = Enum.Font.GothamBold

local function addChatBubble(sender, text, timestamp)
    local msgFrame = Instance.new("Frame")
    msgFrame.Parent = chatScroll
    msgFrame.Size = UDim2.new(1, 0, 0, 45)
    msgFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = msgFrame
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "[" .. timestamp .. "] " .. sender .. " : " .. text
    
    table.insert(chatHistoryStore, {sender = sender, text = text, time = timestamp})
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatList.AbsoluteContentSize.Y + 20)
end

chatSend.MouseButton1Click:Connect(function()
    local text = chatInput.Text
    if text ~= "" then
        local timeNow = os.date("%H:%M:%S")
        addChatBubble("BUMBLEBE CHAT ME [AldoVz]", text, timeNow)
        chatInput.Text = ""
        
        task.delay(0.01, function()
            local violetReplies = {
                "Hati-hati, Aldo. Aku selalu mengawasimu di sini.",
                "Jangan terlalu memaksakan diri, AldoVz. Fokuslah.",
                "Aku percaya kemampuanmu, mari selesaikan ini bersama.",
                "Tetap tenang dan atur langkahmu, Aldo."
            }
            local reply = violetReplies[math.random(1, #violetReplies)]
            addChatBubble("BUMBLEBE CHAT AI [Violet Evergarden]", reply, os.date("%H:%M:%S"))
        end)
    end
end)

addChatBubble("BUMBLEBE CHAT AI [Violet Evergarden]", "Halo AldoVz, aku Violet Evergarden. Siap mendampingimu.", os.date("%H:%M:%S"))

local pageSpectate = createPage("Spectate")
local spectateDropdown = Instance.new("ScrollingFrame")
spectateDropdown.Parent = pageSpectate
spectateDropdown.Size = UDim2.new(1, 0, 1, 0)
spectateDropdown.BackgroundTransparency = 1
spectateDropdown.CanvasSize = UDim2.new(0, 0, 0, 500)

local specList = Instance.new("UIListLayout")
specList.Parent = spectateDropdown
specList.SortOrder = Enum.SortOrder.LayoutOrder
specList.Padding = UDim.new(0, 5)

local function refreshSpectateList()
    for _, c in pairs(spectateDropdown:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = spectateDropdown
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            btn.Text = "Spectate: " .. plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
                end
            end)
        end
    end
end

local btnRefreshSpec = Instance.new("TextButton")
btnRefreshSpec.Parent = pageSpectate
btnRefreshSpec.Size = UDim2.new(1, 0, 0, 30)
btnRefreshSpec.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
btnRefreshSpec.Text = "Refresh Player List"
btnRefreshSpec.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRefreshSpec.TextSize = 12
btnRefreshSpec.Font = Enum.Font.GothamBold
btnRefreshSpec.MouseButton1Click:Connect(refreshSpectateList)

local pageStaff = createPage("Staff")
local staffLabel = Instance.new("TextLabel")
staffLabel.Parent = pageStaff
staffLabel.Size = UDim2.new(1, 0, 1, 0)
staffLabel.BackgroundTransparency = 1
staffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
staffLabel.TextSize = 12
staffLabel.Font = Enum.Font.Gotham
staffLabel.TextXAlignment = Enum.TextXAlignment.Left
staffLabel.TextYAlignment = Enum.TextYAlignment.Top

local function updateStaffList()
    local staffNames = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p:GetRankInGroup(1) > 0 or p.UserId == game.CreatorId then
            table.insert(staffNames, p.Name)
        end
    end
    staffLabel.Text = "Staff Joined Server:\n- " .. (#staffNames > 0 and table.concat(staffNames, "\n- ") or "None detected")
end
task.spawn(updateStaffList)

local pagePlayers = createPage("Players")
local playerListLabel = Instance.new("TextLabel")
playerListLabel.Parent = pagePlayers
playerListLabel.Size = UDim2.new(1, 0, 1, 0)
playerListLabel.BackgroundTransparency = 1
playerListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerListLabel.TextSize = 12
playerListLabel.Font = Enum.Font.Gotham
playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
playerListLabel.TextYAlignment = Enum.TextYAlignment.Top

RunService.RenderStepped:Connect(function()
    if pagePlayers.Visible then
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            table.insert(names, p.Name .. " (Ping: " .. tostring(p:GetNetworkPing() * 1000) .. "ms)")
        end
        playerListLabel.Text = "Total Players: " .. #names .. "\n\n" .. table.concat(names, "\n")
    end
end)

local pageTools = createPage("Tools")
local f3xBtn = Instance.new("TextButton")
f3xBtn.Parent = pageTools
f3xBtn.Size = UDim2.new(1, 0, 0, 35)
f3xBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 150)
f3xBtn.Text = "Load Tools F3X"
f3xBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
f3xBtn.TextSize = 12
f3xBtn.Font = Enum.Font.GothamBold

f3xBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:GetObjects("rbxassetid://669564429")[1].Source)()
    end)
end)

local noteBox = Instance.new("TextBox")
noteBox.Parent = pageTools
noteBox.Size = UDim2.new(1, 0, 0, 100)
noteBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
noteBox.PlaceholderText = "Write your notes here..."
noteBox.Text = ""
noteBox.TextColor3 = Color3.fromRGB(255, 255, 255)
noteBox.TextSize = 12
noteBox.Font = Enum.Font.Gotham
noteBox.ClearTextOnFocus = false

local saveNoteBtn = Instance.new("TextButton")
saveNoteBtn.Parent = pageTools
saveNoteBtn.Size = UDim2.new(1, 0, 0, 30)
saveNoteBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
saveNoteBtn.Text = "SAVE NOTE"
saveNoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveNoteBtn.TextSize = 12
saveNoteBtn.Font = Enum.Font.GothamBold

local savedNoteDisplay = Instance.new("TextLabel")
savedNoteDisplay.Parent = pageTools
savedNoteDisplay.Size = UDim2.new(1, 0, 0, 60)
savedNoteDisplay.BackgroundTransparency = 1
savedNoteDisplay.TextColor3 = Color3.fromRGB(200, 255, 200)
savedNoteDisplay.TextSize = 12
savedNoteDisplay.Font = Enum.Font.Gotham
savedNoteDisplay.TextXAlignment = Enum.TextXAlignment.Left
savedNoteDisplay.TextYAlignment = Enum.TextYAlignment.Top

saveNoteBtn.MouseButton1Click:Connect(function()
    savedNoteDisplay.Text = "Saved Notes:\n" .. noteBox.Text
end)

local pageAutoJump = createPage("AutoJump")
local autoJumpToggle = Instance.new("TextButton")
autoJumpToggle.Parent = pageAutoJump
autoJumpToggle.Size = UDim2.new(1, 0, 0, 40)
autoJumpToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
autoJumpToggle.Text = "AI Auto Jump Rute: OFF"
autoJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJumpToggle.TextSize = 12
autoJumpToggle.Font = Enum.Font.GothamBold

local autoJumpActive = false
autoJumpToggle.MouseButton1Click:Connect(function()
    autoJumpActive = not autoJumpActive
    if autoJumpActive then
        autoJumpToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        autoJumpToggle.Text = "AI Auto Jump Rute: ON"
    else
        autoJumpToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        autoJumpToggle.Text = "AI Auto Jump Rute: OFF"
    end
end)

RunService.RenderStepped:Connect(function()
    if autoJumpActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            local rayOrigin = hrp.Position
            local rayDirection = hrp.CFrame.LookVector * 5
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {char}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            if result then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

print("AldoVz")
