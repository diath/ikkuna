local Button = ikkuna.class('Button', ikkuna.Widget)

function Button:initialize(args)
	ikkuna.Widget.initialize(self, args)

	self.draggable = false
	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

ikkuna.Button = Button
