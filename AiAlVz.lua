-- Pengatas Hitbox — bawa semua Hitbox dari Stages ke pemain dan ikut terus

local LayananJalankan = game:GetService("RunService")
local LayananPemain = game:GetService("Players")

local PemainLokal = LayananPemain.LocalPlayer
local GuiPemain = PemainLokal:WaitForChild("PlayerGui")

local SedangAktif = false
local DaftarHitbox = {}
local BagianTubuh = nil
local HubunganKejadian = {}

-- Warna tema
local WarnaCian = Color3.fromRGB(0, 255, 255)
local WarnaUngu = Color3.fromRGB(170, 0, 255)
local WarnaPutih = Color3.fromRGB(255, 255, 255)
local WarnaHitam = Color3.fromRGB(0, 0, 0)

-- Antarmuka layar
local GuiLayar = Instance.new("ScreenGui")
GuiLayar.Name = "PengatashitboxGui"
GuiLayar.ResetOnSpawn = false
GuiLayar.Parent = GuiPemain

-- Tombol buka menu
local TombolBuka = Instance.new("TextButton")
TombolBuka.Name = "TombolBuka"
TombolBuka.Size = UDim2.new(0, 120, 0, 40)
TombolBuka.Position = UDim2.new(0, 15, 0.5, -20)
TombolBuka.BackgroundColor3 = WarnaPutih
TombolBuka.TextColor3 = WarnaHitam
TombolBuka.Text = "BUKA MENU"
TombolBuka.Font = Enum.Font.GothamBold
TombolBuka.TextSize = 14
TombolBuka.AutoButtonColor = false
TombolBuka.Parent = GuiLayar

local SudutBuka = Instance.new("UICorner")
SudutBuka.CornerRadius = UDim.new(0.8, 0)
SudutBuka.Parent = TombolBuka

local GarisBuka = Instance.new("UIStroke")
GarisBuka.Thickness = 2
GarisBuka.Color = WarnaPutih
GarisBuka.Parent = TombolBuka

local GradienBuka = Instance.new("UIGradient")
GradienBuka.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, WarnaCian),
    ColorSequenceKeypoint.new(1, WarnaUngu)
})
GradienBuka.Rotation = 0
GradienBuka.Parent = TombolBuka

-- Bingkai utama
local BingkaiUtama = Instance.new("Frame")
BingkaiUtama.Name = "BingkaiUtama"
BingkaiUtama.Size = UDim2.new(0, 285, 0, 175)
BingkaiUtama.Position = UDim2.new(0.5, -142, 0.5, -87)
BingkaiUtama.BackgroundColor3 = WarnaPutih
BingkaiUtama.Visible = false
BingkaiUtama.Active = true
BingkaiUtama.Draggable = true
BingkaiUtama.Parent = GuiLayar

local SudutBingkai = Instance.new("UICorner")
SudutBingkai.CornerRadius = UDim.new(0.8, 0)
SudutBingkai.Parent = BingkaiUtama

local GradienBingkai = Instance.new("UIGradient")
GradienBingkai.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, WarnaCian),
    ColorSequenceKeypoint.new(1, WarnaUngu)
})
GradienBingkai.Rotation = 45
GradienBingkai.Parent = BingkaiUtama

local GarisBingkai = Instance.new("UIStroke")
GarisBingkai.Thickness = 2.5
GarisBingkai.Color = WarnaPutih
GarisBingkai.Parent = BingkaiUtama

local GradienGaris = Instance.new("UIGradient")
GradienGaris.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, WarnaCian),
    ColorSequenceKeypoint.new(0.5, WarnaPutih),
    ColorSequenceKeypoint.new(1, WarnaUngu)
})
GradienGaris.Parent = GarisBingkai

-- Teks judul
local LabelJudul = Instance.new("TextLabel")
LabelJudul.Name = "Judul"
LabelJudul.Size = UDim2.new(1, -60, 0, 40)
LabelJudul.Position = UDim2.new(0, 15, 0, 3)
LabelJudul.BackgroundTransparency = 1
LabelJudul.Text = "PENGATAS HITBOX"
LabelJudul.TextColor3 = WarnaHitam
LabelJudul.Font = Enum.Font.GothamBold
LabelJudul.TextSize = 17
LabelJudul.TextXAlignment = Enum.TextXAlignment.Left
LabelJudul.Parent = BingkaiUtama

-- Tombol tutup
local TombolTutup = Instance.new("TextButton")
TombolTutup.Name = "TombolTutup"
TombolTutup.Size = UDim2.new(0, 32, 0, 32)
TombolTutup.Position = UDim2.new(1, -42, 0, 7)
TombolTutup.BackgroundColor3 = WarnaPutih
TombolTutup.TextColor3 = WarnaHitam
TombolTutup.Text = "X"
TombolTutup.Font = Enum.Font.GothamBold
TombolTutup.TextSize = 15
TombolTutup.AutoButtonColor = false
TombolTutup.Parent = BingkaiUtama

local SudutTutup = Instance.new("UICorner")
SudutTutup.CornerRadius = UDim.new(0.8, 0)
SudutTutup.Parent = TombolTutup

local GarisTutup = Instance.new("UIStroke")
GarisTutup.Thickness = 2
GarisTutup.Color = WarnaPutih
GarisTutup.Parent = TombolTutup

local GradienTutup = Instance.new("UIGradient")
GradienTutup.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, WarnaCian),
    ColorSequenceKeypoint.new(1, WarnaUngu)
})
GradienTutup.Rotation = 0
GradienTutup.Parent = TombolTutup

-- Tombol hidup/mati hitbox
local TombolHidup = Instance.new("TextButton")
TombolHidup.Name = "TombolHidup"
TombolHidup.Size = UDim2.new(0.86, 0, 0, 52)
TombolHidup.Position = UDim2.new(0.07, 0, 0, 78)
TombolHidup.BackgroundColor3 = WarnaPutih
TombolHidup.TextColor3 = WarnaHitam
TombolHidup.Text = "Aktifkan Hitbox: MATI"
TombolHidup.Font = Enum.Font.GothamBold
TombolHidup.TextSize = 16
TombolHidup.AutoButtonColor = false
TombolHidup.Parent = BingkaiUtama

local SudutHidup = Instance.new("UICorner")
SudutHidup.CornerRadius = UDim.new(0.8, 0)
SudutHidup.Parent = TombolHidup

local GarisHidup = Instance.new("UIStroke")
GarisHidup.Thickness = 2
GarisHidup.Color = WarnaPutih
GarisHidup.Parent = TombolHidup

local GradienHidup = Instance.new("UIGradient")
GradienHidup.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, WarnaCian),
    ColorSequenceKeypoint.new(1, WarnaUngu)
})
GradienHidup.Rotation = 0
GradienHidup.Parent = TombolHidup

-- Kumpulkan semua hitbox di Stages
local function KumpulkanHitbox()
    DaftarHitbox = {}

    local FolderTahap = workspace:FindFirstChild("Stages")
    if not FolderTahap then
        return
    end

    for _, Tahap in ipairs(FolderTahap:GetChildren()) do
        local Hitbox = Tahap:FindFirstChild("Hitbox")
        if Hitbox and Hitbox:IsA("BasePart") then
            table.insert(DaftarHitbox, {
                Bagian = Hitbox,
                CfAsli = Hitbox.CFrame,
                AnchorAsli = Hitbox.Anchored,
                CollAsli = Hitbox.CanCollide,
                TouchAsli = Hitbox.CanTouch
            })
        end
    end
end

-- Kembalikan hitbox ke kondisi semula
local function KembalikanHitbox()
    for _, Data in ipairs(DaftarHitbox) do
        if Data.Bagian and Data.Bagian.Parent then
            Data.Bagian.CFrame = Data.CfAsli
            Data.Bagian.Anchored = Data.AnchorAsli
            Data.Bagian.CanCollide = Data.CollAsli
            Data.Bagian.CanTouch = Data.TouchAsli
        end
    end

    DaftarHitbox = {}
    BagianTubuh = nil
end

-- Peristiwa tombol buka
TombolBuka.MouseButton1Click:Connect(function()
    BingkaiUtama.Visible = not BingkaiUtama.Visible
end)

-- Peristiwa tombol tutup
TombolTutup.MouseButton1Click:Connect(function()
    BingkaiUtama.Visible = false
end)

-- Peristiwa tombol hidup/mati hitbox
TombolHidup.MouseButton1Click:Connect(function()
    SedangAktif = not SedangAktif

    if SedangAktif then
        KumpulkanHitbox()
        BagianTubuh = PemainLokal.Character and PemainLokal.Character:FindFirstChild("HumanoidRootPart")
        TombolHidup.Text = "Aktifkan Hitbox: NYA (" .. #DaftarHitbox .. " Ditemukan)"

        for _, Data in ipairs(DaftarHitbox) do
            if Data.Bagian and Data.Bagian.Parent then
                Data.Bagian.CanCollide = false
                Data.Bagian.CanTouch = true
                Data.Bagian.Anchored = false
            end
        end
    else
        TombolHidup.Text = "Aktifkan Hitbox: MATI"
        KembalikanHitbox()
    end
end)

-- Perulangan pembawaan hitbox mengikut pemain
LayananJalankan.Heartbeat:Connect(function()
    if not SedangAktif then
        return
    end

    if not BagianTubuh or not BagianTubuh.Parent then
        BagianTubuh = PemainLokal.Character and PemainLokal.Character:FindFirstChild("HumanoidRootPart")
        if not BagianTubuh then
            return
        end
    end

    local TargetCF = BagianTubuh.CFrame

    for i = 1, #DaftarHitbox do
        local Data = DaftarHitbox[i]
        if Data.Bagian and Data.Bagian.Parent then
            Data.Bagian.CFrame = TargetCF
        end
    end
end)

-- Perulangan animasi garis bingkai
task.spawn(function()
    local Putaran = 0

    while GuiLayar.Parent do
        Putaran = (Putaran + 1.5) % 360

        GradienGaris.Rotation = Putaran
        GradienBuka.Rotation = Putaran
        GradienHidup.Rotation = Putaran
        GradienTutup.Rotation = Putaran

        task.wait(0.03)
    end
end)
