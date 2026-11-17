-- Brainrot Bay: base plots, placement and locks.
-- Each base holds twelve plot pads; six are open at first and the
-- Plots upgrade opens two more per level. A pad tints to the rarity of
-- the brainrot standing on it, and goes back to grey when emptied.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)

local Bases = {}

local plots = {}
local worldRef = nil

function Bases.setup(world)
	worldRef = world
	for index, base in ipairs(world.Bases) do
		local list = {}
		for i, position in ipairs(base.Plots) do
			list[i] = {
				Position = position,
				Pad = base.PadParts[i],
				Occupant = nil,
			}
		end
		plots[index] = list
	end
end

function Bases.plotCount()
	return Config.PlotsMax
end

function Bases.freePlotIndex(player)
	local base = State.baseOf(player)
	if base == nil then
		return nil
	end
	local list = plots[base]
	local open = State.plotCount(player)
	for i = 1, math.min(open, #list) do
		if list[i].Occupant == nil then
			return i
		end
	end
	return nil
end

local function settleModel(model, position)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end
	model:PivotTo(CFrame.new(position))
end

function Bases.placeAt(baseIndex, plotIndex, def, mutation, model)
	local list = plots[baseIndex]
	if list == nil or list[plotIndex] == nil then
		return false
	end
	local plot = list[plotIndex]
	if plot.Occupant ~= nil then
		return false
	end
	plot.Occupant = { Def = def, Mutation = mutation, Model = model }
	settleModel(model, plot.Position)
	plot.Pad.Color = Config.rarityColor(def.Rarity)
	return true
end

function Bases.place(player, def, mutation, model)
	local base = State.baseOf(player)
	local slot = Bases.freePlotIndex(player)
	if base == nil or slot == nil then
		return false
	end
	return Bases.placeAt(base, slot, def, mutation, model)
end

-- Take the occupant off a plot and hand it back, pad reset to grey.
function Bases.take(baseIndex, plotIndex)
	local list = plots[baseIndex]
	if list == nil or list[plotIndex] == nil then
		return nil
	end
	local plot = list[plotIndex]
	local occupant = plot.Occupant
	if occupant == nil then
		return nil
	end
	plot.Occupant = nil
	plot.Pad.Color = Color3.fromRGB(210, 210, 210)
	return occupant
end

function Bases.occupant(baseIndex, plotIndex)
	local list = plots[baseIndex]
	if list == nil or list[plotIndex] == nil then
		return nil
	end
	return list[plotIndex].Occupant
end

-- Every plot on the island, for the steal search.
function Bases.describePlots()
	local out = {}
	for baseIndex, list in ipairs(plots) do
		for plotIndex, plot in ipairs(list) do
			table.insert(out, {
				Base = baseIndex,
				Plot = plotIndex,
				Position = plot.Position,
				Occupant = plot.Occupant,
				Owner = State.ownerOfBase(baseIndex),
			})
		end
	end
	return out
end

-- Everything earning on one player's base.
function Bases.allPlaced(player)
	local base = State.baseOf(player)
	local out = {}
	if base == nil then
		return out
	end
	for _, plot in ipairs(plots[base]) do
		if plot.Occupant ~= nil then
			table.insert(out, plot.Occupant)
		end
	end
	return out
end

-- Empty a whole base, destroying the models. Used by rebirth and by
-- a player leaving, so no orphan brainrot keeps earning.
function Bases.clearBase(player)
	local base = State.baseOf(player)
	if base == nil then
		return
	end
	for _, plot in ipairs(plots[base]) do
		if plot.Occupant ~= nil then
			plot.Occupant.Model:Destroy()
			plot.Occupant = nil
			plot.Pad.Color = Color3.fromRGB(210, 210, 210)
		end
	end
end

function Bases.isLocked(player)
	local record = State.get(player)
	if record == nil then
		return false
	end
	return os.time() < record.LockUntil
end

function Bases.lockSecondsLeft(player)
	local record = State.get(player)
	if record == nil then
		return 0
	end
	return math.max(0, record.LockUntil - os.time())
end

-- Lock the base for LockDuration seconds. The lock can only be raised
-- again once the lock plus the cooldown have both run out.
function Bases.toggleLock(player)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	local now = os.time()
	if now < record.LockReadyAt then
		return false, "Lock recharging: " .. tostring(record.LockReadyAt - now) .. "s"
	end
	record.LockUntil = now + Config.LockDuration
	record.LockReadyAt = now + Config.LockDuration + Config.LockCooldown
	return true, "Base locked for " .. tostring(Config.LockDuration) .. "s!"
end

return Bases
