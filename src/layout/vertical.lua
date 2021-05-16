local VerticalLayout = ikkuna.class('VerticalLayout', ikkuna.Layout)

function VerticalLayout:initialize(args)
	ikkuna.Layout.initialize(self, args.parent)

	local args = args or {}
	self.updatesEnabled = args.updatesEnabled or true
	self.fitParent = args.fitParent or false
	self.childSpacing = args.childSpacing or 5
end

function VerticalLayout:setParent(parent)
	self.parent = parent
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
	local position = parent.padding.top
	local width = parent.width - parent.padding.left - parent.padding.right

	if self.fitParent then
		local spacing = (#parent.children - 1) * self.childSpacing
		local totalHeight = parent.height - parent.padding.top - parent.padding.bottom - spacing
		for index, child in pairs(parent.children) do
			totalHeight = totalHeight - child.margin.top
			if index < #parent.children then
				totalHeight = totalHeight - child.margin.bottom
			end
		end

		local height = math.floor(totalHeight / #parent.children)

		for _, child in pairs(parent.children) do
			position = position + child.margin.top

			child:setPosition(parent.x + parent.padding.left, position)
			child:setExplicitSize(width, height)

			position = position + height + self.childSpacing + child.margin.bottom
		end
	else
		for _, child in pairs(self.parent.children) do
			position = position + child.margin.top

			child:setPosition(parent.x + parent.padding.left, position)
			child:setExplicitSize(width, child.height)

			position = position + child.height + self.childSpacing + child.margin.bottom
		end
	end
end

ikkuna.VerticalLayout = VerticalLayout
