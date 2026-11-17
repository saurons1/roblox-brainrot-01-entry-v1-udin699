-- Brainrot Bay: client input.
-- E catches a brainrot or places the one you carry, F slaps a
-- thief, Q locks your base, R rebirths at the totem, U opens the
-- upgrades. Keys are bound with ContextActionService, never with
-- InputBegan, because Roblox's camera scripts eat the arrow keys
-- and any handler that returns on gameProcessedEvent never sees
-- them. The hint line always names the action E will take here.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Hud = require(script.Parent:WaitForChild("Hud"))

local Input = {}
Input.remotes = nil
Input.carrying = false

function Input.init(remotes)
	Input.remotes = remotes
	local function fire(name)
		return function(_, state, _)
			if state == Enum.UserInputState.Begin then
				remotes[name]:FireServer()
			end
		end
	end

	-- E does the context action: place what you carry, else catch.
	ContextActionService:BindAction("BrainrotCatch", function(_, state, _)
		if state == Enum.UserInputState.Begin then
			if Input.carrying then
				remotes.PlaceRequest:FireServer()
			else
				remotes.CatchRequest:FireServer()
			end
		end
	end, false, Enum.KeyCode.E)

	ContextActionService:BindAction("BrainrotSlap", fire("SlapRequest"), false, Enum.KeyCode.F)
	ContextActionService:BindAction("BrainrotLock", fire("LockRequest"), false, Enum.KeyCode.Q)
	ContextActionService:BindAction("BrainrotRebirth", fire("RebirthRequest"), false, Enum.KeyCode.R)
	ContextActionService:BindAction("BrainrotUpgrades", function(_, state, _)
		if state == Enum.UserInputState.Begin then
			Hud.toggleUpgrades()
		end
	end, false, Enum.KeyCode.U)

	-- The hint line follows where you stand.
	task.spawn(function()
		while true do
			task.wait(0.25)
			Input.refreshHint()
		end
	end)
end

-- Where the player stands decides what E does, and the hint says so.
function Input.refreshHint()
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local pos = root.Position
	if Input.carrying then
		Hud.setHint("[E] Place your stolen brainrot on YOUR base  [F] Slap  [Q] Lock base")
		return
	end
	if (pos - Config.TOTEM_POSITION).Magnitude <= 14 then
		Hud.setHint("[R] Rebirth at the totem  [E] Catch  [F] Slap  [Q] Lock base")
		return
	end
	if (pos - Config.UPGRADE_POSITION).Magnitude <= 14 then
		Hud.setHint("[U] Open upgrades  [E] Catch  [F] Slap  [Q] Lock base")
		return
	end
	if math.abs(pos.Z + 165) <= 16 then
		Hud.setHint("[E] Catch a brainrot  [F] Slap a thief  [Q] Lock base")
		return
	end
	Hud.setHint("[E] Catch  [F] Slap  [Q] Lock base  [R] Rebirth  [U] Upgrades")
end

return Input
