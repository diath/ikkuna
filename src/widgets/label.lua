local Label = ikkuna.class('Label', ikkuna.Widget)

function Label:initialize()
	ikkuna.Widget.initialize(self)

	self.draggable = false
	self.focusable = false
end

ikkuna.Label = Label
