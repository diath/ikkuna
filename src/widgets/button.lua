local Button = ikkuna.class('Button', ikkuna.Widget)

function Button:initialize(args)
	self.preferredSize = {width = 100, height = 25}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.Button

	self.draggable = false
	self.focusable = true

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

function Button:onKeyPressed(key, code, repeated)
	if key == 'space' or key == 'return' then
		self.onClick:emit(self, self.x, self.y, ikkuna.Mouse.Button.Left, false, 1)
		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
end

ikkuna.Button = Button
