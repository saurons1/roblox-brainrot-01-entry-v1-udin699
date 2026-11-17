-- Brainrot Bay: shared formatting helpers.
-- One place for every number the player reads, so "$1,234/s" and
-- "1:23" look the same on the HUD, the labels and the boards.

local Format = {}

-- 1234567 -> "$1,234,567". Handles negatives by keeping the sign.
function Format.money(amount)
	local n = math.floor(amount + 0.5)
	local sign = ""
	if n < 0 then
		sign = "-"
		n = -n
	end
	local text = tostring(n)
	local out = ""
	while #text > 3 do
		out = "," .. string.sub(text, -3) .. out
		text = string.sub(text, 1, -4)
	end
	return sign .. "$" .. text .. out
end

-- 90 -> "1:30", 8 -> "0:08". Used for the tsunami and event timers.
function Format.clock(seconds)
	seconds = math.max(0, math.floor(seconds + 0.5))
	local minutes = math.floor(seconds / 60)
	local rest = seconds - minutes * 60
	if rest < 10 then
		return minutes .. ":0" .. rest
	end
	return minutes .. ":" .. rest
end

-- 1500 -> "1.5K", 2500000 -> "2.5M". Short form for tight labels.
function Format.short(amount)
	if amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("%.1fK", amount / 1000)
	else
		return tostring(math.floor(amount + 0.5))
	end
end

-- "1500" per second, as the brainrot labels show it.
function Format.rate(amount)
	return Format.short(amount) .. "/s"
end

return Format
