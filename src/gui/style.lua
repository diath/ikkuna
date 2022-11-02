local Style = ikkuna.class('Style')

local AttrBoolean = ikkuna.Set({'draggable', 'focusable', 'visible', 'phantom'})
local AttrNumber = ikkuna.Set({'borderSize'})
local AttrRect = ikkuna.Set({'padding', 'margin'})
local AttrColor = ikkuna.Set({'color', 'background', 'border', 'fillColor'})
local AttrString = ikkuna.Set({})

function Style:initialize()
	self.styles = {}
end

function Style:load(sheet)
	for name, info in pairs(sheet) do
		local style = {}
		for stateName, properties in pairs(info) do
			style[stateName] = {}
			for propertyName, propertyValue in pairs(properties) do
				style[stateName][propertyName] = self:parseProperty(propertyName, propertyValue)
			end
		end

		local result = {}
		if style.normal then
			result[ikkuna.StyleState.Normal] = style.normal
			result[ikkuna.StyleState.Hovered] = self:mergeStyles(style.normal, style.hovered)
			result[ikkuna.StyleState.Focused] = self:mergeStyles(style.normal, style.focused)
			result[ikkuna.StyleState.Disabled] = self:mergeStyles(style.normal, style.disabled)

			self.styles[name] = result
		end
	end

	-- ikkuna.dump(self.styles)
	return true
end

function Style:mergeStyles(base, style)
	if style then
		local section = ikkuna.copyTable(base)
		for propertyName, propertyValue in pairs(style) do
			section[propertyName] = propertyValue
		end

		return section
	end

	return ikkuna.copyTable(base)
end

function Style:parseProperty(name, value)
	if AttrBoolean:contains(name) then
		if type(name) == 'boolean' then
			return value
		end
	elseif AttrNumber:contains(name) then
		return tonumber(value) or 0
	elseif AttrRect:contains(name) then
		if type(value) == 'number' then
			return ikkuna.Rect({all = value, raw = true})
		elseif type(value) == 'table' then
			local rect = ikkuna.Rect()
			rect.top = value.top or 0
			rect.bottom = value.bottom or 0
			rect.left = value.left or 0
			rect.right = value.right or 0
		end
	elseif AttrColor:contains(name) then
		return ikkuna.parseColor(value)
	elseif AttrString:contains(name) then
		if type(value) == 'string' then
			return value
		end
	end

	return nil
end

function Style:getStyle(name, state)
	local style = self.styles[name]
	if not style then
		print(('Style::getStyle: Missing style for %s (state: %d).'):format(name, state))
		return {}
	end

	local style = style[state]
	if not style then
		print(('Style::getStyle: Missing state style for %s (state: %d).'):format(name, state))
		return {}
	end

	return style
end

ikkuna.Style = Style
