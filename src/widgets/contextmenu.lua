local ContextMenu = ikkuna.class('ContextMenu', ikkuna.Widget)

function ContextMenu:initialize(args)
	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.ContextMenu

	self.draggable = false
	self.focusable = false

	self:setLayout(ikkuna.VerticalLayout:new({resizeParent = true}))
end

function ContextMenu:addOption(name, callback)
	local button = ikkuna.Button:new({style = 'ContextMenuItem'})
	button:setExplicitSize(80, 25)
	button:setTextAlign({vertical = ikkuna.TextAlign.Vertical.Center, horizontal = ikkuna.TextAlign.Horizontal.Left})
	button:setText(name)

	button.onClick:connect(function()
		if callback then
			callback()
		end

		if not ikkuna.isControlPressed() then
			self:hide()
			return true
		end

		return false
	end)

	self:addChild(button)
end

function ContextMenu:addSeparator()
	local separator = ikkuna.Separator:new()
	separator:setExplicitSize(80, 6)
	self:addChild(separator)
end

function ContextMenu:show(x, y)
	if not x and not y then
		x, y = love.mouse.getPosition()
	end

	ikkuna.root:addChild(self)
	ikkuna.root:moveChildToBack(self)

	self:setPosition(x, y)
	ikkuna.Widget.show(self)
	ikkuna.contextMenu = self
end

function ContextMenu:hide()
	if self.parent then
		self.parent:removeChild(self)
	end
end

ikkuna.ContextMenu = ContextMenu
