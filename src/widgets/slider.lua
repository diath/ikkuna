local Slider = ikkuna.class('Slider', ikkuna.Widget)

function Slider:initialize(min, max, displayValueOnKnob)
	ikkuna.Widget.initialize(self)

	self.min = min or 0
	self.max = max or self.min + 1
	if self.max < self.min then
		self.max = self.min + 1
	end

	self.value = self.min
	self.displayValueOnKnob = displayValueOnKnob or false
	self.onValueChange = ikkuna.Event()

	local decButton = ikkuna.Button:new()
	decButton:setExplicitSize(10, self.height / 2)
	decButton:setText('<')
	decButton.onClick:connect(function() self:decrease() return true end)
	decButton.onPress:connect(function() self:decrease() return true end)
	self:addChild(decButton)

	local incButton = ikkuna.Button:new()
	incButton:setExplicitSize(10, self.height / 2)
	incButton:setText('>')
	incButton.onClick:connect(function() self:increase() return true end)
	incButton.onPress:connect(function() self:increase() return true end)
	self:addChild(incButton)

	local knob = ikkuna.Button:new()
	knob:setExplicitSize(10, self.height / 2)
	knob:setText(displayValueOnKnob and self.value or "")
	knob.draggable = true
	knob.onDragMove:connect(function(knob, x, y, dx, dy)
		if x - knob.dragOffset.x < decButton.x + decButton.width then
			return false
		end

		if x - knob.dragOffset.x + knob.width > incButton.x then
			return false
		end

		self:calculateValue()
		return true
	end)
	self:addChild(knob)

	local function onMouseWheel(dx, dy)
		if dy < 0 then
			self:decrease()
		elseif dy > 0 then
			self:increase()
		end
	end

	self.onMouseWheel:connect(onMouseWheel)
	decButton.onMouseWheel:connect(onMouseWheel)
	incButton.onMouseWheel:connect(onMouseWheel)
	knob.onMouseWheel:connect(onMouseWheel)

	self.step = knob.width
end

function Slider:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)

	self.children[1].height = height
	self.children[2].height = height

	self.children[3].width = (self.width - self.children[1].width - self.children[2].width) / math.max(1, (self.max - self.min + 1))
	self.children[3].height = height

	self.step = self.children[3].width
	self:calculateChildrenPosition()
end

function Slider:setPosition(x, y)
	ikkuna.Widget.setPosition(self, x, y)

	self:calculateChildrenPosition()
end

function Slider:calculateValue()
	self:setValue(self.min + math.floor((self.children[3].x - self.children[1].x - self.children[1].width) / self.step))
end

function Slider:calculateChildrenPosition()
	self.children[1].x = self.x
	self.children[1].y = self.y

	self.children[2].x = self.x + self.width - self.children[2].width
	self.children[2].y = self.y

	self:calculateKnobPosition()
end

function Slider:calculateKnobPosition()
	self.children[3].x = self.children[1].x + self.children[1].width + self.step * (self.value - self.min)
	self.children[3].y = self.y
end

function Slider:setValue(value)
	if value < self.min or value > self.max then
		return false
	end

	self.children[3]:setText(self.displayValueOnKnob and value or "")
	self.value = value
	self.onValueChange:emit(self, self.value)
	return true
end

function Slider:increase()
	local increment = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.min(self.max, self.value + increment)
	if not self:setValue(newValue) then
		return false
	end

	self:calculateKnobPosition()
	return true
end

function Slider:decrease()
	local decrement = ikkuna.isControlPressed() and 10 or 1
	local newValue = math.max(self.min, self.value - decrement)
	if not self:setValue(newValue) then
		return false
	end

	self:calculateKnobPosition()
	return true
end

ikkuna.Slider = Slider
