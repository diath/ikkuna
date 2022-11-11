local Separator = ikkuna.class('Separator', ikkuna.Widget)

function Separator:initialize(args)
	self.preferredSize = {width = 100, height = 10}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.Separator

	self.draggable = false
	self.focusable = false
end

function Separator:drawAt(x, y)
	local style = self:getStyle()
	if not style then
		return
	end

	local color = style.color
	if color then
		love.graphics.setColor(color.r, color.g, color.b, color.a)
	end

	local y = self.y + (self.height / 2) - (ikkuna.SeparatorHeight / 2)

	love.graphics.setLineWidth(ikkuna.SeparatorHeight)
	love.graphics.line(self.x, y, self.x + self.width, y)
end

ikkuna.Separator = Separator
