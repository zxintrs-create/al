--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 1/3
-- LOCAL SCRIPT ONLY
--========================================================--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")


--========================================================--
-- CHARACTER UPDATE
--========================================================--

LocalPlayer.CharacterAdded:Connect(function(char)

	Character = char
	RootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")

end)



--========================================================--
-- DATA
--========================================================--

local RecordData = {}

local Recording = false
local Playing = false

local SafePointIndex = nil

local RecordStart = 0
local RecordTimer = 0

local RECORD_RATE = 60



--========================================================--
-- GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KnightXOzAutoWalk"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")


local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,220,0,300)
Main.Position = UDim2.new(0,20,0.5,-150)
Main.BackgroundTransparency = 0.2
Main.Parent = ScreenGui



local function CreateButton(text,pos)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(0,200,0,40)
	Button.Position = UDim2.new(0,10,0,pos)

	Button.Text = text
	Button.TextScaled = true

	Button.Parent = Main

	return Button

end



local RecordButton = CreateButton("RECORD",10)
local StopButton = CreateButton("STOP",60)
local PlayButton = CreateButton("PLAY",110)
local RollbackButton = CreateButton("ROLLBACK",160)
local SaveButton = CreateButton("SAVE",210)
local LoadButton = CreateButton("LOAD",260)



--========================================================--
-- VISUAL LINE
--========================================================--

local LineFolder = Instance.new("Folder")
LineFolder.Name = "KnightXOz_Record_Line"
LineFolder.Parent = workspace


local LastPoint = nil



local function ClearLine()

	for _,obj in ipairs(LineFolder:GetChildren()) do
		obj:Destroy()
	end

	LastPoint = nil

end



local function CreateLine(position)

	local Point = Instance.new("Part")

	Point.Name = "Node"
	Point.Size = Vector3.new(0.05,0.05,0.05)

	Point.Anchored = true
	Point.CanCollide = false
	Point.Transparency = 1

	Point.Position = position
	Point.Parent = LineFolder



	if LastPoint then

		local A = Instance.new("Attachment")
		A.Parent = LastPoint


		local B = Instance.new("Attachment")
		B.Parent = Point


		local Beam = Instance.new("Beam")

		Beam.Attachment0 = A
		Beam.Attachment1 = B

		Beam.Width0 = 0.1
		Beam.Width1 = 0.1

		Beam.FaceCamera = true

		Beam.Parent = Point

	end


	LastPoint = Point

end



--========================================================--
-- SAFE POINT
--========================================================--

local function CheckSafe()

	if Humanoid.FloorMaterial == Enum.Material.Air then
		return false
	end


	local State = Humanoid:GetState()


	if State == Enum.HumanoidStateType.Freefall then
		return false
	end


	return true

end



--========================================================--
-- RECORD
--========================================================--

local function CaptureFrame()


	local FrameData = {

		Time = os.clock() - RecordStart,

		CFrame = RootPart.CFrame,

		Position = RootPart.Position,

		MoveDirection = Humanoid.MoveDirection,

		Velocity = RootPart.AssemblyLinearVelocity,

		State = Humanoid:GetState(),

		WalkSpeed = Humanoid.WalkSpeed,

		Safe = CheckSafe()

	}



	table.insert(
		RecordData,
		FrameData
	)



	CreateLine(
		FrameData.Position
	)



	if FrameData.Safe then

		SafePointIndex = #RecordData

	end

end



--========================================================--
-- RECORD CONTROL
--========================================================--

local function StartRecord()

	table.clear(RecordData)

	ClearLine()

	SafePointIndex = nil

	Recording = true

	RecordStart = os.clock()

end



local function StopRecord()

	Recording = false

end



RecordButton.MouseButton1Click:Connect(StartRecord)

StopButton.MouseButton1Click:Connect(StopRecord)



--========================================================--
-- RECORD LOOP
--========================================================--

RunService.Heartbeat:Connect(function(dt)

	if Recording then

		RecordTimer += dt


		if RecordTimer >= 1 / RECORD_RATE then

			RecordTimer = 0

			CaptureFrame()

		end

	end

end)



--========================================================--
-- OUTPUT
--========================================================--

print("I'M KNIGHTXOz")

--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 2/3
-- PLAYBACK ENGINE
--========================================================--


local PlaybackConnection = nil

local PlaybackIndex = 1



--========================================================--
-- STOP PLAY
--========================================================--

local function StopPlayback()

	Playing = false


	if PlaybackConnection then

		PlaybackConnection:Disconnect()
		PlaybackConnection = nil

	end


	if Humanoid then

		Humanoid:Move(
			Vector3.zero,
			false
		)

	end

end



--========================================================--
-- MOVE TO RECORDED FRAME
--========================================================--

local function FollowFrame(frame)

	if not frame then
		return
	end


	local Direction =
		frame.Position - RootPart.Position


	local Distance =
		Direction.Magnitude



	if Distance > 1 then


		Humanoid:Move(
			Direction.Unit,
			false
		)


	else


		Humanoid:Move(
			Vector3.zero,
			false
		)


	end



	if frame.WalkSpeed then

		Humanoid.WalkSpeed =
			frame.WalkSpeed

	end

end



--========================================================--
-- ROTATE FOLLOW
--========================================================--

local function FollowRotation(frame)

	if not frame then
		return
	end


	local Look =
		frame.CFrame.LookVector



	local Current =
		RootPart.CFrame.LookVector



	local Smooth =
		Current:Lerp(
			Look,
			0.15
		)



	RootPart.CFrame =
		CFrame.lookAt(
			RootPart.Position,
			RootPart.Position + Smooth
		)

end



--========================================================--
-- JUMP FOLLOW
--========================================================--

local function FollowJump(frame)

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



--========================================================--
-- START PLAYBACK
--========================================================--

local function StartPlayback()


	if #RecordData < 2 then
		return
	end



	StopPlayback()


	Playing = true

	PlaybackIndex = 1



	PlaybackConnection =
	RunService.Heartbeat:Connect(function()


		if not Playing then
			return
		end



		local FrameData =
			RecordData[PlaybackIndex]



		if not FrameData then

			StopPlayback()

			return

		end



		FollowFrame(
			FrameData
		)


		FollowRotation(
			FrameData
		)


		FollowJump(
			FrameData
		)



		PlaybackIndex += 1



		if PlaybackIndex > #RecordData then

			StopPlayback()

		end


	end)


end



--========================================================--
-- PLAY BUTTON
--========================================================--

PlayButton.MouseButton1Click:Connect(function()

	StartPlayback()

end)
		
		--========================================================--
-- AUTO WALK RECORD SYSTEM
-- PART 3/3
-- ROLLBACK + SAVE LOAD
--========================================================--


local SavedData = {}



--========================================================--
-- ROLLBACK SYSTEM
--========================================================--

local function RemoveWrongTimeline()


	if not SafePointIndex then
		return
	end



	while #RecordData > SafePointIndex do

		table.remove(
			RecordData
		)

	end


end



local function RefreshLine()


	for _,obj in ipairs(LineFolder:GetChildren()) do

		obj:Destroy()

	end



	LastPoint = nil



	for _,frame in ipairs(RecordData) do

		CreateLine(
			frame.Position
		)

	end


end



local function Rollback()


	StopPlayback()


	RemoveWrongTimeline()


	RefreshLine()



	local SafeFrame =
		RecordData[#RecordData]



	if SafeFrame and RootPart then


		RootPart.CFrame =
			SafeFrame.CFrame


	end

end



--========================================================--
-- SAVE SYSTEM
--========================================================--

local function CopyData()


	local Copy = {}


	for i,frame in ipairs(RecordData) do


		Copy[i] = frame


	end



	return Copy

end



local function SaveRecord()


	SavedData =
		CopyData()


end



local function LoadRecord()


	if #SavedData == 0 then
		return
	end



	table.clear(
		RecordData
	)



	for i,frame in ipairs(SavedData) do


		RecordData[i] =
			frame


	end



	RefreshLine()

end



--========================================================--
-- BUTTON CONNECTION
--========================================================--

RollbackButton.MouseButton1Click:Connect(function()

	Rollback()

end)



SaveButton.MouseButton1Click:Connect(function()

	SaveRecord()

end)



LoadButton.MouseButton1Click:Connect(function()

	LoadRecord()

end)



--========================================================--
-- FINAL CLEANUP
--========================================================--

UserInputService.InputBegan:Connect(function(input,gp)

	if gp then
		return
	end



	if input.KeyCode == Enum.KeyCode.X then

		StopPlayback()

	end

end)
		
