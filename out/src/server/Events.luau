-- Brainrot Bay: timed island events.
-- Every five minutes the island throws an event: brainrots rain
-- from the sky, all earnings double, or mutation chances triple
-- for a minute. The banner tells every player what is happening.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Spawner = require(script.Parent:WaitForChild("Spawner"))
local Economy = require(script.Parent:WaitForChild("Economy"))

local Events = {}
Events.running = false
Events.active = nil

-- Roll one event from the weighted table.
function Events.rollEvent()
	local total = 0
	for _, event in ipairs(Config.EVENTS) do
		total = total + event.weight
	end
	local roll = math.random() * total
	for _, event in ipairs(Config.EVENTS) do
		roll = roll - event.weight
		if roll <= 0 then
			return event
		end
	end
	return Config.EVENTS[1]
end

-- Start an event: apply its effect, banner it, end it on time.
function Events.startEvent(parent)
	local event = Events.rollEvent()
	Events.active = event
	if event.key == "Rain" then
		Spawner.rainBurst(parent, 6)
	elseif event.key == "Double" then
		Economy.doubleMoney = true
		for _, record in ipairs(State.allRecords()) do
			record.eventMult = 2
		end
	elseif event.key == "Golden" then
		Spawner.goldenHour = true
	end
	Remotes.broadcast("EventBanner", event.name, event.desc, Config.EVENT_LENGTH)
	task.delay(Config.EVENT_LENGTH, function()
		Events.endEvent()
	end)
end

function Events.endEvent()
	if not Events.active then
		return
	end
	if Events.active.key == "Double" then
		Economy.doubleMoney = false
		for _, record in ipairs(State.allRecords()) do
			record.eventMult = 1
		end
	elseif Events.active.key == "Golden" then
		Spawner.goldenHour = false
	end
	Events.active = nil
	Remotes.broadcast("EventBanner", "", "", 0)
end

function Events.start(parent)
	if Events.running then
		return
	end
	Events.running = true
	task.spawn(function()
		while true do
			task.wait(Config.EVENT_PERIOD)
			Events.startEvent(parent)
		end
	end)
end

return Events
