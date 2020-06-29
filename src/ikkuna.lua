if not class then
	class = require('vendor.middleclass')
end

ikkuna = {}
ikkuna.font = love.graphics.newFont('res/Verdana.ttf')

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

ikkuna.StyleState = {}
ikkuna.StyleState.Normal = 1
ikkuna.StyleState.Hover = 2

ikkuna.Mouse = {}
ikkuna.Mouse.Button = {}
ikkuna.Mouse.Button.Primary = 1
ikkuna.Mouse.Button.Secondary = 2
ikkuna.Mouse.Button.Middle = 3

-- Util
require('util.math')
require('util.table')

-- Style
require('style.stream')
require('style.token')
require('style.lexer')
require('style.parser')
require('style.styles')

-- Base
require('gui.event')
require('gui.display')
require('gui.widget')

-- Widgets
require('widgets.button')
require('widgets.checkbox')
require('widgets.progressbar')
require('widgets.pushbutton')
require('widgets.radiobox')
require('widgets.radiogroup')
require('widgets.label')
