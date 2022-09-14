local Label = ikkuna.class('Label', ikkuna.Widget)

function Label:initialize(args)
	ikkuna.Widget.initialize(self, args)

	self.draggable = false
	self.focusable = false
	self.phantom = true
end

ikkuna.Label = Label
