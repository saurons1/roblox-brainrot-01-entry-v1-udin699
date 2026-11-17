-- Brainrot Bay: server boot.
-- Requires every module in order, builds the island, starts the
-- loops, and wires the remotes the client calls. Nothing else
-- runs on the server; every job lives in its own module.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Server = script.Parent

local State = require(Server:WaitForChild("State"))
local Remotes = require(Server:WaitForChild("Remotes"))
local World = require(Server:WaitForChild("World"))
local Bases = require(Server:WaitForChild("Bases"))
local Spawner = require(Server:WaitForChild("Spawner"))
local Economy = require(Server:WaitForChild("Economy"))
local Steal = require(Server:WaitForChild("Steal"))
local Tsunami = require(Server:WaitForChild("Tsunami"))
local Events = require(Server:WaitForChild("Events"))

Remotes.init()
local island = World.build()
Bases.world = World
Spawner.start(island)
Economy.startTick()
Tsunami.start(island)
Events.start(island)

-- A joining player claims the first free base and gets a wallet.
local function onPlayerAdded(player)
	local baseIndex = Bases.claimBase(player)
	local record = State.addPlayer(player, baseIndex)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = record.cash
	cash.Parent = leaderstats
	local rate = Instance.new("IntValue")
	rate.Name = "$/s"
	rate.Value = 0
	rate.Parent = leaderstats
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			local current = State.get(player)
			if current then
				cash.Value = math.floor(current.cash)
				rate.Value = math.floor(State.effectiveRate(player))
			end
		end
	end)
	Remotes.send(player, "Notify", "Welcome to " .. Config.GAME_NAME .. "! Press E near a brainrot to buy it.")
	Remotes.send(player, "UpdateHud", Economy.hudState(player))
end

-- A leaving player frees their base and drops what they carry.
local function onPlayerRemoving(player)
	local record = State.get(player)
	if record and record.carrying then
		Steal.dropCarried(player, "left the game")
	end
	for plotIndex, entry in pairs(record and record.plots or {}) do
		if entry.model then
			entry.model:Destroy()
		end
	end
	Bases.releaseBase(player)
	State.removePlayer(player)
end

-- Keep walk speed honest: upgrades and carrying both change it.
local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	task.wait(0.5)
	humanoid.WalkSpeed = State.walkSpeed(player)
	humanoid.Died:Connect(function()
		local record = State.get(player)
		if record and record.carrying then
			Steal.dropCarried(player, "got knocked out")
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

-- The remotes the client calls. Each answers with ok and a message
-- the client shows, and the server re-checks every rule itself.
Remotes.get("CatchRequest").OnServerEvent:Connect(function(player)
	local ok, message = Economy.buyBrainrot(player)
	if not ok then
		Remotes.send(player, "Notify", message)
	end
end)

Remotes.get("PlaceRequest").OnServerEvent:Connect(function(player)
	local ok, message = Steal.placeCarried(player)
	if not ok then
		Remotes.send(player, "Notify", message)
	end
end)

Remotes.get("SlapRequest").OnServerEvent:Connect(function(player)
	local ok, message = Steal.slap(player)
	if not ok then
		Remotes.send(player, "Notify", message)
	end
end)

Remotes.get("LockRequest").OnServerEvent:Connect(function(player)
	local ok, message = Bases.lockBase(player)
	if ok then
		Remotes.send(player, "Notify", "Base locked for " .. Config.LOCK_TIME .. "s!")
	else
		Remotes.send(player, "Notify", message)
	end
end)

Remotes.get("RebirthRequest").OnServerEvent:Connect(function(player)
	local ok, message = Economy.rebirth(player)
	if not ok then
		Remotes.send(player, "Notify", message)
	end
end)

Remotes.get("UpgradeRequest").OnServerEvent:Connect(function(player, key)
	local ok, message = Economy.buyUpgrade(player, key)
	if not ok then
		Remotes.send(player, "Notify", message)
	end
end)

-- The client asks for a fresh snapshot when it boots.
Remotes.get("GetState").OnServerInvoke = function(player)
	return Economy.hudState(player)
end
