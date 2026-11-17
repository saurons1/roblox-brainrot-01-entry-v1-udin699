-- Brainrot Bay: random timed events.
-- Every minute and a half to two and a half minutes one event runs for
-- a minute: Brainrot Rain halves the spawn interval, Double Money
-- doubles every payout, Golden Hour makes every spawn at least Golden.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local Events = {}

local current = nil

function Events.start(remotes)
	task.spawn(function()
		while true do
			task.wait(math.random(Config.EventIntervalMin, Config.EventIntervalMax))
			local name = Config.Events[math.random(1, #Config.Events)]
			current = { Name = name, EndsAt = os.time() + Config.EventDuration }
			remotes.Notify:FireAllClients("EVENT: " .. name .. " for 60s!", "event")
			task.wait(Config.EventDuration)
			current = nil
			remotes.Notify:FireAllClients("Event over.", "info")
		end
	end)
end

function Events.currentName()
	if current == nil then
		return ""
	end
	return current.Name
end

function Events.moneyMultiplier()
	if current ~= nil and current.Name == "Double Money" then
		return 2
	end
	return 1
end

function Events.spawnIntervalFactor()
	if current ~= nil and current.Name == "Brainrot Rain" then
		return 0.5
	end
	return 1
end

function Events.forceGolden()
	return current ~= nil and current.Name == "Golden Hour"
end

return Events

-- The current event is the only shared state; the multipliers above
-- are the whole interface the spawner and the economy need.
