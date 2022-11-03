local TextInput = ikkuna.class('TextInput', ikkuna.Widget)

function TextInput:initialize(args)
	self.editable = true
	self.buffer = ''

	self.cursorPosition = 0
	self.cursorTimer = ikkuna.Timer()
	self.cursorVisible = false

	self.masked = false
	self.maskCharacter = '*'

	self.frontBufferWidth = 0

	self.preferredSize = {width = 100, height = 30}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.TextInput

	self.focusable = true
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

function TextInput:update(delta)
	ikkuna.Widget.update(self, delta)

	if self.cursorTimer:elapsed() > 0.35 then
		self.cursorVisible = not self.cursorVisible
		self.cursorTimer:reset()
	end
end

function TextInput:drawAt(x, y)
	self:drawBase(x, y)

	love.graphics.setScissor(x, y, self.width, self.height)
	if self.frontBufferWidth < self.width then
		self:drawText(x, y)

		if self.cursorVisible and self:isFocused() then
			local cursorSpace = 2
			local height = ikkuna.fontHeight
			local x = x + self.frontBufferWidth + cursorSpace

			love.graphics.setColor(1, 1, 1)
			love.graphics.line(x, y + (self.height / 2 - height / 2), x, y + (self.height / 2 - height / 2) + height)
		end
	else
		local cursorWidth = 3
		self:drawText(x + self.width - self.frontBufferWidth - cursorWidth, y)

		if self.cursorVisible and self:isFocused() then
			local height = ikkuna.fontHeight
			local x = x + self.width - cursorWidth

			love.graphics.setColor(1, 1, 1)
			love.graphics.line(x, y + (self.height / 2 - height / 2), x, y + (self.height / 2 - height / 2) + height)
		end
	end
	love.graphics.setScissor()
end

function TextInput:onMousePressed(x, y, button, touch, presses)
	return true
end

function TextInput:onTextInput(text)
	if not self.editable then
		return false
	end

	local code = string.byte(text)
	if code < 32 or code > 127 then
		return false
	end

	self.buffer = ('%s%s%s'):format(self.buffer:sub(1, self.cursorPosition), text, self.buffer:sub(self.cursorPosition + 1))
	self:setCursorPosition(self.cursorPosition + 1)

	self:updateText()

	return true
end

function TextInput:onKeyPressed(key, code, repeated)
	if not self.editable then
		ikkuna.Widget.onKeyPressed(self, key, code, repeated)
		return false
	end

	if key == 'backspace' then
		if #self.buffer > 0 and self.cursorPosition > 0 then
			self.buffer = ('%s%s'):format(self:getFrontBuffer():sub(1, -2), self:getBackBuffer())
			self:setCursorPosition(math.max(0, self.cursorPosition - 1))
			self:updateText()
		end
	elseif key == 'delete' then
		if #self.buffer > 0 then
			self.buffer = ('%s%s'):format(self:getFrontBuffer(), self:getBackBuffer():sub(2))
			self:setCursorPosition(self.cursorPosition)
			self:updateText()
		end
	elseif key == 'left' then
		self:setCursorPosition(math.max(0, self.cursorPosition - 1))
	elseif key == 'right' then
		self:setCursorPosition(math.min(#self.buffer, self.cursorPosition + 1))
	elseif key == 'home' then
		self:setCursorPosition(0)
	elseif key == 'end' then
		self:setCursorPosition(#self.buffer)
	elseif (key == 'v' and ikkuna.isControlPressed()) or (key == 'insert' and ikkuna.isShiftPressed()) then
		local clipboard = love.system.getClipboardText():gsub('\n', '')
		if #clipboard > 0 then
			self.buffer = ('%s%s%s'):format(self:getFrontBuffer(), clipboard, self:getBackBuffer())
			self:setCursorPosition(self.cursorPosition + #clipboard)
			self:updateText()
		end
	else
		ikkuna.Widget.onKeyPressed(self, key, code, repeated)
	end

	return true
end

function TextInput:updateText()
	self:setText(self.masked and self:getMaskedText() or self.buffer)

	local text = love.graphics.newText(ikkuna.font)
	text:set(self.masked and self:getMaskedFrontBuffer() or self:getFrontBuffer())
	self.frontBufferWidth = text:getWidth()
end

function TextInput:getMaskedText()
	return self.buffer:gsub('.', self.maskCharacter)
end

function TextInput:getMaskedFrontBuffer()
	return self:getMaskedText():sub(1, self.cursorPosition)
end

function TextInput:getFrontBuffer()
	-- Returns a copy of the buffer in front of the cursor.
	return self.buffer:sub(1, self.cursorPosition)
end

function TextInput:getBackBuffer()
	-- Returns a copy of the buffer after the cursor.
	return self.buffer:sub(self.cursorPosition + 1)
end

function TextInput:setCursorPosition(position)
	self.cursorPosition = position
	self.cursorVisible = true
	self.cursorTimer:reset()

	local text = love.graphics.newText(ikkuna.font)
	text:set(self:getFrontBuffer())
	self.frontBufferWidth = text:getWidth()
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
