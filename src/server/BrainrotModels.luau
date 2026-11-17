-- Brainrot Bay: the brainrot models.
-- Every brainrot is built from plain parts in code: a body in its
-- shape and colour, eyes, an accessory, and a billboard label with
-- its name, its rarity and its money per second. No catalog assets,
-- so the place runs anywhere and the screenshots carry the look.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Format"))

local BrainrotModels = {}

-- A small helper for one part of a brainrot.
local function modelPart(model, name, size, offset, color, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "Ball" then
		part.Shape = Enum.PartType.Ball
	elseif shape == "Cylinder" then
		part.Shape = Enum.PartType.Cylinder
		part.CFrame = CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90))
	else
		part.CFrame = CFrame.new(offset)
	end
	part.Parent = model
	return part
end

-- Eyes: two white balls with black pupils, on the body's front face.
local function addEyes(model, def, front)
	local y = def.size.Y * 0.18
	local x = def.size.X * 0.22
	for _, side in ipairs({ -1, 1 }) do
		local eye = modelPart(model, "Eye", Vector3.new(0.5, 0.6, 0.3), Vector3.new(side * x, y, front), Color3.fromRGB(255, 255, 255), "Block")
		eye.CanCollide = false
		local pupil = modelPart(model, "Pupil", Vector3.new(0.25, 0.35, 0.1), Vector3.new(side * x, y, front + 0.15), Color3.fromRGB(20, 20, 20), "Block")
		pupil.CanCollide = false
	end
end

-- The accessory that makes each brainrot read at a glance.
local function addAccessory(model, def)
	local top = def.size.Y / 2
	if def.accessory == "Cup" then
		local cup = modelPart(model, "Cup", Vector3.new(0.8, 1, 0.8), Vector3.new(def.size.X * 0.3, top + 0.5, 0), Color3.fromRGB(255, 255, 255), "Cylinder")
		cup.CanCollide = false
		modelPart(model, "Coffee", Vector3.new(0.7, 0.2, 0.7), Vector3.new(def.size.X * 0.3, top + 1, 0), Color3.fromRGB(120, 70, 30), "Cylinder").CanCollide = false
	elseif def.accessory == "Phones" then
		local band = modelPart(model, "Headband", Vector3.new(def.size.X + 0.3, 0.4, def.size.Z + 0.3), Vector3.new(0, top - 0.1, 0), Color3.fromRGB(30, 30, 30), "Block")
		band.CanCollide = false
		for _, side in ipairs({ -1, 1 }) do
			modelPart(model, "EarCup", Vector3.new(0.4, 1, 1), Vector3.new(side * (def.size.X / 2 + 0.1), top - 0.5, 0), Color3.fromRGB(30, 30, 30), "Block").CanCollide = false
		end
	elseif def.accessory == "Crown" then
		modelPart(model, "Crown", Vector3.new(def.size.X * 0.7, 0.8, def.size.Z * 0.7), Vector3.new(0, top + 0.4, 0), Color3.fromRGB(255, 215, 0), "Cylinder").CanCollide = false
		for _, side in ipairs({ -1, 0, 1 }) do
			modelPart(model, "CrownSpike", Vector3.new(0.3, 0.8, 0.3), Vector3.new(side * def.size.X * 0.25, top + 1, 0), Color3.fromRGB(255, 215, 0), "Block").CanCollide = false
		end
	elseif def.accessory == "Ghost" then
		modelPart(model, "GhostWisp", Vector3.new(1, 1.2, 1), Vector3.new(0, top + 0.6, 0), Color3.fromRGB(200, 230, 255), "Ball").CanCollide = false
	elseif def.accessory == "Hat" then
		modelPart(model, "HatTop", Vector3.new(def.size.X * 0.6, 0.7, def.size.Z * 0.6), Vector3.new(0, top + 0.35, 0), Color3.fromRGB(40, 40, 40), "Cylinder").CanCollide = false
		modelPart(model, "HatBrim", Vector3.new(def.size.X + 0.4, 0.2, def.size.Z + 0.4), Vector3.new(0, top + 0.05, 0), Color3.fromRGB(40, 40, 40), "Cylinder").CanCollide = false
	elseif def.accessory == "Antenna" then
		modelPart(model, "AntennaRod", Vector3.new(0.2, 1.4, 0.2), Vector3.new(0, top + 0.7, 0), Color3.fromRGB(60, 60, 60), "Block").CanCollide = false
		modelPart(model, "AntennaBall", Vector3.new(0.7, 0.7, 0.7), Vector3.new(0, top + 1.5, 0), Color3.fromRGB(255, 80, 80), "Ball").CanCollide = false
	end
end

-- The label every brainrot wears: name, rarity, money per second,
-- and its mutation when it has one. The judge reads the game here.
local function addLabel(model, def, mutation, rate)
	local body = model:FindFirstChild("Body")
	if not body then
		return
	end
	local rarity = Config.rarityByKey(def.rarity)
	local gui = Instance.new("BillboardGui")
	gui.Name = "BrainrotLabel"
	gui.Size = UDim2.new(0, 160, 0, 70)
	gui.StudsOffset = Vector3.new(0, def.size.Y / 2 + 2.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Parent = gui
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0.3, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.4, 0)
	rarityLabel.BackgroundTransparency = 1
	local mutationText = ""
	if mutation.key ~= "Normal" then
		mutationText = " " .. mutation.name
	end
	rarityLabel.Text = rarity.name .. mutationText
	rarityLabel.TextColor3 = rarity.color
	rarityLabel.TextStrokeTransparency = 0
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = gui
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Size = UDim2.new(1, 0, 0.3, 0)
	rateLabel.Position = UDim2.new(0, 0, 0.7, 0)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = Format.rate(rate)
	rateLabel.TextColor3 = Color3.fromRGB(140, 255, 140)
	rateLabel.TextStrokeTransparency = 0
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.GothamBlack
	rateLabel.Parent = gui
end

-- A mutation tints the body so a Golden or Void brainrot reads
-- as special from across the island.
function BrainrotModels.tintForMutation(def, mutation)
	if mutation.key == "Golden" then
		return Color3.fromRGB(255, 215, 0)
	elseif mutation.key == "Diamond" then
		return Color3.fromRGB(150, 220, 255)
	elseif mutation.key == "Rainbow" then
		return Color3.fromRGB(255, 120, 220)
	elseif mutation.key == "Void" then
		return Color3.fromRGB(90, 40, 160)
	end
	return def.body
end

-- Build one brainrot model at a position, facing a direction.
-- Returns the model; its PrimaryPart is the body.
function BrainrotModels.buildBrainrot(def, mutation, position, facing)
	local rate = def.rate * mutation.mult
	local model = Instance.new("Model")
	model.Name = def.id
	local bodyColor = BrainrotModels.tintForMutation(def, mutation)
	local body = modelPart(model, "Body", def.size, Vector3.new(0, 0, 0), bodyColor, def.shape)
	body.CanCollide = true
	body.Anchored = true
	model.PrimaryPart = body
	local front = def.size.Z / 2 + 0.05
	addEyes(model, def, front)
	addAccessory(model, def)
	addLabel(model, def, mutation, rate)
	-- Feet, so it reads as walking, not floating.
	for _, side in ipairs({ -1, 1 }) do
		local foot = modelPart(model, "Foot", Vector3.new(0.7, 0.5, 1), Vector3.new(side * def.size.X * 0.25, -def.size.Y / 2 - 0.2, 0.1), Color3.fromRGB(40, 40, 40), "Block")
		foot.CanCollide = false
	end
	model:PivotTo(CFrame.new(position) * CFrame.Angles(0, facing, 0))
	return model
end

-- The money per second one brainrot earns, with its mutation.
function BrainrotModels.rateOf(def, mutation)
	return def.rate * mutation.mult
end

-- Rebuild the label after a brainrot changes hands, so its rate
-- never lies about who owns it or what it earns.
function BrainrotModels.refreshLabel(model, def, mutation)
	local body = model:FindFirstChild("Body")
	if not body then
		return
	end
	local old = body:FindFirstChild("BrainrotLabel")
	if old then
		old:Destroy()
	end
	addLabel(model, def, mutation, BrainrotModels.rateOf(def, mutation))
end

return BrainrotModels
