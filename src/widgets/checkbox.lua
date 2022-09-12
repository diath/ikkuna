local CheckBox = ikkuna.class('CheckBox', ikkuna.Widget)

function CheckBox:initialize()
	ikkuna.Widget.initialize(self)
	self.textOffset.x = 20
	self.checked = false
	self.draggable = false

	self.onCheckChange = ikkuna.Event()
end

function CheckBox:draw()
	self:drawAt(self.x, self.y)
end

function CheckBox:drawAt(x, y)
	ikkuna.Widget.draw(self)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('line', x - 1, y - 1, 18, 18)

	if self.checked then
		love.graphics.setColor(0, 1, 0, 1)
	else
		love.graphics.setColor(1, 0, 0, 1)
	end
	love.graphics.rectangle('fill', x, y, 16, 16)
end

function CheckBox:onMousePressed(x, y, button, touch, presses)
	if self.onCheckChange:emit(self, self.checked, not self.checked) then
		self.checked = not self.checked
	end

	return ikkuna.Widget.onMousePressed(self, x, y, button, touch, presses)
end

ikkuna.CheckBox = CheckBox
