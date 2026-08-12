local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if _G._MapStudioLiteCleanup then
	pcall(_G._MapStudioLiteCleanup)
end

local connections = {}
local destroyed = false

local function connect(sig, cb)
	local c
	pcall(function() c = sig:Connect(cb) end)
	if c then table.insert(connections, c) end
	return c
end

local function cleanup()
	destroyed = true
	for _, c in ipairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(connections)
	local sg = playerGui:FindFirstChild("MapStudioLite")
	if sg then sg:Destroy() end
end

_G._MapStudioLiteCleanup = cleanup

-- ============================================================
-- GUI
-- ============================================================
local sg = Instance.new("ScreenGui")
sg.Name = "MapStudioLite"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 100
sg.Parent = playerGui

-- Main Frame
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(500, 300)
main.Position = UDim2.new(0.5, -250, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
main.BorderSizePixel = 0
main.Visible = false
main.Parent = sg

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- Stroke
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 120, 255)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3
mainStroke.Parent = main

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

local titleBarInner = Instance.new("UICorner")
titleBarInner.CornerRadius = UDim.new(0, 12)
titleBarInner.Parent = main

-- Fix top corners
local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 12)
titleCover.Position = UDim2.new(0, 0, 0, 24)
titleCover.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleCover.BorderSizePixel = 0
titleCover.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.Text = "📦 MAP STUDIO LITE"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -34, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
closeBtn.BackgroundTransparency = 0.5
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(1, 0, 0, 32)
tabFrame.Position = UDim2.new(0, 0, 0, 36)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = main

local tabs = {"TOOLS", "NOTES", "AUDIO", "TERRAIN"}
local tabButtons = {}
local tabPanels = {}
local activeTab = 1

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. name
	btn.Size = UDim2.new(0.25, -2, 1, -4)
	btn.Position = UDim2.new((i - 1) * 0.25, 1, 0, 2)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(180, 180, 200)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.Parent = tabFrame
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	tabButtons[i] = btn

	connect(btn.Activated, function()
		activeTab = i
		for j, tb in ipairs(tabButtons) do
			tb.BackgroundColor3 = (j == i) and Color3.fromRGB(60, 80, 160) or Color3.fromRGB(45, 45, 60)
			tb.TextColor3 = (j == i) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
		end
		for j, panel in ipairs(tabPanels) do
			if panel then panel.Visible = (j == i) end
		end
	end)
end

-- Content area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -10, 1, -78)
content.Position = UDim2.new(0, 5, 0, 72)
content.BackgroundTransparency = 1
content.Parent = main

-- ============================================================
-- TAB 1: TOOLS
-- ============================================================
local toolsPanel = Instance.new("ScrollingFrame")
toolsPanel.Name = "ToolsPanel"
toolsPanel.Size = UDim2.new(1, 0, 1, 0)
toolsPanel.BackgroundTransparency = 1
toolsPanel.BorderSizePixel = 0
toolsPanel.ScrollBarThickness = 6
toolsPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
toolsPanel.Parent = content
tabPanels[1] = toolsPanel

local toolsLayout = Instance.new("UIListLayout")
toolsLayout.Padding = UDim.new(0, 6)
toolsLayout.Parent = toolsPanel

local function makeToolsHeader(text)
	local h = Instance.new("TextLabel")
	h.Size = UDim2.new(1, -10, 0, 24)
	h.Text = text
	h.TextColor3 = Color3.fromRGB(100, 150, 255)
	h.Font = Enum.Font.GothamBold
	h.TextSize = 13
	h.TextXAlignment = Enum.TextXAlignment.Left
	h.BackgroundTransparency = 1
	h.Parent = toolsPanel
	return h
end

local function makeToolsButton(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.Gotham
	btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 75)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Parent = toolsPanel
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
	connect(btn.Activated, callback)
	return btn
end

local function makeToolsInput(placeholder, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 34)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = toolsPanel
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 6)
	frameCorner.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -40, 1, 0)
	box.Position = UDim2.fromOffset(8, 0)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 13
	box.Font = Enum.Font.Gotham
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = frame

	local goBtn = Instance.new("TextButton")
	goBtn.Size = UDim2.fromOffset(30, 26)
	goBtn.Position = UDim2.new(1, -34, 0, 4)
	goBtn.Text = "→"
	goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	goBtn.TextSize = 14
	goBtn.Font = Enum.Font.GothamBold
	goBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 160)
	goBtn.BackgroundTransparency = 0.3
	goBtn.BorderSizePixel = 0
	goBtn.Parent = frame
	local goCorner = Instance.new("UICorner")
	goCorner.CornerRadius = UDim.new(0, 5)
	goCorner.Parent = goBtn

	connect(goBtn.Activated, function()
		callback(box.Text)
	end)
	connect(box.FocusLost, function(enter)
		if enter then callback(box.Text) end
	end)

	return box
end

-- Search Toolbox
makeToolsHeader("🔍 TOOLBOX SEARCH")
local searchBox = makeToolsInput("Search model ID...", function(query)
	local id = tonumber(query:match("%d+"))
	if id then
		pcall(function()
			local model = InsertService:LoadAsset(id)
			if model then
				local cloned = model:GetChildren()
				for _, obj in ipairs(cloned) do
					obj.Parent = workspace
				end
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "✅ Imported",
					Text = "Asset " .. id .. " loaded",
					Duration = 2
				})
			end
		end)
	end
end)

-- Auto Create
makeToolsHeader("⚡ QUICK ACTIONS")
makeToolsButton("📦 Auto Create Part", Color3.fromRGB(50, 70, 120), function()
	local p = Instance.new("Part")
	p.Name = "AutoPart"
	p.Size = Vector3.new(4, 1, 4)
	p.Color = Color3.fromRGB(200, 150, 100)
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = false
	p.Position = (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position) or Vector3.new(0, 5, 0)
	p.Parent = workspace
	Selection:Set({p})
end)

makeToolsButton("🔓 UnGroup Selection", Color3.fromRGB(120, 60, 60), function()
	local sel = Selection:Get()
	for _, obj in ipairs(sel) do
		if obj:IsA("Model") then
			local children = obj:GetChildren()
			for _, child in ipairs(children) do
				child.Parent = workspace
			end
			obj:Destroy()
		end
	end
end)

-- Map ID Tools
makeToolsHeader("🗺️ MAP ID TOOLS")
makeToolsButton("📋 Copy Map ID", Color3.fromRGB(50, 100, 80), function()
	local mapId = game.PlaceId
	setclipboard(tostring(mapId))
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "📋 Copied",
		Text = "Map ID: " .. mapId,
		Duration = 2
	})
end)

makeToolsButton("📋 Copy Map ID (Explorer)", Color3.fromRGB(50, 100, 120), function()
	local sel = Selection:Get()
	for _, obj in ipairs(sel) do
		if obj:IsA("Instance") then
			setclipboard(tostring(obj:GetDebugId(8)))
			break
		end
	end
end)

local pasteBox = makeToolsInput("Paste Map ID Explorer...", function(query)
	if query and #query > 0 then
		-- try to find by debug id
		for _, v in ipairs(workspace:GetDescendants()) do
			local success, match = pcall(function()
				return v:GetDebugId(8):find(query)
			end)
			if success and match then
				Selection:Set({v})
				break
			end
		end
	end
end)

-- AI Script
makeToolsHeader("🤖 AI CREATE SCRIPT")
local aiBox = makeToolsInput("Describe script...", function(prompt)
	if prompt and #prompt > 0 then
		local s = Instance.new("Script")
		s.Name = "AIScript_" .. math.random(1000, 9999)
		s.Source = string.format("--[[\n  AI Generated Script\n  Prompt: %s\n]]\n\nlocal Players = game:GetService(\"Players\")\nlocal player = Players.LocalPlayer\n\nprint(\"Script loaded: %s\")\n\n-- Generated by Map Studio Lite AI\n-- Modify as needed\n", prompt, prompt)
		s.Parent = workspace
		Selection:Set({s})
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "🤖 Script Created",
			Text = s.Name .. " added to workspace",
			Duration = 2
		})
	end
end)

-- Update canvas size
connect(toolsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
	toolsPanel.CanvasSize = UDim2.new(0, 0, 0, toolsLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- TAB 2: NOTES
-- ============================================================
local notesPanel = Instance.new("ScrollingFrame")
notesPanel.Name = "NotesPanel"
notesPanel.Size = UDim2.new(1, 0, 1, 0)
notesPanel.BackgroundTransparency = 1
notesPanel.BorderSizePixel = 0
notesPanel.ScrollBarThickness = 6
notesPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
notesPanel.Visible = false
notesPanel.Parent = content
tabPanels[2] = notesPanel

local notesLayout = Instance.new("UIListLayout")
notesLayout.Padding = UDim.new(0, 6)
notesLayout.Parent = notesPanel

local notes = {}
local noteFrames = {}

local function loadNotes()
	local success, data = pcall(function()
		return readfile("MapStudio_Notes.json")
	end)
	if success and data and #data > 0 then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(data)
		end)
		if ok and type(decoded) == "table" then
			notes = decoded
		end
	end
end

local function saveNotes()
	local success, encoded = pcall(function()
		return HttpService:JSONEncode(notes)
	end)
	if success then
		pcall(function()
			writefile("MapStudio_Notes.json", encoded)
		end)
	end
end

local function refreshNotesUI()
	for _, f in ipairs(noteFrames) do
		if f and f.Parent then f:Destroy() end
	end
	table.clear(noteFrames)

	for i, note in ipairs(notes) do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, -10, 0, 80)
		frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		frame.BackgroundTransparency = 0.3
		frame.BorderSizePixel = 0
		frame.Parent = notesPanel
		local frameCorner = Instance.new("UICorner")
		frameCorner.CornerRadius = UDim.new(0, 6)
		frameCorner.Parent = frame
		table.insert(noteFrames, frame)

		local titleL = Instance.new("TextLabel")
		titleL.Size = UDim2.new(1, -50, 0, 20)
		titleL.Position = UDim2.fromOffset(6, 4)
		titleL.Text = note.title or "Note " .. i
		titleL.TextColor3 = Color3.fromRGB(200, 200, 255)
		titleL.Font = Enum.Font.GothamBold
		titleL.TextSize = 13
		titleL.TextXAlignment = Enum.TextXAlignment.Left
		titleL.BackgroundTransparency = 1
		titleL.Parent = frame

		local bodyL = Instance.new("TextLabel")
		bodyL.Size = UDim2.new(1, -12, 0, 40)
		bodyL.Position = UDim2.fromOffset(6, 24)
		bodyL.Text = note.body or ""
		bodyL.TextColor3 = Color3.fromRGB(180, 180, 200)
		bodyL.Font = Enum.Font.Gotham
		bodyL.TextSize = 11
		bodyL.TextXAlignment = Enum.TextXAlignment.Left
		bodyL.TextYAlignment = Enum.TextYAlignment.Top
		bodyL.BackgroundTransparency = 1
		bodyL.TextWrapped = true
		bodyL.Parent = frame

		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.fromOffset(24, 24)
		delBtn.Position = UDim2.new(1, -30, 0, 4)
		delBtn.Text = "✕"
		delBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		delBtn.TextSize = 12
		delBtn.Font = Enum.Font.GothamBold
		delBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
		delBtn.BackgroundTransparency = 0.5
		delBtn.BorderSizePixel = 0
		delBtn.Parent = frame
		local delCorner = Instance.new("UICorner")
		delCorner.CornerRadius = UDim.new(0, 4)
		delCorner.Parent = delBtn
		connect(delBtn.Activated, function()
			table.remove(notes, i)
			saveNotes()
			refreshNotesUI()
		end)
	end

	notesPanel.CanvasSize = UDim2.new(0, 0, 0, #notes * 86 + 50)
end

-- Add note input
local addNoteFrame = Instance.new("Frame")
addNoteFrame.Size = UDim2.new(1, -10, 0, 90)
addNoteFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
addNoteFrame.BackgroundTransparency = 0.3
addNoteFrame.BorderSizePixel = 0
addNoteFrame.Parent = notesPanel
local addNoteCorner = Instance.new("UICorner")
addNoteCorner.CornerRadius = UDim.new(0, 6)
addNoteCorner.Parent = addNoteFrame

local noteTitleBox = Instance.new("TextBox")
noteTitleBox.Size = UDim2.new(1, -16, 0, 24)
noteTitleBox.Position = UDim2.fromOffset(8, 4)
noteTitleBox.PlaceholderText = "Note title..."
noteTitleBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
noteTitleBox.Text = ""
noteTitleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
noteTitleBox.TextSize = 13
noteTitleBox.Font = Enum.Font.GothamBold
noteTitleBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
noteTitleBox.BackgroundTransparency = 0.3
noteTitleBox.BorderSizePixel = 0
noteTitleBox.ClearTextOnFocus = false
noteTitleBox.Parent = addNoteFrame
local ntCorner = Instance.new("UICorner")
ntCorner.CornerRadius = UDim.new(0, 4)
ntCorner.Parent = noteTitleBox

local noteBodyBox = Instance.new("TextBox")
noteBodyBox.Size = UDim2.new(1, -16, 0, 28)
noteBodyBox.Position = UDim2.fromOffset(8, 32)
noteBodyBox.PlaceholderText = "Note content..."
noteBodyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
noteBodyBox.Text = ""
noteBodyBox.TextColor3 = Color3.fromRGB(200, 200, 200)
noteBodyBox.TextSize = 11
noteBodyBox.Font = Enum.Font.Gotham
noteBodyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
noteBodyBox.BackgroundTransparency = 0.3
noteBodyBox.BorderSizePixel = 0
noteBodyBox.ClearTextOnFocus = false
noteBodyBox.TextWrapped = true
noteBodyBox.Parent = addNoteFrame
local nbCorner = Instance.new("UICorner")
nbCorner.CornerRadius = UDim.new(0, 4)
nbCorner.Parent = noteBodyBox

local addNoteBtn = Instance.new("TextButton")
addNoteBtn.Size = UDim2.new(1, -16, 0, 22)
addNoteBtn.Position = UDim2.fromOffset(8, 64)
addNoteBtn.Text = "➕ ADD NOTE"
addNoteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addNoteBtn.TextSize = 12
addNoteBtn.Font = Enum.Font.GothamBold
addNoteBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 80)
addNoteBtn.BackgroundTransparency = 0.2
addNoteBtn.BorderSizePixel = 0
addNoteBtn.Parent = addNoteFrame
local addBtnCorner = Instance.new("UICorner")
addBtnCorner.CornerRadius = UDim.new(0, 4)
addBtnCorner.Parent = addNoteBtn

connect(addNoteBtn.Activated, function()
	local title = noteTitleBox.Text
	local body = noteBodyBox.Text
	if #title > 0 or #body > 0 then
		table.insert(notes, {title = title, body = body})
		saveNotes()
		refreshNotesUI()
		noteTitleBox.Text = ""
		noteBodyBox.Text = ""
	end
end)

loadNotes()
refreshNotesUI()

-- ============================================================
-- TAB 3: AUDIO
-- ============================================================
local audioPanel = Instance.new("ScrollingFrame")
audioPanel.Name = "AudioPanel"
audioPanel.Size = UDim2.new(1, 0, 1, 0)
audioPanel.BackgroundTransparency = 1
audioPanel.BorderSizePixel = 0
audioPanel.ScrollBarThickness = 6
audioPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
audioPanel.Visible = false
audioPanel.Parent = content
tabPanels[3] = audioPanel

local audioLayout = Instance.new("UIListLayout")
audioLayout.Padding = UDim.new(0, 6)
audioLayout.Parent = audioPanel

makeToolsHeader("🎵 AUDIO TOOLS")
local audioIdBox = makeToolsInput("Search Audio ID...", function(query)
	local id = tonumber(query:match("%d+"))
	if id then
		setclipboard("rbxassetid://" .. id)
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "📋 Copied",
			Text = "rbxassetid://" .. id,
			Duration = 2
		})
	end
end)

makeToolsButton("▶️ Play Test Sound", Color3.fromRGB(80, 60, 120), function()
	local id = tonumber(audioIdBox.Text:match("%d+"))
	if id then
		local old = workspace:FindFirstChild("TestSound")
		if old then old:Destroy() end
		local s = Instance.new("Sound")
		s.Name = "TestSound"
		s.SoundId = "rbxassetid://" .. id
		s.Volume = 0.5
		s.Parent = workspace
		s:Play()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "▶️ Playing",
			Text = "Sound ID: " .. id,
			Duration = 2
		})
	end
end)

makeToolsButton("⏹️ Stop Sound", Color3.fromRGB(100, 50, 50), function()
	local s = workspace:FindFirstChild("TestSound")
	if s then s:Stop() s:Destroy() end
end)

makeToolsButton("📋 Copy ID Music", Color3.fromRGB(50, 80, 100), function()
	local s = workspace:FindFirstChild("TestSound")
	if s and s.SoundId then
		local id = s.SoundId:match("%d+")
		if id then
			setclipboard(id)
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "📋 Copied",
				Text = "ID: " .. id,
				Duration = 2
			})
		end
	end
end)

-- Audio ID list
makeToolsHeader("📋 COMMON AUDIO IDS")
local commonAudio = {
	{"Epic Theme", "138004082589684"},
	{"Sad Violin", "1837548907"},
	{"Sword Fight", "138004082589684"},
	{"Rain", "166900177"},
	{"Wind", "151220103"},
	{"Thunder", "138004082589684"},
	{"Clock Tick", "9120387532"},
	{"Coin", "119223313"},
	{"Jump", "123710580"},
	{"Explosion", "141224111"},
}

for _, item in ipairs(commonAudio) do
	local btn = makeToolsButton(item[1] .. " (" .. item[2] .. ")", Color3.fromRGB(50, 50, 65), function()
		setclipboard("rbxassetid://" .. item[2])
		audioIdBox.Text = item[2]
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "📋 Copied",
			Text = "rbxassetid://" .. item[2],
			Duration = 2
		})
	end)
end

connect(audioLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
	audioPanel.CanvasSize = UDim2.new(0, 0, 0, audioLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- TAB 4: TERRAIN
-- ============================================================
local terrainPanel = Instance.new("ScrollingFrame")
terrainPanel.Name = "TerrainPanel"
terrainPanel.Size = UDim2.new(1, 0, 1, 0)
terrainPanel.BackgroundTransparency = 1
terrainPanel.BorderSizePixel = 0
terrainPanel.ScrollBarThickness = 6
terrainPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
terrainPanel.Visible = false
terrainPanel.Parent = content
tabPanels[4] = terrainPanel

local terrainLayout = Instance.new("UIListLayout")
terrainLayout.Padding = UDim.new(0, 6)
terrainLayout.Parent = terrainPanel

makeToolsHeader("⛰️ TERRAIN STUDIO LITE")

local terrain = workspace:FindFirstChildOfClass("Terrain")

makeToolsButton("🏔️ Fill Region (Grass)", Color3.fromRGB(50, 100, 50), function()
	if not terrain then return end
	local region = Region3.new(Vector3.new(-256, -10, -256), Vector3.new(256, 10, 256))
	terrain:FillRegion(region, 4, Enum.Material.Grass)
end)

makeToolsButton("🏖️ Fill Region (Sand)", Color3.fromRGB(100, 90, 50), function()
	if not terrain then return end
	local region = Region3.new(Vector3.new(-256, -10, -256), Vector3.new(256, 10, 256))
	terrain:FillRegion(region, 4, Enum.Material.Sand)
end)

makeToolsButton("🌊 Fill Region (Water)", Color3.fromRGB(30, 60, 120), function()
	if not terrain then return end
	local region = Region3.new(Vector3.new(-256, -5, -256), Vector3.new(256, 5, 256))
	terrain:FillRegion(region, 4, Enum.Material.Water)
end)

makeToolsButton("🪨 Add Rocks (Sphere)", Color3.fromRGB(70, 60, 50), function()
	if not terrain then return end
	local pos = (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position) or Vector3.new(0, 5, 0)
	terrain:FillBall(pos + Vector3.new(0, -5, 0), 8, Enum.Material.Slate)
end)

makeToolsButton("🗑️ Clear Terrain", Color3.fromRGB(100, 40, 40), function()
	if not terrain then return end
	terrain:Clear()
end)

makeToolsButton("📏 Auto Create Flat Terrain", Color3.fromRGB(50, 70, 100), function()
	if not terrain then return end
	local region = Region3.new(Vector3.new(-256, -5, -256), Vector3.new(256, 5, 256))
	terrain:FillRegion(region, 4, Enum.Material.Grass)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "✅ Terrain Created",
		Text = "Flat grass terrain generated",
		Duration = 2
	})
end)

connect(terrainLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
	terrainPanel.CanvasSize = UDim2.new(0, 0, 0, terrainLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- TOGGLE MENU
-- ============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0, 12, 1, -62)
toggleBtn.Text = "📦"
toggleBtn.TextSize = 22
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = sg
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleBtn

connect(toggleBtn.Activated, function()
	main.Visible = not main.Visible
end)

connect(closeBtn.Activated, function()
	main.Visible = false
end)

-- Keyboard shortcut
connect(UserInputService.InputBegan, function(input, gp)
	if gp or destroyed then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		main.Visible = not main.Visible
	end
end)

-- Make draggable
local dragging = false
local dragStart = nil
local frameStart = nil

connect(titleBar.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		frameStart = main.Position
	end
end)

connect(UserInputService.InputChanged, function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
	end
end)

connect(UserInputService.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Set tab 1 active by default
tabButtons[1].BackgroundColor3 = Color3.fromRGB(60, 80, 160)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

print("hai")
