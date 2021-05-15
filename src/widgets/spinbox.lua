local SpinBox = ikkuna.class('SpinBox', ikkuna.Widget)

function SpinBox:initialize(min, max)
	ikkuna.Widget.initialize(self)

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
	self.min = min or 0
	self.max = max or 0
	self.value = self.min
	self:setText(self.value)

	self.onValueChange = ikkuna.Event()

	local incButton = ikkuna.Button:new()
	incButton:setExplicitSize(10, self.height / 2)
	incButton:setText('^')
	incButton.onClick:connect(function()
		self:increase()
		return true
	end)
	incButton.onPress:connect(function(pressedButton)
		self:increase()
		return true
	end)
	self:addChild(incButton)

	local decButton = ikkuna.Button:new()
	decButton:setExplicitSize(10, self.height / 2)
	decButton:setText('v')
	decButton.onClick:connect(function()
		self:decrease()
		return true
	end)
	decButton.onPress:connect(function(pressedButton)
		self:decrease()
		return true
	end)
	self:addChild(decButton)

	self.onMouseWheel:connect(function(dx, dy)
		if dy < 0 then
			self:decrease()
		elseif dy > 0 then
			self:increase()
		end

		return true
	end)
end

function SpinBox:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)

	self.children[1].height = height / 2
	self.children[2].height = height / 2

	self:calculateChildrenPosition()
end

function SpinBox:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)

	self:calculateChildrenPosition()
end

function SpinBox:calculateChildrenPosition()
	self.children[1].x = self.x + self.width - self.children[1].width
	self.children[1].y = self.y

	self.children[2].x = self.x + self.width - self.children[2].width
	self.children[2].y = self.y + self.height - self.children[1].height
end

function SpinBox:setValue(value)
	if value < self.min or value > self.max then
		return false
	end

	self.value = value
	self:setText(self.value)
	self.onValueChange:emit(self, self.value)

	return true
end

function SpinBox:increase()
	return self:setValue(self.value + 1)
end

function SpinBox:decrease()
	return self:setValue(self.value - 1)
end

ikkuna.SpinBox = SpinBox
