ikkuna = {}
ikkuna.class = require('src.vendor.middleclass')

ikkuna.font = love.graphics.newFont('res/Verdana.ttf')
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
