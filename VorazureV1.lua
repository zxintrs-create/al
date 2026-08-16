--[[  
	VZ COMBAT EXECUTOR  
	Standalone Script for Executor  
	All-in-one script - executes directly in executor  
--]]

local Players = game:GetService("Players")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Configuration Settings  
local SETTINGS = {  
	MaxDistance = 100,  
	UI scale = 1,  
	AnimationSpeed = 1,  
	AutoRefresh = true,  
	RefreshInterval = 3  
}

-- State Variables  
local selectedPlayer = nil  
local selectedRemote = nil  
local currentAnimation = nil  
local isAnimating = false  
local scanResults = {}  
local playerList = {}  
local connectionTable = {}

-- Animation IDs  
local ANIMATION_IDS = {  
	Grab = "rbxassetid://7691396275",  
	Choke = "rbxassetid://3752886447",  
	Custom1 = "",  
	Custom2 = "",  
	Custom3 = ""  
}

-- Logging System  
local LOG_TABLE = {}  
local MAX_LOGS = 200

local function logMessage(message, messageType)  
	local logEntry = {  
		timestamp = tick(),  
		message = tostring(message),  
		type = messageType or "INFO"  
	}  
	table.insert(LOG_TABLE, logEntry)  
	if #LOG_TABLE > MAX_LOGS then  
		table.remove(LOG_TABLE, 1)  
	end  
end

local function logError(message)  
	logMessage(message, "ERROR")  
end

local function logWarning(message)  
	logMessage(message, "WARNING")  
end

-- Utility Functions  
local function createInstance(className, properties, parent)  
	local instance = Instance.new(className)  
	if properties then  
		for key, value in pairs(properties) do  
			instance[key] = value  
		end  
	end  
	if parent then  
		instance.Parent = parent  
	end  
	return instance  
end

local function deepScanInstance(instance, results, path)  
	path = path or ""  
	local currentPath = path .. (path ~= "" and "." or "") .. instance.Name

	table.insert(results, {  
		Name = instance.Name,  
		ClassName = instance.ClassName,  
		Path = currentPath,  
		Instance = instance  
	})

	if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then  
		return  
	end

	for _, child in ipairs(instance:GetChildren()) do  
		if child:IsA("Folder") or child:IsA("ModuleScript") or child:FindFirstChildWhichIsA("RemoteEvent") or child:FindFirstChildWhichIsA("RemoteFunction") then  
			spawn(function()  
				deepScanInstance(child, results, currentPath)  
			end)  
		elseif #instance:GetChildren() < 100 then  
			deepScanInstance(child, results, currentPath)  
		end  
	end  
end

-- Player Scanner Functions  
local function updatePlayerList()  
	playerList = {}  
	for _, player in ipairs(Players:GetPlayers()) do  
		if player ~= LocalPlayer then  
			table.insert(playerList, player)  
		end  
	end  
end

local function getPlayerInfo(player)  
	if not player then return nil end  
	  
	local char = player.Character  
	if not char then return nil end  
	  
	local humanoid = char:FindFirstChildOfClass("Humanoid")  
	local rootPart = char:FindFirstChild("HumanoidRootPart")  
	  
	local isR15 = false  
	if humanoid then  
		isR15 = #char:GetChildren() > 20  
	end  
	  
	local distance = "N/A"  
	if LocalPlayer.Character and rootPart then  
		local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
		if myRoot then  
			distance = math.floor((rootPart.Position - myRoot.Position).Magnitude)  
		end  
	end  
	  
	return {  
		player = player,  
		character = char,  
		humanoid = humanoid,  
		rootPart = rootPart,  
		isR15 = isR15,  
		distance = distance  
	}  
end

Players.PlayerAdded:Connect(function(player)  
	updatePlayerList()  
end)

Players.PlayerRemoving:Connect(function(player)  
	updatePlayerList()  
	if selectedPlayer == player then  
		selectedPlayer = nil  
	end  
end)

LocalPlayer.CharacterAdded:Connect(function()  
	spawn(function()  
		wait(1)  
		updatePlayerList()  
	end)  
end)

-- Remote Scanner Functions  
local function scanRemotes()  
	scanResults = {}  
	logMessage("Scanning for remotes...", "INFO")  
	  
	local foldersToScan = {  
		ReplicatedStorage,  
		game:GetService("Workspace")  
	}  
	  
	for _, folder in ipairs(foldersToScan) do  
		spawn(function()  
			deepScanInstance(folder, scanResults, folder.Name)  
		end)  
	end  
	  
	wait(2)  
	  
	local remoteEvents = {}  
	for _, item in ipairs(scanResults) do  
		if item.ClassName == "RemoteEvent" or item.ClassName == "RemoteFunction" then  
			table.insert(remoteEvents, item)  
		end  
	end  
	  
	scanResults = remoteEvents  
	logMessage("Scan complete. Found " .. #scanResults .. " remotes.", "INFO")  
end

-- GUI System  
local CoreGui = game:GetService("CoreGui")  
local ScreenGui = createInstance("ScreenGui", {  
	Name = "VZCombatGui",  
	ResetOnSpawn = false,  
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,  
	Parent = CoreGui  
})

local mainFrame = createInstance("Frame", {  
	Size = UDim2.new(0, 600, 0, 500),  
	Position = UDim2.new(0.5, -300, 0.5, -250),  
	BackgroundTransparency = 0.1,  
	BackgroundColor3 = Color3.fromRGB(30, 30, 40),  
	BorderSizePixel = 0,  
	Parent = ScreenGui  
})

local uiCorner = createInstance("UICorner", {  
	CornerRadius = UDim.new(0, 15),  
	Parent = mainFrame  
})

local titleLabel = createInstance("TextLabel", {  
	Text = "VZ COMBAT EXECUTOR",  
	TextScaled = true,  
	Font = Enum.Font.GothamBold,  
	TextColor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 50),  
	Position = UDim2.new(0, 0, 0, 0),  
	Parent = mainFrame  
})

local tabBar = createInstance("Frame", {  
	Size = UDim2.new(1, 0, 0, 40),  
	Position = UDim2.new(0, 0, 0, 50),  
	BackgroundColor3 = Color3.fromRGB(25, 25, 35),  
	BorderSizePixel = 0,  
	Parent = mainFrame  
})

local tabNames = {"PLAYERS", "REMOTES", "ANIMATION", "SETTINGS", "LOGS"}  
local tabButtons = {}  
local tabFrames = {}

local function createTab(name, index)  
	local btn = createInstance("TextButton", {  
		Text = name,  
		TextScaled = true,  
		Font = Enum.Font.Gotham,  
		TextColor3 = Color3.fromRGB(200, 200, 200),  
		BackgroundTransparency = 0.4,  
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),  
		Size = UDim2.new(0.2, 0, 1, 0),  
		Position = UDim2.new((index - 1) * 0.2, 0, 0, 0),  
		BorderSizePixel = 0,  
		Parent = tabBar  
	})  
	  
	local corner = createInstance("UICorner", {  
		CornerRadius = UDim.new(0, 8),  
		Parent = btn  
	})  
	  
	local frame = createInstance("Frame", {  
		Size = UDim2.new(1, 0, 1, 0),  
		Position = UDim2.new(0, 0, 0, 90),  
		BackgroundTransparency = 0.5,  
		BackgroundColor3 = Color3.fromRGB(35, 35, 45),  
		BorderSizePixel = 0,  
		Visible = index == 1,  
		Parent = mainFrame  
	})  
	  
	local frameCorner = createInstance("UICorner", {  
		CornerRadius = UDim.new(0, 8),  
		Parent = frame  
	})  
	  
	return btn, frame  
end

for i, name in ipairs(tabNames) do  
	tabButtons[i], tabFrames[i] = createTab(name, i)  
end

local function switchTab(index)  
	for i, frame in ipairs(tabFrames) do  
		frame.Visible = i == index  
	end  
	for i, btn in ipairs(tabButtons) do  
		btn.BackgroundTransparency = i == index and 0.2 or 0.4  
	end  
end

for i, btn in ipairs(tabButtons) do  
	btn.MouseButton1Click:Connect(function()  
		switchTab(i)  
	end)  
end

-- TABBED UI CONTENT  
-- PLAYERS TAB  
local playersFrame = tabFrames[1]

local searchBox = createInstance("TextBox", {  
	PlaceholderText = "Search player...",  
	Text = "",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	TextColor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 0.3,  
	BackgroundColor3 = Color3.fromRGB(50, 50, 60),  
	Size = UDim2.new(0.9, 0, 0, 35),  
	Position = UDim2.new(0.05, 0, 0, 10),  
	BorderSizePixel = 0,  
	ClearTextOnFocus = false,  
	Parent = playersFrame  
})

local searchCorner = createInstance("UICorner", {  
	CornerRadius = UDim.new(0, 8),  
	Parent = searchBox  
})

local playerListFrame = createInstance("ScrollingFrame", {  
	Size = UDim2.new(0.9, 0, 0, 200),  
	Position = UDim2.new(0.05, 0, 0, 55),  
	BackgroundTransparency = 0.5,  
	BackgroundColor3 = Color3.fromRGB(45, 45, 55),  
	BorderSizePixel = 0,  
	CanvasSize = UDim2.new(0, 0, 0, 0),  
	ScrollBarThickness = 8,  
	Parent = playersFrame  
})

local playerListCorner = createInstance("UICorner", {  
	CornerRadius = UDim2.new(0, 8),  
	Parent = playerListFrame  
})

local playerListLayout = createInstance("UIListLayout", {  
	Padding = UDim.new(0, 5),  
	FillDirection = Enum.FillDirection.Vertical,  
	Parent = playerListFrame  
})

local refreshPlayersBtn = createInstance("TextButton", {  
	Text = "Refresh Players",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	Textcolor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 0.3,  
	BackgroundColor3 = Color3.fromRGB(70, 130, 180),  
	Size = UDim2.new(0.3, 0, 0, 35),  
	Position = UDim2.new(0.05, 0, 0, 270),  
	BorderSizePixel = 0,  
	Parent = playersFrame  
})

local refreshPlayersCorner = createInstance("UICorner", {  
	CornerRadius = UDim.new(0, 8),  
	Parent = refreshPlayersBtn  
})

local targetInfoFrame = createInstance("Frame", {  
	Size = UDim2.new(0.5, 0, 0, 180),  
	Position = UDim2.new(0.55, 0, 0, 270),  
	BackgroundTransparency = 0.3,  
	BackgroundColor3 = Color3.fromRGB(50, 50, 60),  
	BorderSizePixel = 0,  
	Visible = false,  
	Parent = playersFrame  
})

local targetInfoCorner = createInstance("UICorner", {  
	CornerRadius = UDim.new(0, 8),  
	Parent = targetInfoFrame  
})

local targetNameLabel = createInstance("TextLabel", {  
	Text = "Target: N/A",  
	TextScaled = true,  
	Font = Enum.Font.GothamBold,  
	TextColor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 30),  
	Position = UDim2.new(0, 0, 0, 0),  
	Parent = targetInfoFrame  
})

local targetDistanceLabel = createInstance("TextLabel", {  
	Text = "Distance: N/A",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	TextColor3 = Color3.fromRGB(200, 200, 200),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 25),  
	Position = UDim2.new(0, 0, 0, 35),  
	Parent = targetInfoFrame  
})

local targetCharLabel = createInstance("TextLabel", {  
	Text = "Character: N/A",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	TextColor3 = Color3.fromRGB(200, 200, 200),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 25),  
	Position = UDim2.new(0, 0, 0, 65),  
	Parent = targetInfoFrame  
})

local targetHumanoidLabel = createInstance("TextLabel", {  
	Text = "Humanoid: N/A",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	TextColor3 = Color3.fromRGB(200, 200, 200),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 25),  
	Position = UDim2.new(0, 0, 0, 95),  
	Parent = targetInfoFrame  
})

local targetBodyLabel = createInstance("TextLabel", {  
	Text = "Body Type: N/A",  
	TextScaled = true,  
	Font = Enum.Font.Gotham,  
	TextColor3 = Color3.fromRGB(200, 200, 200),  
	BackgroundTransparency = 1,  
	Size = UDim2.new(1, 0, 0, 25),  
	Position = UDim2.new(0, 0, 0, 125),  
	Parent = targetInfoFrame  
})

local selectPlayerBtn = createInstance("TextButton", {  
	Text = "SELECT PLAYER",  
	TextScaled = true,  
	Font = Enum.Font.GothamBold,  
	Textcolor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 0.4,  
	BackgroundColor3 = Color3.fromRGB(70, 130, 180),  
	Size = UDim2.new(0.3, 0, 0, 30),  
	Position = UDim2.new(0.05, 0, 0, 310),  
	BorderSizePixel = 0,  
	Visible = false,  
	Parent = playersFrame  
})

-- REMOTES TAB  
local remotesFrame = tabFrames[2]

local scanRemotesBtn = createInstance("TextButton", {  
	Text = "SCAN REMOTES",  
	TextScaled = true,  
	Font = Enum.Font.GothamBold,  
	Textcolor3 = Color3.fromRGB(255, 255, 255),  
	BackgroundTransparency = 0.4,  
	BackgroundColor3 = Color3.fromRGB(70, 130, 180),  
	Size = UDim2.new(0.2, 0, 0, 35),  
	Position = UDim2.new(0.05, 0, 0, 10),  
	BorderSizePixel = 0,  
	Parent = remotesFrame  
})

local scanRemotesCorner = createInstance("UICorner", {  
	CornerRadius = UDim.new(0, 8),  
	Parent = scanRemotesBtn  
})

local refreshRemotesBtn = create
