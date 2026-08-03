local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local Config = {
    MaxSlots = 22,
    FilePrefix = "TP_Save_",
    Theme = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(0, 180, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 160),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 170, 0),
        Danger = Color3.fromRGB(255, 50, 50),
        Border = Color3.fromRGB(50, 50, 60)
    }
}

local SaveData = {
    Slots = {},
    LastPosition = nil,
    AutoLoadLast = false,
    CurrentFile = "Default"
}

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
            return true
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
                    local index = tonumber(i)
                    if index and SaveData.Slots[index] then
                        SaveData.Slots[index].Name = slot.Name
                        SaveData.Slots[index].Saved = slot.Saved
                        SaveData.Slots[index].DateString = slot.DateString
                        SaveData.Slots[index].PlaceId = slot.PlaceId
                        if slot.Position then
                            SaveData.Slots[index].Position = Vector3.new(slot.Position.X, slot.Position.Y, slot.Position.Z)
                        end
                        if slot.CFrameData then
                            SaveData.Slots[index].CFrame = CFrame.new(unpack(slot.CFrameData))
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
            return true
        end
    end
    return false
end

local function teleportTo(cf)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = cf
        return true
    end
    return false
end

local function saveSlot(slotIndex)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        SaveData.Slots[slotIndex] = {
            Name = SaveData.Slots[slotIndex].Name,
            Saved = true,
            DateString = os.date("%H:%M:%S - %d/%m/%Y"),
            Position = hrp.Position,
            CFrame = hrp.CFrame,
            PlaceId = game.PlaceId
        }
        saveToFile(SaveData.CurrentFile)
        return true
    end
    return false
end

local function loadSlot(slotIndex)
    local slot = SaveData.Slots[slotIndex]
    if slot and slot.Saved then
        if slot.PlaceId ~= 0 and slot.PlaceId ~= game.PlaceId then
            local TeleportService = game:GetService("TeleportService")
            pcall(function()
                TeleportService:TeleportToPose(slot.PlaceId, slot.CFrame, player)
            end)
        else
            teleportTo(slot.CFrame)
        end
        return true
    end
    return false
end

local function deleteSlot(slotIndex)
    if SaveData.Slots[slotIndex] then
        SaveData.Slots[slotIndex].Saved = false
        SaveData.Slots[slotIndex].DateString = "Kosong"
        SaveData.Slots[slotIndex].Position = Vector3.new(0, 0, 0)
        SaveData.Slots[slotIndex].CFrame = CFrame.new(0, 0, 0)
        SaveData.Slots[slotIndex].PlaceId = 0
        saveToFile(SaveData.CurrentFile)
        return true
    end
    return false
end

loadFromFile(SaveData.CurrentFile)
