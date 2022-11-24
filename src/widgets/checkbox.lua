local CheckBox = ikkuna.class('CheckBox', ikkuna.Widget)

function CheckBox:initialize(args)
	self.preferredSize = {width = 100, height = 20}

	self.checked = false
	self.onCheckChange = ikkuna.Event()

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.CheckBox

	self.textOffset.x = 20
	self.focusable = true
	self.draggable = false

	self.image = ikkuna.Resources.getImage(ikkuna.path('res/checkbox', '.png', '/'))
	self.sound = ikkuna.Resources.getSound(ikkuna.path('res/ui_click', '.ogg', '/'))
end

function CheckBox:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.events then
		self:parseEventsArg(self.onCheckChange, args.events.onCheckChange)
	end
end

function CheckBox:drawAt(x, y)
	self:drawBase(x, y)

	-- TODO: Make these based on the Style definition.
	local r = 57 / 255
	local g = 62 / 255
	local b = 75 / 255
	love.graphics.setColor(r, g, b, 1)
	love.graphics.rectangle('fill', x, y, ikkuna.CheckBoxBoxSize, ikkuna.CheckBoxBoxSize)

	local r = 32 / 255
	local g = 36 / 255
	local b = 48 / 255
	love.graphics.setColor(r, g, b, 1)
	love.graphics.setLineWidth(ikkuna.CheckBoxFrameSize)
	love.graphics.rectangle('line', x, y, ikkuna.CheckBoxBoxSize, ikkuna.CheckBoxBoxSize)
	love.graphics.setLineWidth(1)

	if self.checked then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.image, x + 2, y + 3)
	end

	self:drawText(x, y)
end

function CheckBox:onKeyPressed(key, code, repeated)
	if key == 'space' or key == 'return' then
		self:toggle()
		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
end

function CheckBox:onMousePressed(x, y, button, touch, presses)
	self:toggle()
	return true
end

function CheckBox:toggle()
	if self.onCheckChange:emit(self, self.checked, not self.checked) then
		self.checked = not self.checked
		self.sound:play()
	end
end

function CheckBox:setChecked(checked)
	if self.checked == checked then
		return
	end

	if self.onCheckChange:emit(self, self.checked, checked) then
		self.checked = checked
		self.sound:play()
	end
end

ikkuna.CheckBox = CheckBox
