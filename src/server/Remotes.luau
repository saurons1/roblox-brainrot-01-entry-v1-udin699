-- Brainrot Bay: the remotes both sides talk through.
-- Client to server: Catch (E, context sensitive), Slap (F),
-- ToggleLock (Q), Rebirth, BuyUpgrade. Server to client: StateUpdate
-- (HUD snapshot every tick) and Notify (one-line banner messages).
-- Stealing goes through Catch: near a rival plot it steals, near the
-- conveyor it buys, while carrying it places on your own base.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local function makeEvent(name)
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = folder
	Remotes[name] = event
	return event
end

makeEvent("Catch")
makeEvent("Slap")
makeEvent("ToggleLock")
makeEvent("Rebirth")
makeEvent("BuyUpgrade")
makeEvent("StateUpdate")
makeEvent("Notify")

return Remotes

-- The folder lives in ReplicatedStorage so both server and client can
-- find the same events by name with WaitForChild("Remotes").
