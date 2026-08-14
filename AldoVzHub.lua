--[[  
Standalone Catalog Prompt Script - PRO VERSION  
Target: Mobile Executor (Delta)  
Author: Avz (Senior Luau Engineer)  
Function: Official Roblox Purchase Prompt with State Machine & Proper Lifecycle  
]]

local MarketplaceService = game:GetService("MarketplaceService")  
local Players = game:GetService("Players")  
local UserInputService = game:GetService("UserInputService")  
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Constants & State  
local GUI_NAME = "Avz_CatalogPrompt_V2"  
local STATE = {  
    IDLE = "IDLE",  
    CHECKING = "CHECKING",  
    PROMPT_OPEN = "PROMPT_OPEN",  
    FINISHED = "FINISHED",  
    ERROR = "ERROR"  
}

local currentState = STATE.IDLE  
local connections = {}

-- Cleanup existing GUI and connections  
local function cleanup()  
    for _, conn in pairs(connections) do  
        conn:Disconnect()  
    end  
    connections = {}  
    local existing = CoreGui:FindFirstChild(GUI_NAME)  
    if existing then existing:Destroy() end  
end

cleanup()

-- UI Implementation  
local screenGui = Instance.new("ScreenGui")  
screenGui.Name = GUI_NAME  
screenGui.ResetOnSpawn = false  
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")  
mainFrame.Size = UDim2.new(0, 260, 0, 190)  
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -95)  
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
mainFrame.BorderSizePixel = 0  
mainFrame.Active = true  
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")  
uiCorner.CornerRadius = UDim.new(0, 10)  
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")  
title.Size = UDim2.new(1, 0, 0, 35)  
title.Text = " avz | Catalog Prompt"  
title.TextColor3 = Color3.fromRGB(255, 255, 255)  
title.BackgroundTransparency = 1  
title.Font = Enum.Font.GothamBold  
title.TextSize = 14  
title.TextXAlignment = Enum.TextXAlignment.Left  
title.Position = UDim2.new(0, 10, 0, 0)  
title.Parent = mainFrame

local assetInput = Instance.new("TextBox")  
assetInput.Size = UDim2.new(0, 220, 0, 40)  
assetInput.Position = UDim2.new(0.5, -110, 0, 45)  
assetInput.PlaceholderText = "Enter Asset ID..."  
assetInput.Text = ""  
assetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)  
assetInput.TextColor3 = Color3.fromRGB(255, 255, 255)  
assetInput.Font = Enum.Font.Gotham  
assetInput.TextSize = 14  
assetInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")  
inputCorner.CornerRadius = UDim.new(0, 6)  
inputCorner.Parent = assetInput

local buyButton = Instance.new("TextButton")  
buyButton.Size = UDim2.new(0, 220, 0, 40)  
buyButton.Position = UDim2.new(0.5, -110, 0, 95)  
buyButton.Text = "BUY ITEM"  
buyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)  
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
buyButton.Font = Enum.Font.GothamBold  
buyButton.TextSize = 14  
buyButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")  
btnCorner.CornerRadius = UDim.new(0, 6)  
btnCorner.Parent = buyButton

local statusLabel = Instance.new("TextLabel")  
statusLabel.Size = UDim2.new(1, 0, 0, 30)  
statusLabel.Position = UDim2.new(0, 0, 0, 145)  
statusLabel.Text = "Status: IDLE"  
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)  
statusLabel.BackgroundTransparency = 1  
statusLabel.Font = Enum.Font.Gotham  
statusLabel.TextSize = 12  
statusLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")  
closeButton.Size = UDim2.new(0, 24, 0, 24)  
closeButton.Position = UDim2.new(1, -30, 0, 6)  
closeButton.Text = "X"  
closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)  
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
closeButton.Font = Enum.Font.GothamBold  
closeButton.TextSize = 12  
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")  
closeCorner.CornerRadius = UDim.new(1, 0)  
closeCorner.Parent = closeButton

-- Modern Drag System  
local dragging, dragInput, dragStart, startPos  
local function update(input)  
    local delta = input.Position - dragStart  
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
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
        update(input)  
    end  
end)

-- Logic Helpers  
local function setStatus(txt, color)  
    statusLabel.Text = "Status: " .. txt  
    statusLabel.TextColor3 = color  
end

local function validateId(text)  
    local id = tonumber(text)  
    if not id then return nil end  
    if id <= 0 or id % 1 ~= 0 then return nil end  
    return id  
end

local function promptPurchase()  
    if currentState ~= STATE.IDLE and currentState ~= STATE.FINISHED and currentState ~= STATE.ERROR then   
        return   
    end

    local assetId = validateId(assetInput.Text)  
    if not assetId then  
        setStatus("Invalid ID! Use positive integers.", Color3.fromRGB(255, 80, 80))  
        currentState = STATE.ERROR  
        return  
    end

    currentState = STATE.CHECKING  
    setStatus("Checking Asset...", Color3.fromRGB(255, 255, 0))  
    print("[AVZ] Asset ID: " .. assetId)

    -- Use pcall for API calls  
    local success, result = pcall(function()  
        return MarketplaceService:PromptPurchase(player, assetId)  
    end)

    if not success then  
        warn("[AVZ] Prompt Error: " .. tostring(result))  
        setStatus("API Error: " .. tostring(result), Color3.fromRGB(255, 80, 80))  
        currentState = STATE.ERROR  
    else  
        print("[AVZ] Opening Roblox purchase prompt")  
        setStatus("Prompt Opened", Color3.fromRGB(80, 200, 255))  
        currentState = STATE.PROMPT_OPEN  
        buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)  
    end  
end

-- Connections  
table.insert(connections, buyButton.Activated:Connect(promptPurchase))

table.insert(connections, closeButton.Activated:Connect(function()  
    cleanup()  
    screenGui:Destroy()  
end))

table.insert(connections, MarketplaceService.PromptPurchaseFinished:Connect(function(p, id, purchased)  
    if p == player then  
        print("[AVZ] Prompt finished. State: " .. tostring(purchased))  
        if purchased then  
            setStatus("Purchase Completed!", Color3.fromRGB(80, 255, 80))  
            print("[AVZ] Ownership: Pending Roblox verification")  
        else  
            setStatus("Transaction Cancelled/Failed", Color3.fromRGB(255, 150, 150))  
        end  
          
        -- Reset state to IDLE  
        currentState = STATE.IDLE  
        buyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)  
    end  
end))

print("[AVZ] Loaded Successfully. Senior Engineer Audit Applied.")  
