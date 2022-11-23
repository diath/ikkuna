local Layout = ikkuna.class('Layout')

function Layout:initialize()
	self.parent = nil
	self.updatesEnabled = true
end

function Layout:setParent(parent)
	self.parent = parent
	self:update()
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

function Layout:disableUpdates()
	self.updatesEnabled = false
end

function Layout:enableUpdates()
	self.updatesEnabled = true
end

ikkuna.Layout = Layout
