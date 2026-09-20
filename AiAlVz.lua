local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- ⚙️ PENGATURAN UTAMA (KHUSUS MOBILE)
-- =========================================================
local HITBOX_LEBAR = 900         -- Lebar area hitbox ke samping (Sumbu X)
local HITBOX_PANJANG = 992       -- Jangkauan area ke depan (Sumbu Z)
local HITBOX_TINGGI = 6         -- Tinggi area hitbox (Sumbu Y)

local COOLDOWN_ATTACK = 0.35    -- Jeda antar serangan otomatis (detik)
local AUTO_ATTACK_AKTIF = true  -- Status awal Auto Attack (true = ON, false = OFF)

local WARNA_HITBOX = Color3.fromRGB(255, 50, 50) -- Warna Hitbox Visual (Merah)
local TRANSPARANSI_HITBOX = 0.5  -- Kejelasan visual (0 = Padat, 1 = Tidak Terlihat)
-- =========================================================

local sedangSerang = false
local btnGuiInstance = nil

-----------------------------------------------------------
-- 1. EFEK VISUAL HITBOX MERAH
-----------------------------------------------------------
local function tampilkanVisual(hrp)
	local visual = Instance.new("Part")
	visual.Name = "LocalHitbox_Visual"
	visual.Size = Vector3.new(HITBOX_LEBAR, HITBOX_TINGGI, HITBOX_PANJANG)
	visual.Material = Enum.Material.Forcefield
	visual.Color = WARNA_HITBOX
	visual.Transparency = TRANSPARANSI_HITBOX
	visual.CanCollide = false
	visual.CanQuery = false
	visual.CanTouch = false
	visual.Anchored = true

	-- Posisikan kotak di depan karakter
	visual.CFrame = hrp.CFrame * CFrame.new(0, 0, -HITBOX_PANJANG / 2)
	visual.Parent = workspace

	-- Animasi Menghilang Halus (Fade Out)
	local tween = TweenService:Create(visual, TweenInfo.new(0.2), {Transparency = 1})
	tween:Play()
	tween.Completed:Connect(function()
		visual:Destroy()
	end)
end

-----------------------------------------------------------
-- 2. MEMANGGIL EVENT SERANGAN MAP BAWAAN
-----------------------------------------------------------
local function eksekusiSerangan(hrp)
	if sedangSerang then return end
	sedangSerang = true

	-- Tampilkan efek visual kotak merah
	tampilkanVisual(hrp)

	-- Memanggil RemoteEvent Combat bawaan map (Net -> Events -> Combat)
	pcall(function()
		local combatEvent = ReplicatedStorage:FindFirstChild("Net")
			and ReplicatedStorage.Net:FindFirstChild("Events")
			and ReplicatedStorage.Net.Events:FindFirstChild("Combat")
		
		if combatEvent then
			combatEvent:FireServer()
		end
	end)

	task.wait(COOLDOWN_ATTACK)
	sedangSerang = false
end

-----------------------------------------------------------
-- 3. DETEKSI MUSUH DI HP (SEMUA MODEL / RIG)
-----------------------------------------------------------
local function cekHitbox()
	if not AUTO_ATTACK_AKTIF or sedangSerang then return end

	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid or humanoid.Health <= 0 then return end

	-- Buat batasan area kotak di depan pemain
	local centerCFrame = hrp.CFrame * CFrame.new(0, 0, -HITBOX_PANJANG / 2)
	local boxSize = Vector3.new(HITBOX_LEBAR, HITBOX_TINGGI, HITBOX_PANJANG)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character}

	local partsInBox = workspace:GetPartBoundsInBox(centerCFrame, boxSize, overlapParams)

	for _, part in ipairs(partsInBox) do
		local enemyModel = part:FindFirstAncestorOfClass("Model")
		
		if enemyModel and enemyModel ~= character then
			local targetHumanoid = enemyModel:FindFirstChildOfClass("Humanoid")
			
			if targetHumanoid and targetHumanoid.Health > 0 then
				local enemiesFolder = workspace:FindFirstChild("Enemies")
				local isEnemy = (enemiesFolder and enemyModel:IsDescendantOf(enemiesFolder)) 
					or not Players:GetPlayerFromCharacter(enemyModel)

				if isEnemy then
					eksekusiSerangan(hrp)
					break
				end
			end
		end
	end
end

-----------------------------------------------------------
-- 4. GUI OPTIMASI LAYAR SENTUH HP (TOUCH & DRAGGABLE)
-----------------------------------------------------------
local function updateButtonUI()
	if not btnGuiInstance then return end
	if AUTO_ATTACK_AKTIF then
		btnGuiInstance.Text = "AUTO ATTACK: ON"
		btnGuiInstance.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
	else
		btnGuiInstance.Text = "AUTO ATTACK: OFF"
		btnGuiInstance.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah
	end
end

local function buatGUIMobile()
	local existingGui = playerGui:FindFirstChild("AutoAttackGUI")
	if existingGui then existingGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoAttackGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Tombol Lebih Besar dan Mudah Ditap Jari
	local btn = Instance.new("TextButton")
	btn.Name = "ToggleButton"
	btn.Size = UDim2.new(0, 160, 0, 50) -- Ukuran pas untuk ibu jari
	btn.Position = UDim2.new(0.5, -80, 0.1, 0) -- Bagian atas layar HP
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 17
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Active = true
	btn.Draggable = true -- BISA DIGESER DENGAN JARI DI LAYAR HP

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = btn

	btnGuiInstance = btn

	-- Deteksi Sentuhan Layar HP (Activated)
	btn.Activated:Connect(function()
		AUTO_ATTACK_AKTIF = not AUTO_ATTACK_AKTIF
		updateButtonUI()
	end)

	updateButtonUI()
	btn.Parent = screenGui
end

-----------------------------------------------------------
-- 5. MENJALANKAN SISTEM AUTOMATIS
-----------------------------------------------------------
buatGUIMobile()

player.CharacterAdded:Connect(function()
	task.wait(1)
	buatGUIMobile()
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		cekHitbox()
	end
end)
