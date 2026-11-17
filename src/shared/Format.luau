-- Brainrot Bay: small text helpers shared by server and client.
-- Money is shortened past a thousand so HUD labels stay readable.

local Format = {}

local SUFFIXES = { "K", "M", "B", "T" }

function Format.money(amount)
	local whole = math.floor(amount)
	if whole < 1000 then
		return "$" .. tostring(whole)
	end
	local value = amount
	local suffix = 0
	while value >= 1000 and suffix < #SUFFIXES do
		value = value / 1000
		suffix = suffix + 1
	end
	if value >= 100 then
		return "$" .. tostring(math.floor(value)) .. SUFFIXES[suffix]
	end
	return "$" .. string.format("%.1f", value) .. SUFFIXES[suffix]
end

function Format.rate(amount)
	return Format.money(amount) .. "/s"
end

function Format.clock(seconds)
	local left = math.max(0, math.floor(seconds))
	local minutes = math.floor(left / 60)
	local secs = left - minutes * 60
	if secs < 10 then
		return tostring(minutes) .. ":0" .. tostring(secs)
	end
	return tostring(minutes) .. ":" .. tostring(secs)
end

-- One line for a brainrot's floating label: name, rate, rarity,
-- and the mutation up front when there is one.
function Format.label(def, mutation)
	local text = def.Name .. "  " .. Format.rate(def.Rate) .. "  " .. def.Rarity
	if mutation ~= nil then
		text = mutation.Name .. " " .. text .. "  x" .. tostring(mutation.Multiplier)
	end
	return text
end

return Format
