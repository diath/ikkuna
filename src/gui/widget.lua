local Widget = class('Widget')

function Widget:initialize()
	self.children = {}
	self.x = 0
	self.y = 0

	self.width = 100
	self.height = 100

	self.draggable = true
	self.dragging = false
	self.dragOffset = {x = 0, y = 0}

	self.focusable = true

	self.isTextDirty = false
	self.text = nil
	self.textString = ''
	self.textPosition = {x = 0, y = 0}
	self.textOffset = {x = 0, y = 0}
	self.textAlign = ikkuna.TextAlign.Left
	self.textColor = {r = 1, g = 1, b = 1, a = 1}

	self.onResize = ikkuna.Event()
	self.onClick = ikkuna.Event()
	self.onDoubleClick = ikkuna.Event()
	self.onDragStart = ikkuna.Event()
	self.onDragMove = ikkuna.Event()
	self.onDragEnd = ikkuna.Event()
	self.onMouseMove = ikkuna.Event()
	self.onHoverChange = ikkuna.Event()
	self.onFocusChange = ikkuna.Event()
end

function Widget:update(delta)
	for _, child in pairs(self.children) do
		if child:isVisible() then
			child:update(delta)
		end
	end

	if self.isTextDirty then
		self:calculateTextPosition()
	end
end

function Widget:draw()
	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	for _, child in pairs(self.children) do
		if child:isVisible() then
			child:draw()
		end
	end

	if self.text then
		local color = self.textColor
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.draw(self.text, self.textPosition.x, self.textPosition.y)
	end
end

function Widget:onKeyPressed(key, code, repeated)
	return false
end

function Widget:onKeyReleased(key, code)
	return false
end

function Widget:onMousePressed(x, y, button, touch, presses)
	local child = self:getChildAt(x, y)
	if child then
		return child:onMousePressed(x, y)
	end

	if self.draggable then
		if self.onDragStart:emit(self, x, y) then
			self.dragging = true
			self.dragOffset.x = x - self.x
			self.dragOffset.y = y - self.y
			return true
		end
	end

	if presses == 2 then
		return self.onDoubleClick:emit(self, x, y, button, touch, presses)
	end

	if self.onClick:emit(self, x, y, button, touch, presses) then
		self.pressed = true
		return true
	end

	return false
end

function Widget:onMouseReleased(x, y, button, touch, presses)
	if self.dragging then
		self.dragging = false
		return self.onDragEnd:emit(self, x, y)
	end

	local child = self:getChildAt(x, y)
	if child then
		return child:onMouseReleased(x, y, button, touch, presses)
	end

	if self.pressed then
		self.pressed = false
	end

	return false
end

function Widget:onMouseMoved(x, y, dx, dy, touch)
	if self.dragging then
		local result = self.onDragMove:emit(self, x, y)
		if result then
			self.x = x - self.dragOffset.x
			self.y = y - self.dragOffset.y

			-- TODO: setPosition() & onPositionChanged event instead?
			self.isTextDirty = true
		end

		return result
	end

	return self.onMouseMove:emit(self, x, y, dx, dy, touch)
end

function Widget:setHovered(hovered)
	if self.hovered == hovered then
		return false
	end

	if self.onHoverChange:emit(self, hovered) then
		self.hovered = hovered
		return true
	end

	return false
end

function Widget:setExplicitSize(width, height)
	self.width = width
	self.height = height

	self.onResize:emit(width, height)
end

function Widget:addChild(child)
	table.insert(self.children, child)

	-- TODO: Layout update if present
end

function Widget:isVisible()
	return true
end

function Widget:setText(text)
	if not self.text then
		-- TODO: Shared font resources?
		self.text = love.graphics.newText(ikkuna.font)
	end

	self.text:set(text)
	self.textString = text
	self.isTextDirty = true
end

function Widget:getText()
	return self.textString
end

function Widget:calculateTextPosition()
	if not self.text then
		return
	end

	local width = self.text:getWidth()
	local height = self.text:getHeight()

	if self.textAlign == ikkuna.TextAlign.Left then
		self.textPosition.x = math.floor(self.x + self.textOffset.x)
	elseif self.textAlign == ikkuna.TextAlign.Right then
		self.textPosition.x = math.floor((self.x + self.width) - width + self.textOffset.x)
	elseif self.textAlign == ikkuna.TextAlign.Center then
		self.textPosition.x = math.floor((self.x + self.width) / 2 - (width / 2) + self.textOffset.x)
	end
	self.textPosition.y = math.floor(self.y + self.textOffset.y)

	self.isTextDirty = false
end

function Widget:contains(x, y)
	return x >= self.x and x <= self.x + self.width and
	       y >= self.y and y <= self.y + self.height
end

function Widget:getChildAt(x, y)
	for _, child in pairs(self.children) do
		if child:isVisible() and child:contains(x, y) then
			return child
		end
	end

	return nil
end

ikkuna.Widget = Widget
