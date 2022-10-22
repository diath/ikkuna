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

			if style.hovered then
				local section = ikkuna.copyTable(style.normal)
				for propertyName, propertyValue in pairs(style.hovered) do
					section[propertyName] = propertyValue
				end
				result[ikkuna.StyleState.Hovered] = section
			else
				result[ikkuna.StyleState.Hovered] = ikkuna.copyTable(style.normal)
			end

			if style.disabled then
				local section = ikkuna.copyTable(style.normal)
				for propertyName, propertyValue in pairs(style.disabled) do
					section[propertyName] = propertyValue
				end
				result[ikkuna.StyleState.Disabled] = section
			else
				result[ikkuna.StyleState.Disabled] = ikkuna.copyTable(style.normal)
			end

			self.styles[name] = result
		end
	end

	-- ikkuna.dump(self.styles)
	return true
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
		-- TODO: Error?
		print(('Style::getStyle: Missing style for %s (State: %d)'):format(name, state))
		return {}
	end

	return style[state]
end

ikkuna.Style = Style
