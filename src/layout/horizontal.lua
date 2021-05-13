local HorizontalLayout = class('HorizontalLayout', ikkuna.Layout)

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

function HorizontalLayout:update()
	if not self.updatesEnabled then
		return
	end

	self:updateInternal()
end

function HorizontalLayout:updateInternal()
	-- TODO: Take padding and margins into account
	if self.fitParent then
		local parent = self.parent

		local spacing = (#parent.children - 1) * self.childSpacing
		local width = (parent.width - spacing) / #parent.children
		local height = parent.height
		local position = 0

		for _, child in pairs(parent.children) do
			child:setPosition(position, parent.y)
			child:setExplicitSize(width, height)

			position = position + width + self.childSpacing
		end
	else
		local parent = self.parent
		local height = parent.height
		local position = 0
		for _, child in pairs(self.parent.children) do
			child:setPosition(position, parent.y)
			child:setExplicitSize(child.width, height)
			position = position + child.width + self.childSpacing
		end
	end
end

ikkuna.HorizontalLayout = HorizontalLayout
