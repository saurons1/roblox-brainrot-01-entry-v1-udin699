-- Brainrot Bay: the remotes.
-- Every RemoteEvent and RemoteFunction the client and server share
-- is made here, in one place, so a name typed wrong in one script
-- fails loudly at boot instead of silently in play.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}
Remotes.events = {}

local EVENT_NAMES = {
	"CatchRequest",
	"PlaceRequest",
	"SlapRequest",
	"LockRequest",
	"RebirthRequest",
	"UpgradeRequest",
	"Notify",
	"UpdateHud",
	"TsunamiWarning",
	"TsunamiStart",
	"TsunamiEnd",
	"EventBanner",
	"StealAlert",
	"BrainrotBought",
	"BaseLocked",
}

local FUNCTION_NAMES = {
	"GetState",
}

-- Make the folder and every remote. Called once, at boot.
function Remotes.init()
	local folder = Instance.new("Folder")
	folder.Name = "BrainrotRemotes"
	folder.Parent = ReplicatedStorage

	for _, name in ipairs(EVENT_NAMES) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		Remotes.events[name] = remote
	end

	for _, name in ipairs(FUNCTION_NAMES) do
		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = folder
		Remotes.events[name] = remote
	end
end

function Remotes.get(name)
	return Remotes.events[name]
end

-- One call to reach every client at once.
function Remotes.broadcast(name, ...)
	local remote = Remotes.events[name]
	if remote then
		remote:FireAllClients(...)
	end
end

-- One call to reach a single player.
function Remotes.send(player, name, ...)
	local remote = Remotes.events[name]
	if remote then
		remote:FireClient(player, ...)
	end
end

return Remotes
