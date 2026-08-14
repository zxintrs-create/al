--[[  
    Standalone Catalog Prompt Script  
    Target: Mobile Executor (Delta)  
    Function: Trigger Official Roblox Purchase Prompt  
]]

local MarketplaceService = game:GetService("MarketplaceService")  
local Players = game:GetService("Players")  
local UserInputService = game:GetService("UserInputService")  
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- UI Setup  
local screenGui = Instance.new("ScreenGui")  
screenGui.Name = "Avz_CatalogPrompt"  
screenGui.ResetOnSpawn = false  
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")  
mainFrame.Size = UDim2.new(0, 250, 0, 180)  
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)  
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)  
mainFrame.BorderSizePixel = 0  
mainFrame.Active = true  
mainFrame.Draggable = true -- Fitur legacy, tapi masih jalan di banyak executor mobile  
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")  
uiCorner.CornerRadius = UDim.new(0, 8)  
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")  
title.Size = UDim2.new(1, 0, 0, 30)  
title.Text = "Catalog Prompt"  
title.TextColor3 = Color3.fromRGB(255, 255, 255)  
title.BackgroundTransparency = 1  
title.Font = Enum.Font.GothamBold  
title.TextSize = 16  
title.Parent = mainFrame

local assetInput = Instance.new("TextBox")  
assetInput.Size = UDim2.new(0, 200, 0, 40)  
assetInput.Position = UDim2.new(0.5, -100, 0, 40)  
assetInput.PlaceholderText = "Enter Asset ID..."  
assetInput.Text = ""  
assetInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
assetInput.TextColor3 = Color3.fromRGB(255, 255, 255)  
assetInput.Font = Enum.Font.Gotham  
assetInput.TextSize = 14  
assetInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")  
inputCorner.CornerRadius = UDim.new(0, 6)  
inputCorner.Parent = assetInput

local buyButton = Instance.new("TextButton")  
buyButton.Size = UDim2.new(0, 200, 0, 40)  
buyButton.Position = UDim2.new(0.5, -100, 0, 90)  
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
statusLabel.Position = UDim2.new(0, 0, 0, 135)  
statusLabel.Text = "Ready"  
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)  
statusLabel.BackgroundTransparency = 1  
statusLabel.Font = Enum.Font.Gotham  
statusLabel.TextSize = 12  
statusLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")  
closeButton.Size = UDim2.new(0, 20, 0, 20)  
closeButton.Position = UDim2.new(1, -25, 0, 5)  
closeButton.Text = "X"  
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)  
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)  
closeButton.Font = Enum.Font.GothamBold  
closeButton.TextSize = 12  
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")  
closeCorner.CornerRadius = UDim.new(1, 0)  
closeCorner.Parent = closeButton

-- Logic  
local isProcessing = false

local function updateStatus(txt, color)  
    statusLabel.Text = txt  
    statusLabel.TextColor3 = color  
end

local function promptPurchase()  
    if isProcessing then return end  
      
    local assetId = tonumber(assetInput.Text)  
    if not assetId then  
        updateStatus("Invalid Asset ID!", Color3.fromRGB(255, 80, 80))  
        return  
    end

    isProcessing = true  
    updateStatus("Processing...", Color3.fromRGB(255, 255, 0))

    local success, errorMessage = pcall(function()  
        -- Panggil prompt resmi Roblox  
        MarketplaceService:PromptPurchase(player, assetId)  
    end)

    if not success then  
        warn("Prompt Error: " .. tostring(errorMessage))  
        updateStatus("Error calling prompt", Color3.fromRGB(255, 80, 80))  
    else  
        updateStatus("Prompt sent. Check screen.", Color3.fromRGB(80, 255, 80))  
    end

    task.wait(2)  
    isProcessing = false  
end

-- Connections  
buyButton.Activated:Connect(promptPurchase)  
closeButton.Activated:Connect(function()  
    screenGui:Destroy()  
end)

-- Transaction Handling  
MarketplaceService.PromptPurchaseFinished:Connect(function(playerWhoPurchased, assetId, isPurchased)  
    if playerWhoPurchased == player then  
        if isPurchased then  
            updateStatus("Purchase Successful!", Color3.fromRGB(80, 255, 80))  
        else  
            updateStatus("Purchase Cancelled/Failed", Color3.fromRGB(255, 150, 150))  
        end  
    end  
end)

print("Avz Catalog Prompt Loaded Successfully")  
