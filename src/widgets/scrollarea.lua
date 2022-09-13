local ScrollArea = ikkuna.class('ScrollArea', ikkuna.Widget)
local HorizontalScrollArea = ikkuna.class('HorizontalScrollArea', ScrollArea)
local VerticalScrollArea = ikkuna.class('VerticalScrollArea', ScrollArea)

local ScrollStep = 10

function ScrollArea:initialize(args)
	ikkuna.Widget.initialize(self, args)

	self.draggable = false

	self.offset = {}
	self.offset.x = 0
	self.offset.y = 0
end

function HorizontalScrollArea:initialize(args)
	ikkuna.ScrollArea.initialize(self, args)

	self:setLayout(ikkuna.HorizontalLayout:new())

	self.onMouseWheel:connect(function (dx, dy)
		self:setHorizontalOffset(self.offset.x + (dy * ScrollStep))
	end)
end

function VerticalScrollArea:initialize(args)
	ikkuna.ScrollArea.initialize(self, args)

	self:setLayout(ikkuna.VerticalLayout:new())

	self.onMouseWheel:connect(function (dx, dy)
		self:setVerticalOffset(self.offset.y + (dy * ScrollStep))
	end)
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

ikkuna.ScrollArea = ScrollArea
ikkuna.HorizontalScrollArea = HorizontalScrollArea
ikkuna.VerticalScrollArea = VerticalScrollArea
