local ProgressBar = ikkuna.class('ProgressBar', ikkuna.Widget)

function ProgressBar:initialize()
	ikkuna.Widget.initialize(self)

	self.textAlign.horizontal = ikkuna.TextAlign.Horizontal.Center

	self.min = 1
	self.max = 100
	self.value = 1
	self.fillWidth = 0
	self.fillColor = {r = 0, g = 0, b = 1, a = 1}
end

function ProgressBar:draw()
	self:drawAt(self.x, self.y)
end

function ProgressBar:drawAt(x, y)
	ikkuna.Widget.draw(self)

	if self.fillWidth ~= 0 then
		local color = self.fillColor
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.rectangle('fill', x + 1, y + 1, self.fillWidth, self.height - 2)
	end
end

function ProgressBar:setMinimum(min)
	self.min = min
	self:calculateFillWidth()
end

function ProgressBar:setMaximum(max)
	self.max = max
	self:calculateFillWidth()
end

function ProgressBar:setValue(value)
	self.value = math.clamp(self.min, value, self.max)
	self:calculateFillWidth()
end

function ProgressBar:calculateFillWidth()
	local ratio = (self.value - self.min) / (self.max - self.min)
	self.fillWidth = math.ceil((self.width - 2) * ratio)
	self:setText(('%d%%'):format(ratio * 100))
end

ikkuna.ProgressBar = ProgressBar
