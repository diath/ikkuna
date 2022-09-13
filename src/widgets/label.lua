local Label = ikkuna.class('Label', ikkuna.Widget)

function Label:initialize(args)
	ikkuna.Widget.initialize(self, args)

	self.draggable = false
	self.focusable = false
end

ikkuna.Label = Label
