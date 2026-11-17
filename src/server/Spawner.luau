-- Brainrot Bay: the conveyor spawner.
-- Brainrots wash in on the dock, ride the belt west to east, and fall
-- off the end if nobody catches them. Spawn picks a rarity by weight,
-- then a brainrot of that rarity, then rolls a mutation.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotModels = require(script.Parent.BrainrotModels)

local Spawner = {}

local active = {}
local nextId = 1
local worldRef = nil
local eventsRef = nil

function Spawner.start(world, events)
	worldRef = world
	eventsRef = events
	task.spawn(function()
		while true do
			local interval = Config.SpawnInterval * eventsRef.spawnIntervalFactor()
			task.wait(interval)
			if #active < Config.MaxOnConveyor then
				Spawner.spawnOne()
			end
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		Spawner.step(dt)
	end)
end

function Spawner.spawnOne()
	local def = Config.pickBrainrot()
	local mutation = Config.rollMutation(eventsRef.forceGolden())
	local model = BrainrotModels.build(def, mutation)
	model.Parent = workspace
	local entry = {
		Id = nextId,
		Def = def,
		Mutation = mutation,
		Model = model,
		From = worldRef.ConveyorWaypoints[1],
		To = worldRef.ConveyorWaypoints[2],
		Progress = 0,
	}
	nextId = nextId + 1
	table.insert(active, entry)
	model:PivotTo(CFrame.new(entry.From))
	return entry
end

function Spawner.step(dt)
	local distance = worldRef.ConveyorWaypoints[2].X - worldRef.ConveyorWaypoints[1].X
	for i = #active, 1, -1 do
		local entry = active[i]
		entry.Progress = entry.Progress + Config.ConveyorSpeed * dt
		if entry.Progress >= distance then
			entry.Model:Destroy()
			table.remove(active, i)
		else
			local t = entry.Progress / distance
			local pos = entry.From:lerp(entry.To, t)
			local bob = math.sin(os.clock() * 3 + entry.Id) * 0.2
			local spot = Vector3.new(pos.X, pos.Y + bob, pos.Z)
			entry.Model:PivotTo(CFrame.lookAt(spot, Vector3.new(spot.X + 1, spot.Y, spot.Z)))
		end
	end
end

-- Nearest brainrot on the belt to a position, inside a range.
function Spawner.nearest(position, range)
	local best = nil
	local bestDist = range
	for _, entry in ipairs(active) do
		local pivot = entry.Model:GetPivot()
		local flat = Vector3.new(pivot.X - position.X, 0, pivot.Z - position.Z)
		local dist = flat.Magnitude
		if dist < bestDist then
			bestDist = dist
			best = entry
		end
	end
	return best
end

function Spawner.byId(id)
	for _, entry in ipairs(active) do
		if entry.Id == id then
			return entry
		end
	end
	return nil
end

-- Take an entry off the belt without destroying its model:
-- the buyer keeps the model and places it on a base.
function Spawner.remove(entry)
	for i, other in ipairs(active) do
		if other == entry then
			table.remove(active, i)
			return true
		end
	end
	return false
end

function Spawner.count()
	return #active
end

return Spawner
