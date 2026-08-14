-- ByVinzzHub - Auto Walk + Auto Detect Mount Script
-- Paste file ini sebagai ByVinzzHub.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP(char)
    return char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
end

local mountainNames = {
    "Mt Lembayana",
    "Mount Atin",
    "Mount Daun",
    "Mount Sibuatan",
    "Mount Bromo"
}

local mountainLocations = {}

local function getPositionFromObject(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        else
            local ok, min, max = pcall(function() return obj:GetBoundingBox() end)
            if ok and min then return min.Position end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function detectMountains()
    mountainLocations = {}
    for _, name in ipairs(mountainNames) do
        local found = Workspace:FindFirstChild(name, true)
        local pos = getPositionFromObject(found)
        if pos then
            mountainLocations[name] = pos
            warn("[ByVinzzHub] Ditemukan:", name, "->", pos)
        else
            warn("[ByVinzzHub] Tidak menemukan posisi untuk:", name)
        end
    end
end

local function autoWalkTo(destination, speed)
    speed = speed or 50
    local char = getChar()
    local hrp = getHRP(char)
    if not hrp then
        warn("[ByVinzzHub] HumanoidRootPart tidak ditemukan.")
        return
    end
    local distance = (hrp.Position - destination).Magnitude
    if distance < 2 then return end
    local time = math.max(0.1, distance / speed)
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(destination)})
    tween:Play()
    local done = false
    tween.Completed:Connect(function() done = true end)
    -- wait until complete or character respawn
    while not done do
        if not player.Character or not player.Character.Parent then
            tween:Cancel()
            return
        end
        task.wait(0.1)
    end
end

-- public function untuk dipanggil dari executor / command
getgenv().ByVinzzHub_Go = function(mountainName)
    if not mountainLocations or next(mountainLocations) == nil then
        warn("[ByVinzzHub] Lokasi belum terdeteksi, mencoba detect ulang...")
        detectMountains()
    end
    local pos = mountainLocations and mountainLocations[mountainName]
    if pos then
        print("[ByVinzzHub] Menuju:", mountainName)
        autoWalkTo(pos)
        print("[ByVinzzHub] Sampai di:", mountainName)
    else
        warn("[ByVinzzHub] Tidak ada data untuk:", tostring(mountainName))
    end
end

-- detect awal dan juga saat workspace berubah (opsional)
detectMountains()
Workspace.ChildAdded:Connect(function()
    -- small delay agar objek siap
    task.wait(0.5)
    detectMountains()
end)
