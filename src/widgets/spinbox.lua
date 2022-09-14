local SpinBox = ikkuna.class('SpinBox', ikkuna.Widget)

function SpinBox:initialize(args)
	self.min = 0
	self.max = 0
	self.value = self.min

	-- NOTE: Used to update the value and children properly post-initialization.
	self.needUpdateValue = false

	ikkuna.Widget.initialize(self, args)

	self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self:setText(self.value)

	self.onValueChange = ikkuna.Event()

	self.incButton = ikkuna.Button:new()
	self.incButton:setExplicitSize(10, self.height / 2)
	self.incButton:setText('^')
	self.incButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.incButton.onClick:connect(function()
		self:increase()
		return true
	end)
	self.incButton.onPress:connect(function(pressedButton)
		self:increase()
		return true
	end)
	self.incButton.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
	self:addChild(self.incButton)

	self.decButton = ikkuna.Button:new()
	self.decButton:setExplicitSize(10, self.height / 2)
	self.decButton:setText('v')
	self.decButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.decButton.onClick:connect(function()
		self:decrease()
		return true
	end)
	self.decButton.onPress:connect(function(pressedButton)
		self:decrease()
		return true
	end)
	self.decButton.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
	self:addChild(self.decButton)

	self.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
end

function SpinBox:parseArgs(args)
	if not args then
		return
	end

	if args.min then
		self:setMin(args.min)
	end

	if args.max then
		self:setMax(args.max)
	end
end

function SpinBox:update(delta)
	ikkuna.Widget.update(self, delta)

	if self.needUpdateValue then
		self:setValue(math.clamp(self.min, self.value, self.max))
		self:calculateChildrenPosition()

		self.needUpdateValue = false
	end
end

function SpinBox:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)

	self.incButton:setExplicitSize(self.incButton.width, height / 2)
	self.decButton:setExplicitSize(self.decButton.width, height / 2)

	self:calculateChildrenPosition()
end

function SpinBox:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)

	self:calculateChildrenPosition()
end

function SpinBox:calculateChildrenPosition()
	self.incButton:setPosition(self.x + self.width - self.incButton.width, self.y)
	self.decButton:setPosition(self.x + self.width - self.decButton.width, self.y + self.height - self.incButton.height)
end

function SpinBox:setValue(value)
	if value < self.min or value > self.max then
		return false
	end

	if self.value == value then
		return false
	end

	self.value = value
	self:setText(self.value)
	self.onValueChange:emit(self, self.value)

	return true
end

function SpinBox:increase()
	local increment = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.min(self.max, self.value + increment)
	return self:setValue(newValue)
end

function SpinBox:decrease()
	local decrement = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.max(self.min, self.value - decrement)
	return self:setValue(newValue)
end

function SpinBox:handleMouseWheel(dx, dy)
	if dy < 0 then
		self:decrease()
	elseif dy > 0 then
		self:increase()
	end

	return true
end

function SpinBox:setMin(min)
	self.min = min

	if self.value < self.min then
		self.needUpdateValue = true
	end
end

function SpinBox:setMax(max)
	self.max = max
	if self.max < self.min then
		self.max = self.min + 1
	end

	if self.value > self.max then
		self.needUpdateValue = true
	end
end

ikkuna.SpinBox = SpinBox
