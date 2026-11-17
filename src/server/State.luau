-- Brainrot Bay: the single state store.
-- Every module reads and writes player data through this one table,
-- so money, brainrots, plots, locks and upgrades never disagree.
-- Nothing here touches the world; it only holds numbers and lists.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local State = {}
State.players = {}

-- A fresh record for a player who just joined.
function State.newPlayerRecord(player)
	return {
		player = player,
		cash = Config.START_CASH,
		totalEarned = 0,
		rebirths = 0,
		mult = 1,
		owned = {},
		plots = {},
		plotCount = Config.PLOTS_PER_BASE,
		baseIndex = 0,
		carrying = nil,
		slapReadyAt = 0,
		catchReadyAt = 0,
		lockUntil = 0,
		lockReadyAt = 0,
		upgrades = { Speed = 0, Range = 0, Plots = 0, Boost = 0 },
		eventMult = 1,
	}
end

function State.addPlayer(player, baseIndex)
	local record = State.newPlayerRecord(player)
	record.baseIndex = baseIndex
	State.players[player.UserId] = record
	return record
end

function State.get(player)
	if typeof(player) == "Instance" then
		return State.players[player.UserId]
	end
	return State.players[player]
end

function State.removePlayer(player)
	State.players[player.UserId] = nil
end

-- Money in, money out. Returns false when the player cannot afford it.
function State.spend(player, amount)
	local record = State.get(player)
	if not record or record.cash < amount then
		return false
	end
	record.cash = record.cash - amount
	return true
end

function State.earn(player, amount)
	local record = State.get(player)
	if not record then
		return
	end
	record.cash = record.cash + amount
	record.totalEarned = record.totalEarned + amount
end

-- The player's current $/s from owned brainrots, before multipliers.
function State.baseRate(player)
	local record = State.get(player)
	if not record then
		return 0
	end
	local total = 0
	for _, entry in ipairs(record.owned) do
		total = total + entry.rate
	end
	return total
end

-- The full multiplier: rebirths, Boost upgrades and the live event.
function State.multiplier(player)
	local record = State.get(player)
	if not record then
		return 1
	end
	local mult = record.mult
	mult = mult * (1.5 ^ record.upgrades.Boost)
	mult = mult * record.eventMult
	return mult
end

-- The $/s the HUD shows: base rate times every multiplier.
function State.effectiveRate(player)
	return State.baseRate(player) * State.multiplier(player)
end

function State.walkSpeed(player)
	local record = State.get(player)
	if not record then
		return 16
	end
	local speed = 16 * (1 + 0.15 * record.upgrades.Speed)
	if record.carrying then
		speed = speed * Config.CARRY_SLOW
	end
	return speed
end

function State.catchRange(player)
	local record = State.get(player)
	if not record then
		return Config.CATCH_RANGE_BASE
	end
	return Config.CATCH_RANGE_BASE + 4 * record.upgrades.Range
end

function State.freePlot(player)
	local record = State.get(player)
	if not record then
		return nil
	end
	for index = 1, record.plotCount do
		if not record.plots[index] then
			return index
		end
	end
	return nil
end

function State.plotCount(player)
	local record = State.get(player)
	if not record then
		return 0
	end
	local count = 0
	for _, _ in pairs(record.plots) do
		count = count + 1
	end
	return count
end

-- Every player currently in the game, for loops that pay or warn all.
function State.allPlayers()
	local list = {}
	for _, record in pairs(State.players) do
		table.insert(list, record.player)
	end
	return list
end

function State.allRecords()
	local list = {}
	for _, record in pairs(State.players) do
		table.insert(list, record)
	end
	return list
end

return State
