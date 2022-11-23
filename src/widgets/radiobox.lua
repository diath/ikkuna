local RadioBox = ikkuna.class('RadioBox', ikkuna.Widget)

function RadioBox:initialize(args)
	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.RadioBox

	self.draggable = false
	self.focusable = true

	self.textOffset.x = 20
	self.checked = false

	self.onCheckChange = ikkuna.Event()

	-- TODO: Use a resource manager to share loaded images.
	self.image = love.graphics.newImage(ikkuna.path('res/radiobox', '.png', '/'))
	self.imageChecked = love.graphics.newImage(ikkuna.path('res/radiobox_checked', '.png', '/'))
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
		self:toggle()
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
			ikkuna.sound:play()
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
