local Resources = {}
Resources.cache = {}

function Resources.getImage(path)
	if Resources.cache[path] then
		return Resources.cache[path]
	end

	local status, image = pcall(love.graphics.newImage, path)
	if not status then
		print(('Resources::getImage: Image "%s" could not be loaded.'):format(path))
		return nil
	end

	Resources.cache[path] = image
	return image
end

function Resources.getFont(path, size)
	local key = ('%s_%d'):format(path, size)
	if Resources.cache[key] then
		return Resources.cache[key]
	end

	local status, font = pcall(love.graphics.newFont, path, size)
	if not status then
		print(('Resources::getFont: Font "%s" could not be loaded.'):format(path))
		return nil
	end

	Resources.cache[key] = font
	return font
end

function Resources.getSound(path)
	if Resources.cache[path] then
		return Resources.cache[path]
	end

	local status, sound = pcall(love.audio.newSource, path, 'static')
	if not status then
		print(('Resources::getSound: Sound "%s" could not be loaded.'):format(path))
		return nil
	end

	sound:setVolume(1)
	Resources.cache[path] = sound
	return sound
end

ikkuna.Resources = Resources
