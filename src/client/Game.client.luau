-- Brainrot Bay: client boot.
-- Builds the HUD, binds the keys, wires every remote the server
-- fires, and asks the server for a fresh snapshot. The camera
-- stays Roblox's default third-person camera: the game is played
-- in the 3D world, and the interface is a ScreenGui over it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Client = script.Parent
local Hud = require(Client:WaitForChild("Hud"))
local Input = require(Client:WaitForChild("Input"))

local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")

Hud.build()
Input.init(remotes)

-- Upgrade buttons send one request each, named by their key.
for key, button in pairs(Hud.upgradeButtons) do
	button.MouseButton1Click:Connect(function()
		remotes.UpgradeRequest:FireServer(key)
	end)
end

-- Everything the server tells the client, in one place.
remotes.Notify.OnClientEvent:Connect(function(text)
	Hud.showNotification(text)
end)

remotes.UpdateHud.OnClientEvent:Connect(function(state)
	Input.carrying = state and state.carrying == true
	Hud.update(state)
end)

remotes.TsunamiWarning.OnClientEvent:Connect(function(seconds)
	Hud.showTsunamiWarning(seconds)
end)

remotes.TsunamiStart.OnClientEvent:Connect(function()
	Hud.showTsunamiStart()
end)

remotes.TsunamiEnd.OnClientEvent:Connect(function()
	Hud.showTsunamiEnd()
end)

remotes.EventBanner.OnClientEvent:Connect(function(name, desc, seconds)
	Hud.showEvent(name, desc, seconds)
end)

remotes.StealAlert.OnClientEvent:Connect(function(text)
	Hud.showNotification(text)
end)

remotes.BrainrotBought.OnClientEvent:Connect(function(name, mutation, rate)
	local label = name
	if mutation ~= "" then
		label = mutation .. " " .. name
	end
	Hud.showNotification("You bought " .. label .. " - " .. rate .. "/s!")
end)

remotes.BaseLocked.OnClientEvent:Connect(function(who, seconds)
	Hud.showNotification(who .. " locked their base for " .. seconds .. "s")
end)

-- The server tracks carrying; the client only mirrors it for hints.
local function refreshCarrying()
	local player = Players.LocalPlayer
	local state = remotes.GetState:InvokeServer()
	if state then
		Hud.update(state)
	end
end
refreshCarrying()
