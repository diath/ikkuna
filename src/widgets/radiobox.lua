local RadioBox = ikkuna.class('RadioBox', ikkuna.Widget)

function RadioBox:initialize(args)
	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.RadioBox

	self.draggable = false
	self.focusable = true

	self.textOffset.x = 20
	self.checked = false

	self.onCheckChange = ikkuna.Event()
end

function RadioBox:drawAt(x, y)
	self:drawBase(x, y)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.circle('line', x + 5, y + 5, 5, ikkuna.RadioBoxCircleSegments)

	if self.checked then
		love.graphics.setColor(0, 1, 0, 1)
	else
		love.graphics.setColor(1, 0, 0, 1)
	end
	love.graphics.circle('fill', x + 6, y + 6, 4, ikkuna.RadioBoxCircleSegments)

	self:drawText(x, y)
end

function RadioBox:onKeyPressed(key, code, repeated)
	if key == 'space' or key == 'return' then
		self:toggle()
		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
end

function RadioBox:setChecked(checked)
	if self.onCheckChange:emit(self, self.checked, checked) then
		self.checked = checked

		if self.group and checked then
			self.group:setSelected(self)
		end

		return true
	end

	return false
end

function RadioBox:toggle()
	return self:setChecked(not self.checked)
end

function RadioBox:check()
	return self:setChecked(true)
end

function RadioBox:uncheck()
	return self:setChecked(false)
end

ikkuna.RadioBox = RadioBox
