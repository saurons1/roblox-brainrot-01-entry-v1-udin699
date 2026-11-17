-- Brainrot Bay: stealing, carrying, slapping and dropping.
-- A steal lifts a brainrot off a rival's plot and welds it above the
-- thief's head; the thief walks slower until it is placed on their own
-- base. A slap drops what a nearby thief is carrying and knocks them
-- back, and the dropped brainrot goes home to its old plot.

local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent.State)

local Steal = {}

local function rootOf(player)
	local character = player.Character
	if character == nil then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function distanceTo(player, position)
	local root = rootOf(player)
	if root == nil then
		return math.huge
	end
	return (root.Position - position).Magnitude
end

local function setCarriedParts(model, anchored, collide)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = anchored
			part.CanCollide = collide
		end
	end
end

function Steal.restoreSpeed(player)
	local character = player.Character
	if character == nil then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= nil then
		humanoid.WalkSpeed = State.walkSpeed(player)
	end
end

function Steal.carry(player, def, mutation, model, fromPlayer, fromBase, fromPlot)
	local record = State.get(player)
	local root = rootOf(player)
	if record == nil or root == nil then
		return false
	end
	record.Carrying = {
		Def = def,
		Mutation = mutation,
		Model = model,
		FromPlayer = fromPlayer,
		FromBase = fromBase,
		FromPlot = fromPlot,
	}
	setCarriedParts(model, false, false)
	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = root
	weld.Part1 = model.PrimaryPart
	weld.C0 = CFrame.new(0, 3.5, 0)
	weld.Parent = root
	local character = player.Character
	if character ~= nil then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid ~= nil then
			humanoid.WalkSpeed = State.walkSpeed(player) * 0.7
		end
	end
	return true
end

-- Lift the nearest brainrot off an unlocked rival plot in reach.
function Steal.trySteal(player, bases)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	if record.Carrying ~= nil then
		return false, "already carrying one"
	end
	local myBase = State.baseOf(player)
	local range = State.catchRange(player)
	local best = nil
	local bestDist = range
	for _, plot in ipairs(bases.describePlots()) do
		if plot.Base ~= myBase and plot.Occupant ~= nil and plot.Owner ~= nil then
			if not bases.isLocked(plot.Owner) then
				local dist = distanceTo(player, plot.Position)
				if dist < bestDist then
					bestDist = dist
					best = plot
				end
			end
		end
	end
	if best == nil then
		return false, "no brainrot in reach"
	end
	local taken = bases.take(best.Base, best.Plot)
	if taken == nil then
		return false, "too late"
	end
	Steal.carry(player, taken.Def, taken.Mutation, taken.Model, best.Owner, best.Base, best.Plot)
	return true, "Stole " .. taken.Def.Name .. "! Run home!"
end

-- Put what is carried on the thief's own first free plot. A full base
-- sends the brainrot back to the plot it was stolen from.
function Steal.placeCarried(player, bases)
	local record = State.get(player)
	if record == nil or record.Carrying == nil then
		return false, "not carrying"
	end
	local carried = record.Carrying
	local root = rootOf(player)
	if root ~= nil then
		local weld = root:FindFirstChild("CarryWeld")
		if weld ~= nil then
			weld:Destroy()
		end
	end
	record.Carrying = nil
	local ok = bases.place(player, carried.Def, carried.Mutation, carried.Model)
	if not ok then
		bases.placeAt(carried.FromBase, carried.FromPlot, carried.Def, carried.Mutation, carried.Model)
		Steal.restoreSpeed(player)
		return false, "base is full, returned it"
	end
	Steal.restoreSpeed(player)
	return true, "Placed " .. carried.Def.Name .. " on your base!"
end

-- Drop what is carried and send it home to its old plot.
function Steal.dropCarried(player, bases)
	local record = State.get(player)
	if record == nil or record.Carrying == nil then
		return
	end
	local carried = record.Carrying
	local root = rootOf(player)
	if root ~= nil then
		local weld = root:FindFirstChild("CarryWeld")
		if weld ~= nil then
			weld:Destroy()
		end
	end
	record.Carrying = nil
	local ok = bases.placeAt(carried.FromBase, carried.FromPlot, carried.Def, carried.Mutation, carried.Model)
	if not ok then
		carried.Model:Destroy()
	end
	Steal.restoreSpeed(player)
end

-- Slap every thief in reach: they drop their catch and get knocked back.
function Steal.slap(player, bases)
	local record = State.get(player)
	if record == nil then
		return false, "no data"
	end
	if os.time() < record.SlapReadyAt then
		return false, "slap recharging"
	end
	record.SlapReadyAt = os.time() + Config.SlapCooldown
	local root = rootOf(player)
	if root == nil then
		return false, "no character"
	end
	local hits = 0
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local otherRecord = State.get(other)
			if otherRecord ~= nil and otherRecord.Carrying ~= nil then
				local otherRoot = rootOf(other)
				if otherRoot ~= nil and (otherRoot.Position - root.Position).Magnitude <= Config.SlapRange then
					Steal.dropCarried(other, bases)
					local away = otherRoot.Position - root.Position
					away = Vector3.new(away.X, 0, away.Z)
					if away.Magnitude > 0.1 then
						otherRoot.CFrame = CFrame.new(otherRoot.Position + away.Unit * 10)
					end
					hits = hits + 1
				end
			end
		end
	end
	if hits == 0 then
		return false, "nobody to slap"
	end
	return true, "Slapped " .. tostring(hits) .. " thief!"
end

return Steal
