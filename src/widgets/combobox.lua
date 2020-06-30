local ComboBox = class('ComboBox', ikkuna.Widget)

function ComboBox:initialize(options)
	ikkuna.Widget.initialize(self)

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
	self.selectedIndex = 0
	self.options = {}

	self.onValueChange = ikkuna.Event()

	if options ~= nil then
		for _, option in pairs(options) do
			if type(option) == 'table' then
				self:addOption(option[1], option[2] or nil)
			else
				self:addOption(option, nil)
			end
		end
	end

	if #self.options > 0 then
		self:selectByIndex(1)
	end

	local leftButton = ikkuna.Button:new()
	leftButton:setExplicitSize(10, 25)
	leftButton:setText('<')
	leftButton.onClick:connect(function() self:selectPrevious() print('ComboBox.leftButton:onClick()') return true end)
	self:addChild(leftButton)

	local rightButton = ikkuna.Button:new()
	rightButton:setExplicitSize(10, 25)
	rightButton:setText('>')
	rightButton.onClick:connect(function() self:selectNext() print('ComboBox.rightButton:onClick()') return true end)
	self:addChild(rightButton)
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
	self.children[1].x = self.x
	self.children[1].y = self.y

	self.children[2].x = self.x + self.width - self.children[2].width
	self.children[2].y = self.y
end

function ComboBox:selectByIndex(index)
	if index < 1 or index > #self.options then
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

ikkuna.ComboBox = ComboBox
