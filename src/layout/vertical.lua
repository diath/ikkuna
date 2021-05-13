local VerticalLayout = class('VerticalLayout', ikkuna.Layout)

function VerticalLayout:initialize(options)
	local options = options or {}
	self.updatesEnabled = options.updatesEnabled or true
	self.fitParent = options.fitParent or false
	self.childSpacing = options.childSpacing or 5
end

function VerticalLayout:setParent(parent)
	self.parent = parent
end

function VerticalLayout:setFitParent(fit)
	self.fitParent = fit
	self:update()
end

function VerticalLayout:updateInternal()
	-- TODO: Take padding and margins into account
	if self.fitParent then
		local parent = self.parent

		local spacing = (#parent.children - 1) * self.childSpacing
		local width = parent.width
		local height = (parent.height - spacing) / #parent.children
		local position = 0

		for _, child in pairs(parent.children) do
			child:setPosition(parent.x, position)
			child:setExplicitSize(width, height)

			position = position + height + self.childSpacing
		end
	else
		local parent = self.parent
		local width = parent.width
		local position = 0
		for _, child in pairs(self.parent.children) do
			child:setPosition(parent.x, position)
			child:setExplicitSize(width, child.height)
			position = position + child.height + self.childSpacing
		end
	end
end

ikkuna.VerticalLayout = VerticalLayout
