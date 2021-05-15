local Display = ikkuna.class('Display')

function Display:initialize()
	local styles = ikkuna.Styles:new()
	styles:loadFile('src/res/theme.css')

	self.root = ikkuna.Widget:new()

	local width, height = love.graphics.getDimensions()
	self.root:setExplicitSize(width, height)

	local child = ikkuna.Widget:new()
	child.onClick:connect(function() print('onClick()') return true end)
	child.onDoubleClick:connect(function() print('onDoubleClick()') return true end)
	child.onDragStart:connect(function() print('onDragStart()') return true end)
	child.onDragMove:connect(function() print('onDragMove()') return true end)
	child.onDragEnd:connect(function() print('onDragEnd()') return true end)
	child.onResize:connect(function() print('onResize()') end)
	child.onHoverChange:connect(function(widget, hovered) return true end)
	child:setLayout(ikkuna.VerticalLayout({fitParent = true}))
	child:setExplicitSize(140, 300)
	self.root:addChild(child)

	local button = ikkuna.Button:new()
	button:setText('Click')
	button.onClick:connect(function() print('Button:onClick()') return true end)
	button.onDoubleClick:connect(function() print('Button:onDoubleClick()') return true end)
	child:addChild(button)

	local pushButton = ikkuna.PushButton:new()
	pushButton:setText('Click')
	pushButton.onClick:connect(function() print('PushButton:onClick()') return true end)
	pushButton.onDoubleClick:connect(function() print('PushButton:onDoubleClick()') return true end)
	pushButton.onPushChange:connect(function(widget, state) print('PushButton:onPushChange()') return true end)
	pushButton.onPress:connect(function() print('PushButton:onPress()') return true end)
	child:addChild(pushButton)

	local comboBox = ikkuna.ComboBox:new({'Yes', 'Maybe', {'No', {something = 'something'}}})
	comboBox.onValueChange:connect(function(widget, selectedIndex, option) print('ComboBox:onValueChange()', option.label, option.data) return true end)
	child:addChild(comboBox)

	local spinBox = ikkuna.SpinBox:new(0, 50)
	spinBox.onValueChange:connect(function(widget, value) print('SpinBox:onValueChange()', value) return true end)
	child:addChild(spinBox)

	local textInput = ikkuna.TextInput:new()
	textInput.onFocusChange:connect(function(widget, value) print('TextInput:onFocusChange()', value) return true end)
	child:addChild(textInput)

	local maskButton = ikkuna.Button:new()
	maskButton:setText('Mask')
	maskButton.onClick:connect(function() textInput:setMasked(not textInput.masked) return true end)
	child:addChild(maskButton)

	local draggableButton = ikkuna.Button:new()
	draggableButton:setText('Drag Me')
	draggableButton.draggable = true
	child:addChild(draggableButton)

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
					self.focusedWidget.onFocusChange:emit(self.focusedWidget, false)
					self.focusedWidget = nil
				end

				if widget.focusable then
					self.focusedWidget = widget
					self.focusedWidget.onFocusChange:emit(self.focusedWidget, true)
				end
			end
		end
	elseif self.focusedWidget ~= nil then
		self.focusedWidget.onFocusChange:emit(self.focusedWidget, false)
		self.focusedWidget = nil
	end

	return result
end

function Display:onMouseReleased(x, y, button, touch, presses)
	if self.draggingWidget then
		local ret = self.draggingWidget:onMouseReleased(x, y, button, touch, presses)
		self.draggingWidget = nil
		return ret
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
