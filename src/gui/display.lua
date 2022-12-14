local Display = ikkuna.class('Display')

function Display:initialize()
	self.root = ikkuna.Widget:new({
		id = 'root',
		style = 'Root',
		layout = 'anchor',
		phantom = true,
	})

	ikkuna.root = self.root
	ikkuna.display = self

	local width, height = love.graphics.getDimensions()
	self.root:setExplicitSize(width, height)

	self.style = ikkuna.Style:new()
	self.style:load(require(ikkuna.path('src.styles.default')))

	-- TODO: Figure out a way to make Style globally accessible to all widgets per Display instance.
	ikkuna.Widget.Style = self.style

	self.tooltip = nil
	self.baseTooltip = ikkuna.Widget:new({
		style = 'Tooltip',
		visible = false,
		phantom = true,
		resizeToText = true,
		text = {
			align = {
				horizontal = 'center',
				vertical = 'center',
			},
		},
	})

	self.root:addChild(self.baseTooltip)

	self.keybinds = {}

	self.draggingWidget = nil
	self.focusedWidget = nil
	self.activeWindow = nil
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

function Display:addKeybind(keys, callback)
	self.keybinds[keys] = callback
end

function Display:onResize(width, height)
	ikkuna.Width = width
	ikkuna.Height = height

	self.root:setExplicitSize(width, height)
end

function Display:onTextInput(text)
	if self.focusedWidget then
		return self.focusedWidget:onTextInput(text)
	end

	return false
end

function Display:onKeyPressed(key, code, repeated)
	if self.focusedWidget and self.focusedWidget.receivesInput then
		return self.root:onKeyPressed(key, code, repeated)
	end

	if self.activeWindow and self.activeWindow:isVisible() then
		if key == 'return' then
			if self.activeWindow.onEnter:emit() then
				return true
			end
		elseif key == 'escape' then
			if self.activeWindow.onEscape:emit() then
				return true
			end
		end
	end

	local name = ''
	if ikkuna.isControlPressed() then
		name = 'ctrl-'
	end
	if ikkuna.isShiftPressed() then
		name = ('%sshift-'):format(name)
	end
	if ikkuna.isAltPressed() then
		name = ('%salt-'):format(name)
	end
	name = ('%s%s'):format(name, key)

	if self.keybinds[name] then
		return self.keybinds[name]()
	end

	return self.root:onKeyPressed(key, code, repeated)
end

function Display:onKeyReleased(key, code)
	return self.root:onKeyReleased(key, code)
end

function Display:onMousePressed(x, y, button, touch, presses)
	if ikkuna.contextMenu and not ikkuna.contextMenu:contains(x, y) then
		ikkuna.contextMenu:hide()
		ikkuna.contextMenu = nil
	end

	local result = self.root:onMousePressed(x, y, button, touch, presses)
	if result then
		local widget = self.root:getChildAt(x, y, true)
		if widget and not widget:isDisabled() then
			if widget.dragging then
				self.draggingWidget = widget
			end

			self.pressedWidget = widget

			widget:focus(ikkuna.FocusReason.Mouse)
		end
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

function Display:getTooltipPosition(widget, x, y)
	local tx = x + (ikkuna.TooltipOffset.x * 2)
	if tx + widget.width > ikkuna.Width then
		tx = ikkuna.Width - widget.width - ikkuna.TooltipOffset.x
	end

	local ty = y + (ikkuna.TooltipOffset.y * 2)
	if ty + widget.height > ikkuna.Height then
		ty = ikkuna.Height - widget.height - ikkuna.TooltipOffset.y
	end

	return tx, ty
end

function Display:onMouseMoved(x, y, dx, dy, touch)
	if self.draggingWidget then
		return self.draggingWidget:onMouseMoved(x, y, dx, dy, touch)
	end

	if self.baseTooltip:isVisible() then
		local tx, ty = self:getTooltipPosition(self.baseTooltip, x, y)
		self.baseTooltip:setPosition(tx, ty)
	end

	if self.tooltip and self.tooltip:isVisible() then
		local tx, ty = self:getTooltipPosition(self.tooltip, x, y)
		self.tooltip:setPosition(tx, ty)
	end

	local widget = self.root:getChildAt(x, y)
	if self.hoveredWidget and (not widget or widget ~= self.hoveredWidget) then
		if self.baseTooltip:isVisible() then
			self.baseTooltip:hide()
		end

		if self.tooltip and self.tooltip:isVisible() then
			self.tooltip:hide()
			self.root:removeChild(self.tooltip)
			self.tooltip = nil
		end

		self.hoveredWidget:setHovered(false)
		self.hoveredWidget = nil
	end

	if widget then
		if widget:onMouseMoved(x, y, dx, dy, touch) then
			local result = widget:setHovered(true)
			if result then
				if widget.tooltip then
					if type(widget.tooltip) == 'string' or type(widget.tooltip) == 'function' then
						local text = widget.tooltip
						if type(widget.tooltip) == 'function' then
							text = widget.tooltip()
						end

						self.baseTooltip:setText(text)

						local tx, ty = self:getTooltipPosition(self.baseTooltip, x, y)
						self.baseTooltip:setPosition(tx, ty)

						self.baseTooltip:show()
						self.baseTooltip.parent:moveChildToBack(self.baseTooltip)
					else
						-- TODO: Handle non-userdata warning?
						self.tooltip = widget.tooltip

						local tx, ty = self:getTooltipPosition(self.tooltip, x, y)
						self.tooltip:setPosition(tx, ty)

						self.tooltip:show()
						self.root:addChild(widget.tooltip)
					end
				end

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
