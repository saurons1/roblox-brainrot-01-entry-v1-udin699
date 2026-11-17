-- Brainrot Bay: server boot.
-- Requires every module in dependency order, builds the island, starts
-- the loops, and handles players joining and leaving. The Catch remote
-- is context sensitive: carrying places, near a rival plot steals, and
-- near the conveyor buys.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)
local Remotes = require(script.Parent.Remotes)
local World = require(script.Parent.World)
local Spawner = require(script.Parent.Spawner)
local Bases = require(script.Parent.Bases)
local Economy = require(script.Parent.Economy)
local Steal = require(script.Parent.Steal)
local Tsunami = require(script.Parent.Tsunami)
local Events = require(script.Parent.Events)

local world = World.build()
Bases.setup(world)
Spawner.start(world, Events)
Economy.start(Bases, Events, Tsunami, Remotes)
Tsunami.start(world, Bases, Steal, Remotes)
Events.start(Remotes)

local function sendState(player)
	local snapshot = Economy.snapshot(player, Bases, Events, Tsunami)
	if snapshot ~= nil then
		Remotes.StateUpdate:FireClient(player, snapshot)
	end
end

local function onCharacter(player, character)
	local root = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = State.walkSpeed(player)
	local base = State.baseOf(player)
	if base ~= nil and world.Bases[base] ~= nil then
		task.wait(0.2)
		root.CFrame = CFrame.new(world.Bases[base].Spawn)
	end
	task.wait(0.5)
	sendState(player)
end

local function onPlayerAdded(player)
	State.create(player)
	local base = State.baseOf(player)
	if base ~= nil then
		world.setBaseOwner(base, player.Name)
	end
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	sendState(player)
end

local function onPlayerRemoving(player)
	local record = State.get(player)
	if record ~= nil and record.Carrying ~= nil then
		Steal.dropCarried(player, Bases)
	end
	Bases.clearBase(player)
	State.remove(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Remotes.Catch.OnServerEvent:Connect(function(player)
	local record = State.get(player)
	if record == nil then
		return
	end
	local ok, message
	if record.Carrying ~= nil then
		ok, message = Steal.placeCarried(player, Bases)
	else
		ok, message = Steal.trySteal(player, Bases)
		if not ok then
			ok, message = Economy.buyNearest(player, Spawner, Bases)
		end
	end
	Remotes.Notify:FireClient(player, message, ok and "ok" or "info")
	sendState(player)
end)

Remotes.Slap.OnServerEvent:Connect(function(player)
	local ok, message = Steal.slap(player, Bases)
	Remotes.Notify:FireClient(player, message, ok and "ok" or "info")
	sendState(player)
end)

Remotes.ToggleLock.OnServerEvent:Connect(function(player)
	local ok, message = Bases.toggleLock(player)
	Remotes.Notify:FireClient(player, message, ok and "ok" or "info")
	sendState(player)
end)

Remotes.Rebirth.OnServerEvent:Connect(function(player)
	local ok, message = Economy.rebirth(player, Bases)
	Remotes.Notify:FireClient(player, message, ok and "ok" or "info")
	sendState(player)
end)

Remotes.BuyUpgrade.OnServerEvent:Connect(function(player, name)
	local ok, message = Economy.buyUpgrade(player, name)
	Remotes.Notify:FireClient(player, message, ok and "ok" or "info")
	sendState(player)
end)

-- Leaderboard refresh, top five by money.
task.spawn(function()
	while true do
		task.wait(Config.LeaderboardInterval)
		local rows = {}
		for _, player in ipairs(State.allPlayers()) do
			local record = State.get(player)
			if record ~= nil then
				table.insert(rows, { Name = player.Name, Money = record.Money })
			end
		end
		table.sort(rows, function(a, b) return a.Money > b.Money end)
		local lines = {}
		for i = 1, math.min(5, #rows) do
			table.insert(lines, tostring(i) .. ". " .. rows[i].Name .. "  $" .. tostring(math.floor(rows[i].Money)))
		end
		world.setLeaderboard(lines)
	end
end)
