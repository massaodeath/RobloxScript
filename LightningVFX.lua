local tool = script.Parent
local RunService = game:GetService("RunService")

if not tool:IsA("Tool") then
	warn("LightningVFX: este Script precisa ficar dentro de uma Tool.")
	return
end

local old = tool:FindFirstChild("LightningVFX")
if old then
	old:Destroy()
end

local vfxFolder = Instance.new("Folder")
vfxFolder.Name = "LightningVFX"
vfxFolder.Parent = tool

local handle = tool:FindFirstChild("Handle")

if not handle or not handle:IsA("BasePart") then
	warn("LightningVFX: a espada precisa possuir um Handle.")
	return
end

local effects = Instance.new("Folder")
effects.Name = "Effects"
effects.Parent = vfxFolder

local COLORS = {
	Color3.fromRGB(170, 220, 255),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(255, 255, 255),
}

local function randomColor()
	return COLORS[math.random(1, #COLORS)]
end

local function createAttachment(name, position)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Position = position
	attachment.Parent = handle
	return attachment
end

local center = createAttachment("LightningCenter", Vector3.new(0, 0, 0))
local top = createAttachment("LightningTop", Vector3.new(0, handle.Size.Y / 2, 0))
local bottom = createAttachment("LightningBottom", Vector3.new(0, -handle.Size.Y / 2, 0))

local attachments = {center, top, bottom}

local light = Instance.new("PointLight")
light.Name = "LightningGlow"
light.Color = Color3.fromRGB(100, 190, 255)
light.Brightness = 2
light.Range = 8
light.Shadows = false
light.Parent = center

local particles = Instance.new("ParticleEmitter")
particles.Name = "ElectricParticles"
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Rate = 35
particles.Lifetime = NumberRange.new(0.12, 0.35)
particles.Speed = NumberRange.new(0.5, 2.5)
particles.SpreadAngle = Vector2.new(180, 180)
particles.Rotation = NumberRange.new(0, 360)
particles.RotSpeed = NumberRange.new(-180, 180)
particles.LightEmission = 1
particles.LightInfluence = 0
particles.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.18),
	NumberSequenceKeypoint.new(0.45, 0.09),
	NumberSequenceKeypoint.new(1, 0),
})
particles.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.7, 0.25),
	NumberSequenceKeypoint.new(1, 1),
})
particles.Color = ColorSequence.new(
	Color3.fromRGB(220, 245, 255),
	Color3.fromRGB(60, 150, 255)
)
particles.Parent = center

local sparks = Instance.new("ParticleEmitter")
sparks.Name = "ElectricSparks"
sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
sparks.Rate = 12
sparks.Lifetime = NumberRange.new(0.08, 0.22)
sparks.Speed = NumberRange.new(3, 7)
sparks.SpreadAngle = Vector2.new(180, 180)
sparks.LightEmission = 1
sparks.LightInfluence = 0
sparks.Size = NumberSequence.new(0.08)
sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
sparks.Parent = center

local function createBeam(a0, a1, name)
	local beam = Instance.new("Beam")
	beam.Name = name
	beam.Attachment0 = a0
	beam.Attachment1 = a1

	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0

	beam.Width0 = 0.09
	beam.Width1 = 0.025

	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0.25),
	})

	beam.Color = ColorSequence.new(randomColor())

	beam.Segments = 8
	beam.CurveSize0 = math.random(-2, 2)
	beam.CurveSize1 = math.random(-2, 2)

	beam.Parent = effects
	return beam
end

local beams = {}

for i = 1, 5 do
	local a = createAttachment("ArcA_" .. i, Vector3.new(
		math.random(-100, 100) / 100 * handle.Size.X,
		math.random(-100, 100) / 100 * handle.Size.Y,
		math.random(-100, 100) / 100 * handle.Size.Z
		))

	local b = createAttachment("ArcB_" .. i, Vector3.new(
		math.random(-100, 100) / 100 * handle.Size.X,
		math.random(-100, 100) / 100 * handle.Size.Y,
		math.random(-100, 100) / 100 * handle.Size.Z
		))

	table.insert(attachments, a)
	table.insert(attachments, b)

	local beam = createBeam(a, b, "LightningArc_" .. i)
	table.insert(beams, beam)
end

task.spawn(function()
	while tool.Parent do
		for _, beam in ipairs(beams) do
			if beam and beam.Parent then
				beam.Enabled = math.random() > 0.15
				beam.Width0 = math.random(5, 13) / 100
				beam.Width1 = math.random(1, 5) / 100
				beam.Color = ColorSequence.new(randomColor())

				beam.CurveSize0 = math.random(-25, 25) / 10
				beam.CurveSize1 = math.random(-25, 25) / 10
			end
		end

		light.Brightness = math.random(12, 30) / 10
		light.Range = math.random(65, 95) / 10

		task.wait(math.random(5, 12) / 100)
	end
end)

task.spawn(function()
	while tool.Parent do
		for i = 1, 10 do
			if not light.Parent then
				return
			end
			light.Brightness = 1.5 + i * 0.08
			task.wait(0.025)
		end

		for i = 10, 1, -1 do
			if not light.Parent then
				return
			end
			light.Brightness = 1.5 + i * 0.08
			task.wait(0.025)
		end
	end
end)
