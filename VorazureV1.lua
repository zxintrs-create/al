local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")

local FrameworkV8 = {}
FrameworkV8.RecordedData = {}
FrameworkV8.IsRecording = false
FrameworkV8.IsPlaying = false
FrameworkV8.PlaybackConnection = nil
FrameworkV8.RecordConnection = nil
FrameworkV8.LoadedTracks = {}

-- ==========================================
-- 1. UTILITY: REAL LINE BOUNDARY CLAMPING
-- ==========================================
local function ClampCFrameToLineSegment(targetCF, lineStart, lineEnd)
	local targetPos = targetCF.Position
	local lineVec = lineEnd - lineStart
	local lineLenSq = lineVec.Magnitude ^ 2
	
	if lineLenSq == 0 then
		return CFrame.new(lineStart) * (targetCF - targetPos)
	end
	
	local t = math.clamp((targetPos - lineStart):Dot(lineVec) / lineLenSq, 0, 1)
	local clampedPos = lineStart + (t * lineVec)
	
	return CFrame.new(clampedPos) * (targetCF - targetPos)
end

-- ==========================================
-- 2. ANIMATION HELPER FUNCTIONS
-- ==========================================
local function ApplyRecordedAnimations(animDataList)
	for _, animInfo in ipairs(animDataList) do
		local track = FrameworkV8.LoadedTracks[animInfo.AnimationId]
		if not track then
			local animObject = Instance.new("Animation")
			animObject.AnimationId = animInfo.AnimationId
			track = Animator:LoadAnimation(animObject)
			FrameworkV8.LoadedTracks[animInfo.AnimationId] = track
		end
		
		if not track.IsPlaying then
			track:Play(0.1, animInfo.Weight, animInfo.Speed)
		end
		
		if math.abs(track.TimePosition - animInfo.TimePosition) > 0.05 then
			track.TimePosition = animInfo.TimePosition
		end
		track:AdjustSpeed(animInfo.Speed)
	end
end

local function ClearActiveAnimations()
	for _, track in pairs(FrameworkV8.LoadedTracks) do
		if track.IsPlaying then
			track:Stop(0.1)
		end
	end
end

-- ==========================================
-- 3. RECORD SYSTEM
-- ==========================================
function FrameworkV8.StartRecording()
	FrameworkV8.RecordedData = {}
	FrameworkV8.IsRecording = true
	local startTime = os.clock()
	
	FrameworkV8.RecordConnection = RunService.Heartbeat:Connect(function()
		if not FrameworkV8.IsRecording then return end
		
		local activeAnimations = {}
		for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
			table.insert(activeAnimations, {
				AnimationId = track.Animation.AnimationId,
				TimePosition = track.TimePosition,
				Speed = track.Speed,
				Weight = track.WeightTarget
			})
		end
		
		table.insert(FrameworkV8.RecordedData, {
			Timestamp = os.clock() - startTime,
			CFrame = RootPart.CFrame,
			Velocity = RootPart.AssemblyLinearVelocity,
			RotVelocity = RootPart.AssemblyAngularVelocity,
			WalkSpeed = Humanoid.WalkSpeed,
			JumpState = (Humanoid:GetState() == Enum.HumanoidStateType.Jumping),
			Animations = activeAnimations
		})
	end)
end

function FrameworkV8.StopRecording()
	FrameworkV8.IsRecording = false
	if FrameworkV8.RecordConnection then
		FrameworkV8.RecordConnection:Disconnect()
		FrameworkV8.RecordConnection = nil
	end
end

-- ==========================================
-- 4. PLAYBACK SYSTEM
-- ==========================================
function FrameworkV8.StartPlayback(lineStartPoint, lineEndPoint)
	if #FrameworkV8.RecordedData == 0 then return end
	
	FrameworkV8.IsPlaying = true
	local playbackStartTime = os.clock()
	local currentIndex = 1
	local totalNodes = #FrameworkV8.RecordedData
	
	RootPart.Anchored = true
	
	FrameworkV8.PlaybackConnection = RunService.RenderStepped:Connect(function()
		if not FrameworkV8.IsPlaying then return end
		
		local elapsedTime = os.clock() - playbackStartTime
		
		while currentIndex < totalNodes and FrameworkV8.RecordedData[currentIndex + 1].Timestamp <= elapsedTime do
			currentIndex = currentIndex + 1
		end
		
		local currentFrame = FrameworkV8.RecordedData[currentIndex]
		local nextFrame = FrameworkV8.RecordedData[currentIndex + 1]
		
		local finalCFrame = currentFrame.CFrame
		
		if nextFrame then
			local timeDiff = nextFrame.Timestamp - currentFrame.Timestamp
			local alpha = (timeDiff > 0) and math.clamp((elapsedTime - currentFrame.Timestamp) / timeDiff, 0, 1) or 0
			finalCFrame = currentFrame.CFrame:Lerp(nextFrame.CFrame, alpha)
		end
		
		if lineStartPoint and lineEndPoint then
			finalCFrame = ClampCFrameToLineSegment(finalCFrame, lineStartPoint, lineEndPoint)
		end
		
		RootPart.CFrame = finalCFrame
		RootPart.AssemblyLinearVelocity = currentFrame.Velocity
		RootPart.AssemblyAngularVelocity = currentFrame.RotVelocity
		Humanoid.WalkSpeed = currentFrame.WalkSpeed
		
		if currentFrame.Animations then
			ApplyRecordedAnimations(currentFrame.Animations)
		end
		
		if currentIndex >= totalNodes and elapsedTime >= FrameworkV8.RecordedData[totalNodes].Timestamp then
			FrameworkV8.StopPlayback()
		end
	end)
end

function FrameworkV8.StopPlayback()
	FrameworkV8.IsPlaying = false
	if FrameworkV8.PlaybackConnection then
		FrameworkV8.PlaybackConnection:Disconnect()
		FrameworkV8.PlaybackConnection = nil
	end
	
	ClearActiveAnimations()
	RootPart.Anchored = false
end

return FrameworkV8
