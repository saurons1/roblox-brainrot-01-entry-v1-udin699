-- Brainrot Bay: procedural brainrot models and their labels.
-- No asset ids anywhere: every character is built from parts, so the
-- place runs anywhere and the screenshots carry the look. The label is
-- a BillboardGui on the body, so name, rarity and dollars-per-second
-- stay readable from any angle.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Format"))

local BrainrotModels = {}

local SIZES = {
	Common = 2.6,
	Rare = 2.9,
	Epic = 3.2,
	Legendary = 3.5,
	Mythic = 3.8,
	["Brainrot God"] = 4.2,
	Secret = 4.6,
}

local function shapeOf(bodyName)
	if bodyName == "Ball" then
		return Enum.PartType.Ball
	end
	if bodyName == "Cylinder" then
		return Enum.PartType.Cylinder
	end
	return Enum.PartType.Block
end

local function sizeOf(rarityName)
	local size = SIZES[rarityName]
	if size == nil then
		return 3
	end
	return size
end

local function addEye(model, x, y, z, size)
	local eye = Instance.new("Part")
	eye.Name = "Eye"
	eye.Shape = Enum.PartType.Ball
	eye.Size = Vector3.new(size, size, size)
	eye.Position = Vector3.new(x, y, z)
	eye.Color = Color3.fromRGB(255, 255, 255)
	eye.Material = Enum.Material.SmoothPlastic
	eye.Anchored = true
	eye.CanCollide = false
	eye.Parent = model
	local pupil = Instance.new("Part")
	pupil.Name = "Pupil"
	pupil.Shape = Enum.PartType.Ball
	pupil.Size = Vector3.new(size * 0.5, size * 0.5, size * 0.5)
	pupil.Position = Vector3.new(x, y, z - size * 0.35)
	pupil.Color = Color3.fromRGB(20, 20, 20)
	pupil.Material = Enum.Material.SmoothPlastic
	pupil.Anchored = true
	pupil.CanCollide = false
	pupil.Parent = model
end

function BrainrotModels.build(def, mutation)
	local size = sizeOf(def.Rarity)
	local color = def.Color
	if mutation ~= nil then
		color = mutation.Color
	end
	local model = Instance.new("Model")
	model.Name = def.Name
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = shapeOf(def.Body)
	body.Size = Vector3.new(size, size, size)
	body.Color = color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model
	if def.Body == "Cylinder" then
		body.CFrame = CFrame.Angles(0, 0, math.rad(90))
	end
	-- Eyes on the -Z face, which is the side the model walks towards.
	local eyeSize = size * 0.22
	addEye(model, -size * 0.18, size * 0.15, -size * 0.5, eyeSize)
	addEye(model, size * 0.18, size * 0.15, -size * 0.5, eyeSize)
	-- Accent feature on top, so the cast reads at a glance.
	local top = Instance.new("Part")
	top.Name = "Top"
	top.Shape = Enum.PartType.Ball
	top.Size = Vector3.new(size * 0.45, size * 0.45, size * 0.45)
	top.Position = Vector3.new(0, size * 0.55, 0)
	top.Color = def.Accent
	top.Material = Enum.Material.SmoothPlastic
	top.Anchored = true
	top.CanCollide = false
	top.Parent = model
	-- Floating label: name above, rate and rarity below.
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.new(0, 150, 0, 56)
	gui.StudsOffsetWorldSpace = Vector3.new(0, size * 0.7 + 1, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Text = def.Name
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = gui
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Text = Format.rate(def.Rate) .. "  " .. def.Rarity
	if mutation ~= nil then
		infoLabel.Text = mutation.Name .. "  x" .. tostring(mutation.Multiplier) .. "  " .. infoLabel.Text
		infoLabel.TextColor3 = mutation.Color
	else
		infoLabel.TextColor3 = Config.rarityColor(def.Rarity)
	end
	infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
	infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextStrokeTransparency = 0.3
	infoLabel.Font = Enum.Font.GothamBold
	infoLabel.TextScaled = true
	infoLabel.Parent = gui
	model.PrimaryPart = body
	return model
end

return BrainrotModels
