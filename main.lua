--[[
    ULTIMATE TELEPORT SYSTEM v2.0
    - 22 Slot Posisi
    - Save Permanen ke File
    - Load File Multiple
    - Delete Slot
    - Auto Execute OFF
    - Auto Rejoin OFF
    - Loop TP OFF
    - Rejoin Execute OFF
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- ========== KONFIGURASI ==========
local Config = {
    MaxSlots = 22,
    FilePrefix = "TP_Save_",
    Theme = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(0, 180, 255),
        Accent2 = Color3.fromRGB(100, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 160),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 170, 0),
        Danger = Color3.fromRGB(255, 50, 50),
        Border = Color3.fromRGB(50, 50, 60)
    }
}

-- ========== DATA STORAGE ==========
local SaveData = {
    Slots = {},
    LastPosition = nil,
    AutoLoadLast = false,
    CurrentFile = "Default"
}

-- Inisialisasi 22 slot
for i = 1, Config.MaxSlots do
    SaveData.Slots[i] = {
        Name = "TP " .. i,
        Saved = false,
        DateString = "Kosong",
        Position = Vector3.new(0, 0, 0),
        CFrame = CFrame.new(0, 0, 0),
        PlaceId = 0
    }
end

-- ========== FUNGSI FILE SYSTEM ==========
local function getFilePath(fileName)
    return Config.FilePrefix .. fileName .. ".json"
end

local function saveToFile(fileName)
    local dataToSave = {
        Slots = {},
        LastPosition = nil,
        AutoLoadLast = SaveData.AutoLoadLast
    }
    
    for i, slot in pairs(SaveData.Slots) do
        dataToSave.Slots[i] = {
            Name = slot.Name,
            Saved = slot.Saved,
            DateString = slot.DateString,
            Position = {X = slot.Position.X, Y = slot.Position.Y, Z = slot.Position.Z},
            CFrameData = {slot.CFrame:GetComponents()},
            PlaceId = slot.PlaceId
        }
    end
    
    if SaveData.LastPosition then
        dataToSave.LastPosition = {
            Position = {X = SaveData.LastPosition.Position.X, Y = SaveData.LastPosition.Position.Y, Z = SaveData.LastPosition.Position.Z},
            CFrameData = {SaveData.LastPosition.CFrame:GetComponents()}
        }
    end
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(dataToSave)
    end)
    
    if success then
        local writeSuccess = pcall(function()
            writefile(getFilePath(fileName), json)
        end)
        
        if writeSuccess then
            StarterGui:SetCore("SendNotification", {
                Title = "✅ File Saved",
                Text = "File '" .. fileName .. "' berhasil disimpan!",
                Duration = 2
            })
            return true
        else
            StarterGui:SetCore("SendNotification", {
                Title = "❌ Error",
                Text = "Gagal menulis file!",
                Duration = 2
            })
        end
    end
    return false
end

local function loadFromFile(fileName)
    local success, data = pcall(function()
        return readfile(getFilePath(fileName))
    end)
    
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        if decoded then
            if decoded.Slots then
                for i, slot in pairs(decoded.Slots) do
                    if SaveData.Slots[i] then
                        SaveData.Slots[i] = slot
                        if slot.Position then
                            SaveData.Slots[i].Position = Vector3.new(slot.Position.X, slot.Position.Y, slot.Position.Z)
                        end
                        if slot.CFrameData then
                            SaveData.Slots[i].CFrame = CFrame.new(unpack(slot.CFrameData))
                        end
                    end
                end
            end
            if decoded.LastPosition then
                SaveData.LastPosition = {
                    Position = Vector3.new(decoded.LastPosition.Position.X, decoded.LastPosition.Position.Y, decoded.LastPosition.Position.Z),
                    CFrame = CFrame.new(unpack(decoded.LastPosition.CFrameData))
                }
            end
            if decoded.AutoLoadLast ~= nil then
                SaveData.AutoLoadLast = decoded.AutoLoadLast
            end
            
            SaveData.CurrentFile = fileName
            refreshSlotsUI()
            
            StarterGui:SetCore("SendNotification", {
                Title = "✅ File Loaded",
                Text = "File '" .. fileName .. "' berhasil dimuat!",
                Duration = 2
            })
            return true
        end
    else
        StarterGui:SetCore("SendNotification", {
            Title = "❌ Error",
            Text = "File '" .. fileName .. "' tidak ditemukan!",
            Duration = 2
        })
    end
    return false
end

local function listFiles()
    local files = {}
    local success, result = pcall(function()
        return listfiles()
    end)
    
    if success then
        for _, file in pairs(result) do
            if string.find(file, Config.FilePrefix) then
                local fileName = string.gsub(file, ".*" .. Config.FilePrefix, "")
                fileName = string.gsub(fileName, "%.json", "")
                table.insert(files, fileName)
            end
        end
    end
    return files
end

-- ========== FUNGSI TELEPORT ==========
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function teleportTo(position, cframe)
    local character = getCharacter()
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid or humanoid.Health <= 0 then
        StarterGui:SetCore("SendNotification", {
            Title = "❌ Error",
            Text = "Karakter tidak valid!",
            Duration = 2
        })
        return false
    end
    
    local targetCF = cframe or CFrame.new(position)
    
    hrp.Anchored = true
    task.wait(0.05)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()
    
    hrp.Anchored = false
    
    SaveData.LastPosition = {
        Position = targetCF.Position,
        CFrame = targetCF
    }
    
    return true
end

-- ========== GUI CREATION ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateTeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Config.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Theme.Accent
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Config.Theme.Secondary
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 15)
TopCorner.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ ULTIMATE TELEPORT SYSTEM"
Title.TextColor3 = Config.Theme.Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Config.Theme.Danger
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Config.Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- File Management Frame
local FileFrame = Instance.new("Frame")
FileFrame.Size = UDim2.new(1, -40, 0, 60)
FileFrame.Position = UDim2.new(0, 20, 0, 60)
FileFrame.BackgroundColor3 = Config.Theme.Secondary
FileFrame.BorderSizePixel = 0
FileFrame.Parent = MainFrame
Instance.new("UICorner", FileFrame).CornerRadius = UDim.new(0, 10)

-- File Name Input
local FileNameInput = Instance.new("TextBox")
FileNameInput.Size = UDim2.new(0, 150, 0, 30)
FileNameInput.Position = UDim2.new(0, 10, 0, 15)
FileNameInput.BackgroundColor3 = Config.Theme.Background
FileNameInput.Text = "File1"
FileNameInput.TextColor3 = Config.Theme.Text
FileNameInput.PlaceholderText = "Nama File"
FileNameInput.Font = Enum.Font.Gotham
FileNameInput.TextSize = 13
FileNameInput.Parent = FileFrame
Instance.new("UICorner", FileNameInput).CornerRadius = UDim.new(0, 6)

-- Save File Button
local SaveFileBtn = Instance.new("TextButton")
SaveFileBtn.Size = UDim2.new(0, 80, 0, 30)
SaveFileBtn.Position = UDim2.new(0, 170, 0, 15)
SaveFileBtn.BackgroundColor3 = Config.Theme.Success
SaveFileBtn.Text = "💾 SAVE"
SaveFileBtn.TextColor3 = Config.Theme.Text
SaveFileBtn.Font = Enum.Font.GothamBold
SaveFileBtn.TextSize = 12
SaveFileBtn.Parent = FileFrame
Instance.new("UICorner", SaveFileBtn).CornerRadius = UDim.new(0, 
    
