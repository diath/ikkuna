local Display = ikkuna.class('Display')

function Display:initialize()
	self.root = ikkuna.Widget:new()
	ikkuna.root = self.root

	local width, height = love.graphics.getDimensions()
	self.root:setExplicitSize(width, height)

	self.draggingWidget = nil
	self.focusedWidget = nil
	self.hoveredWidget = nil
	self.pressedWidget = nil
end

function Display:update(delta)
	self.root:update(delta)
end

function Display:draw()
	love.graphics.setColor(1, 1, 1, 1)
	self.root:draw()
end

function Display:onResize(width, height)
	self.root:setExplicitSize(width, height)
end

function Display:onTextInput(text)
	return self.focusedWidget and self.focusedWidget:onTextInput(text) or false
end

function Display:onKeyPressed(key, code, repeated)
	if self.focusedWidget then
		return self.focusedWidget:onKeyPressed(key, code, repeated)
	end

	return self.root:onKeyPressed(key, code, repeated)
end

function Display:onKeyReleased(key, code)
	return self.root:onKeyReleased(key, code, repeated)
end

function Display:onMousePressed(x, y, button, touch, presses)
	if ikkuna.contextMenu and not ikkuna.contextMenu:contains(x, y) then
		ikkuna.contextMenu:hide()
		ikkuna.contextMenu = nil
	end

	local result = self.root:onMousePressed(x, y, button, touch, presses)
	if result then
		local widget = self.root:getChildAt(x, y, true)
		if widget then
			if widget.dragging then
				self.draggingWidget = widget
			end

			self.pressedWidget = widget

			if widget ~= self.focusedWidget then
				if self.focusedWidget then
					self.focusedWidget.focused = false
					self.focusedWidget.onFocusChange:emit(self.focusedWidget, false)
					self.focusedWidget = nil
				end

				if widget.focusable then
					self.focusedWidget = widget
					self.focusedWidget.focused = true
					self.focusedWidget.onFocusChange:emit(self.focusedWidget, true)
				end
			end
		end
	elseif self.focusedWidget ~= nil then
		self.focusedWidget.onFocusChange:emit(self.focusedWidget, false)
		self.focusedWidget.focused = false
		self.focusedWidget = nil
	end

	return result
end

function Display:onMouseReleased(x, y, button, touch, presses)
	if self.draggingWidget then
		self.draggingWidget:onMouseReleased(x, y, button, touch, presses)
		self.draggingWidget = nil

		return true
	end

	local widget = self.root:getChildAt(x, y)
	if widget then
		return widget:onMouseReleased(x, y, button, touch, presses)
	end

	if self.pressedWidget then
		local ret = self.pressedWidget:onMouseReleased(x, y, button, touch, presses)
		self.pressedWidget = nil
		return ret
	end

	return false
end

function Display:onMouseMoved(x, y, dx, dy, touch)
	if self.draggingWidget then
		return self.draggingWidget:onMouseMoved(x, y, dx, dy, touch)
	end

	local widget = self.root:getChildAt(x, y)
	if self.hoveredWidget and (not widget or widget ~= self.hoveredWidget) then
		self.hoveredWidget:setHovered(false)
		self.hoveredWidget = nil
	end

	if widget then
		if widget:onMouseMoved(x, y, dx, dy, touch) then
			local result = widget:setHovered(true)
			if result then
				self.hoveredWidget = widget
			end

			return result
		end
	end

	return false
end

function Display:onWheelMoved(dx, dy)
	if self.hoveredWidget then
		return self.hoveredWidget:onWheelMoved(dx, dy)
	end

	return false
end

ikkuna.Display = Display
