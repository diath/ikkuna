local ScrollArea = ikkuna.class('ScrollArea', ikkuna.Widget)

function ScrollArea:initialize(args)
	self.offset = {}
	self.offset.x = 0
	self.offset.y = 0
	self.orientation = ikkuna.ScrollAreaOrientation.Vertical

	ikkuna.Widget.initialize(self, args)

	self:setOrientation(self.orientation)

	self.draggable = false
	self.scrollbar = nil
end

function ScrollArea:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.orientation then
		if type(args.orientation) == 'number' then
			self:setOrientation(args.orientation)
		elseif type(args.orientation) == 'string' then
			if args.orientation == 'horizontal' then
				self:setOrientation(ikkuna.ScrollAreaOrientation.Horizontal)
			elseif args.orientation == 'vertical' then
				self:setOrientation(ikkuna.ScrollAreaOrientation.Vertical)
			end
		end
	end
end

function ScrollArea:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)
end

function ScrollArea:drawAt(x, y)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle('line', x, y, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setScissor(x, y, self.width, self.height)

	-- TODO: Only draw children that partially fall within the area.
	for _, child in pairs(self.children) do
		if child:isVisible() then
			child:drawAt(child.x + self.offset.x, child.y + self.offset.y)
		end
	end

	love.graphics.setScissor()
end

function ScrollArea:setOrientation(orientation)
	if self.orientation == ikkuna.ScrollAreaOrientation.Horizontal then
		self:setLayout(ikkuna.HorizontalLayout:new())

		self.onMouseWheel:clear()
		self.onMouseWheel:connect(function (dx, dy)
			-- TODO: Update the scrollbar if present without firing the onValueChange callback?
			self:setHorizontalOffset(self.offset.x + (dy * ikkuna.ScrollAreaScrollStep))
		end)
	elseif self.orientation == ikkuna.ScrollAreaOrientation.Vertical then
		self:setLayout(ikkuna.VerticalLayout:new())

		self.onMouseWheel:clear()
		self.onMouseWheel:connect(function (dx, dy)
			-- TODO: Update the scrollbar if present without firing the onValueChange callback?
			self:setVerticalOffset(self.offset.y + (dy * ikkuna.ScrollAreaScrollStep))
		end)
	end

	self.orientation = orientation
end

function ScrollArea:setOffset(x, y)
	self:setHorizontalOffset(x)
	self:setVerticalOffset(y)
end

function ScrollArea:setHorizontalOffset(offset)
	self.offset.x = math.clamp(-(self.layout:getTotalWidth() - self.width), offset, 0)
end

function ScrollArea:setVerticalOffset(offset)
	self.offset.y = math.clamp(-(self.layout:getTotalHeight() - self.height), offset, 0)
end

function ScrollArea:setScrollbar(scrollbar)
	self.scrollbar = scrollbar
	if self.orientation == ikkuna.ScrollAreaOrientation.Horizontal then
		self.scrollbar:setMax(self.layout:getTotalWidth() - self.width)
	elseif self.orientation == ikkuna.ScrollAreaOrientation.Vertical then
		self.scrollbar:setMax(self.layout:getTotalHeight() - self.height)
	end
	self.scrollbar:setMin(0)
	self.scrollbar:setValue(0)

	scrollbar.onValueChange:connect(function(scrollbar, value)
		if self.orientation == ikkuna.ScrollBarOrientation.Horizontal then
			self:setHorizontalOffset(-value)
		elseif self.orientation == ikkuna.ScrollBarOrientation.Vertical then
			self:setVerticalOffset(-value)
		end
	end)
end

ikkuna.ScrollArea = ScrollArea
