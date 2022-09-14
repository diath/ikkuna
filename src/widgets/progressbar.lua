local ProgressBar = ikkuna.class('ProgressBar', ikkuna.Widget)

function ProgressBar:initialize(args)
	self.min = 1
	self.max = 100
	self.value = 1
	self.fillWidth = 0
	self.fillColor = {r = 0, g = 0, b = 1, a = 1}
	self.format = '|percent|'

	ikkuna.Widget.initialize(self, args)

	self:setTextAlign({horizontal = ikkuna.TextAlign.Horizontal.Center, vertical = ikkuna.TextAlign.Vertical.Center})
end

function ProgressBar:parseArgs(args)
	if not args then
		return
	end

	ikkuna.Widget.parseArgs(self, args)

	if args.min then
		self:setMin(args.min)
	end

	if args.max then
		self:setMax(args.max)
	end

	if args.value then
		self:setValue(args.value)
	end

	if args.format then
		self:setFormat(args.format)
	end
end

function ProgressBar:drawAt(x, y)
	self:drawBase(x, y)

	if self.fillWidth ~= 0 then
		local color = self.fillColor
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.rectangle('fill', x + 1, y + 1, self.fillWidth, self.height - 2)
	end

	self:drawText(x, y)
end

function ProgressBar:setExplicitSize(width, height)
	ikkuna.Widget.setExplicitSize(self, width, height)
	self:calculateFillWidthAndText()
end

function ProgressBar:setMin(min)
	self.min = min
	self:calculateFillWidthAndText()
end

function ProgressBar:setMax(max)
	self.max = max
	self:calculateFillWidthAndText()
end

function ProgressBar:setValue(value)
	self.value = math.clamp(self.min, value, self.max)
	self:calculateFillWidthAndText()
end

function ProgressBar:calculateFillWidthAndText()
	local ratio = (self.value - self.min) / (self.max - self.min)
	self.fillWidth = math.ceil((self.width - 2) * ratio)

	local text = self.format
	text = text:gsub('|min|', self.min)
	text = text:gsub('|max|', self.max)
	text = text:gsub('|value|', self.value)
	text = text:gsub('|percent|', ('%.02f%%%%'):format(ratio * 100))

	self:setText(text)
end

function ProgressBar:setFormat(format)
	self.format = format
	self:calculateFillWidthAndText()
end

ikkuna.ProgressBar = ProgressBar
