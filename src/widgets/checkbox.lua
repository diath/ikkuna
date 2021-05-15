local CheckBox = ikkuna.class('CheckBox', ikkuna.Widget)

function CheckBox:initialize()
	ikkuna.Widget.initialize(self)
	self.textOffset.x = 20
	self.checked = false
	self.draggable = false

	self.onCheckChange = ikkuna.Event()
end

function CheckBox:draw()
	ikkuna.Widget.draw(self)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('line', self.x - 1, self.y - 1, 18, 18)

	if self.checked then
		love.graphics.setColor(0, 1, 0, 1)
	else
		love.graphics.setColor(1, 0, 0, 1)
	end
	love.graphics.rectangle('fill', self.x, self.y, 16, 16)
end

function CheckBox:onMousePressed(x, y, button, touch, presses)
	if self.onCheckChange:emit(self, self.checked, not self.checked) then
		self.checked = not self.checked
	end

	return ikkuna.Widget.onMousePressed(self, x, y, button, touch, presses)
end

ikkuna.CheckBox = CheckBox
