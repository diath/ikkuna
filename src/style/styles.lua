local Styles = class('Styles')

function Styles:initialize()
	self.styles = {}
end

function Styles:loadFile(path)
	local stream = ikkuna.StyleStream:new()
	if not stream:loadFile(path) then
		return false
	end

	self:loadInternal(stream)
	return true
end

function Styles:loadBuffer(buffer)
	local stream = ikkuna.StyleStream:new()
	if not stream:loadBuffer(path) then
		return false
	end

	self:loadInternal(stream)
	return true
end

function Styles:loadInternal(stream)
	local lexer = ikkuna.StyleLexer:new(stream)
	local parser = ikkuna.StyleParser:new(lexer)

	for _, style in pairs(parser:parse()) do
		if not self.styles[style.name] then
			self.styles[style.name] = {}
		end

		if not self.styles[style.name][style.state] then
			self.styles[style.name][style.state] = {}
		end

		self.styles[style.name][style.state] = table.copy(style.attributes)
	end
end

function Styles:clear()
	self.styles = {}
end

function Styles:getStyle(name, state)
	local style = self.styles[name]
	if not style then
		return nil
	end

	return style[state]
end

function Styles:getStyleById(id, state)
	local style = self.styles[('#%s'):format(id)]
	if not style then
		return nil
	end

	return style[state]
end

ikkuna.Styles = Styles
