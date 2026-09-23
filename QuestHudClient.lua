local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = script.Parent
local panel = gui:WaitForChild("Panel")
local objectiveLabel = panel:WaitForChild("ObjectiveLabel")
local progressLabel = panel:WaitForChild("ProgressLabel")
local questRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("QuestRemote")

questRemote.OnClientEvent:Connect(function(data)
	progressLabel.Text = string.format("Progresso: %d/%d", data.progress, data.total)

	if data.active then
		objectiveLabel.Text = "Objetivo: derrotar os 3 bandidos"
	else
		objectiveLabel.Text = data.message or "Fale com o NPC para começar uma quest"
	end

	if data.message and data.active then
		objectiveLabel.Text = data.message
	end
end)