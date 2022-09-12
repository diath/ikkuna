local PushButton = ikkuna.class('PushButton', ikkuna.Button)

function PushButton:initialize()
	ikkuna.Button.initialize(self)
	self.pushed = false

	self.onPushChange = ikkuna.Event()
end

function PushButton:drawAt(x, y)
	if self.pushed then
		love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
		love.graphics.rectangle('fill', x, y, self.width, self.height)
	end

	self:drawText(x, y)
end

function PushButton:onMouseReleased(x, y, button, touch, pressed)
	if self.pressed and self.onPushChange:emit(self, not self.pushed) then
		self.pushed = not self.pushed
	end

	return ikkuna.Widget.onMouseReleased(self, x, y, button, touch, pressed)
end

ikkuna.PushButton = PushButton
