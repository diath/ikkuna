local Window = ikkuna.class('Window', ikkuna.Widget)

function Window:initialize(args)
	-- Title bar
	self.titleBarVisible = true

	self.titleLabel = ikkuna.Label:new()
	self.titleLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.titleLabel:setExplicitSize(100, 20)
	self.titleLabel:setPhantom(true)

	self.closeButton = ikkuna.Button:new()
	self.closeButton:setText('x')
	self.closeButton:setExplicitSize(20, 20)
	self.closeButton.onClick:connect(function()
		self:hide()
	end)

	-- Status bar
	self.statusBarVisible = true

	self.statusLabel = ikkuna.Label:new()
	self.statusLabel:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.statusLabel:setExplicitSize(100, 20)
	self.statusLabel:setPhantom(true)

	self.statusTime = 0
	self.statusTimeout = -1

	ikkuna.Widget.initialize(self, args)

	self.draggable = true

	self:addChild(self.titleLabel)
	self:addChild(self.closeButton)
	self:addChild(self.statusLabel)

	self:calculateChildrenPositionAndSize()
end

function Window:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.titleBarVisible ~= nil then
		if args.titleBarVisible then
			self:showTitleBar()
		else
			self:hideTitleBar()
		end
	end

	if args.title then
		self:setTitle(args.title)
	end

	if args.statusBarVisible ~= nil then
		if args.statusBarVisible then
			self:showStatusBar()
		else
			self:hideStatusBar()
		end
	end
end

function Window:update(delta)
	ikkuna.Widget.update(self)

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
		self.closeButton:draw()
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

function Window:calculateChildrenPositionAndSize()
	local contentOffset = 0
	local contentHeight = self.height
	if self.titleBarVisible then
		self.titleLabel:setExplicitSize(self.width, self.titleLabel.height)
		self.titleLabel:setPosition(self.x, self.y)

		self.closeButton:setPosition(self.x + self.width - self.closeButton.width, self.y)

		contentHeight = contentHeight - self.titleLabel.height
		contentOffset = contentOffset + self.titleLabel.height
	end

	if self.statusBarVisible then
		self.statusLabel:setExplicitSize(self.width, self.statusLabel.height)
		self.statusLabel:setPosition(self.x, self.y + self.height - self.statusLabel.height)
		contentHeight = contentHeight - self.statusLabel.height
	end

	if self.contentWidget then
		self.contentWidget:setExplicitSize(self.width, contentHeight)
		self.contentWidget:setPosition(self.x, self.y + contentOffset)
	end
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
		self.contentWidget = nil
	end

	self.contentWidget = widget
	self.contentWidget:setPhantom(true)
	self:addChild(self.contentWidget)

	self:calculateChildrenPositionAndSize()
end

ikkuna.Window = Window
