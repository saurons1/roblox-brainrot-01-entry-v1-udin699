-- Brainrot Bay: the beach bases.
-- Eight bases ring the plaza. A player claims one on join; their
-- brainrots stand on its plots and earn money. The owner can lock
-- the base, which stops every steal until the lock runs out.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))

local Bases = {}
Bases.world = nil
Bases.taken = {}

-- Claim the first free base for a player. Returns its index.
function Bases.claimBase(player)
	for index = 1, Config.BASE_COUNT do
		if not Bases.taken[index] then
			Bases.taken[index] = player
			local base = Bases.world.bases[index]
			if base then
				base.signLabel.Text = player.DisplayName .. "'s BASE"
			end
			return index
		end
	end
	return 0
end

function Bases.releaseBase(player)
	local record = State.get(player)
	if not record then
		return
	end
	local index = record.baseIndex
	if index > 0 and Bases.taken[index] == player then
		Bases.taken[index] = nil
		local base = Bases.world.bases[index]
		if base then
			base.signLabel.Text = "EMPTY BASE"
			base.lockGui.Enabled = false
		end
	end
end

function Bases.baseOf(player)
	local record = State.get(player)
	if not record or record.baseIndex < 1 then
		return nil
	end
	return Bases.world.bases[record.baseIndex]
end

function Bases.ownerOf(index)
	return Bases.taken[index]
end

-- Is this player standing on their own base's platform?
function Bases.onOwnBase(player)
	local record = State.get(player)
	if not record or record.baseIndex < 1 then
		return false
	end
	local character = player.Character
	if not character then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	local base = Bases.world.bases[record.baseIndex]
	local offset = root.Position - base.center
	return math.abs(offset.X) <= 20 and math.abs(offset.Z) <= 20
end

-- Is a position inside ANY base's platform? The tsunami spares those.
function Bases.insideAnyBase(position)
	for _, base in ipairs(Bases.world.bases) do
		local offset = position - base.center
		if math.abs(offset.X) <= 20 and math.abs(offset.Z) <= 20 then
			return true
		end
	end
	return false
end

-- Place a brainrot model on a player's free plot. Returns the plot
-- index, or nil when the base is full.
function Bases.placeOnPlot(player, model, def, mutation)
	local record = State.get(player)
	if not record then
		return nil
	end
	local plotIndex = State.freePlot(player)
	if not plotIndex then
		return nil
	end
	local base = Bases.world.bases[record.baseIndex]
	if not base then
		return nil
	end
	local plotPosition = base.plots[plotIndex]
	model:PivotTo(CFrame.new(plotPosition + Vector3.new(0, def.size.Y / 2 + 1, 0)))
	model.Parent = base.folder
	record.plots[plotIndex] = {
		def = def,
		mutation = mutation,
		model = model,
		rate = def.rate * mutation.mult,
	}
	table.insert(record.owned, record.plots[plotIndex])
	-- A rival's touch steals it: watch the body from now on.
	-- Required lazily here, since Steal requires Bases too.
	require(script.Parent:WaitForChild("Steal")).watchPlot(player, plotIndex, record.plots[plotIndex])
	return plotIndex
end

-- Lift a brainrot off its owner's plot, for stealing or rebirth.
function Bases.liftFromPlot(owner, plotIndex)
	local record = State.get(owner)
	if not record then
		return nil
	end
	local entry = record.plots[plotIndex]
	if not entry then
		return nil
	end
	record.plots[plotIndex] = nil
	for index, owned in ipairs(record.owned) do
		if owned == entry then
			table.remove(record.owned, index)
			break
		end
	end
	return entry
end

-- Lock the caller's base. Steals stop until the lock runs out.
function Bases.lockBase(player)
	local record = State.get(player)
	if not record then
		return false, "no record"
	end
	local now = os.clock()
	if now < record.lockReadyAt then
		return false, "lock is cooling down"
	end
	record.lockUntil = now + Config.LOCK_TIME
	record.lockReadyAt = now + Config.LOCK_TIME + Config.LOCK_COOLDOWN
	local base = Bases.world.bases[record.baseIndex]
	if base then
		base.lockGui.Enabled = true
		task.delay(Config.LOCK_TIME, function()
			if base.lockGui then
				base.lockGui.Enabled = false
			end
		end)
	end
	Remotes.broadcast("BaseLocked", player.DisplayName, Config.LOCK_TIME)
	return true, "locked"
end

function Bases.isLocked(player)
	local record = State.get(player)
	if not record then
		return false
	end
	return os.clock() < record.lockUntil
end

function Bases.lockRemaining(player)
	local record = State.get(player)
	if not record then
		return 0
	end
	return math.max(0, record.lockUntil - os.clock())
end

return Bases
