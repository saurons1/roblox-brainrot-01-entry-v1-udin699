-- Brainrot Bay: stealing.
-- Touch a rival's brainrot while their base is unlocked and you
-- carry it over your head, slowed, all the way home. The owner
-- slaps you to make you drop it; the tsunami washes it out of
-- your hands too. A stolen brainrot placed on your own plot
-- starts earning for you.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local BrainrotModels = require(script.Parent:WaitForChild("BrainrotModels"))

local Steal = {}

-- The carried brainrot follows its thief's head, one step a frame.
function Steal.followCarrier(thief, entry)
	task.spawn(function()
		while entry.model.Parent do
			local record = State.get(thief)
			if not record or record.carrying ~= entry then
				break
			end
			local character = thief.Character
			if not character then
				break
			end
			local head = character:FindFirstChild("Head")
			if not head then
				break
			end
			entry.model:PivotTo(CFrame.new(head.Position + Vector3.new(0, Config.CARRY_HEIGHT, 0)))
			task.wait(0.05)
		end
	end)
end

-- Pick up a brainrot from its owner's plot. Called by touch.
function Steal.pickUp(thief, owner, plotIndex)
	local thiefRecord = State.get(thief)
	if not thiefRecord or thiefRecord.carrying then
		return false
	end
	if Bases.isLocked(owner) then
		return false
	end
	local entry = Bases.liftFromPlot(owner, plotIndex)
	if not entry then
		return false
	end
	thiefRecord.carrying = entry
	entry.stolenFrom = owner
	entry.model.Parent = workspace:FindFirstChild("BrainrotBay")
	Steal.followCarrier(thief, entry)
	local humanoid = thief.Character and thief.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = State.walkSpeed(thief)
	end
	Remotes.send(thief, "Notify", "You stole " .. entry.def.name .. "! Run home!")
	Remotes.send(owner, "StealAlert", thief.DisplayName .. " stole your " .. entry.def.name .. "!")
	Remotes.broadcast("StealAlert", thief.DisplayName .. " stole " .. entry.def.name .. " from " .. owner.DisplayName .. "!")
	return true
end

-- Drop what you carry where you stand. The brainrot goes back to
-- its owner's first free plot, or despawns when that base is full.
function Steal.dropCarried(thief, reason)
	local record = State.get(thief)
	if not record or not record.carrying then
		return false
	end
	local entry = record.carrying
	record.carrying = nil
	local humanoid = thief.Character and thief.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = State.walkSpeed(thief)
	end
	local owner = entry.stolenFrom
	if owner and State.get(owner) then
		local plotIndex = State.freePlot(owner)
		if plotIndex then
			Bases.placeOnPlot(owner, entry.model, entry.def, entry.mutation)
			Remotes.send(thief, "Notify", "You dropped " .. entry.def.name .. " (" .. reason .. ")")
			return true
		end
	end
	if entry.model then
		entry.model:Destroy()
	end
	Remotes.send(thief, "Notify", "You dropped " .. entry.def.name .. " (" .. reason .. ")")
	return true
end

-- Place the carried brainrot on your own free plot. It earns for you.
function Steal.placeCarried(thief)
	local record = State.get(thief)
	if not record or not record.carrying then
		return false, "you carry nothing"
	end
	if not Bases.onOwnBase(thief) then
		return false, "stand on your own base to place it"
	end
	local entry = record.carrying
	local plotIndex = Bases.placeOnPlot(thief, entry.model, entry.def, entry.mutation)
	if not plotIndex then
		return false, "base is full - buy more plots"
	end
	record.carrying = nil
	local humanoid = thief.Character and thief.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = State.walkSpeed(thief)
	end
	Remotes.send(thief, "Notify", entry.def.name .. " is yours now! +" .. entry.rate .. "/s")
	Remotes.send(thief, "UpdateHud", require(script.Parent:WaitForChild("Economy")).hudState(thief))
	return true, "placed"
end

-- Slap the nearest thief who carries one of YOUR brainrots.
function Steal.slap(player)
	local record = State.get(player)
	if not record then
		return false, "no record"
	end
	local now = os.clock()
	if now < record.slapReadyAt then
		return false, "slap is cooling down"
	end
	local character = player.Character
	if not character then
		return false, "no character"
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false, "no character"
	end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local otherRecord = State.get(other)
			if otherRecord and otherRecord.carrying and otherRecord.carrying.stolenFrom == player then
				local otherRoot = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				if otherRoot and (otherRoot.Position - root.Position).Magnitude <= 8 then
					record.slapReadyAt = now + Config.SLAP_COOLDOWN
					Steal.dropCarried(other, "slapped by " .. player.DisplayName)
					Remotes.send(player, "Notify", "You slapped " .. other.DisplayName .. " and got it back!")
					return true, "slapped"
				end
			end
		end
	end
	return false, "no thief in reach"
end

-- Watch every owned brainrot's body for a rival's touch.
function Steal.watchPlot(owner, plotIndex, entry)
	local body = entry.model and entry.model:FindFirstChild("Body")
	if not body then
		return
	end
	body.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local thief = Players:GetPlayerFromCharacter(character)
		if not thief or thief == owner then
			return
		end
		local ownerRecord = State.get(owner)
		if not ownerRecord or not ownerRecord.plots[plotIndex] then
			return
		end
		Steal.pickUp(thief, owner, plotIndex)
	end)
end

return Steal
