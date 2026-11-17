-- Brainrot Bay: the tsunami.
-- Every two minutes the sea rises. Ten seconds of siren warning,
-- then a wall of water sweeps the island from north to south.
-- Bases are safe ground; anyone caught outside is washed back to
-- spawn and drops whatever they carry. Wild brainrots are swept
-- away with the wave.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local Steal = require(script.Parent:WaitForChild("Steal"))
local Spawner = require(script.Parent:WaitForChild("Spawner"))

local Tsunami = {}
Tsunami.nextAt = 0
Tsunami.wave = nil
Tsunami.running = false

-- Build the wave wall once: a huge translucent slab, parked under
-- the island until the siren sounds.
function Tsunami.buildWave(folder)
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(520, 44, 12)
	wave.Position = Vector3.new(0, -60, -260)
	wave.Color = Color3.fromRGB(40, 110, 220)
	wave.Material = Enum.Material.SmoothPlastic
	wave.Transparency = 0.3
	wave.Anchored = true
	wave.CanCollide = false
	wave.TopSurface = Enum.SurfaceType.Smooth
	wave.BottomSurface = Enum.SurfaceType.Smooth
	wave.Parent = folder
	Tsunami.wave = wave
	return wave
end

-- Wash one player out: drop what they carry, send them to spawn.
function Tsunami.washOut(player)
	Steal.dropCarried(player, "washed away by the tsunami")
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(Config.SPAWN_POINT)
	end
	Remotes.send(player, "Notify", "The tsunami washed you back to spawn!")
end

-- Sweep the wave across the island. Anyone outside a base is washed.
function Tsunami.sweep()
	local wave = Tsunami.wave
	if not wave then
		return
	end
	Remotes.broadcast("TsunamiStart")
	local steps = 40
	for step = 1, steps do
		local z = -260 + (520 * step / steps)
		wave.Position = Vector3.new(0, 20, z)
		for _, player in ipairs(State.allPlayers()) do
			local character = player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root and math.abs(root.Position.Z - z) < 10 and not Bases.insideAnyBase(root.Position) then
					Tsunami.washOut(player)
				end
			end
		end
		task.wait(Config.TSUNAMI_WAVE_TIME / steps)
	end
	wave.Position = Vector3.new(0, -60, -260)
	for _, entry in ipairs(Spawner.wild) do
		Spawner.removeWild(entry)
	end
	Spawner.wild = {}
	Remotes.broadcast("TsunamiEnd")
end

-- One full cycle: warn, then sweep, then schedule the next.
function Tsunami.cycle()
	Remotes.broadcast("TsunamiWarning", Config.TSUNAMI_WARNING)
	task.wait(Config.TSUNAMI_WARNING)
	Tsunami.sweep()
	Tsunami.nextAt = os.clock() + Config.TSUNAMI_PERIOD
end

function Tsunami.start(folder)
	if Tsunami.running then
		return
	end
	Tsunami.running = true
	Tsunami.buildWave(folder)
	Tsunami.nextAt = os.clock() + Config.TSUNAMI_PERIOD
	task.spawn(function()
		while true do
			local waitFor = Tsunami.nextAt - os.clock()
			if waitFor > 0 then
				task.wait(waitFor)
			end
			Tsunami.cycle()
		end
	end)
end

function Tsunami.secondsUntil()
	return math.max(0, Tsunami.nextAt - os.clock())
end

return Tsunami
