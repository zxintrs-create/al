Local Library = {}  
local UserInputService = game:GetService("UserInputService")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local TweenService = game:GetService("TweenService")

-- Configuration  
local Config = {  
    AutoFish = false,  
    AutoFavorite = false,  
    CatchSpeed = 0.1, -- Lower is faster  
    ThemeColor = Color3.fromRGB(120, 0, 255) -- Luxury Purple  
}

-- UI Construction  
local CoreGui = Instance.new("ScreenGui")  
CoreGui.Name = "DeltaFishingHub"  
CoreGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")  
MainFrame.Name = "MainFrame"  
MainFrame.Size = UDim2.new(0, 220, 0, 280)  
MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)  
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  
MainFrame.BorderSizePixel = 0  
MainFrame.Parent = CoreGui

local UICorner = Instance.new("UICorner")  
UICorner.CornerRadius = UDim.new(0, 10)  
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")  
UIStroke.Thickness = 2  
UIStroke.Color = Config.ThemeColor  
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")  
Title.Text = "RAPID FISHING HUB"  
Title.Size = UDim2.new(1, 0, 0, 40)  
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  
Title.Font = Enum.Font.GothamBold  
Title.TextSize = 16  
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")  
TitleCorner.CornerRadius = UDim.new(0, 10)  
TitleCorner.Parent = Title

-- Function to create buttons  
local function CreateToggle(name, pos, default, callback)  
    local Button = Instance.new("TextButton")  
    Button.Name = name  
    Button.Text = name .. ": " .. (default and "ON" or "OFF")  
    Button.Size = UDim2.new(0.8, 0, 0, 40)  
    Button.Position = pos  
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)  
    Button.Font = Enum.Font.Gotham  
    Button.TextSize = 14  
    Button.Parent = MainFrame  
      
    local BCorner = Instance.new("UICorner")  
    BCorner.CornerRadius = UDim.new(0, 6)  
    BCorner.Parent = Button

    local state = default  
    Button.MouseButton1Click:Connect(function()  
        state = not state  
        Button.Text = name .. ": " .. (state and "ON" or "OFF")  
        Button.TextColor3 = state and Config.ThemeColor or Color3.fromRGB(200, 200, 200)  
        callback(state)  
    end)  
end

-- Logic implementation  
local function FindRemote(name)  
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do  
        if v:IsA("RemoteEvent") and v.Name:find(name) then  
            return v  
        end  
    end  
    return nil  
end

-- Fishing Loop  
task.spawn(function()  
    while task.wait(Config.CatchSpeed) do  
        if Config.AutoFish then  
            local FishRemote = FindRemote("Fish") or FindRemote("Catch") or FindRemote("Fishing")  
            if FishRemote then  
                -- Rapid firing the remote to bypass speed limits  
                FishRemote:FireServer()  
            end  
        end  
          
        if Config.AutoFavorite then  
            local FavRemote = FindRemote("Favorite") or FindRemote("Save")  
            if FavRemote then  
                -- Logic to target "Unknown" fish specifically  
                -- Usually requires a loop through current inventory  
                FavRemote:FireServer("Unknown")   
            end  
        end  
    end  
end)

-- Init UI  
CreateToggle("Auto Fish", UDim2.new(0.1, 0, 0, 60), false, function(v) Config.AutoFish = v end)  
CreateToggle("Auto Favorite", UDim2.new(0.1, 0, 0, 110), false, function(v) Config.AutoFavorite = v end)

-- Make Draggable  
local dragging, dragInput, dragStart, startPos  
MainFrame.InputBegan:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 then  
        dragging = true  
        dragStart = input.Position  
        startPos = MainFrame.Position  
    end  
end)

UserInputService.InputChanged:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then  
        local delta = input.Position - dragStart  
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
    end  
end)

UserInputService.InputEnded:Connect(function(input)  
    if input.UserInputType == Enum.UserInputType.MouseButton1 then  
        dragging = false  
    end  
end)

print("AL ART")
