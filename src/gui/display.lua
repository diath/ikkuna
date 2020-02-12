local Display = class('Display')

function Display:initialize()
	self.root = ikkuna.Widget:new()

	local width, height = love.graphics.getDimensions()
	self.root:setExplicitSize(width, height)

	local child = ikkuna.Widget:new()
	child:setExplicitSize(100, 100)
	child.onClick:connect(function() print('onClick()') return true end)
	child.onDoubleClick:connect(function() print('onDoubleClick()') return true end)
	child.onDragStart:connect(function() print('onDragStart()') return true end)
	child.onDragMove:connect(function() print('onDragMove()') return true end)
	child.onDragEnd:connect(function() print('onDragEnd()') return true end)
	child.onResize:connect(function() print('onResize()') end)

	self.root:addChild(child)

	self.draggingWidget = nil
end

function Display:update(delta)
	self.root:update(delta)
end

function Display:draw()
	self.root:draw()
end

function Display:onResize(width, height)
	self.root:setExplicitSize(width, height)
end

function Display:onKeyPressed(key, code, repeated)
	return self.root:onKeyPressed(key, code, repeated)
end

function Display:onKeyReleased(key, code)
	return self.root:onKeyReleased(key, code, repeated)
end

function Display:onMousePressed(x, y, button, touch, presses)
	local widget = self.root:getChildAt(x, y)
	if widget then
		local result = widget:onMousePressed(x, y, button, touch, presses)
		if result and widget.dragging then
			self.draggingWidget = widget
		end

		return result
	end

	return false
end

function Display:onMouseReleased(x, y, button, touch, presses)
	if self.draggingWidget then
		return self.draggingWidget:onMouseReleased(x, y, button, touch, presses)
	end

	local widget = self.root:getChildAt(x, y)
	if widget then
		return widget:onMouseReleased(x, y, button, touch, presses)
	end

	return false
end

function Display:onMouseMoved(x, y, dx, dy, touch)
	if self.draggingWidget then
		return self.draggingWidget:onMouseMoved(x, y, dx, dy, touch)
	end

	local widget = self.root:getChildAt(x, y)
	if widget then
		return widget:onMouseMoved(x, y, dx, dy, touch)
	end

	return false
end

ikkuna.Display = Display
