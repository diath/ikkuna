function table.contains(t, v)
	for _, value in pairs(t) do
		if value == v then
			return true
		end
	end

	return false
end

function table.copy(t)
	local result = {}
	for key, value in pairs(t) do
		if type(value) == 'table' then
			result[key] = table.copy(value)
		else
			result[key] = value
		end
	end

	return result
end
