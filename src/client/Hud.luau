-- Brainrot Bay: the client HUD.
-- One ScreenGui over the 3D world: cash and rate top-right (kept
-- clear of Roblox's own menu buttons top-left), the tsunami timer
-- top-centre, upgrade buttons down the right, hints along the
-- bottom, and a notification feed in the middle. Everything the
-- player must read stays big enough to read once scaled down.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Format = require(Shared:WaitForChild("Format"))

local Hud = {}
Hud.built = false

local function makeLabel(parent, name, size, position, text, textSize, color, font)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.4
	label.Font = font or Enum.Font.GothamBold
	label.Parent = parent
	return label
end

local function makeButton(parent, name, size, position, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextSize = 18
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

-- Build the whole interface once, at boot.
function Hud.build()
	if Hud.built then
		return
	end
	Hud.built = true
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotBayHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")
	Hud.gui = gui

	-- Cash, top-right, far from the menu buttons.
	local cashPanel = Instance.new("Frame")
	cashPanel.Name = "CashPanel"
	cashPanel.Size = UDim2.new(0, 260, 0, 110)
	cashPanel.Position = UDim2.new(1, -280, 0, 16)
	cashPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	cashPanel.BackgroundTransparency = 0.25
	cashPanel.BorderSizePixel = 0
	cashPanel.Parent = gui
	local cashCorner = Instance.new("UICorner")
	cashCorner.CornerRadius = UDim.new(0, 10)
	cashCorner.Parent = cashPanel
	Hud.cashLabel = makeLabel(cashPanel, "Cash", UDim2.new(1, -16, 0, 44), UDim2.new(0, 8, 0, 6), "$50", 34, Color3.fromRGB(120, 255, 140), Enum.Font.GothamBlack)
	Hud.cashLabel.TextXAlignment = Enum.TextXAlignment.Left
	Hud.rateLabel = makeLabel(cashPanel, "Rate", UDim2.new(1, -16, 0, 26), UDim2.new(0, 8, 0, 52), "$0/s", 22, Color3.fromRGB(255, 255, 255))
	Hud.rateLabel.TextXAlignment = Enum.TextXAlignment.Left
	Hud.multLabel = makeLabel(cashPanel, "Mult", UDim2.new(1, -16, 0, 22), UDim2.new(0, 8, 0, 80), "x1 - 0 rebirths", 17, Color3.fromRGB(255, 220, 90))
	Hud.multLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Tsunami timer, top-centre.
	Hud.tsunamiLabel = makeLabel(gui, "Tsunami", UDim2.new(0, 420, 0, 40), UDim2.new(0.5, -210, 0, 14), "Tsunami in 2:00", 26, Color3.fromRGB(140, 210, 255), Enum.Font.GothamBlack)
	Hud.tsunamiLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
	Hud.tsunamiLabel.BackgroundTransparency = 0.3

	-- Event banner, under the timer.
	Hud.eventLabel = makeLabel(gui, "Event", UDim2.new(0, 520, 0, 36), UDim2.new(0.5, -260, 0, 60), "", 24, Color3.fromRGB(255, 220, 90), Enum.Font.GothamBlack)
	Hud.eventLabel.Visible = false

	-- Notification feed, centre screen.
	Hud.notifyLabel = makeLabel(gui, "Notify", UDim2.new(0, 640, 0, 34), UDim2.new(0.5, -320, 0, 120), "", 22, Color3.fromRGB(255, 255, 255))
	Hud.notifyLabel.Visible = false

	-- Hints, bottom-centre.
	Hud.hintLabel = makeLabel(gui, "Hints", UDim2.new(0, 700, 0, 30), UDim2.new(0.5, -350, 1, -44), "[E] Catch  [F] Slap  [Q] Lock base  [R] Rebirth  [U] Upgrades", 19, Color3.fromRGB(255, 255, 255))
	Hud.hintLabel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	Hud.hintLabel.BackgroundTransparency = 0.35

	-- Base status, bottom-left.
	Hud.baseLabel = makeLabel(gui, "Base", UDim2.new(0, 300, 0, 30), UDim2.new(0, 16, 1, -44), "Base: 0/8 plots", 19, Color3.fromRGB(255, 255, 255))
	Hud.baseLabel.TextXAlignment = Enum.TextXAlignment.Left
	Hud.baseLabel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	Hud.baseLabel.BackgroundTransparency = 0.35

	-- Upgrade buttons, right side under the cash panel.
	Hud.upgradePanel = Instance.new("Frame")
	Hud.upgradePanel.Name = "UpgradePanel"
	Hud.upgradePanel.Size = UDim2.new(0, 260, 0, 220)
	Hud.upgradePanel.Position = UDim2.new(1, -280, 0, 140)
	Hud.upgradePanel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	Hud.upgradePanel.BackgroundTransparency = 0.25
	Hud.upgradePanel.BorderSizePixel = 0
	Hud.upgradePanel.Visible = false
	Hud.upgradePanel.Parent = gui
	local upCorner = Instance.new("UICorner")
	upCorner.CornerRadius = UDim.new(0, 10)
	upCorner.Parent = Hud.upgradePanel
	makeLabel(Hud.upgradePanel, "Title", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 4), "UPGRADES", 20, Color3.fromRGB(255, 220, 90), Enum.Font.GothamBlack)
	Hud.upgradeButtons = {}
	local keys = { "Speed", "Range", "Plots", "Boost" }
	for i, key in ipairs(keys) do
		local def = Config.UPGRADES[key]
		local button = makeButton(Hud.upgradePanel, key, UDim2.new(1, -16, 0, 40), UDim2.new(0, 8, 0, 34 + (i - 1) * 46), def.name .. " - " .. Format.money(def.costs[1]))
		button.TextSize = 16
		Hud.upgradeButtons[key] = button
	end
end

-- Refresh every number from one server snapshot.
function Hud.update(state)
	if not Hud.built or not state or not state.cash then
		return
	end
	Hud.cashLabel.Text = Format.money(state.cash)
	Hud.rateLabel.Text = Format.rate(state.rate) .. "  (" .. state.owned .. " brainrots)"
	Hud.multLabel.Text = "x" .. state.mult .. "  -  " .. state.rebirths .. " rebirths"
	if state.locked then
		Hud.baseLabel.Text = "Base: " .. state.owned .. "/" .. state.plots .. " plots  -  LOCKED " .. math.ceil(state.lockLeft) .. "s"
	else
		Hud.baseLabel.Text = "Base: " .. state.owned .. "/" .. state.plots .. " plots"
	end
	if state.tsunamiLeft then
		if state.tsunamiLeft > 60 then
			Hud.tsunamiLabel.Text = "Tsunami in " .. Format.clock(state.tsunamiLeft)
			Hud.tsunamiLabel.TextColor3 = Color3.fromRGB(140, 210, 255)
		else
			Hud.tsunamiLabel.Text = "Tsunami in " .. Format.clock(state.tsunamiLeft) .. " - RUN HOME!"
			Hud.tsunamiLabel.TextColor3 = Color3.fromRGB(255, 120, 90)
		end
	end
	for key, button in pairs(Hud.upgradeButtons) do
		local def = Config.UPGRADES[key]
		local level = state.upgrades[key] or 0
		if level >= def.max then
			button.Text = def.name .. " - MAX"
		else
			button.Text = def.name .. " Lv" .. level .. " - " .. Format.money(def.costs[level + 1])
		end
	end
end

-- One notification in the middle of the screen, gone in 3 seconds.
function Hud.showNotification(text)
	if not Hud.built then
		return
	end
	Hud.notifyLabel.Text = text
	Hud.notifyLabel.Visible = true
	task.delay(3, function()
		if Hud.notifyLabel.Text == text then
			Hud.notifyLabel.Visible = false
		end
	end)
end

-- The event banner: name, description and a countdown.
function Hud.showEvent(name, desc, seconds)
	if not Hud.built then
		return
	end
	if name == "" then
		Hud.eventLabel.Visible = false
		return
	end
	Hud.eventLabel.Text = name .. ": " .. desc
	Hud.eventLabel.Visible = true
	task.delay(seconds, function()
		Hud.eventLabel.Visible = false
	end)
end

-- The tsunami siren: red, urgent, impossible to miss.
function Hud.showTsunamiWarning(seconds)
	if not Hud.built then
		return
	end
	Hud.tsunamiLabel.Text = "TSUNAMI IN " .. seconds .. "s - GET TO YOUR BASE!"
	Hud.tsunamiLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
end

function Hud.showTsunamiStart()
	if not Hud.built then
		return
	end
	Hud.tsunamiLabel.Text = "TSUNAMI! HOLD ON!"
	Hud.tsunamiLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
end

function Hud.showTsunamiEnd()
	if not Hud.built then
		return
	end
	Hud.tsunamiLabel.Text = "All clear - the wave has passed"
	Hud.tsunamiLabel.TextColor3 = Color3.fromRGB(140, 255, 140)
end

function Hud.setHint(text)
	if Hud.built then
		Hud.hintLabel.Text = text
	end
end

function Hud.toggleUpgrades()
	if Hud.built then
		Hud.upgradePanel.Visible = not Hud.upgradePanel.Visible
	end
end

return Hud
