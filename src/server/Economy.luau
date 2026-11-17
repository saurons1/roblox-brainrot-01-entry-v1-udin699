-- Brainrot Bay: the economy.
-- Money ticks once a second from every brainrot on every base.
-- Cash buys brainrots, upgrades and rebirths; rebirths multiply
-- all future earnings. The leaderboard board shows the top earners.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Format"))
local State = require(script.Parent:WaitForChild("State"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local BrainrotModels = require(script.Parent:WaitForChild("BrainrotModels"))
local Spawner = require(script.Parent:WaitForChild("Spawner"))

local Economy = {}
Economy.running = false
Economy.doubleMoney = false

-- One second of earnings for one player.
function Economy.payPlayer(player)
	local rate = State.effectiveRate(player)
	if rate > 0 then
		State.earn(player, rate * Config.MONEY_TICK)
	end
end

-- The tick loop: pay everyone, push their HUD numbers, refresh
-- the board every few ticks.
function Economy.startTick()
	if Economy.running then
		return
	end
	Economy.running = true
	local tick = 0
	task.spawn(function()
		while true do
			task.wait(Config.MONEY_TICK)
			tick = tick + 1
			for _, player in ipairs(State.allPlayers()) do
				Economy.payPlayer(player)
				Remotes.send(player, "UpdateHud", Economy.hudState(player))
			end
			if tick % 5 == 0 then
				Economy.refreshLeaderboard()
			end
		end
	end)
end

-- Everything the HUD needs, in one table.
function Economy.hudState(player)
	local record = State.get(player)
	if not record then
		return {}
	end
	return {
		cash = record.cash,
		rate = State.effectiveRate(player),
		rebirths = record.rebirths,
		mult = State.multiplier(player),
		owned = State.plotCount(player),
		plots = record.plotCount,
		locked = Bases.isLocked(player),
		lockLeft = Bases.lockRemaining(player),
		upgrades = record.upgrades,
		carrying = record.carrying ~= nil,
		tsunamiLeft = require(script.Parent:WaitForChild("Tsunami")).secondsUntil(),
	}
end

-- Buy the nearest wild brainrot on the conveyor. It walks to the
-- buyer's first free plot and starts earning at once.
function Economy.buyBrainrot(player)
	local record = State.get(player)
	if not record then
		return false, "no record"
	end
	local now = os.clock()
	if now < record.catchReadyAt then
		return false, "catch is cooling down"
	end
	local character = player.Character
	if not character then
		return false, "no character"
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false, "no character"
	end
	local entry, distance = Spawner.nearestWild(root.Position, State.catchRange(player))
	if not entry then
		return false, "no brainrot in reach"
	end
	if record.cash < entry.def.price then
		return false, "need " .. Format.money(entry.def.price)
	end
	if not State.freePlot(player) then
		return false, "base is full - buy more plots"
	end
	record.catchReadyAt = now + Config.CATCH_COOLDOWN
	State.spend(player, entry.def.price)
	Spawner.removeEntry(entry)
	local plotIndex = Bases.placeOnPlot(player, entry.model, entry.def, entry.mutation)
	if not plotIndex then
		State.earn(player, entry.def.price)
		return false, "base is full - buy more plots"
	end
	Remotes.send(player, "BrainrotBought", entry.def.name, entry.mutation.name, entry.def.rate * entry.mutation.mult)
	Remotes.send(player, "UpdateHud", Economy.hudState(player))
	return true, "bought"
end

-- Rebirth: wipe cash and brainrots for a permanent x2 multiplier.
function Economy.rebirth(player)
	local record = State.get(player)
	if not record then
		return false, "no record"
	end
	if record.mult >= Config.REBIRTH_MULT_MAX then
		return false, "max rebirth multiplier reached"
	end
	local needed = Config.REBIRTH_BASE * (record.rebirths + 1)
	if record.totalEarned < needed then
		return false, "need " .. Format.money(needed) .. " total earned"
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - Config.TOTEM_POSITION).Magnitude > 14 then
		return false, "stand at the Rebirth Totem to rebirth"
	end
	for plotIndex, entry in pairs(record.plots) do
		if entry.model then
			entry.model:Destroy()
		end
		record.plots[plotIndex] = nil
	end
	record.owned = {}
	record.cash = Config.START_CASH
	record.rebirths = record.rebirths + 1
	record.mult = math.min(Config.REBIRTH_MULT_MAX, record.mult * Config.REBIRTH_MULT_STEP)
	Remotes.send(player, "Notify", "REBIRTH! Your money multiplier is now x" .. record.mult)
	Remotes.broadcast("Notify", player.DisplayName .. " rebirthed! Multiplier x" .. record.mult .. "!")
	Remotes.send(player, "UpdateHud", Economy.hudState(player))
	return true, "rebirthed"
end

-- Buy one level of an upgrade at the stand. Costs grow per level.
function Economy.buyUpgrade(player, key)
	local record = State.get(player)
	if not record then
		return false, "no record"
	end
	local def = Config.UPGRADES[key]
	if not def then
		return false, "no such upgrade"
	end
	local level = record.upgrades[key] or 0
	if level >= def.max then
		return false, def.name .. " is maxed"
	end
	local cost = def.costs[level + 1]
	if record.cash < cost then
		return false, "need " .. Format.money(cost)
	end
	State.spend(player, cost)
	record.upgrades[key] = level + 1
	if key == "Plots" then
		record.plotCount = record.plotCount + 2
	end
	Remotes.send(player, "Notify", def.name .. " level " .. (level + 1) .. " bought!")
	Remotes.send(player, "UpdateHud", Economy.hudState(player))
	return true, "bought"
end

-- The top three earners, written onto the board at the plaza.
function Economy.refreshLeaderboard()
	local records = State.allRecords()
	table.sort(records, function(a, b)
		return a.totalEarned > b.totalEarned
	end)
	local board = workspace:FindFirstChild("BrainrotBay")
	if board then
		board = board:FindFirstChild("LeaderboardBoard")
	end
	if not board then
		return
	end
	local gui = board:FindFirstChild("LeaderboardGui")
	if not gui then
		return
	end
	for slot = 1, 3 do
		local line = gui:FindFirstChild("Rank" .. slot)
		if line then
			local record = records[slot]
			if record then
				line.Text = slot .. ". " .. record.player.DisplayName .. " - " .. Format.short(record.totalEarned)
			else
				line.Text = slot .. ". ---"
			end
		end
	end
end

return Economy
