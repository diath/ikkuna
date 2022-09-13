local ComboBox = ikkuna.class('ComboBox', ikkuna.Widget)

function ComboBox:initialize(args)
	self.selectedIndex = 0
	self.options = {}

	ikkuna.Widget.initialize(self, args)

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center

	self.onValueChange = ikkuna.Event()

	if #self.options > 0 then
		self:selectByIndex(1)
	end

	self.prevButton = ikkuna.Button:new()
	self.prevButton:setExplicitSize(10, 25)
	self.prevButton:setText('<')
	self.prevButton.onClick:connect(function()
		self:selectPrevious()
		return true
	end)
	self.prevButton.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
	self:addChild(self.prevButton)

	self.nextButton = ikkuna.Button:new()
	self.nextButton:setExplicitSize(10, 25)
	self.nextButton:setText('>')
	self.nextButton.onClick:connect(function()
		self:selectNext()
		return true
	end)
	self.nextButton.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
	self:addChild(self.nextButton)

	self.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
end

function ComboBox:parseArgs(args)
	if not args then
		return
	end

	if args.options then
		for _, option in pairs(args.options) do
			if type(option) == 'table' then
				self:addOption(option[1], option[2] or nil)
			else
				self:addOption(option, nil)
			end
		end
	end
end

function ComboBox:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)

	self:calculateChildrenPosition()
end

function ComboBox:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)

	self:calculateChildrenPosition()
end

function ComboBox:addOption(label, data)
	table.insert(self.options, {label = label, data = data})
end

function ComboBox:calculateChildrenPosition()
	self.prevButton.x = self.x
	self.prevButton.y = self.y

	self.nextButton.x = self.x + self.width - self.nextButton.width
	self.nextButton.y = self.y
end

function ComboBox:selectByIndex(index)
	if index < 1 or index > #self.options then
		return false
	end

	if self.selectedIndex == index then
		return false
	end

	self.selectedIndex = index
	self:setText(self.options[self.selectedIndex].label)
	self.onValueChange:emit(self, self.selectedIndex, self.options[self.selectedIndex])

	return true
end

function ComboBox:selectByLabel(label)
	for i, option in pairs(self.options) do
		if option.label == label then
			return self:selectByIndex(i)
		end
	end
end

function ComboBox:selectPrevious()
	self:selectByIndex(self.selectedIndex == 1 and #self.options or self.selectedIndex - 1)
end

function ComboBox:selectNext()
	self:selectByIndex(self.selectedIndex == #self.options and 1 or self.selectedIndex + 1)
end

function ComboBox:handleMouseWheel(dx, dy)
	if dy < 0 then
		self:selectPrevious()
	elseif dy > 0 then
		self:selectNext()
	end

	return true
end

ikkuna.ComboBox = ComboBox
