-- [[ ALDO KNIGHTXORZ V4.38 ULTIMATE PRODUCTION MASTER ]] --
-- FULL SCRIPT
-- Recording + Playback + Auto Walk + Pause/Resume + Cut
-- File 1-5 + Save/Load + Route Visualization
-- Mobile Activated Support + Character Respawn Safety

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- CLEANUP PREVIOUS VERSION
----------------------------------------------------------------

pcall(function()
	if _G.AldoKnightXorzV438_Cleanup then
		_G.AldoKnightXorzV438_Cleanup()
	end
end)

pcall(function()
	RunService:UnbindFromRenderStep("AldoKnightXorzV438_Record")
	RunService:UnbindFromRenderStep("AldoKnightXorzV438_Playback")
end)

----------------------------------------------------------------
-- CHARACTER
----------------------------------------------------------------

local Character
local RootPart
local Humanoid

local stopPlayback

local function setupCharacter(char)
	if stopPlayback then
		pcall(function()
			stopPlayback(true)
		end)
	end

	Character = char

	Humanoid = char:WaitForChild("Humanoid", 10)
	RootPart = char:WaitForChild("HumanoidRootPart", 10)

	if Humanoid then
		Humanoid.AutoRotate = true
	end
end

if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end

----------------------------------------------------------------
-- CONNECTION STORAGE
----------------------------------------------------------------

local currentConnections = {}

local function addConnection(connection)
	if connection then
		table.insert(currentConnections, connection)
	end
	return connection
end

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------

local CFG = {
	NodeInterval = 1 / 30,
	MinDistance = 0.035,

	LineColor = Color3.fromRGB(0, 255, 255),
	AccentColor = Color3.fromRGB(170, 0, 255),

	ButtonColor = Color3.fromRGB(30, 30, 40),
	ButtonHover = Color3.fromRGB(45, 45, 60),

	PlaybackPositionSnap = 3,
	PlaybackSmooth = 18,

	RouteFolderName = "KNIGHTXORZ_ROUTE_V438",

	SaveFileName = "ALDO_KNIGHTXORZ_V4_38.json"
}

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local state = {
	isRecording = false,
	isPlaying = false,
	isPaused = false,
	isAutoWalk = false,

	playbackID = 0,

	timeline = {},
	visualNodes = {},

	lineVisible = true,

	selectedFile = 1,
	savedFiles = {},

	startTime = 0,
	lastRecordTime = 0,

	lastJumpState = false,

	cutStart = 1,
	cutEnd = 1,

	originalWalkSpeed = 16,

	memoryStorage = {}
}

----------------------------------------------------------------
-- CHARACTER CONNECTION
----------------------------------------------------------------

addConnection(
	LocalPlayer.CharacterAdded:Connect(function(char)
		setupCharacter(char)
	end)
)

----------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------

local function isCharacterAlive()
	return Character
		and Character.Parent
		and RootPart
		and RootPart.Parent
		and Humanoid
		and Humanoid.Parent
		and Humanoid.Health > 0
end

local function getNow()
	return os.clock()
end

----------------------------------------------------------------
-- TIMELINE
----------------------------------------------------------------

local function normalizeTimeline(timeline)
	if not timeline or #timeline == 0 then
		return timeline
	end

	local base = timeline[1].Timestamp or 0

	for _, node in ipairs(timeline) do
		node.RelativeTimestamp = math.max(
			0,
			(node.Timestamp or base) - base
		)
	end

	return timeline
end

local function cloneTimeline(source)
	local result = {}

	for _, node in ipairs(source or {}) do
		table.insert(result, {
			CFrame = node.CFrame,
			Position = node.Position,

			Timestamp = node.Timestamp or 0,
			RelativeTimestamp = node.RelativeTimestamp or 0,

			Jump = node.Jump == true,

			WalkSpeed = node.WalkSpeed or 16,

			HumanoidState = node.HumanoidState,

			MovementDirection = node.MovementDirection
				or Vector3.zero
		})
	end

	return result
end

----------------------------------------------------------------
-- ROUTE FOLDER
----------------------------------------------------------------

local function getRouteFolder()
	local folder = workspace:FindFirstChild(CFG.RouteFolderName)

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = CFG.RouteFolderName
		folder.Parent = workspace
	end

	return folder
end

----------------------------------------------------------------
-- CLEAR VISUAL ROUTE
----------------------------------------------------------------

local function clearVisuals()
	for _, obj in ipairs(state.visualNodes) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end

	state.visualNodes = {}

	local folder = workspace:FindFirstChild(CFG.RouteFolderName)

	if folder then
		folder:ClearAllChildren()
	end
end

----------------------------------------------------------------
-- CREATE ROUTE SEGMENT
----------------------------------------------------------------

local function createRouteSegment(p1, p2)
	if not p1 or not p2 then
		return
	end

	local offset = p2 - p1
	local distance = offset.Magnitude

	if distance < 0.035 then
		return
	end

	local folder = getRouteFolder()

	------------------------------------------------------------
	-- MAIN LINE
	------------------------------------------------------------

	local line = Instance.new("Part")

	line.Name = "VisualNode"
	line.Anchored = true
	line.CanCollide = false
	line.CanTouch = false
	line.CanQuery = false
	line.CastShadow = false
	line.Locked = true

	line.Material = Enum.Material.Neon
	line.Color = CFG.LineColor

	line.Size = Vector3.new(
		0.08,
		0.08,
		distance
	)

	line.CFrame = CFrame.lookAt(
		p1:Lerp(p2, 0.5),
		p2
	)

	line.Transparency = state.lineVisible and 0 or 1

	line.Parent = folder

	table.insert(state.visualNodes, line)

	------------------------------------------------------------
	-- GROUND MARKER
	------------------------------------------------------------

	local params = RaycastParams.new()

	params.FilterType = Enum.RaycastFilterType.Exclude

	local filter = {folder}

	if Character then
		table.insert(filter, Character)
	end

	params.FilterDescendantsInstances = filter
	params.IgnoreWater = true

	local middle = p1:Lerp(p2, 0.5)

	local ray = workspace:Raycast(
		middle + Vector3.new(0, 6, 0),
		Vector3.new(0, -20, 0),
		params
	)

	if ray and ray.Position then
		local ground = ray.Position + Vector3.new(0, 0.025, 0)

		local marker = Instance.new("Part")

		marker.Name = "GroundMarker"
		marker.Anchored = true
		marker.CanCollide = false
		marker.CanTouch = false
		marker.CanQuery = false
		marker.CastShadow = false
		marker.Locked = true

		marker.Material = Enum.Material.SmoothPlastic
		marker.Color = CFG.LineColor

		marker.Size = Vector3.new(
			0.6,
			0.03,
			distance
		)

		marker.CFrame = CFrame.lookAt(
			ground,
			ground + offset.Unit
		)

		marker.Transparency =
			state.lineVisible and 0.3 or 1

		marker.Parent = folder

		table.insert(state.visualNodes, marker)
	end
end

----------------------------------------------------------------
-- REBUILD ROUTE
----------------------------------------------------------------

local function rebuildRoute()
	clearVisuals()

	if #state.timeline < 2 then
		return
	end

	for i = 2, #state.timeline do
		local previous = state.timeline[i - 1]
		local current = state.timeline[i]

		if previous.Position and current.Position then
			createRouteSegment(
				previous.Position,
				current.Position
			)
		end
	end
end

----------------------------------------------------------------
-- SAVE
----------------------------------------------------------------

local function saveToDisk()
	local exportData = {}

	for slot, data in pairs(state.savedFiles) do
		if data and data.timeline then

			local encoded = {}

			for _, node in ipairs(data.timeline) do
				if node.CFrame and node.Position then

					local components = {
						node.CFrame:GetComponents()
					}

					local rounded = {}

					for _, value in ipairs(components) do
						table.insert(
							rounded,
							math.round(value * 1000) / 1000
						)
					end

					table.insert(encoded, {
						C = rounded,

						P = {
							math.round(node.Position.X * 100) / 100,
							math.round(node.Position.Y * 100) / 100,
							math.round(node.Position.Z * 100) / 100
						},

						T = math.round(
							(node.Timestamp or 0) * 1000
						) / 1000,

						J = node.Jump == true,

						W = node.WalkSpeed or 16,

						S = tostring(
							node.HumanoidState
								or Enum.HumanoidStateType.Running
						),

						D = node.MovementDirection
							and {
								node.MovementDirection.X,
								node.MovementDirection.Y,
								node.MovementDirection.Z
							}
							or {
								0,
								0,
								0
							}
					})
				end
			end

			exportData[tostring(slot)] = {
				timeline = encoded
			}
		end
	end

	state.memoryStorage = exportData

	------------------------------------------------------------
	-- OPTIONAL FILE API
	------------------------------------------------------------

	pcall(function()
		if typeof(writefile) == "function" then
			writefile(
				CFG.SaveFileName,
				HttpService:JSONEncode(exportData)
			)
		end
	end)
end

----------------------------------------------------------------
-- LOAD
----------------------------------------------------------------

local function loadFromDisk()
	local decoded

	------------------------------------------------------------
	-- OPTIONAL FILE API
	------------------------------------------------------------

	pcall(function()
		if typeof(readfile) == "function" then

			local success, content = pcall(function()
				return readfile(CFG.SaveFileName)
			end)

			if success and content then

				local successDecode, result =
					pcall(function()
						return HttpService:JSONDecode(content)
					end)

				if successDecode then
					decoded = result
				end
			end
		end
	end)

	------------------------------------------------------------
	-- MEMORY FALLBACK
	------------------------------------------------------------

	if not decoded
		and state.memoryStorage
		and next(state.memoryStorage) then

		decoded = state.memoryStorage
	end

	if type(decoded) ~= "table" then
		return
	end

	------------------------------------------------------------
	-- DECODE
	------------------------------------------------------------

	for slot, data in pairs(decoded) do

		if data and type(data.timeline) == "table" then

			local timeline = {}

			for _, node in ipairs(data.timeline) do

				local cf
				local position

				if node.C
					and type(node.C) == "table"
					and #node.C == 12 then

					pcall(function()
						cf = CFrame.new(
							table.unpack(node.C)
						)
					end)

					if cf then
						position = cf.Position
					end

				elseif node.P
					and type(node.P) == "table"
					and #node.P == 3 then

					position = Vector3.new(
						node.P[1],
						node.P[2],
						node.P[3]
					)

					cf = CFrame.new(position)
				end

				if position and cf then

					local direction = Vector3.zero

					if node.D
						and type(node.D) == "table"
						and #node.D == 3 then

						direction = Vector3.new(
							node.D[1],
							node.D[2],
							node.D[3]
						)
					end

					table.insert(timeline, {

						CFrame = cf,

						Position = position,

						Timestamp = tonumber(node.T) or 0,

						RelativeTimestamp = 0,

						Jump = node.J == true,

						WalkSpeed =
							tonumber(node.W) or 16,

						HumanoidState =
							node.S,

						MovementDirection =
							direction
					})
				end
			end

			normalizeTimeline(timeline)

			state.savedFiles[
				tonumber(slot) or slot
			] = {
				timeline = timeline
			}
		end
	end
end

loadFromDisk()

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "AldoKnightXorzV438Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

----------------------------------------------------------------
-- OPEN BUTTON
----------------------------------------------------------------

local OpenMenu = Instance.new("ImageButton")

OpenMenu.Name = "OpenMenu"

OpenMenu.Size = UDim2.fromOffset(58, 58)

OpenMenu.Position =
	UDim2.new(
		0.05,
		0,
		0.5,
		0
	)

OpenMenu.BackgroundColor3 =
	Color3.fromRGB(15, 15, 20)

OpenMenu.BackgroundTransparency = 0.2

OpenMenu.BorderSizePixel = 0

OpenMenu.AutoButtonColor = false

OpenMenu.ZIndex = 20

OpenMenu.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")

OpenCorner.CornerRadius =
	UDim.new(0, 8)

OpenCorner.Parent = OpenMenu

local OpenStroke = Instance.new("UIStroke")

OpenStroke.Thickness = 2

OpenStroke.Color =
	Color3.fromRGB(255, 255, 255)

OpenStroke.Parent = OpenMenu

local IconImage = Instance.new("ImageLabel")

IconImage.Name = "Icon"

IconImage.Size =
	UDim2.new(
		0.8,
		0,
		0.8,
		0
	)

IconImage.Position =
	UDim2.new(
		0.1,
		0,
		0.1,
		0
	)

IconImage.BackgroundTransparency = 1

IconImage.Image =
	"rbxassetid://101640388423900"

IconImage.ZIndex = 21

IconImage.Parent = OpenMenu

----------------------------------------------------------------
-- MAIN FRAME
----------------------------------------------------------------

local MainFrame = Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Size =
	UDim2.fromOffset(550, 325)

MainFrame.Position =
	UDim2.new(
		0.5,
		-275,
		0.5,
		-162
	)

MainFrame.BackgroundColor3 =
	Color3.fromRGB(15, 15, 20)

MainFrame.BorderSizePixel = 0

MainFrame.Active = true

MainFrame.Visible = false

MainFrame.ZIndex = 5

MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0, 12)

MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")

MainStroke.Thickness = 2

MainStroke.Color =
	CFG.AccentColor

MainStroke.Parent = MainFrame

----------------------------------------------------------------
-- OPEN BUTTON DRAGGING
----------------------------------------------------------------

local openDragging = false
local openMoved = false
local openDragStart
local openStartPos

addConnection(
	OpenMenu.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			openDragging = true
			openMoved = false

			openDragStart = input.Position
			openStartPos = OpenMenu.Position
		end
	end)
)

addConnection(
	UserInputService.InputChanged:Connect(function(input)

		if not openDragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position - openDragStart

			if delta.Magnitude > 4 then

				openMoved = true

				OpenMenu.Position =
					UDim2.new(
						openStartPos.X.Scale,
						openStartPos.X.Offset + delta.X,

						openStartPos.Y.Scale,
						openStartPos.Y.Offset + delta.Y
					)
			end
		end
	end)
)

addConnection(
	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			openDragging = false
		end
	end)
)

addConnection(
	OpenMenu.Activated:Connect(function()

		if openMoved then
			openMoved = false
			return
		end

		MainFrame.Visible =
			not MainFrame.Visible
	end)
)

----------------------------------------------------------------
-- TITLE
----------------------------------------------------------------

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(1, 0, 0, 35)

Title.Text =
	"ALDO KNIGHTXORZ V4.38 ULTIMATE MASTER"

Title.TextColor3 =
	Color3.fromRGB(255, 255, 255)

Title.Font =
	Enum.Font.GothamBold

Title.TextSize = 14

Title.BackgroundTransparency = 1

Title.ZIndex = 6

Title.Parent = MainFrame

----------------------------------------------------------------
-- STATUS
----------------------------------------------------------------

local StatusLabel = Instance.new("TextLabel")

StatusLabel.Name =
	"StatusLabel"

StatusLabel.Size =
	UDim2.new(1, 0, 0, 25)

StatusLabel.Position =
	UDim2.new(0, 0, 0, 35)

StatusLabel.Text =
	"Status: IDLE | File: 1 | Cut: 1-1"

StatusLabel.TextColor3 =
	CFG.LineColor

StatusLabel.Font =
	Enum.Font.GothamBold

StatusLabel.TextSize = 12

StatusLabel.BackgroundTransparency = 1

StatusLabel.ZIndex = 6

StatusLabel.Parent = MainFrame

----------------------------------------------------------------
-- SCROLLING
----------------------------------------------------------------

local ScrollingContainer =
	Instance.new("ScrollingFrame")

ScrollingContainer.Size =
	UDim2.new(1, -20, 1, -75)

ScrollingContainer.Position =
	UDim2.new(0, 10, 0, 65)

ScrollingContainer.BackgroundTransparency = 1

ScrollingContainer.BorderSizePixel = 0

ScrollingContainer.ScrollBarThickness = 4

ScrollingContainer.ScrollBarImageColor3 =
	CFG.AccentColor

ScrollingContainer.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

ScrollingContainer.CanvasSize =
	UDim2.new(0, 0, 0, 0)

ScrollingContainer.ZIndex = 6

ScrollingContainer.Parent = MainFrame

local UIGrid =
	Instance.new("UIGridLayout")

UIGrid.CellSize =
	UDim2.fromOffset(120, 39)

UIGrid.CellPadding =
	UDim2.fromOffset(8, 8)

UIGrid.SortOrder =
	Enum.SortOrder.LayoutOrder

UIGrid.Parent = ScrollingContainer

----------------------------------------------------------------
-- STATUS UPDATE
----------------------------------------------------------------

local function updateStatus(text)

	if not StatusLabel
		or not StatusLabel.Parent then
		return
	end

	StatusLabel.Text =
		"Status: "
		.. tostring(text)
		.. " | File: "
		.. tostring(state.selectedFile)
		.. " | Cut: "
		.. tostring(state.cutStart)
		.. "-"
		.. tostring(state.cutEnd)
end

----------------------------------------------------------------
-- BUTTON
----------------------------------------------------------------

local function createButton(text, order, callback)

	local button =
		Instance.new("TextButton")

	button.Name =
		"Button_" .. tostring(order)

	button.Size =
		UDim2.fromOffset(120, 39)

	button.BackgroundColor3 =
		CFG.ButtonColor

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.fromRGB(230, 230, 230)

	button.Font =
		Enum.Font.GothamBold

	button.TextSize = 11

	button.AutoButtonColor = false

	button.LayoutOrder = order

	button.ZIndex = 8

	button.Parent =
		ScrollingContainer

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 6)

	corner.Parent = button

	local stroke =
		Instance.new("UIStroke")

	stroke.Thickness = 1

	stroke.Color =
		Color3.fromRGB(70, 70, 90)

	stroke.Parent = button

	addConnection(
		button.Activated:Connect(function()

			TweenService:Create(
				button,
				TweenInfo.new(
					0.08,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					BackgroundColor3 =
						CFG.AccentColor
				}
			):Play()

			task.defer(function()

				local success, err =
					pcall(callback)

				if not success then
					warn(
						"[ALDO KNIGHTXORZ] Button error:",
						err
					)
				end

				if button.Parent then
					TweenService:Create(
						button,
						TweenInfo.new(
							0.12,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							BackgroundColor3 =
								CFG.ButtonColor
						}
					):Play()
				end
			end)
		end)
	)

	return button
end

----------------------------------------------------------------
-- RECORD
----------------------------------------------------------------

pcall(function()
	RunService:UnbindFromRenderStep(
		"AldoKnightXorzV438_Record"
	)
end)

local function beginRecording()

	if not isCharacterAlive() then
		return
	end

	if state.isPlaying then
		stopPlayback(true)
	end

	state.isRecording = true

	state.timeline = {}

	state.startTime = getNow()
	state.lastRecordTime = 0

	state.lastJumpState = false

	state.cutStart = 1
	state.cutEnd = 1

	clearVisuals()

	updateStatus("RECORDING")
end

local function finishRecording()

	state.isRecording = false

	normalizeTimeline(
		state.timeline
	)

	state.cutStart = 1

	state.cutEnd =
		math.max(
			1,
			#state.timeline
		)

	rebuildRoute()

	updateStatus("IDLE")
end

RunService:BindToRenderStep(
	"AldoKnightXorzV438_Record",
	Enum.RenderPriority.Character.Value,
	function()

		if not state.isRecording then
			return
		end

		if not isCharacterAlive() then
			return
		end

		local now = getNow()

		if now - state.lastRecordTime
			< CFG.NodeInterval then
			return
		end

		state.lastRecordTime = now

		local cf =
			RootPart.CFrame

		local pos =
			cf.Position

		local humanoidState =
			Humanoid:GetState()

		local timestamp =
			now - state.startTime

		local jumping =
			humanoidState ==
			Enum.HumanoidStateType.Jumping
			or humanoidState ==
			Enum.HumanoidStateType.Freefall

		local jumpTrigger =
			jumping
			and not state.lastJumpState

		state.lastJumpState = jumping

		local movement =
			Humanoid.MoveDirection

		--------------------------------------------------------
		-- FIRST NODE
		--------------------------------------------------------

		if #state.timeline == 0 then

			table.insert(
				state.timeline,
				{
					CFrame = cf,
					Position = pos,

					Timestamp = timestamp,
					RelativeTimestamp = 0,

					Jump = jumpTrigger,

					WalkSpeed =
						Humanoid.WalkSpeed,

					HumanoidState =
						humanoidState,

					MovementDirection =
						movement
				}
			)

			state.cutStart = 1
			state.cutEnd = 1

			return
		end

		--------------------------------------------------------
		-- NEXT NODE
		--------------------------------------------------------

		local previous =
			state.timeline[#state.timeline]

		local distance =
			(pos - previous.Position).Magnitude

		local timeDifference =
			timestamp - previous.Timestamp

		local shouldRecord =
			distance >= CFG.MinDistance
			and timeDifference >= CFG.NodeInterval

		if jumpTrigger then
			shouldRecord = true
		end

		if not shouldRecord then
			return
		end

		createRouteSegment(
			previous.Position,
			pos
		)

		table.insert(
			state.timeline,
			{
				CFrame = cf,
				Position = pos,

				Timestamp = timestamp,
				RelativeTimestamp = 0,

				Jump = jumpTrigger,

				WalkSpeed =
					Humanoid.WalkSpeed,

				HumanoidState =
					humanoidState,

				MovementDirection =
					movement
			}
		)

		normalizeTimeline(
			state.timeline
		)

		state.cutEnd =
			#state.timeline
	end
)

----------------------------------------------------------------
-- STOP PLAYBACK
----------------------------------------------------------------

stopPlayback = function(manualStop)

	state.isPlaying = false
	state.isPaused = false

	state.playbackID =
		state.playbackID + 1

	if manualStop then
		state.isAutoWalk = false
	end

	pcall(function()
		RunService:UnbindFromRenderStep(
			"AldoKnightXorzV438_Playback"
		)
	end)

	if isCharacterAlive() then

		Humanoid.AutoRotate = true

		Humanoid:Move(
			Vector3.zero,
			true
		)

		Humanoid.WalkSpeed =
			state.originalWalkSpeed
	end

	updateStatus("IDLE")
end

----------------------------------------------------------------
-- PLAYBACK
----------------------------------------------------------------

local function executePlayback()

	if state.isRecording then
		return
	end

	if state.isPlaying then
		return
	end

	if not isCharacterAlive() then
		return
	end

	if #state.timeline < 2 then
		updateStatus("NO ROUTE")
		return
	end

	normalizeTimeline(
		state.timeline
	)

	state.isPlaying = true
	state.isPaused = false

	state.playbackID =
		state.playbackID + 1

	local playbackID =
		state.playbackID

	state.originalWalkSpeed =
		Humanoid.WalkSpeed

	local timeline =
		state.timeline

	local startPosition =
		timeline[1].Position

	local startCFrame =
		timeline[1].CFrame

	local playbackState =
		"WALK_TO_START"

	local currentIndex = 1

	local playbackStart = getNow()

	local pausedAt = 0

	local totalPaused = 0

	local jumpConsumed = {}

	local startTimeout =
		getNow() + 30

	local moveStarted = false

	updateStatus("WALKING TO START")

	pcall(function()
		RunService:UnbindFromRenderStep(
			"AldoKnightXorzV438_Playback"
		)
	end)

	RunService:BindToRenderStep(
		"AldoKnightXorzV438_Playback",
		Enum.RenderPriority.Character.Value - 1,
		function(dt)

			----------------------------------------------------
			-- VALIDATION
			----------------------------------------------------

			if not state.isPlaying
				or state.playbackID ~= playbackID
				or not isCharacterAlive() then

				stopPlayback(false)
				return
			end

			----------------------------------------------------
			-- PAUSE
			----------------------------------------------------

			if state.isPaused then

				if pausedAt == 0 then
					pausedAt = getNow()
				end

				Humanoid:Move(
					Vector3.zero,
					true
				)

				RootPart.AssemblyLinearVelocity =
					Vector3.zero

				RootPart.AssemblyAngularVelocity =
					Vector3.zero

				return
			end

			----------------------------------------------------
			-- RESUME
			----------------------------------------------------

			if pausedAt > 0 then

				totalPaused +=
					getNow() - pausedAt

				pausedAt = 0
			end

			----------------------------------------------------
			-- WALK TO START
			----------------------------------------------------

			if playbackState ==
				"WALK_TO_START"
				or playbackState ==
				"RETURN_TO_START" then

				if not moveStarted then

					Humanoid.AutoRotate = true

					Humanoid:MoveTo(
						startPosition
					)

					moveStarted = true
				end

				local distance =
					(
						RootPart.Position
						- startPosition
					).Magnitude

				if distance <= 1.25 then

					RootPart.CFrame =
						startCFrame

					RootPart.AssemblyLinearVelocity =
						Vector3.zero

					RootPart.AssemblyAngularVelocity =
						Vector3.zero

					playbackState =
						"PLAYING"

					playbackStart =
						getNow()

					totalPaused = 0

					currentIndex = 1

					jumpConsumed = {}

					moveStarted = false

					updateStatus(
						state.isAutoWalk
							and "AUTO WALK"
							or "PLAYING"
					)

					return
				end

				if getNow() > startTimeout then

					local remaining =
						(
							RootPart.Position
							- startPosition
						).Magnitude

					if remaining > 5 then

						stopPlayback(false)

						updateStatus(
							"ABORTED: STUCK"
						)

						return
					end

					RootPart.CFrame =
						startCFrame

					playbackState =
						"PLAYING"

					playbackStart =
						getNow()

					totalPaused = 0

					currentIndex = 1

					jumpConsumed = {}

					moveStarted = false

					updateStatus(
						state.isAutoWalk
							and "AUTO WALK"
							or "PLAYING"
					)
				end

				return
			end

			----------------------------------------------------
			-- PLAYING
			----------------------------------------------------

			local elapsed =
				getNow()
				- playbackStart
				- totalPaused

			----------------------------------------------------
			-- FIND CURRENT NODE
			----------------------------------------------------

			while
				currentIndex < #timeline
				and elapsed >=
					(
						timeline[
							currentIndex + 1
						].RelativeTimestamp
					)
			do

				currentIndex += 1
			end

			----------------------------------------------------
			-- END
			----------------------------------------------------

			if currentIndex >= #timeline then

				if state.isAutoWalk then

					playbackState =
						"RETURN_TO_START"

					startTimeout =
						getNow() + 30

					moveStarted = false

					updateStatus(
						"WALKING TO START"
					)

					return

				else

					stopPlayback(false)
					return
				end
			end

			----------------------------------------------------
			-- NODE DATA
			----------------------------------------------------

			local currentNode =
				timeline[currentIndex]

			local nextNode =
				timeline[currentIndex + 1]

			local currentTime =
				currentNode.RelativeTimestamp

			local nextTime =
				nextNode.RelativeTimestamp

			local duration =
				nextTime - currentTime

			----------------------------------------------------
			-- ALPHA
			----------------------------------------------------

			local alpha = 0

			if duration > 0 then

				alpha =
					math.clamp(
						(elapsed - currentTime)
							/ duration,
						0,
						1
					)
			end

			----------------------------------------------------
			-- TARGET
			----------------------------------------------------

			local targetPosition =
				currentNode.Position:Lerp(
					nextNode.Position,
					alpha
				)

			local targetCFrame =
				currentNode.CFrame:Lerp(
					nextNode.CFrame,
					alpha
				)

			local currentPosition =
				RootPart.Position

			local difference =
				targetPosition
				- currentPosition

			local distance =
				difference.Magnitude

			----------------------------------------------------
			-- WALK SPEED
			----------------------------------------------------

			if currentNode.WalkSpeed then
				Humanoid.WalkSpeed =
					currentNode.WalkSpeed
			end

			----------------------------------------------------
			-- JUMP
			----------------------------------------------------

			if currentNode.Jump
				and not jumpConsumed[currentIndex] then

				jumpConsumed[currentIndex] =
					true

				Humanoid.Jump = true
			end

			----------------------------------------------------
			-- MOVEMENT
			----------------------------------------------------

			Humanoid.AutoRotate = false

			local horizontal =
				Vector3.new(
					difference.X,
					0,
					difference.Z
				)

			if horizontal.Magnitude > 0.03 then

				Humanoid:Move(
					horizontal.Unit,
					false
				)

			else

				Humanoid:Move(
					Vector3.zero,
					true
				)
			end

			----------------------------------------------------
			-- POSITION CORRECTION
			----------------------------------------------------

			if distance >
				CFG.PlaybackPositionSnap then

				RootPart.CFrame =
					targetCFrame

				RootPart.AssemblyLinearVelocity =
					Vector3.zero

			else

				local smooth =
					math.clamp(
						dt * CFG.PlaybackSmooth,
						0.15,
						0.85
					)

				RootPart.CFrame =
					RootPart.CFrame:Lerp(
						targetCFrame,
						smooth
					)
			end
		end
	)
end

----------------------------------------------------------------
-- AUTO WALK
----------------------------------------------------------------

local function toggleAutoWalk()

	if state.isRecording then
		return
	end

	if state.isAutoWalk then

		state.isAutoWalk = false

		stopPlayback(true)

		return
	end

	if #state.timeline < 2 then
		updateStatus("NO ROUTE")
		return
	end

	state.isAutoWalk = true

	updateStatus("AUTO WALK")

	if not state.isPlaying then
		executePlayback()
	end
end

----------------------------------------------------------------
-- BUTTONS
----------------------------------------------------------------

createButton(
	"RECORD START",
	1,
	function()

		if state.isRecording then
			finishRecording()
		else
			beginRecording()
		end
	end
)

createButton(
	"PLAY ROUTE",
	2,
	function()

		if state.isRecording then
			return
		end

		state.isAutoWalk = false

		if not state.isPlaying then
			executePlayback()
		end
	end
)

createButton(
	"PAUSE / RES",
	3,
	function()

		if not state.isPlaying then
			return
		end

		state.isPaused =
			not state.isPaused

		if state.isPaused then
			updateStatus("PAUSED")
		else
			updateStatus(
				state.isAutoWalk
					and "AUTO WALK"
					or "PLAYING"
			)
		end
	end
)

createButton(
	"AUTO WALK",
	4,
	function()
		toggleAutoWalk()
	end
)

createButton(
	"STOP",
	5,
	function()
		stopPlayback(true)
	end
)

----------------------------------------------------------------
-- CUT START
----------------------------------------------------------------

createButton(
	"<< CUT",
	6,
	function()

		if #state.timeline <= 2 then
			return
		end

		state.cutStart =
			math.clamp(
				state.cutStart + 1,
				1,
				math.max(
					1,
					state.cutEnd - 1
				)
			)

		updateStatus("CUT CONFIG")
	end
)

----------------------------------------------------------------
-- CUT END
----------------------------------------------------------------

createButton(
	"CUT >>",
	7,
	function()

		if #state.timeline <= 2 then
			return
		end

		state.cutEnd =
			math.clamp(
				state.cutEnd - 1,
				math.min(
					#state.timeline,
					state.cutStart + 1
				),
				#state.timeline
			)

		updateStatus("CUT CONFIG")
	end
)

----------------------------------------------------------------
-- APPLY CUT
----------------------------------------------------------------

createButton(
	"APPLY CUT",
	8,
	function()

		if #state.timeline <= 2 then
			return
		end

		if state.cutStart >= state.cutEnd then
			return
		end

		local newTimeline = {}

		for i =
			state.cutStart,
			state.cutEnd do

			local node =
				state.timeline[i]

			table.insert(
				newTimeline,
				{
					CFrame = node.CFrame,
					Position = node.Position,

					Timestamp =
						node.Timestamp,

					RelativeTimestamp = 0,

					Jump = node.Jump,

					WalkSpeed =
						node.WalkSpeed,

					HumanoidState =
						node.HumanoidState,

					MovementDirection =
						node.MovementDirection
				}
			)
		end

		normalizeTimeline(
			newTimeline
		)

		state.timeline =
			newTimeline

		state.cutStart = 1

		state.cutEnd =
			#state.timeline

		rebuildRoute()

		updateStatus("CUT APPLIED")
	end
)

----------------------------------------------------------------
-- PUT TOGETHER
----------------------------------------------------------------

createButton(
	"PUT TOGETHER",
	9,
	function()

		local base =
			state.savedFiles[
				state.selectedFile
			]

		if not base
			or not base.timeline
			or #base.timeline == 0 then
			return
		end

		if #state.timeline == 0 then
			return
		end

		local merged =
			cloneTimeline(
				base.timeline
			)

		normalizeTimeline(
			merged
		)

		local offset =
			merged[
				#merged
			].RelativeTimestamp
			+ CFG.NodeInterval

		for _, node in ipairs(
			state.timeline
		) do

			local copy =
				cloneTimeline(
					{node}
				)[1]

			copy.RelativeTimestamp =
				offset
				+ node.RelativeTimestamp

			copy.Timestamp =
				merged[1].Timestamp
				+ copy.RelativeTimestamp

			table.insert(
				merged,
				copy
			)
		end

		normalizeTimeline(
			merged
		)

		state.timeline =
			merged

		state.cutStart = 1

		state.cutEnd =
			#state.timeline

		rebuildRoute()

		updateStatus(
			"MERGED ROUTE"
		)
	end
)

----------------------------------------------------------------
-- FILE BUTTONS
----------------------------------------------------------------

for i = 1, 5 do

	local fileNumber = i

	createButton(
		"FILE " .. tostring(i),
		9 + i,
		function()

			if state.isRecording then
				return
			end

			state.selectedFile =
				fileNumber

			state.cutStart = 1

			state.cutEnd =
				math.max(
					1,
					#state.timeline
				)

			updateStatus("IDLE")
		end
	)
end

----------------------------------------------------------------
-- SAVE
----------------------------------------------------------------

createButton(
	"SAVE FILE",
	15,
	function()

		if #state.timeline == 0 then
			updateStatus("NOTHING TO SAVE")
			return
		end

		normalizeTimeline(
			state.timeline
		)

		state.savedFiles[
			state.selectedFile
		] = {
			timeline =
				cloneTimeline(
					state.timeline
				)
		}

		saveToDisk()

		updateStatus(
			"SAVED FILE "
				.. tostring(
					state.selectedFile
				)
		)
	end
)

----------------------------------------------------------------
-- LOAD
----------------------------------------------------------------

createButton(
	"LOAD FILE",
	16,
	function()

		local data =
			state.savedFiles[
				state.selectedFile
			]

		if not data
			or not data.timeline then

			updateStatus("FILE EMPTY")
			return
		end

		stopPlayback(true)

		state.timeline =
			cloneTimeline(
				data.timeline
			)

		normalizeTimeline(
			state.timeline
		)

		state.cutStart = 1

		state.cutEnd =
			#state.timeline

		rebuildRoute()

		updateStatus(
			"LOADED FILE "
				.. tostring(
					state.selectedFile
				)
		)
	end
)

----------------------------------------------------------------
-- CLEAR
----------------------------------------------------------------

createButton(
	"CLEAR",
	17,
	function()

		stopPlayback(true)

		state.isRecording = false

		state.timeline = {}

		state.cutStart = 1
		state.cutEnd = 1

		state.lastJumpState = false

		clearVisuals()

		updateStatus("CLEARED")
	end
)

----------------------------------------------------------------
-- LINE VISIBLE
----------------------------------------------------------------

createButton(
	"LINE VISIBLE",
	18,
	function()

		state.lineVisible =
			not state.lineVisible

		local folder =
			workspace:FindFirstChild(
				CFG.RouteFolderName
			)

		if not folder then
			return
		end

		for _, object in ipairs(
			folder:GetChildren()
		) do

			if object.Name ==
				"VisualNode" then

				object.Transparency =
					state.lineVisible
						and 0
						or 1

			elseif object.Name ==
				"GroundMarker" then

				object.Transparency =
					state.lineVisible
						and 0.3
						or 1
			end
		end

		updateStatus(
			state.lineVisible
				and "LINE ON"
				or "LINE OFF"
		)
	end
)

----------------------------------------------------------------
-- GLOBAL CLEANUP
----------------------------------------------------------------

_G.AldoKnightXorzV438_Cleanup = function()

	state.isRecording = false
	state.isPlaying = false
	state.isPaused = false
	state.isAutoWalk = false

	state.playbackID =
		state.playbackID + 1

	pcall(function()
		RunService:UnbindFromRenderStep(
			"AldoKnightXorzV438_Record"
		)
	end)

	pcall(function()
		RunService:UnbindFromRenderStep(
			"AldoKnightXorzV438_Playback"
		)
	end)

	for _, connection in ipairs(
		currentConnections
	) do

		if typeof(connection) ==
			"RBXScriptConnection" then

			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	currentConnections = {}

	clearVisuals()

	pcall(function()
		if ScreenGui then
			ScreenGui:Destroy()
		end
	end)
end

----------------------------------------------------------------
-- FINAL
----------------------------------------------------------------

updateStatus("IDLE")
