local PushButton = ikkuna.class('PushButton', ikkuna.Button)

function PushButton:initialize()
	ikkuna.Button.initialize(self)
	self.pushed = false

	self.onPushChange = ikkuna.Event()
end

function PushButton:draw()
	ikkuna.Widget.draw(self)

	if self.pushed then
		love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	end

	if self.text then
		local color = self.textColor
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.draw(self.text, self.textPosition.x, self.textPosition.y)
	end
end

function PushButton:onMouseReleased(x, y, button, touch, pressed)
	if self.pressed and self.onPushChange:emit(self, not self.pushed) then
		self.pushed = not self.pushed
	end

	return ikkuna.Widget.onMouseReleased(self, x, y, button, touch, pressed)
end

ikkuna.PushButton = PushButton
