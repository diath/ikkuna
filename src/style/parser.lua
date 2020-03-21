local Parser = class('StyleParser')
local Token = ikkuna.StyleToken

function Parser:initialize(lexer)
	self.lexer = lexer
	self.variables = {}

	self.functions = {}
	self.functions['rgba'] = Parser.funcrgba

	-- Function aliases
	self.functions['rgb'] = self.functions['rgba']

	self:nextToken()
end

function Parser:parse()
	local styles = {}
	while self.token.type ~= Token.Type.Unknown do
		if self:checkToken(Token.Type.Symbol, '$') then
			self:parseVariable()
		elseif self:checkToken(Token.Type.Identifier) then
			local style = self:parseStyleNode()
			if style then
				table.insert(styles, style)
			end
		else
			self.lexer.stream:warning(('Unknown top level style node (expected an identifier or "$"), found %s.'):format(
				self.token:toString()
			))
			return styles
		end
	end

	return styles
end

function Parser:nextToken()
	self.token = self.lexer:next()
end

function Parser:checkToken(types, value)
	if not value then
		if type(types) == 'table' then
			for _, type in pairs(types) do
				if self.token.type == type then
					return true
				end
			end
		end

		return self.token.type == types
	end

	return self.token.type == types and self.token.value == value
end

function Parser:parseNameValuePair()
	local name = self.token.value
	self:nextToken()

	if not self:checkToken(Token.Type.Symbol, ':') then
		self.lexer.stream:warning('Expected ":".')
		return
	end
	self:nextToken()

	local value = self.token.value
	if self:checkToken(Token.Type.Keyword) then
		if self.token.value == 'true' then
			value = true
		elseif self.token.value == 'false' then
			value = false
		else
			self.lexer.stream:warning('Unknown keyword value.')
			return
		end
	elseif self:checkToken(Token.Type.Symbol, '$') then
		self:nextToken()

		if self:checkToken(Token.Type.Identifier) then
			value = self.variables[self.token.value]
		else
			self.lexer.stream:warning('Expected an identifier.')
			return
		end
	elseif self:checkToken(Token.Type.Identifier) then
		local functionName = self.token.value
		self:nextToken()

		if not self:checkToken(Token.Type.Punctuation, '(') then
			self.lexer.stream:warning('Expected "(".')
			return
		end
		self:nextToken()

		if self:checkToken(Token.Type.Punctuation, ')') then
			if self.functions[functionName] then
				value = self.functions[functionName]()
			else
				self.lexer.stream:warning(('Unknown function "%s".'):format(functionName))
			end
		else
			local params = {}
			if not self:checkToken({Token.Type.Number, Token.Type.String}) then
				self.lexer.stream:warning('Expected a value.')
				return
			end

			table.insert(params, self.token.value)
			self:nextToken()

			while self:checkToken(Token.Type.Punctuation, ',') do
				self:nextToken()

				if not self:checkToken({Token.Type.Number, Token.Type.String}) then
					self.lexer.stream:warning('Expected a value.')
					return
				end

				table.insert(params, self.token.value)
				self:nextToken()
			end
			self:nextToken()

			if self.functions[functionName] then
				value = self.functions[functionName](unpack(params))
			else
				self.lexer.stream:warning(('Unknown function "%s".'):format(functionName))
			end
		end
	end

	self:nextToken()

	-- NOTE(diath): Semicolons are optional, skip if found.
	if self:checkToken(Token.Type.Punctuation, ';') then
		self:nextToken()
	end

	return name, value
end

function Parser:parseVariable()
	self:nextToken()

	local name, value = self:parseNameValuePair()
	if not name or not value then
		return
	end

	self.variables[name] = value
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
		local name, value = self:parseNameValuePair()
		if not name or not value then
			return
		end

		style.attributes[name] = value
	end

	if not self:checkToken(Token.Type.Punctuation, '}') then
		self.lexer.stream:warning('Expected "}".')
		return
	end

	self:nextToken()
	return style
end

function Parser.funcrgba(r, g, b, a)
	local r = (r and r or 255) / 255
	local g = (g and g or 255) / 255
	local b = (b and b or 255) / 255
	local a = (a and a or 255) / 255

	return {
		r = r,
		g = g,
		b = b,
		a = a,
	}
end

ikkuna.StyleParser = Parser
