local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local questSystem = ReplicatedStorage:WaitForChild("QuestSystem")

local questEvent = questSystem:WaitForChild("QuestEvent")

local questConfig = require(
	questSystem:WaitForChild("QuestConfig")
)

local questData = {}

-- criar daodos do jogador

local function setupPlayer(player)

	questData[player] = {

		Active = false,

		Completed = false,

		Kills = 0
	}

end

-- remover dados

local function removePlayer(player)

	questData[player] = nil

end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(removePlayer)

-- aceitar quest

local function acceptQuest(player, questId)

	local data = questData[player]

	if not data then
		return
	end

	local quest = questConfig[questId]

	if not quest then
		return
	end

	if data.Active then
		return
	end

	if data.Completed then
		return
	end

	data.Active = true
	data.Kills = 0

	questEvent:FireClient(
		player,
		"QuestAccepted",
		questId,
		data.Kills,
		quest.RequiredKills
	)

end

-- contar morte do mob

local function registerMobKill(player, mob)

	local data = questData[player]

	if not data then
		return
	end

	if not data.Active then
		return
	end

	local quest = questConfig["SlimeHunt"]

	if not quest then
		return
	end

	if mob.Name ~= quest.TargetMob then
		return
	end

	data.Kills += 1

-- atualizar cliente

	questEvent:FireClient(
		player,
		"QuestProgress",
		"SlimeHunt",
		data.Kills,
		quest.RequiredKills
	)
	
-- quest completa

	if data.Kills >= quest.RequiredKills then

		data.Active = false
		data.Completed = true

-- recompensa

		local leaderstats = player:FindFirstChild("leaderstats")

		if leaderstats then

			local coins = leaderstats:FindFirstChild("Coins")

			if coins then

				coins.Value += quest.RewardCoins

			end

			local xp = leaderstats:FindFirstChild("XP")

			if xp then

				xp.Value += quest.RewardXP

			end

		end

		questEvent:FireClient(
			player,
			"QuestCompleted",
			"SlimeHunt",
			quest.RewardCoins,
			quest.RewardXP
		)

	end

end

-- receber evento dos clientes

questEvent.OnServerEvent:Connect(function(
	player,
	action,
	questId
)

	if action == "AcceptQuest" then

		acceptQuest(
			player,
			questId
		)

	end

end)

-- funcao global pra registrar kill

_G.RegisterQuestMobKill = registerMobKill