local ScrollBar = ikkuna.class('ScrollBar', ikkuna.Widget)

function ScrollBar:initialize(args)
	self.min = 0
	self.max = 1
	self.value = self.min
	self.displayValue = false

	-- NOTE: Used to update the value and children properly post-initialization.
	self.needUpdateValue = false

	ikkuna.Widget.initialize(self, args)

	self.onValueChange = ikkuna.Event()

	self.decButton = ikkuna.Button:new()
	self.decButton:setExplicitSize(10, self.height / 2)
	self.decButton:setText('<')
	self.decButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.decButton.onClick:connect(function() self:decrease() return true end)
	self.decButton.onPress:connect(function() self:decrease() return true end)
	self:addChild(self.decButton)

	self.incButton = ikkuna.Button:new()
	self.incButton:setExplicitSize(10, self.height / 2)
	self.incButton:setText('>')
	self.incButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.incButton.onClick:connect(function() self:increase() return true end)
	self.incButton.onPress:connect(function() self:increase() return true end)
	self:addChild(self.incButton)

	self.knob = ikkuna.Button:new()
	self.knob:setExplicitSize(10, self.height / 2)
	self.knob:setText(self.displayValue and self.value or '')
	self.knob:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.knob.draggable = true
	self.knob.onDragMove:connect(function(knob, x, y, dx, dy)
		if x - knob.dragOffset.x < self.decButton.x + self.decButton.width then
			return false
		end

		if x - knob.dragOffset.x + knob.width > self.incButton.x then
			return false
		end

		self:calculateValue()
		return true
	end)
	self:addChild(self.knob)

	local function onMouseWheel(dx, dy)
		if dy < 0 then
			self:decrease()
		elseif dy > 0 then
			self:increase()
		end
	end

	self.onMouseWheel:connect(onMouseWheel)
	self.decButton.onMouseWheel:connect(onMouseWheel)
	self.incButton.onMouseWheel:connect(onMouseWheel)
	self.knob.onMouseWheel:connect(onMouseWheel)

	self.step = self.knob.width
end

function ScrollBar:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.min then
		self:setMin(args.min)
	end

	if args.max then
		self:setMax(args.max)
	end

	if args.displayValue then
		self:setDisplayValue(args.displayValue)
	end
end

function ScrollBar:update(delta)
	if self.needUpdateValue then
		self:setValue(math.clamp(self.min, self.value, self.max))
		self:calculateChildrenPosition()

		self.needUpdateValue = false
	end
end

function ScrollBar:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)

	self.decButton:setExplicitSize(self.decButton.width, height)
	self.incButton:setExplicitSize(self.incButton.width, height)

	self.knob:setExplicitSize((self.width - self.decButton.width - self.incButton.width) / math.max(1, (self.max - self.min + 1)), height)

	self.step = self.knob.width
	self:calculateChildrenPosition()
end

function ScrollBar:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)

	self:calculateChildrenPosition()
end

function ScrollBar:calculateValue()
	self:setValue(self.min + math.floor((self.knob.x - self.decButton.x - self.decButton.width) / self.step))
end

function ScrollBar:calculateChildrenPosition()
	self.decButton:setPosition(self.x, self.y)
	self.incButton:setPosition(self.x + self.width - self.decButton.width, self.y)

	self:calculateKnobPosition()
end

function ScrollBar:calculateKnobPosition()
	self.knob:setPosition(self.decButton.x + self.decButton.width + self.step * (self.value - self.min), self.y)
end

function ScrollBar:setValue(value)
	if value < self.min or value > self.max then
		return false
	end

	if self.value == value then
		return false
	end

	self.knob:setText(self.displayValue and value or '')
	self.value = value
	self.onValueChange:emit(self, self.value)
	return true
end

function ScrollBar:increase()
	local increment = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.min(self.max, self.value + increment)
	if not self:setValue(newValue) then
		return false
	end

	self:calculateKnobPosition()
	return true
end

function ScrollBar:decrease()
	local decrement = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.max(self.min, self.value - decrement)
	if not self:setValue(newValue) then
		return false
	end

	self:calculateKnobPosition()
	return true
end

function ScrollBar:setMin(min)
	self.min = min

	if self.value < self.min then
		self.needUpdateValue = true
	end
end

function ScrollBar:setMax(max)
	self.max = max
	if self.max < self.min then
		self.max = self.min + 1
	end

	if self.value > self.max then
		self.needUpdateValue = true
	end
end

function ScrollBar:setDisplayValue(display)
	self.displayValue = display

	self.needUpdateValue = true
end

ikkuna.ScrollBar = ScrollBar
