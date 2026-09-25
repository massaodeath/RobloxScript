	local ReplicatedStorage =
		game:GetService("ReplicatedStorage")

	local TweenService =
		game:GetService("TweenService")


	local DamageFolder =
		ReplicatedStorage:WaitForChild("DamageIndicator")

	local DamageEvent =
		DamageFolder:WaitForChild("DamageEvent")


	DamageEvent.OnClientEvent:Connect(function(
		character,
		damage
	)

		local head =
			character:FindFirstChild("Head")

		if not head then
			return
		end


		local billboard =
			Instance.new("BillboardGui")

		billboard.Size =
			UDim2.new(0, 100, 0, 40)

		billboard.StudsOffset =
			Vector3.new(
				math.random(-10, 10) / 10,
				2,
				0
			)

		billboard.AlwaysOnTop = true

		billboard.Parent = head


		local text =
			Instance.new("TextLabel")

		text.Size =
			UDim2.new(1, 0, 1, 0)

		text.BackgroundTransparency = 1

		text.Text = "-" .. tostring(damage)

		text.TextColor3 =
			Color3.fromRGB(255, 60, 60)

		text.TextStrokeTransparency = 0

		text.TextScaled = true

		text.Font = Enum.Font.GothamBold

		text.Parent = billboard


		local moveTween =
			TweenService:Create(
				billboard,

				TweenInfo.new(
					0.8,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),

				{
					StudsOffset =
					Vector3.new(
						math.random(-15, 15) / 10,
						4,
						0
					)
				}
			)


		local fadeTween =
			TweenService:Create(
				text,

				TweenInfo.new(0.8),

				{
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}
			)


		moveTween:Play()
		fadeTween:Play()


		task.wait(0.8)

		billboard:Destroy()

	end)
