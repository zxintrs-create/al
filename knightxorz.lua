local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local CONFIG = {
	AudioId = "rbxassetid://138004082589684",
	AudioVolume = 1,
	AudioLooped = true,
	ScaleTarget = Vector3.new(3, 3, 3),
	ScaleDuration = 2,
	SoulRingCount = 5,
	SoulRingRadius = 4,
	SoulRingSpeed = 1.5,
	SoulRingColors = {
		Color3.fromRGB(255, 50, 50),
		Color3.fromRGB(255, 150, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(100, 200, 255),
		Color3.fromRGB(200, 50, 255),
	},
	MeteorCount = 30,
	MeteorSpawnRadius = 60,
	MeteorHeight = 80,
	MeteorFallSpeed = 120,
	AuraParticleCount = 40,
	AuraRadius = 3.5,
	SkyColor = Color3.fromRGB(180, 20, 20),
	FogColor = Color3.fromRGB(80, 5, 5),
	FogEnd = 200,
	AmbientColor = Color3.fromRGB(60, 10, 10),
	OutdoorAmbient = Color3.fromRGB(80, 15, 15),
	Brightness = 1.5,
	ClockTime = 0,
	GlobalShadows = true,
}

local function notify(title, text, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text or "",
			Duration = dur or 5
		})
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoulMasterGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainBtn = Instance.new("TextButton")
mainBtn.Name = "MainButton"
mainBtn.Size = UDim2.new(0, 120, 0, 44)
mainBtn.Position = UDim2.new(0.5, -60, 1, -60)
mainBtn.Text = "🔥 ACTIVATE"
mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mainBtn.TextSize = 16
mainBtn.Font = Enum.Font.GothamBold
mainBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
mainBtn.BackgroundTransparency = 0.15
mainBtn.BorderSizePixel = 0
mainBtn.Parent = screenGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 10)
uicorner.Parent = mainBtn

local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.fromRGB(255, 100, 0)
uistroke.Thickness = 2
uistroke.Transparency = 0.3
uistroke.Parent = mainBtn

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 200, 0, 24)
statusLabel.Position = UDim2.new(0.5, -100, 1, -110)
statusLabel.Text = "🌀 Press to activate"
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.BackgroundTransparency = 1
statusLabel.TextStrokeTransparency = 0.5
statusLabel.Parent = screenGui

local volUpBtn = Instance.new("TextButton")
volUpBtn.Name = "VolUp"
volUpBtn.Size = UDim2.new(0, 50, 0, 50)
volUpBtn.Position = UDim2.new(1, -60, 0.5, -55)
volUpBtn.Text = "+"
volUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
volUpBtn.TextSize = 24
volUpBtn.Font = Enum.Font.GothamBold
volUpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
volUpBtn.BackgroundTransparency = 0.2
volUpBtn.BorderSizePixel = 0
volUpBtn.Parent = screenGui
local volUpCorner = Instance.new("UICorner")
volUpCorner.CornerRadius = UDim.new(0, 25)
volUpCorner.Parent = volUpBtn

local volDownBtn = Instance.new("TextButton")
volDownBtn.Name = "VolDown"
volDownBtn.Size = UDim2.new(0, 50, 0, 50)
volDownBtn.Position = UDim2.new(1, -60, 0.5, 5)
volDownBtn.Text = "-"
volDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
volDownBtn.TextSize = 24
volDownBtn.Font = Enum.Font.GothamBold
volDownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
volDownBtn.BackgroundTransparency = 0.2
volDownBtn.BorderSizePixel = 0
volDownBtn.Parent = screenGui
local volDownCorner = Instance.new("UICorner")
volDownCorner.CornerRadius = UDim.new(0, 25)
volDownCorner.Parent = volDownBtn

local volLabel = Instance.new("TextLabel")
volLabel.Name = "VolLabel"
volLabel.Size = UDim2.new(0, 50, 0, 20)
volLabel.Position = UDim2.new(1, -60, 0.5, -25)
volLabel.Text = "VOL 1.0"
volLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
volLabel.TextSize = 11
volLabel.Font = Enum.Font.Gotham
volLabel.BackgroundTransparency = 1
volLabel.Parent = screenGui

local function setHellSky()
	if not _G._originalLighting then
		_G._originalLighting = {
			FogColor = Lighting.FogColor,
			FogEnd = Lighting.FogEnd,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			GlobalShadows = Lighting.GlobalShadows,
			ColorShift_Top = Lighting.ColorShift_Top,
			ColorShift_Bottom = Lighting.ColorShift_Bottom,
		}
	end

	Lighting.FogColor = CONFIG.FogColor
	Lighting.FogEnd = CONFIG.FogEnd
	Lighting.Ambient = CONFIG.AmbientColor
	Lighting.OutdoorAmbient = CONFIG.OutdoorAmbient
	Lighting.Brightness = CONFIG.Brightness
	Lighting.ClockTime = CONFIG.ClockTime
	Lighting.GlobalShadows = CONFIG.GlobalShadows
	Lighting.ColorShift_Top = Color3.fromRGB(200, 30, 30)
	Lighting.ColorShift_Bottom = Color3.fromRGB(50, 5, 5)

	local sky = Instance.new("Sky")
	sky.Name = "HellSky"
	sky.SkyboxBk = "rbxassetid://14607339215"
	sky.SkyboxDn = "rbxassetid://14607339215"
	sky.SkyboxFt = "rbxassetid://14607339215"
	sky.SkyboxLf = "rbxassetid://14607339215"
	sky.SkyboxRt = "rbxassetid://14607339215"
	sky.SkyboxUp = "rbxassetid://14607339215"
	sky.SunTextureId = "rbxassetid://14607339215"
	sky.MoonTextureId = ""
	sky.StarAngle = 0
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "HellAtmosphere"
	atmosphere.Density = 0.5
	atmosphere.Offset = 0.3
	atmosphere.Color = CONFIG.SkyColor
	atmosphere.Decay = Color3.fromRGB(100, 10, 10)
	atmosphere.Glare = 0.4
	atmosphere.Haze = 0.8
	atmosphere.Parent = Lighting

	notify("🔥 Hell Mode", "Soul Master activated", 3)
end

local function hideDisplayName()
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name:lower():match("name") then
			v.Enabled = false
		end
	end
	pcall(function() player.NameDisplayDistance = 0 end)
end

local function scaleAvatar()
	local scales = {
		BodyHeightScale = CONFIG.ScaleTarget.Y,
		BodyWidthScale = CONFIG.ScaleTarget.X,
		BodyDepthScale = CONFIG.ScaleTarget.Z,
		HeadScale = CONFIG.ScaleTarget.X * 0.8
	}
	
	local tweenInfo = TweenInfo.new(CONFIG.ScaleDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for name, val in pairs(scales) do
		local valObj = humanoid:FindFirstChild(name)
		if valObj and valObj:IsA("NumberValue") then
			TweenService:Create(valObj, tweenInfo, {Value = val}):Play()
		end
	end

	notify("⚡ Avatar", "Soul Avatar enlarged!", 2)
end

local soulRingParts = {}

local function createSoulRing(index, color, radius)
	local ring = Instance.new("Part")
	ring.Name = "SoulRing_" .. index
	ring.Size = Vector3.new(radius * 2, 0.2, 0.2)
	ring.Shape = Enum.PartType.Cylinder
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.3
	ring.BrickColor = BrickColor.new("Really red")
	ring.Parent = workspace

	local att = Instance.new("Attachment")
	att.Name = "RingAtt"
	att.Parent = ring

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "RingParticle"
	particle.Texture = "rbxassetid://14293532190"
	particle.Rate = 15
	particle.Lifetime = NumberRange.new(0.3, 0.6)
	particle.Speed = NumberRange.new(1, 3)
	particle.Rotation = NumberRange.new(0, 360)
	particle.RotSpeed = NumberRange.new(-50, 50)
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	particle.Transparency = NumberSequence.new(0.3)
	particle.Color = ColorSequence.new(color)
	particle.LightEmission = 1
	particle.LightInfluence = 0
	particle.Enabled = true
	particle.Parent = att

	local beam = Instance.new("Beam")
	beam.Name = "RingBeam"
	beam.Texture = "rbxassetid://14293532190"
	beam.TextureSpeed = 5
	beam.TextureLength = 1
	beam.Width0 = 0.3
	beam.Width1 = 0.3
	beam.Color = ColorSequence.new(color)
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Transparency = NumberSequence.new(0.2)
	beam.FaceCamera = true
	beam.Parent = att

	local attEnd = Instance.new("Attachment")
	attEnd.Name = "RingAttEnd"
	attEnd.Position = Vector3.new(0, 0, radius * 2)
	attEnd.Parent = ring

	beam.Attachment0 = att
	beam.Attachment1 = attEnd

	table.insert(soulRingParts, ring)
	return ring
end

local function updateSoulRings()
	for _, ring in ipairs(soulRingParts) do
		ring:Destroy()
	end
	soulRingParts = {}

	local ringHeightOffset = -1.5

	for i = 1, CONFIG.SoulRingCount do
		local radius = CONFIG.SoulRingRadius + (i * 0.3)
		local color = CONFIG.SoulRingColors[(i - 1) % #CONFIG.SoulRingColors + 1]
		local ring = createSoulRing(i, color, radius)

		local data = {
			ring = ring,
			angle = (i / CONFIG.SoulRingCount) * math.pi * 2,
			radius = radius,
			heightOffset = ringHeightOffset + (i * 0.6),
			speed = CONFIG.SoulRingSpeed + (i * 0.1),
			tiltAngle = math.rad(15 + (i * 5)),
		}

		ring:SetAttribute("RingData", data)
	end
end

local wingParts = {}

local function createWingedAura()
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or rootPart
	if not torso then return end

	local wingConfigs = {
		{side = "Left",  offset = Vector3.new(-2, 0.5, 0), rot = Vector3.new(0, 0, 20)},
		{side = "Right", offset = Vector3.new(2, 0.5, 0),  rot = Vector3.new(0, 0, -20)},
	}

	for _, cfg in ipairs(wingConfigs) do
		local wingPart = Instance.new("Part")
		wingPart.Name = "WingAura_" .. cfg.side
		wingPart.Size = Vector3.new(0.5, 3, 4)
		wingPart.Shape = Enum.PartType.Block
		wingPart.Anchored = true
		wingPart.CanCollide = false
		wingPart.Material = Enum.Material.Neon
		wingPart.Color = Color3.fromRGB(255, 100, 50)
		wingPart.Transparency = 0.3
		wingPart.BrickColor = BrickColor.new("Bright red")
		wingPart.Parent = workspace

		local att = Instance.new("Attachment")
		att.Name = "WingAtt"
		att.Parent = wingPart

		local particle = Instance.new("ParticleEmitter")
		particle.Name = "WingParticle"
		particle.Texture = "rbxassetid://14293532190"
		particle.Rate = 30
		particle.Lifetime = NumberRange.new(0.5, 1)
		particle.Speed = NumberRange.new(2, 5)
		particle.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		particle.Transparency = NumberSequence.new(0.2)
		particle.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 0))
		})
		particle.LightEmission = 1
		particle.LightInfluence = 0
		particle.SpreadAngle = Vector2.new(30, 30)
		particle.Drag = 2
		particle.Parent = att

		local light = Instance.new("PointLight")
		light.Name = "WingLight"
		light.Color = Color3.fromRGB(255, 100, 0)
		light.Range = 12
		light.Brightness = 3
		light.Parent = wingPart

		table.insert(wingParts, {
			part = wingPart,
			side = cfg.side,
			offset = cfg.offset,
			rot = cfg.rot,
		})
	end
end

local swordParts = {}

local function createEnergySword()
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or rootPart
	if not torso then return end

	local blade = Instance.new("Part")
	blade.Name = "EnergySword_Blade"
	blade.Size = Vector3.new(0.5, 6, 0.5)
	blade.Anchored = true
	blade.CanCollide = false
	blade.Material = Enum.Material.Neon
	blade.Color = Color3.fromRGB(0, 200, 255)
	blade.Transparency = 0.2
	blade.BrickColor = BrickColor.new("Cyan")
	blade.Parent = workspace

	local att = Instance.new("Attachment")
	att.Name = "BladeAtt"
	att.Parent = blade

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "BladeParticle"
	particle.Texture = "rbxassetid://14293532190"
	particle.Rate = 40
	particle.Lifetime = NumberRange.new(0.3, 0.8)
	particle.Speed = NumberRange.new(1, 3)
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})
	particle.Transparency = NumberSequence.new(0.1)
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 255))
	})
	particle.LightEmission = 2
	particle.LightInfluence = 0
	particle.SpreadAngle = Vector2.new(10, 10)
	particle.Parent = att

	local light = Instance.new("PointLight")
	light.Name = "SwordLight"
	light.Color = Color3.fromRGB(0, 200, 255)
	light.Range = 15
	light.Brightness = 5
	light.Parent = blade

	local guard = Instance.new("Part")
	guard.Name = "EnergySword_Guard"
	guard.Size = Vector3.new(1.5, 0.3, 0.3)
	guard.Anchored = true
	guard.CanCollide = false
	guard.Material = Enum.Material.Neon
	guard.Color = Color3.fromRGB(255, 200, 50)
	guard.BrickColor = BrickColor.new("Bright yellow")
	guard.Parent = workspace

	table.insert(swordParts, {part = blade, type = "blade", offset = Vector3.new(0, 3, 0)})
	table.insert(swordParts, {part = guard, type = "guard", offset = Vector3.new(0, 0, 0)})
end

local meteorParts = {}

local function createMeteor()
	if not rootPart then return end
	local spawnPos = rootPart.Position + Vector3.new(
		math.random(-CONFIG.MeteorSpawnRadius, CONFIG.MeteorSpawnRadius),
		CONFIG.MeteorHeight + math.random(0, 30),
		math.random(-CONFIG.MeteorSpawnRadius, CONFIG.MeteorSpawnRadius)
	)

	local meteor = Instance.new("Part")
	meteor.Name = "Meteor"
	meteor.Size = Vector3.new(2 + math.random() * 3, 2 + math.random() * 3, 2 + math.random() * 3)
	meteor.Shape = Enum.PartType.Ball
	meteor.Anchored = true
	meteor.CanCollide = false
	meteor.Material = Enum.Material.Neon
	meteor.Color = Color3.fromRGB(255, 100 + math.random(50), 0)
	meteor.Transparency = 0.1
	meteor.BrickColor = BrickColor.new("Bright red")
	meteor.CFrame = CFrame.new(spawnPos)
	meteor.Parent = workspace

	local att = Instance.new("Attachment")
	att.Name = "MeteorAtt"
	att.Parent = meteor

	local fire = Instance.new("ParticleEmitter")
	fire.Name = "MeteorFire"
	fire.Texture = "rbxassetid://14293532190"
	fire.Rate = 50
	fire.Lifetime = NumberRange.new(0.5, 1.5)
	fire.Speed = NumberRange.new(3, 8)
	fire.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2 + math.random() * 3),
		NumberSequenceKeypoint.new(1, 0)
	})
	fire.Transparency = NumberSequence.new(0)
	fire.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 0))
	})
	fire.LightEmission = 2
	fire.LightInfluence = 0
	fire.SpreadAngle = Vector2.new(20, 20)
	fire.Acceleration = Vector3.new(0, -20, 0)
	fire.Drag = 1
	fire.Parent = att

	local trailAtt = Instance.new("Attachment")
	trailAtt.Name = "TrailAtt"
	trailAtt.Parent = meteor

	local trail = Instance.new("Trail")
	trail.Name = "MeteorTrail"
	trail.Texture = "rbxassetid://14293532190"
	trail.TextureLength = 3
	trail.TextureMode = Enum.TextureMode.Wrap
	trail.Width0 = 1.5
	trail.Width1 = 0.5
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 0))
	})
	trail.LightEmission = 2
	trail.Lifetime = 1
	trail.Parent = trailAtt
	trail.Attachment0 = trailAtt
	trail.Attachment1 = att

	local light = Instance.new("PointLight")
	light.Name = "MeteorLight"
	light.Color = Color3.fromRGB(255, 100, 0)
	light.Range = 20
	light.Brightness = 5
	light.Parent = meteor

	local data = {
		part = meteor,
		velocity = Vector3.new(
			math.random(-20, 20),
			-CONFIG.MeteorFallSpeed - math.random(0, 30),
			math.random(-20, 20)
		),
		rotationSpeed = Vector3.new(
			math.rad(math.random(-100, 100)),
			math.rad(math.random(-100, 100)),
			math.rad(math.random(-100, 100))
		),
	}

	table.insert(meteorParts, data)
	Debris:AddItem(meteor, 15)
	return data
end

local auraParticles = {}

local function createBodyAura()
	if not rootPart then return end
	local att = Instance.new("Attachment")
	att.Name = "BodyAuraAtt"
	att.Position = Vector3.new(0, 0, 0)
	att.Parent = rootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "BodyAuraParticle"
	particle.Texture = "rbxassetid://14293532190"
	particle.Rate = 60
	particle.Lifetime = NumberRange.new(1, 2.5)
	particle.Speed = NumberRange.new(2, 6)
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	particle.Transparency = NumberSequence.new(0.2)
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 100)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 0))
	})
	particle.LightEmission = 2
	particle.LightInfluence = 0
	particle.SpreadAngle = Vector2.new(60, 60)
	particle.VelocityInheritance = 0.2
	particle.Acceleration = Vector3.new(0, 5, 0)
	particle.Parent = att

	table.insert(auraParticles, particle)

	local particle2 = particle:Clone()
	particle2.Rate = 30
	particle2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2.5),
		NumberSequenceKeypoint.new(1, 0.5)
	})
	particle2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 100))
	})
	particle2.Transparency = NumberSequence.new(0.4)
	particle2.Parent = att

	table.insert(auraParticles, particle2)
end

local soundRef = nil

local function setupAudio()
	local oldSound = workspace:FindFirstChild("SoulMasterAudio")
	if oldSound then oldSound:Destroy() end

	local sound = Instance.new("Sound")
	sound.Name = "SoulMasterAudio"
	sound.SoundId = CONFIG.AudioId
	sound.Volume = CONFIG.AudioVolume
	sound.Looped = CONFIG.AudioLooped
	sound.PlayOnRemove = false
	sound.EmitterSize = 0
	sound.Parent = workspace
	soundRef = sound

	sound:Play()
	notify("🎵 Audio", "Soul Master theme playing", 2)
	return sound
end

local updateConnection
local function startUpdateLoop()
	if updateConnection then updateConnection:Disconnect() end
	updateConnection = RunService.Heartbeat:Connect(function(dt)
		if not rootPart then return end
		local charPos = rootPart.Position

		for _, ringPart in ipairs(soulRingParts) do
			local data = ringPart:GetAttribute("RingData")
			if data then
				data.angle = data.angle + data.speed * dt
				local x = math.cos(data.angle) * data.radius
				local z = math.sin(data.angle) * data.radius
				local y = data.heightOffset + math.sin(data.angle * 2) * 0.5
				local worldPos = charPos + Vector3.new(x, y, z)
				local lookDir = (charPos - worldPos).Unit
				if lookDir.Magnitude > 0.01 then
					ringPart.CFrame = CFrame.lookAt(worldPos, worldPos + lookDir) * CFrame.Angles(math.rad(90), 0, 0)
				end
			end
		end

		for _, w in ipairs(wingParts) do
			local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or rootPart
			if torso then
				local torsoCF = torso.CFrame
				local pos = torsoCF.Position + torsoCF:VectorToWorldSpace(w.offset)
				local rotCF = torsoCF * CFrame.Angles(math.rad(w.rot.X), math.rad(w.rot.Y), math.rad(w.rot.Z))
				w.part.CFrame = CFrame.new(pos) * rotCF.Rotation
			end
		end

		local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		if rightHand then
			local handCF = rightHand.CFrame
			for _, s in ipairs(swordParts) do
				local pos = handCF.Position + handCF:VectorToWorldSpace(s.offset)
				local swordCF = handCF * CFrame.Angles(math.rad(-90), 0, 0)
				s.part.CFrame = CFrame.new(pos) * swordCF.Rotation
			end
		elseif rootPart then
			for _, s in ipairs(swordParts) do
				local pos = rootPart.Position + Vector3.new(2, 1, 0) + s.offset
				s.part.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(-90), 0, 0)
			end
		end

		for i = #meteorParts, 1, -1 do
			local m = meteorParts[i]
			if m.part and m.part.Parent then
				m.part.CFrame = m.part.CFrame * CFrame.Angles(m.rotationSpeed.X * dt, m.rotationSpeed.Y * dt, m.rotationSpeed.Z * dt)
				m.part.Position = m.part.Position + m.velocity * dt
				if m.part.Position.Y < charPos.Y - 20 then
					m.part:Destroy()
					table.remove(meteorParts, i)
				end
			else
				table.remove(meteorParts, i)
			end
		end
	end)
end

local function startMeteorRain()
	task.spawn(function()
		for i = 1, CONFIG.MeteorCount do
			task.wait(0.1)
			createMeteor()
		end

		while character and character.Parent and _G._soulMasterActive do
			task.wait(0.3 + math.random() * 0.5)
			createMeteor()
		end
	end)
end

local function cleanup()
	if updateConnection then
		updateConnection:Disconnect()
		updateConnection = nil
	end

	local sky = Lighting:FindFirstChild("HellSky")
	if sky then sky:Destroy() end

	local atmo = Lighting:FindFirstChild("HellAtmosphere")
	if atmo then atmo:Destroy() end

	if _G._originalLighting then
		for prop, val in pairs(_G._originalLighting) do
			pcall(function() Lighting[prop] = val end)
		end
	end

	for _, ring in ipairs(soulRingParts) do ring:Destroy() end
	soulRingParts = {}

	for _, w in ipairs(wingParts) do w.part:Destroy() end
	wingParts = {}

	for _, s in ipairs(swordParts) do s.part:Destroy() end
	swordParts = {}

	for _, m in ipairs(meteorParts) do
		if m.part and m.part.Parent then m.part:Destroy() end
	end
	meteorParts = {}

	for _, p in ipairs(auraParticles) do
		if p and p.Parent then p:Destroy() end
	end
	auraParticles = {}

	local sound = workspace:FindFirstChild("SoulMasterAudio")
	if sound then sound:Destroy() end
	soundRef = nil

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	end

	notify("🌀 Deactivated", "Soul Master mode off", 2)
end

local function activateSoulMaster()
	if _G._soulMasterActive then return end
	_G._soulMasterActive = true

	mainBtn.Text = "🔥 ACTIVE"
	mainBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
	statusLabel.Text = "🔥 Soul Master ACTIVE"

	notify("🔥 SOUL MASTER", "Activating...", 2)
	setHellSky()
	hideDisplayName()
	scaleAvatar()
	createBodyAura()
	updateSoulRings()
	createWingedAura()
	createEnergySword()
	startMeteorRain()
	setupAudio()
	startUpdateLoop()
	notify("✅ SOUL MASTER", "Fully activated!", 3)
end

local function deactivateSoulMaster()
	if not _G._soulMasterActive then return end
	_G._soulMasterActive = false

	mainBtn.Text = "🔥 ACTIVATE"
	mainBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
	statusLabel.Text = "🌀 Press to activate"

	cleanup()
end

mainBtn.MouseButton1Click:Connect(function()
	if _G._soulMasterActive then
		deactivateSoulMaster()
	else
		activateSoulMaster()
	end
end)

volUpBtn.MouseButton1Click:Connect(function()
	if soundRef then
		soundRef.Volume = math.min(soundRef.Volume + 0.1, 2)
		volLabel.Text = "VOL " .. string.format("%.1f", soundRef.Volume)
	end
end)

volDownBtn.MouseButton1Click:Connect(function()
	if soundRef then
		soundRef.Volume = math.max(soundRef.Volume - 0.1, 0)
		volLabel.Text = "VOL " .. string.format("%.1f", soundRef.Volume)
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F1 then
		mainBtn.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.Equals then
		volUpBtn.MouseButton1Click:Fire()
	elseif input.KeyCode == Enum.KeyCode.Minus then
		volDownBtn.MouseButton1Click:Fire()
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")

	if _G._soulMasterActive then
		task.wait(0.5)
		hideDisplayName()
		scaleAvatar()

		for _, ring in ipairs(soulRingParts) do ring:Destroy() end
		soulRingParts = {}
		updateSoulRings()

		for _, w in ipairs(wingParts) do w.part:Destroy() end
		wingParts = {}
		createWingedAura()

		for _, s in ipairs(swordParts) do s.part:Destroy() end
		swordParts = {}
		createEnergySword()

		notify("🔄 Respawned", "Soul Master re-applied", 2)
	end
end)

notify("🌀 Soul Master Loaded", "Tap 🔥 button to activate", 5)
print("AldoVz")
