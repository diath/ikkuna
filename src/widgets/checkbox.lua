local CheckBox = ikkuna.class('CheckBox', ikkuna.Widget)

function CheckBox:initialize(args)
	self.preferredSize = {width = 100, height = 20}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.CheckBox

	self.textOffset.x = 20
	self.checked = false
	self.focusable = true
	self.draggable = false

	self.onCheckChange = ikkuna.Event()
end

function CheckBox:drawAt(x, y)
	self:drawBase(x, y)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('line', x - 1, y - 1, 18, 18)

	if self.checked then
		love.graphics.setColor(0, 1, 0, 1)
	else
		love.graphics.setColor(1, 0, 0, 1)
	end
	love.graphics.rectangle('fill', x, y, 16, 16)

	self:drawText(x, y)
end

function CheckBox:onKeyPressed(key, code, repeated)
	if key == 'space' or key == 'return' then
		self:toggle()
		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
end

function CheckBox:onMousePressed(x, y, button, touch, presses)
	self:toggle()
	return true
end

function CheckBox:toggle()
	if self.onCheckChange:emit(self, self.checked, not self.checked) then
		self.checked = not self.checked
	end
end

ikkuna.CheckBox = CheckBox
