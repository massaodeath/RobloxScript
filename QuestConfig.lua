local QuestConfig = {}

QuestConfig.QuestName = "Caçador de Bandidos"

QuestConfig.RequiredKills = 3

QuestConfig.RewardXP = 100
QuestConfig.RewardGold = 50

QuestConfig.Enemies = {

	Bandit1 = {
		DisplayName = "Bandido da Ponte",
		RespawnTime = 15,
		DropChance = 35,
	},

	Bandit2 = {
		DisplayName = "Bandido da Floresta",
		RespawnTime = 15,
		DropChance = 35,
	},

	Bandit3 = {
		DisplayName = "Chefe Bandido",
		RespawnTime = 15,
		DropChance = 100,
	},

}

QuestConfig.AttackDamage = 25
QuestConfig.AttackRange = 12
QuestConfig.AttackCooldown = 0.65

return QuestConfig
