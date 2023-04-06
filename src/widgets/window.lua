local Window = ikkuna.class('Window', ikkuna.Widget)

function Window:initialize(args)
	-- Title bar
	self.titleLabel = ikkuna.Label:new({id = 'WindowTitleBar', style = 'WindowTitleBar'})
	self.titleLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.titleLabel:setExplicitSize(100, 20)
	self.titleLabel:setPhantom(true)

	self.closeButton = ikkuna.Button:new({id = 'WindowCloseButton'})
	self.closeButton:setText('X')
	self.closeButton:setExplicitSize(16, 16)
	self.closeButton.onClick:connect(function()
		self:hide()
	end)

	-- Status bar
	self.statusLabel = ikkuna.Label:new({id = 'WindowStatusLabel', style = 'WindowStatusBar'})
	self.statusLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.statusLabel:setExplicitSize(100, 20)
	self.statusLabel:setPhantom(true)
	self.statusLabel:setVisible(false)

	self.statusTime = 0
	self.statusTimeout = -1
	self.dockMode = ikkuna.WindowDockMode.None
	self.fixedDockModeSize = false

	self.shouldResizeToContentWidget = false

	self.contentWidget = nil
	self.contentWidgetResizeCallbackId = nil

	self.onEnter = ikkuna.Event:new()
	self.onEscape = ikkuna.Event:new()

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.Window

	self:addChild(self.titleLabel)
	self:addChild(self.closeButton)
	self:addChild(self.statusLabel)

	self:calculateChildrenPositionAndSize()

	self.onDragStart:connect(function(widget, x, y)
		if self.draggable and self.parent then
			self.parent:moveChildToBack(self)
		end

		return true
	end)

	self.onFocusChange:connect(function(widget, focused)
		if focused then
			ikkuna.display.activeWindow = widget
		elseif not focused and self.display.activeWindow == widget then
			ikkuna.display.activeWindow = nil
		end

		return true
	end)

	self.parent.onResize:connect(function(widget, width, height)
		self:updateDockPositionAndSize()
		return true
	end)
end

function Window:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	self:parseArg(args, 'string', 'title', Window.setTitle)
	self:parseArg(args, 'boolean', 'titleBarVisible', Window.setTitleBarVisible)
	self:parseArg(args, 'boolean', 'statusBarVisible', Window.setStatusBarVisible)
	self:parseArg(args, 'boolean', 'closeButtonVisible', Window.setCloseButtonVisible)
	self:parseArg(args, 'boolean', 'resizeToContentWidget', Window.setResizeToContentWidget)
	self:parseArg(args, 'number', 'dockMode', Window.setDockMode)
	self:parseArg(args, 'boolean', 'fixedDockModeSize', Window.setFixedDockModeSize)

	if args.events then
		self:parseEventsArg(self.onEnter, args.events.onEnter)
		self:parseEventsArg(self.onEscape, args.events.onEscape)
	end
end

function Window:update(delta)
	ikkuna.Widget.update(self, delta)

	if self.statusTimeout ~= -1 then
		self.statusTime = self.statusTime + delta
		if self.statusTime > self.statusTimeout then
			self.statusLabel:setText('')
			self.statusTime = 0
			self.statusTimeout = -1
		end
	end
end

function Window:drawAt(x, y)
	self:drawBase(x, y)

	-- Title bar
	if self.titleLabel:isVisible() then
		self.titleLabel:draw()

		if self.closeButton:isVisible() then
			self.closeButton:draw()
		end
	end

	-- Content widget
	if self.contentWidget then
		self.contentWidget:draw()
	end

	-- Status bar
	if self.statusLabel:isVisible() then
		self.statusLabel:draw()
	end
end

function Window:hide()
	if ikkuna.display.activeWindow == self then
		ikkuna.display.activeWindow = nil
	end

	ikkuna.Widget.hide(self)
end

function Window:show()
	if self.parent then
		self.parent:moveChildToBack(self)
	end

	self:focusFirstChild()
	ikkuna.display.activeWindow = self
	ikkuna.Widget.show(self)
end

function Window:showCentered()
	local x = ikkuna.Width / 2 - self.width / 2
	local y = ikkuna.Height / 2 - self.height / 2

	self:setPosition(x, y)
	self:show()
end

function Window:setTitle(title)
	self.titleLabel:setText(title)
end

function Window:showTitleBar()
	self:setTitleBarVisible(true)
end

function Window:hideTitleBar()
	self:setTitleBarVisible(false)
end

function Window:setTitleBarVisible(visible)
	self.titleLabel:setVisible(visible)
	self:calculateChildrenPositionAndSize()
end

function Window:setStatus(status, timeout)
	self.statusLabel:setText(status)

	if timeout then
		self.statusTime = 0
		self.statusTimeout = timeout
	else
		self.statusTime = 0
		self.statusTimeout = -1
	end
end

function Window:showStatusBar()
	self:setStatusBarVisible(true)
end

function Window:hideStatusBar()
	self:setStatusBarVisible(false)
end

function Window:setStatusBarVisible(visible)
	self.statusLabel:setVisible(visible)
	self:calculateChildrenPositionAndSize()
end

function Window:setCloseButtonVisible(visible)
	self.closeButton:setVisible(visible)
	self:calculateChildrenPositionAndSize()
end

function Window:setResizeToContentWidget(resize)
	self.shouldResizeToContentWidget = resize

	if resize then
		self:resizeToContentWidget()
	end
end

function Window:calculateChildrenPositionAndSize()
	local contentOffset = 0
	local contentHeight = self.height
	if self.titleLabel:isVisible() then
		self.titleLabel:setExplicitSize(self.width, self.titleLabel.height)
		self.titleLabel:setPosition(self.x, self.y)

		self.closeButton:setPosition(self.x + self.width - self.closeButton.width - 1, self.y + (self.titleLabel.height / 2) - (self.closeButton.height / 2))

		contentHeight = contentHeight - self.titleLabel.height
		contentOffset = contentOffset + self.titleLabel.height
	end

	if self.statusLabel:isVisible() then
		self.statusLabel:setExplicitSize(self.width, self.statusLabel.height)
		self.statusLabel:setPosition(self.x, self.y + self.height - self.statusLabel.height)
		contentHeight = contentHeight - self.statusLabel.height
	end

	if self.contentWidget then
		if not self.shouldResizeToContentWidget then
			self.contentWidget:setExplicitSize(self.width, contentHeight)
		end

		self.contentWidget:setPosition(self.x, self.y + contentOffset)
	end
end

function Window:resizeToContentWidget()
	if not self.contentWidget then
		return
	end

	local height = 0
	if self.titleLabel:isVisible() then
		height = height + self.titleLabel.height
	end

	if self.statusLabel:isVisible() then
		height = height + self.statusLabel.height
	end

	height = height + self.contentWidget.height
	self:setExplicitSize(self.width, height)
	self.contentWidget:setExplicitSize(self.width, self.contentWidget.height)
end

function Window:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)
	self:calculateChildrenPositionAndSize()
end

function Window:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)
	self:calculateChildrenPositionAndSize()
end

function Window:setContentWidget(widget)
	if self.contentWidget then
		self:removeChild(self.contentWidget)
		self.contentWidget.onResize:disconnect(self.contentWidgetResizeCallbackId)

		self.contentWidget = nil
		self.contentWidgetResizeCallbackId = nil
	end

	if not widget then
		return
	end

	self.contentWidget = widget
	self.contentWidgetResizeCallbackId = self.contentWidget.onResize:connect(function(widget, width, height)
		if self.shouldResizeToContentWidget then
			self:resizeToContentWidget()
		end

		return true
	end)

	self.contentWidget:setPhantom(true)
	self:addChild(self.contentWidget)

	self:calculateChildrenPositionAndSize()

	if self.shouldResizeToContentWidget then
		self:resizeToContentWidget()
	end
end

function Window:setDockMode(dockMode)
	if self.dockMode == dockMode then
		return
	end

	self.dockMode = dockMode
	self:updateDockPositionAndSize()
end

function Window:setFixedDockModeSize(fixedDockModeSize)
	if self.fixedDockModeSize == fixedDockModeSize then
		return
	end

	self.fixedDockModeSize = fixedDockModeSize
	self:updateDockPositionAndSize()
end

function Window:updateDockPositionAndSize()
	local dockMode = self.dockMode
	if dockMode == ikkuna.WindowDockMode.None then
		self.draggable = true
	elseif dockMode == ikkuna.WindowDockMode.Left then
		self.draggable = false

		if self.fixedDockModeSize then
			self:setPosition(0, ikkuna.Height / 2 - self.height / 2)
		else
			self:setPosition(0, 0)
			self:setExplicitSize(self.width, ikkuna.Height)
		end
	elseif dockMode == ikkuna.WindowDockMode.Right then
		self.draggable = false

		if self.fixedDockModeSize then
			self:setPosition(ikkuna.Width - self.width, ikkuna.Height / 2 - self.height / 2)
		else
			self:setPosition(ikkuna.Width - self.width, 0)
			self:setExplicitSize(self.width, ikkuna.Height)
		end
	elseif dockMode == ikkuna.WindowDockMode.Top then
		self.draggable = false

		if self.fixedDockModeSize then
			self:setPosition(ikkuna.Width / 2 - self.width / 2, 0)
		else
			self:setPosition(0, 0)
			self:setExplicitSize(ikkuna.Width, self.height)
		end
	elseif dockMode == ikkuna.WindowDockMode.Bottom then
		self.draggable = false

		if self.fixedDockModeSize then
			self:setPosition(ikkuna.Width / 2 - self.width / 2, ikkuna.Height - self.height)
		else
			self:setPosition(0, ikkuna.Height - self.height)
			self:setExplicitSize(ikkuna.Width, self.height)
		end
	end
end

ikkuna.Window = Window
