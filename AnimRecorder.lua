--// TS AUTO WALK V2 FULL FINAL
--// Client-side | UI Clean | Record - Stop - Play - History

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- ================= UTIL =================
local function notify(txt)
	pcall(function()
		StarterGui:SetCore("SendNotification",{
			Title = "TS Auto Walk",
			Text = txt,
			Duration = 2
		})
	end)
end

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

-- ================= DATA =================
local recording = false
local paused = false
local playing = false
local loopPlay = false
local canSave = false

local speed = 16
local currentRecord = {}
local records = {}

-- ================= GUI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "TS_AutoWalk"
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.32,0.48)
main.Position = UDim2.fromScale(0.34,0.26)
main.BackgroundTransparency = 1

-- BACKGROUND IMAGE
local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.fromScale(1,1)
bg.Image = "rbxassetid://14445734352"
bg.ScaleType = Enum.ScaleType.Crop
bg.BackgroundTransparency = 1
bg.ImageTransparency = 0.15
Instance.new("UICorner", bg).CornerRadius = UDim.new(0,18)

-- TOPBAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0.12,0)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(0.65,0,1,0)
title.Text = "TS AUTO WALK"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BackgroundTransparency = 1

local btnMin = Instance.new("TextButton", top)
btnMin.Size = UDim2.new(0.15,0,0.6,0)
btnMin.Position = UDim2.new(0.7,0,0.2,0)
btnMin.Text = "—"
btnMin.TextScaled = true
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.BackgroundTransparency = 1

local btnClose = Instance.new("TextButton", top)
btnClose.Size = UDim2.new(0.15,0,0.6,0)
btnClose.Position = UDim2.new(0.85,0,0.2,0)
btnClose.Text = "✕"
btnClose.TextScaled = true
btnClose.TextColor3 = Color3.new(1,0.4,0.4)
btnClose.BackgroundTransparency = 1

-- DRAG
do
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- BUTTON MAKER
local function mkBtn(txt,y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0.85,0,0.075,0)
	b.Position = UDim2.new(0.075,0,y,0)
	b.Text = txt
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(20,20,20)
	b.BackgroundTransparency = 0.2
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	return b
end

local y = 0.14
local btnRecord = mkBtn("Record Track", y); y+=0.085
local btnPause  = mkBtn("Pause Track", y); y+=0.085
local btnStop   = mkBtn("Stop Track", y); y+=0.085
local btnPlay   = mkBtn("Start Track", y); y+=0.085
local btnLoop   = mkBtn("Loop : OFF", y); y+=0.085
local btnSave   = mkBtn("Simpan Record", y); y+=0.085

-- SPEED
local spdTxt = Instance.new("TextLabel", main)
spdTxt.Size = UDim2.new(0.85,0,0.06,0)
spdTxt.Position = UDim2.new(0.075,0,y,0)
spdTxt.Text = "Speed : 16"
spdTxt.TextColor3 = Color3.new(1,1,1)
spdTxt.Font = Enum.Font.Gotham
spdTxt.TextScaled = true
spdTxt.BackgroundTransparency = 1
y+=0.07

local plus = mkBtn("+ Speed", y)
plus.Size = UDim2.new(0.4,0,0.06,0)
plus.Position = UDim2.new(0.075,0,y,0)

local minus = mkBtn("- Speed", y)
minus.Size = UDim2.new(0.4,0,0.06,0)
minus.Position = UDim2.new(0.525,0,y,0)
y+=0.075

-- HISTORY
local histLabel = Instance.new("TextLabel", main)
histLabel.Size = UDim2.new(0.85,0,0.05,0)
histLabel.Position = UDim2.new(0.075,0,y,0)
histLabel.Text = "Riwayat Record"
histLabel.TextColor3 = Color3.new(1,1,1)
histLabel.Font = Enum.Font.GothamBold
histLabel.TextScaled = true
histLabel.BackgroundTransparency = 1
y+=0.05

local list = Instance.new("ScrollingFrame", main)
list.Size = UDim2.new(0.85,0,0.18,0)
list.Position = UDim2.new(0.075,0,y,0)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.5
list.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

-- ================= RECORD LOOP =================
task.spawn(function()
	while true do
		if recording and not paused then
			local hrp = getChar():FindFirstChild("HumanoidRootPart")
			if hrp then
				table.insert(currentRecord,{
					pos = hrp.Position,
					wait = 0.15
				})
			end
		end
		task.wait(0.15)
	end
end)

-- ================= PLAY =================
local function playTrack(data)
	if #data == 0 or playing then return end
	playing = true
	local hum = getChar():WaitForChild("Humanoid")
	hum.WalkSpeed = speed
	notify("Play | Speed "..speed)

	repeat
		for _,v in ipairs(data) do
			if not playing then break end
			hum:MoveTo(v.pos)
			hum.MoveToFinished:Wait()
			task.wait(v.wait)
		end
	until not loopPlay or not playing

	hum.WalkSpeed = 16
	playing = false
end

-- ================= BUTTON LOGIC =================
btnRecord.MouseButton1Click:Connect(function()
	currentRecord = {}
	recording = true
	paused = false
	canSave = false
	notify("Record dimulai")
end)

btnPause.MouseButton1Click:Connect(function()
	if recording then
		paused = not paused
		notify(paused and "Record di-pause" or "Record dilanjutkan")
	end
end)

btnStop.MouseButton1Click:Connect(function()
	if recording then
		recording = false
		paused = false
		canSave = true
		notify("Record dihentikan")
	end
end)

btnPlay.MouseButton1Click:Connect(function()
	task.spawn(function()
		playTrack(currentRecord)
	end)
end)

btnLoop.MouseButton1Click:Connect(function()
	loopPlay = not loopPlay
	btnLoop.Text = loopPlay and "Loop : ON" or "Loop : OFF"
	notify("Loop "..(loopPlay and "ON" or "OFF"))
end)

btnSave.MouseButton1Click:Connect(function()
	if canSave and #currentRecord > 0 then
		local rec = currentRecord
		table.insert(records, rec)

		local b = Instance.new("TextButton", list)
		b.Size = UDim2.new(1,0,0,32)
		b.Text = "Record "..#records
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = Color3.fromRGB(20,20,20)
		b.BackgroundTransparency = 0.2
		b.Font = Enum.Font.Gotham
		b.TextScaled = true
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

		b.MouseButton1Click:Connect(function()
			task.spawn(function()
				playTrack(rec)
			end)
		end)

		list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
		canSave = false
		notify("Record disimpan")
	end
end)

plus.MouseButton1Click:Connect(function()
	speed += 1
	spdTxt.Text = "Speed : "..speed
	notify("Speed "..speed)
end)

minus.MouseButton1Click:Connect(function()
	speed = math.max(5, speed-1)
	spdTxt.Text = "Speed : "..speed
	notify("Speed "..speed)
end)

btnClose.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

btnMin.MouseButton1Click:Connect(function()
	main.Visible = false
	local icon = Instance.new("TextButton", gui)
	icon.Size = UDim2.new(0,50,0,50)
	icon.Position = UDim2.new(0.02,0,0.5,0)
	icon.Text = "TS"
	icon.TextColor3 = Color3.new(1,1,1)
	icon.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
	icon.MouseButton1Click:Connect(function()
		main.Visible = true
		icon:Destroy()
	end)
end)
