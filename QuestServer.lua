local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

print("QUEST SYSTEM INICIANDO")

local Remotes =
	ReplicatedStorage:WaitForChild("Remotes")

local QuestRemote =
	Remotes:WaitForChild("QuestRemote")

local EnemyDefeatEvent =
	Remotes:WaitForChild("EnemyDefeatEvent")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local QuestConfig =
	require(Shared:WaitForChild("QuestConfig"))

local MobsFolder =
	workspace:WaitForChild("Mobs")

local ItemDrops =
	ServerStorage:WaitForChild("ItemDrops")

print("Pastas encontradas")
print("QuestConfig carregado")
print("EnemyDefeatEvent conectado")

local REQUIRED_KILLS =
	QuestConfig.RequiredKills

local REWARD_XP =
	QuestConfig.RewardXP

local REWARD_GOLD =
	QuestConfig.RewardGold

local RESPAWN_HEIGHT = 500

local ActiveQuests = {}

local function CreateLeaderstats(Player)

	local leaderstats =
		Player:FindFirstChild("leaderstats")

	if not leaderstats then

		leaderstats =
			Instance.new("Folder")

		leaderstats.Name = "leaderstats"
		leaderstats.Parent = Player

	end

	local Gold =
		leaderstats:FindFirstChild("Gold")

	if not Gold then

		Gold =
			Instance.new("IntValue")

		Gold.Name = "Gold"
		Gold.Value = 0
		Gold.Parent = leaderstats

	end

	local XP =
		leaderstats:FindFirstChild("XP")

	if not XP then

		XP =
			Instance.new("IntValue")

		XP.Name = "XP"
		XP.Value = 0
		XP.Parent = leaderstats

	end

end

local function UpdateHUD(Player)

	local QuestData =
		ActiveQuests[Player]

	if not QuestData then
		return
	end

	QuestRemote:FireClient(
		Player,
		"Progress",
		QuestData.Kills,
		REQUIRED_KILLS
	)

end

local function StartQuest(Player)

	if ActiveQuests[Player] then

		QuestRemote:FireClient(
			Player,
			"Message",
			"Você já possui esta missão!"
		)

		return
	end

	ActiveQuests[Player] = {

		Kills = 0,

		Completed = false,

	}

	print(
		"QUEST INICIADA:",
		Player.Name
	)

	QuestRemote:FireClient(
		Player,
		"Started",
		QuestConfig.QuestName,
		REQUIRED_KILLS
	)

	UpdateHUD(Player)

end

local function GiveRewards(Player)

	local leaderstats =
		Player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local Gold =
		leaderstats:FindFirstChild("Gold")

	local XP =
		leaderstats:FindFirstChild("XP")

	if Gold then
		Gold.Value += REWARD_GOLD
	end

	if XP then
		XP.Value += REWARD_XP
	end

	print(
		" RECOMPENSA:",
		Player.Name,
		"| Gold +",
		REWARD_GOLD,
		"| XP +",
		REWARD_XP
	)

end

local function GiveDrop(Player, Enemy)

	local EnemyConfig =
		QuestConfig.Enemies[Enemy.Name]

	if not EnemyConfig then
		return
	end

	local DropChance =
		EnemyConfig.DropChance or 0

	local Roll =
		math.random(1, 100)

	print(
		"🎲 DROP:",
		Enemy.Name,
		"| Chance:",
		DropChance,
		"| Resultado:",
		Roll
	)

	if Roll > DropChance then

		print("Não dropou item")

		return
	end

	local Drop =
		ItemDrops:FindFirstChild("QuestCrystal")

	if not Drop then

		warn(
			"QuestCrystal não encontrado em ServerStorage > ItemDrops"
		)

		return
	end

	local Character =
		Player.Character

	if not Character then
		return
	end

	local Backpack =
		Player:FindFirstChild("Backpack")

	if not Backpack then
		return
	end

	local NewDrop =
		Drop:Clone()

	NewDrop.Parent = Backpack

	print(
		"DROP ENTREGUE:",
		Player.Name,
		"recebeu QuestCrystal"
	)

end

local function HideEnemy(Enemy)

	if not Enemy then
		return
	end

	if Enemy:GetAttribute("HandledDeath") then
		return
	end

	Enemy:SetAttribute(
		"HandledDeath",
		true
	)

	local Humanoid =
		Enemy:FindFirstChildOfClass("Humanoid")

	local Root =
		Enemy:FindFirstChild("HumanoidRootPart")

	if not Root then

		warn(
			"HumanoidRootPart não encontrado:",
			Enemy.Name
		)

		return
	end


	if not Enemy:GetAttribute("OriginalX") then

		local Position =
			Root.Position

		Enemy:SetAttribute(
			"OriginalX",
			Position.X
		)

		Enemy:SetAttribute(
			"OriginalY",
			Position.Y
		)

		Enemy:SetAttribute(
			"OriginalZ",
			Position.Z
		)

	end

	for _, Object in ipairs(
		Enemy:GetDescendants()
		) do

		if Object:IsA("BasePart") then

			Object.Transparency = 1
			Object.CanCollide = false
			Object.CanTouch = false

		elseif Object:IsA("Decal") then

			Object.Transparency = 1

		end

	end

	Root.CFrame =
		Root.CFrame *
		CFrame.new(0, -RESPAWN_HEIGHT, 0)

	if Humanoid then

		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
		Humanoid.Health = 1

	end

	print(
		"INIMIGO ESCONDIDO:",
		Enemy.Name
	)

end

local function RespawnEnemy(Enemy)

	if not Enemy then
		return
	end

	local Root =
		Enemy:FindFirstChild("HumanoidRootPart")

	local Humanoid =
		Enemy:FindFirstChildOfClass("Humanoid")

	if not Root then
		return
	end

	local X =
		Enemy:GetAttribute("OriginalX")

	local Y =
		Enemy:GetAttribute("OriginalY")

	local Z =
		Enemy:GetAttribute("OriginalZ")

	if X and Y and Z then

		Root.CFrame =
			CFrame.new(X, Y, Z)

	end

	for _, Object in ipairs(
		Enemy:GetDescendants()
		) do

		if Object:IsA("BasePart") then

			Object.Transparency = 0
			Object.CanCollide = true
			Object.CanTouch = true

		elseif Object:IsA("Decal") then

			Object.Transparency = 0

		end

	end

	if Humanoid then

		Humanoid.Health =
			Humanoid.MaxHealth

		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50

	end

	Enemy:SetAttribute(
		"HandledDeath",
		false
	)

	print(
		"INIMIGO RENASCEU:",
		Enemy.Name
	)

end

local function ProcessEnemyDefeat(
	Enemy,
	Player
)

	if not Enemy then
		return
	end

	if not Player then
		return
	end

	if not Enemy:IsDescendantOf(MobsFolder) then

		warn(
			"Inimigo não está dentro de Workspace > Mobs"
		)

		return
	end

	print(
		"☠️ PROCESSANDO DERROTA:",
		Enemy.Name,
		"| Jogador:",
		Player.Name
	)

	local QuestData =
		ActiveQuests[Player]

	if QuestData then

		if not QuestData.Completed then

			QuestData.Kills += 1

			print(
				"PROGRESSO:",
				Player.Name,
				QuestData.Kills,
				"/",
				REQUIRED_KILLS
			)

			UpdateHUD(Player)

			QuestRemote:FireClient(
				Player,
				"Kill",
				QuestData.Kills,
				REQUIRED_KILLS,
				Enemy.Name
			)

			if QuestData.Kills >= REQUIRED_KILLS then

				QuestData.Completed = true

				print(
					"QUEST COMPLETADA:",
					Player.Name
				)

				GiveRewards(Player)

				QuestRemote:FireClient(
					Player,
					"Completed",
					REWARD_XP,
					REWARD_GOLD
				)

			end

		end

	else

		print(
			"Jogador não possui quest ativa:",
			Player.Name
		)

	end

	GiveDrop(
		Player,
		Enemy
	)

	HideEnemy(Enemy)

	local EnemyConfig =
		QuestConfig.Enemies[Enemy.Name]

	local RespawnTime = 15

	if EnemyConfig then

		RespawnTime =
			EnemyConfig.RespawnTime or 15

	end

	task.delay(
		RespawnTime,
		function()

			if Enemy and Enemy.Parent then

				RespawnEnemy(
					Enemy
				)

			end

		end
	)

end

EnemyDefeatEvent.Event:Connect(
	ProcessEnemyDefeat
)

local QuestNPC =
	workspace:WaitForChild("Quest NPC")

local QuestPrompt =
	QuestNPC:FindFirstChildWhichIsA(
		"ProximityPrompt",
		true
	)

if QuestPrompt then

	print(
		"ProximityPrompt encontrado no Quest NPC"
	)

	QuestPrompt.Triggered:Connect(
		function(Player)

			StartQuest(Player)

		end
	)

else

	warn(
		" Nenhum ProximityPrompt encontrado dentro de Quest NPC!"
	)

end

Players.PlayerAdded:Connect(
	function(Player)

		CreateLeaderstats(
			Player
		)

		print(
			"👤 Jogador entrou:",
			Player.Name
		)

	end
)

for _, Player in ipairs(
	Players:GetPlayers()
	) do

	CreateLeaderstats(
		Player
	)

end

Players.PlayerRemoving:Connect(
	function(Player)

		ActiveQuests[Player] = nil

		print(
			"Jogador saiu:",
			Player.Name
		)

	end
)
