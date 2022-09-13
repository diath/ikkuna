require('ikkuna')

local display = nil

function love.load()
	love.keyboard.setKeyRepeat(true)
	display = ikkuna.Display:new()

	local child = ikkuna.Widget:new()
	child.onClick:connect(function() print('onClick()') return true end)
	child.onDoubleClick:connect(function() print('onDoubleClick()') return true end)
	child.onDragStart:connect(function() print('onDragStart()') return true end)
	child.onDragMove:connect(function() print('onDragMove()') return true end)
	child.onDragEnd:connect(function() print('onDragEnd()') return true end)
	child.onResize:connect(function() print('onResize()') end)
	child.onHoverChange:connect(function(widget, hovered) return true end)
	child:setLayout(ikkuna.VerticalLayout({fitParent = true}))
	child:setExplicitSize(140, 340)
	display.root:addChild(child)

	local button = ikkuna.Button:new()
	button:setText('Click/Right Click')
	button.onClick:connect(function() print('Button:onClick()') return true end)
	button.onDoubleClick:connect(function() print('Button:onDoubleClick()') return true end)
	child:addChild(button)

	local menu = ikkuna.ContextMenu:new()
	menu:addOption('Foo', function() print('foo') end)
	menu:addOption('Bar', function() print('bar') end)
	button.contextMenu = menu

	local pushButton = ikkuna.PushButton:new()
	pushButton:setText('Push')
	pushButton.onClick:connect(function() print('PushButton:onClick()') return true end)
	pushButton.onDoubleClick:connect(function() print('PushButton:onDoubleClick()') return true end)
	pushButton.onPushChange:connect(function(widget, state) print('PushButton:onPushChange()') return true end)
	pushButton.onPress:connect(function() print('PushButton:onPress()') return true end)
	child:addChild(pushButton)

	local comboBox = ikkuna.ComboBox:new({options = {'Yes', 'Maybe', {'No', {something = 'something'}}}})
	comboBox.onValueChange:connect(function(widget, selectedIndex, option) print('ComboBox:onValueChange()', option.label, option.data) return true end)
	child:addChild(comboBox)

	local spinBox = ikkuna.SpinBox:new({min = 0, max = 50})
	spinBox.onValueChange:connect(function(widget, value) print('SpinBox:onValueChange()', value) return true end)
	child:addChild(spinBox)

	local textInput = ikkuna.TextInput:new()
	textInput.onFocusChange:connect(function(widget, value) print('TextInput:onFocusChange()', value) return true end)
	child:addChild(textInput)

	local maskButton = ikkuna.Button:new()
	maskButton:setText('Mask')
	maskButton.onClick:connect(function() textInput:setMasked(not textInput.masked) return true end)
	child:addChild(maskButton)

	local draggableButton = ikkuna.Button:new()
	draggableButton:setText('Drag Me')
	draggableButton.draggable = true
	child:addChild(draggableButton)

	local scrollBar = ikkuna.ScrollBar:new({min = 0, max = 5})
	scrollBar.onValueChange:connect(function(widget, value) print('ScrollBar:onValueChange()', value) return true end)
	child:addChild(scrollBar)

	local scrollBarWithValueOnKnob = ikkuna.ScrollBar:new({min = 5, max = 20, displayValue = true})
	scrollBarWithValueOnKnob.onValueChange:connect(function(widget, value) print('ScrollBar:onValueChange()', value) return true end)
	child:addChild(scrollBarWithValueOnKnob)

	local scrollArea = ikkuna.HorizontalScrollArea:new()
	scrollArea.id = 'scrollArea'
	for i = 1, 5 do
		local button = ikkuna.Button:new()
		button:setText(('Button #%d'):format(i))
		scrollArea:addChild(button)
	end
	scrollArea:setPosition(200, 200)
	scrollArea:setExplicitSize(200, 200)
	display.root:addChild(scrollArea)
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
	if display:onKeyReleased(key, code, repeated) then
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
