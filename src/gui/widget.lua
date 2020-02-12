local Widget = class('Widget')

function Widget:initialize()
	self.children = {}
	self.x = 0
	self.y = 0

	self.width = 100
	self.height = 100

	self.draggable = true
	self.dragging = false
	self.dragOffset = {}
	self.dragOffset.x = 0
	self.dragOffset.y = 0

	self.onResize = ikkuna.Event()
	self.onClick = ikkuna.Event()
	self.onDoubleClick = ikkuna.Event()
	self.onDragStart = ikkuna.Event()
	self.onDragMove = ikkuna.Event()
	self.onDragEnd = ikkuna.Event()
	self.onMouseMove = ikkuna.Event()
end

function Widget:update(delta)
	for _, child in pairs(self.children) do
		if child:isVisible() then
			child:update(delta)
		end
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

	return self.onClick:emit(self, x, y, button, touch, presses)
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

	return false
end

function Widget:onMouseMoved(x, y, dx, dy, touch)
	if self.dragging then
		local result = self.onDragMove:emit(self, x, y)
		if result then
			self.x = x - self.dragOffset.x
			self.y = y - self.dragOffset.y
		end

		return result
	end

	return self.onMouseMove:emit(self, x, y, dx, dy, touch)
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
