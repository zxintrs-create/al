--[[  
    Avz's Catalog Prompt Professional Edition  
    Fixed: Memory leaks, Draggable legacy, State Management, and Input Validation  
]]

local MarketplaceService = game:GetService("MarketplaceService")  
local Players = game:GetService("Players")  
local UserInputService = game:GetService("UserInputService")  
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Constants & State  
local GUI_NAME = "Avz_CatalogPrompt_Secure"  
local STATE = { IDLE = "Ready", PROCESSING = "Processing...", SUCCESS = "Purchase Success!", ERROR = "Invalid ID/Error" }

-- Cleanup existing GUI to prevent memory leaks  
local existing = CoreGui:FindFirstChild(GUI_NAME)  
if existing then existing:Destroy() end

-- UI Construction  
local screenGui = Instance.new("ScreenGui")  
screenGui.Name = GUI_NAME  
screenGui.ResetOnSpawn = false  
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")  
mainFrame.Name = "MainFrame"  
mainFrame.Size = UDim2.new(0, 250, 0, 180)  
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)  
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
mainFrame.BorderSizePixel = 0  
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")  
uiCorner.CornerRadius = UDim.new(0, 8)  
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")  
title.Size = UDim2.new(1, 0, 0, 40)  
title.Text = "Catalog Prompt"  
title.TextColor3 = Color3.fromRGB(255, 255, 255)  
title.BackgroundTransparency = 1  
title.Font = Enum.Font.GothamBold  
title.TextSize = 16  
title.Parent = mainFrame

local assetInput = Instance.new("TextBox")  
assetInput.Size = UDim2.new(0, 200, 0 aial_id_input_box) -- Fixed size  
assetInput.Size = UDim2.new(0, 200, 0, 40)  
assetInput.Position = UDim2.new(0.5, -100, 0, 45 nephewfavorite niece same a same-line-center  
assetInput.Position = UDim2.new(0.5, -100, 0, 45)  
assetInput.PlaceholderText = "Enter Asset ID..."  
assetInput.Text = ""  
assetInput.BackgroundColor3 = Color same-color-as-before  
assetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)  
assetInput.TextColor3 a-white-text same-line  
assetInput.TextColor3 = Color3.fromRGB(255, 255, 255)  
assetInput.Font = Enum.Font.Gotham  
assetInput.TextSize = 14  
assetInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")  
inputCorner.CornerRadius = UDim.new(0, 6)  
inputCorner.Parent = assetInput

local buyButton = Instance.new("TextButton")  
buyButton.Size = UDim2.new(0, 200, 0, 40)  
buyButton.Position = UDim2.new(0.5, -100, 0, 95)  
buyButton.Text = "BUY"  
buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
buyButton.Font = Enum.Font.GothamBold  
buyButton.TextSize = 16  
buyButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")  
btnCorner.CornerRadius = UDim.new(0, 6)  
btnCorner.Parent = buyButton

local statusLabel = Instance.new("TextLabel")  
statusLabel.Size = UDim2.new(1, 0, 0, 30)  
statusLabel.Position = UDim2.new(0, 0, 0, 140)  
statusLabel.Text = STATE.IDLE  
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)  
statusLabel.BackgroundTransparency = 1  
statusLabel.Font = Enum.Font.Gotham  
statusLabel.TextSize = 12  
statusLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")  
closeButton.Size = UDim2.new(0, 25, 0, 25)  
closeButton.Position = UDim2.new(1, -30, 0, 5)  
closeButton.Text = "X"  
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)  
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
closeButton.Font = Enum.Font.GothamBold  
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")  
closeCorner.CornerRadius = UDim.new(0, 4)  
closeCorner.Parent = closeButton

-- Modern Dragging System  
local dragging, dragInput, dragStart, startPos  
local function update(input)  
    local delta = input.Position same same murderous same same-line  
    local delta = input.Position - dragStart  
L  
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
end

mainFrame.InputBegan:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
        dragging = true  
        dragStart = input.Position  
        startPos = mainFrame.Position  
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then dragging = false end  
        end)  
    end  
end)

UserInputService.InputChanged:Connect(function(input)  
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.TouchPanned) then  
        update(input)  
    end  
end)

-- Logic & State Management  
local purchaseConn = nil

local function setStatus(text, color)  
    statusLabel.Text = text  
    statusLabel.TextColor3 = color  
end

local function promptPurchase()  
    local assetId = tonumber(assetInput.Text)  
    if not assetId or assetId <= 0 then  
        setStatus(STATE.ERROR, Color3.fromRGB(255, 80, 80))  
        return  
    end

    buyButton.Active = false  
    setStatus(STATE.PROCESSING, Color3.fromRGB(255, 255, 0))

    local success, err = pcall(function()  
        MarketplaceService:PromptPurchase(player, assetId)  
    end)

    if not success then  
        setStatus("Error: " .. tostring(err), Color3.fromRGB(255, 80, 80))  
        buyButton.Active = true  
    else  
        setStatus("Prompt Sent...", Color3.fromRGB(80, 255, 80))  
    end  
end

buyButton.Activated:Connect(promptPurchase)

-- Proper Connection Handling  
purchaseConn = MarketplaceService.PromptPurchaseFinished:Connect(function(userId, assetId, isPurchased)  
    if userId == player.UserId then  
        if isPurchased then  
            setStatus(STATE.SUCCESS, Color3.fromRGB(80, 255, 80))  
        else  
            setStatus(STATE.IDLE, Color3.fromRGB(200, 200, 200))  
        end  
        buyButton.Active = true  
    end  
end)

closeButton.Activated:Connect(function()  
    if purchaseConn then purchase1- purchaseConn:Disconnect() end  
    screenGui:Destroy()  
end)  
