-- Brainrot Bay: the tsunami.
-- Every two minutes a wave sweeps the island. Ten seconds before it
-- hits, everyone is warned and a wall of water starts rolling in from
-- the north. When it lands, anyone caught outside their own base is
-- washed back to their spawn and drops whatever they were carrying.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)

local Tsunami = {}

local nextAt = 0

function Tsunami.start(world, bases, steal, remotes)
	nextAt = os.time() + Config.TsunamiInterval
	local warned = false
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.time()
			if not warned and now >= nextAt - Config.TsunamiWarning then
				warned = true
				remotes.Notify:FireAllClients("TSUNAMI INCOMING — DASH HOME!", "warn")
				Tsunami.showWave()
			elseif now >= nextAt then
				Tsunami.strike(world, bases, steal, remotes)
				nextAt = os.time() + Config.TsunamiInterval
				warned = false
			end
		end
	end)
end

-- A translucent wall that rolls from the north edge to the south edge
-- over about twelve seconds.
function Tsunami.showWave()
	local wall = Instance.new("Part")
	wall.Name = "TsunamiWave"
	wall.Size = Vector3.new(220, 26, 4)
	wall.Position = Vector3.new(0, 10, -110)
	wall.Color = Color3.fromRGB(40, 140, 220)
	wall.Material = Enum.Material.SmoothPlastic
	wall.Transparency = 0.25
	wall.Anchored = true
	wall.CanCollide = false
	wall.Parent = workspace
	task.spawn(function()
		for step = 1, 120 do
			task.wait(0.1)
			if wall.Parent == nil then
				return
			end
			wall.Position = Vector3.new(0, 10, -110 + step * 2)
		end
		wall:Destroy()
	end)
end

-- Wash everyone outside their own base back to its spawn.
function Tsunami.strike(world, bases, steal, remotes)
	remotes.Notify:FireAllClients("TSUNAMI! Swept away outside your base!", "warn")
	for _, player in ipairs(State.allPlayers()) do
		local base = State.baseOf(player)
		local center = nil
		if base ~= nil and world.Bases[base] ~= nil then
			center = world.Bases[base].Center
		end
		local character = player.Character
		local root = nil
		if character ~= nil then
			root = character:FindFirstChild("HumanoidRootPart")
		end
		if root ~= nil and center ~= nil then
			local flat = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
			if flat.Magnitude > 14 then
				steal.dropCarried(player, bases)
				root.CFrame = CFrame.new(world.Bases[base].Spawn)
			end
		end
	end
end

function Tsunami.secondsUntil()
	return math.max(0, nextAt - os.time())
end

return Tsunami
