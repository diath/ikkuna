local Set = {}
Set.__index = Set

function Set.create(data)
	local set = setmetatable({
		internalValues = {},
		size = 0,
	}, Set)

	if data then
		if type(data) == 'table' then
			for _, value in pairs(data) do
				set:add(value)
			end
		else
			print('[Warning] Set data not a table.')
		end
	end

	return set
end

function Set.add(self, value)
	if self.internalValues[value] then
		return false
	end

	self.internalValues[value] = true
	self.size = self.size + 1

	return true
end

function Set.remove(self, value)
	if not self.internalValues[value] then
		return false
	end

	self.internalValues[value] = nil
	self.size = self.size - 1

	return true
end

function Set.contains(self, value)
	return self.internalValues[value] ~= nil
end

function Set.clear(self)
	self.internalValues = {}
	self.size = 0
end

function Set.values(self)
	return table.keys(self.internalValues)
end

function Set.pop_first(self)
	local value = self:values()[1]
	if value then
		self:remove(value)
	end

	return value
end

setmetatable(Set, {
	__index = Set,
	__call = function(_, ...)
		return Set.create(...)
	end,
})

ikkuna.Set = Set
