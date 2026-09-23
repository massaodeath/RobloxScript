local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttackRemote")

tool.Activated:Connect(function()
	-- Não mandamos alvo, dano, XP nem dinheiro. O servidor encontra e valida o alvo.
	attackRemote:FireServer()
end)