local RadioBox = ikkuna.class('RadioBox', ikkuna.Widget)

function RadioBox:initialize(args)
	self.checked = false
	self.onCheckChange = ikkuna.Event()

	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.RadioBox

	self.draggable = false
	self.focusable = true

	self.textOffset.x = 20

	self.image = ikkuna.Resources.getImage(ikkuna.path('res/radiobox', '.png', '/'))
	self.imageChecked = ikkuna.Resources.getImage(ikkuna.path('res/radiobox_checked', '.png', '/'))
	self.sound = ikkuna.Resources.getSound(ikkuna.path('res/ui_click', '.ogg', '/'))
end

function RadioBox:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.events then
		self:parseEventsArg(self.onCheckChange, args.events.onCheckChange)
	end
end

function RadioBox:drawAt(x, y)
	self:drawBase(x, y)

	if self.checked then
		love.graphics.draw(self.imageChecked, x, y)
	else
		love.graphics.draw(self.image, x, y)
	end

	self:drawText(x, y)
end

function RadioBox:onKeyPressed(key, code, repeated)
	if key == 'space' or key == 'return' then
		self:setChecked(true)
		return true
	end

	return ikkuna.Widget.onKeyPressed(self, key, code, repeated)
end

function RadioBox:setChecked(checked)
	if self.checked == checked then
		return
	end

	if self.onCheckChange:emit(self, self.checked, checked) then
		self.checked = checked

		if self.group and checked then
			self.group:setSelected(self)
		end

		-- TODO: Do not play the first auto select sound when adding a RadioBox to an empty RadioGroup.
		if checked then
			self.sound:play()
		end

		return true
	end

	return false
end

function RadioBox:toggle()
	return self:setChecked(not self.checked)
end

function RadioBox:check()
	return self:setChecked(true)
end

function RadioBox:uncheck()
	return self:setChecked(false)
end

ikkuna.RadioBox = RadioBox
