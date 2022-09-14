local ScrollBar = ikkuna.class('ScrollBar', ikkuna.Widget)

function ScrollBar:initialize(args)
	self.min = 0
	self.max = 1
	self.value = self.min
	self.displayValue = false
	self.orientation = ikkuna.ScrollBarOrientation.Horizontal

	-- NOTE: Used to update the value and children properly post-initialization.
	self.needUpdateValue = false

	self.onValueChange = ikkuna.Event()

	self.decButton = ikkuna.Button:new()
	self.decButton:setExplicitSize(20, 20)
	self.decButton:setText('<')
	self.decButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.decButton.onClick:connect(function() self:decrease() return true end)
	self.decButton.onPress:connect(function() self:decrease() return true end)

	self.incButton = ikkuna.Button:new()
	self.incButton:setExplicitSize(20, 20)
	self.incButton:setText('>')
	self.incButton:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.incButton.onClick:connect(function() self:increase() return true end)
	self.incButton.onPress:connect(function() self:increase() return true end)

	self.knob = ikkuna.Button:new()
	self.knob:setExplicitSize(20, 20)
	self.knob:setText(self.displayValue and self.value or '')
	self.knob:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self.knob.draggable = true
	self.knob.onDragMove:connect(function(knob, x, y, dx, dy)
		if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
			if x - knob.dragOffset.x < self.decButton.x + self.decButton.width then
				return false
			end

			if x - knob.dragOffset.x + knob.width > self.incButton.x then
				return false
			end
		elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
			if y - knob.dragOffset.y < self.decButton.y + self.decButton.height then
				return false
			end

			if y - knob.dragOffset.y + knob.height > self.incButton.y then
				return false
			end
		end

		self:calculateValue()
		return true
	end)

	ikkuna.Widget.initialize(self, args)

	self:addChild(self.decButton)
	self:addChild(self.incButton)
	self:addChild(self.knob)

	local function onMouseWheel(dx, dy)
		if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
			if dy < 0 then
				self:decrease()
			elseif dy > 0 then
				self:increase()
			end
		elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
			if dy < 0 then
				self:increase()
			elseif dy > 0 then
				self:decrease()
			end
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

	if args.orientation then
		self:setOrientation(args.orientation)
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

	if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
		self.decButton:setExplicitSize(self.decButton.width, height)
		self.incButton:setExplicitSize(self.incButton.width, height)

		self.knob:setExplicitSize((self.width - self.decButton.width - self.incButton.width) / math.max(1, (self.max - self.min + 1)), height)

		self.step = self.knob.width
	elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
		self.decButton:setExplicitSize(width, self.decButton.height)
		self.incButton:setExplicitSize(width, self.incButton.height)

		self.knob:setExplicitSize(width, (self.height - self.decButton.height - self.incButton.height) / math.max(1, (self.max - self.min + 1)))

		self.step = self.knob.height
	end

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
	if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
		self.decButton:setPosition(self.x, self.y)
		self.incButton:setPosition(self.x + self.width - self.incButton.width, self.y)
	elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
		self.decButton:setPosition(self.x, self.y)
		self.incButton:setPosition(self.x, self.y + self.height - self.incButton.height)
	end

	self:calculateKnobPosition()
end

function ScrollBar:calculateKnobPosition()
	if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
		self.knob:setPosition(self.decButton.x + self.decButton.width + self.step * (self.value - self.min), self.y)
	elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
		self.knob:setPosition(self.x, self.decButton.y + self.decButton.height + self.step * (self.value - self.min))
	end
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

function ScrollBar:setOrientation(orientation)
	self.orientation = orientation

	if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
		self.decButton:setText('<')
		self.incButton:setText('>')
	elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
		self.decButton:setText('^')
		self.incButton:setText('V')
	end

	self.needUpdateValue = true
end

ikkuna.ScrollBar = ScrollBar
