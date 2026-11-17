-- Brainrot Bay: shared configuration.
-- The cast, the rarity ladder, prices, timings and world constants.
-- Both the server and the client read this one table, so a number
-- changed here changes the game everywhere at once.

local Config = {}

Config.GAME_NAME = "Brainrot Bay"
Config.GAME_TAGLINE = "Catch absurd brainrots. Grow your base. Outrun the wave."

-- Rarity ladder, weakest first. Weight is the share of conveyor spawns.
Config.RARITIES = {
	{ key = "Common", name = "Common", color = Color3.fromRGB(190, 190, 190), weight = 40 },
	{ key = "Rare", name = "Rare", color = Color3.fromRGB(80, 160, 255), weight = 26 },
	{ key = "Epic", name = "Epic", color = Color3.fromRGB(170, 90, 255), weight = 16 },
	{ key = "Legendary", name = "Legendary", color = Color3.fromRGB(255, 180, 40), weight = 10 },
	{ key = "Mythic", name = "Mythic", color = Color3.fromRGB(255, 70, 120), weight = 5 },
	{ key = "God", name = "Brainrot God", color = Color3.fromRGB(255, 220, 0), weight = 2 },
	{ key = "Secret", name = "Secret", color = Color3.fromRGB(0, 230, 190), weight = 1 },
}

-- Mutations roll on every catch. Chance is a percent; mult multiplies $/s.
Config.MUTATIONS = {
	{ key = "Normal", name = "", color = Color3.fromRGB(255, 255, 255), chance = 87.8, mult = 1 },
	{ key = "Golden", name = "Golden", color = Color3.fromRGB(255, 215, 0), chance = 8, mult = 2 },
	{ key = "Diamond", name = "Diamond", color = Color3.fromRGB(120, 220, 255), chance = 3, mult = 5 },
	{ key = "Rainbow", name = "Rainbow", color = Color3.fromRGB(255, 110, 220), chance = 1, mult = 10 },
	{ key = "Void", name = "Void", color = Color3.fromRGB(140, 60, 255), chance = 0.2, mult = 25 },
}

-- The cast. rate is money per second; price is rate x 15.
-- shape: Block, Ball or Cylinder. accessory: Cup, Phones, Crown,
-- Ghost, Hat, Antenna or None. Every brainrot is built from parts
-- by BrainrotModels, so no catalog assets are needed.
Config.BRAINROTS = {
	{
		id = "soggy-sam", name = "Soggy Cereal Sam", rarity = "Common", rate = 1,
		shape = "Block", size = Vector3.new(2, 2.4, 2), body = Color3.fromRGB(214, 164, 110),
		accessory = "None", walk = 6,
		blurb = "Left in milk too long. Still crunchy about it.",
	},
	{
		id = "noodle-ned", name = "Noodle Ned", rarity = "Common", rate = 2,
		shape = "Cylinder", size = Vector3.new(2, 2.2, 2), body = Color3.fromRGB(240, 200, 90),
		accessory = "Hat", walk = 7,
		blurb = "A ramen cup that achieved sentience and regrets nothing.",
	},
	{
		id = "capy-cappuccino", name = "Capybara Cappuccino", rarity = "Rare", rate = 5,
		shape = "Block", size = Vector3.new(2.6, 2, 3), body = Color3.fromRGB(150, 105, 70),
		accessory = "Cup", walk = 6,
		blurb = "Chillest animal alive. Froths milk with its mind.",
	},
	{
		id = "sir-barksalot", name = "Sir Barksalot", rarity = "Rare", rate = 8,
		shape = "Block", size = Vector3.new(2.2, 2.4, 2.8), body = Color3.fromRGB(120, 90, 200),
		accessory = "Hat", walk = 8,
		blurb = "A dog in a suit. Barks in board meetings. Promoted twice.",
	},
	{
		id = "dj-pickle", name = "DJ Pickle", rarity = "Epic", rate = 15,
		shape = "Cylinder", size = Vector3.new(2, 3, 2), body = Color3.fromRGB(90, 200, 80),
		accessory = "Phones", walk = 9,
		blurb = "Drops beats, never drops the brine.",
	},
	{
		id = "wifi-ghost", name = "Grandma's WiFi Ghost", rarity = "Epic", rate = 25,
		shape = "Ball", size = Vector3.new(2.4, 2.8, 2.4), body = Color3.fromRGB(230, 235, 245),
		accessory = "Ghost", walk = 7,
		blurb = "Haunts your router. The password is always 'password'.",
	},
	{
		id = "moon-moose", name = "Moon Cheese Moose", rarity = "Legendary", rate = 50,
		shape = "Block", size = Vector3.new(3, 3.2, 3.4), body = Color3.fromRGB(250, 225, 130),
		accessory = "Antenna", walk = 7,
		blurb = "Made of moon cheese. Antlers pick up alien radio.",
	},
	{
		id = "toilet-titan", name = "Turbo Toilet Titan", rarity = "Legendary", rate = 80,
		shape = "Cylinder", size = Vector3.new(3, 2.6, 3), body = Color3.fromRGB(250, 215, 60),
		accessory = "Crown", walk = 6,
		blurb = "Flushes first, asks questions never.",
	},
	{
		id = "prof-bubblebrain", name = "Professor Bubblebrain", rarity = "Mythic", rate = 150,
		shape = "Ball", size = Vector3.new(3, 3, 3), body = Color3.fromRGB(255, 150, 200),
		accessory = "Antenna", walk = 8,
		blurb = "A brain in a jar. Published 400 papers. All about snacks.",
	},
	{
		id = "emperor-eggplant", name = "Emperor Eggplant", rarity = "Mythic", rate = 250,
		shape = "Block", size = Vector3.new(3.2, 3.6, 3), body = Color3.fromRGB(120, 50, 180),
		accessory = "Crown", walk = 6,
		blurb = "Rules the vegetable kingdom with an iron spatula.",
	},
	{
		id = "lord-loopty", name = "Lord Loopty-Loop", rarity = "God", rate = 500,
		shape = "Ball", size = Vector3.new(3.6, 3.6, 3.6), body = Color3.fromRGB(255, 140, 40),
		accessory = "Crown", walk = 9,
		blurb = "An infinite pretzel dragon. Loops forever. Tastes of victory.",
	},
	{
		id = "forbidden-fridge", name = "The Forbidden Fridge", rarity = "Secret", rate = 1000,
		shape = "Block", size = Vector3.new(3.4, 4.4, 2.6), body = Color3.fromRGB(180, 240, 255),
		accessory = "Ghost", walk = 5,
		blurb = "Do not open after midnight. It hums in four languages.",
	},
}

for _, def in ipairs(Config.BRAINROTS) do
	def.price = def.rate * 15
end

-- Timings, in seconds.
Config.MONEY_TICK = 1
Config.SPAWN_INTERVAL = 6
Config.CONVEYOR_LIFETIME = 55
Config.TSUNAMI_PERIOD = 120
Config.TSUNAMI_WARNING = 10
Config.TSUNAMI_WAVE_TIME = 8
Config.LOCK_TIME = 45
Config.LOCK_COOLDOWN = 90
Config.EVENT_PERIOD = 300
Config.EVENT_LENGTH = 60
Config.SLAP_COOLDOWN = 3
Config.CATCH_COOLDOWN = 1

-- Money.
Config.START_CASH = 50
Config.REBIRTH_BASE = 100000
Config.REBIRTH_MULT_STEP = 2
Config.REBIRTH_MULT_MAX = 10

-- The island.
Config.BASE_COUNT = 8
Config.BASE_RADIUS = 115
Config.PLOTS_PER_BASE = 8
Config.PLOT_SIZE = Vector3.new(6, 1, 6)
Config.CONVEYOR_START = Vector3.new(-165, 2, -165)
Config.CONVEYOR_END = Vector3.new(165, 2, -165)
Config.SPAWN_POINT = Vector3.new(0, 3, 30)
Config.TOTEM_POSITION = Vector3.new(0, 0, -20)
Config.UPGRADE_POSITION = Vector3.new(-24, 0, -20)

-- Catching and carrying.
Config.CATCH_RANGE_BASE = 12
Config.CARRY_SLOW = 0.6
Config.CARRY_HEIGHT = 4.5

-- Upgrades sold at the Upgrade Stand. cost grows per level owned.
Config.UPGRADES = {
	Speed = {
		name = "Walk Speed", desc = "+15% walk speed",
		costs = { 500, 2500, 10000 }, max = 3,
	},
	Range = {
		name = "Catch Range", desc = "+4 studs catch range",
		costs = { 400, 2000, 8000 }, max = 3,
	},
	Plots = {
		name = "Base Plots", desc = "+2 brainrot plots",
		costs = { 1000, 5000 }, max = 2,
	},
	Boost = {
		name = "Money Boost", desc = "x1.5 money forever",
		costs = { 5000, 25000, 100000 }, max = 3,
	},
}

-- Timed island events. weight is the share of event rolls.
Config.EVENTS = {
	{ key = "Rain", name = "Brainrot Rain", desc = "Rare brainrots rain from the sky!", weight = 3 },
	{ key = "Double", name = "Double Money", desc = "All earnings DOUBLED for 60 seconds!", weight = 4 },
	{ key = "Golden", name = "Golden Hour", desc = "Mutation chances TRIPLED for 60 seconds!", weight = 3 },
}

-- Lookups the rest of the game uses. Written once, here, so no
-- module repeats the search.
function Config.rarityByKey(key)
	for _, rarity in ipairs(Config.RARITIES) do
		if rarity.key == key then
			return rarity
		end
	end
	return Config.RARITIES[1]
end

function Config.brainrotById(id)
	for _, def in ipairs(Config.BRAINROTS) do
		if def.id == id then
			return def
		end
	end
	return nil
end

function Config.rollRarity()
	local total = 0
	for _, rarity in ipairs(Config.RARITIES) do
		total = total + rarity.weight
	end
	local roll = math.random() * total
	for _, rarity in ipairs(Config.RARITIES) do
		roll = roll - rarity.weight
		if roll <= 0 then
			return rarity.key
		end
	end
	return "Common"
end

function Config.rollMutation(goldenHour)
	local roll = math.random() * 100
	if goldenHour then
		roll = roll / 3
	end
	local acc = 0
	for _, mutation in ipairs(Config.MUTATIONS) do
		acc = acc + mutation.chance
		if roll <= acc then
			return mutation
		end
	end
	return Config.MUTATIONS[1]
end

function Config.rollBrainrot()
	local rarityKey = Config.rollRarity()
	local pool = {}
	for _, def in ipairs(Config.BRAINROTS) do
		if def.rarity == rarityKey then
			table.insert(pool, def)
		end
	end
	if #pool == 0 then
		return Config.BRAINROTS[1]
	end
	return pool[math.random(1, #pool)]
end

return Config
