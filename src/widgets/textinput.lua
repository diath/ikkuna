local TextInput = class('TextInput', ikkuna.Widget)

function TextInput:initialize(options)
	ikkuna.Widget.initialize(self)

	self.focusable = true
end

function TextInput:onMousePressed(x, y, button, touch, presses)
	return true
end

function TextInput:onTextInput(text)
	local code = string.byte(text)
	if code < 32 or code > 127 then
		return false
	end

	ikkuna.Widget.setText(self, self.textString..text)
	return true
end

function TextInput:onKeyPressed(key, code, repeated)
	if key == "backspace" then
		ikkuna.Widget.setText(self, self.textString:sub(1, -2))
	end

	return true
end

ikkuna.TextInput = TextInput
