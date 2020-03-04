local Stream = class('StyleStream')

function Stream:initialize()
	self.path = ''

	self.data = ''
	self.size = 0

	self.position = 1
	self.line = 0
	self.column = 0
end

function Stream:loadFile(path)
	self:reset()

	local handle = io.open(path, 'r')
	if not handle then
		return false
	end

	self.data = handle:read('*all')
	self.size = #self.data

	handle:close()
	return true
end

function Stream:loadBuffer(buffer)
	self:reset()

	if type(buffer) ~= 'string' then
		return false
	end

	self.data = buffer
	self.size = #buffer

	return true
end

function Stream:reset()
	self.position = 1
	self.line = 0
	self.column = 0
end

function Stream:next()
	local char = self.data:sub(self.position, self.position)
	if char == '\n' then
		self.line = self.line + 1
		self.column = 0
	else
		self.column = self.column + 1
	end

	self.position = self.position + 1
	return char
end

function Stream:peek(offset)
	local offset = offset or 0
	if self.position + offset >= self.size then
		return ''
	end

	local position = self.position + offset
	return self.data:sub(position, position)
end

function Stream:eof()
	return self.position >= self.size
end

function Stream:warning(message)
	-- TODO: Add offending line to the error?
	print(('[Style] Parsing error (Line: %d, Column: %d).'):format(self.line, self.column))
	print(('[Style] %s'):format(message))
end

ikkuna.StyleStream = Stream
