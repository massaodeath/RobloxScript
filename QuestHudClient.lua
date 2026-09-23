local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer

local QuestRemote =
	ReplicatedStorage
	:WaitForChild("Remotes")
	:WaitForChild("QuestRemote")

local QuestHud =
	script.Parent

local Frame =
	QuestHud:FindFirstChild("QuestFrame")

if not Frame then

	Frame =
		Instance.new("Frame")

	Frame.Name = "QuestFrame"

	Frame.Size =
		UDim2.new(
			0,
			320,
			0,
			150
		)

	Frame.Position =
		UDim2.new(
			0,
			25,
			0,
			100
		)

	Frame.BackgroundColor3 =
		Color3.fromRGB(
			25,
			27,
			35
		)

	Frame.BorderSizePixel = 0

	Frame.Parent = QuestHud

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(
			0,
			12
		)

	Corner.Parent = Frame

end

local Title =
	Frame:FindFirstChild("Title")

if not Title then

	Title =
		Instance.new("TextLabel")

	Title.Name = "Title"

	Title.Size =
		UDim2.new(
			1,
			-20,
			0,
			35
		)

	Title.Position =
		UDim2.new(
			0,
			10,
			0,
			8
		)

	Title.BackgroundTransparency = 1

	Title.Text =
		"CAÇADOR DE BANDIDOS"

	Title.TextColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	Title.TextSize = 20

	Title.Font =
		Enum.Font.GothamBold

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.Parent = Frame

end

local Description =
	Frame:FindFirstChild("Description")

if not Description then

	Description =
		Instance.new("TextLabel")

	Description.Name = "Description"

	Description.Size =
		UDim2.new(
			1,
			-20,
			0,
			25
		)

	Description.Position =
		UDim2.new(
			0,
			10,
			0,
			45
		)

	Description.BackgroundTransparency = 1

	Description.Text =
		"Derrote os bandidos."

	Description.TextColor3 =
		Color3.fromRGB(
			180,
			185,
			195
		)

	Description.TextSize = 15

	Description.Font =
		Enum.Font.Gotham

	Description.TextXAlignment =
		Enum.TextXAlignment.Left

	Description.Parent = Frame

end

local Progress =
	Frame:FindFirstChild("Progress")

if not Progress then

	Progress =
		Instance.new("TextLabel")

	Progress.Name = "Progress"

	Progress.Size =
		UDim2.new(
			1,
			-20,
			0,
			40
		)

	Progress.Position =
		UDim2.new(
			0,
			10,
			0,
			82
		)

	Progress.BackgroundTransparency = 1

	Progress.Text =
		"0 / 3"

	Progress.TextColor3 =
		Color3.fromRGB(
			255,
			210,
			80
		)

	Progress.TextSize = 24

	Progress.Font =
		Enum.Font.GothamBold

	Progress.TextXAlignment =
		Enum.TextXAlignment.Left

	Progress.Parent = Frame

end

local BarBackground =
	Frame:FindFirstChild("BarBackground")

if not BarBackground then

	BarBackground =
		Instance.new("Frame")

	BarBackground.Name =
		"BarBackground"

	BarBackground.Size =
		UDim2.new(
			1,
			-20,
			0,
			8
		)

	BarBackground.Position =
		UDim2.new(
			0,
			10,
			0,
			125
		)

	BarBackground.BackgroundColor3 =
		Color3.fromRGB(
			55,
			58,
			68
		)

	BarBackground.BorderSizePixel = 0

	BarBackground.Parent = Frame

	local BarCorner =
		Instance.new("UICorner")

	BarCorner.CornerRadius =
		UDim.new(
			0,
			5
		)

	BarCorner.Parent =
		BarBackground

end

local Bar =
	BarBackground:FindFirstChild("Bar")

if not Bar then

	Bar =
		Instance.new("Frame")

	Bar.Name = "Bar"

	Bar.Size =
		UDim2.new(
			0,
			0,
			1,
			0
		)

	Bar.BackgroundColor3 =
		Color3.fromRGB(
			255,
			190,
			60
		)

	Bar.BorderSizePixel = 0

	Bar.Parent =
		BarBackground

	local BarCorner =
		Instance.new("UICorner")

	BarCorner.CornerRadius =
		UDim.new(
			0,
			5
		)

	BarCorner.Parent =
		Bar

end

local function SetProgress(
	Kills,
	Required
)

	if typeof(Kills) ~= "number" then
		warn("Kills inválido:", Kills)
		return
	end

	if typeof(Required) ~= "number" then
		warn("Required inválido:", Required)
		return
	end

	Progress.Text =
		tostring(Kills)
		.. " / "
		.. tostring(Required)

	local Percentage =
		math.clamp(
			Kills / Required,
			0,
			1
		)

	Bar.Size =
		UDim2.new(
			Percentage,
			0,
			1,
			0
		)

end

QuestRemote.OnClientEvent:Connect(
	function(Action, ...)

		print(
			"QuestRemote:",
			Action
		)

		if Action == "Started" then

			local QuestName,
			Required =
				...

			if typeof(QuestName) ~= "string" then
				warn("Nome da quest inválido")
				return
			end

			if typeof(Required) ~= "number" then
				warn("Quantidade necessária inválida")
				return
			end

			Title.Text =
				"⚔️ " .. QuestName

			Description.Text =
				"Derrote os bandidos."

			SetProgress(
				0,
				Required
			)

			Frame.Visible = true

			print(
				"HUD: Quest iniciada"
			)

		elseif Action == "Progress" then

			local Kills,
			Required =
				...

			SetProgress(
				Kills,
				Required
			)

			Frame.Visible = true

		elseif Action == "Kill" then

			local Kills,
			Required,
			EnemyName =
				...

			SetProgress(
				Kills,
				Required
			)

			Frame.Visible = true

			print(
				"☠️ HUD:",
				EnemyName,
				Kills,
				"/",
				Required
			)

		elseif Action == "Completed" then

			local XP,
			Gold =
				...

			Progress.Text =
				" QUEST COMPLETA!"

			Bar.Size =
				UDim2.new(
					1,
					0,
					1,
					0
				)

			Description.Text =
				"+"
				.. tostring(XP)
				.. " XP   |   +"
				.. tostring(Gold)
				.. " Gold"

			print(
				"HUD: Quest completa!"
			)

		elseif Action == "Message" then

			local Message =
				...

			print(
				" Quest:",
				Message
			)

		else

			warn(
				"Ação desconhecida:",
				Action
			)

		end

	end
)


Frame.Visible = false
