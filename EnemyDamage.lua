local Players = game:GetService("Players")

local enemy = script.Parent
local humanoid = enemy:WaitForChild("Humanoid")
local root = enemy:WaitForChild("HumanoidRootPart")

local DAMAGE = 10
local RANGE = 5
local COOLDOWN = 1.5
local lastHit = {}

while humanoid.Health > 0 do
	local nearestCharacter = nil
	local nearestDistance = RANGE

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local playerHumanoid = character and character:FindFirstChildOfClass("Humanoid")
		local playerRoot = character and character:FindFirstChild("HumanoidRootPart")

		if playerHumanoid and playerRoot and playerHumanoid.Health > 0 then
			local distance = (root.Position - playerRoot.Position).Magnitude
			if distance <= nearestDistance then
				nearestCharacter = character
				nearestDistance = distance
			end
		end
	end

	if nearestCharacter then
		local playerHumanoid = nearestCharacter:FindFirstChildOfClass("Humanoid")
		local now = os.clock()
		if now - (lastHit[nearestCharacter] or 0) >= COOLDOWN then
			lastHit[nearestCharacter] = now
			playerHumanoid:TakeDamage(DAMAGE)
		end
	end

	task.wait(0.2)
end