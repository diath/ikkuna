local Widget = ikkuna.class('Widget')
Widget.LastId = 0
Widget.PressInterval = 0.25

function Widget:initialize(args)
	Widget.LastId = Widget.LastId + 1
	self.id = ('Widget%d'):format(Widget.LastId)
	self.type = ikkuna.WidgetType.Widget

	self.parent = nil
	self.children = {}

	-- NOTE: We use a set in addition to children array for O(1) lookup to check if a widget is already a known child.
	self.knownChildren = ikkuna.Set()

	self.x = 0
	self.y = 0

	self.width = 100
	self.height = 100

	self.visible = true
	self.phantom = false
	self.hovered = false
	self.disabled = false

	self.style = nil

	self.padding = ikkuna.Rect({raw = true, all = 5})
	self.margin = ikkuna.Rect({raw = true, all = 0})

	self.pressed = false
	self.pressTimer = ikkuna.Timer()

	self.draggable = false
	self.dragging = false
	self.dragOffset = {x = 0, y = 0}

	self.focused = false
	self.focusable = false
	self.receivesInput = false

	self.tooltip = nil

	self.isTextDirty = false
	self.text = nil
	self.textString = ''
	self.relativeTextPosition = {x = 0, y = 0}
	self.textOffset = {x = 0, y = 0}
	self.textAlign = {horizontal = ikkuna.TextAlign.Horizontal.Left, vertical = ikkuna.TextAlign.Vertical.Top}
	self.textColor = {r = 1, g = 1, b = 1, a = 1}
	self.resizeToText = false

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

	if args then
		self:parseArgs(args)
	else
		if self.preferredSize then
			self:setExplicitSize(self.preferredSize.width, self.preferredSize.height)
		end
	end
end

function Widget:parseArg(args, typeName, name, field)
	if args[name] == nil then
		return
	end

	if type(args[name]) == typeName then
		if type(field) == 'function' then
			field(self, args[name])
		else
			self[field] = args[name]
		end
		return
	end

	print(('Widget::parseArg: %s expected argument "%s" to be of type "%s", got "%s" (%s).'):format(
		ikkuna.WidgetName[self.type], name, typeName, type(name), args[name]
	))
end

function Widget:parseArgs(args)
	if type(args) ~= 'table' then
		return
	end

	-- ID
	self:parseArg(args, 'string', 'id', 'id')

	-- Size
	if args.size then
		if type(args.size) == 'number' then
			self:setExplicitSize(args.size, args.size)
		elseif type(args.size) == 'table' then
			self:setExplicitSize(args.size.width, args.size.height)
		end
	elseif self.preferredSize then
		self:setExplicitSize(self.preferredSize.width, self.preferredSize.height)
	end

	-- Position
	if args.position then
		if type(args.position) == 'number' then
			self:setPosition(args.position, args.position)
		elseif type(args.position) == 'table' then
			self:setPosition(args.position.x, args.position.y)
		end
	end

	-- Layout
	if args.layout then
		if type(args.layout) == 'table' then
			local layout = args.layout
			if layout.type == 'horizontal' then
				self:setLayout(ikkuna.HorizontalLayout:new(layout.args))
			elseif layout.type == 'vertical' then
				self:setLayout(ikkuna.VerticalLayout:new(layout.args))
			end
		elseif type(args.layout) == 'string' then
			if args.layout == 'horizontal' then
				self:setLayout(ikkuna.HorizontalLayout:new())
			elseif args.layout == 'vertical' then
				self:setLayout(ikkuna.VerticalLayout:new())
			end
		end
	end

	-- State
	self:parseArg(args, 'boolean', 'draggable', 'draggable')
	self:parseArg(args, 'boolean', 'focusable', 'focusable')
	self:parseArg(args, 'boolean', 'visible', 'visible')
	self:parseArg(args, 'boolean', 'phantom', 'phantom')
	self:parseArg(args, 'boolean', 'disabled', 'disabled')

	-- Padding and margin
	if args.padding then
		if type(args.padding) == 'number' then
			self.padding = ikkuna.Rect({all = args.padding, raw = true})
		end
	end

	if args.margin then
		if type(args.margin) == 'number' then
			self.margin = ikkuna.Rect({all = args.margin, raw = true})
		end
	end

	-- Events
	if args.events then
		local function parseEvents(event, field)
			if not field then
				return
			end

			if type(field) == 'function' then
				event:connect(field)
			elseif type(field) == 'table' then
				for _, func in pairs(field) do
					event:connect(func)
				end
			end
		end

		parseEvents(self.onResize, args.events.onResize)
		parseEvents(self.onClick, args.events.onClick)
		parseEvents(self.onPress, args.events.onPress)
		parseEvents(self.onDoubleClick, args.events.onDoubleClick)
		parseEvents(self.onMouseWheel, args.events.onMouseWheel)
		parseEvents(self.onDragStart, args.events.onDragStart)
		parseEvents(self.onDragMove, args.events.onDragMove)
		parseEvents(self.onDragEnd, args.events.onDragEnd)
		parseEvents(self.onMouseMove, args.events.onMouseMove)
		parseEvents(self.onHoverChange, args.events.onHoverChange)
		parseEvents(self.onFocusChange, args.events.onFocusChange)
	end

	-- Text
	if args.text then
		if type(args.text) == 'string' then
			self:setText(args.text)
		elseif type(args.text) == 'table' then
			local text = args.text
			if text.label then
				self:setText(text.label)
			end

			if text.offset then
				self:setTextOffset(text.offset.x, text.offset.y)
			end

			if text.align then
				if type(text.align.horizontal) == 'number' then
					self:setTextAlign({horizontal = text.align.horizontal})
				elseif type(text.align.horizontal) == 'string' then
					if text.align.horizontal == 'left' then
						self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Left})
					elseif text.align.horizontal == 'center' then
						self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center})
					elseif text.align.horizontal == 'right' then
						self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Right})
					end
				end

				if type(text.align.vertical) == 'number' then
					self:setTextAlign({vertical = text.align.vertical})
				elseif type(text.align.vertical) == 'string' then
					if text.align.vertical == 'top' then
						self:setTextAlign({vertical = ikkuna.TextAlign.Vertical.Top})
					elseif text.align.vertical == 'center' then
						self:setTextAlign({vertical = ikkuna.TextAlign.Vertical.Center})
					elseif text.align.vertical == 'bottom' then
						self:setTextAlign({vertical = ikkuna.TextAlign.Vertical.Bottom})
					end
				end
			end

			if text.color then
				self.textColor = ikkuna.parseColor(text.color)
			end
		end
	end

	self:parseArg(args, 'boolean', 'resizeToText', 'resizeToText')

	-- Misc
	self:parseArg(args, 'string', 'tooltip', 'tooltip')
	self:parseArg(args, 'string', 'style', 'style')

	if args.children then
		for _, child in pairs(args.children) do
			local widgetType = nil
			if child.type == 'Widget' then
				widgetType = ikkuna.Widget
			elseif child.type == 'Button' then
				widgetType = ikkuna.Button
			elseif child.type == 'CheckBox' then
				widgetType = ikkuna.CheckBox
			elseif child.type == 'ComboBox' then
				widgetType = ikkuna.ComboBox
			elseif child.type == 'ContextMenu' then
				widgetType = ikkuna.ContextMenu
			elseif child.type == 'Label' then
				widgetType = ikkuna.Label
			elseif child.type == 'ProgressBar' then
				widgetType = ikkuna.ProgressBar
			elseif child.type == 'PushButton' then
				widgetType = ikkuna.PushButton
			elseif child.type == 'RadioBox' then
				widgetType = ikkuna.RadioBox
			elseif child.type == 'Separator' then
				widgetType = ikkuna.Separator
			elseif child.type == 'ScrollArea' then
				widgetType = ikkuna.ScrollArea
			elseif child.type == 'ScrollBar' then
				widgetType = ikkuna.ScrollBar
			elseif child.type == 'SpinBox' then
				widgetType = ikkuna.SpinBox
			elseif child.type == 'TabBar' then
				widgetType = ikkuna.TabBar
			elseif child.type == 'TextInput' then
				widgetType = ikkuna.TextInput
			elseif child.type == 'Window' then
				widgetType = ikkuna.Window
			end

			if widgetType then
				self:addChild(widgetType:new(child.args))
			else
				print(('Widget::parseArgs: Unknown child type: %s'):format(child.type))
			end
		end
	end

	if args.parent then
		args.parent:addChild(self)
	end
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
	self:drawAt(self.x, self.y)
end

function Widget:drawAt(x, y)
	self:drawBase(x, y)

	for _, child in pairs(self.children) do
		if child:isVisible() then
			child:draw()
		end
	end

	self:drawText(x, y)
end

function Widget:drawBase(x, y)
	local style = self:getStyle()
	if style.borderSize then
		love.graphics.setLineWidth(style.borderSize)

		if style.border then
			love.graphics.setColor(style.border.r, style.border.g, style.border.b, style.border.a)
		end
		love.graphics.rectangle('line', x, y, self.width, self.height)
	end

	if style.background then
		love.graphics.setColor(style.background.r, style.background.g, style.background.b, style.background.a)
	end
	love.graphics.rectangle('fill', x, y, self.width, self.height)

	if ikkuna.Debug then
		if self:isFocused() then
			love.graphics.setColor(0, 1, 0, 1)
		else
			love.graphics.setColor(1, 0, 0, 1)
		end

		love.graphics.rectangle('line', x, y, self.width, self.height)
	end

	-- Restore the painter color.
	love.graphics.setColor(1, 1, 1, 1)
end

function Widget:drawText(x, y)
	if self.text then
		local color = self.textColor
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.draw(self.text, math.ceil(x + self.relativeTextPosition.x), math.ceil(y + self.relativeTextPosition.y))
	end
end

function Widget:onTextInput(text)
	return false
end

function Widget:onKeyPressed(key, code, repeated)
	if key == 'tab' then
		if ikkuna.isShiftPressed() then
			self:focusPreviousChild()
		else
			self:focusNextChild()
		end
		return true
	end

	local focusedWidget = ikkuna.display.focusedWidget
	if focusedWidget and focusedWidget ~= self then
		return focusedWidget:onKeyPressed(key, code, repeated)
	end

	return false
end

function Widget:onKeyReleased(key, code)
	local focusedWidget = ikkuna.display.focusedWidget
	if focusedWidget and focusedWidget ~= self then
		return focusedWidget:onKeyReleased(key, code)
	end

	return false
end

function Widget:setPosition(x, y)
	self.x = x
	self.y = y

	self:calculateTextPosition()

	if self.layout then
		self.layout:update()
	end
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

	if button == ikkuna.MouseButton.Primary then
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
	elseif button == ikkuna.MouseButton.Secondary then
		if self.contextMenu then
			self.contextMenu:show(x, y)
		end
	end

	return false
end

function Widget:onMouseReleased(x, y, button, touch, presses)
	if button == ikkuna.MouseButton.Primary and self.dragging then
		self.dragging = false
		return self.onDragEnd:emit(self, x, y)
	end

	local child = self:getChildAt(x, y)
	if child then
		return child:onMouseReleased(x, y, button, touch, presses)
	end

	if button == ikkuna.MouseButton.Primary and self.pressed then
		self.pressed = false
	end

	return false
end

function Widget:onMouseMoved(x, y, dx, dy, touch)
	if self.dragging then
		local result = self.onDragMove:emit(self, x, y, dx, dy)
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

function Widget:getAllFocusableChildren()
	local children = {}
	for _, child in pairs(self.children) do
		if child.focusable and child:isVisible() and not child:isDisabled() then
			table.insert(children, child)
		end

		if #child.children > 0 then
			for _, subChild in pairs(child:getAllFocusableChildren()) do
				if subChild.focusable and child:isVisible() and not child:isDisabled() then
					table.insert(children, subChild)
				end
			end
		end
	end

	return children
end

function Widget:focusPreviousChild()
	local allChildren = self:getAllFocusableChildren()
	if #allChildren == 0 then
		return
	end

	local focusedChildIndex = -1
	for index, child in pairs(allChildren) do
		if child:isFocused() then
			focusedChildIndex = index
			break
		end
	end

	if focusedChildIndex ~= -1 then
		allChildren[focusedChildIndex]:unfocus()
	end

	if focusedChildIndex ~= -1 and focusedChildIndex > 1 then
		allChildren[focusedChildIndex - 1]:focus()
	else
		allChildren[#allChildren]:focus()
	end
end

function Widget:focusNextChild()
	local allChildren = self:getAllFocusableChildren()
	if #allChildren == 0 then
		return
	end

	local focusedChildIndex = -1
	for index, child in pairs(allChildren) do
		if child:isFocused() then
			focusedChildIndex = index
			break
		end
	end

	if focusedChildIndex ~= -1 then
		allChildren[focusedChildIndex]:unfocus()
	end

	if focusedChildIndex ~= -1 and focusedChildIndex < #allChildren then
		allChildren[focusedChildIndex + 1]:focus()
	else
		allChildren[1]:focus()
	end
end

function Widget:unfocus()
	if not self:isFocused() then
		return
	end

	self.focused = false
	self.onFocusChange:emit(self, false)
end

function Widget:focus()
	if not self.focusable then
		return
	end

	if self:isFocused() then
		return
	end

	if ikkuna.Debug then
		print(('Widget::focus: Switching focus to %s::%s.'):format(ikkuna.WidgetName[self.type], self.id))
	end

	if ikkuna.display.focusedWidget then
		ikkuna.display.focusedWidget:unfocus()
		ikkuna.display.focusedWidget = nil
	end

	ikkuna.display.focusedWidget = self
	self.focused = true
	self.onFocusChange:emit(self, true)
end

function Widget:isFocused()
	return self.focused
end

function Widget:isHovered()
	return self.hovered
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
	if not child then
		return false
	end

	if self.knownChildren:contains(child) then
		print(('Widget %s already contains child widget %s'):format(self.id, child.id))
		return false
	end

	child.parent = self

	table.insert(self.children, child)
	self.knownChildren:add(child)

	if self.layout then
		self.layout:update()
	end

	return true
end

function Widget:removeChild(widget)
	if not widget then
		return false
	end

	for index, child in pairs(self.children) do
		if child == widget then
			table.remove(self.children, index)
			self.knownChildren:remove(child)
			return true
		end
	end

	return false
end

function Widget:moveChildToBack(widget)
	local found = true

	for index, child in pairs(self.children) do
		if child == widget then
			table.remove(self.children, index)
			self.knownChildren:remove(child)
			found = true
			break
		end
	end

	if found then
		self:addChild(widget)
	end

	return found
end

function Widget:setLayout(layout)
	self.layout = layout
	if self.layout then
		self.layout:setParent(self)
	end
end

function Widget:isVisible()
	return self.visible
end

function Widget:getVisibleChildren()
	local children = {}
	for _, child in pairs(self.children) do
		if child:isVisible() then
			table.insert(children, child)
		end
	end

	return children
end

function Widget:forEachVisibleChild(fn)
	for _, child in pairs(self.children) do
		if child:isVisible() then
			fn(child)
		end
	end
end

function Widget:show()
	self.visible = true

	if self.parent and self.parent.layout then
		self.parent.layout:update()
	end
end

function Widget:hide()
	self.visible = false

	if self.parent and self.parent.layout then
		self.parent.layout:update()
	end
end

function Widget:isPhantom()
	return self.phantom
end

function Widget:setPhantom(phantom)
	self.phantom = phantom
end

function Widget:isDisabled()
	return self.disabled
end

function Widget:disable()
	self.disabled = true
end

function Widget:enable()
	self.disabled = false
end

function Widget:getStyleState()
	-- NOTE: In order of importance.
	if self:isDisabled() then
		return ikkuna.StyleState.Disabled
	end

	if self:isHovered() then
		return ikkuna.StyleState.Hovered
	end

	if self:isFocused() then
		return ikkuna.StyleState.Focused
	end

	return ikkuna.StyleState.Normal
end

function Widget:getStyle()
	return ikkuna.Widget.Style:getStyle(self.style or ikkuna.WidgetName[self.type], self:getStyleState())
end

function Widget:setText(text)
	if self.textString == text then
		return
	end

	if not self.text then
		-- TODO: Shared font resources?
		self.text = love.graphics.newText(ikkuna.font)
	end

	self.text:set(text)
	self.textString = text
	self.isTextDirty = true

	if self.resizeToText then
		local width, height = self.text:getDimensions()
		self:setExplicitSize(width + self.padding.left + self.padding.right, height + self.padding.top + self.padding.bottom)
	end
end

function Widget:setTextOffset(x, y)
	self.textOffset.x = x
	self.textOffset.y = y

	self.isTextDirty = true
end

function Widget:setTextAlign(align)
	if align.horizontal then
		self.textAlign.horizontal = align.horizontal
	end

	if align.vertical then
		self.textAlign.vertical = align.vertical
	end

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
		self.relativeTextPosition.x = math.floor(self.textOffset.x)
	elseif self.textAlign.horizontal == ikkuna.TextAlign.Horizontal.Right then
		self.relativeTextPosition.x = math.floor(self.width - width + self.textOffset.x)
	elseif self.textAlign.horizontal == ikkuna.TextAlign.Horizontal.Center then
		self.relativeTextPosition.x = math.floor(self.width / 2 - width / 2 + self.textOffset.x)
	end

	if self.textAlign.vertical == ikkuna.TextAlign.Vertical.Top then
		self.relativeTextPosition.y = math.floor(self.textOffset.y)
	elseif self.textAlign.vertical == ikkuna.TextAlign.Vertical.Bottom then
		self.relativeTextPosition.y = math.floor(self.height - height + self.textOffset.y)
	elseif self.textAlign.vertical == ikkuna.TextAlign.Vertical.Center then
		self.relativeTextPosition.y = math.floor(self.height / 2 - height / 2 + self.textOffset.y)
	end

	self.isTextDirty = false
end

function Widget:contains(x, y)
	return x >= self.x and x <= self.x + self.width and
	       y >= self.y and y <= self.y + self.height
end

function Widget:getChildAt(x, y)
	for index = #self.children, 1, -1 do
		local child = self.children[index]
		if child:isVisible() and child:contains(x, y) then
			local subChild = child:getChildAt(x, y)
			if subChild and subChild:isVisible() then
				return subChild
			end

			if not child:isPhantom() then
				return child
			end
		end
	end

	return nil
end

function Widget:getChild(id, recursive)
	for _, child in pairs(self.children) do
		if child.id == id then
			return child
		end

		if recursive then
			local subChild = child:getChild(id, recursive)
			if subChild then
				return subChild
			end
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
