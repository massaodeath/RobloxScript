local ReplicatedStorage = game:GetService("ReplicatedStorage")

local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent")

local DAMAGE = 25
local ATTACK_DISTANCE = 12

combatEvent.OnServerEvent:Connect(function(player)
	print("ATAQUE RECEBIDO DE:", player.Name)

	local character = player.Character

	if not character then
		warn("Personagem do jogador não encontrado")
		return
	end

	local playerRoot = character:FindFirstChild("HumanoidRootPart")

	if not playerRoot then
		warn("HumanoidRootPart do jogador não encontrado")
		return
	end

	local mobsFolder = workspace:FindFirstChild("Mobs")

	if not mobsFolder then
		warn("A pasta Mobs não existe no Workspace")
		return
	end

	for _, mob in ipairs(mobsFolder:GetChildren()) do
		local mobHumanoid = mob:FindFirstChildOfClass("Humanoid")
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")

		if mobHumanoid and mobRoot then
			if mobHumanoid.Health > 0 then
				local distance = (
					playerRoot.Position - mobRoot.Position
				).Magnitude

				print("Distância até", mob.Name, ":", distance)

				if distance <= ATTACK_DISTANCE then
					mobHumanoid:TakeDamage(DAMAGE)

					print(
						"DANO APLICADO!",
						mob.Name,
						"Vida atual:",
						mobHumanoid.Health
					)

					return
				end
			end
		end
	end

	warn("Nenhum Slime encontrado perto do jogador")
end)