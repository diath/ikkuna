local RadioBox = ikkuna.class('RadioBox', ikkuna.Widget)
RadioBox.Segments = 20

function RadioBox:initialize()
	ikkuna.Widget.initialize(self)

	self.draggable = false
	self.textOffset.x = 20
	self.checked = false

	self.onCheckChange = ikkuna.Event()
end

function RadioBox:draw()
	ikkuna.Widget.draw(self)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.circle('line', self.x + 5, self.y + 5, 5, RadioBox.Segments)

	if self.checked then
		love.graphics.setColor(0, 1, 0, 1)
	else
		love.graphics.setColor(1, 0, 0, 1)
	end
	love.graphics.circle('fill', self.x + 6, self.y + 6, 4, RadioBox.Segments)
end

ikkuna.RadioBox = RadioBox
