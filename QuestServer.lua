local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local attackRemote = remotes:WaitForChild("AttackRemote")
local questRemote = remotes:WaitForChild("QuestRemote")
local QuestConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("QuestConfig"))

local enemiesFolder = Workspace:WaitForChild("Enemies")
local questGiver = Workspace:WaitForChild("QuestGiver")
local prompt = questGiver:WaitForChild("Head"):WaitForChild("QuestPrompt")

local worldDrops = Workspace:FindFirstChild("ItemDrops")
if not worldDrops then
	worldDrops = Instance.new("Folder")
	worldDrops.Name = "ItemDrops"
	worldDrops.Parent = Workspace
end

local itemTemplates = ServerStorage:WaitForChild("ItemDrops")

-- Estado somente no servidor. O cliente nunca recebe permissão para alterá-lo.
local questStates = {}
local lastAttackAt = {}
local lastDamager = {}
local spawnCFrames = {}
local connectEnemy

local function getState(player)
	if not questStates[player] then
		questStates[player] = {
			active = false,
			defeated = {},
		}
	end

	return questStates[player]
end

local function countDefeated(state)
	local count = 0
	for _ in pairs(state.defeated) do
		count += 1
	end
	return count
end

local function sendHud(player, message)
	local state = getState(player)
	questRemote:FireClient(player, {
		active = state.active,
		progress = countDefeated(state),
		total = QuestConfig.RequiredKills,
		message = message,
	})
end

local function setEnemyEnabled(enemy, enabled)
	for _, object in ipairs(enemy:GetDescendants()) do
		if object:IsA("BasePart") then
			if enabled then
				object.Transparency = object:GetAttribute("QuestOriginalTransparency") or 0
				object.CanCollide = object:GetAttribute("QuestOriginalCanCollide") == true
				object.CanTouch = object:GetAttribute("QuestOriginalCanTouch") == true
				object.CanQuery = object:GetAttribute("QuestOriginalCanQuery") == true
			else
				-- Guardamos o estado inicial para restaurar corretamente no respawn.
				object:SetAttribute("QuestOriginalTransparency", object.Transparency)
				object:SetAttribute("QuestOriginalCanCollide", object.CanCollide)
				object:SetAttribute("QuestOriginalCanTouch", object.CanTouch)
				object:SetAttribute("QuestOriginalCanQuery", object.CanQuery)
				object.Transparency = 1
				object.CanCollide = false
				object.CanTouch = false
				object.CanQuery = false
			end
		elseif object:IsA("ParticleEmitter") or object:IsA("Trail") then
			object.Enabled = enabled
		end
	end
end

local function dropItem(position, enemyInfo)
	if math.random(1, 100) > enemyInfo.DropChance then
		return
	end

	local template = itemTemplates:FindFirstChild("QuestCrystal")
	if not template or not template:IsA("Tool") then
		warn("Crie ServerStorage.ItemDrops.QuestCrystal como Tool para habilitar drops.")
		return
	end

	local item = template:Clone()
	item.Parent = worldDrops
	local handle = item:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		warn("QuestCrystal precisa de uma Part chamada Handle.")
		item:Destroy()
		return
	end
	handle.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))

	-- Evita que drops esquecidos ocupem o mapa para sempre.
	task.delay(30, function()
		if item and item.Parent then
			item:Destroy()
		end
	end)
end

local function giveReward(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	leaderstats.XP.Value += QuestConfig.RewardXP
	leaderstats.Gold.Value += QuestConfig.RewardGold
end

local function onEnemyDied(enemy)
	local enemyInfo = QuestConfig.Enemies[enemy.Name]
	if not enemyInfo or enemy:GetAttribute("HandledDeath") then
		return
	end

	enemy:SetAttribute("HandledDeath", true)
	setEnemyEnabled(enemy, false)

	local root = enemy:FindFirstChild("HumanoidRootPart")
	local deathPosition = root and root.Position or enemy:GetPivot().Position
	local initialCFrame = spawnCFrames[enemy.Name] or enemy:GetPivot()
	-- -500 studs deixa o NPC bem abaixo do terreno enquanto aguarda o respawn.
	enemy:PivotTo(initialCFrame * CFrame.new(0, -500, 0))
	local killer = lastDamager[enemy]

	-- Só o jogador que realmente causou o último dano, com quest ativa,
	-- recebe progresso. Assim uma morte externa não pode completar a missão.
	if killer and killer.Parent == Players then
		local state = getState(killer)
		if state.active and not state.defeated[enemy.Name] then
			state.defeated[enemy.Name] = true
			dropItem(deathPosition, enemyInfo)

			local progress = countDefeated(state)
			if progress >= QuestConfig.RequiredKills then
				state.active = false
				giveReward(killer)
				sendHud(killer, "Quest concluída! +" .. QuestConfig.RewardXP .. " XP e +" .. QuestConfig.RewardGold .. " Gold")
			else
				sendHud(killer, "Você derrotou " .. enemyInfo.DisplayName .. "!")
			end
		end
	end

	local respawnTime = enemyInfo.RespawnTime
	local enemyName = enemy.Name
	task.delay(respawnTime, function()
		local humanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
		local spawnCFrame = spawnCFrames[enemyName]
		if enemy and enemy.Parent and humanoid and spawnCFrame then
			-- É o mesmo NPC: ele ficou invisível abaixo do mapa e volta ao ponto inicial.
			enemy:PivotTo(spawnCFrame)
			humanoid.Health = humanoid.MaxHealth
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			setEnemyEnabled(enemy, true)
			enemy:SetAttribute("HandledDeath", false)
			lastDamager[enemy] = nil
		end
	end)
end

connectEnemy = function(enemy)
	local enemyInfo = QuestConfig.Enemies[enemy.Name]
	if not enemyInfo then
		return
	end

	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	local root = enemy:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then
		warn(enemy.Name .. " precisa de Humanoid e HumanoidRootPart.")
		return
	end

	humanoid.BreakJointsOnDeath = false
	humanoid.Died:Connect(function()
		onEnemyDied(enemy)
	end)
end

for enemyName in pairs(QuestConfig.Enemies) do
	local enemy = enemiesFolder:WaitForChild(enemyName)
	local root = enemy:WaitForChild("HumanoidRootPart")
	spawnCFrames[enemyName] = root.CFrame

	connectEnemy(enemy)
end

local function closestValidEnemy(player)
	local character = player.Character
	local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then
		return nil
	end

	local closestEnemy = nil
	local closestDistance = QuestConfig.AttackRange

	for enemyName in pairs(QuestConfig.Enemies) do
		local enemy = enemiesFolder:FindFirstChild(enemyName)
		local humanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
		local root = enemy and enemy:FindFirstChild("HumanoidRootPart")
		if humanoid and root and humanoid.Health > 0 and not enemy:GetAttribute("HandledDeath") then
			local distance = (playerRoot.Position - root.Position).Magnitude
			if distance <= closestDistance then
				closestEnemy = enemy
				closestDistance = distance
			end
		end
	end

	return closestEnemy
end

attackRemote.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if now - (lastAttackAt[player] or 0) < QuestConfig.AttackCooldown then
		return
	end

	local character = player.Character
	-- O jogador deve estar segurando a Tool criada pelo servidor no StarterPack.
	if not character or not character:FindFirstChild("QuestSword") then
		return
	end

	local enemy = closestValidEnemy(player)
	if not enemy then
		return
	end

	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	lastAttackAt[player] = now
	lastDamager[enemy] = player
	humanoid:TakeDamage(QuestConfig.AttackDamage)
end)

prompt.Triggered:Connect(function(player)
	local state = getState(player)
	if state.active then
		sendHud(player, "Você já está nessa quest.")
		return
	end

	state.active = true
	state.defeated = {}
	sendHud(player, "Derrote Bandit1, Bandit2 e Bandit3.")
end)

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = 0
	xp.Parent = leaderstats

	local gold = Instance.new("IntValue")
	gold.Name = "Gold"
	gold.Value = 0
	gold.Parent = leaderstats

	getState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	questStates[player] = nil
	lastAttackAt[player] = nil
end)
