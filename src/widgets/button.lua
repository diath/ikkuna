local Button = class('Button', ikkuna.Widget)

function Button:initialize()
	ikkuna.Widget.initialize(self)

	self.draggable = false
	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

ikkuna.Button = Button
