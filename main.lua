require('ikkuna')

local display = nil

function love.load()
	love.window.setMode(ikkuna.Width, ikkuna.Height, {resizable = true})
	love.window.setTitle('ikkuna - GUI library for Love2D.')

	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter('nearest', 'nearest')

	display = ikkuna.Display:new()

	local window = ikkuna.Window:new({
		id = 'Window',
		parent = display.root,
		title = 'ikkuna - GUI library for Love2D.',
		size = {width = 640, height = 480},
		position = {x = 200, y = 25},
		resizeToContentWidget = true,
	})
	local gameRoot = nil

	local content = ikkuna.Widget:new({
		layout = {
			type = 'vertical',
			args = {
				resizeParent = true,
			},
		},
	})

	local tabBar = ikkuna.TabBar:new({
		size = {width = 0, height = 45},
	})

	local widgets = ikkuna.Widget:new({layout = {type = 'vertical', args = {resizeParent = true}}, children = {
		{type = 'Widget', args = {
			size = {width = 0, height = 30},
			padding = 0,
			layout = {type = 'horizontal', args = {fitParent = true}},
			children = {
				{type = 'Button', args = {
					text = 'Button',
				}},
				{type = 'PushButton', args = {
					text = 'Push Button',
				}},
				{type = 'Button', args = {
					text = 'Disabled', disabled = true,
				}},
			}
		}},
		{type = 'ComboBox', args = {
			options = {'One', 'Two', 'Three', 'Four'},
		}},
		{type = 'ProgressBar', args = {
			id = 'progress',
			min = 0, max = 100, value = 50, format = '|value|/|max| (|percent|)',
		}},
		{type = 'SpinBox', args = {
			min = 0, max = 100, value = 50,
		}},
		{type = 'ScrollBar', args = {
			min = 0, max = 100, value = 50,
		}},
		{type = 'TextInput'},
		{type = 'Separator'},
		{type = 'CheckBox', args = {
			text = 'Check Box',
		}},
		{type = 'Widget', args = {
			size = {width = 0, height = 30},
			padding = 0,
			layout = {type = 'horizontal', args = {fitParent = true}},
			children = {
				{type = 'RadioBox', args = {
					id = 'radio1',
					text = 'Choose me!',
				}},
				{type = 'RadioBox', args = {
					id = 'radio2',
					text = 'No, choose me!',
				}},
				{type = 'RadioBox', args = {
					id = 'radio3',
					text = 'Choose me, choose me!',
				}},
			}
		}},
		{type = 'Button', args = {
			text = 'Open Menu',
			events = {
				onClick = function()
					local contextMenu = ikkuna.ContextMenu:new()
					contextMenu:addOption('One')
					contextMenu:addOption('Two')
					contextMenu:addSeparator()
					contextMenu:addOption('Three')
					contextMenu:show()
				end,
			}
		}},
		{type = 'Button', args = {
			text = 'Switch to game UI mockup.',
			events = {
				onClick = function()
					window:hide()
					gameRoot:show()
				end,
			},
		}}
	}})

	local radioGroup = ikkuna.RadioGroup:new()
	radioGroup:addChild(widgets:getChild('radio1', true))
	radioGroup:addChild(widgets:getChild('radio2', true))
	radioGroup:addChild(widgets:getChild('radio3', true))

	tabBar:addTab('Widgets', widgets)

	local layouts = ikkuna.Widget:new({layout = 'vertical', tooltip = 'Test tooltip!'})
	layouts:addChild(ikkuna.Button:new({text = 'Layouts', size = {width = 50, height = 20}}))
	tabBar:addTab('Layouts', layouts)

	local tabContent = ikkuna.Widget:new({
		size = {width = 0, height = 380},
		layout = 'vertical',
	})
	tabBar:setContentWidget(tabContent)

	content:addChild(tabBar)
	content:addChild(tabContent)

	window:setContentWidget(content)
	window:showCentered()

	gameRoot = ikkuna.Widget:new({
		id = 'gameroot',
		parent = display.root,
		visible = false,
		layout = 'anchor',
		anchors = {
			fill = 'parent',
		},
		style = {
			normal = {
				background = 'transparent',
			},
		},
	})

	local buffs = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'buffs',
		layout = 'horizontal',
		size = {width = 250, height = 40},
		margin = 5,
		anchors = {
			top = 'parent.top',
			left = 'parent.left',
		},
		text = 'Buffs',
	})

	local debuffs = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'debuffs',
		layout = 'horizontal',
		size = {width = 250, height = 40},
		margin = 5,
		anchors = {
			top = 'buffs.bottom',
			left = 'parent.left',
		},
		text = 'Debuffs',
	})

	local minimap = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'minimap',
		size = {width = 200, height = 200},
		margin = 5,
		anchors = {
			bottom = 'parent.bottom',
			right = 'parent.right',
		},
		text = 'Minimap',
	})

	local healthInfo = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'healthinfo',
		size = {width = 200, height = 110},
		margin = 5,
		anchors = {
			bottom = 'parent.bottom',
			left = 'parent.left',
		},
		layout = 'vertical',
		children = {
			{type = 'ProgressBar'},
			{type = 'ProgressBar'},
			{type = 'ProgressBar'},
		}
	})

	local areaInfo = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'areainfo',
		size = {width = 200, height = 110},
		margin = 5,
		anchors = {
			top = 'parent.top',
			right = 'parent.right',
		},
		layout = 'vertical',
		children = {
			{type = 'Label', args = {text = 'Area Name'}},
			{type = 'Label', args = {text = 'Area Level: 1337'}},
			{type = 'Label', args = {text = 'Monsters left: 420'}},
		}
	})

	local centerMessage = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'centermessage',
		anchors = {
			centerIn = 'parent',
		},
		resizeToText = true,
		text = {
			label = 'Game message.',
			align = {
				vertical = 'center',
				horizontal = 'center',
			},
		},
	})

	local bossHealthInfo = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'bosshealthinfo',
		anchors = {
			top = 'parent.top',
			horizontalCenter = 'parent.horizontalCenter',
		},
		layout = {
			type = 'vertical',
			args = {
				resizeParent = true
			},
		},
		size = {width = 200, height = 0},
		children = {
			{type = 'Label', args = {
				text = {
					label = 'Boss Name',
				},
			}},
			{type = 'ProgressBar'},
		},
	})

	local buttons = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'buttons',
		anchors = {
			bottom = 'parent.bottom',
			horizontalCenter = 'parent.horizontalCenter',
		},
		layout = {type = 'horizontal', args = {fitParent = true}},
		size = {width = 300, height = 32},
		children = {
			{type = 'Button', args = {text = 'Char'}},
			{type = 'Button', args = {text = 'Inv'}},
			{type = 'Button', args = {text = 'Splls'}},
			{type = 'Button', args = {text = '> Menu', events = {
				onClick = function()
					gameRoot:hide()
					window:show()
				end,
			},}},
		},
	})

	local objectives = ikkuna.Widget:new({
		parent = gameRoot,
		id = 'objectives',
		anchors = {
			right = 'parent.right',
			verticalCenter = 'parent.verticalCenter',
		},
		layout = {type = 'vertical', args = {resizeParent = true}},
		size = {width = 200, height = 32},
		children = {
			{type = 'Label', args = {text = 'Objectives (1)'}},
			{type = 'Label', args = {text = '1. Kill boss.'}},
		},
		style = {
			normal = {
				background = 'transparent',
			},
		},
	})
end

function love.update(delta)
	display:update(delta)
end

function love.draw()
	display:draw()
end

function love.textinput(text)
	if display:onTextInput(text) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.keypressed(key, code, repeated)
	if display:onKeyPressed(key, code, repeated) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.keyreleased(key, code)
	if display:onKeyReleased(key, code) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.mousepressed(x, y, button, touch, presses)
	if display:onMousePressed(x, y, button, touch, presses) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.mousereleased(x, y, button, touch, presses)
	if display:onMouseReleased(x, y, button, touch, presses) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.mousemoved(x, y, dx, dy, touch)
	if display:onMouseMoved(x, y, dx, dy, touch) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.wheelmoved(x, y)
	if display:onWheelMoved(x, y) then
		return
	end

	-- The event was not handled by the UI, process it normally.
end

function love.resize(width, height)
	display:onResize(width, height)
end
