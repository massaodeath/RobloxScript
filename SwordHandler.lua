local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Tool = script.Parent

local CombatSystem = ReplicatedStorage:WaitForChild("CombatSystem")
local CombatEvent = CombatSystem:WaitForChild("CombatEvent")

local character
local humanoid
local animator

local animations
local idleTrack
local attackTrack

local equipped = false
local attacking = false

local function SetupCharacter()

	character = player.Character
		or player.CharacterAdded:Wait()

	humanoid = character:WaitForChild("Humanoid")

	animator = humanoid:WaitForChild("Animator")

	animations = Tool:WaitForChild("Animations")

	idleTrack = animator:LoadAnimation(
		animations:WaitForChild("Idle")
	)

	idleTrack.Priority = Enum.AnimationPriority.Idle

	attackTrack = animator:LoadAnimation(
		animations:WaitForChild("Attack")
	)

	attackTrack.Priority = Enum.AnimationPriority.Action

	attackTrack:GetMarkerReachedSignal("Hit1"):Connect(function()

		if not equipped then
			return
		end

		print("HIT 1")

		CombatEvent:FireServer("Hit1")

	end)
	
	attackTrack:GetMarkerReachedSignal("Hit2"):Connect(function()

		if not equipped then
			return
		end

		print("HIT 2")

		CombatEvent:FireServer("Hit2")

	end)


	attackTrack:GetMarkerReachedSignal("Hit3"):Connect(function()

		if not equipped then
			return
		end

		print("HIT 3")

		CombatEvent:FireServer("Hit3")

	end)

	attackTrack:GetMarkerReachedSignal("Hit4"):Connect(function()

		if not equipped then
			return
		end

		print("HIT 4")

		CombatEvent:FireServer("Hit4")

	end)

	attackTrack:GetMarkerReachedSignal("Ragdoll"):Connect(function()

		if not equipped then
			return
		end

		print("RAGDOLL")

		CombatEvent:FireServer("Ragdoll")

	end)

end

SetupCharacter()

Tool.Equipped:Connect(function()

	equipped = true
	attacking = false

	if idleTrack then
		idleTrack:Play()
	end

end)

Tool.Unequipped:Connect(function()

	equipped = false
	attacking = false

	if idleTrack then
		idleTrack:Stop()
	end

	if attackTrack and attackTrack.IsPlaying then
		attackTrack:Stop()
	end

end)

Tool.Activated:Connect(function()

	if not equipped then
		return
	end

	if attacking then
		return
	end

	if not attackTrack then
		return
	end

	attacking = true

	if idleTrack and idleTrack.IsPlaying then
		idleTrack:Stop()
	end

	attackTrack:Play()

	attackTrack.Stopped:Wait()

	if equipped then

		attacking = false

		if idleTrack and not idleTrack.IsPlaying then
			idleTrack:Play()
		end

	else

		attacking = false

	end

end)

player.CharacterAdded:Connect(function()

	task.wait(0.2)

	SetupCharacter()

end)