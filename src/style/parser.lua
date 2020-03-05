local Parser = class('StyleParser')
local Token = ikkuna.StyleToken

function Parser:initialize(lexer)
	self.lexer = lexer
	self:nextToken()
end

function Parser:parse()
	local styles = {}
	while self.token.type ~= Token.Type.Unknown do
		local style = self:parseStyleNode()
		if style then
			table.insert(styles, style)
		end

		self:nextToken()
	end

	return styles
end

function Parser:nextToken()
	self.token = self.lexer:next()
end

function Parser:checkToken(type, value)
	if not value then
		return self.token.type == type
	end

	return self.token.type == type and self.token.value == value
end

function Parser:parseStyleNode()
	local style = {}
	style.name = self.token.value
	style.state = ikkuna.StyleState.Normal
	style.attributes = {}

	self:nextToken()
	if self:checkToken(Token.Type.Symbol, ':') then
		self:nextToken()

		if not self:checkToken(Token.Type.Identifier) then
			self.lexer.stream:warning('Expected an identifier.')
			return
		end

		local state = self.token.value
		if state == 'hover' then
			style.state = ikkuna.StyleState.Hover
		else
			self.lexer.stream:warning(('Unknown style state: %s.'):format(state))
		end

		self:nextToken()
	end

	if not self:checkToken(Token.Type.Punctuation, '{') then
		self.lexer.stream:warning('Expected "{".')
		return
	end
	self:nextToken()

	while self:checkToken(Token.Type.Identifier) do
		local name = self.token.value
		self:nextToken()

		if not self:checkToken(Token.Type.Symbol, ':') then
			self.lexer.stream:warning('Expected ":".')
			return
		end
		self:nextToken()

		local value = self.token.value
		self:nextToken()

		-- NOTE(diath): Semicolons are optional, skip if found.
		if self:checkToken(Token.Type.Punctuation, ';') then
			self:nextToken()
		end

		style.attributes[name] = value
	end

	if not self:checkToken(Token.Type.Punctuation, '}') then
		self.lexer.stream:warning('Expected "}".')
		return
	end

	return style
end

ikkuna.StyleParser = Parser
