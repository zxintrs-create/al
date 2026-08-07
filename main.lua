-- [[ DELTA ULTIMATE AUTO-WALK RECORDER & TIMELINE STITCHING SYSTEM ]] --  
-- Developed by Delta maker script for Aldo Tzy  
-- Features: Visual Line, Smart Timeline Cut, Seamless Playback, Precise Rollback

local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local TweenService = game:GetService("TweenService")  
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local RootPart = Character:WaitForChild("HumanoidRootPart")  
local Humanoid = Character:WaitForChild("Humanoid")

-- // CONFIGURATION // --  
local CONFIG = {  
    NodeInterval = 0.05, -- Capture every 0.05 seconds for extreme precision  
    VisualLineColor = Color3.fromRGB(0, 255, 255),  
    VisualLineThickness = 0.1,  
    MaxError = 0.05,  
    PlaybackSpeed = 1  
}

-- // STATE VARIABLES // --  
local isRecording = false  
local isPlaying = false  
local timeline = {} -- Stores {CFrame, State}  
local visualNodes = {} -- Stores visual parts  
local lastCaptureTime = 0

-- // VISUAL LINE SYSTEM // --  
local function createNodeVisual(pos1, pos2)  
    local distance = (pos1 - pos2).Magnitude  
    if distance < 0.01 then return end  
      
    local line = Instance.new("Part")  
    line.Size = Vector3.new(CONFIG.VisualLineThickness, CONFIG.VisualLineThickness, distance)  
    line.CFrame = CFrame.new(pos1:Lerp(pos2, 0.5), pos2)  
    line.Anchored = true  
    line.CanCollide = false  
    line.Material = Enum.Material.Neon  
    line.Color = CONFIG.VisualLineColor  
    line.Parent = workspace:FindFirstChild("DeltaVisuals") or Instance.new("Folder", workspace)  
    line.Name = "VisualNode"  
      
    table.insert(visualNodes, line)  
end

local function clearVisualLine()  
    for _, node in ipairs(visualNodes) do  
        node:Destroy()  
    end  
    visualNodes = {}  
end

-- // CORE LOGIC // --

-- Recording Process  
RunService.Heartbeat:Connect(function()  
    if not isRecording then return end  
      
    local now = tick()  
    if now - lastCaptureTime >= CONFIG.NodeInterval then  
        lastCaptureTime = now  
          
        local currentCFrame = RootPart.CFrame  
        local currentState = Humanoid:GetState()  
          
        -- Create Visual Line  
        if #timeline > 0 then  
            createNodeVisual(timeline[#timeline].CFrame.Position, currentCFrame.Position)  
        end  
          
        -- Record Frame  
        table.insert(timeline, {  
            CFrame = currentCFrame,  
            State = currentState  
        })  
    end  
end)

-- Playback Process (Automatic Character Control)  
local function playPlayback()  
    if #timeline == 0 then return end  
    isPlaying = true  
      
    -- Disable player control  
    Humanoid.WalkSpeed = 0  
    Humanoid.JumpPower = 0  
      
    for i = 1, #timeline do  
        if not isPlaying then break end  
          
        local target = timeline[i]  
        local duration = CONFIG.NodeInterval / CONFIG.PlaybackSpeed  
          
        -- Smooth Interpolation (No Teleporting)  
        local tween = TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = target.CFrame})  
        tween:Play()  
          
        -- Handle Jump State  
        if target.State == Enum.HumanoidStateType.Jumping then  
            Humanoid.Jump = true  
        end  
          
        TweenService:Create(RootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = target.CFrame}):Play()  
          
        task.wait(duration)  
    end  
      
    isPlaying = false  
    Humanoid.WalkSpeed = 16  
    Humanoid.JumpPower = 50  
end

-- ROLLBACK: Timeline Cut & Stitching  
local function rollbackToSafePoint()  
    -- This system looks for the last frame where character was NOT falling/teleporting  
    local safeIndex = #timeline  
      
    for i = #timeline, 1, -1 do  
        local frame = timeline[i]  
        -- Definition of "Invalid": Falling or huge distance jump (Teleport)  
        if i > 1 then  
            local dist = (frame.CFrame.Position - timeline[i-1].CFrame.Position).Magnitude  
            if dist > 5 or frame.State == Enum.HumanoidStateType.FallingDown or frame.State == Enum.HumanoidStateType.Freefall then  
                safeIndex = i - 1  
                -- Keep looking back until we find a stable grounded frame  
            else  
                break  
            end  
        end  
    end  
      
    -- 1. CUT THE TIMELINE (Discard invalid frames)  
    for i = #timeline, safeIndex + 1, -1 do  
        table.remove(timeline, i)  
        -- 2. EDIT VISUAL LINE (Remove corresponding visuals)  
        if visualNodes[i] then  
            visualNodes[i]:Destroy()  
            table.remove(visualNodes, i)  
        end  
    end  
      
    -- 3. STITCHING: Move character back to safe point instantly but resume flow  
    if #timeline > 0 then  
        RootPart.CFrame = timeline[#timeline].CFrame  
    end  
      
    print("Timeline Stitched! Invalid frames removed. Safe point restored.")  
end

-- // KEYBINDS // --  
UserInputService.InputBegan:Connect(function(input, gameProcessed)  
    if gameProcessed then return end  
      
    if input.KeyCode == Enum.KeyCode.R then -- Record Toggle  
        isRecording = not isRecording  
        if isRecording then   
            timeline = {}   
            clearVisualLine()  
            print("Recording Started...")   
        else   
            print("Recording Saved!")   
        end  
    elseif input.KeyCode == Enum.KeyCode.P then -- Play  
        if not isRecording then  
            playPlayback()  
        end  
    elseif input.KeyCode == Enum.KeyCode.X then -- Rollback (Stitch)  
        rollbackToSafePoint()  
    end  
end)

print("HEY")
print("I'M KNIGHTXORZ")  
