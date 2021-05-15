local HorizontalLayout = ikkuna.class('HorizontalLayout', ikkuna.Layout)

function HorizontalLayout:initialize(options)
	local options = options or {}
	self.updatesEnabled = options.updatesEnabled or true
	self.fitParent = options.fitParent or false
	self.childSpacing = options.childSpacing or 5
end

function HorizontalLayout:setParent(parent)
	self.parent = parent
end

function HorizontalLayout:setFitParent(fit)
	self.fitParent = fit
	self:update()
end

function HorizontalLayout:updateInternal()
	if not self.parent or #self.parent.children == 0 then
		return
	end

	-- TODO: Take padding and margins into account
	local parent = self.parent
	local position = 0
	local height = parent.height

	if self.fitParent then
		local spacing = (#parent.children - 1) * self.childSpacing
		local width = (parent.width - spacing) / #parent.children

		for _, child in pairs(parent.children) do
			child:setPosition(position, parent.y)
			child:setExplicitSize(width, height)

			position = position + width + self.childSpacing
		end
	else
		for _, child in pairs(self.parent.children) do
			child:setPosition(position, parent.y)
			child:setExplicitSize(child.width, height)
			position = position + child.width + self.childSpacing
		end
	end
end

ikkuna.HorizontalLayout = HorizontalLayout
