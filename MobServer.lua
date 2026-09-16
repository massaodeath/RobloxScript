local mobsFolder = workspace:WaitForChild("Mobs")

local RESPAWN_TIME = 15

local function hideMob(mob)
	for _, object in ipairs(mob:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Transparency = 1
			object.CanCollide = false

		elseif object:IsA("Decal") then
			object.Transparency = 1

		elseif object:IsA("ParticleEmitter") then
			object.Enabled = false

		elseif object:IsA("BillboardGui") then
			object.Enabled = false
		end
	end
end

local function showMob(mob)
	for _, object in ipairs(mob:GetDescendants()) do
		if object:IsA("BasePart") then
			if object.Name == "HumanoidRootPart" then
				object.Transparency = 1
			else
				object.Transparency = 0
			end

			object.CanCollide = true

		elseif object:IsA("Decal") then
			object.Transparency = 0

		elseif object:IsA("ParticleEmitter") then
			object.Enabled = true

		elseif object:IsA("BillboardGui") then
			object.Enabled = true
		end
	end
end

local function setupMob(mob)
	if not mob:IsA("Model") then
		return
	end

	local humanoid = mob:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("O mob não possui Humanoid:", mob.Name)
		return
	end

	humanoid.Died:Connect(function()
		print(mob.Name .. " morreu")

		hideMob(mob)

		task.wait(RESPAWN_TIME)

		humanoid.Health = humanoid.MaxHealth

		showMob(mob)

		print(mob.Name .. " renasceu")
	end)
end

for _, mob in ipairs(mobsFolder:GetChildren()) do
	setupMob(mob)
end

mobsFolder.ChildAdded:Connect(function(mob)
	setupMob(mob)
end)