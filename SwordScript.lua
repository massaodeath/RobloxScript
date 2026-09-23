local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local DAMAGE = 25
local ATTACK_COOLDOWN = 0.65
local ATTACK_TIME = 0.35
local Player = nil
local Character = nil
local Humanoid = nil

local Equipped = false
local Attacking = false

local AlreadyHit = {}

local LastAttack = 0

local Remotes =
	ReplicatedStorage:WaitForChild("Remotes")

local EnemyDefeatEvent =
	Remotes:WaitForChild("EnemyDefeatEvent")



local function TagHumanoid(TargetHumanoid)

	if not Player then
		return
	end


	-- Remove tag antiga
	local OldTag =
		TargetHumanoid:FindFirstChild("creator")


	if OldTag then
		OldTag:Destroy()
	end


	-- Cria nova tag
	local CreatorTag =
		Instance.new("ObjectValue")


	CreatorTag.Name =
		"creator"


	CreatorTag.Value =
		Player


	CreatorTag.Parent =
		TargetHumanoid


	-- Remove a tag depois de 2 segundos
	Debris:AddItem(
		CreatorTag,
		2
	)

end

local function OnTouched(Hit)

	-- Espada precisa estar equipada
	if not Equipped then
		return
	end


	-- Precisa estar atacando
	if not Attacking then
		return
	end


	if not Hit then
		return
	end


	-- Procura o Model do inimigo
	local EnemyModel =
		Hit:FindFirstAncestorOfClass("Model")


	if not EnemyModel then
		return
	end


	-- Não pode acertar o próprio jogador
	if EnemyModel == Character then
		return
	end


	-- Procura o Humanoid
	local EnemyHumanoid =
		EnemyModel:FindFirstChildOfClass(
			"Humanoid"
		)


	if not EnemyHumanoid then
		return
	end


	-- Ignora inimigos já derrotados
	if EnemyHumanoid.Health <= 0 then
		return
	end


	-- Ignora inimigos que já estão no processo
	-- de respawn
	if EnemyModel:GetAttribute(
		"HandledDeath"
		) then
		return
	end


	-- Evita acertar o mesmo inimigo
	-- várias vezes no mesmo ataque
	if AlreadyHit[EnemyHumanoid] then
		return
	end


	AlreadyHit[EnemyHumanoid] = true


	-- Marca quem causou o dano
	TagHumanoid(
		EnemyHumanoid
	)

	if EnemyHumanoid.Health <= DAMAGE then


		print(
			"☠️ GOLPE FINAL:",
			EnemyModel.Name,
			"| Vida antes:",
			EnemyHumanoid.Health
		)

		EnemyHumanoid.Health = 1


		-- Avisa o QuestServer
		EnemyDefeatEvent:Fire(
			EnemyModel,
			Player
		)

	else


		EnemyHumanoid:TakeDamage(
			DAMAGE
		)


		print(
			"Acertou:",
			EnemyModel.Name,
			"| Vida:",
			EnemyHumanoid.Health
		)

	end

end

local function Attack()

	-- Precisa estar equipada
	if not Equipped then
		return
	end


	-- Precisa ter Humanoid
	if not Humanoid then
		return
	end


	-- Jogador não pode estar morto
	if Humanoid.Health <= 0 then
		return
	end


	-- Tempo atual
	local Now =
		os.clock()


	-- Cooldown
	if Now - LastAttack
		< ATTACK_COOLDOWN then

		return

	end


	-- Atualiza último ataque
	LastAttack =
		Now


	-- Limpa inimigos atingidos
	AlreadyHit = {}


	-- Começa ataque
	Attacking = true


	print(
		"⚔️ ATAQUE!"
	)


	-- Finaliza a janela de ataque
	task.delay(
		ATTACK_TIME,
		function()

			Attacking = false

		end
	)

end

local function OnEquipped()

	-- Pega personagem
	Character =
		Tool.Parent


	-- Pega jogador
	Player =
		Players:GetPlayerFromCharacter(
			Character
		)


	if not Player then
		return
	end


	-- Pega Humanoid
	Humanoid =
		Character:FindFirstChildOfClass(
			"Humanoid"
		)


	if not Humanoid then
		return
	end


	-- Marca como equipada
	Equipped = true


	print(
		"ClassicSword equipada por",
		Player.Name
	)

end

local function OnUnequipped()

	Equipped = false

	Attacking = false

	AlreadyHit = {}


	print(
		" ClassicSword desequipada"
	)

end

Tool.Equipped:Connect(
	OnEquipped
)


Tool.Unequipped:Connect(
	OnUnequipped
)


Tool.Activated:Connect(
	Attack
)


Handle.Touched:Connect(
	OnTouched
)
