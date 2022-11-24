local SpinBox = ikkuna.class('SpinBox', ikkuna.Widget)

function SpinBox:initialize(args)
	self.min = 0
	self.max = 0
	self.value = self.min
	self.editTimer = ikkuna.Timer()

	self.incButton = ikkuna.Button:new()
	self.incButton:setExplicitSize(25, 25)
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

	self.decButton = ikkuna.Button:new()
	self.decButton:setExplicitSize(25, 25)
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

	-- NOTE: Used to update the value and children properly post-initialization.
	self.needUpdateValue = false

	self.onValueChange = ikkuna.Event()

	self.preferredSize = {width = 100, height = 30}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.SpinBox

	self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
	self:setText(self.value)

	self.focusable = true

	self:addChild(self.incButton)
	self:addChild(self.decButton)

	self.onMouseWheel:connect(function(dx, dy)
		return self:handleMouseWheel(dx, dy)
	end)
end

function SpinBox:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	self:parseArg(args, 'number', 'min', SpinBox.setMin)
	self:parseArg(args, 'number', 'max', SpinBox.setMax)

	if args.events then
		self:parseEventsArg(self.onValueChange, args.events.onValueChange)
	end
end

function SpinBox:onKeyPressed(key, code, repeated)
	if key == 'left' or key == 'down' then
		self:decrease()
		return true
	elseif key == 'right' or key == 'up' then
		self:increase()
		return true
	elseif table.contains({
		'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
		'kp1', 'kp2', 'kp3', 'kp4', 'kp5', 'kp6', 'kp7', 'kp8', 'kp9', 'kp0',
	}, key) then
		local value = key
		if value:find('kp') == 1 then
			value = value:sub(3)
		end

		value = tonumber(value)
		if not value then
			return false
		end

		local elapsed = self.editTimer:elapsed()
		if elapsed >= 1 then
			self:setValue(value)
		else
			value = tonumber(('%d%d'):format(self.value, value))
			if not value then
				return false
			end

			self:setValue(value)
		end
		self.editTimer:reset()

		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
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
	if value < self.min then
		return self:setValue(self.min)
	elseif value > self.max then
		return self:setValue(self.max)
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
