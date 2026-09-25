local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ── Config ──────────────────────────────────────────────────────────
local TOGGLE_KEY = Enum.KeyCode.F
local CAST_KEY = Enum.KeyCode.E
local STOP_KEY = Enum.KeyCode.X

local LOOP_DELAY = 0.3 -- Jeda per siklus instant (detik)

-- ── State ───────────────────────────────────────────────────────────
local enabled = false
local fishing = false
local thread = nil

-- ── Helpers ─────────────────────────────────────────────────────────
local function findRemote(name, parent)
    local p = parent or ReplicatedStorage
    local r = p:FindFirstChild(name)
    if r then return r end
    for _, v in pairs(p:GetDescendants()) do
        if v.Name:lower() == name:lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

local function findRemoteInFolder(name)
    local folder = ReplicatedStorage:FindFirstChild("Remote") or ReplicatedStorage:FindFirstChild("Remotes")
    if folder then
        local r = folder:FindFirstChild(name)
        if r then return r end
    end
    return findRemote(name)
end

local function fireRemote(name, ...)
    local r = findRemoteInFolder(name)
    if r then
        if r:IsA("RemoteEvent") then
            r:FireServer(...)
        elseif r:IsA("RemoteFunction") then
            r:InvokeServer(...)
        end
    end
end

local function getBestRod()
    local best = nil
    local bestPower = -1
    local containers = {player:FindFirstChild("Backpack"), character}
    for _, container in pairs(containers) do
        if container then
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("rod") then
                    local power = tonumber(item:GetAttribute("Power") or item:GetAttribute("CastPower") or 0)
                    if power > bestPower then
                        bestPower = power
                        best = item
                    end
                end
            end
        end
    end
    return best
end

local function equipRod(rod)
    if not rod or not humanoid then return false end
    if rod.Parent ~= character then
        humanoid:EquipTool(rod)
    end
    task.wait(0.1)
    return true
end

local function hasRodEquipped()
    local tool = character:FindFirstChildWhichIsA("Tool")
    return tool ~= nil and tool.Name:lower():find("rod") ~= nil
end

local function castLine()
    fireRemote("AturRodRemote")
    fireRemote("CastLine")
    fireRemote("Cast")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function reelIn()
    fireRemote("EfekMancingEvent")
    fireRemote("ReelIn")
    fireRemote("Reel")
end

local function catchFish()
    fireRemote("FishCatchBroadcast")
    fireRemote("Catch")
    fireRemote("FishCatch")
end

local function sellFish()
    fireRemote("SellFish")
    fireRemote("Sell")
end

local function playCatchCutscene()
    fireRemote("CutsceneBroadcast")
    fireRemote("KitsuneCutscene")
end

local function kitsuneGigit()
    fireRemote("KitsuneGigitPink")
    fireRemote("KitsuneCore")
    fireRemote("KitsuneGigit")
end

local function useBestBait()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack or not humanoid then return end
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("bait") or item.Name:lower():find("worm") or item.Name:lower():find("lure")) then
            humanoid:EquipTool(item)
            task.wait(0.05)
            return
        end
    end
end

-- ── Main fishing loop ──────────────────────────────────────────────
local function fishingLoop()
    while fishing do
        local rod = getBestRod()
        if rod and not hasRodEquipped() then
            equipRod(rod)
        end

        useBestBait()
        castLine()
        reelIn()
        catchFish()
        kitsuneGigit()
        playCatchCutscene()
        sellFish()

        task.wait(LOOP_DELAY)
    end
end

-- ── Toggle ──────────────────────────────────────────────────────────
local function startFishing()
    if fishing then return end
    fishing = true
    thread = task.spawn(fishingLoop)
end

local function stopFishing()
    fishing = false
    if thread then
        task.cancel(thread)
        thread = nil
    end
end

local function toggleFishing()
    if fishing then
        stopFishing()
    else
        startFishing()
    end
end

-- ── Input ───────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY then
        toggleFishing()
    elseif input.KeyCode == STOP_KEY then
        stopFishing()
    elseif input.KeyCode == CAST_KEY and not fishing then
        castLine()
    end
end)

-- ── Cleanup on character respawn ────────────────────────────────────
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    fishing = false
    thread = nil
end)
