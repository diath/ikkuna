local VerticalLayout = ikkuna.class('VerticalLayout', ikkuna.Layout)

function VerticalLayout:initialize(args)
	ikkuna.Layout.initialize(self)

	local args = args or {}
	self.updatesEnabled = args.updatesEnabled or true
	self.fitParent = args.fitParent or false
	self.resizeParent = args.resizeParent or false
	self.childSpacing = args.childSpacing or 5
end

function VerticalLayout:setFitParent(fit)
	self.fitParent = fit
	self:update()
end

function VerticalLayout:updateInternal()
	if not self.parent or #self.parent.children == 0 then
		return
	end

	local parent = self.parent
	local position = parent.y + parent.padding.top
	local width = parent.width - parent.padding.left - parent.padding.right

	if self.fitParent then
		local spacing = (#parent.children - 1) * self.childSpacing
		local totalHeight = parent.height - parent.padding.top - parent.padding.bottom - spacing
		local children = parent:getVisibleChildren()
		for index, child in pairs(children) do
			if child:isVisible() then
				totalHeight = totalHeight - child.margin.top
				if index < #children then
					totalHeight = totalHeight - child.margin.bottom
				end
			end
		end

		local height = math.floor(totalHeight / #children)

		for _, child in pairs(children) do
			if child:isVisible() then
				position = position + child.margin.top

				child:setExplicitSize(width, height)
				child:setPosition(parent.x + parent.padding.left, position)

				position = position + height + self.childSpacing + child.margin.bottom
			end
		end
	else
		local height = parent.padding.top + parent.padding.bottom
		parent:forEachVisibleChild(function(child, isFirst, isLast)
			position = position + child.margin.top + child:getBorderSize()

			child:setExplicitSize(width, child.height)
			child:setPosition(parent.x + parent.padding.left + child:getBorderSize(), position)

			position = position + child.height + self.childSpacing + child.margin.bottom
			height = height + child.margin.top + child.height
			if not isLast then
				height = height + self.childSpacing + child.margin.bottom + (child:getBorderSize() * 2)
			end
		end)

		if self.resizeParent then
			parent:setExplicitSize(parent.width, height)
		end
	end
end

function VerticalLayout:getTotalHeight()
	local parent = self.parent
	local height = parent.padding.top
	parent:forEachVisibleChild(function(child, isFirst, isLast)
		height = height + child.margin.top + child.height
		if not isLast then
			height = height + child.margin.bottom + self.childSpacing
		end
	end)

	return height
end

ikkuna.VerticalLayout = VerticalLayout
