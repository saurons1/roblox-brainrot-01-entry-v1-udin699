-- Brainrot Bay: client boot.
-- Builds the HUD, binds the keys, and keeps the HUD fed from the
-- server's state updates. On spawn the camera opens with a short look
-- at the island, then hands control back to the player.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Hud = require(script.Parent.Hud)
local Input = require(script.Parent.Input)

local screen = Hud.build(player, remotes)
Input.bind(remotes)

remotes.StateUpdate.OnClientEvent:Connect(function(data)
	if data ~= nil then
		Hud.update(screen, data)
	end
end)

remotes.Notify.OnClientEvent:Connect(function(text, kind)
	Hud.banner(screen, text, kind)
end)

local function intro(character)
	local humanoid = character:WaitForChild("Humanoid")
	local camera = workspace.CurrentCamera
	if camera == nil then
		return
	end
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(Vector3.new(0, 45, 95), Vector3.new(0, 0, -20))
	task.delay(2.5, function()
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end)
end

player.CharacterAdded:Connect(function(character)
	intro(character)
end)
if player.Character ~= nil then
	intro(player.Character)
end
