ikkuna = {}
ikkuna.class = require('src.vendor.middleclass')

ikkuna.font = love.graphics.newFont('res/Verdana.ttf', 12)
ikkuna.fontHeight = ikkuna.font:getHeight()

-- Const
ikkuna.TextAlign = {}
ikkuna.TextAlign.Horizontal = {}
ikkuna.TextAlign.Horizontal.Left = 1
ikkuna.TextAlign.Horizontal.Right = 2
ikkuna.TextAlign.Horizontal.Center = 3
ikkuna.TextAlign.Vertical = {}
ikkuna.TextAlign.Vertical.Top = 1
ikkuna.TextAlign.Vertical.Bottom = 2
ikkuna.TextAlign.Vertical.Center = 3

ikkuna.Mouse = {}
ikkuna.Mouse.Button = {}
ikkuna.Mouse.Button.Primary = 1
ikkuna.Mouse.Button.Secondary = 2
ikkuna.Mouse.Button.Middle = 3

function ikkuna.isControlPressed()
	return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')
end

function ikkuna.isShiftPressed()
	return love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
end

function ikkuna.startSwith(s, prefix)
	if #s < #prefix then
		return false
	end

	return s:sub(1, #prefix) == prefix
end

function ikkuna.parseColor(color)
	local result = {r = 1, g = 1, b = 1, a = 1}

	if type(color) == 'table' then
		if color.red <= 1 and color.green <= 1 and color.blue <= 1 then
			result.r = color.red
			result.g = color.green
			result.b = color.blue

			if color.alpha then
				result.a = color.alpha
			end
		else
			result.r = color.red / 255
			result.g = color.green / 255
			result.b = color.blue / 255

			if color.alpha then
				result.a = color.alpha / 255
			end
		end
	elseif type(color) == 'string' then
		if ikkuna.startSwith(color, '#') then
			local value = color:sub(2)
			local red = tonumber(value:sub(1, 2), 16)
			if red then
				result.r = red / 255
			end

			local green = tonumber(value:sub(3, 4), 16)
			if green then
				result.g = green / 255
			end

			local blue = tonumber(value:sub(5, 6), 16)
			if blue then
				result.b = blue / 255
			end
		else
			-- TODO: Basic color lookup by name.
		end
	end

	return result
end

-- Util
require('src.util.math')
require('src.util.table')
require('src.util.timer')
require('src.util.rect')

-- Base
require('src.gui.event')
require('src.gui.display')
require('src.gui.widget')

-- Layouts
require('src.layout.layout')
require('src.layout.horizontal')
require('src.layout.vertical')

-- Widgets
require('src.widgets.button')
require('src.widgets.checkbox')
require('src.widgets.combobox')
require('src.widgets.contextmenu')
require('src.widgets.label')
require('src.widgets.progressbar')
require('src.widgets.pushbutton')
require('src.widgets.radiobox')
require('src.widgets.radiogroup')
require('src.widgets.scrollarea')
require('src.widgets.scrollbar')
require('src.widgets.spinbox')
require('src.widgets.textinput')
