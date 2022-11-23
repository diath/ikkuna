-- TODO: We should return utility functions as a table and keep them within ikkuna namespace.
function string.split(self, separator)
	local chunks = {}
	for chunk in self:gmatch(('([^%s]+)'):format(separator)) do
		-- TODO: Trim the chunks?
		table.insert(chunks, chunk)
	end
	return chunks
end
