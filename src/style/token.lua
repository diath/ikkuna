local Token = class('StyleToken')

Token.Type = {}
Token.Type.Unknown = 1
Token.Type.String = 2
Token.Type.Number = 3
Token.Type.Identifier = 4
Token.Type.Punctuation = 5
Token.Type.Symbol = 6
Token.Type.Keyword = 7

Token.Names = {}
Token.Names[Token.Type.Unknown] = 'Unknown'
Token.Names[Token.Type.String] = 'String'
Token.Names[Token.Type.Number] = 'Number'
Token.Names[Token.Type.Identifier] = 'Identifier'
Token.Names[Token.Type.Punctuation] = 'Punctuation'
Token.Names[Token.Type.Symbol] = 'Symbol'
Token.Names[Token.Type.Keyword] = 'Keyword'

function Token:initialize(type, value)
	local type = type or Token.Type.Unknown
	local value = value or nil

	self.type = type
	self.value = value
end

function Token:toString()
	local name = Token.Names[self.type]
	if name then
		if self.type == Token.Type.Number then
			return ('Token(type=%d, name=%s, value=%.02f)'):format(self.type, name, self.value)
		else
			return ('Token(type=%d, name=%s, value="%s")'):format(self.type, name, self.value)
		end
	end

	return 'Token(Invalid)'
end

ikkuna.StyleToken = Token
