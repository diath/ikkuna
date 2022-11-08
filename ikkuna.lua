ikkuna = {}
ikkuna.class = require('src.vendor.middleclass')

ikkuna.font = love.graphics.newFont('res/VeraMono.ttf', 12)
ikkuna.fontHeight = ikkuna.font:getHeight()

-- Const
ikkuna.Width = 800
ikkuna.Height = 600

local function enum(...)
	local result = {}
	for index, key in pairs({...}) do
		result[key] = index
	end
	return result
end

ikkuna.TextAlign = {}
ikkuna.TextAlign.Horizontal = enum('Left', 'Right', 'Center')
ikkuna.TextAlign.Vertical = enum('Top', 'Bottom', 'Center')

ikkuna.ScrollAreaOrientation = enum('Horizontal', 'Vertical')
ikkuna.ScrollBarOrientation = enum('Horizontal', 'Vertical')

ikkuna.TextInputMode = enum('SingleLine', 'MultiLine', 'Number')
ikkuna.StyleState = enum('Normal', 'Hovered', 'Focused', 'Disabled')
ikkuna.WindowDockMode = enum('None', 'Left', 'Right', 'Top', 'Bottom')

ikkuna.WidgetType = enum(
	'Widget', 'Button', 'CheckBox', 'ComboBox',
	'ContextMenu', 'Label', 'ProgressBar', 'PushButton', 'RadioBox',
	'ScrollArea', 'ScrollBar', 'SpinBox', 'TabBar',
	'TextInput', 'Window'
)

ikkuna.MouseButton = enum('Primary', 'Secondary', 'Middle')

ikkuna.WidgetName = {}
ikkuna.WidgetName[ikkuna.WidgetType.Widget] = 'Widget'
ikkuna.WidgetName[ikkuna.WidgetType.Button] = 'Button'
ikkuna.WidgetName[ikkuna.WidgetType.CheckBox] = 'CheckBox'
ikkuna.WidgetName[ikkuna.WidgetType.ComboBox] = 'ComboBox'
ikkuna.WidgetName[ikkuna.WidgetType.ContextMenu] = 'ContextMenu'
ikkuna.WidgetName[ikkuna.WidgetType.Label] = 'Label'
ikkuna.WidgetName[ikkuna.WidgetType.ProgressBar] = 'ProgressBar'
ikkuna.WidgetName[ikkuna.WidgetType.PushButton] = 'PushButton'
ikkuna.WidgetName[ikkuna.WidgetType.RadioBox] = 'RadioBox'
ikkuna.WidgetName[ikkuna.WidgetType.ScrollArea] = 'ScrollArea'
ikkuna.WidgetName[ikkuna.WidgetType.ScrollBar] = 'ScrollBar'
ikkuna.WidgetName[ikkuna.WidgetType.SpinBox] = 'SpinBox'
ikkuna.WidgetName[ikkuna.WidgetType.TabBar] = 'TabBar'
ikkuna.WidgetName[ikkuna.WidgetType.TextInput] = 'TextInput'
ikkuna.WidgetName[ikkuna.WidgetType.Window] = 'Window'

ikkuna.Debug = false
ikkuna.ScrollAreaScrollStep = 10
ikkuna.ScrollBarMinKnobSize = 20
ikkuna.RadioBoxCircleSegments = 20
ikkuna.TooltipOffset = {x = 10, y = 10}

function ikkuna.isControlPressed()
	return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')
end

function ikkuna.isShiftPressed()
	return love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
end

function ikkuna.isAltPressed()
	return love.keyboard.isDown('lalt') or love.keyboard.isDown('ralt')
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

function ikkuna.copyTable(t)
	local result = {}
	for key, value in pairs(t) do
		if type(value) == 'table' then
			result[key] = ikkuna.copyTable(value)
		else
			result[key] = value
		end
	end

	return result
end

function ikkuna.dump(t, level)
	local level = level or 0
	for key, value in pairs(t) do
		if type(value) == 'table' then
			print(('%s%s'):format(('\t'):rep(level), key))
			ikkuna.dump(value, level + 1)
		else
			print(('%s%s => %s'):format(('\t'):rep(level), key, value))
		end
	end
end

-- Util
require('src.util.math')
require('src.util.table')
require('src.util.timer')
require('src.util.rect')
require('src.util.set')

-- Base
require('src.gui.event')
require('src.gui.display')
require('src.gui.widget')
require('src.gui.style')

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
require('src.widgets.tabbar')
require('src.widgets.textinput')
require('src.widgets.window')
