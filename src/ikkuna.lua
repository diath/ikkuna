if not class then
	class = require('vendor.middleclass')
end

ikkuna = {}

-- Const
ikkuna.TextAlign = {}
ikkuna.TextAlign.Left = 1
ikkuna.TextAlign.Right = 2
ikkuna.TextAlign.Center = 3

-- Base
require('gui.event')
require('gui.display')
require('gui.widget')
