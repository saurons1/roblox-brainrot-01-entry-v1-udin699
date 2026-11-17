-- Brainrot Bay: money tick, buying, rebirths and upgrades.
-- Every second each placed brainrot pays its rate times its mutation,
-- the owner's rebirth multiplier, the Boost upgrade and the running
-- event. Buying takes the nearest brainrot in reach off the belt and
-- puts it on the buyer's first free plot.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Format"))
local State = require(script.Parent.State)

local Economy = {}

local function placedRate(player, bases, events)
	local total = 0
	for _, item in ipairs(bases.allPlaced(player)) do
		local mult = 1
		if item.Mutation ~= nil then
			mult = item.Mutation.Multiplier
		end
		total = total + item.Def.Rate * mult
	end
	return total * State.earnMultiplier(player) * events.moneyMultiplier()
end

function Economy.snapshot(player, bases, events, tsunami)
	local record = State.get(player)
	if record == nil then
		return nil
	end
	return {
		Money = record.Money,
		Rate = placedRate(player, bases, events),
		Rebirths = record.Rebirths,
		Multiplier = record.Multiplier,
		PlotsUsed = #bases.allPlaced(player),
		PlotsMax = State.plotCount(player),
		Upgrades = record.Upgrades,
		Locked = bases.isLocked(player),
		LockLeft = bases.lockSecondsLeft(player),
		Carrying = record.Carrying ~= nil,
		Event = events.currentName(),
		TsunamiIn = tsunami.secondsUntil(),
	}
end

function Economy.start(bases, events, tsunami, remotes)
	task.spawn(function()
		while true do
			task.wait(Config.TickInterval)
			for _, player in ipairs(State.allPlayers()) do
				local earned = placedRate(player, bases, events)
				if earned > 0 then
					State.addMoney(player, earned)
				end
				local snapshot = Economy.snapshot(player, bases, events, tsunami)
				if snapshot ~= nil then
					remotes.StateUpdate:FireClient(player, snapshot)
				end
			end
		end
	end)
end

-- Buy the nearest brainrot in reach off the belt. If the base is full
-- the money comes straight back and the model is destroyed.
function Economy.buyNearest(player, spawner, bases)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	local character = player.Character
	if character == nil then
		return false, "no character"
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false, "no character"
	end
	local entry = spawner.nearest(root.Position, State.catchRange(player))
	if entry == nil then
		return false, "nothing in reach"
	end
	local price = Config.priceOf(entry.Def)
	if record.Money < price then
		return false, "need " .. Format.money(price)
	end
	if not State.spend(player, price) then
		return false, "need " .. Format.money(price)
	end
	spawner.remove(entry)
	local ok = bases.place(player, entry.Def, entry.Mutation, entry.Model)
	if not ok then
		State.addMoney(player, price)
		entry.Model:Destroy()
		return false, "base is full"
	end
	return true, "Caught " .. entry.Def.Name .. "!"
end

-- Rebirth: pay a cost that doubles each time, lose the base, gain a
-- permanent earnings multiplier that grows by two each rebirth to x10.
function Economy.rebirth(player, bases)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	local cost = Config.RebirthBaseCost * (2 ^ record.Rebirths)
	if record.Money < cost then
		return false, "need " .. Format.money(cost)
	end
	if not State.spend(player, cost) then
		return false, "need " .. Format.money(cost)
	end
	bases.clearBase(player)
	State.applyRebirth(player)
	return true, "Rebirth! Earnings x" .. tostring(record.Multiplier)
end

-- Buy one level of an upgrade. Speed applies to the character at once.
function Economy.buyUpgrade(player, name)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	local def = Config.Upgrades[name]
	if def == nil then
		return false, "unknown upgrade"
	end
	local level = record.Upgrades[name]
	if level >= def.MaxLevel then
		return false, def.Name .. " is maxed out"
	end
	local cost = def.BaseCost * (def.CostGrowth ^ level)
	if record.Money < cost then
		return false, "need " .. Format.money(cost)
	end
	if not State.spend(player, cost) then
		return false, "need " .. Format.money(cost)
	end
	record.Upgrades[name] = level + 1
	if name == "Speed" then
		local character = player.Character
		if character ~= nil then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid ~= nil then
				humanoid.WalkSpeed = State.walkSpeed(player)
			end
		end
	end
	return true, def.Name .. " level " .. tostring(level + 1)
end

return Economy
