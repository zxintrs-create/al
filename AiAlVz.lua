local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- ⚙️ PENGATURAN UTAMA (HITBOX EXPANDER)
-- =========================================================
local HITBOX_UKURAN = 25        -- Ukuran fisik Hitbox Musuh (25 x 25 x 25 studs)
local TRANSPARANSI_HITBOX = 0.6 -- Kejelasan visual (0 = Padat, 1 = Tak terlihat)
local WARNA_HITBOX = Color3.fromRGB(255, 50, 50) -- Warna Kotak Hitbox (Merah)

local AUTO_ATTACK_AKTIF = true  -- Status ON/OFF saat mulai game
local COOLDOWN_ATTACK = 0.2     -- Kecepatan tebasan (detik)
-- =========================================================

local sedangSerang = false
local btnGuiInstance = nil

-----------------------------------------------------------
-- 1. FUNGSI MEMPERBESAR FISIK HITBOX MUSUH
-----------------------------------------------------------
local function perbesarHitboxMusuh(model)
	if not model or model == player.Character then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")

	if humanoid and hrp and humanoid.Health > 0 then
		-- Pastikan target adalah MUSUH dan bukan Karakter Pemain Lain
		if not Players:GetPlayerFromCharacter(model) then
			-- UBAH FISIK HITBOX SECARA LANGSUNG
			hrp.Size = Vector3.new(HITBOX_UKURAN, HITBOX_UKURAN, HITBOX_UKURAN)
			hrp.Transparency = TRANSPARANSI_HITBOX
			hrp.Color = WARNA_HITBOX
			hrp.Material = Enum.Material.Forcefield
			hrp.CanCollide = false -- Agar pemain tidak tersangkut/terdorong musuh
		end
	end
end

-----------------------------------------------------------
-- 2. LOOP OTOMATIS MEMINDAI DAN MEMPERBESAR SEMUA MUSUH
-----------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.5) -- Memindai musuh baru setiap 0.5 detik
		if AUTO_ATTACK_AKTIF then
			local folderEnemies = workspace:FindFirstChild("Enemies") or workspace
			
			for _, obj in ipairs(folderEnemies:GetDescendants()) do
				if obj:IsA("Model") then
					perbesarHitboxMusuh(obj)
				end
			end
		end
	end
end)

-----------------------------------------------------------
-- 3. EKSEKUSI ATTACK BAWAAN MAP
-----------------------------------------------------------
local function eksekusiSerangan()
	if sedangSerang or not AUTO_ATTACK_AKTIF then return end
	sedangSerang = true

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
-- 4. GUI TOMBOL DRAGGABLE UNTUK MOBILE
-----------------------------------------------------------
local function updateButtonUI()
	if not btnGuiInstance then return end
	if AUTO_ATTACK_AKTIF then
		btnGuiInstance.Text = "HITBOX & AUTO: ON"
		btnGuiInstance.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	else
		btnGuiInstance.Text = "HITBOX & AUTO: OFF"
		btnGuiInstance.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	end
end

local function buatGUIMobile()
	local existingGui = playerGui:FindFirstChild("HitboxAutoGUI")
	if existingGui then existingGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HitboxAutoGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local btn = Instance.new("TextButton")
	btn.Name = "ToggleButton"
	btn.Size = UDim2.new(0, 170, 0, 50)
	btn.Position = UDim2.new(0.5, -85, 0.1, 0)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Active = true
	btn.Draggable = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = btn

	btnGuiInstance = btn

	btn.Activated:Connect(function()
		AUTO_ATTACK_AKTIF = not AUTO_ATTACK_AKTIF
		updateButtonUI()
	end)

	updateButtonUI()
	btn.Parent = screenGui
end

-----------------------------------------------------------
-- 5. JALANKAN SISTEM
-----------------------------------------------------------
buatGUIMobile()

player.CharacterAdded:Connect(function()
	task.wait(1)
	buatGUIMobile()
end)

-- Loop Auto Attack Kontinu
RunService.RenderStepped:Connect(function()
	if AUTO_ATTACK_AKTIF then
		eksekusiSerangan()
	end
end)
