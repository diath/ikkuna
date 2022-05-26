local HorizontalLayout = ikkuna.class('HorizontalLayout', ikkuna.Layout)

function HorizontalLayout:initialize(args)
	ikkuna.Layout.initialize(self)

	local args = args or {}
	self.updatesEnabled = args.updatesEnabled or true
	self.fitParent = args.fitParent or false
	self.resizeParent = args.resizeParent or false
	self.childSpacing = args.childSpacing or 5
end

function HorizontalLayout:setFitParent(fit)
	self.fitParent = fit
	self:update()
end

function HorizontalLayout:updateInternal()
	if not self.parent or #self.parent.children == 0 then
		return
	end

	local parent = self.parent
	local position = parent.x + parent.padding.left
	local height = parent.height - parent.padding.top - parent.padding.right

	if self.fitParent then
		local spacing = (#parent.children - 1) * self.childSpacing
		local total = parent.width - parent.padding.left - parent.padding.right - spacing
		for index, child in pairs(parent.children) do
			totalWidth = totalWidth - child.margin.left
			if index < #parent.children then
				totalWidth = totalWidth - child.margin.right
			end
		end

		local width = math.floor(totalWidth / #parent.children)

		for _, child in pairs(parent.children) do
			position = position + child.margin.left

			child:setExplicitSize(width, height)
			child:setPosition(position, parent.y + parent.padding.top)

			position = position + width + self.childSpacing + child.margin.right
		end
	else
		local width = parent.padding.left
		for _, child in pairs(parent.children) do
			position = position + child.margin.left

			child:setExplicitSize(child.width, height)
			child:setPosition(position, parent.y + parent.padding.top)

			position = position + child.width + self.childSpacing + child.margin.right
			width = width + child.margin.left + child.width + child.margin.right + self.childSpacing
		end

		if self.resizeParent then
			parent:setExplicitSize(width, parent.height)
		end
	end
end

ikkuna.HorizontalLayout = HorizontalLayout
