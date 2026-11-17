-- Brainrot Bay: the ScreenGui HUD over the 3D world.
-- Money sits top right, clear of Roblox's top-left menu buttons.
-- Banners sit top centre, the prompt sits bottom centre, and the
-- action buttons sit bottom right with the upgrades panel above them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Format = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Format"))

local Hud = {}

local function makeLabel(parent, name, text, position, size, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Position = position
	label.Size = size
	label.AnchorPoint = anchor or Vector2.new(0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.4
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = parent
	return label
end

local function makeButton(parent, name, text, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Parent = parent
	return button
end

function Hud.build(player, remotes)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBayHud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local screen = { Gui = gui, Remotes = remotes }

	screen.Money = makeLabel(gui, "Money", "Money: $50", UDim2.new(1, -16, 0, 12), UDim2.new(0, 260, 0, 36), Vector2.new(1, 0))
	screen.Rate = makeLabel(gui, "Rate", "+$0/s", UDim2.new(1, -16, 0, 50), UDim2.new(0, 260, 0, 28), Vector2.new(1, 0))
	screen.Rebirths = makeLabel(gui, "Rebirths", "Rebirths: 0 (x1)", UDim2.new(1, -16, 0, 80), UDim2.new(0, 260, 0, 28), Vector2.new(1, 0))

	screen.Event = makeLabel(gui, "Event", "", UDim2.new(0.5, 0, 0, 12), UDim2.new(0, 420, 0, 32), Vector2.new(0.5, 0))
	screen.Event.TextColor3 = Color3.fromRGB(255, 220, 0)
	screen.Tsunami = makeLabel(gui, "Tsunami", "", UDim2.new(0.5, 0, 0, 48), UDim2.new(0, 420, 0, 32), Vector2.new(0.5, 0))
	screen.Tsunami.TextColor3 = Color3.fromRGB(255, 90, 90)

	screen.Message = makeLabel(gui, "Message", "", UDim2.new(0.5, 0, 0.5, -80), UDim2.new(0, 560, 0, 34), Vector2.new(0.5, 0.5))

	screen.Prompt = makeLabel(gui, "Prompt", "Walk to the conveyor and press E to catch a brainrot", UDim2.new(0.5, 0, 1, -90), UDim2.new(0, 560, 0, 30), Vector2.new(0.5, 1))

	screen.LockButton = makeButton(gui, "LockButton", "Lock Base (Q)", UDim2.new(1, -176, 1, -160), UDim2.new(0, 160, 0, 40))
	screen.RebirthButton = makeButton(gui, "RebirthButton", "Rebirth (x2)", UDim2.new(1, -176, 1, -112), UDim2.new(0, 160, 0, 40))
	screen.UpgradesButton = makeButton(gui, "UpgradesButton", "Upgrades", UDim2.new(1, -176, 1, -64), UDim2.new(0, 160, 0, 40))

	screen.LockButton.MouseButton1Click:Connect(function()
		remotes.ToggleLock:FireServer()
	end)
	screen.RebirthButton.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)

	-- Upgrades panel, hidden until the Upgrades button opens it.
	local panel = Instance.new("Frame")
	panel.Name = "UpgradesPanel"
	panel.Position = UDim2.new(1, -360, 1, -260)
	panel.Size = UDim2.new(0, 340, 0, 190)
	panel.BackgroundColor3 = Color3.fromRGB(25, 40, 60)
	panel.BackgroundTransparency = 0.2
	panel.Visible = false
	panel.Parent = gui
	screen.Panel = panel
	makeLabel(panel, "Title", "Upgrades", UDim2.new(0, 10, 0, 6), UDim2.new(0, 320, 0, 26), Vector2.new(0, 0))
	screen.UpgradeButtons = {}
	local order = { "Speed", "Range", "Plots", "Boost" }
	for i, key in ipairs(order) do
		local def = Config.Upgrades[key]
		local button = makeButton(panel, key, def.Name .. "  Lv 0  -  $" .. tostring(def.BaseCost), UDim2.new(0, 10, 0, 36 + (i - 1) * 36), UDim2.new(0, 320, 0, 30))
		button.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
		button.MouseButton1Click:Connect(function()
			remotes.BuyUpgrade:FireServer(key)
		end)
		screen.UpgradeButtons[key] = button
	end
	screen.UpgradesButton.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)

	return screen
end

function Hud.update(screen, data)
	screen.Money.Text = "Money: " .. Format.money(data.Money)
	screen.Rate.Text = "+" .. Format.rate(data.Rate)
	screen.Rebirths.Text = "Rebirths: " .. tostring(data.Rebirths) .. " (x" .. tostring(data.Multiplier) .. ")"
	if data.Event ~= nil and data.Event ~= "" then
		screen.Event.Text = "EVENT: " .. data.Event
	else
		screen.Event.Text = ""
	end
	if data.TsunamiIn ~= nil and data.TsunamiIn <= 10 then
		screen.Tsunami.Text = "TSUNAMI IN " .. tostring(data.TsunamiIn) .. "s — RUN HOME!"
	else
		screen.Tsunami.Text = ""
	end
	if data.Carrying then
		screen.Prompt.Text = "Carrying a brainrot! Press E on your base to place it"
	elseif data.Locked then
		screen.Prompt.Text = "Base locked — " .. tostring(data.LockLeft) .. "s left"
	else
		screen.Prompt.Text = "Press E to catch  •  F to slap  •  Q to lock base"
	end
	local nextMult = math.min(Config.RebirthStep * (data.Rebirths + 1), Config.RebirthMax)
	local rebirthCost = Config.RebirthBaseCost * (2 ^ data.Rebirths)
	screen.RebirthButton.Text = "Rebirth x" .. tostring(nextMult) .. " — " .. Format.money(rebirthCost)
	for key, button in pairs(screen.UpgradeButtons) do
		local def = Config.Upgrades[key]
		local level = 0
		if data.Upgrades ~= nil and data.Upgrades[key] ~= nil then
			level = data.Upgrades[key]
		end
		if level >= def.MaxLevel then
			button.Text = def.Name .. "  MAX"
		else
			local cost = def.BaseCost * (def.CostGrowth ^ level)
			button.Text = def.Name .. "  Lv " .. tostring(level) .. "  -  " .. Format.money(cost)
		end
	end
end

-- One centre message for a few seconds, coloured by kind.
function Hud.banner(screen, text, kind)
	screen.Message.Text = text
	if kind == "warn" then
		screen.Message.TextColor3 = Color3.fromRGB(255, 90, 90)
	elseif kind == "ok" then
		screen.Message.TextColor3 = Color3.fromRGB(120, 255, 120)
	else
		screen.Message.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	task.delay(3, function()
		if screen.Message.Text == text then
			screen.Message.Text = ""
		end
	end)
end

return Hud
