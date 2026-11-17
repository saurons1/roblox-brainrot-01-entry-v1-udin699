-- Brainrot Bay: shared configuration.
-- One table holds the whole cast, the rarities, the mutations, the
-- timings and the upgrade ladder, so server and client agree on every
-- number the game shows or charges.

local Config = {}

Config.GameName = "Brainrot Bay"
Config.StartMoney = 50
Config.BaseCount = 8
Config.PlotsPerBase = 6
Config.PlotsMax = 12
Config.PricePerRate = 15

-- Rarities, lightest first. Weight is the share of spawns.
Config.Rarities = {
	{ Name = "Common", Weight = 40, Color = Color3.fromRGB(178, 178, 178) },
	{ Name = "Rare", Weight = 25, Color = Color3.fromRGB(86, 178, 255) },
	{ Name = "Epic", Weight = 15, Color = Color3.fromRGB(186, 92, 255) },
	{ Name = "Legendary", Weight = 10, Color = Color3.fromRGB(255, 176, 32) },
	{ Name = "Mythic", Weight = 6, Color = Color3.fromRGB(255, 92, 122) },
	{ Name = "Brainrot God", Weight = 3, Color = Color3.fromRGB(255, 222, 0) },
	{ Name = "Secret", Weight = 1, Color = Color3.fromRGB(0, 255, 200) },
}

-- The cast. Rate is dollars per second. Price is Rate * PricePerRate.
-- Body picks the silhouette, Accent picks the feature on top.
Config.Brainrots = {
	{ Name = "Soggy Cereal Sam", Rarity = "Common", Rate = 1, Body = "Ball", Color = Color3.fromRGB(224, 196, 138), Accent = Color3.fromRGB(255, 255, 255) },
	{ Name = "Noodle Ned", Rarity = "Common", Rate = 2, Body = "Block", Color = Color3.fromRGB(240, 214, 120), Accent = Color3.fromRGB(200, 60, 60) },
	{ Name = "Capybara Cappuccino", Rarity = "Rare", Rate = 5, Body = "Ball", Color = Color3.fromRGB(150, 110, 70), Accent = Color3.fromRGB(255, 240, 210) },
	{ Name = "Sir Barksalot", Rarity = "Rare", Rate = 8, Body = "Block", Color = Color3.fromRGB(120, 150, 220), Accent = Color3.fromRGB(255, 220, 90) },
	{ Name = "DJ Pickle", Rarity = "Epic", Rate = 15, Body = "Cylinder", Color = Color3.fromRGB(90, 200, 90), Accent = Color3.fromRGB(40, 40, 40) },
	{ Name = "Grandma's WiFi Ghost", Rarity = "Epic", Rate = 25, Body = "Ball", Color = Color3.fromRGB(230, 230, 245), Accent = Color3.fromRGB(150, 180, 255) },
	{ Name = "Moon Cheese Moose", Rarity = "Legendary", Rate = 50, Body = "Block", Color = Color3.fromRGB(250, 230, 140), Accent = Color3.fromRGB(140, 100, 40) },
	{ Name = "Turbo Toilet Titan", Rarity = "Legendary", Rate = 80, Body = "Cylinder", Color = Color3.fromRGB(240, 240, 240), Accent = Color3.fromRGB(60, 140, 255) },
	{ Name = "Professor Bubblebrain", Rarity = "Mythic", Rate = 150, Body = "Ball", Color = Color3.fromRGB(140, 220, 255), Accent = Color3.fromRGB(255, 140, 200) },
	{ Name = "Emperor Eggplant", Rarity = "Mythic", Rate = 250, Body = "Block", Color = Color3.fromRGB(120, 50, 160), Accent = Color3.fromRGB(90, 220, 90) },
	{ Name = "Lord Loopty-Loop", Rarity = "Brainrot God", Rate = 500, Body = "Ball", Color = Color3.fromRGB(255, 210, 0), Accent = Color3.fromRGB(255, 90, 90) },
	{ Name = "The Forbidden Fridge", Rarity = "Secret", Rate = 1000, Body = "Block", Color = Color3.fromRGB(200, 230, 255), Accent = Color3.fromRGB(0, 220, 180) },
}

-- Mutations. Chance is a percentage of spawns; the first roll that hits wins.
Config.Mutations = {
	{ Name = "Golden", Multiplier = 2, Chance = 8, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Diamond", Multiplier = 5, Chance = 3, Color = Color3.fromRGB(180, 240, 255) },
	{ Name = "Rainbow", Multiplier = 10, Chance = 1, Color = Color3.fromRGB(255, 120, 220) },
	{ Name = "Void", Multiplier = 25, Chance = 0.2, Color = Color3.fromRGB(120, 40, 180) },
}

-- Timings, in seconds unless named otherwise.
Config.SpawnInterval = 6
Config.MaxOnConveyor = 8
Config.ConveyorSpeed = 4
Config.TickInterval = 1
Config.TsunamiInterval = 120
Config.TsunamiWarning = 10
Config.LockDuration = 45
Config.LockCooldown = 90
Config.CatchRange = 10
Config.SlapRange = 7
Config.SlapCooldown = 3
Config.EventIntervalMin = 90
Config.EventIntervalMax = 150
Config.EventDuration = 60
Config.LeaderboardInterval = 5

-- Rebirths: each one adds this multiplier, up to the cap.
Config.RebirthBaseCost = 5000
Config.RebirthStep = 2
Config.RebirthMax = 10

-- Upgrades: cost = BaseCost * CostGrowth ^ level.
Config.Upgrades = {
	Speed = { Name = "Speed", MaxLevel = 5, BaseCost = 250, CostGrowth = 2, Desc = "+2 walk speed per level" },
	Range = { Name = "Range", MaxLevel = 5, BaseCost = 250, CostGrowth = 2, Desc = "+2 catch range per level" },
	Plots = { Name = "Plots", MaxLevel = 3, BaseCost = 500, CostGrowth = 2, Desc = "+2 base plots per level" },
	Boost = { Name = "Boost", MaxLevel = 4, BaseCost = 500, CostGrowth = 2, Desc = "+25% earnings per level" },
}

Config.Events = { "Brainrot Rain", "Double Money", "Golden Hour" }

-- Prices are filled in from the rates so the two never drift apart.
for _, brainrot in ipairs(Config.Brainrots) do
	brainrot.Price = brainrot.Rate * Config.PricePerRate
end

function Config.priceOf(brainrot)
	return brainrot.Rate * Config.PricePerRate
end

function Config.rarityColor(rarityName)
	for _, rarity in ipairs(Config.Rarities) do
		if rarity.Name == rarityName then
			return rarity.Color
		end
	end
	return Color3.fromRGB(200, 200, 200)
end

-- Pick a rarity by weight, then a brainrot of that rarity at random.
function Config.pickBrainrot()
	local total = 0
	for _, rarity in ipairs(Config.Rarities) do
		total = total + rarity.Weight
	end
	local roll = math.random() * total
	local picked = Config.Rarities[1].Name
	for _, rarity in ipairs(Config.Rarities) do
		roll = roll - rarity.Weight
		if roll <= 0 then
			picked = rarity.Name
			break
		end
	end
	local pool = {}
	for _, brainrot in ipairs(Config.Brainrots) do
		if brainrot.Rarity == picked then
			table.insert(pool, brainrot)
		end
	end
	return pool[math.random(1, #pool)]
end

-- Roll a mutation. The first chance the roll falls inside wins.
function Config.rollMutation(forceGolden)
	if forceGolden then
		return Config.Mutations[1]
	end
	local roll = math.random() * 100
	local used = 0
	for _, mutation in ipairs(Config.Mutations) do
		used = used + mutation.Chance
		if roll <= used then
			return mutation
		end
	end
	return nil
end

return Config
