local Label = ikkuna.class('Label', ikkuna.Widget)

function Label:initialize(args)
	self.preferredSize = {width = 100, height = 20}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.Label

	self.draggable = false
	self.focusable = false
	self.phantom = true
end

ikkuna.Label = Label
