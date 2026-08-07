--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 1/3
-- LOCAL SCRIPT ONLY
-- ALDO KNIGHTXOz
--========================================================--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")


LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	RootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
end)


-- DATA

local RecordData = {}
local SavedData = {}

local Recording = false
local Playing = false

local SafePointIndex = nil
local CutIndex = 1

local RecordStart = 0
local RecordTimer = 0

local RECORD_RATE = 60



-- GUI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ALDO_KNIGHTXOz_AutoWalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui


local OpenMenu = Instance.new("TextButton")
OpenMenu.Size = UDim2.new(0,70,0,35)
OpenMenu.Position = UDim2.new(0,20,0.5,-220)
OpenMenu.Text = "MENU"
OpenMenu.TextScaled = true
OpenMenu.Parent = ScreenGui


local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,260,0,430)
Main.Position = UDim2.new(0.5,-130,0.5,-215)
Main.Visible = false
Main.Parent = ScreenGui



local function AddUIEffect(obj)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Parent = obj


	local gradient = Instance.new("UIGradient")
	gradient.Parent = obj


	task.spawn(function()
		while gradient.Parent do
			gradient.Rotation += 2
			task.wait(0.03)
		end
	end)

end


AddUIEffect(OpenMenu)
AddUIEffect(Main)



local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.BackgroundTransparency = 1
Title.Text = "ALDO KNIGHTXOz"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

AddUIEffect(Title)



local function CreateButton(text,y)

	local b = Instance.new("TextButton")

	b.Size = UDim2.new(0,220,0,40)
	b.Position = UDim2.new(0,20,0,y)
	b.Text = text
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.Parent = Main

	AddUIEffect(b)

	return b

end


local RecordButton = CreateButton("RECORD",70)
local StopButton = CreateButton("STOP",120)
local PlayButton = CreateButton("PLAY",170)
local RollbackButton = CreateButton("ROLLBACK",220)
local BackButton = CreateButton("<<",270)
local ForwardButton = CreateButton(">>",320)
local CutButton = CreateButton("CUT",370)



OpenMenu.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)


UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.O then
		Main.Visible = not Main.Visible
	end
end)



-- VISUAL LINE

local LineFolder = Instance.new("Folder")
LineFolder.Name = "ALDO_Record_Line"
LineFolder.Parent = workspace


local LastPoint



local function ClearLine()

	for _,v in ipairs(LineFolder:GetChildren()) do
		v:Destroy()
	end

	LastPoint = nil

end



local function CreateLine(pos)

	local p = Instance.new("Part")

	p.Size = Vector3.new(0.05,0.05,0.05)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.Position = pos
	p.Parent = LineFolder


	if LastPoint then

		local a = Instance.new("Attachment")
		a.Parent = LastPoint

		local b = Instance.new("Attachment")
		b.Parent = p


		local beam = Instance.new("Beam")

		beam.Attachment0 = a
		beam.Attachment1 = b

		beam.Width0 = 0.12
		beam.Width1 = 0.12

		beam.FaceCamera = true

		beam.Parent = p

	end


	LastPoint = p

end



-- RECORD

local function IsSafe()

	if Humanoid.FloorMaterial == Enum.Material.Air then
		return false
	end

	local state = Humanoid:GetState()

	if state == Enum.HumanoidStateType.Freefall then
		return false
	end

	return true

end



local function Capture()

	local frame = {

		Time = os.clock()-RecordStart,

		CFrame = RootPart.CFrame,

		Position = RootPart.Position,

		MoveDirection = Humanoid.MoveDirection,

		Velocity = RootPart.AssemblyLinearVelocity,

		State = Humanoid:GetState(),

		WalkSpeed = Humanoid.WalkSpeed,

		Safe = IsSafe()

	}


	table.insert(RecordData,frame)


	CreateLine(frame.Position)


	if frame.Safe then
		SafePointIndex = #RecordData
	end

end



local function StartRecord()

	table.clear(RecordData)

	ClearLine()

	SafePointIndex = nil

	CutIndex = 1

	Recording = true

	RecordStart = os.clock()

end



local function StopRecord()

	Recording = false

end



RecordButton.MouseButton1Click:Connect(StartRecord)
StopButton.MouseButton1Click:Connect(StopRecord)



RunService.Heartbeat:Connect(function(dt)

	if Recording then

		RecordTimer += dt

		if RecordTimer >= 1/RECORD_RATE then

			RecordTimer = 0

			Capture()

		end

	end

end)



print("I'M KNIGHTXOz")
	
	--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 2/3
-- PLAYBACK ENGINE
--========================================================--


local PlaybackConnection = nil
local PlaybackIndex = 1



local function StopPlayback()

	Playing = false

	if PlaybackConnection then
		PlaybackConnection:Disconnect()
		PlaybackConnection = nil
	end

	Humanoid:Move(
		Vector3.zero,
		false
	)

end



local function SmoothMove(target)

	local direction =
		target - RootPart.Position


	local distance =
		direction.Magnitude


	if distance > 0.8 then

		Humanoid:Move(
			direction.Unit,
			false
		)

	else

		Humanoid:Move(
			Vector3.zero,
			false
		)

	end

end



local function SmoothRotate(frame)

	if not frame then
		return
	end


	local look =
		frame.CFrame.LookVector


	local current =
		RootPart.CFrame.LookVector


	local result =
		current:Lerp(
			look,
			0.2
		)


	RootPart.CFrame =
		CFrame.lookAt(
			RootPart.Position,
			RootPart.Position + result
		)

end



local function SyncJump(frame)

	if not frame then
		return
	end


	if frame.State ==
		Enum.HumanoidStateType.Jumping then


		if Humanoid.FloorMaterial ~= Enum.Material.Air then

			Humanoid:ChangeState(
				Enum.HumanoidStateType.Jumping
			)

		end

	end

end



local function StartPlayback()

	if #RecordData < 2 then
		return
	end



	StopPlayback()



	local first =
		RecordData[1]


	if first then

		RootPart.CFrame =
			first.CFrame

	end



	PlaybackIndex = 1

	Playing = true



	PlaybackConnection =
	RunService.Heartbeat:Connect(function()


		if not Playing then
			return
		end



		local current =
			RecordData[PlaybackIndex]


		local nextFrame =
			RecordData[PlaybackIndex + 1]



		if not current or not nextFrame then

			StopPlayback()

			return

		end



		SmoothMove(
			nextFrame.Position
		)


		SmoothRotate(
			current
		)


		SyncJump(
			current
		)



		if
			(RootPart.Position -
			nextFrame.Position).Magnitude
			< 1
		then

			PlaybackIndex += 1

		end



	end)

end



PlayButton.MouseButton1Click:Connect(function()

	StartPlayback()

end)



--========================================================--
-- TIMELINE CUT CONTROL
--========================================================--


local function UpdateCut()

	if CutIndex < 1 then
		CutIndex = 1
	end


	if CutIndex > #RecordData then
		CutIndex = #RecordData
	end

end



BackButton.MouseButton1Click:Connect(function()

	CutIndex -= 10

	UpdateCut()

end)



ForwardButton.MouseButton1Click:Connect(function()

	CutIndex += 10

	UpdateCut()

end)
		
		--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 3/3
-- ROLLBACK + CUT + SAVE LOAD
--========================================================--


--========================================================--
-- REFRESH VISUAL LINE
--========================================================--

local function RefreshLine()

	ClearLine()


	for _,frame in ipairs(RecordData) do

		CreateLine(
			frame.Position
		)

	end

end



--========================================================--
-- CUT TIMELINE
--========================================================--

local function ApplyCut()


	if #RecordData == 0 then
		return
	end



	local NewData = {}


	for i = 1,CutIndex do

		table.insert(
			NewData,
			RecordData[i]
		)

	end



	for i = CutIndex + 1,#RecordData do

		if RecordData[i].Safe then

			table.insert(
				NewData,
				RecordData[i]
			)

			break

		end

	end



	RecordData = NewData



	SafePointIndex = nil


	for i,frame in ipairs(RecordData) do

		if frame.Safe then

			SafePointIndex = i

		end

	end



	RefreshLine()

end



CutButton.MouseButton1Click:Connect(function()

	ApplyCut()

end)



--========================================================--
-- ROLLBACK SMART
--========================================================--

RollbackButton.MouseButton1Click:Connect(function()


	StopPlayback()



	if SafePointIndex then


		local safe =
			RecordData[SafePointIndex]


		if safe then


			RootPart.CFrame =
				safe.CFrame


			CutIndex =
				SafePointIndex


			ApplyCut()


		end


	end


end)



--========================================================--
-- SAVE LOAD
--========================================================--

SaveButton.MouseButton1Click:Connect(function()


	table.clear(
		SavedData
	)



	for i,frame in ipairs(RecordData) do


		SavedData[i] = frame


	end


end)



LoadButton.MouseButton1Click:Connect(function()


	if #SavedData == 0 then
		return
	end



	table.clear(
		RecordData
	)



	for i,frame in ipairs(SavedData) do


		RecordData[i] = frame


	end



	RefreshLine()


end)



--========================================================--
-- CONTINUE RECORD AFTER CUT
--========================================================--

local OldRecord = StartRecord



StartRecord = function()


	if #RecordData > 0 then


		local last =
			RecordData[#RecordData]


		if last then


			RootPart.CFrame =
				last.CFrame


		end


	end



	Recording = true

	RecordStart = os.clock()


end



RecordButton.MouseButton1Click:Connect(function()

	StartRecord()

end)



--========================================================--
-- REMOVE MENU WITH ESC
--========================================================--

UserInputService.InputBegan:Connect(function(input,gp)

	if gp then
		return
	end


	if input.KeyCode == Enum.KeyCode.Escape then

		Main.Visible = false

	end

end)
		
		
