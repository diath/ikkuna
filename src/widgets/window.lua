local Window = ikkuna.class('Window', ikkuna.Widget)

function Window:initialize(args)
	-- Title bar
	self.titleBarVisible = true

	self.titleLabel = ikkuna.Label:new({style = 'WindowTitleBar'})
	self.titleLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.titleLabel:setExplicitSize(100, 20)
	self.titleLabel:setPhantom(true)

	self.closeButtonVisible = true
	self.closeButton = ikkuna.Button:new()
	self.closeButton:setText('X')
	self.closeButton:setExplicitSize(16, 16)
	self.closeButton.onClick:connect(function()
		self:hide()
	end)

	-- Status bar
	self.statusBarVisible = false

	self.statusLabel = ikkuna.Label:new({style = 'WindowStatusBar'})
	self.statusLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.statusLabel:setExplicitSize(100, 20)
	self.statusLabel:setPhantom(true)

	self.statusTime = 0
	self.statusTimeout = -1
	self.dockMode = ikkuna.WindowDockMode.None

	self.shouldResizeToContentWidget = false

	self.contentWidget = nil
	self.contentWidgetResizeCallbackId = nil

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
	if self.titleBarVisible then
		self.titleLabel:draw()

		if self.closeButtonVisible then
			self.closeButton:draw()
		end
	end

	-- Content widget
	if self.contentWidget then
		self.contentWidget:draw()
	end

	-- Status bar
	if self.statusBarVisible then
		self.statusLabel:draw()
	end
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
	self.titleBarVisible = true
	self:calculateChildrenPositionAndSize()
end

function Window:hideTitleBar()
	self.titleBarVisible = false
	self:calculateChildrenPositionAndSize()
end

function Window:setTitleBarVisible(visible)
	self.titleBarVisible = visible
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
	self.statusBarVisible = true
	self:calculateChildrenPositionAndSize()
end

function Window:hideStatusBar()
	self.statusBarVisible = false
	self:calculateChildrenPositionAndSize()
end

function Window:setStatusBarVisible(visible)
	self.statusBarVisible = visible
	self:calculateChildrenPositionAndSize()
end

function Window:setCloseButtonVisible(visible)
	self.closeButtonVisible = visible
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
	if self.titleBarVisible then
		self.titleLabel:setExplicitSize(self.width, self.titleLabel.height)
		self.titleLabel:setPosition(self.x, self.y)

		self.closeButton:setPosition(self.x + self.width - self.closeButton.width - 1, self.y + (self.titleLabel.height / 2) - (self.closeButton.height / 2))

		contentHeight = contentHeight - self.titleLabel.height
		contentOffset = contentOffset + self.titleLabel.height
	end

	if self.statusBarVisible then
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
	if self.titleBarVisible then
		height = height + self.titleLabel.height
	end

	if self.statusBarVisible then
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

	if dockMode == ikkuna.WindowDockMode.None then
		self.draggable = true
	elseif dockMode == ikkuna.WindowDockMode.Left then
		self.draggable = false
		self:setPosition(0, 0)
		self:setExplicitSize(self.width, ikkuna.Height)
	elseif dockMode == ikkuna.WindowDockMode.Right then
		self.draggable = false
		self:setPosition(ikkuna.Width - self.width, 0)
		self:setExplicitSize(self.width, ikkuna.Height)
	elseif dockMode == ikkuna.WindowDockMode.Top then
		self.draggable = false
		self:setPosition(0, 0)
		self:setExplicitSize(ikkuna.Width, self.height)
	elseif dockMode == ikkuna.WindowDockMode.Bottom then
		self.draggable = false
		self:setPosition(0, ikkuna.Height - self.height)
		self:setExplicitSize(ikkuna.Width, self.height)
	end
end

ikkuna.Window = Window
