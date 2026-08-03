local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local WALK_ANIMATION_ID = "rbxassetid://656118852" -- Default Roblox walk animation
local runAnimationTrack = nil
local walkAnimationTrack = nil

local function loadAnimations()
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = WALK_ANIMATION_ID
    walkAnimationTrack = animator:LoadAnimation(walkAnim)
    walkAnimationTrack.Priority = Enum.AnimationPriority.Movement
end

loadAnimations()

local lastState = false

RunService.RenderStepped:Connect(function()
    if not humanoid or not walkAnimationTrack then return end
    
    local speed = humanoid.MoveDirection.Magnitude
    local isMoving = speed > 0.1

    if isMoving and not lastState then
        walkAnimationTrack:Play(0.25, 1, 1)
        lastState = true
    elseif not isMoving and lastState then
        walkAnimationTrack:Stop(0.25)
        lastState = false
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:WaitForChild("Animator")
    loadAnimations()
    lastState = false
end)
