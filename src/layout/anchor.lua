local AnchorLayout = ikkuna.class('AnchorLayout', ikkuna.Layout)

function AnchorLayout:initialize(args)
	ikkuna.Layout.initialize(self)

	local args = args or {}
	self.updatesEnabled = args.updatesEnabled or true
end

function AnchorLayout:updateInternal()
	if not self.parent or #self.parent.children == 0 then
		return
	end

	-- TODO: Order children based on their anchor dependency and detect cyclic dependencies.
	for _, child in pairs(self.parent.children) do
		local anchors = child.anchors
		if anchors then
			local x = child.x
			local y = child.y
			local width = child.width
			local height = child.height

			if anchors.fill then
				local hook = self:getHook(ikkuna.Anchor.Fill, anchors.fill)
				if hook.widget then
					x = hook.widget.x + child.margin.left
					y = hook.widget.y + child.margin.top
					width = hook.widget.width - child.margin.left - child.margin.right
					height = hook.widget.height - child.margin.top - child.margin.bottom
				else
					print(('AnchorLayout::updateInternal: Widget "%s" filled in Widget "%s" which does not exist.'):format(child, anchors.fill))
				end
			elseif anchors.centerIn then
				local hook = self:getHook(ikkuna.Anchor.CenterIn, anchors.centerIn)
				if hook.widget then
					x = hook.widget.x + math.floor(hook.widget.width / 2) - math.floor(child.width / 2)
					y = hook.widget.y + math.floor(hook.widget.height / 2) - math.floor(child.height / 2)
				else
					print(('AnchorLayout::updateInternal: Widget "%s" centerd in Widget "%s" which does not exist.'):format(child, anchors.centerIn))
				end
			else
				if anchors.top and not anchors.bottom then
					local hook = self:getHook(ikkuna.Anchor.Top, anchors.top)
					if hook.widget then
						y = hook.position + hook.widget.margin.bottom + child.margin.top
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (top) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				elseif anchors.bottom and not anchors.top then
					local hook = self:getHook(ikkuna.Anchor.Bottom, anchors.bottom)
					if hook.widget then
						y = hook.position - child.height - child.margin.bottom
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (bottom) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				elseif anchors.top and anchors.bottom then
					local topHook = self:getHook(ikkuna.Anchor.Top, anchors.top)
					if topHook.widget then
						local bottomHook = self:getHook(ikkuna.Anchor.Bottom, anchors.bottom)
						if bottomHook.widget then
							local topHookPosition = self:getHookPosition(topHook.widget, topHook.toAnchor)
							local bottomHookPosition = self:getHookPosition(bottomHook.widget, bottomHook.toAnchor)

							if topHookPosition < bottomHookPosition then
								y = topHookPosition + topHook.widget.margin.bottom + child.margin.top
								height = bottomHookPosition - y - bottomHook.widget.margin.top - child.margin.bottom
							else
								print(('AnchorLayout::updateInternal: Widget "%s" is anchored backwards (bottom > bottom) to Widget "%s" and Widget "%s".'):format(child, bottomHook.widgetName, topHook.widgetName))
							end
						else
							print(('AnchorLayout::updateInternal: Widget "%s" is anchored (bottom) to Widget "%s" which does not exist.'):format(child, bottomHook.widgetName))
						end
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (top) to Widget "%s" which does not exist.'):format(child, topHook.widgetName))
					end
				end

				if anchors.left and not anchors.right then
					local hook = self:getHook(ikkuna.Anchor.Left, anchors.left)
					if hook.widget then
						x = hook.position + hook.widget.margin.right + child.margin.left
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (left) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				elseif anchors.right and not anchors.left then
					local hook = self:getHook(ikkuna.Anchor.Right, anchors.right)
					if hook.widget then
						x = hook.position - child.width - child.margin.right
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (right) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				elseif anchors.left and anchors.right then
					local leftHook = self:getHook(ikkuna.Anchor.Left, anchors.left)
					if leftHook.widget then
						local rightHook = self:getHook(ikkuna.Anchor.Right, anchors.right)
						if rightHook.widget then
							local leftHookPosition = self:getHookPosition(leftHook.widget, leftHook.toAnchor)
							local rightHookPosition = self:getHookPosition(rightHook.widget, rightHook.toAnchor)

							if leftHookPosition < rightHookPosition then
								x = leftHookPosition + leftHook.widget.margin.right + child.margin.left
								width = rightHookPosition - x - rightHook.widget.margin.left - child.margin.right
							else
								print(('AnchorLayout::updateInternal: Widget "%s" is anchored backwards (right > left) to Widget "%s" and Widget "%s".'):format(child, rightHook.widgetName, leftHook.widgetName))
							end
						else
							print(('AnchorLayout::updateInternal: Widget "%s" is anchored (right) to Widget "%s" which does not exist.'):format(child, rightHook.widgetName))
						end
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (left) to Widget "%s" which does not exist.'):format(child, leftHook.widgetName))
					end
				end

				if anchors.horizontalCenter then
					local hook = self:getHook(ikkuna.Anchor.HorizontalCenter, anchors.horizontalCenter)
					if hook.widget then
						x = hook.position - math.floor(child.width / 2)
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (horizontalCenter) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				end

				if anchors.verticalCenter then
					local hook = self:getHook(ikkuna.Anchor.HorizontalCenter, anchors.verticalCenter)
					if hook.widget then
						y = hook.position - math.floor(child.height / 2)
					else
						print(('AnchorLayout::updateInternal: Widget "%s" is anchored (verticalCenter) to Widget "%s" which does not exist.'):format(child, hook.widgetName))
					end
				end
			end

			child:setPosition(x, y)
			child:setExplicitSize(width, height)
		end
	end
end

function AnchorLayout:getHook(fromAnchor, hook)
	if not self.parent then
		return {}
	end

	local parts = hook:split('.')
	local widget = nil
	if parts[1] == 'parent' then
		widget = self.parent
	else
		widget = self.parent:getChild(parts[1])
	end

	if fromAnchor == ikkuna.Anchor.Fill or fromAnchor == ikkuna.Anchor.CenterIn then
		return {widgetName = parts[1], widget = widget}
	end

	if #parts ~= 2 then
		return {widgetName = parts[1]}
	end

	if not widget then
		return {widgetName = parts[1]}
	end

	local toAnchor = ikkuna.AnchorByName[parts[2]]
	local position = self:getHookPosition(widget, toAnchor)
	return {widgetName = parts[1], widget = widget, toAnchor = toAnchor, position = position}
end

function AnchorLayout:getHookPosition(widget, anchor)
	if anchor == ikkuna.Anchor.Left then
		return widget.x
	elseif anchor == ikkuna.Anchor.Right then
		return widget.x + widget.width
	elseif anchor == ikkuna.Anchor.Top then
		return widget.y
	elseif anchor == ikkuna.Anchor.Bottom then
		return widget.y + widget.height
	elseif anchor == ikkuna.Anchor.HorizontalCenter then
		return widget.x + math.floor(widget.width / 2)
	elseif anchor == ikkuna.Anchor.VerticalCenter then
		return widget.y + math.floor(widget.height / 2)
	end

	return 0
end

ikkuna.AnchorLayout = AnchorLayout
