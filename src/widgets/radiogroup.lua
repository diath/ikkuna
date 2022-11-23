local RadioGroup = ikkuna.class('RadioGroup')

function RadioGroup:initialize()
	self.children = {}
	self.selected = nil
	self.onSelectedChildChange = ikkuna.Event()
end

function RadioGroup:addChild(widget)
	if widget.type ~= ikkuna.WidgetType.RadioBox then
		return false
	end

	if table.contains(self.children, widget) then
		return false
	end

	table.insert(self.children, widget)

	if not self.selected then
		self:setSelected(widget)
	end

	widget.onClick:connect(function(widget, x, y, button, touch, presses)
		self:setSelected(widget)
	end)

	widget.group = self
	return true
end

function RadioGroup:setSelected(widget)
	if self.selected == widget then
		return
	end

	if self.selected then
		self.selected:uncheck()
	end
	self.previouslySelected = self.selected

	self.selected = widget
	self.selected:check()

	self.onSelectedChildChange:emit(self, self.previouslySelected, self.selected)
end

ikkuna.RadioGroup = RadioGroup
