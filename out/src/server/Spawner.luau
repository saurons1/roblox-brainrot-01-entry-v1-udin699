-- Brainrot Bay: the conveyor spawner.
-- Brainrots wash ashore at the dock, stroll east along the beach,
-- and walk into the sea if nobody buys them. Each spawn rolls its
-- rarity from the ladder and its mutation from the table; during
-- Golden Hour the mutation chances triple.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotModels = require(script.Parent:WaitForChild("BrainrotModels"))

local Spawner = {}
Spawner.wild = {}
Spawner.goldenHour = false
Spawner.running = false

-- One wild brainrot: its definition, its mutation, its model, where
-- it is on the walk and how fast it strolls.
function Spawner.spawnOne(parent)
	local def = Config.rollBrainrot()
	local mutation = Config.rollMutation(Spawner.goldenHour)
	local start = Config.CONVEYOR_START
	local model = BrainrotModels.buildBrainrot(def, mutation, start, math.rad(90))
	model.Parent = parent
	local entry = {
		def = def,
		mutation = mutation,
		model = model,
		distance = 0,
		speed = def.walk,
		bornAt = os.clock(),
	}
	table.insert(Spawner.wild, entry)
	return entry
end

-- Move every wild brainrot one step east. A brainrot that reaches
-- the sea, or outlives its lifetime, is swept away.
function Spawner.stepWild(dt)
	local length = Config.CONVEYOR_END.X - Config.CONVEYOR_START.X
	for index = #Spawner.wild, 1, -1 do
		local entry = Spawner.wild[index]
		if not entry.model.Parent then
			table.remove(Spawner.wild, index)
		else
			entry.distance = entry.distance + entry.speed * dt
			local x = Config.CONVEYOR_START.X + entry.distance
			local bob = math.sin(os.clock() * 6 + index) * 0.15
			entry.model:PivotTo(CFrame.new(x, Config.CONVEYOR_START.Y + bob, Config.CONVEYOR_START.Z) * CFrame.Angles(0, math.rad(90), 0))
			if entry.distance >= length or os.clock() - entry.bornAt > Config.CONVEYOR_LIFETIME then
				Spawner.removeWild(entry)
				table.remove(Spawner.wild, index)
			end
		end
	end
end

function Spawner.removeWild(entry)
	if entry.model then
		entry.model:Destroy()
	end
end

function Spawner.removeEntry(entry)
	for index, other in ipairs(Spawner.wild) do
		if other == entry then
			table.remove(Spawner.wild, index)
			break
		end
	end
	Spawner.removeWild(entry)
end

-- The closest wild brainrot to a point, within a range.
function Spawner.nearestWild(position, range)
	local best = nil
	local bestDistance = range
	for _, entry in ipairs(Spawner.wild) do
		if entry.model.Parent and entry.model.PrimaryPart then
			local distance = (entry.model.PrimaryPart.Position - position).Magnitude
			if distance < bestDistance then
				best = entry
				bestDistance = distance
			end
		end
	end
	return best, bestDistance
end

-- Rain down a burst of rare-or-better brainrots for the event.
function Spawner.rainBurst(parent, count)
	for _ = 1, count do
		local def = Config.rollBrainrot()
		while def.rarity == "Common" do
			def = Config.rollBrainrot()
		end
		local mutation = Config.rollMutation(Spawner.goldenHour)
		local x = Config.CONVEYOR_START.X + math.random() * 200
		local model = BrainrotModels.buildBrainrot(def, mutation, Vector3.new(x, Config.CONVEYOR_START.Y, Config.CONVEYOR_START.Z), math.rad(90))
		model.Parent = parent
		table.insert(Spawner.wild, {
			def = def,
			mutation = mutation,
			model = model,
			distance = x - Config.CONVEYOR_START.X,
			speed = def.walk,
			bornAt = os.clock(),
		})
	end
end

-- The spawn loop: one new brainrot every few seconds, forever.
function Spawner.start(parent)
	if Spawner.running then
		return
	end
	Spawner.running = true
	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_INTERVAL)
			Spawner.spawnOne(parent)
		end
	end)
	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(0.1)
			local now = os.clock()
			Spawner.stepWild(now - last)
			last = now
		end
	end)
end

return Spawner
