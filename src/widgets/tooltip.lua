local Tooltip = ikkuna.class('Tooltip', ikkuna.Widget)

function Tooltip:initialize(options)
	ikkuna.Widget.initialize(self)

	self.focusable = false
	self.draggable = false
	self.visible = false
	self.fitToText = false

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

function Tooltip:draw()
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

	ikkuna.Widget.draw(self)
end

function Tooltip:setExplicitSize(width, height)
	if self.fitToText then
		return
	end

	ikkuna.Widget.setExplicitSize(self, width, height)
end

function Tooltip:setText(text)
	ikkuna.Widget.setText(self, text)

	if self.fitToText then
		ikkuna.Widget.setExplicitSize(self, self.text:getWidth() + 10, self.text:getHeight() + 10)
	end
end

ikkuna.Tooltip = Tooltip
