--[[  
🔥 BIG FIRE NO VISUAL — Delta Mobile  
Efek Fire + Explosion real, dilihat semua player  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
CARA PAKAI:  
- Execute di Delta, langsung nyala  
- Tap tombol 🔥 di layar buat trigger fire di posisi karakter  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
--]]

local Players = game:GetService("Players")  
local Workspace = game:GetService("Workspace")  
local Debris = game:GetService("Debris")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local StarterGui = game:GetService("StarterGui")  
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer  
local playerGui = player:WaitForChild("PlayerGui")

local function protect(cb)  
  local ok, r = pcall(cb)  
  return ok, r  
end

local function notify(t, txt, d)  
  protect(function()  
    StarterGui:SetCore("SendNotification", {Title = t, Text = txt, Duration = d or 1.5})  
  end)  
end

-- cari parent gui  
local guiParent  
protect(function()  
  if gethui then guiParent = gethui() end  
end)  
if not guiParent then guiParent = CoreGui end

-- screengui  
local sg = Instance.new("ScreenGui")  
sg.Name = "BigFireNoVisual"  
sg.ResetOnSpawn = false  
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
sg.DisplayOrder = 999999  
sg.IgnoreGuiInset = true  
protect(function() sg.Parent = guiParent end)  
if not sg.Parent then  
  protect(function() sg.Parent = playerGui end)  
end

-- floating button  
local btn = Instance.new("TextButton")  
btn.Size = UDim2.fromOffset(60, 60)  
btn.Position = UDim2.new(0, 20, 0.5, -30)  
btn.Text = "🔥"  
btn.TextSize = 28  
btn.BackgroundColor3 = Color3.fromRGB(200, 40, 0)  
btn.BackgroundTransparency = 0.1  
btn.BorderSizePixel = 0  
btn.ZIndex = 999  
btn.Parent = sg

local corner = Instance.new("UICorner")  
corner.CornerRadius = UDim.new(1, 0)  
corner.Parent = btn

local stroke = Instance.new("UIStroke")  
stroke.Color = Color3.fromRGB(255, 120, 0)  
stroke.Thickness = 2  
stroke.Transparency = 0.2  
stroke.Parent = btn

-- drag logic  
local dragging = false  
local offset = Vector2.new()

btn.InputBegan:Connect(function(input)  
  if input.UserInputType == Enum.UserInputType.Touch then  
    dragging = true  
    offset = input.Position - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)  
  end  
end)

btn.InputEnded:Connect(function(input)  
  if input.UserInputType == Enum.UserInputType.Touch then  
    dragging = false  
  end  
end)

UserInputService.InputChanged:Connect(function(input)  
  if not dragging then return end  
  if input.UserInputType ~= Enum.UserInputType.Touch then return end  
  protect(function()  
    local vp = Workspace.CurrentCamera.ViewportSize  
    local p = input.Position - offset  
    btn.Position = UDim2.fromOffset(  
      math.clamp(p.X, 0, vp.X - 60),  
      math.clamp(p.Y, 0, vp.Y - 60)  
    )  
  end)  
end)

-- ─── CORE FIRE FUNCTION ────────────────────────  
-- bikin Fire + Explosion di posisi karakter  
-- Fire instance = real, semua player bisa lihat  
local function spawnFire()  
  protect(function()  
    local char = player.Character  
    if not char then  
      notify("🔥 Fire", "Karakter tidak ditemukan!", 1)  
      return  
    end

    local root = char:FindFirstChild("HumanoidRootPart")  
    if not root then  
      notify("🔥 Fire", "Root part tidak ada!", 1)  
      return  
    end

    local pos = root.Position  
    local cf = root.CFrame

    -- ─── BIG FIRE (Fire Instance) ─────────────  
    -- Fire di 5 titik di sekitar karakter  
    -- Fire instance REPLICATE ke semua player  
    local fireParts = {}  
    for i = 1, 5 do  
      local angle = (i / 5) * math.pi * 2  
      local radius = 6 + math.random() * 4  
      local x = math.cos(angle) * radius  
      local z = math.sin(angle) * radius

      -- bikin part tipis transparan sebagai anchor fire  
      local part = Instance.new("Part")  
      part.Size = Vector3.new(2, 0.5, 2)  
      part.Position = pos + Vector3.new(x, 0.5, z)  
      part.Anchored = true  
      part.CanCollide = false  
      part.Transparency = 1  -- invisible, cuma fire yang kelihatan  
      part.Material = Enum.Material.Fire  
      part.Parent = Workspace  
      table.insert(fireParts, part)

      -- FIRE INSTANCE — REAL, semua player lihat  
      local fire = Instance.new("Fire")  
      fire.Size = 12 + math.random() * 8  
      fire.Heat = 8 + math.random() * 6  
      fire.Color = Color3.new(1, 0.5, 0)  
      fire.SecondaryColor = Color3.new(1, 0.2, 0)  
      fire.Parent = part

      -- sparkles  
      local sparkles = Instance.new("Sparkles")  
      sparkles.SparkleColor = Color3.new(1, 0.6, 0)  
      sparkles.Parent = part

      -- smoke  
      local smoke = Instance.new("Smoke")  
      smoke.Color = Color3.fromRGB(80, 80, 80)  
      smoke.Opacity = 0.4  
      smoke.Size = 10  
      smoke.RiseVelocity = 2  
      smoke.Parent = part

      -- cleanup 15 detik  
      Debris:AddItem(part, 15)  
    end

    -- ─── BIG FIRE DI TITIK TENGAH ────────────  
    local centerPart = Instance.new("Part")  
    centerPart.Size = Vector3.new(4, 0.5, 4)  
    centerPart.Position = pos + Vector3.new(0, 0.5, 0)  
    centerPart.Anchored = true  
    centerPart.CanCollide = false  
    centerPart.Transparency = 1  
    centerPart.Material = Enum.Material.Fire  
    centerPart.Parent = Workspace  
    table.insert(fireParts, centerPart)

    local centerFire = Instance.new("Fire")  
    centerFire.Size = 20 + math.random() * 10  
    centerFire.Heat = 15  
    centerFire.Color = Color3.new(1, 0.8, 0)  
    centerFire.SecondaryColor = Color3.new(1, 0.3, 0)  
    centerFire.Parent = centerPart

    local centerSparkles = Instance.new("Sparkles")  
    centerSparkles.SparkleColor = Color3.new(1, 0.8, 0.2)  
    centerSparkles.Parent = centerPart

    local centerSmoke = Instance.new("Smoke")  
    centerSmoke.Color = Color3.fromRGB(60, 60, 60)  
    centerSmoke.Opacity = 0.6  
    centerSmoke.Size = 15  
    centerSmoke.RiseVelocity = 3  
    centerSmoke.Parent = centerPart

    Debris:AddItem(centerPart, 20)

    -- ─── EXPLOSION ───────────────────────────  
    -- Explosion instance = real damage + push, semua player kena  
    local explosion = Instance.new("Explosion")  
    explosion.Position = pos + Vector3.new(0, 2, 0)  
    explosion.BlastRadius = 20  
    explosion.BlastPressure = 50000  
    explosion.DestroyJointRadiusPercent = 0.3  
    explosion.Visible = true  -- player lain lihat ledakan  
    explosion.Parent = Workspace

    notify("🔥 BIG FIRE", "Api menyala! Semua player bisa lihat!", 2)  
  end)  
end

-- ─── TRIGGER ───────────────────────────────────  
btn.Activated:Connect(function()  
  if dragging then return end  
  spawnFire()  
end)

-- ─── NOTIF ─────────────────────────────────────  
task.delay(1, function()  
  notify("🔥 Big Fire", "Tap 🔥 buat trigger fire real!", 2.5)  
end)

print("[BigFireNoVisual] Loaded — Fire + Explosion real, semua player lihat")  
