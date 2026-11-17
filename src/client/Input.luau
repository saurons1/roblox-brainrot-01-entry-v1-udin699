-- Brainrot Bay: keyboard bindings.
-- E is the do-everything key: catch on the conveyor, steal at a rival
-- plot, place while carrying. F slaps a nearby thief, Q locks the base.
-- ContextActionService is used because Roblox's default camera scripts
-- eat the arrow keys before InputBegan ever sees them.

local ContextActionService = game:GetService("ContextActionService")

local Input = {}

function Input.bind(remotes)
	ContextActionService:BindAction("BrainrotCatch", function(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			remotes.Catch:FireServer()
		end
	end, false, Enum.KeyCode.E)

	ContextActionService:BindAction("BrainrotSlap", function(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			remotes.Slap:FireServer()
		end
	end, false, Enum.KeyCode.F)
	ContextActionService:BindAction("BrainrotLock", function(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			remotes.ToggleLock:FireServer()
		end
	end, false, Enum.KeyCode.Q)
end

return Input
