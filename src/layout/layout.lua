local Layout = class('Layout')

function Layout:initialize(parent)
	self.parent = parent
	self.updatesEnabled = true
end

function Layout:setParent(parent)
	self.parent = parent
end

function Layout:update()
	if not self.updatesEnabled then
		return
	end

	if not self.parent or #self.parent.children == 0 then
		return
	end

	self:updateInternal()
end

function Layout:updateInternal()
end

ikkuna.Layout = Layout
