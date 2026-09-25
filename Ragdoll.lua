local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CombatSystem =
	ReplicatedStorage:WaitForChild("CombatSystem")

local CombatEvent =
	CombatSystem:WaitForChild("CombatEvent")

local DamageIndicator =
	ReplicatedStorage:WaitForChild("DamageIndicator")

local DamageEvent =
	DamageIndicator:WaitForChild("DamageEvent")

local Ragdoll =
	require(
		game.ServerScriptService:WaitForChild("Ragdoll")
	)

local DAMAGES = {
	Hit1 = 10,
	Hit2 = 12,
	Hit3 = 15,
	Hit4 = 25
}

local ATTACK_DISTANCE = 7
local HIT_COOLDOWN = 0.15
local RAGDOLL_TIME = 1.5

local lastHit = {}
local comboTargets = {}

local function FindClosestTarget(player)

	local character =
		player.Character

	if not character then
		return nil
	end

	local attackerRoot =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not attackerRoot then
		return nil
	end

	local closestCharacter = nil

	local closestDistance =
		ATTACK_DISTANCE

	-- Procura todos os modelos no Workspace

	for _, object in ipairs(
		workspace:GetDescendants()
		) do

		if object:IsA("Model")
			and object ~= character then

			local targetHumanoid =
				object:FindFirstChildOfClass(
					"Humanoid"
				)

			local targetRoot =
				object:FindFirstChild(
					"HumanoidRootPart"
				)

			-- Verifica se é um alvo válido

			if targetHumanoid
				and targetRoot
				and targetHumanoid.Health > 0 then

				local distance =
					(
						attackerRoot.Position
						- targetRoot.Position
					).Magnitude

				if distance <= closestDistance then

					local targetPlayer =
						Players:GetPlayerFromCharacter(
							object
						)

					-- Não pode atacar outro jogador
					-- nem a si mesmo

					if targetPlayer == nil then

						closestCharacter =
							object

						closestDistance =
							distance

					end

				end

			end

		end

	end

	return closestCharacter

end

local function DamageCharacter(
	player,
	target,
	damage
)

	if not target then
		return false
	end

	local humanoid =
		target:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	local attackerCharacter =
		player.Character

	if not attackerCharacter then
		return false
	end

	-- Não pode acertar a si mesmo

	if target == attackerCharacter then
		return false
	end

	humanoid:TakeDamage(damage)

	DamageEvent:FireAllClients(
		target,
		damage
	)

	return true

end

local function ApplyRagdoll(
	player,
	target
)

	if not target then
		return
	end

	local humanoid =
		target:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	local attackerCharacter =
		player.Character

	if not attackerCharacter then
		return
	end

	)

	Ragdoll.Start(
		target,
		attackerCharacter
	)

	task.delay(
		RAGDOLL_TIME,
		function()

			if target
				and target.Parent
				and humanoid
				and humanoid.Health > 0 then

				Ragdoll.Stop(target)

				print(
					"RAGDOLL REMOVIDO DE:",
					target.Name
				)

			end

		end
	)

end

CombatEvent.OnServerEvent:Connect(
	function(
		player,
		attackName
	)
		if typeof(attackName) ~= "string" then
			return
		end

		if attackName ~= "Hit1"
			and attackName ~= "Hit2"
			and attackName ~= "Hit3"
			and attackName ~= "Hit4" then

			return

		end

		local character =
			player.Character

		if not character then
			return
		end

		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)

		if not humanoid then
			return
		end

		if humanoid.Health <= 0 then
			return
		end

		local tool = nil

		for _, object in ipairs(
			character:GetChildren()
			) do

			if object:IsA("Tool") then

				tool = object

				break

			end

		end

		if not tool then
			return
		end

		local currentTime =
			os.clock()

		local previousHit =
			lastHit[player] or 0

		if currentTime - previousHit
			< HIT_COOLDOWN then

			return

		end

		lastHit[player] =
			currentTime

		if attackName == "Hit1" then

			-- Começou um novo combo

			comboTargets[player] = nil

			-- Procura um novo alvo

			local target =
				FindClosestTarget(player)

			if not target then
				return
			end

			-- Guarda o alvo para os próximos golpes

			comboTargets[player] =
				target

			local damage =
				DAMAGES.Hit1

			local hitSuccessful =
				DamageCharacter(
					player,
					target,
					damage
				)

			if not hitSuccessful then
				comboTargets[player] = nil
				return
			end

			print(
				player.Name,
				"acertou HIT 1 em",
				target.Name
			)

			return

		end

		if attackName == "Hit2" then

			local target =
				comboTargets[player]

			if not target then
				return
			end

			local damage =
				DAMAGES.Hit2

			local hitSuccessful =
				DamageCharacter(
					player,
					target,
					damage
				)

			if not hitSuccessful then
				return
			end

			print(
				player.Name,
				"acertou HIT 2 em",
				target.Name
			)

			return

		end


		if attackName == "Hit3" then

			local target =
				comboTargets[player]

			if not target then
				return
			end

			local damage =
				DAMAGES.Hit3

			local hitSuccessful =
				DamageCharacter(
					player,
					target,
					damage
				)

			if not hitSuccessful then
				return
			end

			print(
				player.Name,
				"acertou HIT 3 em",
				target.Name
			)

			return

		end

		if attackName == "Hit4" then

			local target =
				comboTargets[player]

			if not target then
				return
			end

			local damage =
				DAMAGES.Hit4

			-- Causa o dano

			local hitSuccessful =
				DamageCharacter(
					player,
					target,
					damage
				)

			if not hitSuccessful then
				return
			end

			print(
				player.Name,
				"acertou HIT 4 em",
				target.Name
			)

			ApplyRagdoll(
				player,
				target
			)
			
			comboTargets[player] = nil

			return

		end

	end
)

Players.PlayerRemoving:Connect(
	function(player)

		lastHit[player] = nil

		comboTargets[player] = nil

	end
)