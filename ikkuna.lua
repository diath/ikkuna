local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''

ikkuna = {}

function ikkuna.path(suffix, ext, separator)
	if separator then
		return ('%s%s%s'):format(_PATH:gsub('%.', separator), suffix, ext or '')
	end

	return ('%s%s%s'):format(_PATH, suffix, ext or '')
end

ikkuna.class = require(ikkuna.path('src.vendor.middleclass'))

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
ikkuna.StyleState = enum('Normal', 'Hovered', 'Focused', 'MouseFocused', 'Disabled')
ikkuna.WindowDockMode = enum('None', 'Left', 'Right', 'Top', 'Bottom')

ikkuna.WidgetType = enum(
	'Widget', 'Button', 'CheckBox', 'ComboBox',
	'ContextMenu', 'Label', 'ProgressBar', 'PushButton', 'RadioBox',
	'Separator', 'ScrollArea', 'ScrollBar', 'SpinBox', 'TabBar',
	'TextInput', 'Window'
)

ikkuna.Anchor = enum(
	'Left', 'Right', 'Top', 'Bottom',
	'CenterIn', 'Fill',
	'HorizontalCenter', 'VerticalCenter'
)

ikkuna.AnchorByName = {}
ikkuna.AnchorByName['left'] = ikkuna.Anchor.Left
ikkuna.AnchorByName['right'] = ikkuna.Anchor.Right
ikkuna.AnchorByName['top'] = ikkuna.Anchor.Top
ikkuna.AnchorByName['bottom'] = ikkuna.Anchor.Bottom
ikkuna.AnchorByName['centerIn'] = ikkuna.Anchor.CenterIn
ikkuna.AnchorByName['fill'] = ikkuna.Anchor.Fill
ikkuna.AnchorByName['horizontalCenter'] = ikkuna.Anchor.HorizontalCenter
ikkuna.AnchorByName['verticalCenter'] = ikkuna.Anchor.VerticalCenter

ikkuna.MouseButton = enum('Primary', 'Secondary', 'Middle')
ikkuna.FocusReason = enum('Mouse', 'Keyboard')

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
ikkuna.WidgetName[ikkuna.WidgetType.Separator] = 'Separator'
ikkuna.WidgetName[ikkuna.WidgetType.ScrollArea] = 'ScrollArea'
ikkuna.WidgetName[ikkuna.WidgetType.ScrollBar] = 'ScrollBar'
ikkuna.WidgetName[ikkuna.WidgetType.SpinBox] = 'SpinBox'
ikkuna.WidgetName[ikkuna.WidgetType.TabBar] = 'TabBar'
ikkuna.WidgetName[ikkuna.WidgetType.TextInput] = 'TextInput'
ikkuna.WidgetName[ikkuna.WidgetType.Window] = 'Window'

ikkuna.Colors = {}
ikkuna.Colors['transparent'] = {r = 1, g = 1, b = 1, a = 0}
ikkuna.Colors['green'] = {r = 124/255, g = 168/255, b = 70/255, a = 1}
ikkuna.Colors['blue'] = {r = 120/255, g = 179/255, b = 209/255, a = 1}
ikkuna.Colors['purple'] = {r = 132/255, g = 84/255, b = 202/255, a = 1}
ikkuna.Colors['orange'] = {r = 250/255, g = 155/255, b = 0, a = 1}
ikkuna.Colors['yellow'] = {r = 214/255, g = 161/255, b = 41/255, a = 1}
ikkuna.Colors['red'] = {r = 230/255, g = 39/255, b = 72/255, a = 1}

ikkuna.Debug = false
ikkuna.ScrollAreaScrollStep = 10
ikkuna.ScrollBarMinKnobSize = 20
ikkuna.RadioBoxCircleSegments = 20
ikkuna.TooltipOffset = {x = 10, y = 10}
ikkuna.SeparatorHeight = 2
ikkuna.CheckBoxBoxSize = 15
ikkuna.CheckBoxFrameSize = 2

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
			local knownColor = ikkuna.Colors[color:lower()]
			if knownColor then
				result = knownColor
			else
				print(('ikkuna::parseColor: Unknown named color "%s".'):format(color))
			end
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
require(ikkuna.path('src.util.math'))
require(ikkuna.path('src.util.misc'))
require(ikkuna.path('src.util.table'))
require(ikkuna.path('src.util.timer'))
require(ikkuna.path('src.util.rect'))
require(ikkuna.path('src.util.set'))

-- Base
require(ikkuna.path('src.gui.event'))
require(ikkuna.path('src.gui.display'))
require(ikkuna.path('src.gui.widget'))
require(ikkuna.path('src.gui.style'))
require(ikkuna.path('src.gui.resources'))

-- Layouts
require(ikkuna.path('src.layout.layout'))
require(ikkuna.path('src.layout.anchor'))
require(ikkuna.path('src.layout.horizontal'))
require(ikkuna.path('src.layout.vertical'))

-- Widgets
require(ikkuna.path('src.widgets.button'))
require(ikkuna.path('src.widgets.checkbox'))
require(ikkuna.path('src.widgets.combobox'))
require(ikkuna.path('src.widgets.contextmenu'))
require(ikkuna.path('src.widgets.label'))
require(ikkuna.path('src.widgets.progressbar'))
require(ikkuna.path('src.widgets.pushbutton'))
require(ikkuna.path('src.widgets.radiobox'))
require(ikkuna.path('src.widgets.radiogroup'))
require(ikkuna.path('src.widgets.separator'))
require(ikkuna.path('src.widgets.scrollarea'))
require(ikkuna.path('src.widgets.scrollbar'))
require(ikkuna.path('src.widgets.spinbox'))
require(ikkuna.path('src.widgets.tabbar'))
require(ikkuna.path('src.widgets.textinput'))
require(ikkuna.path('src.widgets.window'))

ikkuna.defaultFont = ikkuna.Resources.getFont(ikkuna.path('res/NotoSansDisplayBold', '.ttf', '/'), 12)
