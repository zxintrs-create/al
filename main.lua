--[[   
    ALDO KNIGHTXOz HUB - ULTIMATE TELEPORT SYSTEM  
    Created by: Delta maker script  
    Features: 20 Permanent Slots, Auto-Rejoin Load, Modern Aesthetic GUI, Stabilizer & Play TP
]]

local Players = game:GetService("Players")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local DataStoreService = game:GetService("DataStoreService")  
local TweenService = game:GetService("TweenService")  
local RunService = game:GetService("RunService")  
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

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
        Sync = getEvent("SyncData", "RemoteEvent"),
        PlayTP = getEvent("PlayTPPos", "RemoteEvent")
    }  
end

local Net = setupNetwork()

-- STABILIZER HELPER FUNCTION
local function SafeTeleport(character, cframeTarget)
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid and humanoid.Health > 0 then
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = cframeTarget
        end)
        return true
    end
    return false
end

-- SERVER LOGIC  
if RunService:IsServer() then  
    local TPStore = DataStoreService:GetDataStore(Config.DataStoreKey)  
    local ActivePlayTP = {}

    local function getPlayerData(player)  
        local success, data = pcall(function() return TPStore:GetAsync("User_" .. player.UserId) end)  
        if success and data then return data end  
          
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
        if slotData and slotData.Saved and slotData.Pos then  
            SafeTeleport(player.Character, CFrame.new(unpack(slotData.Pos)))
        end  
    end)

    Net.PlayTP.OnServerEvent:Connect(function(player, slot, enable)
        local userId = player.UserId
        if enable then
            ActivePlayTP[userId] = slot
            task.spawn(function()
                while ActivePlayTP[userId] == slot and player.Parent do
                    local data = getPlayerData(player)
                    local slotData = data[tostring(slot)]
                    if slotData and slotData.Saved and slotData.Pos then
                        SafeTeleport(player.Character, CFrame.new(unpack(slotData.Pos)))
                    end
                    task.wait(0.1)
                end
            end)
        else
            ActivePlayTP[userId] = nil
        end
    end)

    Net.Delete.OnServerEvent:Connect(function(player, slot)  
        local data = getPlayerData(player)  
        data[tostring(slot)] = {Name = "Slot "..slot, Saved = false, Pos = nil}  
        pcall(function() TPStore:SetAsync("User_" .. player.UserId, data) end)  
        Net.Sync:FireClient(player, data)  
    end)

    -- Kirimkan data tersimpan saat pemain baru bergabung/rejoin
    Players.PlayerAdded:Connect(function(player)  
        task.wait(2)  
        Net.Sync:FireClient(player, getPlayerData(player))  
    end)  

    Players.PlayerRemoving:Connect(function(player)
        ActivePlayTP[player.UserId] = nil
    end)
end

-- CLIENT GUI LOGIC  
if RunService:IsClient() then  
    local player = Players.LocalPlayer  
    local activePlaySlots = {}
    local slotFrames = {} -- Menyimpan reference UI slot untuk auto-update
      
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)  
    ScreenGui.Name = "KnightXOzGui"  
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)  
    MainFrame.Size = UDim2.new(0, 480, 0, 500)  
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -250)  
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
        Label.Size = UDim2.new(0, 80, 1, 0)  
        Label.Position = UDim2.new(0, 10, 0, 0)  
        Label.Text = "Slot "..id  
        Label.TextColor3 = Config.Theme.Text  
        Label.Font = Enum.Font.Gotham  
        Label.TextXAlignment = Enum.TextXAlignment.Left  
        Label.BackgroundTransparency = 1

        local SaveBtn = Instance.new("TextButton", SlotFrame)  
        SaveBtn.Size = UDim2.new(0, 55, 0, 30)  
        SaveBtn.Position = UDim2.new(1, -235, 0.5, -15)  
        SaveBtn.Text = "Save"  
        SaveBtn.BackgroundColor3 = Config.Theme.Accent  
        SaveBtn.Font = Enum.Font.GothamBold  
        SaveBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", SaveBtn)

        local LoadBtn = Instance.new("TextButton", SlotFrame)  
        LoadBtn.Size = UDim2.new(0, 55, 0, 30)  
        LoadBtn.Position = UDim2.new(1, -175, 0.5, -15)  
        LoadBtn.Text = "Load"  
        LoadBtn.BackgroundColor3 = Config.Theme.Success  
        LoadBtn.Font = Enum.Font.GothamBold  
        LoadBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", LoadBtn)

        local PlayBtn = Instance.new("TextButton", SlotFrame)  
        PlayBtn.Size = UDim2.new(0, 55, 0, 30)  
        PlayBtn.Position = UDim2.new(1, -115, 0.5, -15)  
        PlayBtn.Text = "Play"  
        PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)  
        PlayBtn.Font = Enum.Font.GothamBold  
        PlayBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", PlayBtn)

        local DelBtn = Instance.new("TextButton", SlotFrame)  
        DelBtn.Size = UDim2.new(0, 50, 0, 30)  
        DelBtn.Position = UDim2.new(1, -55, 0.5, -15)  
        DelBtn.Text = "Del"  
        DelBtn.BackgroundColor3 = Config.Theme.Danger  
        DelBtn.Font = Enum.Font.GothamBold  
        DelBtn.TextColor3 = Config.Theme.Text  
        Instance.new("UICorner", DelBtn)

        SaveBtn.MouseButton1Click:Connect(function() Net.Save:FireServer(id) end)  
        LoadBtn.MouseButton1Click:Connect(function() Net.Load:FireServer(id) end)  
        DelBtn.MouseButton1Click:Connect(function() 
            activePlaySlots[id] = false
            PlayBtn.Text = "Play"
            PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
            Net.PlayTP:FireServer(id, false)
            Net.Delete:FireServer(id) 
        end)  

        PlayBtn.MouseButton1Click:Connect(function()
            activePlaySlots[id] = not activePlaySlots[id]
            if activePlaySlots[id] then
                PlayBtn.Text = "Stop"
                PlayBtn.BackgroundColor3 = Config.Theme.Danger
                Net.PlayTP:FireServer(id, true)
            else
                PlayBtn.Text = "Play"
                PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
                Net.PlayTP:FireServer(id, false)
            end
        end)

        slotFrames[tostring(id)] = {
            Label = Label,
            LoadBtn = LoadBtn,
            PlayBtn = PlayBtn
        }
    end

    for i = 1, Config.MaxSlots do createSlot(i) end

    -- Menerima dan menyinkronkan data tersimpan saat rejoin
    Net.Sync.OnClientEvent:Connect(function(data)
        if type(data) == "table" then
            for slotId, slotInfo in pairs(data) do
                local uiElements = slotFrames[tostring(slotId)]
                if uiElements then
                    if slotInfo.Saved then
                        uiElements.Label.Text = "Slot " .. slotId .. " [Saved]"
                        uiElements.Label.TextColor3 = Config.Theme.Success
                    else
                        uiElements.Label.Text = "Slot " .. slotId
                        uiElements.Label.TextColor3 = Config.Theme.Text
                    end
                end
            end
        end
    end)

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
    UserInputService.InputChanged:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end  
    end)  
    UserInputService.InputEnded:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end  
    end)  
end
