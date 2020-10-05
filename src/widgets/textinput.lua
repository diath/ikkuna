local TextInput = class('TextInput', ikkuna.Widget)

function TextInput:initialize(options)
	ikkuna.Widget.initialize(self)

	self.focusable = true

	self.editable = true
	self.buffer = ''

	self.cursorPosition = 0
	self.cursorTime = 0
	self.cursorVisible = false

	self.masked = false
	self.maskCharacter = '*'
end

function TextInput:update(delta)
	ikkuna.Widget.update(self, delta)

	self.cursorTime = self.cursorTime + delta
	if self.cursorTime > 0.35 then
		self.cursorVisible = not self.cursorVisible
		self.cursorTime = 0
	end
end

function TextInput:draw()
	ikkuna.Widget.draw(self)

	if self.cursorVisible then
		local width = 0
		if #self.buffer > 0 and self.cursorPosition > 0 then
			width = ikkuna.font:getWidth(self.buffer:sub(1, self.cursorPosition))
		end

		local height = ikkuna.font:getHeight()

		love.graphics.setColor(1, 1, 1)
		love.graphics.line(self.x + width, self.y, self.x + width, self.y + height)
	end
end

function TextInput:onMousePressed(x, y, button, touch, presses)
	return true
end

function TextInput:onTextInput(text)
	if not self.editable then
		return true
	end

	local code = string.byte(text)
	if code < 32 or code > 127 then
		return false
	end

	self.buffer = ('%s%s%s'):format(self.buffer:sub(1, self.cursorPosition ), text, self.buffer:sub(self.cursorPosition + 1))
	self.cursorPosition = self.cursorPosition + 1

	self:updateText()

	return true
end

function TextInput:onKeyPressed(key, code, repeated)
	if not self.editable then
		return true
	end

	if key == 'backspace' then
		if #self.buffer > 0 then
			self.buffer = ('%s%s'):format(self.buffer:sub(1, self.cursorPosition - 1), self.buffer:sub(self.cursorPosition + 1))
			self.cursorPosition = math.max(0, self.cursorPosition - 1)
			self:updateText()
		end
	elseif key == 'delete' then
		if #self.buffer > 0 then
			self.buffer = ('%s%s'):format(self.buffer:sub(1, self.cursorPosition), self.buffer:sub(self.cursorPosition + 2))
			self:updateText()
		end
	elseif key == 'left' then
		self.cursorPosition = math.max(0, self.cursorPosition - 1)
		self.cursorVisible = true
		self.cursorTime = 0
	elseif key == 'right' then
		self.cursorPosition = math.min(#self.buffer, self.cursorPosition + 1)
		self.cursorVisible = true
		self.cursorTime = 0
	elseif key == 'home' then
		self.cursorPosition = 0
		self.cursorVisible = true
		self.cursorTime = 0
	elseif key == 'end' then
		self.cursorPosition = #self.buffer
		self.cursorVisible = true
		self.cursorTime = 0
	elseif key == 'v' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
		self.buffer = ('%s%s%s'):format(self.buffer:sub(1, self.cursorPosition ), love.system.getClipboardText():gsub('\n', ''), self.buffer:sub(self.cursorPosition + 1))
		self:updateText()
	end

	return true
end

function TextInput:updateText()
	if self.masked then
		local mask = ''
		for i = 1, #self.buffer do
			mask = ('%s%s'):format(mask, self.maskCharacter)
		end

		self:setText(mask)
	else
		self:setText(self.buffer)
	end
end

function TextInput:setMasked(masked)
	self.masked = masked
	self:updateText()
end

function TextInput:setMaskCharacter(maskCharacter)
	self.maskCharacter = maskCharacter
	self:updateText()
end

ikkuna.TextInput = TextInput
