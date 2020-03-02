local RadioGroup = class('RadioGroup')

function RadioGroup:initialize()
	self.children = {}
	self.selected = nil
	self.onSelectedChildChange = ikkuna.Event()
end

function RadioGroup:addChild(widget)
	if tostring(widget) ~= 'instance of class RadioBox' then
		return false
	end

	if table.contains(self.children, widget) then
		return false
	end

	table.insert(self.children, widget)

	if not self.selected then
		self.selected = widget
		widget.checked = true
		widget.onCheckChange:emit(widget, true)
	end

	widget.onClick:connect(function(widget, x, y, button, touch, presses)
		if not widget.selected and widget ~= self.selected then
			self.selected.checked = false
			self.selected.onCheckChange:emit(self.selected, false)

			self.selected = widget
			self.selected.checked = true
			self.selected.onCheckChange:emit(self.selected, true)
		end
	end)

	return true
end

ikkuna.RadioGroup = RadioGroup
