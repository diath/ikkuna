local Button = ikkuna.class('Button', ikkuna.Widget)

function Button:initialize(args)
	self.preferredSize = {width = 100, height = 25}

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.Button

	self.draggable = false
	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center
	self.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
end

ikkuna.Button = Button
