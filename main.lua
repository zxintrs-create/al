--[[   
    ALDO KNIGHTXOz HUB - ULTIMATE TELEPORT SYSTEM  
    Created by: Delta maker script  
    Features: 20 Permanent Slots, Auto-Rejoin Load, Modern Aesthetic GUI  
]]

local Players = game:GetService("Players")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local DataStoreService = game:GetService("DataStoreService")  
local TweenService = game:GetService("TweenService")  
local RunService = game:GetService("RunService")  
local StarterGui = game:GetService("StarterGui")

local Config = {  
    HubName = "ALDO KNIGHTXOz HUB",  
    MaxSlots = 20,  
    DataStoreKey = "AldoKnightXOz_TP_v2",  
    Theme = {  
        Main = Color3.fromRGB(15, 15, 20),  
        Secondary = Color3.fromRGB(25, 25, 35),  
        Accent = Color3.fromRGB(0, 200, 255),  
        Text = Color3.fromRGB(255, 255, 255),  
        Danger = Color3.fromRGB(255, 60, 60),  
        Success = Color3.fromRGB(60, 255, 120)  
    }  
}

-- Networking Setup  
local function setupNetwork()  
    local folder = ReplicatedStorage:FindFirstChild("KnightXOzNet") or Instance.new("Folder", ReplicatedStorage)  
    folder.Name = "KnightXOzNet"  
      
    local function getEvent(name, cls)  
        local ev = folder:FindFirstChild(name) or Instance.new(cls, folder)  
        ev.Name = name  
        return ev  
    end  
      
    return {  
        Save = getEvent("SavePos", "RemoteEvent"),  
        Load = getEvent("LoadPos", "RemoteEvent"),  
        Delete = getEvent("DeletePos", "RemoteEvent"),  
        Sync = getEvent("SyncData", "RemoteEvent")  
    }  
end

local Net = setupNetwork()

-- SERVER LOGIC  
if RunService:IsServer() then  
    local TPStore = DataStoreService:GetDataStore(Config.DataStoreKey)  
    local GlobalData = {}

    local function getPlayerData(player)  
        local success, data = pcall(function() return TPStore:GetAsync("User_" .. player.UserId) end)  
        if success and data then return data end  
          
        -- Default data for new users  
        local default = {}  
        for i = 1, Config.MaxSlots do  
            default[tostring(i)] = {Name = "Slot "..i, Saved = false, Pos = nil}  
        end  
        return default  
    end

    Net.Save.OnServerEvent:Connect(function(player, slot)  
        local data = getPlayerData(player)  
        local char = player.Character  
        if char and char:FindFirstChild("HumanoidRootPart") then  
            local cf = char.HumanoidRootPart.CFrame  
            data[tostring(slot)] = {  
                Name = "Slot "..slot,  
                Saved = true,  
                Pos = {cf:GetComponents()}  
            }  
            pcall(function() TPStore:SetAsync("User_" .. player.UserId, data) end)  
            Net.Sync:FireClient(player, data)  
        end  
    end)

    Net.Load.OnServerEvent:Connect(function(player, slot)  
        local data = getPlayerData(player)  
        local slotData = data[tostring(slot)]  
        if slotData and slotData.Saved then  
            local char = player.Character  
            if char and char:FindFirstChild("HumanoidRootPart") then  
                char.HumanoidRootPart.CFrame = CFrame.new(unpack(slotData.Pos))  
            end  
        end  
    end)

    Net.Delete.OnServerEvent:Connect(function(player, slot)  
        local data = getPlayerData(player)  
        data[tostring(slot)] = {Name = "Slot "..slot, Saved = false, Pos = nil}  
        pcall(function() TPStore:SetAsync("User_" .. player.UserId, data) end)  
        Net.Sync:FireClient(player, data)  
    end)

    Players.PlayerAdded:Connect(function(player)  
        task.wait(2)  
        Net.Sync:FireClient(player, getPlayerData(player))  
    end)  
end

-- CLIENT GUI LOGIC  
if RunService:IsClient() then  
    local player = Players.LocalPlayer  
      
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)  
    ScreenGui.Name = "KnightXOzGui"  
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)  
    MainFrame.Size = UDim2.new(0, 400, 0, 500)  
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)  
    MainFrame.BackgroundColor3 = Config.Theme.Main  
    MainFrame.BorderSizePixel = 0  
    MainFrame.ClipsDescendants = true  
      
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)  
    local Stroke = Instance.new("UIStroke", MainFrame)  
    Stroke.Color = Config.Theme.Accent  
    Stroke.Thickness = 2

    local TopBar = Instance.new("Frame", MainFrame)  
    TopBar.Size = UDim2.new(1, 0, 0, 50)  
    TopBar.BackgroundColor3 = Config.Theme.Secondary  
    TopBar.BorderSizePixel = 0  
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 15)

    local Title = Instance.new("TextLabel", TopBar)  
    Title.Size = UDim2.new(1, 0, 1, 0)  
    Title.Text = Config.HubName  
    Title.TextColor3 = Config.Theme.Text  
    Title.Font = Enum.Font.GothamBold  
    Title.TextSize = 18  
    Title.BackgroundTransparency = 1

    local Scroll = Instance.new("ScrollingFrame", MainFrame)  
    Scroll.Size = UDim2.new(1, -20, 1, -70)  
    Scroll.Position = UDim2.new(0, 10, 0, 60)  
    Scroll.BackgroundTransparency = 1  
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Config.MaxSlots * 45)  
    Scroll.ScrollBarThickness = 4  
      
    local Layout = Instance.new("UIListLayout", Scroll)  
    Layout.Padding = UDim.new(0, 5)

    local function createSlot(id)  
        local SlotFrame = Instance.new("Frame", Scroll)  
        SlotFrame.Size = UDim2.new(1, -10, 0, 40)  
        SlotFrame.BackgroundColor3 = Config.Theme.Secondary  
        Instance.new("UICorner", SlotFrame).CornerRadius = UDim.new(0, 8)

        local Label = Instance.new("TextLabel", SlotFrame)  
        Label.Size = UDim2.new(0, 100, 1, 0)  
        Label.Position = UDim2.new(0, 10, 0, 0)  
        Label.Text = "Slot "..id  
        Label.TextColor3 = Config.Theme.Text  
        Label.Font = Enum.Font.Gotham  
        Label.TextXAlignment = Enum.TextXAlignment.Left  
        Label.BackgroundTransparency = 1

        local SaveBtn = Instance.new("TextButton", SlotFrame)  
        SaveBtn.Size = UDim2.new(0, 60, 0, 30)  
        SaveBtn.Position = UDim2.new(1, -180, 0.5, -15)  
        SaveBtn.Text = "Save"  
        SaveBtn.BackgroundColor3 = Config.Theme.Accent  
        SaveBtn.Font = Enum.Font.GothamBold  
        SaveBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", SaveBtn)

        local LoadBtn = Instance.new("TextButton", SlotFrame)  
        LoadBtn.Size = UDim2.new(0, 60, 0, 30)  
        LoadBtn.Position = UDim2.new(1, -110, 0.5, -15)  
        LoadBtn.Text = "Load"  
        LoadBtn.BackgroundColor3 = Config.Theme.Success  
        LoadBtn.Font = Enum.Font.GothamBold  
        LoadBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", LoadBtn)

        local DelBtn = Instance.new("TextButton", SlotFrame)  
        DelBtn.Size = UDim2.new(0, 60, 0, 30)  
        DelBtn.Position = UDim2.new(1, -50, 0.5, -15)  
        DelBtn.Text = "Del"  
        DelBtn.BackgroundColor3 = Config.Theme.Danger  
        DelBtn.Font = Enum.Font.GothamBold  
        DelBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", DelBtn)

        SaveBtn.MouseButton1Click:Connect(function() Net.Save:FireServer(id) end)  
        LoadBtn.MouseButton1Click:Connect(function() Net.Load:FireServer(id) end)  
        DelBtn.MouseButton1Click:Connect(function() Net.Delete:FireServer(id) end)  
    end

    for i = 1, Config.MaxSlots do createSlot(i) end

    -- Draggable  
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
    game:GetService("UserInputService").InputChanged:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end  
    end)  
    game:GetService("UserInputService").InputEnded:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end  
    end)  
end  
