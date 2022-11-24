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

	self.mode = ikkuna.TextInputMode.SingleLine
	self.textFilterFunction = nil

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.TextInput

	self.focusable = true
	self.receivesInput = true
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

function TextInput:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	self:parseArg(args, 'boolean', 'editable', 'editable')
	self:parseArg(args, 'function', 'textFilterFunction', TextInput.setTextFilterFunction)

	if args.mode then
		if args.mode == 'singleline' then
			self:setInputMode(ikkuna.TextInputMode.SingleLine)
		elseif args.mode == 'multiline' then
			self:setInputMode(ikkuna.TextInputMode.MultiLine)
		elseif args.mode == 'number' then
			self:setInputMode(ikkuna.TextInputMode.Number)
		end
	end
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

		if self.cursorVisible and self:isFocused() and self.text then
			local cursorSpace = 2
			local height = self.text:getFont():getHeight()
			local x = x + self.frontBufferWidth + cursorSpace

			love.graphics.setColor(1, 1, 1)
			love.graphics.line(x, y + (self.height / 2 - height / 2), x, y + (self.height / 2 - height / 2) + height)
		end
	else
		local cursorWidth = 3
		self:drawText(x + self.width - self.frontBufferWidth - cursorWidth, y)

		if self.cursorVisible and self:isFocused() and self.text then
			local height = self.text:getFont():getHeight()
			local x = x + self.width - cursorWidth

			love.graphics.setColor(1, 1, 1)
			love.graphics.line(x, y + (self.height / 2 - height / 2), x, y + (self.height / 2 - height / 2) + height)
		end
	end
	love.graphics.setScissor()
end

function TextInput:onTextInput(text)
	if not self.editable then
		return false
	end

	if self.textFilterFunction then
		if self.textFilterFunction(text) then
			self:insertText(text)
			return true
		end

		return false
	end

	local code = string.byte(text)
	if code < 32 or code > 127 then
		return false
	end

	if self.mode == ikkuna.TextInputMode.Number then
		if not table.contains({'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}, text) then
			return false
		end
	end

	self:insertText(text)
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
		local clipboard = love.system.getClipboardText()
		if #clipboard > 0 then
			self:insertText(clipboard)
		end
	elseif key == 'return' then
		if self.mode == ikkuna.TextInputMode.MultiLine then
			self:insertText('\n')
		end
	else
		return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
	end

	return false
end

function TextInput:insertText(text)
	self.buffer = ('%s%s%s'):format(self.buffer:sub(1, self.cursorPosition), text, self.buffer:sub(self.cursorPosition + 1))
	self:setCursorPosition(self.cursorPosition + 1)
	self:updateText()
end

function TextInput:updateText()
	self:setText(self.masked and self:getMaskedText() or self.buffer)

	local text = love.graphics.newText(ikkuna.Resources.getFont(ikkuna.path(self.font, '.ttf', '/'), self.fontSize))
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

	local text = love.graphics.newText(ikkuna.Resources.getFont(ikkuna.path(self.font, '.ttf', '/'), self.fontSize))
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

function TextInput:setBuffer(buffer)
	self.buffer = buffer
	self.cursorPosition = #self.buffer
	self:updateText()
end

function TextInput:setInputMode(mode)
	if self.mode == mode then
		return
	end

	self.mode = mode

	if mode == ikkuna.TextInputMode.SingleLine then
		self:setBuffer(self.buffer:gsub('\n', ''))
	elseif mode == ikkuna.TextInputMode.Number then
		if not tonumber(self.buffer) then
			self:setBuffer('')
		end
	end
end

function TextInput:setTextFilterFunction(fn)
	self.textFilterFunction = fn
end

ikkuna.TextInput = TextInput
