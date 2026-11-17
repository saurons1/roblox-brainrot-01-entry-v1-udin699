-- Brainrot Bay: the single player-data store.
-- Every other server module reads and writes player data through here,
-- so money, upgrades, locks and carried brainrots never disagree.

local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local State = {}

local records = {}
local baseOwner = {}
local playerBase = {}

local function firstFreeBase()
	for index = 1, Config.BaseCount do
		if baseOwner[index] == nil then
			return index
		end
	end
	return nil
end

function State.create(player)
	local base = firstFreeBase()
	local record = {
		Money = Config.StartMoney,
		Rebirths = 0,
		Multiplier = 1,
		Upgrades = { Speed = 0, Range = 0, Plots = 0, Boost = 0 },
		Carrying = nil,
		LockUntil = 0,
		LockReadyAt = 0,
		SlapReadyAt = 0,
		Base = base,
		LeaderMoney = nil,
		LeaderRebirths = nil,
	}
	records[player] = record
	if base ~= nil then
		baseOwner[base] = player
		playerBase[player] = base
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Value = Config.StartMoney
	money.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = stats
	record.LeaderMoney = money
	record.LeaderRebirths = rebirths
	return record
end

function State.get(player)
	return records[player]
end

function State.remove(player)
	local base = playerBase[player]
	if base ~= nil then
		baseOwner[base] = nil
		playerBase[player] = nil
	end
	records[player] = nil
end

function State.baseOf(player)
	return playerBase[player]
end

function State.ownerOfBase(index)
	return baseOwner[index]
end

function State.addMoney(player, amount)
	local record = records[player]
	if record == nil then
		return
	end
	record.Money = record.Money + amount
	if record.LeaderMoney ~= nil then
		record.LeaderMoney.Value = math.floor(record.Money)
	end
end

function State.spend(player, amount)
	local record = records[player]
	if record == nil or record.Money < amount then
		return false
	end
	record.Money = record.Money - amount
	if record.LeaderMoney ~= nil then
		record.LeaderMoney.Value = math.floor(record.Money)
	end
	return true
end

function State.plotCount(player)
	local record = records[player]
	if record == nil then
		return Config.PlotsPerBase
	end
	return math.min(Config.PlotsPerBase + 2 * record.Upgrades.Plots, Config.PlotsMax)
end

function State.walkSpeed(player)
	local record = records[player]
	if record == nil then
		return 16
	end
	return 16 + 2 * record.Upgrades.Speed
end

function State.catchRange(player)
	local record = records[player]
	if record == nil then
		return Config.CatchRange
	end
	return Config.CatchRange + 2 * record.Upgrades.Range
end

function State.earnMultiplier(player)
	local record = records[player]
	if record == nil then
		return 1
	end
	return record.Multiplier * (1 + 0.25 * record.Upgrades.Boost)
end

function State.applyRebirth(player)
	local record = records[player]
	if record == nil then
		return
	end
	record.Rebirths = record.Rebirths + 1
	record.Multiplier = math.min(Config.RebirthStep * record.Rebirths, Config.RebirthMax)
	if record.LeaderRebirths ~= nil then
		record.LeaderRebirths.Value = record.Rebirths
	end
end

function State.allPlayers()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if records[player] ~= nil then
			table.insert(list, player)
		end
	end
	return list
end

return State
