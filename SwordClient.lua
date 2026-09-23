local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttackRemote")

tool.Activated:Connect(function()
	attackRemote:FireServer()
end)
