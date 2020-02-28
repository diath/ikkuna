function table.contains(t, v)
	for _, value in pairs(t) do
		if value == v then
			return true
		end
	end

	return false
end
