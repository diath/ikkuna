local ContextMenu = ikkuna.class('ContextMenu', ikkuna.Widget)

function ContextMenu:initialize(args)
	ikkuna.Widget.initialize(self, args)
	self.type = ikkuna.WidgetType.ContextMenu

	self.draggable = false
	self.focusable = false

	self:setLayout(ikkuna.VerticalLayout:new({resizeParent = true}))
end

function ContextMenu:addOption(name, callback)
	local label = ikkuna.Label:new()
	label:setExplicitSize(80, 25)
	label.textAlign.vertical = ikkuna.TextAlign.Vertical.Center
	label.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Left
	label:setText(name)

	label.onClick:connect(function()
		if callback then
			callback()
		end

		if not ikkuna.isControlPressed() then
			self:hide()
			return true
		end

		return false
	end)

	self:addChild(label)
end

function ContextMenu:show(x, y)
	ikkuna.root:addChild(self)
	ikkuna.root:moveChildToBack(widget)

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
