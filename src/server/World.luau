-- Brainrot Bay: builds the 3D island.
-- Sand, sea, dock, conveyor, eight beach bases, palms, rocks, a
-- lighthouse and drifting clouds — everything procedural, no asset ids.
-- The island is 190 studs across; the conveyor runs along the north
-- edge at z = -70, the bases ring the middle at radius 45, and the
-- spawn sits south at z = 60 so the leaderboard board at the centre
-- faces the players walking in.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local World = {}

local BASE_COLORS = {
	Color3.fromRGB(255, 214, 140),
	Color3.fromRGB(150, 220, 255),
	Color3.fromRGB(255, 170, 200),
	Color3.fromRGB(180, 255, 170),
	Color3.fromRGB(220, 190, 255),
	Color3.fromRGB(255, 240, 160),
	Color3.fromRGB(170, 235, 230),
	Color3.fromRGB(255, 200, 120),
}

local PALM_SPOTS = {
	{ -80, -40 }, { -82, 20 }, { -60, 78 }, { -20, 84 }, { 30, 82 },
	{ 78, 55 }, { 84, -10 }, { 70, -70 }, { 20, -82 }, { -30, -78 },
}

local ROCK_SPOTS = {
	{ -55, 55 }, { 55, -50 }, { -70, 45 }, { 65, 30 }, { -40, -60 }, { 45, 65 },
}

local CLOUD_SPOTS = {
	{ -70, 46, -40 }, { -20, 52, -70 }, { 40, 44, -30 },
	{ 80, 50, 40 }, { 0, 48, 70 }, { -50, 42, 60 },
}

local function makePart(name, size, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = true
	part.Parent = parent
	return part
end

local function makeBall(name, size, position, color, material, parent)
	local part = makePart(name, Vector3.new(size, size, size), position, color, material, parent)
	part.Shape = Enum.PartType.Ball
	return part
end

local function makeUprightCylinder(name, height, diameter, position, color, material, parent)
	local part = makePart(name, Vector3.new(diameter, height, diameter), position, color, material, parent)
	part.Shape = Enum.PartType.Cylinder
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	return part
end

local function makeSign(parent, position, lookAt, title)
	local sign = makePart("Sign", Vector3.new(9, 3, 0.6), position, Color3.fromRGB(120, 80, 40), Enum.Material.Wood, parent)
	sign.CFrame = CFrame.new(position, lookAt)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.Text = title
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	return label
end

local function makePalm(parent, x, z)
	local trunk = makeUprightCylinder("PalmTrunk", 9, 1.6, Vector3.new(x, 4.5, z), Color3.fromRGB(140, 100, 55), Enum.Material.Wood, parent)
	trunk.CanCollide = false
	local top = Vector3.new(x, 9.5, z)
	makeBall("PalmLeaf", 4, top + Vector3.new(0, 0.5, 0), Color3.fromRGB(60, 180, 70), Enum.Material.Grass, parent).CanCollide = false
	makeBall("PalmLeaf", 3, top + Vector3.new(2.2, -0.4, 0.8), Color3.fromRGB(70, 200, 80), Enum.Material.Grass, parent).CanCollide = false
	makeBall("PalmLeaf", 3, top + Vector3.new(-2, -0.3, -1), Color3.fromRGB(50, 160, 60), Enum.Material.Grass, parent).CanCollide = false
	makeBall("PalmNut", 1.4, top + Vector3.new(0.8, -0.8, 0.5), Color3.fromRGB(120, 80, 40), Enum.Material.SmoothPlastic, parent).CanCollide = false
end

function World.build()
	local folder = Instance.new("Folder")
	folder.Name = "Island"
	folder.Parent = workspace

	-- Sand island and the sea around it.
	makePart("Sand", Vector3.new(190, 2, 190), Vector3.new(0, -1, 0), Color3.fromRGB(238, 214, 150), Enum.Material.Sand, folder)
	local sea = makePart("Sea", Vector3.new(700, 1, 700), Vector3.new(0, -1.6, 0), Color3.fromRGB(40, 130, 200), Enum.Material.SmoothPlastic, folder)
	sea.Transparency = 0.25
	sea.CanCollide = false

	-- Dock planks on the north edge, where the brainrots wash in.
	for i = 0, 9 do
		makePart("DockPlank", Vector3.new(4, 0.6, 14), Vector3.new(-72 + i * 16, 0.3, -90), Color3.fromRGB(150, 105, 60), Enum.Material.Wood, folder)
	end
	makePart("DockPost", Vector3.new(1, 3, 1), Vector3.new(-76, 1.5, -96), Color3.fromRGB(110, 75, 40), Enum.Material.Wood, folder)
	makePart("DockPost", Vector3.new(1, 3, 1), Vector3.new(76, 1.5, -96), Color3.fromRGB(110, 75, 40), Enum.Material.Wood, folder)

	-- Conveyor belt along the north edge, west to east.
	makePart("Conveyor", Vector3.new(150, 1, 6), Vector3.new(0, 1, -70), Color3.fromRGB(60, 60, 70), Enum.Material.SmoothPlastic, folder)
	makePart("ConveyorRail", Vector3.new(150, 1, 1), Vector3.new(0, 2, -73.5), Color3.fromRGB(200, 200, 210), Enum.Material.Metal, folder)
	makePart("ConveyorRail", Vector3.new(150, 1, 1), Vector3.new(0, 2, -66.5), Color3.fromRGB(200, 200, 210), Enum.Material.Metal, folder)
	local waypoints = {
		Vector3.new(-70, 3, -70),
		Vector3.new(70, 3, -70),
	}

	-- Eight bases ring the middle.
	local bases = {}
	local signLabels = {}
	local colOffsets = { -6.75, -2.25, 2.25, 6.75 }
	local rowOffsets = { -5, 0, 5 }
	for index = 1, Config.BaseCount do
		local angle = math.rad((index - 1) * 45)
		local center = Vector3.new(45 * math.sin(angle), 0.5, 45 * math.cos(angle))
		local toCenter = Vector3.new(-center.X, 0, -center.Z).Unit
		local side = Vector3.new(-toCenter.Z, 0, toCenter.X)
		local platform = makePart("BasePlatform", Vector3.new(20, 1, 20), center, BASE_COLORS[index], Enum.Material.SmoothPlastic, folder)
		platform.Name = "Base" .. tostring(index)
		local plotPositions = {}
		local padParts = {}
		for _, row in ipairs(rowOffsets) do
			for _, col in ipairs(colOffsets) do
				local padPos = center + side * col + toCenter * row
				local pad = makePart("PlotPad", Vector3.new(4, 0.4, 4), Vector3.new(padPos.X, 1.2, padPos.Z), Color3.fromRGB(210, 210, 210), Enum.Material.SmoothPlastic, folder)
				pad.CanCollide = false
				table.insert(padParts, pad)
				table.insert(plotPositions, Vector3.new(padPos.X, 3, padPos.Z))
			end
		end
		local spawn = center + toCenter * 13
		spawn = Vector3.new(spawn.X, 3, spawn.Z)
		local totemPos = center - toCenter * 8
		makeUprightCylinder("Totem", 4, 2, Vector3.new(totemPos.X, 3, totemPos.Z), Color3.fromRGB(255, 215, 0), Enum.Material.SmoothPlastic, folder)
		makeBall("TotemTop", 2, Vector3.new(totemPos.X, 5.5, totemPos.Z), Color3.fromRGB(255, 90, 90), Enum.Material.Neon, folder)
		local signPos = center + side * 9
		signPos = Vector3.new(signPos.X, 2.5, signPos.Z)
		signLabels[index] = makeSign(folder, signPos, Vector3.new(0, 2.5, 0), "BASE " .. tostring(index))
		bases[index] = {
			Center = center,
			Spawn = spawn,
			Totem = Vector3.new(totemPos.X, 3, totemPos.Z),
			Plots = plotPositions,
			PadParts = padParts,
		}
	end

	-- Leaderboard board at the centre, facing the spawn.
	local board = makePart("Leaderboard", Vector3.new(18, 9, 1), Vector3.new(0, 6, -8), Color3.fromRGB(40, 60, 90), Enum.Material.SmoothPlastic, folder)
	board.CFrame = CFrame.new(Vector3.new(0, 6, -8), Vector3.new(0, 6, 60))
	local boardGui = Instance.new("SurfaceGui")
	boardGui.Name = "BoardGui"
	boardGui.Face = Enum.NormalId.Front
	boardGui.Parent = board
	local boardLabel = Instance.new("TextLabel")
	boardLabel.Name = "BoardText"
	boardLabel.Text = "TOP EARNERS\nNo players yet"
	boardLabel.Size = UDim2.new(1, 0, 1, 0)
	boardLabel.BackgroundTransparency = 1
	boardLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
	boardLabel.Font = Enum.Font.GothamBold
	boardLabel.TextScaled = true
	boardLabel.Parent = boardGui

	-- Spawn location south of the island centre.
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.Position = Vector3.new(0, 0.5, 60)
	spawnLocation.Color = Color3.fromRGB(100, 200, 100)
	spawnLocation.Material = Enum.Material.Grass
	spawnLocation.Neutral = true
	spawnLocation.Duration = 0
	spawnLocation.Anchored = true
	spawnLocation.Parent = folder

	-- Palms, rocks, lighthouse.
	for _, spot in ipairs(PALM_SPOTS) do
		makePalm(folder, spot[1], spot[2])
	end
	for _, spot in ipairs(ROCK_SPOTS) do
		makeBall("Rock", 4, Vector3.new(spot[1], 1, spot[2]), Color3.fromRGB(130, 130, 130), Enum.Material.Slate, folder)
	end
	makeUprightCylinder("Lighthouse", 18, 7, Vector3.new(-80, 9, 80), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, folder)
	makeUprightCylinder("LighthouseBand", 2, 7.6, Vector3.new(-80, 14, 80), Color3.fromRGB(220, 60, 60), Enum.Material.SmoothPlastic, folder)
	makeUprightCylinder("LighthouseTop", 3, 9, Vector3.new(-80, 18.5, 80), Color3.fromRGB(220, 60, 60), Enum.Material.SmoothPlastic, folder)
	makeBall("LighthouseLight", 3, Vector3.new(-80, 21, 80), Color3.fromRGB(255, 240, 120), Enum.Material.Neon, folder)

	-- Drifting clouds.
	local clouds = {}
	for _, spot in ipairs(CLOUD_SPOTS) do
		local cloud = makeBall("Cloud", 10, Vector3.new(spot[1], spot[2], spot[3]), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, folder)
		cloud.Transparency = 0.15
		cloud.CanCollide = false
		table.insert(clouds, cloud)
	end
	task.spawn(function()
		while true do
			task.wait(0.2)
			for _, cloud in ipairs(clouds) do
				local pos = cloud.Position + Vector3.new(0.4, 0, 0)
				if pos.X > 120 then
					pos = Vector3.new(-120, pos.Y, pos.Z)
				end
				cloud.Position = pos
			end
		end
	end)

	local function setLeaderboard(lines)
		if #lines == 0 then
			boardLabel.Text = "TOP EARNERS\nNo players yet"
		else
			boardLabel.Text = "TOP EARNERS\n" .. table.concat(lines, "\n")
		end
	end

	local function setBaseOwner(index, playerName)
		if signLabels[index] ~= nil then
			signLabels[index].Text = "BASE " .. tostring(index) .. "\n" .. playerName
		end
	end

	return {
		Folder = folder,
		ConveyorWaypoints = waypoints,
		Bases = bases,
		SpawnPoint = Vector3.new(0, 3, 60),
		setLeaderboard = setLeaderboard,
		setBaseOwner = setBaseOwner,
	}
end

return World
