local Button = class('Button', ikkuna.Widget)

function Button:initialize()
	ikkuna.Widget.initialize(self)

	self.draggable = false
	self.textAlign = ikkuna.TextAlign.Center
end

ikkuna.Button = Button
