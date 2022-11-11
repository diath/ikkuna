require('ikkuna')

local display = nil

function love.load()
	love.keyboard.setKeyRepeat(true)
	display = ikkuna.Display:new()

	local window = ikkuna.Window:new({
		id = 'Window',
		title = 'TabBar Test',
		size = {width = 640, height = 480},
		position = {x = 200, y = 25},
	})

	local content = ikkuna.Widget:new({layout = 'vertical'})

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
			min = 0, max = 100, value = 50, format = '|value|/|max| (|percent|)',
		}},
		{type = 'SpinBox', args = {
			min = 0, max = 100, value = 50,
		}},
		{type = 'ScrollBar', args = {
			min = 0, max = 100, value = 50,
		}},
		{type = 'TextInput', args = {
		}},
		{type = 'Separator', args = {
		}},
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

	display.root:addChild(window)
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
