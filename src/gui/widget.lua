local Widget = ikkuna.class('Widget')
Widget.LastId = 0
Widget.PressInterval = 0.25

function Widget:initialize()
	Widget.LastId = Widget.LastId + 1
	self.id = ('Widget%d'):format(Widget.LastId)

	self.parent = nil
	self.children = {}
	self.x = 0
	self.y = 0

	self.width = 100
	self.height = 100

	self.padding = ikkuna.Rect({raw = true, all = 5})
	self.margin = ikkuna.Rect({raw = true, all = 0})

	self.pressed = false
	self.pressTimer = ikkuna.Timer()

	self.draggable = true
	self.dragging = false
	self.dragOffset = {x = 0, y = 0}

	self.focusable = false

	self.isTextDirty = false
	self.text = nil
	self.textString = ''
	self.textPosition = {x = 0, y = 0}
	self.textOffset = {x = 0, y = 0}
	self.textAlign = {horizontal = ikkuna.TextAlign.Horizontal.Left, vertical = ikkuna.TextAlign.Vertical.Top}
	self.textColor = {r = 1, g = 1, b = 1, a = 1}

	self.onResize = ikkuna.Event()
	self.onClick = ikkuna.Event()
	self.onPress = ikkuna.Event()
	self.onDoubleClick = ikkuna.Event()
	self.onMouseWheel = ikkuna.Event()
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

	if self.pressed and self.pressTimer:elapsed() >= Widget.PressInterval then
		self.onPress:emit(self)
		self.pressTimer:reset()
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

function Widget:onTextInput(text)
	return false
end

function Widget:onKeyPressed(key, code, repeated)
	return false
end

function Widget:onKeyReleased(key, code)
	return false
end

function Widget:setPosition(x, y)
	self.x = x
	self.y = y
end

function Widget:setDragOffset(x, y)
	self.dragOffset.x = x - self.x
	self.dragOffset.y = y - self.y

	for _, child in pairs(self.children) do
		child:setDragOffset(x, y)
	end
end

function Widget:drag(x, y)
	if self:hasParent() then
		self.x = math.clamp(self.parent.x, x - self.dragOffset.x, self.parent.x + self.parent.width - self.width)
		self.y = math.clamp(self.parent.y, y - self.dragOffset.y, self.parent.y + self.parent.height - self.height)
	else
		self.x = x - self.dragOffset.x
		self.y = y - self.dragOffset.y
	end

	self.isTextDirty = true

	for _, child in pairs(self.children) do
		child:drag(x, y)
	end
end

function Widget:onMousePressed(x, y, button, touch, presses)
	local child = self:getChildAt(x, y)
	if child then
		return child:onMousePressed(x, y, button, touch, presses)
	end

	if button == ikkuna.Mouse.Button.Primary then
		if self.draggable then
			if self.onDragStart:emit(self, x, y) then
				self.dragging = true

				self:setDragOffset(x, y)
				return true
			end
		end

		if self.onClick:emit(self, x, y, button, touch, presses) then
			self.pressed = true
			self.pressTimer:reset()
			return presses % 2 == 0 and self.onDoubleClick:emit(self, x, y, button, touch, presses) or true
		end
	end

	return false
end

function Widget:onMouseReleased(x, y, button, touch, presses)
	if button == ikkuna.Mouse.Button.Primary and self.dragging then
		self.dragging = false
		return self.onDragEnd:emit(self, x, y)
	end

	local child = self:getChildAt(x, y)
	if child then
		return child:onMouseReleased(x, y, button, touch, presses)
	end

	if button == ikkuna.Mouse.Button.Primary and self.pressed then
		self.pressed = false
	end

	return false
end

function Widget:onMouseMoved(x, y, dx, dy, touch)
	if self.dragging then
		local result = self.onDragMove:emit(self, x, y)
		if result then
			-- TODO: setPosition() & onPositionChanged event instead?
			self:drag(x, y)
		end

		return result
	end

	return self.onMouseMove:emit(self, x, y, dx, dy, touch)
end

function Widget:onWheelMoved(dx, dy)
	return self.onMouseWheel:emit(dx, dy)
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

	-- TODO: Emit child geometry update on the parent to update the layout
end

function Widget:addChild(child)
	-- TODO: Use a set?
	if not table.contains(self.children, child) then
		child.parent = self
		table.insert(self.children, child)
	else
		print(('Widget %s already contains child widget %s'):format(self.id, child.id))
	end

	if self.layout then
		self.layout:update()
	end
end

function Widget:setLayout(layout)
	self.layout = layout
	if self.layout then
		self.layout:setParent(self)
		self.layout:update()
	end
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

	if self.textAlign.horizontal == ikkuna.TextAlign.Horizontal.Left then
		self.textPosition.x = math.floor(self.x + self.textOffset.x)
	elseif self.textAlign.horizontal == ikkuna.TextAlign.Horizontal.Right then
		self.textPosition.x = math.floor(self.x + self.width - width + self.textOffset.x)
	elseif self.textAlign.horizontal == ikkuna.TextAlign.Horizontal.Center then
		self.textPosition.x = math.floor(self.x + self.width / 2 - width / 2 + self.textOffset.x)
	end

	if self.textAlign.vertical == ikkuna.TextAlign.Vertical.Top then
		self.textPosition.y = math.floor(self.y + self.textOffset.y)
	elseif self.textAlign.vertical == ikkuna.TextAlign.Vertical.Bottom then
		self.textPosition.y = math.floor(self.y + self.height - height + self.textOffset.y)
	elseif self.textAlign.vertical == ikkuna.TextAlign.Vertical.Center then
		self.textPosition.y = math.floor(self.y + self.height / 2 - height / 2 + self.textOffset.y)
	end

	self.isTextDirty = false
end

function Widget:contains(x, y)
	return x >= self.x and x <= self.x + self.width and
	       y >= self.y and y <= self.y + self.height
end

function Widget:getChildAt(x, y)
	for _, child in pairs(self.children) do
		if child:isVisible() and child:contains(x, y) then
			return child:getChildAt(x, y) or child
		end
	end

	return nil
end

function Widget:hasParent()
	return self.parent ~= nil
end

function Widget:getParent()
	return self.parent
end

function Widget:getTopParent()
	local parent = self:getParent()
	if not parent then
		return nil
	end

	while parent:hasParent() do
		parent = parent:getParent()
	end

	return parent
end

ikkuna.Widget = Widget
