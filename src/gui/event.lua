local Event = class('Event')

function Event:initialize()
	self.callbacks = {}
	self.lastCallbackId = 1
end

function Event:connect(fn)
	self.lastCallbackId = self.lastCallbackId + 1

	table.insert(self.callbacks, {
		id = self.lastCallbackId,
		fn = fn,
	})

	return self.lastCallbackId
end

function Event:disconnect(fn)
	local position = nil
	if type(fn) == 'number' then
		for index, callback in pairs(self.callbacks) do
			if callback.id == fn then
				position = index
				break
			end
		end
	elseif type(fn) == 'function' then
		for index, callback in pairs(self.callbacks) do
			if callback.fn == fn then
				position = index
			end
		end
	end

	if position then
		table.remove(self.callbacks, position)
	end
end

function Event:emit(...)
	local result = true
	for _, callback in pairs(self.callbacks) do
		if not callback.fn(...) then
			result = false
		end
	end

	return result
end

ikkuna.Event = Event
