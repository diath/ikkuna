local Lexer = class('StyleLexer')
local Token = ikkuna.StyleToken

Lexer.Whitespace = {' ', '\n', '\t'}
Lexer.Punctuation = {'{', '}', ';'}
Lexer.Symbols = {':'}
Lexer.StringQuotes = {"'", '"'}

Lexer.Comment = '/'
Lexer.CommentMultiline = '*'

Lexer.EscapeMap = {}
Lexer.EscapeMap['r'] = '\r'
Lexer.EscapeMap['n'] = '\n'
Lexer.EscapeMap['t'] = '\t'
Lexer.EscapeMap['\\'] = '\\'
Lexer.EscapeMap['"'] = '"'
Lexer.EscapeMap["'"] = "'"

function Lexer:initialize(stream)
	self.stream = stream
	self.current = Token:new()
end

function Lexer:reset()
	self.stream:reset()
	self.current = Token:new()
end

function Lexer:readNext()
	self:readWhile(Lexer.isWhitespace)

	if self.stream:eof() then
		return Token:new()
	end

	local char = self.stream:peek()
	if char == Lexer.Comment then
		local nextChar = self.stream:peek(1)
		if nextChar == Lexer.Comment then
			self:skipComment()
			return self:readNext()
		else
			self:skipMultilineComment()
			return self:readNext()
		end
	end

	if Lexer.isStringStart(char) then
		return self:readString(char)
	end

	if Lexer.isDigit(char) then
		return self:readNumber()
	end

	if Lexer.isIdentifierStart(char) then
		return self:readIdentifier()
	end

	if Lexer.isPunctuation(char) then
		return self:readPunctuation()
	end

	if Lexer.isSymbol(char) then
		return self:readSymbol()
	end

	return Token:new()
end

function Lexer:readAll()
	local tokens = {}
	while not self:eof() do
		table.insert(tokens, self:next())
	end

	return tokens
end

function Lexer:next()
	local token = self.current
	self.current = Token:new()

	if token.type == Token.Type.Unknown then
		return self:readNext()
	end

	return token
end

function Lexer:peek()
	if self.current.type ~= Token.Type.Unknown then
		return self.current
	end

	self.current = self:readNext()
	return self.current
end

function Lexer:eof()
	return self:peek().type == Token.Type.Unknown
end

function Lexer:readWhile(predicate)
	local result = ''
	while not self.stream:eof() and predicate(self.stream:peek()) do
		result = ('%s%s'):format(result, self.stream:next())
	end

	return result
end

function Lexer:skipComment()
	self:readWhile(function(value)
		return value ~= '\n'
	end)
	self.stream:next()
end

function Lexer:skipMultilineComment()
	self.stream:next()

	local levels = 1
	while not self.stream:eof() and levels > 0 do
		local char = self.stream:peek()
		local nextChar = self.stream:peek(1)

		if char == Lexer.Comment and nextChar == Lexer.CommentMultiline then
			levels = levels + 1
			self.stream:next()
		elseif char == Lexer.CommentMultiline and nextChar == Lexer.Comment then
			levels = levels - 1
			self.stream:next()
		end

		self.stream:next()
	end

	if self.stream:eof() and levels > 0 then
		self.stream:warning('Reached end of file while reading a multiline comment.')
	end
end

function Lexer:readString(quote)
	self.stream:next()

	local escaped = false
	local value = ''

	while not self.stream:eof() do
		local char = self.stream:next()
		if escaped then
			local mapped = Lexer.EscapeMap[char]
			if mapped then
				value = ('%s%s'):format(value, mapped)
			else
				self.stream:warning(('Unknown escape sequence (\\%s).'):format(char))
				value = ('%s%s'):format(value, char)
			end
		elseif char == '\\' then
			escaped = true
		elseif char == quote then
			break
		else
			value = ('%s%s'):format(value, char)
		end
	end

	return Token:new(Token.Type.String, value)
end

function Lexer:readNumber()
	local state = {}

	local function parse(char)
		if char == '.' then
			if state['float'] then
				return false
			end

			state['float'] = true
			return true
		end

		return Lexer.isDigit(char)
	end

	return Token:new(Token.Type.Number, tonumber(self:readWhile(parse)))
end

function Lexer:readIdentifier()
	return Token:new(Token.Type.Identifier, self:readWhile(Lexer.isIdentifier))
end

function Lexer:readPunctuation()
	return Token:new(Token.Type.Punctuation, self:readWhile(Lexer.isPunctuation))
end

function Lexer:readSymbol()
	return Token:new(Token.Type.Symbol, self:readWhile(Lexer.isSymbol))
end

function Lexer.isWhitespace(value)
	return table.contains(Lexer.Whitespace, value)
end

function Lexer.isStringStart(value)
	return table.contains(Lexer.StringQuotes, value)
end

function Lexer.isDigit(value)
	local byte = string.byte(value)
	return byte >= 48 and byte <= 57
end

function Lexer.isIdentifierStart(value)
	local byte = string.byte(value)
	return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) or value == '_'
end

function Lexer.isIdentifier(value)
	return Lexer.isIdentifierStart(value) or Lexer.isDigit(value)
end

function Lexer.isPunctuation(value)
	return table.contains(Lexer.Punctuation, value)
end

function Lexer.isSymbol(value)
	return table.contains(Lexer.Symbols, value)
end

ikkuna.StyleLexer = Lexer
