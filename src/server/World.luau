-- Brainrot Bay: the world builder.
-- Every part of the island is built here, in code, at boot: the sand,
-- the sea, the dock conveyor, the eight beach bases, the rebirth
-- totem, the upgrade stand, the leaderboard board, the palms, the
-- rocks, the lighthouse and the drifting clouds. No catalog assets:
-- the screenshots carry the look because the code draws it all.

local World = {}

local SAND = Color3.fromRGB(238, 205, 150)
local SEA = Color3.fromRGB(45, 125, 210)
local WOOD = Color3.fromRGB(150, 105, 60)
local STONE = Color3.fromRGB(200, 200, 205)
local LEAF = Color3.fromRGB(70, 170, 80)
local TRUNK = Color3.fromRGB(140, 95, 55)
local ROCK = Color3.fromRGB(130, 130, 135)
local GOLD = Color3.fromRGB(255, 210, 60)

-- Eight base colours, one per base, so a player finds theirs at a glance.
World.BASE_COLORS = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(90, 160, 255),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(190, 100, 255),
	Color3.fromRGB(255, 130, 200),
	Color3.fromRGB(90, 220, 220),
	Color3.fromRGB(255, 150, 60),
}

World.bases = {}
World.clouds = {}

-- One helper for every block in the world.
local function makePart(parent, name, size, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- A ball part. Used for rocks, clouds, heads and fruit.
local function makeBall(parent, name, size, position, color, material)
	local part = makePart(parent, name, size, position, color, material)
	part.Shape = Enum.PartType.Ball
	return part
end

-- A vertical cylinder. Roblox cylinders lie along X, so this turns one up.
local function makeCylinder(parent, name, height, diameter, position, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, diameter, diameter)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- The sand island and the sea around it, plus the centre plaza.
function World.buildIsland(folder)
	makePart(folder, "Sand", Vector3.new(480, 4, 480), Vector3.new(0, -2, 0), SAND, Enum.Material.Sand)
	local sea = makePart(folder, "Sea", Vector3.new(1400, 2, 1400), Vector3.new(0, -4.5, 0), SEA, Enum.Material.SmoothPlastic)
	sea.Transparency = 0.25
	sea.CanCollide = false
	local plaza = makeCylinder(folder, "Plaza", 1, 64, Vector3.new(0, 0.5, 0), Color3.fromRGB(225, 215, 190), Enum.Material.Slate)
	plaza.CanCollide = true
end

-- The dock conveyor: a wooden walkway along the north beach where
-- brainrots wash ashore and stroll east until they reach the sea.
function World.buildConveyor(folder)
	makePart(folder, "Conveyor", Vector3.new(340, 1, 10), Vector3.new(0, 0.5, -165), WOOD, Enum.Material.Wood)
	makePart(folder, "ConveyorEdgeNorth", Vector3.new(340, 1.5, 1), Vector3.new(0, 0.75, -170.5), Color3.fromRGB(110, 75, 40), Enum.Material.Wood)
	makePart(folder, "ConveyorEdgeSouth", Vector3.new(340, 1.5, 1), Vector3.new(0, 0.75, -159.5), Color3.fromRGB(110, 75, 40), Enum.Material.Wood)
	for _, x in ipairs({ -170, -85, 0, 85, 170 }) do
		makePart(folder, "DockPost", Vector3.new(2, 4, 2), Vector3.new(x, 0, -172), Color3.fromRGB(90, 60, 35), Enum.Material.Wood)
	end
	local dockSign = makePart(folder, "DockSign", Vector3.new(14, 1, 6), Vector3.new(-178, 4, -165), Color3.fromRGB(250, 240, 210), Enum.Material.Wood)
	dockSign.CanCollide = false
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = dockSign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "BRAINROT DOCK"
	label.TextColor3 = Color3.fromRGB(60, 40, 20)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- The spawn pad near the plaza, where washed-out players wake up.
function World.buildSpawn(folder)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(14, 1, 14)
	spawn.Position = Vector3.new(0, 0.5, 30)
	spawn.Color = Color3.fromRGB(120, 220, 255)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = folder
end

-- One beach base: a coloured platform, eight plot pads, an owner sign
-- and a lock banner. Bases sit on a circle around the plaza.
function World.buildBases(folder)
	for index = 1, 8 do
		local angle = (index - 1) * (math.pi * 2 / 8)
		local cx = 115 * math.cos(angle)
		local cz = 115 * math.sin(angle)
		local color = World.BASE_COLORS[index]
		local baseFolder = Instance.new("Folder")
		baseFolder.Name = "Base" .. index
		baseFolder.Parent = folder

		makePart(baseFolder, "Platform", Vector3.new(38, 1, 38), Vector3.new(cx, 0.5, cz), color, Enum.Material.SmoothPlastic)
		makePart(baseFolder, "PlatformTrim", Vector3.new(40, 0.5, 40), Vector3.new(cx, 0.25, cz), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)

		local plots = {}
		local plotIndex = 1
		for _, dz in ipairs({ -8, 8 }) do
			for _, dx in ipairs({ -13.5, -4.5, 4.5, 13.5 }) do
				local pad = makePart(baseFolder, "Plot" .. plotIndex, Vector3.new(7, 0.5, 7), Vector3.new(cx + dx, 1.25, cz + dz), Color3.fromRGB(255, 250, 230), Enum.Material.SmoothPlastic)
				pad.Transparency = 0.15
				plots[plotIndex] = pad.Position
				plotIndex = plotIndex + 1
			end
		end

		-- Owner sign at the edge facing the plaza.
		local signX = cx - 16 * math.cos(angle)
		local signZ = cz - 16 * math.sin(angle)
		makeCylinder(baseFolder, "SignPole", 7, 1, Vector3.new(signX, 4.5, signZ), TRUNK, Enum.Material.Wood)
		local sign = makePart(baseFolder, "OwnerSign", Vector3.new(12, 4, 0.5), Vector3.new(signX, 9, signZ), Color3.fromRGB(250, 245, 220), Enum.Material.Wood)
		sign.CanCollide = false
		local signGui = Instance.new("SurfaceGui")
		signGui.Face = Enum.NormalId.Front
		signGui.Parent = sign
		local signLabel = Instance.new("TextLabel")
		signLabel.Name = "OwnerLabel"
		signLabel.Size = UDim2.new(1, 0, 1, 0)
		signLabel.BackgroundTransparency = 1
		signLabel.Text = "EMPTY BASE"
		signLabel.TextColor3 = Color3.fromRGB(50, 35, 20)
		signLabel.TextScaled = true
		signLabel.Font = Enum.Font.GothamBlack
		signLabel.Parent = signGui

		-- Lock banner, hidden until the owner locks the base.
		local lockGui = Instance.new("BillboardGui")
		lockGui.Name = "LockBanner"
		lockGui.Size = UDim2.new(0, 120, 0, 40)
		lockGui.StudsOffset = Vector3.new(0, 14, 0)
		lockGui.AlwaysOnTop = true
		lockGui.Enabled = false
		lockGui.Parent = sign
		local lockLabel = Instance.new("TextLabel")
		lockLabel.Size = UDim2.new(1, 0, 1, 0)
		lockLabel.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
		lockLabel.Text = "LOCKED"
		lockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		lockLabel.TextScaled = true
		lockLabel.Font = Enum.Font.GothamBlack
		lockLabel.Parent = lockGui

		World.bases[index] = {
			index = index,
			center = Vector3.new(cx, 1, cz),
			plots = plots,
			folder = baseFolder,
			signLabel = signLabel,
			lockGui = lockGui,
		}
	end
end

-- The rebirth totem at the plaza: a golden brain on a pedestal.
-- Walk up and press E to rebirth once you have earned enough.
function World.buildTotem(folder)
	local pos = Vector3.new(0, 0, -20)
	makeCylinder(folder, "TotemBase", 2, 10, Vector3.new(pos.X, 1, pos.Z), STONE, Enum.Material.Slate)
	makeCylinder(folder, "TotemPillar", 6, 4, Vector3.new(pos.X, 5, pos.Z), GOLD, Enum.Material.Neon)
	local brain = makeBall(folder, "TotemBrain", Vector3.new(6, 5, 6), Vector3.new(pos.X, 10, pos.Z), Color3.fromRGB(255, 150, 200), Enum.Material.Neon)
	brain.CanCollide = false
	local eyeLeft = makeBall(folder, "TotemEyeLeft", Vector3.new(1, 1, 1), Vector3.new(pos.X - 1.5, 10.5, pos.Z + 2.8), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic)
	eyeLeft.CanCollide = false
	local eyeRight = makeBall(folder, "TotemEyeRight", Vector3.new(1, 1, 1), Vector3.new(pos.X + 1.5, 10.5, pos.Z + 2.8), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic)
	eyeRight.CanCollide = false
	local gui = Instance.new("BillboardGui")
	gui.Name = "TotemLabel"
	gui.Size = UDim2.new(0, 200, 0, 60)
	gui.StudsOffset = Vector3.new(0, 6, 0)
	gui.AlwaysOnTop = true
	gui.Parent = brain
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "REBIRTH TOTEM\nPress E to rebirth"
	label.TextColor3 = Color3.fromRGB(255, 230, 120)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- The upgrade stand: a striped booth where cash buys walk speed,
-- catch range, more plots and a money boost.
function World.buildUpgradeStand(folder)
	local pos = Vector3.new(-24, 0, -20)
	makePart(folder, "UpgradeCounter", Vector3.new(10, 3, 5), Vector3.new(pos.X, 1.5, pos.Z), Color3.fromRGB(90, 140, 255), Enum.Material.SmoothPlastic)
	makePart(folder, "UpgradeRoof", Vector3.new(12, 1, 7), Vector3.new(pos.X, 7, pos.Z), Color3.fromRGB(255, 90, 90), Enum.Material.SmoothPlastic)
	makeCylinder(folder, "UpgradePoleLeft", 5, 0.8, Vector3.new(pos.X - 5, 4.5, pos.Z - 2.5), TRUNK, Enum.Material.Wood)
	makeCylinder(folder, "UpgradePoleRight", 5, 0.8, Vector3.new(pos.X + 5, 4.5, pos.Z - 2.5), TRUNK, Enum.Material.Wood)
	local board = makePart(folder, "UpgradeBoard", Vector3.new(10, 4, 0.5), Vector3.new(pos.X, 5, pos.Z - 3), Color3.fromRGB(250, 245, 220), Enum.Material.Wood)
	board.CanCollide = false
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "UPGRADES\nSpeed - Range - Plots - Boost"
	label.TextColor3 = Color3.fromRGB(40, 60, 140)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

-- The leaderboard board: the top three earners, updated live.
function World.buildLeaderboard(folder)
	local pos = Vector3.new(24, 0, -20)
	makeCylinder(folder, "BoardPoleLeft", 6, 0.8, Vector3.new(pos.X - 5, 3, pos.Z), TRUNK, Enum.Material.Wood)
	makeCylinder(folder, "BoardPoleRight", 6, 0.8, Vector3.new(pos.X + 5, 3, pos.Z), TRUNK, Enum.Material.Wood)
	local board = makePart(folder, "LeaderboardBoard", Vector3.new(12, 7, 0.5), Vector3.new(pos.X, 7, pos.Z), Color3.fromRGB(40, 40, 60), Enum.Material.SmoothPlastic)
	board.CanCollide = false
	local gui = Instance.new("SurfaceGui")
	gui.Name = "LeaderboardGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.25, 0)
	title.BackgroundTransparency = 1
	title.Text = "TOP EARNERS"
	title.TextColor3 = Color3.fromRGB(255, 220, 80)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = gui
	for slot = 1, 3 do
		local line = Instance.new("TextLabel")
		line.Name = "Rank" .. slot
		line.Size = UDim2.new(1, 0, 0.25, 0)
		line.Position = UDim2.new(0, 0, 0.25 * slot, 0)
		line.BackgroundTransparency = 1
		line.Text = slot .. ". ---"
		line.TextColor3 = Color3.fromRGB(255, 255, 255)
		line.TextScaled = true
		line.Font = Enum.Font.GothamBold
		line.Parent = gui
	end
end

-- Palm trees, rocks and the lighthouse: the dressing that makes the
-- island read as a place, not a grey box. Positions are seeded so
-- every server builds the same island.
function World.buildDecor(folder)
	math.randomseed(20261117)
	for i = 1, 20 do
		local angle = (i - 1) * (math.pi * 2 / 20) + math.random() * 0.2
		local radius = 150 + math.random() * 60
		local x = radius * math.cos(angle)
		local z = radius * math.sin(angle)
		if math.abs(z + 165) < 18 and math.abs(x) < 180 then
			-- Keep the conveyor clear.
		else
			World.buildPalmTree(folder, "Palm" .. i, Vector3.new(x, 0, z))
		end
	end
	for i = 1, 16 do
		local angle = math.random() * math.pi * 2
		local radius = 130 + math.random() * 90
		local size = 2 + math.random() * 3
		makeBall(folder, "Rock" .. i, Vector3.new(size, size * 0.7, size), Vector3.new(radius * math.cos(angle), size * 0.3, radius * math.sin(angle)), ROCK, Enum.Material.Slate)
	end
	World.buildLighthouse(folder)
	World.buildClouds(folder)
end

function World.buildPalmTree(folder, name, base)
	local tree = Instance.new("Folder")
	tree.Name = name
	tree.Parent = folder
	local trunk = makeCylinder(tree, "Trunk", 12, 1.6, Vector3.new(base.X, 6, base.Z), TRUNK, Enum.Material.Wood)
	trunk.CFrame = CFrame.new(base.X, 6, base.Z) * CFrame.Angles(0, 0, math.rad(8))
	local top = Vector3.new(base.X + 1.6, 12, base.Z)
	for leaf = 1, 5 do
		local leafAngle = (leaf - 1) * (math.pi * 2 / 5)
		local leafPart = makePart(tree, "Leaf" .. leaf, Vector3.new(7, 0.4, 2), top + Vector3.new(3.2 * math.cos(leafAngle), 0.4, 3.2 * math.sin(leafAngle)), LEAF, Enum.Material.SmoothPlastic)
		leafPart.CFrame = CFrame.new(leafPart.Position) * CFrame.Angles(0, -leafAngle, math.rad(18))
		leafPart.CanCollide = false
	end
	makeBall(tree, "Coconut", Vector3.new(1.4, 1.4, 1.4), top + Vector3.new(0, -0.8, 0), Color3.fromRGB(120, 80, 40), Enum.Material.SmoothPlastic).CanCollide = false
end

function World.buildLighthouse(folder)
	local pos = Vector3.new(-195, 0, 195)
	makeCylinder(folder, "LighthouseBase", 3, 14, Vector3.new(pos.X, 1.5, pos.Z), STONE, Enum.Material.Slate)
	makeCylinder(folder, "LighthouseWhite", 12, 9, Vector3.new(pos.X, 9, pos.Z), Color3.fromRGB(250, 250, 250), Enum.Material.SmoothPlastic)
	makeCylinder(folder, "LighthouseRed", 4, 9.4, Vector3.new(pos.X, 12, pos.Z), Color3.fromRGB(220, 60, 60), Enum.Material.SmoothPlastic)
	makeCylinder(folder, "LighthouseTop", 6, 10, Vector3.new(pos.X, 17, pos.Z), Color3.fromRGB(250, 250, 250), Enum.Material.SmoothPlastic)
	local lamp = makeBall(folder, "LighthouseLamp", Vector3.new(5, 5, 5), Vector3.new(pos.X, 21, pos.Z), Color3.fromRGB(255, 240, 150), Enum.Material.Neon)
	lamp.CanCollide = false
end

function World.buildClouds(folder)
	for i = 1, 8 do
		local group = Instance.new("Folder")
		group.Name = "Cloud" .. i
		group.Parent = folder
		local cx = -220 + i * 60
		local cy = 70 + (i % 3) * 8
		local cz = -180 + (i % 4) * 110
		makeBall(group, "Puff1", Vector3.new(16, 7, 10), Vector3.new(cx, cy, cz), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic).CanCollide = false
		makeBall(group, "Puff2", Vector3.new(12, 6, 9), Vector3.new(cx + 9, cy + 1, cz), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic).CanCollide = false
		makeBall(group, "Puff3", Vector3.new(10, 5, 8), Vector3.new(cx - 9, cy + 1, cz), Color3.fromRGB(250, 250, 250), Enum.Material.SmoothPlastic).CanCollide = false
		table.insert(World.clouds, group)
	end
end

-- Clouds drift east and wrap around, so the sky is never still.
function World.startCloudDrift()
	task.spawn(function()
		while true do
			task.wait(0.5)
			for _, group in ipairs(World.clouds) do
				local pivot = group:GetPivot()
				local x = pivot.Position.X + 0.4
				if x > 260 then
					x = -260
				end
				group:PivotTo(CFrame.new(x, pivot.Position.Y, pivot.Position.Z))
			end
		end
	end)
end

-- Build the whole island, in order. Returns the folder it lives in.
function World.build()
	local folder = Instance.new("Folder")
	folder.Name = "BrainrotBay"
	folder.Parent = workspace
	World.buildIsland(folder)
	World.buildConveyor(folder)
	World.buildSpawn(folder)
	World.buildBases(folder)
	World.buildTotem(folder)
	World.buildUpgradeStand(folder)
	World.buildLeaderboard(folder)
	World.buildDecor(folder)
	World.startCloudDrift()
	return folder
end

return World
