local TabBar = ikkuna.class('TabBar', ikkuna.Widget)

function TabBar:initialize(args)
	self.tabs = {}
	self.activeTab = nil

	ikkuna.Widget.initialize(self, args)

	self.draggable = false
	self.phantom = true

	self:setLayout(ikkuna.HorizontalLayout:new())
end

function TabBar:parseAgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.tabs then
		for _, tab in pairs(args.tabs) do
			self:addTab(tab.title, tab.panel)
		end
	end
end

function TabBar:addTab(title, panel)
	local button = ikkuna.Button:new({
		size = {width = 100, height = 20},
		text = {
			label = title,
			align = {
				horizontal = 'center',
				vertical = 'center',
			},
		},
		events = {
			onClick = function()
				self:selectTab(title)
			end,
		}
	})
	self:addChild(button)

	if self.contentWidget then
		self.contentWidget:addChild(panel)
	end

	table.insert(self.tabs, {title = title, panel = panel, button = button})

	if #self.tabs == 1 then
		self:selectTab(title)
	end
end

function TabBar:removeTab(title)
	for index, tab in pairs(self.tabs) do
		if tab.title == title then
			if self.contentWidget then
				self.contentWidget:removeChild(tab.panel)
			end

			self:removeChild(tab.button)
			table.remove(self.tabs, index)
			return true
		end
	end

	return false
end

function TabBar:selectTab(title)
	if self.activeTab then
		self.activeTab.panel:hide()
	end

	for _, tab in pairs(self.tabs) do
		if tab.title == title then
			self.activeTab = tab
			self.activeTab.panel:show()
			break
		end
	end
end

function TabBar:setContentWidget(widget)
	if self.contentWidget then
		self:removeChild(self.contentWidget)
		self.contentWidget = nil
	end

	self.contentWidget = widget
	self.contentWidget:setPhantom(true)

	for index, tab in pairs(self.tabs) do
		self.contentWidget:addChild(tab.panel)
		if index == 1 then
			tab.panel:show()
		else
			tab.panel:hide()
		end
	end
end

ikkuna.TabBar = TabBar
